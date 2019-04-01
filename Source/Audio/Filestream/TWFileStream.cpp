//
//  TWFileStream.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/25/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWFileStream.h"


//--- Init ---//

TWFileStream::TWFileStream()
{
    _leftBuffer                     = new TWRingBuffer(kAudioFileRingBufferSize);
    _rightBuffer                    = new TWRingBuffer(kAudioFileRingBufferSize);
    
    _sampleRate                     = kDefaultSampleRate;
    
    _isRunning                      = false;
    _isStopping                     = false;
    _stopSampleCounter              = 0;
    
    _audioFile                      = nullptr;
    _currentFrame                   = 0;
    _framesRead                     = 0;
    _lengthInFrames                 = 0;
    _drumPadMode                    = TWDrumPadMode_OneShot;
    _sourceIdx                      = 0;
    _entireFileInsideRingBuffer     = false;
    _playbackStatus                 = TWPlaybackStatus_Uninitialized;
    _playbackDirection              = TWPlaybackDirection_Forward;
    _finishedPlaybackProc           = nullptr;
    _fileReadError                  = false;
    _endOfFileReached               = false;
    
    _readABL                        = _allocateABL(kNumChannels, kNumChannels * 4, true, kAudioFileReadBufferNumFrames * kNumChannels);
    
    _velocity.setTargetValue(1.0f, 0.0f);
    _maxVolume.setTargetValue(1.0f, 0.0f);
    _fadeOutGain.setTargetValue(1.0f, 0.0f);
}

TWFileStream::~TWFileStream()
{
    delete _leftBuffer;
    delete _rightBuffer;
    
    _leftBuffer = nullptr;
    _rightBuffer = nullptr;
    
    _deallocateABL(_readABL);
    
    _finishedPlaybackProc = nullptr;
}



//--- Audio Source Methods ---//

void TWFileStream::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    _setIsRunning(true);
}

void TWFileStream::getSample(float& leftSample, float& rightSample)
{
    if (!_isRunning) {
        return;
    }
    
    _stopTick();
    
    if ((_drumPadMode == TWDrumPadMode_OneShot) && (_currentFrame >= _lengthInFrames)) {
        _isStopping = false;
        _isRunning = false;
        _stopSampleCounter = 0;
        dispatch_async(_notificationQueue, ^{
            if (_finishedPlaybackProc != nullptr) {
                _finishedPlaybackProc(_sourceIdx, true);
            }
        });
        return;
    }
    
    if (!_entireFileInsideRingBuffer) {
        
        uint32_t readIdx = _leftBuffer->getReadIdx();
        
        if (readIdx == (kAudioFileRingBufferSize * 0.25))
        {
            _leftBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.5);
            _rightBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.5);
            printf("Phase 1! %d\n", readIdx);
            _readNextBlock();
        }
        
        else if (readIdx == (kAudioFileRingBufferSize * 0.5)) {
            _leftBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.75);
            _rightBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.75);
            printf("Phase 2! %d\n", readIdx);
            _readNextBlock();
        }
        
        else if (readIdx == (kAudioFileRingBufferSize * 0.75)) {
            _leftBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.25);
            _rightBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.25);
            printf("Phase 3! %d\n", readIdx);
            _readNextBlock();
        }
    }
    
    
    float velocity = _velocity.getCurrentValue();
    float maxVolume = _maxVolume.getCurrentValue();
    float fadeOutGain = _fadeOutGain.getCurrentValue();
    
    leftSample += (velocity * maxVolume * fadeOutGain * _leftBuffer->read());
    rightSample += (velocity * maxVolume * fadeOutGain * _rightBuffer->read());
    
    _leftBuffer->incReadIdx();
    _rightBuffer->incReadIdx();
    
    
    if (!_entireFileInsideRingBuffer) {
        uint32_t readIdx = _leftBuffer->getReadIdx();
        if (readIdx == 0) {
            _leftBuffer->setReadIdx(kAudioFileRingBufferSize * 0.25);
            _rightBuffer->setReadIdx(kAudioFileRingBufferSize * 0.25);
            printf("Phase 4! %d\n", readIdx);
        }
    }
    
    _currentFrame += 1;
}

void TWFileStream::release()
{
    _setIsRunning(false);
}


//--- Setup Methods ---//

void TWFileStream::setReadQueue(dispatch_queue_t readQueue)
{
    _readQueue = readQueue;
}

void TWFileStream::setNotificationQueue(dispatch_queue_t notificationQueue)
{
    _notificationQueue = notificationQueue;
}

int TWFileStream::loadAudioFile(std::string filepath)
{
    if (_isRunning) {
        stop();
    }
    
    _resetAudioFile();
    
    
    CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, filepath.c_str(), kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, string, NULL);
    
    OSStatus status = ExtAudioFileOpenURL(url, &_audioFile);
    
    CFRelease(url);
    CFRelease(string);
    
    if ((status != noErr) || (_audioFile == NULL)) {
        printf("\nError in ExtAudioFileOpenURL (%s) : %d\n", filepath.c_str(), (unsigned int)status);
        _resetAudioFile();
        return -1;
    }
    
    
    
    AudioStreamBasicDescription outASBD;
    outASBD.mSampleRate = _sampleRate;
    outASBD.mFormatID = kAudioFormatLinearPCM;
    outASBD.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    outASBD.mBitsPerChannel = 32;
    outASBD.mChannelsPerFrame = 2;
    outASBD.mBytesPerFrame = outASBD.mChannelsPerFrame * 4;
    outASBD.mFramesPerPacket = 1;
    outASBD.mBytesPerPacket = outASBD.mFramesPerPacket * outASBD.mBytesPerFrame;
//    _printASBD(&outASBD, "TWFileStream: Out ASBD");
    
    status = ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(outASBD), &outASBD);
    if (status) {
        printf("\nError in setting kExtAudioFileProperty_ClientDataFormat : %d\n", (unsigned int)status);
        _resetAudioFile();
        return -2;
    }
    
    
    
    AudioStreamBasicDescription inASBD;
    UInt32 propSize = sizeof(inASBD);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileDataFormat, &propSize, &inASBD);
    if (status) {
        printf("\nError in reading kExtAudioFileProperty_FileDataFormat : %d\n", (unsigned int)status);
        _resetAudioFile();
    }
//    _printASBD(&inASBD, "TWFileStream: inFileASBD");
    if (inASBD.mSampleRate <= 0) {
        printf("\nError in kExtAudioFileProperty_FileDataFormat, invalid file sample rate : %f\n", inASBD.mSampleRate);
        return -3;
    }
    
    
    SInt64 length = 0;
    propSize = sizeof(SInt64);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileLengthFrames, &propSize, &length);
    if (status) {
        printf("\nError in reading kExtAudioFileProperty_FileLengthFrames : %d\n", (unsigned int)status);
        _resetAudioFile();
        return -4;
    }
    if (length <= 0) {
        printf("\nError in reading kExtAudioFileProperty_FileLengthFrames : length: %lld\n", length);
        _resetAudioFile();
        return -5;
    }
    
    
    _leftBuffer->reset();
    _rightBuffer->reset();
    
    
    _lengthInFrames = uint32_t((_sampleRate * length) / inASBD.mSampleRate);
    
    if (_lengthInFrames <= kAudioFileRingBufferSize) {
        _entireFileInsideRingBuffer = true;
        _leftBuffer->setReadWrapPoint(_lengthInFrames);
        _rightBuffer->setReadWrapPoint(_lengthInFrames);
        
        _leftBuffer->setWriteWrapPoint(_lengthInFrames);
        _rightBuffer->setWriteWrapPoint(_lengthInFrames);
        
        _readEntireAudioFile();
    }
    
    else { // if !_entireFileInsideRingBuffer
        _readNextBlock();
    }
    
    _currentFrame = 0;
    _setPlaybackStatus(TWPlaybackStatus_Stopped);
    
    printf("\nLoad Audio File (%s) of %u total frames.\n\n", filepath.c_str(), _lengthInFrames);
    
    return 0;
}



//--- Transport Methods ---//

int TWFileStream::start(uint32_t startSampleTime)
{
    if (_playbackStatus == TWPlaybackStatus_Uninitialized) {
        printf("TWFileStream::start Error! File stream status is %s\n", _playbackStatusToString(_playbackStatus).c_str());
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), _notificationQueue, ^{
            if (_finishedPlaybackProc != nullptr) {
                _finishedPlaybackProc(_sourceIdx, false);
            }
        });
        return -1;
    }
    
    _leftBuffer->setReadIdx((int)startSampleTime);
    _rightBuffer->setReadIdx((int)startSampleTime);
    
    _leftBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.25);
    _rightBuffer->setWriteIdx(kAudioFileRingBufferSize * 0.25);
    _readNextBlock();
    
    _currentFrame = startSampleTime;
    _fadeOutGain.setTargetValue(1.0f, 0.0f);
    _isRunning = true;
    _setPlaybackStatus(TWPlaybackStatus_Playing);
//    printf("Start! [%d]\n", _sourceIdx);
    return 0;
}

void TWFileStream::stop()
{
    uint32_t stopInSamples = kAudioFilePlaybackFadeOutTime_ms * _sampleRate / 1000.0f;
    _fadeOutGain.setTargetValue(0.0f, stopInSamples);
    _setStopStatusAfterSamples(stopInSamples);
}

float TWFileStream::getNormalizedPlaybackProgress()
{
    return 0.0f;
}

TWPlaybackStatus TWFileStream::getPlaybackStatus()
{
    return _playbackStatus;
}

void TWFileStream::setVelocity(float velocity, float rampTime_ms)
{
    _velocity.setTargetValue(velocity, rampTime_ms * _sampleRate / 1000.0f);
}

float TWFileStream::getVelocity()
{
    return _velocity.getTargetValue();
}

void TWFileStream::setMaxVolume(float maxVolume, float rampTime_ms)
{
    _maxVolume.setTargetValue(maxVolume, rampTime_ms * _sampleRate / 1000.0f);
}

float TWFileStream::getMaxVolume()
{
    return _maxVolume.getTargetValue();
}

void TWFileStream::setPlaybackDirection(TWPlaybackDirection newDirection)
{
    _playbackDirection = newDirection;
}

TWPlaybackDirection TWFileStream::getPlaybackDirection()
{
    return _playbackDirection;
}


void TWFileStream::setDrumPadMode(TWDrumPadMode drumPadMode)
{
    _drumPadMode = drumPadMode;
}

TWDrumPadMode TWFileStream::getDrumPadMode()
{
    return _drumPadMode;
}

void TWFileStream::setSourceIdx(int sourceIdx)
{
    _sourceIdx = sourceIdx;
    _leftBuffer->setDebugID(sourceIdx);
    _rightBuffer->setDebugID(sourceIdx);
}

int TWFileStream::getSourceIdx()
{
    return _sourceIdx;
}

void TWFileStream::setFinishedPlaybackProc(std::function<void(int,bool)> finishedPlaybackProc)
{
    _finishedPlaybackProc = finishedPlaybackProc;
}




void TWFileStream::_printASBD(AudioStreamBasicDescription* asbd, std::string context) {
    printf("\nASBD (%s): ", context.c_str());
    printf("\nmSampleRate: %f",  asbd->mSampleRate);
    printf("\nmFormatID: %u",  (unsigned int)asbd->mFormatID);
    printf("\nmFormatFlags: %u",  (unsigned int)asbd->mFormatFlags);
    printf("\nmBitsPerChannel: %d",  asbd->mBitsPerChannel);
    printf("\nmChannelsPerFrame: %d",  asbd->mChannelsPerFrame);
    printf("\nmBytesPerFrame: %d",  asbd->mBytesPerFrame);
    printf("\nmFramesPerPacket: %d",  asbd->mFramesPerPacket);
    printf("\nmBytesPerPacket: %d",  asbd->mBytesPerPacket);
    printf("\n");
}

void TWFileStream::_printABL(AudioBufferList *abl, std::string context)
{
    printf("\nABL (%s):", context.c_str());
    printf("\nmNumBuffers: %d", abl->mNumberBuffers);
    for (int buffer=0; buffer < abl->mNumberBuffers; buffer++) {
        printf("\nBuffer[%d]. mNumChannels: %d, mDataByteSize: %d", buffer, abl->mBuffers[buffer].mNumberChannels, abl->mBuffers[buffer].mDataByteSize);
    }
    printf("\n");
}


AudioBufferList* TWFileStream::_allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames)
{
    AudioBufferList *bufferList = NULL;
    
    UInt32 numBuffers = interleaved ? 1 : channelsPerFrame;
    UInt32 channelsPerBuffer = interleaved ? channelsPerFrame : 1;
    
    bufferList = static_cast<AudioBufferList*>(calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * numBuffers)));
    
    bufferList->mNumberBuffers = numBuffers;
    
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
        bufferList->mBuffers[bufferIndex].mData = static_cast<void *>(calloc(capacityFrames, bytesPerFrame));
        bufferList->mBuffers[bufferIndex].mDataByteSize = capacityFrames * bytesPerFrame;
        bufferList->mBuffers[bufferIndex].mNumberChannels = channelsPerBuffer;
    }
    
    return bufferList;
}

void TWFileStream::_deallocateABL(AudioBufferList* abl)
{
    if (abl == nullptr) {
        return;
    }
    
    for (UInt32 bufferIdx=0; bufferIdx < abl->mNumberBuffers; bufferIdx++) {
        if (abl->mBuffers[bufferIdx].mData != nullptr) {
            free(abl->mBuffers[bufferIdx].mData);
        }
    }
    free(abl);
    abl = nullptr;
}


void TWFileStream::_readNextBlock()
{
    dispatch_async(_readQueue, ^{
        
        UInt32 framesRead = _readHelper(kAudioFileReadBufferNumFrames);
        
        if (framesRead == 0) {
            _endOfFileReached = true;
            ExtAudioFileSeek(_audioFile, kAudioFileReadBufferNumFrames);
            if (_drumPadMode == TWDrumPadMode_OneShot) {
                dispatch_async(_notificationQueue, ^{
                    if (_finishedPlaybackProc != nullptr) {
                        _finishedPlaybackProc(_sourceIdx, true);
                    }
                });
            }
            SInt64 frameOffset = 0;
            ExtAudioFileTell(_audioFile, &frameOffset);
            printf("_readNextBlock . Test File position %lld\n", (long long)frameOffset);
        }
        
        _framesRead += framesRead;
    });
}

void TWFileStream::_readEntireAudioFile()
{
    if (!_entireFileInsideRingBuffer) {
        printf("Error! Entire file of size(%u) will not fit in ring buffer", _lengthInFrames);
        return;
    }
    
    printf("Reading entire audio file [%d]\n", _sourceIdx);
    
    dispatch_async(_readQueue, ^{
        UInt32 framesRead = kAudioFileReadBufferNumFrames;
        while (framesRead != 0) {
            framesRead = _readHelper(kAudioFileReadBufferNumFrames);
            _framesRead += framesRead;
        }
        _smoothLoopPoint();
    });
}

uint32_t TWFileStream::_readHelper(uint32_t framesToRead)
{
    // Note must be called inside dispatch_async
    UInt32 readFrames = framesToRead;
    OSStatus status = ExtAudioFileRead(_audioFile, &readFrames, _readABL);
    if (status) {
        printf("Error in ExtAudioFileRead. Error: %d\n", status);
        _fileReadError = true;
        stop();
        _resetAudioFile();
        return 0;
    }
    
    if (readFrames != 0) {
        float* buffer = (float*)_readABL->mBuffers[0].mData;
        for (UInt32 i=0; i < readFrames * _readABL->mBuffers[0].mNumberChannels; i++) {
            if ((i % 2) == 0) {
                _leftBuffer->writeAndIncIdx(buffer[i]);
//                printf("[%f, ", buffer[i]);
            } else {
                _rightBuffer->writeAndIncIdx(buffer[i]);
//                printf("%f],\n", buffer[i]);
            }

        }
        _fileReadError = false;
    }
    
    SInt64 frameOffset = 0;
    status = ExtAudioFileTell(_audioFile, &frameOffset);
    printf("_readHelper [%d], read %u frames, total %u frames. File position %lld\n", _sourceIdx, readFrames, _framesRead, (long long)frameOffset);
    return readFrames;
}


void TWFileStream::_resetAudioFile()
{
    if (_audioFile) {
        printf("Dispose Audio File\n");
        ExtAudioFileDispose(_audioFile);
    }
    _audioFile = NULL;
    _lengthInFrames = 0;
    _currentFrame = 0;
    _framesRead = 0;
    _entireFileInsideRingBuffer = false;
    _isStopping = false;
    _stopSampleCounter = 0;
    _isRunning = false;
    _endOfFileReached = false;
    _fileReadError = false;
    
    _leftBuffer->reset();
    _rightBuffer->reset();
    
    _fadeOutGain.setTargetValue(1.0f, 0.0f);
    
    _setPlaybackStatus(TWPlaybackStatus_Uninitialized);
}

void TWFileStream::_setIsRunning(bool isRunning)
{
    _velocity.setIsRunning(isRunning);
    _maxVolume.setIsRunning(isRunning);
    _fadeOutGain.setIsRunning(isRunning);
}


void TWFileStream::_setPlaybackStatus(TWPlaybackStatus newStatus)
{
//    printf("setPlaybackStatus [%d] : %s > %s\n", _sourceIdx, _playbackStatusToString(_playbackStatus).c_str(), _playbackStatusToString(newStatus).c_str());
    _playbackStatus = newStatus;
}


std::string TWFileStream::_playbackStatusToString(TWPlaybackStatus status)
{
    std::string returnString = "Invalid";
    
    switch (status) {
        case TWPlaybackStatus_Uninitialized:
            returnString = "Uninitialized";
            break;
            
        case TWPlaybackStatus_Stopped:
            returnString = "Stopped";
            break;
            
        case TWPlaybackStatus_Playing:
            returnString = "Playing";
            break;
            
        case TWPlaybackStatus_Recording:
            returnString = "Recording";
            break;
            
        default:
            break;
    }
    
    return returnString;
}


void TWFileStream::_smoothLoopPoint()
{
    _leftBuffer->fadeOutTailEnd((kAudioFilePlaybackFadeOutTime_ms / 1000.0f) * _sampleRate);
    _rightBuffer->fadeOutTailEnd((kAudioFilePlaybackFadeOutTime_ms / 1000.0f) * _sampleRate);
}

void TWFileStream::_setStopStatusAfterSamples(uint32_t samples)
{
    _stopSampleCounter = samples;
    _isStopping = true;
}

void TWFileStream::_stopTick()
{
    if (_isStopping) {
        _stopSampleCounter--;
        if (_stopSampleCounter == 0) {
            _isStopping = false;
            _isRunning = false;
            _setPlaybackStatus(TWPlaybackStatus_Stopped);
        }
    }
}

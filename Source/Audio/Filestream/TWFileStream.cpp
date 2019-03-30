//
//  TWFileStream.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/25/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWFileStream.h"

TWFileStream::TWFileStream()
{
    _leftBuffer             = new TWRingBuffer(kAudioFileReadBufferSize);
    _rightBuffer            = new TWRingBuffer(kAudioFileReadBufferSize);
    
    _sampleRate             = kDefaultSampleRate;
    _isRunning              = false;
    _audioFile              = nullptr;
    _currentFrame           = 0;
    _framesRead             = 0;
    _lengthInFrames         = 0;
    _drumPadMode            = TWDrumPadMode_OneShot;
    _sourceIdx              = 0;
    _finishedPlaybackProc   = nullptr;
    
    _readABL                = _allocateABL(kNumChannels, kNumChannels * 4, true, kAudioFileReadBufferSize * kNumChannels);
    
    _velocity.setTargetValue(1.0f, 0.0f);
    _maxVolume.setTargetValue(1.0f, 0.0f);
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
    
    float velocity = _velocity.getCurrentValue();
    float maxVolume = _maxVolume.getCurrentValue();
    
    leftSample += (velocity * maxVolume * _leftBuffer->readAndIncIdx());
    rightSample += (velocity * maxVolume * _rightBuffer->readAndIncIdx());
    
    _currentFrame += 1;
    
    if ((_framesRead - _currentFrame) == (kAudioFileReadBufferSize / 4)) {
//        _readNextBlock();
    }
}

void TWFileStream::release()
{
    _setIsRunning(false);
}

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
    
    if (_audioFile) {
        _resetAudioFile();
    }
    
    
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
    _printASBD(&outASBD, "TWFileStream: Out ASBD");
    
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
    _printASBD(&inASBD, "TWFileStream: inFileASBD");
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
    
    
    _lengthInFrames = uint32_t((_sampleRate * length) / inASBD.mSampleRate);
    
    if (_lengthInFrames <= _leftBuffer->getSize()) {
        _leftBuffer->setWrapPoint(_lengthInFrames);
        _rightBuffer->setWrapPoint(_lengthInFrames);
    }
    
    _leftBuffer->reset();
    _rightBuffer->reset();
    _readNextBlock();
    
    _currentFrame = 0;
    
    printf("\nLoaded Audio File (%s) of %u total samples.\n", filepath.c_str(), _lengthInFrames);
    
    return 0;
}


int TWFileStream::start(uint32_t startSampleTime)
{
    _leftBuffer->setReadIdx((int)startSampleTime);
    _rightBuffer->setReadIdx((int)startSampleTime);
    _currentFrame = startSampleTime;
    _isRunning = true;
//    printf("Start! [%d]\n", _sourceIdx);
    
    // Debug
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2000 * NSEC_PER_MSEC)), _notificationQueue, ^{
//        printf("Dispatch After 2000ms! [%d]\n", _sourceIdx);
        if (_finishedPlaybackProc != nullptr) {
//            printf("Calling Finished Playback Proc! [%d]\n", _sourceIdx);
            _finishedPlaybackProc(_sourceIdx);
        }
    });
    
    return 0;
}

void TWFileStream::stop()
{
    _isRunning = false;
//    printf("\nStop!\n");
}

bool TWFileStream::getIsRunning()
{
    return _isRunning;
}

float TWFileStream::getNormalizedPlaybackProgress()
{
    return 0.0f;
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

void TWFileStream::setFinishedPlaybackProc(std::function<void(int)> finishedPlaybackProc)
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
        
        UInt32 samplesRead = kAudioFileReadBufferSize;
        OSStatus status = ExtAudioFileRead(_audioFile, &samplesRead, _readABL);
        if (status) {
            printf("Error in ExtAudioFileRead. Error: %d\n", status);
            _resetAudioFile();
        } else {
            printf("Samples read : %lu\n", (unsigned long)samplesRead);
            if (samplesRead != 0) {
                _framesRead += samplesRead;
                float* buffer = (float*)_readABL->mBuffers[0].mData;
                for (int i=0; i < samplesRead; i++) {
                    if ((i % 2) == 0) {
                        _leftBuffer->writeAndIncIdx(buffer[i]);
                    } else {
                        _rightBuffer->writeAndIncIdx(buffer[i]);
                    }
                }
            } else {
//                if (_isLooping) {
//                    ExtAudioFileSeek(_audioFile, 0);
//                }
            }
        }
        
    });
}

void TWFileStream::_resetAudioFile()
{
    ExtAudioFileDispose(_audioFile);
    _audioFile = NULL;
    _lengthInFrames = 0;
    _currentFrame = 0;
    _framesRead = 0;
    
    _leftBuffer->reset();
    _rightBuffer->reset();
}

void TWFileStream::_setIsRunning(bool isRunning)
{
    _velocity.setIsRunning(isRunning);
    _maxVolume.setIsRunning(isRunning);
}

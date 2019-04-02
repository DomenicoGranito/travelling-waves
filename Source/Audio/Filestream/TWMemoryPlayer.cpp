//
//  TWMemoryPlayer.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/1/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWMemoryPlayer.h"

#define kAudioFileReadBufferNumFrames           32768

//============================================================================================================
// Init
//============================================================================================================

TWMemoryPlayer::TWMemoryPlayer()
{
    _sampleRate             = kDefaultSampleRate;
    
    _currentVelocity.setTargetValue(1.0f, 0.0f);
    _maxVolume.setTargetValue(1.0f, 0.0f);
    _fadeOutGain.setTargetValue(1.0, 0.0f);
    
    _drumPadMode            = TWDrumPadMode_OneShot;
    _playbackDirection      = TWPlaybackDirection_Forward;
    _sourceIdx              = 0;
    
    _finishedPlaybackProc   = nullptr;
    _readQueue              = nullptr;
    _notificationQueue      = nullptr;
    
    //--- ABL Settings ---//
    float byteDepth         = 4;
    bool isInterleaved      = true;
    _readABL                = _allocateABL(kNumChannels, kNumChannels * byteDepth, isInterleaved, kAudioFileReadBufferNumFrames * kNumChannels);
    
    _buffer                 = nullptr;
    _reset();
}

TWMemoryPlayer::~TWMemoryPlayer()
{
    _reset();
    _deallocateABL(_readABL);
}



//============================================================================================================
// Audio Source Methods
//============================================================================================================

void TWMemoryPlayer::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    _setIsIORunning(true);
}

void TWMemoryPlayer::getSample(float& leftSample, float& rightSample)
{
    if (!_isRunning) {
        return;
    }
    
    _stoppingTick();
    
    float currentVelocity = _currentVelocity.getCurrentValue();
    float maxVolume = _maxVolume.getCurrentValue();
    float fadeOutGain = _fadeOutGain.getCurrentValue();
    
    leftSample += (currentVelocity * maxVolume * fadeOutGain * _buffer[kLeftChannel][_readIdx]);
    rightSample += (currentVelocity * maxVolume * fadeOutGain * _buffer[kRightChannel][_readIdx]);
    
    _incDecReadIdx();
}

void TWMemoryPlayer::release()
{
    _setIsIORunning(false);
}



//============================================================================================================
// Setup Methods
//============================================================================================================

void TWMemoryPlayer::setReadQueue(dispatch_queue_t readQueue)
{
    _readQueue = readQueue;
}


void TWMemoryPlayer::setNotificationQueue(dispatch_queue_t notificationQueue)
{
    _notificationQueue = notificationQueue;
}


int TWMemoryPlayer::loadAudioFile(std::string filepath)
{
    if (_isRunning) {
        stop(0);
    }
    
    
    _reset();
    
    
    
    CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, filepath.c_str(), kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, string, NULL);
    
    OSStatus status = ExtAudioFileOpenURL(url, &_audioFile);
    
    CFRelease(url);
    CFRelease(string);
    
    if ((status != noErr) || (_audioFile == NULL)) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Error in ExtAudioFileOpenURL (%s) : %d\n", _sourceIdx, filepath.c_str(), (unsigned int)status);
        _reset();
        return -1;
    }
    
    
    
    AudioStreamBasicDescription inASBD;
    UInt32 propSize = sizeof(inASBD);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileDataFormat, &propSize, &inASBD);
    if (status) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Error in reading kExtAudioFileProperty_FileDataFormat : %d\n", _sourceIdx, (unsigned int)status);
        _reset();
        return -2;
    }
    //    _printASBD(&inASBD, "TWFileStream: inFileASBD");
    if (inASBD.mSampleRate <= 0) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Error in kExtAudioFileProperty_FileDataFormat, invalid file sample rate : %f\n", _sourceIdx, inASBD.mSampleRate);
        _reset();
        return -3;
    }
    
    
    
    SInt64 length = 0;
    propSize = sizeof(SInt64);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileLengthFrames, &propSize, &length);
    if (status) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Error in reading kExtAudioFileProperty_FileLengthFrames : %d\n", _sourceIdx, (unsigned int)status);
        _reset();
        return -4;
    }
    if (length <= 0) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Error in reading kExtAudioFileProperty_FileLengthFrames : length: %lld\n", _sourceIdx, length);
        _reset();
        return -5;
    }
    
    
    
    _lengthInFrames = uint32_t((_sampleRate * length) / inASBD.mSampleRate);
    
    if (_lengthInFrames > kMemoryPlayerMaxSizeFrames) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Unfortunately, this file is too big for memory player :'( . length: %u\n", _sourceIdx, _lengthInFrames);
        _reset();
        return -6;
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
    
    status = ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(outASBD), &outASBD);
    if (status) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d]. Error in setting kExtAudioFileProperty_ClientDataFormat : %d\n", _sourceIdx, (unsigned int)status);
        _reset();
        return -7;
    }
    
    
    
    _buffer = new float * [kNumChannels];
    for (int c = 0; c < kNumChannels; c++) {
        _buffer[c] = new float[_lengthInFrames];
    }
    
    
    UInt32 framesRead = kAudioFileReadBufferNumFrames;
    while (framesRead > 0) {
        status = _readHelper(&framesRead);
        if (status) {
            _reset();
            return -8;
        }
    }
    
    _fadeOutTailEnd((kAudioFilePlaybackFadeOutTime_ms / 1000.0f) * _sampleRate);
    
    _setPlaybackStatus(TWPlaybackStatus_Stopped);
    
    return 0;
}


void TWMemoryPlayer::setFinishedPlaybackProc(std::function<void(int,bool)>finishedPlaybackProc)
{
    _finishedPlaybackProc = finishedPlaybackProc;
}



//============================================================================================================
// Transport Methods
//============================================================================================================

int TWMemoryPlayer::start(int32_t startSampleTime)
{
    if (_playbackStatus == TWPlaybackStatus_Uninitialized) {
        printf("TWMemoryPlayer::start : Error! Stream is %s\n", _playbackStatusToString(_playbackStatus).c_str());
        dispatch_async(_notificationQueue, ^{
            if (_finishedPlaybackProc != nullptr) {
                _finishedPlaybackProc(_sourceIdx, false);
            }
        });
        return -1;
    }
    
    _setReadIdx(startSampleTime);
    _fadeOutGain.setTargetValue(1.0f, 0.0f);
    _isRunning = true;
    _setPlaybackStatus(TWPlaybackStatus_Playing);
    
    return 0;
}

void TWMemoryPlayer::stop(uint32_t fadeOutSamples)
{    
    if (fadeOutSamples == 0) {
        _stopSampleCounter = 0;
        _isStopping = false;
        _isRunning = false;
    } else {
        _fadeOutGain.setTargetValue(0.0f, fadeOutSamples);
        _stopSampleCounter = fadeOutSamples;
        _isStopping = true;
    }
}

TWPlaybackStatus TWMemoryPlayer::getPlaybackStatus()
{
    return _playbackStatus;
}

float TWMemoryPlayer::getNormalizedPlaybackProgress()
{
    return 0.0f;
}



//============================================================================================================
// Playback Property Methods
//============================================================================================================

void TWMemoryPlayer::setCurrentVelocity(float velocity, float rampTime_ms)
{
    _currentVelocity.setTargetValue(velocity, rampTime_ms * _sampleRate / 1000.0f);
}

float TWMemoryPlayer::getCurrentVelocity()
{
    return _currentVelocity.getTargetValue();
}

void TWMemoryPlayer::setMaxVolume(float maxVolume, float rampTime_ms)
{
    _maxVolume.setTargetValue(maxVolume, rampTime_ms * _sampleRate / 1000.0f);
}

float TWMemoryPlayer::getMaxVolume()
{
    return _maxVolume.getTargetValue();
}

void TWMemoryPlayer::setPlaybackDirection(TWPlaybackDirection newDirection)
{
    _playbackDirection = newDirection;
}

TWPlaybackDirection TWMemoryPlayer::getPlaybackDirection()
{
    return _playbackDirection;
}

void TWMemoryPlayer::setDrumPadMode(TWDrumPadMode drumPadMode)
{
    _drumPadMode = drumPadMode;
}

TWDrumPadMode TWMemoryPlayer::getDrumPadMode()
{
    return _drumPadMode;
}

void TWMemoryPlayer::setSourceIdx(int sourceIdx)
{
    _sourceIdx = sourceIdx;
}

int TWMemoryPlayer::getSourceIdx()
{
    return _sourceIdx;
}




//============================================================================================================
// Private
//============================================================================================================


//----- ASBD Utils -----//

void TWMemoryPlayer::_printASBD(AudioStreamBasicDescription* asbd, std::string context)
{
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

void TWMemoryPlayer::_printABL(AudioBufferList *abl, std::string context)
{
    printf("\nABL (%s):", context.c_str());
    printf("\nmNumBuffers: %d", abl->mNumberBuffers);
    for (int buffer=0; buffer < abl->mNumberBuffers; buffer++) {
        printf("\nBuffer[%d]. mNumChannels: %d, mDataByteSize: %d", buffer, abl->mBuffers[buffer].mNumberChannels, abl->mBuffers[buffer].mDataByteSize);
    }
    printf("\n");
}

AudioBufferList* TWMemoryPlayer::_allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames)
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

void TWMemoryPlayer::_deallocateABL(AudioBufferList* abl)
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



//----- File Read and Reset -----//

OSStatus TWMemoryPlayer::_readHelper(uint32_t * framesToRead)
{
    OSStatus status = ExtAudioFileRead(_audioFile, framesToRead, _readABL);
    if (status) {
        printf("\nTWMemoryPlayer::_readHelper [%d]. Error in ExtAudioFileRead : %d\n", _sourceIdx, (unsigned int)status);
        return status;
    }
    
    float* buffer = (float*)_readABL->mBuffers[0].mData;
    uint32_t framesRead = *framesToRead;
    for (int i = 0; i < framesRead; i++) {
        for (int c = 0; c < kNumChannels; c++) {
            _buffer[c][i] = buffer[(i * kNumChannels) + c];
        }
    }
    
    return 0;
}


void TWMemoryPlayer::_reset()
{
    if (_buffer != nullptr) {
        for (int channel = 0; channel < kNumChannels; channel++) {
            delete [] _buffer[channel];
        }
        delete [] _buffer;
    }
    _buffer = nullptr;
    
    
//    _writeIdx           = 0;
    _readIdx            = 0;
    
    _lengthInFrames     = 0;
//    _currentFrame       = 0;
    
    
    _isStopping         = false;
    _stopSampleCounter  = 0;
    
    _setPlaybackStatus(TWPlaybackStatus_Uninitialized);
    _isRunning          = false;
    
    if (_audioFile) {
        ExtAudioFileDispose(_audioFile);
    }
}



//----- Status Utils -----//

void TWMemoryPlayer::_setPlaybackStatus(TWPlaybackStatus newStatus)
{
    // printf("setPlaybackStatus [%d] : %s > %s\n", _sourceIdx, _playbackStatusToString(_playbackStatus).c_str(), _playbackStatusToString(newStatus).c_str());
    _playbackStatus = newStatus;
}

std::string TWMemoryPlayer::_playbackStatusToString(TWPlaybackStatus status)
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

void TWMemoryPlayer::_setIsIORunning(bool isIORunning)
{
    _currentVelocity.setIsRunning(isIORunning);
    _maxVolume.setIsRunning(isIORunning);
    _fadeOutGain.setIsRunning(isIORunning);
}



//----- Stop Utils -----//

void TWMemoryPlayer::_stoppingTick()
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


//----- Ring Buffer Utilities -----//

void TWMemoryPlayer::_incDecReadIdx()
{
    uint32_t previousReadIdx = _readIdx;
    
    switch (_playbackDirection) {
        
        case TWPlaybackDirection_Forward:
            _readIdx = (_readIdx + 1) % _lengthInFrames;
            break;
            
        case TWPlaybackDirection_Reverse:
            _readIdx = (_readIdx - 1) % _lengthInFrames;
            break;
            
        default:
            break;
    }
    
    if (_drumPadMode == TWDrumPadMode_OneShot) {
        if ((previousReadIdx != 0) && (_readIdx == 0)) {
            stop(0);
            dispatch_async(_notificationQueue, ^{
                if (_finishedPlaybackProc != nullptr) {
                    _finishedPlaybackProc(_sourceIdx, true);
                }
            });
        }
    }
}

void TWMemoryPlayer::_setReadIdx(int32_t newReadIdx)
{
    switch (_playbackDirection) {
            
        case TWPlaybackDirection_Forward:
            _readIdx = (newReadIdx % _lengthInFrames);
            break;
            
        case TWPlaybackDirection_Reverse:
            _readIdx = _lengthInFrames - 1 - (newReadIdx % _lengthInFrames);
            break;
            
        default:
            break;
    }
}

void TWMemoryPlayer::_fadeOutTailEnd(uint32_t endSamplesToFadeOut)
{
    float dec = 1.0f / endSamplesToFadeOut;
    float gain = 1.0f;
    for (uint32_t i = endSamplesToFadeOut; i > 0; i--) {
        gain -= dec;
        if (gain <= 0.0f) {
            gain = 0.0f;
        }
        for (int c = 0; c < kNumChannels; c++) {
            _buffer[c][_lengthInFrames - i] *= gain;
        }
    }
}

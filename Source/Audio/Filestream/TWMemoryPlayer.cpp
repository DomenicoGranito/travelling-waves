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
    _fadeOutNumSamples      = 0;
    _isIORunning            = 0;
    
    _playbackFinishedProc   = nullptr;
    _notificationQueue      = nullptr;
    
    //--- ABL Settings ---//
    float byteDepth         = 4;
    bool isInterleaved      = true;
    _readABL                = _allocateABL(kNumChannels, kNumChannels * byteDepth, isInterleaved, kAudioFileReadBufferNumFrames);
    
    _buffer                 = nullptr;
    _audioFile              = NULL;
    
    _setFadeOutTime(kAudioFilePlaybackFadeOutTime_ms);
    
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
    _setFadeOutTime(kAudioFilePlaybackFadeOutTime_ms);
}

void TWMemoryPlayer::getSample(float& leftSample, float& rightSample)
{
    if (!_isPlaying) {
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

void TWMemoryPlayer::setNotificationQueue(dispatch_queue_t notificationQueue)
{
    _notificationQueue = notificationQueue;
}


int TWMemoryPlayer::loadAudioFile(std::string filepath)
{
    if (_isPlaying) {
        stop(0);
        dispatch_async(_notificationQueue, ^{
            if (_playbackFinishedProc) {
                _playbackFinishedProc(_sourceIdx, TWPlaybackFinishedStatus_Success);
            }
        });
    }
    
    
    _reset();
    
    
//    printf("TWMemoryPlayer::loadAudioFile [%d] : starting to load file : %s\n", _sourceIdx, filepath.c_str());
    
    
    CFStringRef string = CFStringCreateWithCString(kCFAllocatorDefault, filepath.c_str(), kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, string, NULL);
    
    OSStatus status = ExtAudioFileOpenURL(url, &_audioFile);
    
    CFRelease(url);
    CFRelease(string);
    
    if ((status != noErr) || (_audioFile == NULL)) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Error in ExtAudioFileOpenURL (%s) : %d\n", _sourceIdx, filepath.c_str(), (unsigned int)status);
        _reset();
        return -1;
    }
    
    
    
    AudioStreamBasicDescription inASBD;
    UInt32 propSize = sizeof(inASBD);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileDataFormat, &propSize, &inASBD);
    if (status) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Error in reading kExtAudioFileProperty_FileDataFormat : %d\n", _sourceIdx, (unsigned int)status);
        _reset();
        return -2;
    }
//    _printASBD(&inASBD, "TWFileStream: inFileASBD");
    if (inASBD.mSampleRate <= 0) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Error in kExtAudioFileProperty_FileDataFormat, invalid file sample rate : %f\n", _sourceIdx, inASBD.mSampleRate);
        _reset();
        return -3;
    }
    
    
    
    SInt64 length = 0;
    propSize = sizeof(SInt64);
    status = ExtAudioFileGetProperty(_audioFile, kExtAudioFileProperty_FileLengthFrames, &propSize, &length);
    if (status) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Error in reading kExtAudioFileProperty_FileLengthFrames : %d\n", _sourceIdx, (unsigned int)status);
        _reset();
        return -4;
    }
    if (length <= 0) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Error in reading kExtAudioFileProperty_FileLengthFrames : length: %lld\n", _sourceIdx, length);
        _reset();
        return -5;
    }
    
    
    
    _lengthInFrames = uint32_t((_sampleRate * length) / inASBD.mSampleRate);
//    printf("TWMemoryPlayer::loadAudioFile [%d] : length in frames = %u\n", _sourceIdx, _lengthInFrames);
    if (_lengthInFrames > kMemoryPlayerMaxSizeFrames) {
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Unfortunately, this file is too big for memory player :'( . length: %u\n", _sourceIdx, _lengthInFrames);
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
        printf("\nTWMemoryPlayer::loadAudioFile [%d] : Error in setting kExtAudioFileProperty_ClientDataFormat : %d\n", _sourceIdx, (unsigned int)status);
        _reset();
        return -7;
    }
    
    
    
//    printf("TWMemoryPlayer::loadAudioFile [%d] : Creating new buffer\n", _sourceIdx);
    _buffer = new float * [kNumChannels];
    for (int c = 0; c < kNumChannels; c++) {
        _buffer[c] = new float[_lengthInFrames];
    }
    
    
    
//    _printABL(_readABL, "TWMemoryPlayer::loadAudioFile ReadABL\n");
    UInt32 framesRead = kAudioFileReadBufferNumFrames;
    while (framesRead > 0) {
        status = _readHelper(&framesRead);
        if (status) {
            _reset();
            return -8;
        }
    }
    
    _setPlaybackStatus(TWPlaybackStatus_Stopped);
    _updateFileTitleFromFilepath(filepath);
    
    return 0;
}


void TWMemoryPlayer::setPlaybackFinishedProc(std::function<void(int,int)>playbackFinishedProc)
{
    _playbackFinishedProc = playbackFinishedProc;
}


std::string TWMemoryPlayer::getAudioFileTitle()
{
    return _fileTitle;
}

//============================================================================================================
// Transport Methods
//============================================================================================================

int TWMemoryPlayer::start(int32_t startSampleTime)
{
    int status = TWPlaybackFinishedStatus_Success;
    
    if (_playbackStatus == TWPlaybackStatus_Uninitialized) {
        printf("TWMemoryPlayer::start : Error! Stream is %s\n", _playbackStatusToString(_playbackStatus).c_str());
        status = TWPlaybackFinishedStatus_Uninitialized;
        dispatch_async(_notificationQueue, ^{
            if (_playbackFinishedProc != nullptr) {
                _playbackFinishedProc(_sourceIdx, status);
            }
        });
        return status;
    }
    
    if (!_isIORunning) {
        printf("TWMemoryPlayer::start : Error! IO Not Running\n");
        status = TWPlaybackFinishedStatus_NoIORunning;
        dispatch_async(_notificationQueue, ^{
            if (_playbackFinishedProc != nullptr) {
                _playbackFinishedProc(_sourceIdx, TWPlaybackFinishedStatus_NoIORunning);
            }
        });
        return status;
    }
    
//    printf("Start[%d]! SampleTime : %d\n", _sourceIdx, startSampleTime);
    _isStopping = false;
    _stopSampleCounter = 0;
    _fadeOutGain.setTargetValue(1.0f, 0.0f);
    _setReadIdx(startSampleTime);
    _isPlaying = true;
    _setPlaybackStatus(TWPlaybackStatus_Playing);
    
    return status;
}

void TWMemoryPlayer::stop(uint32_t fadeOutSamples)
{    
    if (fadeOutSamples == 0) {
        _stopSampleCounter = 0;
        _isStopping = false;
        _isPlaying = false;
        _setPlaybackStatus(TWPlaybackStatus_Stopped);
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
    if (_lengthInFrames <= 0) {
        return 0.0f;
    }
    return ((float)_readIdx / _lengthInFrames);
}

float TWMemoryPlayer::getLengthInSeconds()
{
    return (float)_lengthInFrames / _sampleRate;
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
    
//    printf("TWMemoryPlayer::_readHelper [%d] : frames read : %u\n", _sourceIdx, *framesToRead);
    
    uint32_t framesRead = *framesToRead;
    if (framesRead == 0) {
        return 0;
    }
    
    float* buffer = (float*)_readABL->mBuffers[0].mData;
    for (int i = 0; i < framesRead; i++) {
        for (int c = 0; c < kNumChannels; c++) {
            _buffer[c][_writeIdx] = buffer[(i * kNumChannels) + c];
        }
        _writeIdx = (_writeIdx + 1) % _lengthInFrames;
    }
    
    return 0;
}


void TWMemoryPlayer::_reset()
{
    if (_buffer != nullptr) {
//        printf("TWMemoryPlayer::_reset [%d]. Deleting buffer\n", _sourceIdx);
        for (int channel = 0; channel < kNumChannels; channel++) {
            delete [] _buffer[channel];
        }
        delete [] _buffer;
    }
    _buffer = nullptr;
    
    
    _writeIdx           = 0;
    _readIdx            = 0;
    
    _lengthInFrames     = 0;
    
    _isStopping         = false;
    _stopSampleCounter  = 0;
    
    _shouldFadeOut      = false;
    
    _setPlaybackStatus(TWPlaybackStatus_Uninitialized);
    _isPlaying          = false;
    
    
    if (_audioFile) {
//        printf("TWMemoryPlayer::_reset [%d] : Disposing audio file\n", _sourceIdx);
        OSStatus status = ExtAudioFileDispose(_audioFile);
        if (status) {
            printf("TWMemoryPlayer::_reset [%d] : Error in ExtAudioFileDispose : %d", _sourceIdx, (int)status);
        }
    }
    _audioFile = NULL;
    
    _fileTitle.erase();
    
    UInt32 byteDepth = 4;
    UInt32 bytesPerFrame = kNumChannels * byteDepth;
    UInt32 capacityFrames = kAudioFileReadBufferNumFrames;
    for (int bufferIdx = 0; bufferIdx < _readABL->mNumberBuffers; bufferIdx++) {
        _readABL->mBuffers[bufferIdx].mDataByteSize = capacityFrames * bytesPerFrame;
    }
}


void TWMemoryPlayer::_updateFileTitleFromFilepath(std::string filepath)
{
    _fileTitle.erase();
    
    std::size_t startPosition = filepath.find_last_of("/") + 1;
    std::size_t endPosition = filepath.length() - startPosition - 4;
    std::string substring = filepath.substr(startPosition, endPosition);
//
//    //--- Replace %20s with spaces
//    //--- TODO: Loop for multiple occurences.
//    std::size_t spaceStart = substring.find_first_of("%20");
//    if (spaceStart < substring.length()) {
//        substring.replace(spaceStart, 3, " ");
//    }
    _fileTitle = substring;
    
//    _fileTitle = filepath;
   
//    printf("\n\nFile Title [%d] : %s. Size(%lu)\n\n", _sourceIdx, _fileTitle.c_str(), _fileTitle.length());
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
    _isIORunning = isIORunning;
}



//----- Stop Utils -----//

void TWMemoryPlayer::_stoppingTick()
{
    if (_isStopping) {
        _stopSampleCounter--;
        if (_stopSampleCounter == 0) {
            _isStopping = false;
            _isPlaying = false;
            _setPlaybackStatus(TWPlaybackStatus_Stopped);
        }
    }
}


//----- Ring Buffer Utilities -----//

void TWMemoryPlayer::_incDecReadIdx()
{
    int32_t previousReadIdx = _readIdx;
    
    switch (_playbackDirection) {
        
        case TWPlaybackDirection_Forward:
            _readIdx = (_readIdx + 1) % _lengthInFrames;
            break;
            
        case TWPlaybackDirection_Reverse:
            _readIdx = _readIdx - 1;
            if (_readIdx < 0) {
                _readIdx = _lengthInFrames - 1;
            }
//            printf("ReadIdx : %u. Prev: %u. Len : %u\n", _readIdx, previousReadIdx, _lengthInFrames);
            break;
            
        default:
            break;
    }
    
    _checkForFadeOut();
    
    if (_drumPadMode == TWDrumPadMode_OneShot) {
        if ((previousReadIdx != 0) && (_readIdx == 0)) {
            stop(0);
            dispatch_async(_notificationQueue, ^{
                if (_playbackFinishedProc != nullptr) {
                    _playbackFinishedProc(_sourceIdx, TWPlaybackFinishedStatus_Success);
                }
            });
        }
    }
}

void TWMemoryPlayer::_setReadIdx(int32_t newReadIdx)
{
//    printf("TWMemoryPlayer::_setReadIdx : %d\n", newReadIdx);
    switch (_playbackDirection) {
            
        case TWPlaybackDirection_Forward:
            _readIdx = (newReadIdx % _lengthInFrames);
            break;
            
        case TWPlaybackDirection_Reverse:
            if (newReadIdx < 0) {
                _readIdx = (newReadIdx * -1) - 1;
            } else {
                _readIdx = _lengthInFrames - 1 - newReadIdx;
            }
            break;
            
        default:
            break;
    }
}

void TWMemoryPlayer::_setFadeOutTime(float fadeOutTime_ms)
{
    _fadeOutNumSamples = (fadeOutTime_ms / 1000.0f * _sampleRate);
}

void TWMemoryPlayer::_checkForFadeOut()
{
    if (!_shouldFadeOut) {
        return;
    }
    
    switch (_playbackDirection) {
            
        case TWPlaybackDirection_Forward:
            if (_readIdx == _lengthInFrames - _fadeOutNumSamples - 1) {
                _fadeOutGain.setTargetValue(0.0f, _fadeOutNumSamples);
//                printf("Forward Start Fade Out. ReadIdx = %d, fadeOutSamples = %u\n", _readIdx, _fadeOutNumSamples);
            } else if (_readIdx == 0) {
                _fadeOutGain.setTargetValue(1.0f, 0.0f);
//                printf("Forward End Fade Out Now. ReadIdx = %d\n", _readIdx);
            }
            break;
            
        case TWPlaybackDirection_Reverse:
            if (_readIdx == _fadeOutNumSamples - 1) {
                _fadeOutGain.setTargetValue(0.0f, _fadeOutNumSamples);
//                printf("Reverse Start Fade Out ReadIdx = %d, fadeOutSamples = %u\n", _readIdx, _fadeOutNumSamples);
            } else if (_readIdx == 0) {
                _fadeOutGain.setTargetValue(1.0f, 0.0f);
//                printf("Reverse End Fade Out Now. ReadIdx = %d\n", _readIdx);
            }
            break;
            
        default:
            break;
    }
}

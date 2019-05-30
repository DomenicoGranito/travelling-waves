//
//  TWMemoryPlayer.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/1/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWMemoryPlayer_h
#define TWMemoryPlayer_h

#include <stdio.h>
#include <string>
#include <functional>

#include "TWParameter.h"
#include "TWHeader.h"

#include <AudioToolbox/ExtendedAudioFile.h>
#include <dispatch/dispatch.h>

class TWMemoryPlayer {
    
    
public:
    
    
    TWMemoryPlayer();
    ~TWMemoryPlayer();
    
    
    //--- Audio Source Methods ---//
    void prepare(float sampleRate);
    void getSample(float& leftSample, float& rightSample);
    void release();
    
    
    //--- Setup Methods ---//
    void setNotificationQueue(dispatch_queue_t notificationQueue);
    
    int loadAudioFile(std::string filepath);
    std::string getAudioFileTitle();
    
    void setPlaybackFinishedProc(std::function<void(int,int)>playbackFinishedProc);
    
    
    //--- Transport Methods ---//
    int start(int32_t startSampleTime);
    void stop(uint32_t fadeOutSamples);
    TWPlaybackStatus getPlaybackStatus();
    float getNormalizedPlaybackProgress();
    float getLengthInSeconds();
    
    
    //--- Playback Property Methods ---//
    void setCurrentVelocity(float velocity, float rampTime_ms);
    float getCurrentVelocity();
    
    void setMaxVolume(float maxVolume, float rampTime_ms);
    float getMaxVolume();
    
    void setPlaybackDirection(TWPlaybackDirection newDirection);
    TWPlaybackDirection getPlaybackDirection();
    
    void setDrumPadMode(TWDrumPadMode drumPadMode);
    TWDrumPadMode getDrumPadMode();
    
    void setSourceIdx(int sourceIdx);
    int getSourceIdx();
    
private:
    
    float                   _sampleRate;
    
    float**                 _buffer;
    int32_t                 _readIdx;
    uint32_t                _writeIdx;
    int32_t                 _lengthInFrames;
    
    
    TWParameter             _currentVelocity;
    TWParameter             _maxVolume;
    TWParameter             _fadeOutGain;
    
    TWDrumPadMode           _drumPadMode;
    TWPlaybackDirection     _playbackDirection;
    
    TWPlaybackStatus        _playbackStatus;
    int                     _sourceIdx;
    
    bool                    _isIORunning;
    bool                    _isPlaying;
    bool                    _isStopping;
    uint32_t                _stopSampleCounter;
    uint32_t                _fadeOutNumSamples;
    bool                    _shouldFadeOut;
    
    std::string             _fileTitle;
    
    std::function<void(int,int)>   _playbackFinishedProc;
    
    dispatch_queue_t        _notificationQueue;
    
    AudioBufferList*        _readABL;
    ExtAudioFileRef         _audioFile;
    
    OSStatus _readHelper(uint32_t * framesToRead);
    void _reset();
    
    void _setPlaybackStatus(TWPlaybackStatus newStatus);
    std::string _playbackStatusToString(TWPlaybackStatus status);
    
    void _setIsIORunning(bool isIORunning);
    
    void _setReadIdx(int32_t newReadIdx);
    void _setFadeOutTime(float fadeOutTime_ms);
    
    void _updateFileTitleFromFilepath(std::string filepath);
    
    //--- On IO Proc ---//
    void _stoppingTick();
    void _incDecReadIdx();
    void _checkForFadeOut();
};

#endif /* TWMemoryPlayer_h */

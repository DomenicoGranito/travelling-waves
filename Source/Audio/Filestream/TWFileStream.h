//
//  TWFileStream.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/25/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWFileStream_h
#define TWFileStream_h

#include "TWRingBuffer.h"
#include "TWParameter.h"
#include "TWHeader.h"

#include <stdio.h>
#include <string>
#include <functional>

#include <AudioToolbox/ExtendedAudioFile.h>
#include <dispatch/dispatch.h>

class TWFileStream {
    
    
public:
    
    TWFileStream();
    ~TWFileStream();
    
    //--- Audio Source Methods ---//
    void prepare(float sampleRate);
    void getSample(float& leftSample, float& rightSample);
    void release();
    
    //--- Setup Methods ---//
    void setReadQueue(dispatch_queue_t readQueue);
    void setNotificationQueue(dispatch_queue_t notificationQueue);
    int loadAudioFile(std::string filepath);
    
    //--- Transport Methods ---//
    int start(uint32_t startSampleTime);
    void stop();
    TWPlaybackStatus getPlaybackStatus();
    float getNormalizedPlaybackProgress();
    
    //--- Playback Property Methods ---//
    void setVelocity(float amplitude, float rampTime_ms);
    float getVelocity();
    void setMaxVolume(float maxVolume, float rampTime_ms);
    float getMaxVolume();
    void setPlaybackDirection(TWPlaybackDirection newDirection);
    TWPlaybackDirection getPlaybackDirection();
    
    void setDrumPadMode(TWDrumPadMode drumPadMode);
    TWDrumPadMode getDrumPadMode();
    
    
    
    
    
    void setSourceIdx(int sourceIdx);
    int getSourceIdx();
    
    void setFinishedPlaybackProc(std::function<void(int,bool)>finishedPlaybackProc);
    
private:
    
    TWRingBuffer*           _leftBuffer;
    TWRingBuffer*           _rightBuffer;
    
    TWParameter             _velocity;
    TWParameter             _maxVolume;
    TWParameter             _fadeOutGain;
    
    TWDrumPadMode           _drumPadMode;
    
    TWPlaybackStatus        _playbackStatus;
    TWPlaybackDirection     _playbackDirection;
    
    float                   _sampleRate;
    
    bool                    _isRunning;
    
    bool                    _isStopping;
    uint32_t                _stopSampleCounter;
    
    uint32_t                _lengthInFrames;
    uint32_t                _framesRead;
    uint32_t                _currentFrame;
    int                     _sourceIdx;
    bool                    _entireFileInsideRingBuffer;
    bool                    _endOfFileReached;
    bool                    _fileReadError;
    
    AudioBufferList*        _readABL;
    ExtAudioFileRef         _audioFile;
    dispatch_queue_t        _readQueue;
    dispatch_queue_t        _notificationQueue;
    
    std::function<void(int,bool)>   _finishedPlaybackProc;
    
    void _printASBD(AudioStreamBasicDescription* asbd, std::string context);
    void _printABL(AudioBufferList *abl, std::string context);
    AudioBufferList* _allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames);
    void _deallocateABL(AudioBufferList* abl);
    
    void _readNextBlock();
    void _readEntireAudioFile();
    void _resetAudioFile();
    uint32_t _readHelper(uint32_t samplesToRead);
    
    void _setPlaybackStatus(TWPlaybackStatus newStatus);
    std::string _playbackStatusToString(TWPlaybackStatus status);
    
    void _setIsRunning(bool isRunning);
    
    void _smoothLoopPoint();
    void _setStopStatusAfterSamples(uint32_t samples);
    void _stopTick();
};


#endif /* TWFileStream_h */

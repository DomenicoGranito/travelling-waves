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
    
    void prepare(float sampleRate);
    void getSample(float& leftSample, float& rightSample);
    void release();
    
    void setReadQueue(dispatch_queue_t readQueue);
    void setNotificationQueue(dispatch_queue_t notificationQueue);
    int loadAudioFile(std::string filepath);
    
    int start(uint32_t startSampleTime);
    void stop();
    
    void setVelocity(float amplitude, float rampTime_ms);
    float getVelocity();
    
    void setMaxVolume(float maxVolume, float rampTime_ms);
    float getMaxVolume();
    
    void setDrumPadMode(TWDrumPadMode drumPadMode);
    TWDrumPadMode getDrumPadMode();
    
    bool getIsRunning();
    
    float getNormalizedPlaybackProgress();
    
    void setSourceIdx(int sourceIdx);
    int getSourceIdx();
    
    void setFinishedPlaybackProc(std::function<void(int)>finishedPlaybackProc);
    
private:
    
    TWRingBuffer*           _leftBuffer;
    TWRingBuffer*           _rightBuffer;
    
    TWParameter             _velocity;
    TWParameter             _maxVolume;
    
    TWDrumPadMode           _drumPadMode;
    
    float                   _sampleRate;
    
    bool                    _isRunning;
    uint32_t                _lengthInFrames;
    uint32_t                _framesRead;
    uint32_t                _currentFrame;
    int                     _sourceIdx;
    
    AudioBufferList*        _readABL;
    ExtAudioFileRef         _audioFile;
    dispatch_queue_t        _readQueue;
    dispatch_queue_t        _notificationQueue;
    
    std::function<void(int)>   _finishedPlaybackProc;
    
    void _printASBD(AudioStreamBasicDescription* asbd, std::string context);
    void _printABL(AudioBufferList *abl, std::string context);
    AudioBufferList* _allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames);
    void _deallocateABL(AudioBufferList* abl);
    
    void _readNextBlock();
    void _resetAudioFile();
    
    void _setIsRunning(bool isRunning);
};


#endif /* TWFileStream_h */

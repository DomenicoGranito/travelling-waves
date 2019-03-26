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
#include <stdio.h>
#include <string>

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
    int loadAudioFile(std::string filepath);
    int start(uint64_t startSampleTime);
    void stop();
    
    void setLooping(bool isLooping);
    bool getLooping();
    
    bool getIsRunning();
    
    float getNormalizedPlaybackProgress();
    
    
    
private:
    
    TWRingBuffer*       _leftBuffer;
    TWRingBuffer*       _rightBuffer;
    
//    AudioBufferList*    _abl;
    float               _sampleRate;
    
    bool                _isRunning;
    bool                _isLooping;
    uint64_t            _length;
    uint64_t            _samplesRead;
    uint64_t            _currentSample;
    
    ExtAudioFileRef     _audioFile;
    dispatch_queue_t    _readQueue;
    
    void _printASBD(AudioStreamBasicDescription* asbd, std::string context);
    void _printABL(AudioBufferList *abl, std::string context);
    AudioBufferList* _allocateABL(UInt32 channelsPerFrame, UInt32 bytesPerFrame, bool interleaved, UInt32 capacityFrames);
    void _deallocateABL(AudioBufferList* abl);
    
    void _readNextBlock();
    void _resetAudioFile();
};


#endif /* TWFileStream_h */

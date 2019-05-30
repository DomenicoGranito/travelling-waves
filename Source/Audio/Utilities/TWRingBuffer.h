//
//  TWRingBuffer.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWRingBuffer_h
#define TWRingBuffer_h

#include <stdio.h>
#include <stdint.h>

class TWRingBuffer {
    
public:
    
    TWRingBuffer(uint32_t size);
    ~TWRingBuffer();
    
    uint32_t getSize();
    
    void writeAndIncIdx(float value);
   
    float read();
    void incReadIdx();
    
    float readAndIncIdx();
    float readAtIdx(float idx);
    
    void offsetReadIdx(int32_t offset);
    void offsetWriteIdx(int32_t offset);
    
    void setReadIdx(int32_t newReadIdx);
    void setWriteIdx(int32_t newWriteIdx);
    
    int32_t getReadIdx();
    int32_t getWriteIdx();
    
    void setReadWrapPoint(int32_t readWrapPoint);
    int32_t getReadWrapPoint();
    
    void setWriteWrapPoint(int32_t writeWrapPoint);
    int32_t getWriteWrapPoint();
    
    void fadeOutTailEnd(uint32_t endSamplesToFadeOut);
    
    void reset();
    
private:
    
    float*          _buffer;
    
    uint32_t        _size;
    
    int32_t        _writeIdx;
    int32_t        _writeWrapPoint;
    
    int32_t        _readIdx;
    int32_t        _readWrapPoint;
    
    void           _incWriteIdx();
};
#endif /* TWRingBuffer_h */

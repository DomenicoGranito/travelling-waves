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
    
    void offsetReadIdx(uint32_t offset);
    void offsetWriteIdx(uint32_t offset);
    
    void setReadIdx(uint32_t newReadIdx);
    void setWriteIdx(uint32_t newWriteIdx);
    
    uint32_t getReadIdx();
    uint32_t getWriteIdx();
    
    void setReadWrapPoint(uint32_t readWrapPoint);
    uint32_t getReadWrapPoint();
    
    void setWriteWrapPoint(uint32_t writeWrapPoint);
    uint32_t getWriteWrapPoint();
    
    void setReadStartPoint(uint32_t readStartPoint);
    uint32_t getReadStartPoint();
    
    void fadeOutTailEnd(uint32_t endSamplesToFadeOut);
    
    void reset();
    
    void setDebugID(int debugID);
    
private:
    
    float*          _buffer;
    
    uint32_t        _size;
    
    uint32_t        _writeIdx;
    uint32_t        _writeWrapPoint;
    
    uint32_t        _readIdx;
    uint32_t        _readWrapPoint;
    uint32_t        _readStartPoint;
    
    void            _incWriteIdx();
    
    int             _debugID;
    
    
};
#endif /* TWRingBuffer_h */

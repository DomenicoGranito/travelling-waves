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
    float readAndIncIdx();
    float readAtIdx(float idx);
    
    void offsetReadIdx(uint32_t offset);
    void offsetWriteIdx(uint32_t offset);
    
    void setReadIdx(uint32_t newReadIdx);
    void setWriteIdx(uint32_t newWriteIdx);
    
    uint32_t getReadIdx();
    uint32_t getWriteIdx();
    
    void setWrapPoint(uint32_t wrapPoint);
    uint32_t getWrapPoint();
    
    void reset();
    
    void setDebugID(int debugID);
    
private:
    
    float*          _buffer;
    
    uint32_t        _size;
    uint32_t        _wrapPoint;
    uint32_t        _writeIdx;
    uint32_t        _readIdx;
    
    void            _incReadIdx();
    void            _incWriteIdx();
    
    int             _debugID;
    
    
};
#endif /* TWRingBuffer_h */

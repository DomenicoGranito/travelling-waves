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

class TWRingBuffer {
    
public:
    
    TWRingBuffer(int numSamples);
    ~TWRingBuffer();
    
    void writeAndIncIdx(float value);
    float readAndIncIdx();
    float readAtIdx(float idx);
    
    void offsetReadIdx(int offset);
    void offsetWriteIdx(int offset);
    
    int getReadIdx();
    int getWriteIdx();
    
    void reset();
    
private:
    
    float*      _buffer;
    
    int         _size;
    int         _writeIdx;
    int         _readIdx;
    
    void        _incReadIdx();
    void        _incWriteIdx();
    
    
};
#endif /* TWRingBuffer_h */

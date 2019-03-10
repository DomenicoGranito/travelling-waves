//
//  TWRingBuffer.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWRingBuffer.h"
#include <cstring>
#include <math.h>

TWRingBuffer::TWRingBuffer(int numSamples)
{
    _size       = numSamples;
    _writeIdx   = 0;
    _readIdx    = 0;
    
    _buffer     = new float[_size];
}

TWRingBuffer::~TWRingBuffer()
{
    delete [] _buffer;
}




void TWRingBuffer::writeAndIncIdx(float value)
{
    _buffer[_writeIdx] = value;
    _incWriteIdx();
}

float TWRingBuffer::readAtIdx(float idx)
{
    if (idx < 0) {
        idx += _size;
    }
    int integer = floor(idx);
    float fraction = idx - integer;
    
    _readIdx = (integer % _size);
    
    if (fraction == 0) {
        return _buffer[_readIdx];
    }
    
    int nextIdx = (_readIdx + 1) % _size;
    
    return ((_buffer[_readIdx] * (1.0 - fraction)) + (_buffer[nextIdx] * fraction));
}

float TWRingBuffer::readAndIncIdx()
{
    float value = _buffer[_readIdx];
    _incReadIdx();
    return value;
}

void TWRingBuffer::reset()
{
    std::memset(_buffer, 0, sizeof(float) * _size);
}

void TWRingBuffer::offsetReadIdx(int offset)
{
    _readIdx = (_readIdx + offset) % _size;
}

void TWRingBuffer::offsetWriteIdx(int offset)
{
    _writeIdx = (_writeIdx + offset) % _size;
}

int TWRingBuffer::getReadIdx()
{
    return _readIdx;
}

int TWRingBuffer::getWriteIdx()
{
    return _writeIdx;
}




void TWRingBuffer::_incReadIdx()
{
    _readIdx = (_readIdx + 1) % _size;
}

void TWRingBuffer::_incWriteIdx()
{
    _writeIdx = (_writeIdx + 1) % _size;
}

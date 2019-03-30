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

TWRingBuffer::TWRingBuffer(uint32_t size)
{
    _size       = size;
    _writeIdx   = 0;
    _readIdx    = 0;
    
    _buffer     = new float[_size];
    _wrapPoint  = _size;
}

TWRingBuffer::~TWRingBuffer()
{
    delete [] _buffer;
}


uint32_t TWRingBuffer::getSize()
{
    return _size;
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
    uint32_t integer = floor(idx);
    float fraction = idx - integer;
    
    _readIdx = (integer % _wrapPoint);
    
    if (fraction == 0) {
        return _buffer[_readIdx];
    }
    
    uint32_t nextIdx = (_readIdx + 1) % _wrapPoint;
    
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
    _readIdx = 0;
    _writeIdx = 0;
    _wrapPoint = _size;
}


void TWRingBuffer::offsetReadIdx(uint32_t offset)
{
    _readIdx = (_readIdx + offset) % _wrapPoint;
}


void TWRingBuffer::offsetWriteIdx(uint32_t offset)
{
    _writeIdx = (_writeIdx + offset) % _wrapPoint;
}


uint32_t TWRingBuffer::getReadIdx()
{
    return _readIdx;
}


uint32_t TWRingBuffer::getWriteIdx()
{
    return _writeIdx;
}


void TWRingBuffer::setReadIdx(uint32_t newReadIdx)
{
    _readIdx = newReadIdx % _wrapPoint;
}


void TWRingBuffer::setWriteIdx(uint32_t newWriteIdx)
{
    _writeIdx = newWriteIdx % _wrapPoint;
}


void TWRingBuffer::setWrapPoint(uint32_t wrapPoint)
{
    _wrapPoint = wrapPoint;
    printf("Set wrap point [%d] : %u. Size : %u\n", _debugID, _wrapPoint, _size);
}


uint32_t TWRingBuffer::getWrapPoint()
{
    return _wrapPoint;
}


void TWRingBuffer::_incReadIdx()
{
    _readIdx = (_readIdx + 1) % _wrapPoint;
    if (_readIdx == 0) {
        printf("Read wrap point reached [%d] : %u\n", _debugID, _wrapPoint);
    }
}

void TWRingBuffer::_incWriteIdx()
{
    _writeIdx = (_writeIdx + 1) % _wrapPoint;
}


void TWRingBuffer::setDebugID(int debugID)
{
    _debugID = debugID;
}

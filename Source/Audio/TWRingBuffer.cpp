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
    _size               = size;
    
    _writeIdx           = 0;
    _readIdx            = 0;
    
    _buffer             = new float[_size];
    
    _writeWrapPoint     = _size;
    _readWrapPoint      = _size;
    
    _readStartPoint     = 0;
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
    
    _readIdx = (integer % _readWrapPoint);
    
    if (fraction == 0) {
        return _buffer[_readIdx];
    }
    
    uint32_t nextIdx = (_readIdx + 1) % _readWrapPoint;
    
    return ((_buffer[_readIdx] * (1.0 - fraction)) + (_buffer[nextIdx] * fraction));
}


float TWRingBuffer::readAndIncIdx()
{
    float value = _buffer[_readIdx];
    incReadIdx();
    return value;
}


void TWRingBuffer::reset()
{
    std::memset(_buffer, 0, sizeof(float) * _size);
    _readIdx        = 0;
    _writeIdx       = 0;
    _readWrapPoint  = _size;
    _readStartPoint = 0;
    _writeWrapPoint = _size;
}


void TWRingBuffer::offsetReadIdx(uint32_t offset)
{
    _readIdx = (_readIdx + offset) % _readWrapPoint;
}


void TWRingBuffer::offsetWriteIdx(uint32_t offset)
{
    _writeIdx = (_writeIdx + offset) % _size;
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
    _readIdx = newReadIdx % _readWrapPoint;
}


void TWRingBuffer::setWriteIdx(uint32_t newWriteIdx)
{
    _writeIdx = newWriteIdx % _size;
}


void TWRingBuffer::setReadWrapPoint(uint32_t readWrapPoint)
{
    _readWrapPoint = readWrapPoint;
    printf("Set read wrap point [%d] : %u. Size : %u\n", _debugID, readWrapPoint, _size);
}


uint32_t TWRingBuffer::getReadWrapPoint()
{
    return _readWrapPoint;
}

void TWRingBuffer::setWriteWrapPoint(uint32_t writeWrapPoint)
{
    _writeWrapPoint = writeWrapPoint;
}

uint32_t TWRingBuffer::getWriteWrapPoint()
{
    return _writeWrapPoint;
}

void TWRingBuffer::setReadStartPoint(uint32_t readStartPoint)
{
    _readStartPoint = readStartPoint;
}

uint32_t TWRingBuffer::getReadStartPoint()
{
    return _readStartPoint;
}


float TWRingBuffer::read()
{
    return _buffer[_readIdx];
}

void TWRingBuffer::incReadIdx()
{
//    uint32_t currentReadIdx = _readIdx;
//    currentReadIdx = (currentReadIdx + 1) % _readWrapPoint;
//
//    if ((currentReadIdx == 0) && (_readIdx != 0)) {
//        <#statements#>
//    }
    _readIdx = ((_readIdx + 1) % _readWrapPoint);
//    if (_readIdx == 0) {
//        printf("Read wrap point reached [%d] : %u\n", _debugID, _readWrapPoint);
//    }
}

void TWRingBuffer::_incWriteIdx()
{
    _writeIdx = (_writeIdx + 1) % _writeWrapPoint;
}


void TWRingBuffer::setDebugID(int debugID)
{
    _debugID = debugID;
}


void TWRingBuffer::fadeOutTailEnd(uint32_t endSamplesToFadeOut)
{
    float dec = 1.0f / endSamplesToFadeOut;
    float gain = 1.0f;
    for (uint32_t i = endSamplesToFadeOut; i > 0; i--) {
        gain -= dec;
        if (gain <= 0.0f) {
            gain = 0.0f;
        }
        _buffer[_writeWrapPoint - i] *= gain;
    }
}

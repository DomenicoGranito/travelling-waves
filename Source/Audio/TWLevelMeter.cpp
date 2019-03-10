//
//  TWLevelMeter.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/26/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWLevelMeter.h"
#include <math.h>

TWLevelMeter::TWLevelMeter()
{
    _buffer = nullptr;
    _sampleRate = 48000.0f;
    setWindowSize_ms(40.0f);
}

TWLevelMeter::~TWLevelMeter()
{
    if (_buffer != nullptr) {
        delete [] _buffer;
        _buffer = nullptr;
    }
}




void TWLevelMeter::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    setWindowSize_ms(_windowSize_ms);
}


void TWLevelMeter::process(float sample)
{
    _buffer[_sampleCount] = sample;
    _sampleCount = (_sampleCount + 1) % _windowSize_samples;
}


void TWLevelMeter::release()
{
    memset(_buffer, 0, sizeof(float) * _windowSize_samples);
}


void TWLevelMeter::setWindowSize_ms(float windowSize_ms)
{
    _windowSize_ms = windowSize_ms;
    _windowSize_samples = (uint32_t)(_windowSize_ms / 1000.0f * _sampleRate);
    
    if (_buffer != nullptr) {
        delete [] _buffer;
        _buffer = nullptr;
    }
    _buffer = new float [_windowSize_samples]();
    _sampleCount = 0;
}



float TWLevelMeter::getCurrentLevel()
{
    float sum = 0.0f;
    for (uint32_t sample = 0; sample < _windowSize_samples; sample++) {
        sum += _buffer[sample] * _buffer[sample];
    }
    return (sqrt(sum / _windowSize_samples));
}

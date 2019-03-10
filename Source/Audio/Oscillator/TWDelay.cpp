//
//  TWDelay.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWDelay.h"
#include <math.h>

#define kMaxSamples     192000

TWDelay::TWDelay()
{
    _wetSignal      = new TWRingBuffer(kMaxSamples);
    _sampleRate     = 44100.0f;
    _enable         = false;
    _delayTime_ms   = 0.0f;
    _delayTimeSamples.setTargetValue(0.0f, 0.0f);
    _feedback.setTargetValue(0.0f, 0.0f);
    _dryWetRatio.setTargetValue(0.0f, 0.0f);
}

TWDelay::~TWDelay()
{
    delete _wetSignal;
}




void TWDelay::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    _wetSignal->reset();
    _setIsRunning(true);
}

float TWDelay::process(float xn)
{
    if (!_enable) {
        return xn;
    }
    
    float dryWet   = _dryWetRatio.getCurrentValue();
    float dryScale = cosf(dryWet * M_PI_2);
    float wetScale = sinf(dryWet * M_PI_2);
    
    float feedback = _feedback.getCurrentValue();
    
    float readIdx = _wetSignal->getWriteIdx() - _delayTimeSamples.getCurrentValue();
    float yn = _wetSignal->readAtIdx(readIdx);

    _wetSignal->writeAndIncIdx(xn + (yn * feedback));
    return (dryScale * xn) + (wetScale * yn);
}

void TWDelay::release()
{
    _setIsRunning(false);
}




void TWDelay::setDelayTime_ms(float delayTime_ms, float rampTime_ms)
{
    _delayTime_ms = delayTime_ms;
    _delayTimeSamples.setTargetValue((_delayTime_ms / 1000.0f) * _sampleRate, (rampTime_ms / 1000.0f) * _sampleRate);
}

void TWDelay::setFeedback(float feedback, float rampTime_ms)
{
    _feedback.setTargetValue(feedback, (rampTime_ms / 1000.0f) * _sampleRate);
}

void TWDelay::setDryWetRatio(float dryWetRatio, float rampTime_ms)
{
    _dryWetRatio.setTargetValue(dryWetRatio, (rampTime_ms / 1000.0f) * _sampleRate);
}




void TWDelay::_setIsRunning(bool isRunning)
{
    _delayTimeSamples.setIsRunning(isRunning);
    _feedback.setIsRunning(isRunning);
    _dryWetRatio.setIsRunning(isRunning);
}

//
//  TWTremolo.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/25/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWTremolo.h"

#define DEBUG_PRINT     0

static const int kDebugCountdown    = 200;

TWTremolo::TWTremolo()
{
    _sampleRate = 48000.0f;
    
    _depth.setTargetValue(0.0f, 0.0f);
    
    _lfo = new TWOscillator();
    _lfo->setFrequency(1.0f, 0.0f);
    _lfo->setWaveform(TWOscillator::Sine);
    _lfo->setAmplitude(1.0f, 0.0f);
    _lfo->setDutyCycle(0.5, 0.0f);
    _lfo->setPhaseOfst(0.0f, 0.0f);
    
    _debugCount = kDebugCountdown;
    _debugID = 0;
}

TWTremolo::~TWTremolo()
{
    delete _lfo;
}




void TWTremolo::prepare(float sampleRate)
{
    _lfo->prepare(sampleRate);
    _depth.setIsRunning(true);
}

void TWTremolo::process(float &leftSample, float &rightSample)
{
    float lfoSample = _lfo->getSample();
    float depth = _depth.getCurrentValue();
    
    float multiplier = 1.0f - (((lfoSample / 2.0f) + 0.5) * depth);
//    float multiplier = 1.0f + (lfoSample * (depth / 2.0f));
    
    leftSample *= multiplier;
    rightSample *= multiplier;
    
#if DEBUG_PRINT
    if (_debugID == 1) {
        _debugCount--;
        if (_debugCount <= 0) {
            printf("lfoS = %f , dpth = %f, mult = %f, newM = %f\n", lfoSample, depth, multiplier, newMultiplier);
            _debugCount = kDebugCountdown;
        }
    }
#endif
}

void TWTremolo::release()
{
    _lfo->release();
    _depth.setIsRunning(false);
}




void TWTremolo::setWaveform(TWOscillator::TWWaveform waveform)
{
    _lfo->setWaveform(waveform);
}

void TWTremolo::setFrequency(float newFrequency, float rampTime_ms)
{
    _lfo->setFrequency(newFrequency, rampTime_ms);
}

void TWTremolo::setDepth(float newDepth, float rampTime_ms)
{
    _depth.setTargetValue(newDepth, rampTime_ms / 1000.0f * _sampleRate);
}

void TWTremolo::setSoftClipp(float newSoftClipp, float rampTime_ms)
{
    _lfo->setSoftClipp(newSoftClipp, rampTime_ms);
}



TWOscillator::TWWaveform TWTremolo::getWaveform()
{
    return _lfo->getWaveform();
}

float TWTremolo::getFrequency()
{
    return _lfo->getFrequency();
}

float TWTremolo::getDepth()
{
    return _depth.getTargetValue();
}

float TWTremolo::getSoftClipp()
{
    return _lfo->getSoftClipp();
}




void TWTremolo::resetPhase(float rampTimeInSamples)
{
    _lfo->resetPhase(rampTimeInSamples);
}




void TWTremolo::setDebugID(int debugID)
{
    _debugID = debugID;
    _lfo->setDebugID(debugID);
}

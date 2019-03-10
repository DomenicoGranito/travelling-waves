//
//  TWTremolo.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/25/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWTremolo.h"

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
    float multiplier = 1.0f + (_lfo->getSample() * (_depth.getCurrentValue() / 2.0f));
    leftSample *= multiplier;
    rightSample *= multiplier;
}

void TWTremolo::release()
{
    _lfo->release();
    _depth.setIsRunning(false);
}



void TWTremolo::setFrequency(float newFrequency, float rampTime_ms)
{
    _lfo->setFrequency(newFrequency, rampTime_ms);
}

void TWTremolo::setDepth(float newDepth, float rampTime_ms)
{
    _depth.setTargetValue(newDepth, rampTime_ms / 1000.0f * _sampleRate);
}

float TWTremolo::getFrequency()
{
    return _lfo->getFrequency();
}

float TWTremolo::getDepth()
{
    return _depth.getTargetValue();
}

void TWTremolo::resetPhase(float rampTimeInSamples)
{
    _lfo->resetPhase(rampTimeInSamples);
}

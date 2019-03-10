//
//  TWBinauralBiquad.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/19/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWBinauralBiquad.h"

TWBinauralBiquad::TWBinauralBiquad()
{
    _sampleRate = 48000.0f;
}

TWBinauralBiquad::~TWBinauralBiquad()
{
    
}


void TWBinauralBiquad::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    for (int i=0; i < 2; i++) {
        _biquads[i].prepare(sampleRate);
    }
}

void TWBinauralBiquad::process(float& leftSample, float& rightSample)
{
    _biquads[0].process(leftSample);
    _biquads[1].process(rightSample);
}

void TWBinauralBiquad::release()
{
    for (int i=0; i < 2; i++) {
        _biquads[i].release();
    }
}




#pragma mark - Parameters

void TWBinauralBiquad::setEnabled(bool enabled)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setEnabled(enabled);
    }
}

void TWBinauralBiquad::setFilterType(TWBiquad::TWFilterType type)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setFilterType(type);
    }
}

void TWBinauralBiquad::setCutoffFrequency(float newFc, float rampTime_ms)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setCutoffFrequency(newFc, rampTime_ms);
    }
}

void TWBinauralBiquad::setCutoffFrequencyInSamples(float newFc, float rampTimeSamples)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setCutoffFrequencyInSamples(newFc, rampTimeSamples);
    }
}

void TWBinauralBiquad::setResonance(float newQ, float rampTime_ms)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setResonance(newQ, rampTime_ms);
    }
}

void TWBinauralBiquad::setGain(float newGain, float rampTime_ms)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setGain(newGain, rampTime_ms);
    }
}



bool TWBinauralBiquad::getEnabled()
{
    return _biquads[0].getEnabled();
}

TWBiquad::TWFilterType TWBinauralBiquad::getFilterType()
{
    return _biquads[0].getFilterType();
}

float TWBinauralBiquad::getCutoffFrequency()
{
    return _biquads[0].getCutoffFrequency();
}

float TWBinauralBiquad::getResonance()
{
    return _biquads[0].getResonance();
}

float TWBinauralBiquad::getGain()
{
    return _biquads[0].getGain();
}




void TWBinauralBiquad::setLFOEnabled(bool enabled)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setLFOEnabled(enabled);
    }
}

void TWBinauralBiquad::setLFOFrequency(float newFc, float rampTime_ms)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setLFOFrequency(newFc, rampTime_ms);
    }
}

void TWBinauralBiquad::setLFORange(float newRange, float rampTime_ms)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].setLFORange(newRange, rampTime_ms);
    }
}

void TWBinauralBiquad::setLFOOffset(float lfoOffset, float rampTime_ms)
{
    _biquads[1].setLFOOffset(lfoOffset, rampTime_ms);
}

void TWBinauralBiquad::resetLFOPhase(float rampTimeInSamples)
{
    for (int i=0; i < 2; i++) {
        _biquads[i].resetLFOPhase(rampTimeInSamples);
    }
}



bool TWBinauralBiquad::getLFOEnabled()
{
    return _biquads[0].getLFOEnabled();
}

float TWBinauralBiquad::getLFOFrequency()
{
    return _biquads[0].getLFOFrequency();
}

float TWBinauralBiquad::getLFORange()
{
    return _biquads[0].getLFORange();
}

float TWBinauralBiquad::getLFOOffset()
{
    return _biquads[1].getLFOOffset();
}


//
//  TWBinauralSynth.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/17/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWBinauralSynth.h"

#include <math.h>
#include <stdlib.h>

#define DEBUG_PRINT     0

#define M_2PI   6.28318530717958647692528676655900576

TWBinauralSynth::TWBinauralSynth()
{
    _sampleRate = 48000.0f;
    
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].setWaveform(TWOscillator::Sine);
        _oscillators[i].setFrequency(100.0f, 0.0f);
        _oscillators[i].setAmplitude(1.0f, 0.0f);
        _oscillators[i].setDutyCycle(0.5f, 0.0f);
        _oscillators[i].setPhaseOfst(0.0f, 0.0f);
    }
    
    _baseFrequency = 100.0f;
    _beatFrequency = 0.0f;
    
//    _baseFrequency.setTargetValue(100.0f, 0.0f);
//    _beatFrequency.setTargetValue(0.0f, 0.0f);
    _mononess.setTargetValue(0.0f, 0.0f);
    resetPhase(0);
    
    _fmOsc.setWaveform(TWOscillator::Sine);
    _fmOsc.setFrequency(0.001, 0.0f);
    _fmOsc.setAmplitude(0.0f, 0.0f);
    _fmOsc.setDutyCycle(0.5f, 0.0f);
    _fmOsc.setPhaseOfst(0.0f, 0.0f);
}

TWBinauralSynth::~TWBinauralSynth()
{
    
}




void TWBinauralSynth::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].prepare(sampleRate);
    }
    _fmOsc.prepare(sampleRate);
    _setIsRunning(true);
}

void TWBinauralSynth::getSample(float& leftSample, float& rightSample)
{
//    _setFrequencies();
    
    float mononess = _mononess.getCurrentValue() / 2.0f;
    float leftOsc = _oscillators[0].getSample();
    float rightOsc = _oscillators[1].getSample();
    
    leftSample = (leftOsc * (1.0f - mononess)) + (rightOsc * mononess);
    rightSample = (rightOsc * (1.0f - mononess)) + (leftOsc * mononess);
}

void TWBinauralSynth::release()
{
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].release();
    }
    _fmOsc.release();
    _setIsRunning(false);
}




void TWBinauralSynth::setWaveform(TWOscillator::TWWaveform type)
{
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].setWaveform(type);
    }
}

void TWBinauralSynth::setBaseFrequency(float baseFrequency, float rampTime_ms)
{
    _baseFrequency = baseFrequency;
    _calculateFrequencies(rampTime_ms);
//    _baseFrequency.setTargetValue(baseFrequency, rampTime_ms / 1000.0f * _sampleRate);
}

void TWBinauralSynth::setBeatFrequency(float beatFrequency, float rampTime_ms)
{
    _beatFrequency = beatFrequency;
    _calculateFrequencies(rampTime_ms);
//    _beatFrequency.setTargetValue(beatFrequency, rampTime_ms / 1000.0f * _sampleRate);
}

void TWBinauralSynth::setAmplitude(float newAmplitude, float rampTime_ms)
{
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].setAmplitude(newAmplitude, rampTime_ms);
    }
}

void TWBinauralSynth::setDutyCycle(float newDutyCycle, float rampTime_ms)
{
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].setDutyCycle(newDutyCycle, rampTime_ms);
    }
}

void TWBinauralSynth::setPhaseOffset(int channel, float phaseOffset, float rampTime_ms)
{
    if ((channel >= 0) && (channel < kNumberChannels)) {
        _oscillators[channel].setPhaseOfst(phaseOffset, rampTime_ms);
    }
}

void TWBinauralSynth::setMononess(float mononess, float rampTime_ms)
{
    _mononess.setTargetValue(mononess, rampTime_ms / 1000.0f * _sampleRate);
}


void TWBinauralSynth::setFMWaveform(TWOscillator::TWWaveform type)
{
    _fmOsc.setWaveform(type);
}

void TWBinauralSynth::setFMAmount(float fmAmount, float rampTime_ms)
{
    _fmOsc.setAmplitude(fmAmount, rampTime_ms);
}

void TWBinauralSynth::setFMFrequency(float fmFrequency, float rampTime_ms)
{
    _fmOsc.setFrequency(fmFrequency, rampTime_ms);
}



void TWBinauralSynth::resetPhase(float rampTimeInSamples)
{
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].resetPhase(rampTimeInSamples);
    }
}




TWOscillator::TWWaveform TWBinauralSynth::getWaveform()
{
    return _oscillators[0].getWaveform();
}

float TWBinauralSynth::getBaseFrequency()
{
    return _baseFrequency;
//    return _baseFrequency.getTargetValue();
}

float TWBinauralSynth::getBeatFrequency()
{
    return _beatFrequency;
//    return _beatFrequency.getTargetValue();
}

float TWBinauralSynth::getAmplitude()
{
    return _oscillators[0].getAmplitude();
}

float TWBinauralSynth::getDutyCycle()
{
    return _oscillators[0].getDutyCycle();
}

float TWBinauralSynth::getPhaseOffset(int channel)
{
    if ((channel >= 0) && (channel < kNumberChannels)) {
        return _oscillators[channel].getPhaseOfst();
    } else {
        return 0.0f;
    }
}

float TWBinauralSynth::getMononess()
{
    return _mononess.getTargetValue();
}


TWOscillator::TWWaveform TWBinauralSynth::getFMWaveform()
{
    return _fmOsc.getWaveform();
}

float TWBinauralSynth::getFMAmount()
{
    return _fmOsc.getAmplitude();
}

float TWBinauralSynth::getFMFrequency()
{
    return _fmOsc.getFrequency();
}


void TWBinauralSynth::_setIsRunning(bool isRunning)
{
//    _beatFrequency.setIsRunning(isRunning);
//    _baseFrequency.setIsRunning(isRunning);
    _mononess.setIsRunning(isRunning);
}

//void TWBinauralSynth::_setFrequencies()
//{
//    float baseFrequency = _baseFrequency.getCurrentValue();
//    float beatFrequency = _beatFrequency.getCurrentValue();
//
//    float leftBaseFrequency  = baseFrequency + (beatFrequency / 2.0f);
//    float rightBaseFrequency = baseFrequency - (beatFrequency / 2.0f);
//
//    _oscillators[0].setFrequency(leftBaseFrequency, 0.0f);
//    _oscillators[1].setFrequency(rightBaseFrequency, 0.0f);
//}

void TWBinauralSynth::_calculateFrequencies(float rampTime_ms)
{
    float leftFrequency = _baseFrequency + (_beatFrequency / 2.0f);
    float rightFrequency = _baseFrequency - (_beatFrequency / 2.0f);

    _oscillators[0].setFrequency(leftFrequency, rampTime_ms);
    _oscillators[1].setFrequency(rightFrequency, rampTime_ms);
}

//
//  TWBiquad.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/24/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//
//  http://shepazu.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html

#include "TWBiquad.h"
#include <math.h>

#define DEBUG_PRINT     0

#define n_1             0
#define n_2             1

#define kMinFrequency   10.0f
#define kMaxFrequency   22000.0f


TWBiquad::TWBiquad()
{
    _sampleRate = 48000.0f;
    
    _filterType = Lowpass;
    _newCutoff = 240.0f;
    _cutoff.setParameterID(55);
    _resonance.setTargetValue(M_SQRT1_2, 0.0f);
    _gain.setTargetValue(1.0f, 0.0f);
    
    _lfo = new TWOscillator();
    _lfo->setWaveform(TWOscillator::Sine);
    _lfo->setAmplitude(1.0f, 0.0f);
    _lfo->setFrequency(1.0f, 0.0f);
    _lfoEnabled = false;
    _newRange = 100.0f;
    
    _setCutoffParameters(0.0f);
    
    _enabled = false;
    _setIsRunning(false);
    _computeFilterParameters();
    _debug = 0;
    
    _x[n_1] = _x[n_2] = _y[n_1] = _y[n_2] = 0.0f;
}

TWBiquad::~TWBiquad()
{
    delete _lfo;
}




void TWBiquad::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    _lfo->prepare(sampleRate);
    _setIsRunning(true);
}

void TWBiquad::process(float& sample)
{
    if (!_enabled) {
        float yn = _x[n_2];
        _x[n_2] = _x[n_1];
        _x[n_1] = sample;
        sample = yn;
        return;
    }
    
    float xn = sample;
    float yn = 0.0f;
    _computeFilterParameters();
    
    yn =    ((_b[0] / _a[0] * xn)      +
             (_b[1] / _a[0] * _x[n_1]) +
             (_b[2] / _a[0] * _x[n_2]) -
             (_a[1] / _a[0] * _y[n_1]) -
             (_a[2] / _a[0] * _y[n_2]));
    
    
    _x[n_2] = _x[n_1];
    _x[n_1] = xn;
    _y[n_2] = _y[n_1];
    _y[n_1] = yn;
    
    sample = yn * _gain.getCurrentValue();
}

void TWBiquad::release()
{
    _lfo->release();
    _setIsRunning(false);
}




#pragma mark - Parameters

void TWBiquad::setEnabled(bool enabled)
{
    _enabled = enabled;
}

void TWBiquad::setFilterType(TWFilterType type)
{
    _filterType = type;
}

void TWBiquad::setCutoffFrequency(float newFc, float rampTime_ms)
{
    if (newFc <= kMinFrequency) {
        _newCutoff = kMinFrequency;
    } else if (newFc >= kMaxFrequency) {
        _newCutoff = kMaxFrequency;
    } else {
        _newCutoff = newFc;
    }
    _setCutoffParameters(rampTime_ms);
}

void TWBiquad::setCutoffFrequencyInSamples(float newFc, float rampTimeSamples)
{
    if (newFc <= kMinFrequency) {
        _newCutoff = kMinFrequency;
    } else if (newFc >= kMaxFrequency) {
        _newCutoff = kMaxFrequency;
    } else {
        _newCutoff = newFc;
    }
    _setCutoffParametersInSamples(rampTimeSamples);
}

void TWBiquad::setResonance(float newQ, float rampTime_ms)
{
    _resonance.setTargetValue(newQ, (rampTime_ms / 1000.0f) * _sampleRate);
}

void TWBiquad::setGain(float newGain, float rampTime_ms)
{
    _gain.setTargetValue(newGain, (rampTime_ms / 1000.0f) * _sampleRate);
}



bool TWBiquad::getEnabled()
{
    return _enabled;
}

TWBiquad::TWFilterType TWBiquad::getFilterType()
{
    return _filterType;
}

float TWBiquad::getCutoffFrequency()
{
    return _cutoff.getTargetValue();
}

float TWBiquad::getResonance()
{
    return _resonance.getTargetValue();
}

float TWBiquad::getGain()
{
    return _gain.getTargetValue();
}




void TWBiquad::setLFOEnabled(bool enable)
{
    _lfoEnabled = enable;
}

void TWBiquad::setLFOFrequency(float newFc, float rampTime_ms)
{
    _lfo->setFrequency(newFc, rampTime_ms);
}

void TWBiquad::setLFORange(float newRange, float rampTime_ms)
{
    _newRange = newRange;
    _setCutoffParameters(rampTime_ms);
}

void TWBiquad::setLFOOffset(float lfoOffset, float rampTime_ms)
{
    _lfo->setPhaseOfst(lfoOffset, rampTime_ms);
}

void TWBiquad::resetLFOPhase(float rampTimeInSamples)
{
    _lfo->resetPhase(rampTimeInSamples);
}



bool TWBiquad::getLFOEnabled()
{
    return _lfoEnabled;
}

float TWBiquad::getLFOFrequency()
{
    return _lfo->getFrequency();
}

float TWBiquad::getLFORange()
{
    return _lfoRange.getTargetValue();
}

float TWBiquad::getLFOOffset()
{
    return _lfo->getPhaseOfst();
}




#pragma mark - Internal

void TWBiquad::_setIsRunning(bool isRunning)
{
    _cutoff.setIsRunning(isRunning);
    _gain.setIsRunning(isRunning);
    _resonance.setIsRunning(isRunning);
    _lfoRange.setIsRunning(isRunning);
}

void TWBiquad::_computeFilterParameters()
{
    float freq = 0.0f;
    if (_lfoEnabled) {
        freq = (_lfo->getSample() * _lfoRange.getCurrentValue() / 2.0f) + _cutoff.getCurrentValue();
    } else {
        freq = _cutoff.getCurrentValue();
    }
    
    float q = _resonance.getCurrentValue();
    
    float w = 2.0 * M_PI * freq / _sampleRate;
    float cw = cosf(w);
    float sw = sinf(w);
    float al = sw / (2.0f * q);
    
    switch (_filterType) {
        
        case Lowpass:
            _b[0] = (1.0f - cw) / 2.0f;
            _b[1] = 1.0f - cw;
            _b[2] = _b[0];
            _a[0] = 1 + al;
            _a[1] = -2.0f * cw;
            _a[2] = 1.0f - al;
            break;
            
        case Highpass:
            _b[0] = (1.0f + cw) / 2.0f;
            _b[1] = -(1.0f + cw);
            _b[2] = _b[0];
            _a[0] = 1 + al;
            _a[1] = -2.0f * cw;
            _a[2] = 1.0f - al;
            break;
            
        case Bandpass1:
            // Constant skirt gain. Peak Gain = Q
            _b[0] = q * al;
            _b[1] = 0.0f;
            _b[2] = -q * al;
            _a[0] = 1.0f + al;
            _a[1] = -2.0f * cw;
            _a[2] = 1.0f - al;
            break;
            
        case Bandpass2:
            // Constant to 0dB peak gain
            _b[0] = al;
            _b[1] = 0.0f;
            _b[2] = -al;
            _a[0] = 1.0f + al;
            _a[1] = -2.0f * cw;
            _a[2] = 1.0f - al;
            break;
            
        case Notch:
            _b[0] = 1.0f;
            _b[1] = -2.0f * cw;
            _b[2] = 1.0f;
            _a[0] = 1.0f + al;
            _a[1] = -2.0f * cw;
            _a[2] = 1.0f - al;
            break;
            
        case Allpass:
            _b[0] = 1.0f - al;
            _b[1] = -2.0f * cw;
            _b[2] = 1.0f + al;
            _a[0] = 1.0f + al;
            _a[1] = -2.0f * cw;
            _a[2] = 1.0f - al;
            break;
            
        default:
            break;
    }
}


void TWBiquad::_setCutoffParameters(float rampTime_ms)
{
    float halfRange = _newRange * 0.5f;
    if ((_newCutoff - halfRange) <= kMinFrequency) {
        _newRange = (_newCutoff - kMinFrequency) * 2.0f;
    } else if ((_newCutoff + halfRange) >= kMaxFrequency) {
        _newRange = (kMaxFrequency - _newCutoff) * 2.0f;
    }
    _lfoRange.setTargetValue(_newRange, rampTime_ms * _sampleRate / 1000.0f);
    _cutoff.setTargetValue(_newCutoff, rampTime_ms * _sampleRate / 1000.0f);
}


void TWBiquad::_setCutoffParametersInSamples(float rampTimeSamples)
{
    float halfRange = _newRange * 0.5f;
    if ((_newCutoff - halfRange) <= kMinFrequency) {
        _newRange = (_newCutoff - kMinFrequency) * 2.0f;
    } else if ((_newCutoff + halfRange) >= kMaxFrequency) {
        _newRange = (kMaxFrequency - _newCutoff) * 2.0f;
    }
    _lfoRange.setTargetValue(_newRange, rampTimeSamples);
    _cutoff.setTargetValue(_newCutoff, rampTimeSamples);
}

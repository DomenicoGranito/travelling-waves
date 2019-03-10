//
//  TWOscillator.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWOscillator.h"
#include <math.h>
#include <stdlib.h>

#define DEBUG_PRINT     0

#define M_2PI   6.28318530717958647692528676655900576

TWOscillator::TWOscillator()
{
    _sampleRate = 48000.0f;
    
    _waveform = Sine;
    
    _frequency.setTargetValue(100.0f, 0.0);
    _frequency.setParameterID(1);
    
    _amplitude.setTargetValue(1.0f, 0.0f);
    
    _dutyCycle.setTargetValue(0.5f, 0.0f);
    
    _phaseOffset.setTargetValue(0.0f, 0.0f);

    _phase = 0.0f;
    _phaseResetIncrement = 0.0f;
    
    _isResettingPhase = false;
    _phaseResetIncrement = 0.0f;
    
    _setIsRunning(false);
    
    _debug  = 0;
}

TWOscillator::~TWOscillator()
{
    
}




void TWOscillator::prepare(float sampleRate)
{
    _setIsRunning(true);
    _sampleRate = sampleRate;
    _phase = 0.0f;
}

float TWOscillator::getSample()
{
    float phase = _getPhase();
    float amplitude = _amplitude.getCurrentValue();
    float dutyCycle = _dutyCycle.getCurrentValue();
    float sample = 0.0f;
    
    switch (_waveform) {
        case Sine:
            sample = amplitude * sin(phase);
            break;
            
        case Sawtooth:
            sample = amplitude * (((fmodf(phase + M_PI, M_2PI)) / M_PI) - 1.0f);
            break;
            
        case Square:
            (phase <= (dutyCycle * M_2PI)) ? sample = amplitude : sample = -amplitude;
            break;
            
        case Noise:
            sample = amplitude * ((2.0f * ((float)rand() / RAND_MAX)) - 1.0f);
            break;
            
        default:
            break;
    }
    
#if DEBUG_PRINT
    if (_debug == 1000) {
        printf("Sample: %f\n", sample);
        _debug = 0;
    }
    _debug++;
#endif
    
    return sample;
}

void TWOscillator::release()
{
    _setIsRunning(false);
}




void TWOscillator::setWaveform(TWWaveform type)
{
    _waveform = type;
}

void TWOscillator::setFrequency(float newFrequency, float rampTime_ms)
{
    _frequency.setTargetValue(newFrequency, (rampTime_ms / 1000.0f) * _sampleRate);
}

void TWOscillator::setAmplitude(float newAmplitude, float rampTime_ms)
{
    newAmplitude > 1.0f ? newAmplitude = 1.0 : newAmplitude < -1.0f ? newAmplitude = -1.0f : newAmplitude;
    _amplitude.setTargetValue(newAmplitude, (rampTime_ms / 1000.0f) * _sampleRate);
}

void TWOscillator::setDutyCycle(float newDutyCycle, float rampTime_ms)
{
    newDutyCycle > 0.9999f ? newDutyCycle = 0.9999f : newDutyCycle < 0.0f ? newDutyCycle = 0.0f : newDutyCycle;
    _dutyCycle.setTargetValue(newDutyCycle, (rampTime_ms / 1000.0f) * _sampleRate);
}

void TWOscillator::setPhaseOfst(float newPhaseOfst, float rampTime_ms)
{
    _phaseOffset.setTargetValue(newPhaseOfst, rampTime_ms);
}

void TWOscillator::resetPhase(float rampTimeInSamples)
{
    _isResettingPhase = true;
    if (rampTimeInSamples == 0.0) {
        _phase = 0.0f;
    } else {
        _phaseResetIncrement = (M_2PI - _phase) / rampTimeInSamples;
    }
}

TWOscillator::TWWaveform TWOscillator::getWaveform()
{
    return _waveform;
}

float TWOscillator::getFrequency()
{
    return _frequency.getTargetValue();
}

float TWOscillator::getAmplitude()
{
    return _amplitude.getTargetValue();
}

float TWOscillator::getDutyCycle()
{
    return _dutyCycle.getTargetValue();
}

float TWOscillator::getPhaseOfst()
{
    return _phaseOffset.getTargetValue();
}


float TWOscillator::_getPhase()
{
    if (_phase == 0.0f) {
        if (_isResettingPhase) {
            printf("Bingo! Reset Inc: %f\n", _phaseResetIncrement);
        }
        _isResettingPhase = false;
    }
    if (_isResettingPhase) {
        _phaseIncrement = _phaseResetIncrement;
    } else {
        _phaseIncrement = (M_2PI * _frequency.getCurrentValue() / _sampleRate);
    }
    _phase = fmodf(_phase + _phaseIncrement, M_2PI);
    return fmodf(_phase + _phaseOffset.getCurrentValue(), M_2PI);
}

void TWOscillator::_setIsRunning(bool isRunning)
{
    _frequency.setIsRunning(isRunning);
    _amplitude.setIsRunning(isRunning);
    _dutyCycle.setIsRunning(isRunning);
    _phaseOffset.setIsRunning(isRunning);
}

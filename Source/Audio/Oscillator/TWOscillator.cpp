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
#include <cstdarg>

#define DEBUG_PRINT                 1
static const int kDebugCountdown    = 200;

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
    
    _softClipp.setTargetValue(0.0f, 0.0f);

    _phase = 0.0f;
    _phaseResetIncrement = 0.0f;
    
    _isResettingPhase = false;
    _phaseResetIncrement = 0.0f;
    
    _currentRandomSample = 0.0f;
    _didCyclePhase = false;
    
    _setIsRunning(false);
    
    _debugCount  = kDebugCountdown;
    _debugID = 0;
}

TWOscillator::~TWOscillator()
{
    
}




void TWOscillator::prepare(float sampleRate)
{
    _setIsRunning(true);
    _sampleRate = sampleRate;
    _phase = 0.0f;
    _currentRandomSample = 0.0f;
    _debugSampleCount = 0;
}

float TWOscillator::getSample()
{
    float phase = _getPhase();
    float amplitude = _amplitude.getCurrentValue();
    float dutyCycle = _dutyCycle.getCurrentValue();
    float sample = 0.0f;
    
    switch (_waveform) {
        case Sine:
            sample = sin(phase);
            break;
            
        case Sawtooth:
            sample = (((fmodf(phase + M_PI, M_2PI)) / M_PI) - 1.0f);
            break;
            
        case Square:
            (phase <= (dutyCycle * M_2PI)) ? sample = 1.0f : sample = -1.0f;
            break;
            
        case Noise:
            sample = ((2.0f * ((float)rand() / RAND_MAX)) - 1.0f);
            break;
            
        case Random:
            if (_didCyclePhase) {
                _currentRandomSample = ((2.0f * ((float)rand() / RAND_MAX)) - 1.0f);
//                _log("Zero Phase [%lld]! %f\n", _debugSampleCount, _currentRandomSample);
            }
            sample = _currentRandomSample;
            break;
            
        default:
            break;
    }
    
    float softClipp = _softClipp.getCurrentValue();
    if (softClipp != 0.0f) {
        float prescale = tanhf(softClipp * M_PI);
        float softClipScale = 2.0 * M_2PI * powf(1000.0f, prescale - 1.0f);
        sample = tanhf(softClipScale * sample) / tanhf(softClipScale);
    }
    
#if DEBUG_PRINT
//    if (_debugID == 2) {
//        if (_debugCount == 0) {
//            printf("SS:%d, ShapeScale: %f, Sample: %f, Shaped: %f\n", _shouldApplyShape, shapeScale, sample, shapedSample);
//            _debugCount = kDebugCountdown;
//        }
//        _debugCount--;
//    }
#endif
    _debugSampleCount++;
    
    return (sample * amplitude);
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

void TWOscillator::setSoftClipp(float newSoftClipp, float rampTime_ms)
{
    newSoftClipp >= 1.0f ? newSoftClipp = 1.0f : newSoftClipp <= 0.0f ? newSoftClipp = 0.0f : newSoftClipp;
    _softClipp.setTargetValue(newSoftClipp, (rampTime_ms / 1000.0f) * _sampleRate);
}


void TWOscillator::resetPhase(float rampTimeInSamples)
{
    if (rampTimeInSamples == 0.0) {
        _phase = 0.0f;
    } else {
        _isResettingPhase = true;
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

float TWOscillator::getSoftClipp()
{
    return _softClipp.getTargetValue();
}



float TWOscillator::_getPhase()
{
    if ((_phase + _phaseIncrement) >= M_2PI) {
        if (_isResettingPhase) {
//            _log("Bingo! Reset Inc: %f. Act Inc: %f\n", _phaseResetIncrement, _phaseIncrement);
        }
//        _log("Zero Cross Phase! %lld\n", _debugSampleCount);
        _isResettingPhase = false;
        _didCyclePhase = true;
    } else {
        _didCyclePhase = false;
    }
    
    
    if (_isResettingPhase) {
        _phaseIncrement = _phaseResetIncrement;
    } else {
        _phaseIncrement = (M_2PI * _frequency.getCurrentValue() / _sampleRate);
    }
    _phase = fmodf(_phase + _phaseIncrement, M_2PI);
//    _log("Phase: %f. Inc: %f\n", _phase, _phaseIncrement);
    return fmodf(_phase + _phaseOffset.getCurrentValue(), M_2PI);
}

void TWOscillator::_setIsRunning(bool isRunning)
{
    _frequency.setIsRunning(isRunning);
    _amplitude.setIsRunning(isRunning);
    _dutyCycle.setIsRunning(isRunning);
    _softClipp.setIsRunning(isRunning);
    _phaseOffset.setIsRunning(isRunning);
}


void TWOscillator::setDebugID(int debugID)
{
    _debugID = debugID;
}

void TWOscillator::_log(const char * format, ...)
{
    if (_debugID == 1) {
        va_list argptr;
        va_start(argptr, format);
        vfprintf(stderr, format, argptr);
        va_end(argptr);
    }
}

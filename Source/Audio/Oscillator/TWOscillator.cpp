//
//  TWOscillator.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWOscillator.h"
#include "TWAudioUtilities.h"
#include "TWLog.h"

#include <math.h>
#include <stdlib.h>
#include <cstdarg>

#define DEBUG_PRINT                 1
static const int kDebugCountdown    = 200;

#define M_2PI                       6.28318530717958647692528676655900576



TWOscillator::TWOscillator()
{
    _sampleRate = 48000.0f;
    
    TWParameter* waveform = new TWParameter();
    waveform->setMaxValue(TWWaveform::NumWaveforms);
    waveform->setMinValue(TWWaveform::Sine);
    waveform->updateDefaultValue(TWWaveform::Sine);
    waveform->setTargetValue(TWWaveform::Sine, 0.0f);
    waveform->setParameterID(ParameterID::WaveformType);
    _parameters.insert(std::make_pair(ParameterID::WaveformType, waveform));
    
    TWParameter* frequency = new TWParameter();
    frequency->setMaxValue(_sampleRate / 2.0f);
    frequency->setMinValue(0.01f);
    frequency->updateDefaultValue(256.0f);
    frequency->setTargetValue(256.0f, 0.0f);
    frequency->setParameterID(ParameterID::Frequency);
    _parameters.insert(std::make_pair(ParameterID::Frequency, frequency));
    
    TWParameter* amplitude = new TWParameter();
    amplitude->setMaxValue(0.0f);
    amplitude->setMinValue(TWAudioUtilities::MinLevelDB());
    amplitude->updateDefaultValue(-6.0f);
    amplitude->setTargetValue(-6.0f, 0.0f);
    amplitude->setParameterID(ParameterID::AmplitudeDB);
    _parameters.insert(std::make_pair(ParameterID::AmplitudeDB, amplitude));
    
    TWParameter* dutyCycle = new TWParameter();
    dutyCycle->setMaxValue(0.99f);
    dutyCycle->setMinValue(0.01f);
    dutyCycle->updateDefaultValue(0.5f);
    dutyCycle->setTargetValue(0.5f, 0.0f);
    dutyCycle->setParameterID(ParameterID::DutyCycle);
    _parameters.insert(std::make_pair(ParameterID::DutyCycle, dutyCycle));
    
    TWParameter* softClipp = new TWParameter();
    softClipp->setMaxValue(1.0f);
    softClipp->setMinValue(0.0f);
    softClipp->updateDefaultValue(0.0f);
    softClipp->setTargetValue(0.0f, 0.0f);
    softClipp->setParameterID(ParameterID::SoftClipp);
    _parameters.insert(std::make_pair(ParameterID::SoftClipp, softClipp));
    
    TWParameter* phaseOffset = new TWParameter();
    phaseOffset->setMaxValue(M_2PI);
    phaseOffset->setMinValue(0.0f);
    phaseOffset->updateDefaultValue(0.0f);
    phaseOffset->setTargetValue(0.0f, 0.0f);
    phaseOffset->setParameterID(ParameterID::PhaseOffset);
    _parameters.insert(std::make_pair(ParameterID::PhaseOffset, phaseOffset));
    
    
//    _waveform = Sine;
    
//    _frequency.setTargetValue(100.0f, 0.0);
//    _frequency.setParameterID(1);
//
//    _amplitude.setTargetValue(1.0f, 0.0f);
//
//    _dutyCycle.setTargetValue(0.5f, 0.0f);
//
//    _phaseOffset.setTargetValue(0.0f, 0.0f);
//
//    _softClipp.setTargetValue(0.0f, 0.0f);

    
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
    _parameters.clear();
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
    TWWaveform waveform = (TWWaveform)_parameterForID(TWOscillator::WaveformType)->getTargetValue();
    
    float phase = _getPhase();
    float amplitude = TWAudioUtilities::DB2Linear(_parameterForID(ParameterID::AmplitudeDB)->getCurrentValue());
    float dutyCycle = _parameterForID(ParameterID::DutyCycle)->getCurrentValue();
    
    float sample = 0.0f;
    
    switch (waveform) {
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
    
    float softClipp = _parameterForID(ParameterID::SoftClipp)->getCurrentValue();
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



void TWOscillator::setParameterValue(int parameterID, float value, float rampTime_ms)
{
    TWParameter* parameter = _parameterForID(parameterID);
    if (parameter == nullptr) {
        TWLog::Log(TWLog::LOG_ERROR, "TWOscillator::setParameterValue: Error! No parameter of ID(%d) found\n", parameterID);
        return;
    }
    parameter->setTargetValue(value, (rampTime_ms / 1000.0f) * _sampleRate);
}

float TWOscillator::getParameterValue(int parameterID)
{
    TWParameter* parameter = _parameterForID(parameterID);
    if (parameter == nullptr) {
        TWLog::Log(TWLog::LOG_ERROR, "TWOscillator::getParameterValue: Error! No parameter of ID(%d) found\n", parameterID);
        return 0.0f;
    }
    return parameter->getTargetValue();
}

float TWOscillator::getParameterMinValue(int parameterID)
{
    TWParameter* parameter = _parameterForID(parameterID);
    if (parameter == nullptr) {
        TWLog::Log(TWLog::LOG_ERROR, "TWOscillator::getParameterMinValue: Error! No parameter of ID(%d) found\n", parameterID);
        return 0.0f;
    }
    return parameter->getMinValue();
}

float TWOscillator::getParameterMaxValue(int parameterID)
{
    TWParameter* parameter = _parameterForID(parameterID);
    if (parameter == nullptr) {
        TWLog::Log(TWLog::LOG_ERROR, "TWOscillator::getParameterMaxValue: Error! No parameter of ID(%d) found\n", parameterID);
        return 0.0f;
    }
    return parameter->getMaxValue();
}

void TWOscillator::setParameterDefaultValue(int parameterID, float rampTime_ms)
{
    TWParameter* parameter = _parameterForID(parameterID);
    if (parameter == nullptr) {
        TWLog::Log(TWLog::LOG_ERROR, "TWOscillator::getParameterMaxValue: Error! No parameter of ID(%d) found\n", parameterID);
        return;
    }
    parameter->setDefaultValue((rampTime_ms / 1000.0f) * _sampleRate);
}

float TWOscillator::getParameterDefaultValue(int parameterID)
{
    TWParameter* parameter = _parameterForID(parameterID);
    if (parameter == nullptr) {
        TWLog::Log(TWLog::LOG_ERROR, "TWOscillator::getParameterMaxValue: Error! No parameter of ID(%d) found\n", parameterID);
        return 0.0f;
    }
    return parameter->getDefaultValue();
}




//void TWOscillator::setWaveform(TWOscillator::enum WaveformType type)
//{
//    _waveform = type;
//}
//
//void TWOscillator::setFrequency(float newFrequency, float rampTime_ms)
//{
//    _frequency.setTargetValue(newFrequency, (rampTime_ms / 1000.0f) * _sampleRate);
//}
//
//void TWOscillator::setAmplitude(float newAmplitude, float rampTime_ms)
//{
//    newAmplitude > 1.0f ? newAmplitude = 1.0 : newAmplitude < -1.0f ? newAmplitude = -1.0f : newAmplitude;
//    _amplitude.setTargetValue(newAmplitude, (rampTime_ms / 1000.0f) * _sampleRate);
//}
//
//void TWOscillator::setDutyCycle(float newDutyCycle, float rampTime_ms)
//{
//    newDutyCycle > 0.9999f ? newDutyCycle = 0.9999f : newDutyCycle < 0.0f ? newDutyCycle = 0.0f : newDutyCycle;
//    _dutyCycle.setTargetValue(newDutyCycle, (rampTime_ms / 1000.0f) * _sampleRate);
//}
//
//void TWOscillator::setPhaseOfst(float newPhaseOfst, float rampTime_ms)
//{
//    _phaseOffset.setTargetValue(newPhaseOfst, rampTime_ms);
//}
//
//void TWOscillator::setSoftClipp(float newSoftClipp, float rampTime_ms)
//{
//    newSoftClipp >= 1.0f ? newSoftClipp = 1.0f : newSoftClipp <= 0.0f ? newSoftClipp = 0.0f : newSoftClipp;
//    _softClipp.setTargetValue(newSoftClipp, (rampTime_ms / 1000.0f) * _sampleRate);
//}


void TWOscillator::resetPhase(float rampTimeInSamples)
{
    if (rampTimeInSamples == 0.0) {
        _phase = 0.0f;
    } else {
        _isResettingPhase = true;
        _phaseResetIncrement = (M_2PI - _phase) / rampTimeInSamples;
    }
}

//TWOscillator::Waveform TWOscillator::getWaveform()
//{
//    return _waveform;
//}
//
//float TWOscillator::getFrequency()
//{
//    return _frequency.getTargetValue();
//}
//
//float TWOscillator::getAmplitude()
//{
//    return _amplitude.getTargetValue();
//}
//
//float TWOscillator::getDutyCycle()
//{
//    return _dutyCycle.getTargetValue();
//}
//
//float TWOscillator::getPhaseOfst()
//{
//    return _phaseOffset.getTargetValue();
//}
//
//float TWOscillator::getSoftClipp()
//{
//    return _softClipp.getTargetValue();
//}



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
        float frequency = _parameterForID(ParameterID::Frequency)->getCurrentValue();
        _phaseIncrement = (M_2PI * frequency / _sampleRate);
    }
    _phase = fmodf(_phase + _phaseIncrement, M_2PI);
//    _log("Phase: %f. Inc: %f\n", _phase, _phaseIncrement);
    float phaseOffset = _parameterForID(ParameterID::PhaseOffset)->getCurrentValue();
    return fmodf(_phase + phaseOffset, M_2PI);
}

void TWOscillator::_setIsRunning(bool isRunning)
{
//    _frequency.setIsIORunning(isRunning);
//    _amplitude.setIsIORunning(isRunning);
//    _dutyCycle.setIsIORunning(isRunning);
//    _softClipp.setIsIORunning(isRunning);
//    _phaseOffset.setIsIORunning(isRunning);
    
    std::map<int, TWParameter*>::iterator it = _parameters.begin();
    while (it != _parameters.end()) {
        it->second->setIsIORunning(isRunning);
        it++;
    }
}


void TWOscillator::setDebugID(int debugID)
{
    _debugID = debugID;
}


TWParameter* TWOscillator::_parameterForID(int parameterID)
{
    TWParameter* parameter = nullptr;
    
    std::map<int, TWParameter*>::iterator it = _parameters.find(parameterID);
    if (it != _parameters.end()) {
        parameter = it->second;
    }
    
    return parameter;
}

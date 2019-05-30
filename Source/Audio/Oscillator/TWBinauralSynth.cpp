//
//  TWBinauralSynth.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/17/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWBinauralSynth.h"
#include "TWAudioUtilities.h"

#include <math.h>
#include <stdlib.h>

#define DEBUG_PRINT     0

#define M_2PI   6.28318530717958647692528676655900576

TWBinauralSynth::TWBinauralSynth()
{
    _sampleRate = 48000.0f;
    
    _baseFrequency = 256.0f;
    _beatFrequency = 0.0f;
    
    
    _mononess.setParameterID(1);
    _mononess.setMinValue(0.0f);
    _mononess.setMaxValue(1.0f);
    _mononess.setTargetValue(0.0f, 0.0f);
    
    
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].setParameterValue(TWOscillator::ParameterID::WaveformType, TWOscillator::TWWaveform::Sine, 0.0f);
        _oscillators[i].setParameterValue(TWOscillator::ParameterID::Frequency, 256.0f, 0.0f);
        _oscillators[i].setParameterValue(TWOscillator::ParameterID::AmplitudeDB, 0.0f, 0.0f);
        _oscillators[i].setParameterValue(TWOscillator::ParameterID::DutyCycle, 0.5f, 0.0f);
        _oscillators[i].setParameterValue(TWOscillator::ParameterID::PhaseOffset, 0.0f, 0.0f);
    }

    _fmOsc.setParameterValue(TWOscillator::ParameterID::WaveformType, TWOscillator::TWWaveform::Sine, 0.0f);
    _fmOsc.setParameterValue(TWOscillator::ParameterID::Frequency, 0.01, 0.0f);
    _fmOsc.setParameterValue(TWOscillator::ParameterID::AmplitudeDB, TWAudioUtilities::MinLevelDB(), 0.0f);
    _fmOsc.setParameterValue(TWOscillator::ParameterID::DutyCycle, 0.5f, 0.0f);
    _fmOsc.setParameterValue(TWOscillator::ParameterID::PhaseOffset, 0.0f, 0.0f);
    
    
    resetPhase(0);
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



void TWBinauralSynth::setParameterValue(int parameterID, float value, float rampTime_ms)
{
    switch (parameterID) {
        
        case WaveformType:
            for (int i=0; i < kNumberChannels; i++) {
                _oscillators[i].setParameterValue(TWOscillator::ParameterID::WaveformType, value, 0.0f);
            }
            break;
            
        case BaseFrequency:
            _baseFrequency = value;
            _calculateFrequencies(rampTime_ms);
            break;
            
        case BeatFrequency:
            _beatFrequency = value;
            _calculateFrequencies(rampTime_ms);
            break;
            
        case AmplitudeDB:
            for (int i=0; i < kNumberChannels; i++) {
                _oscillators[i].setParameterValue(TWOscillator::ParameterID::AmplitudeDB, value, rampTime_ms);
            }
            break;
            
        case DutyCycle:
            for (int i=0; i < kNumberChannels; i++) {
                _oscillators[i].setParameterValue(TWOscillator::ParameterID::DutyCycle, value, rampTime_ms);
            }
            break;
            
        case SoftClipp:
            for (int i=0; i < kNumberChannels; i++) {
                _oscillators[i].setParameterValue(TWOscillator::ParameterID::SoftClipp, value, rampTime_ms);
            }
            break;
            
        case PhaseOffset:
            _oscillators[0].setParameterValue(TWOscillator::ParameterID::PhaseOffset, value, rampTime_ms);
            break;
            
        case Mononess:
            _mononess.setTargetValue(value, rampTime_ms);
            break;
            
        case FMWaveform:
            _fmOsc.setParameterValue(TWOscillator::ParameterID::WaveformType, value, 0.0f);
            break;
            
        case FMAmount:
            _fmOsc.setParameterValue(TWOscillator::ParameterID::AmplitudeDB, value, rampTime_ms);
            break;
            
        case FMFrequency:
            _fmOsc.setParameterValue(TWOscillator::ParameterID::Frequency, value, rampTime_ms);
            break;
            
        default:
            break;
    }
}


float TWBinauralSynth::getParameterValue(int parameterID)
{
    float returnValue = 0.0f;
    
    switch (parameterID) {
            
        case WaveformType:
            returnValue = _oscillators[0].getParameterValue(TWOscillator::ParameterID::WaveformType);
            break;
            
        case BaseFrequency:
            returnValue = _baseFrequency;
            break;
            
        case BeatFrequency:
            returnValue = _beatFrequency;
            break;
            
        case AmplitudeDB:
            returnValue = _oscillators[0].getParameterValue(TWOscillator::ParameterID::AmplitudeDB);
            break;
            
        case DutyCycle:
            returnValue = _oscillators[0].getParameterValue(TWOscillator::ParameterID::DutyCycle);
            break;
            
        case SoftClipp:
            returnValue = _oscillators[0].getParameterValue(TWOscillator::ParameterID::SoftClipp);
            break;
            
        case PhaseOffset:
            returnValue = _oscillators[0].getParameterValue(TWOscillator::ParameterID::PhaseOffset);
            break;
            
        case Mononess:
            returnValue = _mononess.getTargetValue();
            break;
            
        case FMWaveform:
            returnValue = _fmOsc.getParameterValue(TWOscillator::ParameterID::WaveformType);
            break;
            
        case FMAmount:
            returnValue = _fmOsc.getParameterValue(TWOscillator::ParameterID::AmplitudeDB);
            break;
            
        case FMFrequency:
            returnValue = _fmOsc.getParameterValue(TWOscillator::ParameterID::Frequency);
            break;
            
        default:
            break;
    }
    
    return returnValue;
}



float TWBinauralSynth::getParameterMinValue(int parameterID)
{
    float returnValue = 0.0f;
    
    switch (parameterID) {
            
        case WaveformType:
            returnValue = _oscillators[0].getParameterMinValue(TWOscillator::ParameterID::WaveformType);
            break;
            
        case BaseFrequency:
            returnValue = 0.01f;
            break;
            
        case BeatFrequency:
            returnValue = 0.0f;
            break;
            
        case AmplitudeDB:
            returnValue = _oscillators[0].getParameterMinValue(TWOscillator::ParameterID::AmplitudeDB);
            break;
            
        case DutyCycle:
            returnValue = _oscillators[0].getParameterMinValue(TWOscillator::ParameterID::DutyCycle);
            break;
            
        case SoftClipp:
            returnValue = _oscillators[0].getParameterMinValue(TWOscillator::ParameterID::SoftClipp);
            break;
            
        case PhaseOffset:
            returnValue = _oscillators[0].getParameterMinValue(TWOscillator::ParameterID::PhaseOffset);
            break;
            
        case Mononess:
            returnValue = _mononess.getMinValue();
            break;
            
        case FMWaveform:
            returnValue = _fmOsc.getParameterMinValue(TWOscillator::ParameterID::WaveformType);
            break;
            
        case FMAmount:
            returnValue = _fmOsc.getParameterMinValue(TWOscillator::ParameterID::AmplitudeDB);
            break;
            
        case FMFrequency:
            returnValue = _fmOsc.getParameterMinValue(TWOscillator::ParameterID::Frequency);
            break;
            
        default:
            break;
    }
    
    return returnValue;
}


float TWBinauralSynth::getParameterMaxValue(int parameterID)
{
    float returnValue = 0.0f;
    
    switch (parameterID) {
            
        case WaveformType:
            returnValue = _oscillators[0].getParameterMaxValue(TWOscillator::ParameterID::WaveformType);
            break;
            
        case BaseFrequency:
            returnValue = _sampleRate / 2.0f;
            break;
            
        case BeatFrequency:
            returnValue = 48.0f;
            break;
            
        case AmplitudeDB:
            returnValue = _oscillators[0].getParameterMaxValue(TWOscillator::ParameterID::AmplitudeDB);
            break;
            
        case DutyCycle:
            returnValue = _oscillators[0].getParameterMaxValue(TWOscillator::ParameterID::DutyCycle);
            break;
            
        case SoftClipp:
            returnValue = _oscillators[0].getParameterMaxValue(TWOscillator::ParameterID::SoftClipp);
            break;
            
        case PhaseOffset:
            returnValue = _oscillators[0].getParameterMaxValue(TWOscillator::ParameterID::PhaseOffset);
            break;
            
        case Mononess:
            returnValue = _mononess.getMaxValue();
            break;
            
        case FMWaveform:
            returnValue = _fmOsc.getParameterMaxValue(TWOscillator::ParameterID::WaveformType);
            break;
            
        case FMAmount:
            returnValue = _fmOsc.getParameterMaxValue(TWOscillator::ParameterID::AmplitudeDB);
            break;
            
        case FMFrequency:
            returnValue = _fmOsc.getParameterMaxValue(TWOscillator::ParameterID::Frequency);
            break;
            
        default:
            break;
    }
    
    return returnValue;
    
}


//void TWBinauralSynth::setWaveform(TWOscillator::TWWaveform type)
//{
//    for (int i=0; i < kNumberChannels; i++) {
//        _oscillators[i].setWaveform(type);
//    }
//}
//
//void TWBinauralSynth::setBaseFrequency(float baseFrequency, float rampTime_ms)
//{
//    _baseFrequency = baseFrequency;
//    _calculateFrequencies(rampTime_ms);
////    _baseFrequency.setTargetValue(baseFrequency, rampTime_ms / 1000.0f * _sampleRate);
//}
//
//void TWBinauralSynth::setBeatFrequency(float beatFrequency, float rampTime_ms)
//{
//    _beatFrequency = beatFrequency;
//    _calculateFrequencies(rampTime_ms);
////    _beatFrequency.setTargetValue(beatFrequency, rampTime_ms / 1000.0f * _sampleRate);
//}
//
//void TWBinauralSynth::setAmplitude(float newAmplitude, float rampTime_ms)
//{
//    for (int i=0; i < kNumberChannels; i++) {
//        _oscillators[i].setAmplitude(newAmplitude, rampTime_ms);
//    }
//}
//
//void TWBinauralSynth::setDutyCycle(float newDutyCycle, float rampTime_ms)
//{
//    for (int i=0; i < kNumberChannels; i++) {
//        _oscillators[i].setDutyCycle(newDutyCycle, rampTime_ms);
//    }
//}
//
//void TWBinauralSynth::setPhaseOffset(int channel, float phaseOffset, float rampTime_ms)
//{
//    if ((channel >= 0) && (channel < kNumberChannels)) {
//        _oscillators[channel].setPhaseOfst(phaseOffset, rampTime_ms);
//    }
//}

//void TWBinauralSynth::setMononess(float mononess, float rampTime_ms)
//{
//    _mononess.setTargetValue(mononess, rampTime_ms / 1000.0f * _sampleRate);
//}
//
//void TWBinauralSynth::setSoftClipp(float softClipp, float rampTime_ms)
//{
//    for (int i=0; i < kNumberChannels; i++) {
//        _oscillators[i].setSoftClipp(softClipp, rampTime_ms);
//    }
//}


//void TWBinauralSynth::setFMWaveform(TWOscillator::TWWaveform type)
//{
//    _fmOsc.setWaveform(type);
//}
//
//void TWBinauralSynth::setFMAmount(float fmAmount, float rampTime_ms)
//{
//    _fmOsc.setAmplitude(fmAmount, rampTime_ms);
//}
//
//void TWBinauralSynth::setFMFrequency(float fmFrequency, float rampTime_ms)
//{
//    _fmOsc.setFrequency(fmFrequency, rampTime_ms);
//}



void TWBinauralSynth::resetPhase(float rampTimeInSamples)
{
    for (int i=0; i < kNumberChannels; i++) {
        _oscillators[i].resetPhase(rampTimeInSamples);
    }
}




//TWOscillator::TWWaveform TWBinauralSynth::getWaveform()
//{
//    return _oscillators[0].getWaveform();
//}
//
//float TWBinauralSynth::getBaseFrequency()
//{
//    return _baseFrequency;
////    return _baseFrequency.getTargetValue();
//}
//
//float TWBinauralSynth::getBeatFrequency()
//{
//    return _beatFrequency;
////    return _beatFrequency.getTargetValue();
//}
//
//float TWBinauralSynth::getAmplitude()
//{
//    return _oscillators[0].getAmplitude();
//}
//
//float TWBinauralSynth::getDutyCycle()
//{
//    return _oscillators[0].getDutyCycle();
//}
//
//float TWBinauralSynth::getPhaseOffset(int channel)
//{
//    if ((channel >= 0) && (channel < kNumberChannels)) {
//        return _oscillators[channel].getPhaseOfst();
//    } else {
//        return 0.0f;
//    }
//}
//
//float TWBinauralSynth::getMononess()
//{
//    return _mononess.getTargetValue();
//}
//
//float TWBinauralSynth::getSoftClipp()
//{
//    return _oscillators[0].getSoftClipp();
//}
//
//
//TWOscillator::TWWaveform TWBinauralSynth::getFMWaveform()
//{
//    return _fmOsc.getWaveform();
//}
//
//float TWBinauralSynth::getFMAmount()
//{
//    return _fmOsc.getAmplitude();
//}
//
//float TWBinauralSynth::getFMFrequency()
//{
//    return _fmOsc.getFrequency();
//}





//===============================================================================================
// Private
//===============================================================================================

void TWBinauralSynth::_setIsRunning(bool isRunning)
{
//    _beatFrequency.setIsRunning(isRunning);
//    _baseFrequency.setIsRunning(isRunning);
    _mononess.setIsIORunning(isRunning);
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

    _oscillators[0].setParameterValue(TWOscillator::ParameterID::Frequency, leftFrequency, rampTime_ms);
    _oscillators[1].setParameterValue(TWOscillator::ParameterID::Frequency, rightFrequency, rampTime_ms);
}


void TWBinauralSynth::setDebugID(int debugID)
{
    _oscillators[0].setDebugID(debugID);
}

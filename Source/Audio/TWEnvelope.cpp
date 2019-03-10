//
//  TWEnvelope.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/6/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWEnvelope.h"
#include "TWHeader.h"


TWEnvelope::TWEnvelope()
{
    _sampleRate = kDefaultSampleRate;
    _sampleCount = 0;
    _envelopeRunning = false;
    _ampEnvelopeGain.setTargetValue(0.0f, 0.0f);
    
    _enabled = false;
    _enableCrossfade.setTargetValue(0.0f, 0.0f);
    _enableCrossfade.setParameterID(99);
    
    _ampAttackTime_ms = kDefaultEnvAttackTime_ms;
    _ampSustainTime_ms = kDefaultEnvSustainTime_ms;
    _ampReleaseTime_ms = kDefaultEnvReleaseTime_ms;
    
    _audioIORunning = false;
    
    _filter = new TWBinauralBiquad();
    _fltFromCutoff = 100.0f;
    _fltToCutoff = 2000.0f;
    _fltAttackTime_ms = kDefaultFltAttackTime_ms;
    _fltSustainTime_ms = kDefaultFltSustainTime_ms;
    _fltReleaseTime_ms = kDefaultFltReleaseTime_ms;
    
    _updateAmpParams();
    _updateFltParams();
}

TWEnvelope::~TWEnvelope()
{
    delete _filter;
}


void TWEnvelope::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    _filter->prepare(sampleRate);
    _sampleCount = 0;
    _envelopeRunning = false;
    _ampEnvelopeGain.setTargetValue(0.0f, 0.0f);
    _ampEnvelopeGain.setIsRunning(true);
    _enableCrossfade.setIsRunning(true);
    _updateAmpParams();
    _updateFltParams();
    _audioIORunning = true;
}

void TWEnvelope::process(float& leftSample, float& rightSample)
{
    float inLeftSample = leftSample;
    float inRightSample = rightSample;
    
    if (_envelopeRunning) {
        if (_sampleCount == 0) {
            _ampEnvelopeGain.setTargetValue(1.0, _ampAttackTime_samples);
        } else if (_sampleCount == _ampReleaseStartSampleTime) {
            _ampEnvelopeGain.setTargetValue(0.0f, _ampReleaseTime_samples);
        }
        
        if (_sampleCount == 0) {
            _filter->setCutoffFrequencyInSamples(_fltToCutoff, _fltAttackTime_samples);
        } else if (_sampleCount == _fltReleaseStartSampleTime) {
            _filter->setCutoffFrequencyInSamples(_fltFromCutoff, _fltReleaseTime_samples);
        }
        
        if (_sampleCount == _ampReleaseEndSampleTime) {
            _envelopeRunning = false;
            _sampleCount = 0;
        }
        _sampleCount++;
    }
    
    float gain = _ampEnvelopeGain.getCurrentValue();
    float outLeftSample  = gain * inLeftSample;
    float outRightSample = gain * inRightSample;
    
    _filter->process(outLeftSample, outRightSample);
    
    float crossfade = _enableCrossfade.getCurrentValue();
    leftSample   = (crossfade * outLeftSample)  + ((1.0f - crossfade) * inLeftSample);
    rightSample  = (crossfade * outRightSample) + ((1.0f - crossfade) * inRightSample);
}

void TWEnvelope::release()
{
    _audioIORunning = false;
    _filter->release();
}



void TWEnvelope::start()
{
    _sampleCount = 0;
    _filter->setCutoffFrequency(_fltFromCutoff, 0.0);
    _envelopeRunning = true;
}


#pragma mark - Parameters

void TWEnvelope::setAmpAttackTime_ms(float attackTime_ms)
{
    _ampAttackTime_ms = attackTime_ms;
    _updateAmpParams();
}
float TWEnvelope::getAmpAttackTime_ms()
{
    return _ampAttackTime_ms;
}

void TWEnvelope::setAmpSustainTime_ms(float sustainTime_ms)
{
    _ampSustainTime_ms = sustainTime_ms;
    _updateAmpParams();
}
float TWEnvelope::getAmpSustainTime_ms()
{
    return _ampSustainTime_ms;
}

void TWEnvelope::setAmpReleaseTime_ms(float releaseTime_ms)
{
    _ampReleaseTime_ms = releaseTime_ms;
    _updateAmpParams();
}
float TWEnvelope::getAmpReleaseTime_ms()
{
    return _ampReleaseTime_ms;
}



void TWEnvelope::setFltEnabled(bool enabled)
{
    _filter->setEnabled(enabled);
}
bool TWEnvelope::getFltEnabled()
{
    return _filter->getEnabled();
}

void TWEnvelope::setFltAttackTime_ms(float attackTime_ms)
{
    _fltAttackTime_ms = attackTime_ms;
    _updateFltParams();
}
float TWEnvelope::getFltAttackTime_ms()
{
    return _fltAttackTime_ms;
}

void TWEnvelope::setFltSustainTime_ms(float sustainTime_ms)
{
    _fltSustainTime_ms = sustainTime_ms;
    _updateFltParams();
}
float TWEnvelope::getFltSustainTime_ms()
{
    return _fltSustainTime_ms;
}

void TWEnvelope::setFltReleaseTime_ms(float releaseTime_ms)
{
    _fltReleaseTime_ms = releaseTime_ms;
    _updateFltParams();
}
float TWEnvelope::getFltReleaseTime_ms()
{
    return _fltReleaseTime_ms;
}

void TWEnvelope::setFltType(TWBiquad::TWFilterType type)
{
    _filter->setFilterType(type);
}
TWBiquad::TWFilterType TWEnvelope::getFltType()
{
    return _filter->getFilterType();
}

void TWEnvelope::setFltFromCutoff(float fromCutoff)
{
    _fltFromCutoff = fromCutoff;
}
float TWEnvelope::getFltFromCutoff()
{
    return _fltFromCutoff;
}

void TWEnvelope::setFltToCutoff(float toCutoff)
{
    _fltToCutoff = toCutoff;
}
float TWEnvelope::getFltToCutoff()
{
    return _fltToCutoff;
}

void TWEnvelope::setFltResonance(float resonance, float rampTime_ms)
{
    _filter->setResonance(resonance, rampTime_ms);
}
float TWEnvelope::getFltResonance()
{
    return _filter->getResonance();
}



void TWEnvelope::setEnabled(bool enable)
{
    _enabled = enable;
    float rampTime = _audioIORunning ? (kSeqEnableCrossfadeTime_ms * _sampleRate / 1000.0f) : 0.0;
    _enableCrossfade.setTargetValue(enable, rampTime);
}
bool TWEnvelope::getEnabled()
{
    return _enabled;
}



#pragma mark - Private

void TWEnvelope::_updateAmpParams()
{
    _ampAttackTime_samples = _ampAttackTime_ms * _sampleRate / 1000.0f;
    _ampSustainTime_samples = _ampSustainTime_ms * _sampleRate / 1000.0f;
    _ampReleaseTime_samples = _ampReleaseTime_ms * _sampleRate / 1000.0f;
    
    _ampReleaseStartSampleTime = _ampAttackTime_samples + _ampSustainTime_samples;
    _ampReleaseEndSampleTime = _ampReleaseStartSampleTime + _ampReleaseTime_samples;
}

void TWEnvelope::_updateFltParams()
{
    _fltAttackTime_samples = _fltAttackTime_ms * _sampleRate / 1000.0f;
    _fltSustainTime_samples = _fltSustainTime_ms * _sampleRate / 1000.0f;
    _fltReleaseTime_samples = _fltReleaseTime_ms * _sampleRate / 1000.0f;
    
    _fltReleaseStartSampleTime = _fltAttackTime_samples + _fltSustainTime_samples;
    _fltReleaseEndSampleTime = _fltReleaseStartSampleTime + _fltReleaseTime_samples;
}

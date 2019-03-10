//
//  TWEnvelope.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/6/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWEnvelope_h
#define TWEnvelope_h

#include <stdio.h>
#include <stdint.h>
#include "TWParameter.h"
#include "TWHeader.h"
#include "TWBinauralBiquad.h"

class TWEnvelope {
    
public:
    
    TWEnvelope();
    ~TWEnvelope();
    
    
    void prepare(float sampleRate);
    void process(float& leftSample, float& rightSample);
    void release();
    
    
    void setEnabled(bool enabled);
    bool getEnabled();
    
    
    void start();
    
    
    void setAmpAttackTime_ms(float attackTime_ms);
    float getAmpAttackTime_ms();
    
    void setAmpSustainTime_ms(float sustainTime_ms);
    float getAmpSustainTime_ms();
    
    void setAmpReleaseTime_ms(float releaseTime_ms);
    float getAmpReleaseTime_ms();
    
    
    void setFltEnabled(bool enabled);
    bool getFltEnabled();
    
    void setFltAttackTime_ms(float attackTime_ms);
    float getFltAttackTime_ms();
    
    void setFltSustainTime_ms(float sustainTime_ms);
    float getFltSustainTime_ms();
    
    void setFltReleaseTime_ms(float releaseTime_ms);
    float getFltReleaseTime_ms();
    
    void setFltType(TWBiquad::TWFilterType type);
    TWBiquad::TWFilterType getFltType();
    
    void setFltFromCutoff(float fromCutoff);
    float getFltFromCutoff();
    
    void setFltToCutoff(float toCutoff);
    float getFltToCutoff();
    
    void setFltResonance(float resonance, float rampTime_ms);
    float getFltResonance();
    
    
private:
    
    float               _sampleRate;
    
    
    float               _ampAttackTime_ms;
    uint64_t            _ampAttackTime_samples;
    
    float               _ampSustainTime_ms;
    uint64_t            _ampSustainTime_samples;
    
    float               _ampReleaseTime_ms;
    uint64_t            _ampReleaseTime_samples;
    
    uint64_t            _ampReleaseStartSampleTime;
    uint64_t            _ampReleaseEndSampleTime;
    
    TWParameter         _ampEnvelopeGain;
    
    
    float               _fltAttackTime_ms;
    uint64_t            _fltAttackTime_samples;
    
    float               _fltSustainTime_ms;
    uint64_t            _fltSustainTime_samples;
    
    float               _fltReleaseTime_ms;
    uint64_t            _fltReleaseTime_samples;
    
    uint64_t            _fltReleaseStartSampleTime;
    uint64_t            _fltReleaseEndSampleTime;
    
    float               _fltFromCutoff;
    float               _fltToCutoff;
    
    TWBinauralBiquad*   _filter;
    
    
    
    bool                _audioIORunning;
    bool                _envelopeRunning;
    uint64_t            _sampleCount;
    
    
    bool                _enabled;
    TWParameter         _enableCrossfade;
    
    
    void                _updateAmpParams();
    void                _updateFltParams();
    
};
#endif /* TWEnvelope_h */

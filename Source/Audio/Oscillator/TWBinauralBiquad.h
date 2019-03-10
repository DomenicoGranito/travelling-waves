//
//  TWBinauralBiquad.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/19/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWBinauralBiquad_h
#define TWBinauralBiquad_h

#include <stdio.h>
#include "TWBiquad.h"

class TWBinauralBiquad {
    
public:
    
    TWBinauralBiquad();
    ~TWBinauralBiquad();
    
    void prepare(float sampleRate);
    void process(float& leftSample, float& rightSample);
    void release();
    
    void setEnabled(bool enabled);
    void setFilterType(TWBiquad::TWFilterType type);
    void setCutoffFrequency(float newFc, float rampTime_ms);
    void setCutoffFrequencyInSamples(float newFc, float rampTimeSamples);
    void setResonance(float newQ, float rampTime_ms);
    void setGain(float newGain, float rampTime_ms);
    
    bool getEnabled();
    TWBiquad::TWFilterType getFilterType();
    float getCutoffFrequency();
    float getResonance();
    float getGain();
    
    
    void setLFOEnabled(bool enabled);
    void setLFOFrequency(float newFc, float rampTime_ms);
    void setLFORange(float newRange, float rampTime_ms);
    void setLFOOffset(float lfoOffset, float rampTime_ms);
    void resetLFOPhase(float rampTimeInSamples);
    
    bool getLFOEnabled();
    float getLFOFrequency();
    float getLFORange();
    float getLFOOffset();
    
    
private:
    
    float           _sampleRate;
    TWBiquad        _biquads[2];
};

#endif /* TWBinauralBiquad_h */

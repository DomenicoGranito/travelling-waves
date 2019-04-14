//
//  TWBiquad.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/24/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWBiquad_h
#define TWBiquad_h

#include <stdio.h>
#include "TWParameter.h"
#include "TWOscillator.h"

class TWBiquad {
    
public:
    
    TWBiquad();
    ~TWBiquad();
    
    enum TWFilterType {
        Lowpass     = 0,
        Highpass    = 1,
        Bandpass1   = 2,
        Bandpass2   = 3,
        Notch       = 4,
        Allpass     = 5
    };
    
    void prepare(float sampleRate);
    void process(float& sample);
    void release();
    
    void setEnabled(bool enabled);
    void setFilterType(TWFilterType type);
    void setCutoffFrequency(float newFc, float rampTime_ms);
    void setCutoffFrequencyInSamples(float newFc, float rampTimeSamples);
    void setResonance(float newQ, float rampTime_ms);
    void setGain(float newGain, float rampTime_ms);
    
    bool getEnabled();
    TWFilterType getFilterType();
    float getCutoffFrequency();
    float getResonance();
    float getGain();
    
    
    void setLFOEnabled(bool enabled);
    void setLFOWaveform(TWOscillator::TWWaveform waveform);
    void setLFOFrequency(float newFc, float rampTime_ms);
    void setLFORange(float newRange, float rampTime_ms);
    void setLFOOffset(float lfoOffset, float rampTime_ms);
    void resetLFOPhase(float rampTimeInSamples);
    
    bool getLFOEnabled();
    TWOscillator::TWWaveform getLFOWaveform();
    float getLFOFrequency();
    float getLFORange();
    float getLFOOffset();
    
    
private:
    
    void            _setIsRunning(bool isRunning);
    void            _computeFilterParameters();
    
    void            _setCutoffParameters(float rampTime_ms);
    void            _setCutoffParametersInSamples(float rampTimeSamples);
    
    float           _sampleRate;
    
    bool            _enabled;
    TWFilterType    _filterType;
    TWParameter     _cutoff;
    TWParameter     _resonance;
    TWParameter     _gain;
    
    TWOscillator*   _lfo;
    bool            _lfoEnabled;
    TWParameter     _lfoRange;

    float           _newRange;
    float           _newCutoff;
    
    float           _x[2];
    float           _y[2];
    
    float           _a[3];
    float           _b[3];
    
    int             _debug;
    
};
#endif /* TWBiquad_h */

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
#include <map>

#include "TWParameter.h"
#include "TWOscillator.h"

class TWBiquad {
    
public:
    
    TWBiquad();
    ~TWBiquad();
    
    typedef enum {
        Lowpass                 = 0,
        Highpass                = 1,
        Bandpass1               = 2,
        Bandpass2               = 3,
        Notch                   = 4,
        Allpass                 = 5,
        NumFilters              = 6
    } TWFilterType;
    
    enum ParameterID {
        FilterEnable            = 1,
        FilterType              = 2,
        FilterCutoffFrequency   = 3,
        FilterResonance         = 4,
        FilterGain              = 5,
        FilterLFOEnable         = 6,
        FilterLFOWaveform       = 7,
        FilterLFOFrequency      = 8,
        FilterLFORange          = 9,
        FilterLFOPhaseOffset    = 10,
    };
    
    
    void prepare(float sampleRate);
    void process(float& sample);
    void release();
    
    void setParameterValue(int parameterID, float value, float rampTime_ms);
    void setParameterDefaultValue(int parameterID, float rampTime_ms);
    float getParameterValue(int parameterID);
    float getParameterMinValue(int parameterID);
    float getParameterMaxValue(int parameterID);
    float getParameterDefaultValue(int parameterID);
    
//    void setEnabled(bool enabled);
//    void setFilterType(TWFilterType type);
//    void setCutoffFrequencyInSamples(float newFc, float rampTimeSamples);
//    void setResonance(float newQ, float rampTime_ms);
//    void setGain(float newGain, float rampTime_ms);
//
//    bool getEnabled();
//    TWFilterType getFilterType();
//    float getCutoffFrequency();
//    float getResonance();
//    float getGain();
    
    
//    void setLFOEnabled(bool enabled);
//    void setLFOWaveform(TWOscillator::WaveformType waveform);
//    void setLFOFrequency(float newFc, float rampTime_ms);
//    void setLFORange(float newRange, float rampTime_ms);
//    void setLFOOffset(float lfoOffset, float rampTime_ms);
    
    void resetLFOPhase(float rampTimeInSamples);
    
//    bool getLFOEnabled();
//    TWOscillator::TWWaveform getLFOWaveform();
//    float getLFOFrequency();
//    float getLFORange();
//    float getLFOOffset();
    
    
private:
    
    void            _setIsRunning(bool isRunning);
    void            _computeFilterParameters();
    
    void            _setCutoffParameters(float rampTime_ms);
    void            _setCutoffParametersInSamples(float rampTimeSamples);
    
    void            _setCutoffFrequency(float newFc, float rampTime_ms);
    void            _setResonance(float newQ, float rampTime_ms);
    
    float                           _sampleRate;
    
    std::map<int, TWParameter*>     _parameters;
    
//    bool            _enabled;
//    TWFilterType    _filterType;
//    TWParameter     _cutoff;
//    TWParameter     _resonance;
//    TWParameter     _gain;
    
    TWOscillator*   _lfo;
    bool            _lfoEnabled;
//    TWParameter     _lfoRange;

    float           _newRange;
    float           _newCutoff;
    
    float           _x[2];
    float           _y[2];
    
    float           _a[3];
    float           _b[3];
    
    int             _debug;
    
    TWParameter*    _parameterForID(int parameterID);
    
};
#endif /* TWBiquad_h */

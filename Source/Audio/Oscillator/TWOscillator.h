//
//  TWOscillator.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWOscillator_h
#define TWOscillator_h

#include <stdio.h>
#include "TWParameter.h"

class TWOscillator {
    
public:
    
    TWOscillator();
    ~TWOscillator();
    
    enum TWWaveform {
        Sine        = 0,
        Sawtooth    = 1,
        Square      = 2,
        Noise       = 3
    };
    
    void prepare(float sampleRate);
    float getSample();
    void release();
    
    void setWaveform(TWWaveform type);
    void setFrequency(float newFrequency, float rampTime_ms);
    void setAmplitude(float newAmplitude, float rampTime_ms);
    void setDutyCycle(float newDutyCycle, float rampTime_ms);
    void setPhaseOfst(float newPhaseOfst, float rampTime_ms);
    void resetPhase(float rampTimeInSamples);
    
    TWWaveform getWaveform();
    float getFrequency();
    float getAmplitude();
    float getDutyCycle();
    float getPhaseOfst();
    
private:
    
    float           _sampleRate;
    
    TWParameter     _frequency;
    TWParameter     _amplitude;
    TWParameter     _dutyCycle;
    TWParameter     _phaseOffset;
    TWWaveform      _waveform;
    
    float           _getPhase();
    float           _phase;
    float           _phaseIncrement;
    
    bool            _isResettingPhase;
    float           _phaseResetIncrement;
    
    void            _setIsRunning(bool isRunning);
    
    int             _debug;
};

#endif /* TWOscillator_h */

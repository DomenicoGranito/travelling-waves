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
#include <map>
#include "TWParameter.h"

class TWOscillator {
    
public:
    
    TWOscillator();
    ~TWOscillator();
    
    typedef enum {
        Sine            = 0,
        Sawtooth        = 1,
        Square          = 2,
        Noise           = 3,
        Random          = 4,
        NumWaveforms    = 5
    } TWWaveform;
    
    enum ParameterID {
        WaveformType    = 1,
        Frequency       = 2,
        AmplitudeDB     = 3,
        DutyCycle       = 4,
        SoftClipp       = 5,
        PhaseOffset     = 6
    };
    
    
    void prepare(float sampleRate);
    float getSample();
    void release();
    
    void setParameterValue(int parameterID, float value, float rampTime_ms);
    void setParameterDefaultValue(int parameterID, float rampTime_ms);
    float getParameterValue(int parameterID);
    float getParameterMinValue(int parameterID);
    float getParameterMaxValue(int parameterID);
    float getParameterDefaultValue(int parameterID);
    
//    void setWaveform(WaveformType type);
//    void setFrequency(float newFrequency, float rampTime_ms);
//    void setAmplitude(float newAmplitude, float rampTime_ms);
//    void setDutyCycle(float newDutyCycle, float rampTime_ms);
//    void setSoftClipp(float newSoftClipp, float rampTime_ms);
//    void setPhaseOfst(float newPhaseOfst, float rampTime_ms);
    
    void resetPhase(float rampTimeInSamples);
    
    
//    void shouldApplyShape(bool applyShape);
    
//    WaveformType getWaveform();
//    float getFrequency();
//    float getAmplitude();
//    float getDutyCycle();
//    float getSoftClipp();
//    float getPhaseOfst();
    
//    bool willApplyShape();
    
    void setDebugID(int debugID);
    
private:
    
    float                           _sampleRate;
    
    std::map<int, TWParameter*>     _parameters;
    
//    TWParameter     _frequency;
//    TWParameter     _amplitude;
//    TWParameter     _dutyCycle;
//    TWParameter     _softClipp;
//    TWParameter     _phaseOffset;
//    WaveformType    _waveform;
    
    float                           _getPhase();
    float                           _phase;
    float                           _phaseIncrement;
    
    bool                            _isResettingPhase;
    float                           _phaseResetIncrement;
    
    float                           _currentRandomSample;
    bool                            _didCyclePhase;
    long long                       _debugSampleCount;
    
//    bool                          _shouldApplyShape;
    
    TWParameter*                    _parameterForID(int parameterID);
    
    void                            _setIsRunning(bool isRunning);
    
    long                            _debugCount;
    int                             _debugID;
};

#endif /* TWOscillator_h */

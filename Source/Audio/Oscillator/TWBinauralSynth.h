//
//  BinauralSynth.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/17/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWBinauralSynth_h
#define TWBinauralSynth_h

#include <stdio.h>
#include "TWOscillator.h"
#include "TWParameter.h"

#define kNumberChannels    2

class TWBinauralSynth {
    
public:
    
    enum ParameterID {
        WaveformType    = 1,
        BaseFrequency   = 2,
        BeatFrequency   = 3,
        AmplitudeDB     = 4,
        DutyCycle       = 5,
        SoftClipp       = 6,
        PhaseOffset     = 7,
        Mononess        = 8,
        FMWaveform      = 9,
        FMAmount        = 10,
        FMFrequency     = 11
    };
    
    TWBinauralSynth();
    ~TWBinauralSynth();
    
    void prepare(float sampleRate);
    void getSample(float& leftSample, float& rightSample);
    void release();
    
    void setParameterValue(int parameterID, float value, float rampTime_ms);
    float getParameterValue(int parameterID);
    float getParameterMinValue(int parameterID);
    float getParameterMaxValue(int parameterID);
    
    
//    void setWaveform(TWOscillator::TWWaveform type);
//    void setBaseFrequency(float baseFrequency, float rampTime_ms);
//    void setBeatFrequency(float beatFrequency, float rampTime_ms);
//    void setAmplitude(float amplitude, float rampTime_ms);
//    void setDutyCycle(float dutyCycle, float rampTime_ms);
//    void setPhaseOffset(int channel, float phaseOffset, float rampTime_ms);
//    void setMononess(float mononess, float rampTime_ms);
//    void setSoftClipp(float softClipp, float rampTime_ms);
    
//    void setFMWaveform(TWOscillator::TWWaveform type);
//    void setFMAmount(float fmAmount, float rampTime_ms);
//    void setFMFrequency(float fmFrequency, float rampTime_ms);
    
    void resetPhase(float rampTimeInSamples);
    
    
//    TWOscillator::TWWaveform getWaveform();
//    float getBaseFrequency();
//    float getBeatFrequency();
//    float getAmplitude();
//    float getDutyCycle();
//    float getPhaseOffset(int channel);
//    float getMononess();
//    float getSoftClipp();
    
//    TWOscillator::TWWaveform getFMWaveform();
//    float getFMAmount();
//    float getFMFrequency();
    
    void setDebugID(int debugID);
    
    
private:
    
    float                           _sampleRate;
    
    std::map<int, TWParameter*>     _parameters;
    
    TWOscillator                    _oscillators[kNumberChannels];
    TWOscillator                    _fmOsc;
    
    float                           _baseFrequency;
    float                           _beatFrequency;
    
//    TWParameter     _baseFrequency;
//    TWParameter     _beatFrequency;
    TWParameter                     _mononess;
    
    
    void                            _calculateFrequencies(float rampTime_ms);
    
    void                            _setIsRunning(bool isRunning);
//    void                            _setFrequencies();
};

#endif /* TWBinauralSynth_h */

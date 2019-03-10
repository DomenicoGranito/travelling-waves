//
//  TWMixer.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/24/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWMixer_h
#define TWMixer_h

#include <stdio.h>
#include <vector>
#include <array>

#include "TWBinauralSynth.h"
#include "TWOscillator.h"
#include "TWBinauralBiquad.h"
#include "TWTremolo.h"
//#include "TWDelay.h"
#include "TWParameter.h"
#include "TWHeader.h"
#include "TWSequencer.h"


class TWMixer {
    
public:
    
    
    TWMixer();
    ~TWMixer();
    
    
    
    //--- Audio IO ---//
    void prepare(float sampleRate);
    void process(float* leftBuffer, float* rightBuffer, int frameCount);
    void release();
    
    
    
    //--- Master ---//
    void setMasterLeftGain(float gain, float rampTime_ms);
    void setMasterRightGain(float gain, float rampTime_ms);
    
    float getMasterLeftGain();
    float getMasterRightGain();
    
    void resetOscPhase(float rampTimeInSamples);
    void setRampTimeAtSourceIdx(int idx, float rampTime_ms);
    float getRampTimeAtSourceIdx(int idx);
    
    
    
    //--- Oscillator ---//
    void setBinauralWaveform(int idx, TWOscillator::TWWaveform type);
    void setBinauralBaseFrequency(int idx, float frequency, float rampTime_ms);
    void setBinauralBeatFrequency(int idx, float frequency, float rampTime_ms);
    void setBinauralAmplitude(int idx, float amplitude, float rampTime_ms);
    void setBinauralDutyCycle(int idx, float dutyCycle, float rampTime_ms);
    void setBinauralMononess(int idx, float mononess, float rampTime_ms);
    void setBinauralSolo(int idx, bool solo);
    
    TWOscillator::TWWaveform getBinauralWaveform(int idx);
    float getBinauralBaseFrequency(int idx);
    float getBinauralBeatFrequency(int idx);
    float getBinauralAmplitude(int idx);
    float getBinauralDutyCycle(int idx);
    float getBinauralMononess(int idx);
    bool getBinauralSolo(int idx);
    
    
    
    //--- Tremolo ---//
    void setTremoloFrequency(int idx, float frequency, float rampTime_ms);
    void setTremoloDepth(int idx, float depth, float rampTime_ms);
    
    float getTremoloFrequency(int idx);
    float getTremoloDepth(int idx);
    
    
    
    //--- Filter ---//
    void setFilterType(int idx, TWBiquad::TWFilterType type);
    void setFilterCutoff(int idx, float cutoff, float rampTime_ms);
    void setFilterResonance(int idx, float resonance, float rampTime_ms);
    void setFilterGain(int idx, float gain, float rampTime_ms);
    void setFilterEnabled(int idx, bool enabled);
    
    bool getFilterEnabled(int idx);
    TWBiquad::TWFilterType getFilterType(int idx);
    float getFilterCutoff(int idx);
    float getFilterResonance(int idx);
    float getFilterGain(int idx);
    
    
    void setLFOEnabled(int idx, bool enabled);
    void setLFOFrequency(int idx, float newFc, float rampTime_ms);
    void setLFORange(int idx, float newRange, float rampTime_ms);
    void setLFOOffset(int idx, float offset, float rampTime_ms);
    
    bool getLFOEnabled(int idx);
    float getLFOFrequency(int idx);
    float getLFORange(int idx);
    float getLFOOffset(int idx);
    
    
    
    //--- Delay ---//
    void setDelayTime_ms(int idx, float delayTime_ms, float rampTime_ms);
    void setDelayFeedback(int idx, float feedback, float rampTime_ms);
    void setDelayDryWetRatio(int idx, float dryWetRatio, float rampTime_ms);
    
    
    
    //--- Sequencer ---//
    void setSeqDuration_ms(float duration_ms);
    void setSeqEnabledAtSourceIdx(int sourceIdx, bool enabled);
    void setSeqIntervalAtSourceIdx(int sourceIdx, int interval);
    void setSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat, int note);

    float getSeqDuration_ms();
    float getSeqNormalizedTick();
    bool getSeqEnabledAtSourceIdx(int sourceIdx);
    int getSeqIntervalAtSourceIdx(int sourceIdx);
    int getSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat);

    
    void setSeqAmpAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms);
    void setSeqAmpSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms);
    void setSeqAmpReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms);
    
    float getSeqAmpAttackTimeAtSourceIdx(int sourceIdx);
    float getSeqAmpSustainTimeAtSourceIdx(int sourceIdx);
    float getSeqAmpReleaseTimeAtSourceIdx(int sourceIdx);
    
    
    void setSeqFltEnabledAtSourceIdx(int sourceIdx, bool enabled);
    void setSeqFltAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms);
    void setSeqFltSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms);
    void setSeqFltReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms);
    void setSeqFltTypeAtSourceIdx(int sourceIdx, TWBiquad::TWFilterType type);
    void setSeqFltFromCutoffAtSourceIdx(int sourceIdx, float fromCutoff);
    void setSeqFltToCutoffAtSourceIdx(int sourceIdx, float toCutoff);
    void setSeqFltResonanceAtSourceIdx(int sourceIdx, float resonance, float rampTime_ms);
    
    bool getSeqFltEnabledAtSourceIdx(int sourceIdx);
    float getSeqFltAttackTimeAtSourceIdx(int sourceIdx);
    float getSeqFltSustainTimeAtSourceIdx(int sourceIdx);
    float getSeqFltReleaseTimeAtSourceIdx(int sourceIdx);
    TWBiquad::TWFilterType getSeqFltTypeAtSourceIdx(int sourceIdx);
    float getSeqFltFromCutoffAtSourceIdx(int sourceIdx);
    float getSeqFltToCutoffAtSourceIdx(int sourceIdx);
    float getSeqFltResonanceAtSourceIdx(int sourceIdx);
    
    
private:
    
    float                                       _sampleRate;
    
    std::array<TWFrame, kNumSources>            _sourceBuffers;
    
    std::array<TWBinauralSynth, kNumSources>    _synths;
    std::array<TWBinauralBiquad, kNumSources>   _biquads;
    std::array<TWTremolo, kNumSources>          _tremolos;
    
    std::array<float, kNumSources>              _rampTimes;
    
    
    std::array<bool, kNumSources>               _solos;
    int                                         _soloCount;
    std::array<TWParameter, kNumSources>        _soloGains;
    
    
    TWParameter                                 _leftGain;
    TWParameter                                 _rightGain;
    
    
    TWSequencer*                                _sequencer;
    
    
    void log(const char * format, ...);
};

#endif /* TWMixer_h */

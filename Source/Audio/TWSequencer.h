//
//  TWSequencer.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/5/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWSequencer_h
#define TWSequencer_h

#include <stdio.h>
#include <stdint.h>
#include <array>
#include <vector>
#include "TWHeader.h"
#include "TWEnvelope.h"

class TWSequencer {
    
public:
    
    TWSequencer();
    ~TWSequencer();
    
    
    struct TWEvent {
        uint64_t    sampleStartTime;
        int         interval;
        int         beat;
        int         sourceIdx;
    };
    
    
    void prepare(float sampleRate);
    void process(TWFrame* allFrames);
    void release();
    
    
    void setDuration_ms(float duration_ms);
    float getDuration_ms();
    
    
    float getNormalizedTick();
    
    
    void setEnabledAtSourceIdx(int sourceIdx, bool enabled);
    bool getEnabledAtSourceIdx(int sourceIdx);
    
    void setIntervalAtSourceIdx(int sourceIdx, int interval);
    int getIntervalAtSourceIdx(int sourceIdx);
    
    void setNoteForBeatAtSourceIdx(int sourceIdx, int beat, int note);
    int getNoteForBeatAtSourceIdx(int sourceIdx, int beat);
    
    
    
    void setAmpAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms);
    float getAmpAttackTimeAtSourceIdx(int sourceIdx);
    
    void setAmpSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms);
    float getAmpSustainTimeAtSourceIdx(int sourceIdx);
    
    void setAmpReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms);
    float getAmpReleaseTimeAtSourceIdx(int sourceIdx);
    
    
    void setFltEnabledAtSourceIdx(int sourceIdx, bool enabled);
    bool getFltEnabledAtSourceIdx(int sourceIdx);
    
    void setFltAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms);
    float getFltAttackTimeAtSourceIdx(int sourceIdx);
    
    void setFltSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms);
    float getFltSustainTimeAtSourceIdx(int sourceIdx);
    
    void setFltReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms);
    float getFltReleaseTimeAtSourceIdx(int sourceIdx);
    
    void setFltTypeAtSourceIdx(int sourceIdx, TWBiquad::TWFilterType type);
    TWBiquad::TWFilterType getFltTypeAtSourceIdx(int sourceIdx);
    
    void setFltFromCutoffAtSourceIdx(int sourceIdx, float fromCutoff);
    float getFltFromCutoffAtSourceIdx(int sourceIdx);
    
    void setFltToCutoffAtSourceIdx(int sourceIdx, float toCutoff);
    float getFltToCutoffAtSourceIdx(int sourceIdx);
    
    void setFltResonanceAtSourceIdx(int sourceIdx, float resonance, float rampTime_ms);
    float getFltResonanceAtSourceIdx(int sourceIdx);
    
    
    
    
private:
    
    int _arrayIdx(int interval, int idx);
    void _intAndIdxForArrayIdx(int arrayIdx, int& interval, int& idx);
    void _updateTotalDurationSamples();
    uint64_t _sampleTimeForIntervalAndBeat(int interval, int beat);
    
//    std::array<int, (kNumIntervals * (kNumIntervals+1)) / 2>  _sequencer;
    std::array<std::vector<int>, kNumSources>                   _sequencerNotes;
    
    std::array<TWEnvelope, kNumSources>                          _envelopes;
    std::array<int, kNumSources>                                 _intervals;
    std::vector<TWEvent>                                           _events;
    
    
    float       _sampleRate;
    float       _duration_ms;
    
    uint64_t    _durationSamples;
    uint64_t    _sampleCount;
    
    bool        _editingEvents;
    
    
    void _printSeqNotes();
    void _printEvents();
    void _printSeq();
    void _printIntervalNotes();
};

#endif /* TWSequencer_h */

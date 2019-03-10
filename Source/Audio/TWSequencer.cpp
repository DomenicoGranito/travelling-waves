//
//  TWSequencer.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/5/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWSequencer.h"
#include <stdio.h>
#include <math.h>

#define PRINT_SEQUENCER         0
#define PRINT_EVENTS            1
#define PRINT_INTERVAL_NOTES    0
#define PRINT_SEQ_NOTES         0

TWSequencer::TWSequencer()
{
    _sampleRate = kDefaultSampleRate;
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        setIntervalAtSourceIdx(sourceIdx, sourceIdx+1);
    }
    
    _duration_ms = kDefaultSeqDuration_ms;
    _updateTotalDurationSamples();
    _sampleCount = 0;
    _editingEvents = false;
}

TWSequencer::~TWSequencer()
{
    _events.clear();
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        _sequencerNotes[sourceIdx].clear();
    }
}


void TWSequencer::prepare(float sampleRate)
{
    _sampleRate = sampleRate;
    
    _updateTotalDurationSamples();
    _sampleCount = 0;
    
    for (int idx=0; idx < kNumSources; idx++) {
        _envelopes[idx].prepare(sampleRate);
    }
}


void TWSequencer::process(TWFrame* allFrames)
{
    if (!_editingEvents) {
        for (std::vector<TWEvent>::iterator iter = _events.begin(); iter != _events.end(); ++iter) {
            if (_sampleCount == iter->sampleStartTime) {
                _envelopes[iter->sourceIdx].start();
            }
        }
    }
    
    for (int idx=0; idx < kNumSources; idx++) {
        _envelopes[idx].process(allFrames[idx].leftSample, allFrames[idx].rightSample);
    }
    
    _sampleCount = (_sampleCount + 1) % _durationSamples;
}


void TWSequencer::release()
{
    for (int idx=0; idx < kNumSources; idx++) {
        _envelopes[idx].release();
    }
}



#pragma mark - Parameters


void TWSequencer::setDuration_ms(float duration_ms)
{
    if (duration_ms <= 0.0f) {
        duration_ms = 1.0f;
    }
    _duration_ms = duration_ms;
    _updateTotalDurationSamples();
}
float TWSequencer::getDuration_ms()
{
    return _duration_ms;
}

float TWSequencer::getNormalizedTick()
{
    return ((float)_sampleCount / (float)_durationSamples);
}


void TWSequencer::setEnabledAtSourceIdx(int sourceIdx, bool enabled)
{
    _envelopes[sourceIdx].setEnabled(enabled);
}
bool TWSequencer::getEnabledAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getEnabled();
}



void TWSequencer::setIntervalAtSourceIdx(int sourceIdx, int interval)
{
    _intervals[sourceIdx] = interval;
    
    _sequencerNotes[sourceIdx].clear();
    for (int idx=0; idx < interval; idx++) {
        _sequencerNotes[sourceIdx].push_back(0);
    }
    
    _editingEvents = true;
    std::vector<TWEvent>::iterator iter = _events.begin();
    while (iter != _events.end()) {
        if (iter->sourceIdx == sourceIdx) {
            iter = _events.erase(iter);
        } else {
            ++iter;
        }
    }
    _editingEvents = false;
    
    
    _printIntervalNotes();
    _printEvents();
}

int TWSequencer::getIntervalAtSourceIdx(int sourceIdx)
{
    return _intervals[sourceIdx];
}



void TWSequencer::setNoteForBeatAtSourceIdx(int sourceIdx, int beat, int note)
{
    _sequencerNotes[sourceIdx][beat] = note;
    _printSeqNotes();
    
    _editingEvents = true;
    if (note == 0) {
        std::vector<TWEvent>::iterator iter = _events.begin();
        while (iter != _events.end()) {
            if ((iter->sourceIdx == sourceIdx) && (iter->beat == beat)) {
                iter = _events.erase(iter);
                break;
            } else {
                ++iter;
            }
        }
    }
    else {
        TWEvent newEvent;
        newEvent.sampleStartTime = _sampleTimeForIntervalAndBeat(_intervals[sourceIdx], beat);
        newEvent.interval        = _intervals[sourceIdx];
        newEvent.beat             = beat;
        newEvent.sourceIdx       = sourceIdx;
        _events.push_back(newEvent);
    }
    _editingEvents = false;
    
    _printEvents();
}

int TWSequencer::getNoteForBeatAtSourceIdx(int sourceIdx, int beat)
{
    return _sequencerNotes[sourceIdx][beat];
}




void TWSequencer::setAmpAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms)
{
    _envelopes[sourceIdx].setAmpAttackTime_ms(attackTime_ms);
}
float TWSequencer::getAmpAttackTimeAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getAmpAttackTime_ms();
}

void TWSequencer::setAmpSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms)
{
    _envelopes[sourceIdx].setAmpSustainTime_ms(sustainTime_ms);
}
float TWSequencer::getAmpSustainTimeAtSourceIdx(int sourceIdx)
{
    return  _envelopes[sourceIdx].getAmpSustainTime_ms();
}

void TWSequencer::setAmpReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms)
{
    _envelopes[sourceIdx].setAmpReleaseTime_ms(releaseTime_ms);
}
float TWSequencer::getAmpReleaseTimeAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getAmpReleaseTime_ms();
}


void TWSequencer::setFltEnabledAtSourceIdx(int sourceIdx, bool enabled)
{
    _envelopes[sourceIdx].setFltEnabled(enabled);
}
bool TWSequencer::getFltEnabledAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltEnabled();
}

void TWSequencer::setFltAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms)
{
    _envelopes[sourceIdx].setFltAttackTime_ms(attackTime_ms);
}
float TWSequencer::getFltAttackTimeAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltAttackTime_ms();
}

void TWSequencer::setFltSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms)
{
    _envelopes[sourceIdx].setFltSustainTime_ms(sustainTime_ms);
}
float TWSequencer::getFltSustainTimeAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltSustainTime_ms();
}

void TWSequencer::setFltReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms)
{
    _envelopes[sourceIdx].setFltReleaseTime_ms(releaseTime_ms);
}
float TWSequencer::getFltReleaseTimeAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltReleaseTime_ms();
}

void TWSequencer::setFltTypeAtSourceIdx(int sourceIdx, TWBiquad::TWFilterType type)
{
    _envelopes[sourceIdx].setFltType(type);
}
TWBiquad::TWFilterType TWSequencer::getFltTypeAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltType();
}

void TWSequencer::setFltFromCutoffAtSourceIdx(int sourceIdx, float fromCutoff)
{
    _envelopes[sourceIdx].setFltFromCutoff(fromCutoff);
}
float TWSequencer::getFltFromCutoffAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltFromCutoff();
}

void TWSequencer::setFltToCutoffAtSourceIdx(int sourceIdx, float toCutoff)
{
    _envelopes[sourceIdx].setFltToCutoff(toCutoff);
}
float TWSequencer::getFltToCutoffAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltToCutoff();
}

void TWSequencer::setFltResonanceAtSourceIdx(int sourceIdx, float resonance, float rampTime_ms)
{
    _envelopes[sourceIdx].setFltResonance(resonance, rampTime_ms);
}
float TWSequencer::getFltResonanceAtSourceIdx(int sourceIdx)
{
    return _envelopes[sourceIdx].getFltResonance();
}



#pragma mark - Private

int TWSequencer::_arrayIdx(int interval, int idx)
{
    return ((interval * (interval+1)) / 2) + idx;
}

void TWSequencer::_updateTotalDurationSamples()
{
    _durationSamples = _duration_ms * _sampleRate / 1000.0f;
    for (std::vector<TWEvent>::iterator iter = _events.begin(); iter != _events.end(); ++iter) {
        iter->sampleStartTime = _sampleTimeForIntervalAndBeat(iter->interval, iter->beat);
    }
}

uint64_t TWSequencer::_sampleTimeForIntervalAndBeat(int interval, int beat)
{
    return (beat * _duration_ms / interval) * _sampleRate / 1000.0f;
}


void TWSequencer::_intAndIdxForArrayIdx(int arrayIdx, int& interval, int& idx)
{
//    float x1 =
}


void TWSequencer::_printSeq()
{
#if PRINT_SEQUENCER
    printf("\nSequencer:\n");
    int arrayIdx = 0;
    for (int interval=0; interval < kNumIntervals; interval++) {
        printf("%d:\t", interval);
        for (int idx=0; idx <= interval; idx++) {
            printf("%d\t", _sequencer[arrayIdx]);
            arrayIdx++;
        }
        printf("\n");
    }
#endif
}

void TWSequencer::_printIntervalNotes()
{
#if PRINT_INTERVAL_NOTES
    printf("\n\nInterval Notes:\n");
    for (int sourceIdx = 0; sourceIdx < kNumSources; sourceIdx++) {
        printf("%d : %d\n", sourceIdx, _intervals[sourceIdx]);
    }
#endif
}

void TWSequencer::_printSeqNotes()
{
#if PRINT_SEQ_NOTES
    printf("\n\n\nSequencer Notes:\n");
    for (int sourceIdx = 0; sourceIdx < kNumSources; sourceIdx++) {
        printf("%d:\t", sourceIdx);
        for (int beat = 0; beat < _intervals[sourceIdx]; beat++) {
            printf("%d\t", _sequencerNotes[sourceIdx][beat]);
        }
        printf("\n");
    }
#endif
}

void TWSequencer::_printEvents()
{
#if PRINT_EVENTS
    printf("\n\nEvents:\n");
    for (std::vector<TWEvent>::iterator iter = _events.begin(); iter != _events.end(); ++iter) {
        printf("%d, %d, %d, %llu\n", iter->sourceIdx+1, iter->interval, iter->beat, iter->sampleStartTime);
    }
#endif
}

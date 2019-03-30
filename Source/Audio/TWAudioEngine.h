//
//  TWAudioEngine.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWAudioEngine_h
#define TWAudioEngine_h

#include <stdio.h>
#include <vector>
#include <array>
#include <functional>

#include <dispatch/dispatch.h>

#include "TWHeader.h"
#include "TWEnvelope.h"
#include "TWBinauralSynth.h"
#include "TWBinauralBiquad.h"
#include "TWTremolo.h"
#include "TWLevelMeter.h"
#include "TWParameter.h"
#include "TWFileStream.h"

class TWAudioEngine {
    
public:
    
    //============================================================
    // Init, Audio I/O
    //============================================================
    
    TWAudioEngine();
    ~TWAudioEngine();
    
    
    void prepare(float sampleRate);
    void process(float* leftBuffer, float* rightBuffer, int frameCount);
    void release();
    
    
    
    //============================================================
    // Master
    //============================================================
    
    void setMasterGain(int channel, float gain, float rampTime_ms);
    float getMasterGain(int channel);
    
    void resetPhase(float rampTimeInSamples);
    void setRampTimeAtSourceIdx(int sourceIdx, float rampTime_ms);
    float getRampTimeAtSourceIdx(int sourceIdx);
    
    float getRMSLevel(int channel);
    
    
    
    //============================================================
    // Sequencer
    //============================================================
    
    struct TWSeqEvent {
        uint64_t    sampleStartTime;
        int         interval;
        int         beat;
        int         sourceIdx;
    };
    
    void setSeqDuration_ms(float duration_ms);
    float getSeqDuration_ms();
    
    float getSeqNormalizedProgress();
    
    void setSeqEnabledAtSourceIdx(int sourceIdx, bool enabled);
    bool getSeqEnabledAtSourceIdx(int sourceIdx);
    
    void setSeqIntervalAtSourceIdx(int sourceIdx, int interval);
    int getSeqIntervalAtSourceIdx(int sourceIdx);
    
    void setSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat, int note);
    int getSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat);
    
    void setSeqParameterAtSourceIdx(int sourceIdx, int paramID, float value);
    float getSeqParameterAtSourceIdx(int sourceIdx, int paramID);
    
    
    
    //============================================================
    // Oscillators and Effects
    //============================================================
    
    void setOscSoloEnabledAtSourceIdx(int sourceIdx, bool enabled);
    bool getOscSoloEnabledAtSourceIdx(int sourceIdx);
    
    void setOscParameterAtSourceIdx(int sourceIdx, int paramID, float value, float rampTime_ms = 0.0f);
    float getOscParameterAtSourceIdx(int sourceIdx, int paramID);
    
    
    
    //============================================================
    // Drum Pad
    //============================================================
    int loadAudioFileAtSourceIdx(int sourceIdx, std::string filepath);
    void startPlaybackAtSourceIdx(int sourceIdx, uint32_t sampleTime);
    void stopPlaybackAtSourceIdx(int sourceIdx);
    void setPlaybackParameterAtSourceIdx(int sourceIdx, int paramID, float value, float rampTime_ms);
    float getPlaybackParameterAtSourceIdx(int sourceIdx, int paramID);
    void setFinishedPlaybackProc(std::function<void(int)>finishedPlaybackProc);
    
    
private:
    
    float                                           _sampleRate;
    
    std::array<TWFrame, kNumSources>                _sourceBuffers;
    
    std::array<TWParameter, kNumChannels>           _masterGains;
    std::array<TWLevelMeter, kNumChannels>          _levelMeters;
    TWParameter                                     _setupGain;
    
    float                                           _seqDuration_ms;
    uint64_t                                        _seqDurationSamples;
    uint64_t                                        _seqSampleCount;
    bool                                            _seqEditingEvents;
    
    std::array<TWEnvelope, kNumSources>             _seqEnvelopes;
    std::array<int, kNumSources>                    _seqSourceIntervals;
    std::array<std::vector<int>, kNumSources>       _seqNotes;
    std::vector<TWSeqEvent>                         _seqEvents;
    
    
    
    std::array<float, kNumSources>                  _rampTimes;
    
    std::array<bool, kNumSources>                   _solos;
    int                                             _soloCount;
    std::array<TWParameter, kNumSources>            _soloGains;
    
    std::array<TWBinauralSynth, kNumSources>        _synths;
    std::array<TWBinauralBiquad, kNumSources>       _biquads;
    std::array<TWTremolo, kNumSources>              _tremolos;
    
    std::array<TWFileStream, kNumSources>           _fileStreams;
    dispatch_queue_t                                _readQueue;
    dispatch_queue_t                                _notificationQueue;
    
    // Private Seq Methods
    void _seqUpdateTotalDurationSamples();
    uint64_t _seqSampleTimeForIntervalAndBeat(int interval, int beat);
    
    
    // Logging Methods
    void _log(const char * format, ...);
    void _printSeqSourceIntervals();
    void _printSeqNotes();
    void _printSeqEvents();
    
};
#endif /* TWAudioEngine_h */

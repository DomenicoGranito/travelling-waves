//
//  TWAudioEngine.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWAudioEngine.h"


#define PRINT_SEQ_INTERVALS         0
#define PRINT_SEQ_NOTES             0
#define PRINT_SEQ_EVENTS            0
#define DEBUG_PRINT                 0



//============================================================
// Init
//============================================================
#pragma mark - Init, AudioI/O

TWAudioEngine::TWAudioEngine()
{
    _sampleRate = kDefaultSampleRate;
    _notificationQueue = dispatch_queue_create("Notification Queue", NULL);
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        
        _sourceBuffers[sourceIdx].leftSample  = 0.0f;
        _sourceBuffers[sourceIdx].rightSample = 0.0f;
        
        setSeqIntervalAtSourceIdx(sourceIdx, sourceIdx+1);
        
        _rampTimes[sourceIdx] = kDefaultRampTime_ms;
        
        _solos[sourceIdx] = false;
        _soloGains[sourceIdx].setTargetValue(1.0f, 0.0f);
        
        _memoryPlayers[sourceIdx].setNotificationQueue(_notificationQueue);
        _memoryPlayers[sourceIdx].setSourceIdx(sourceIdx);
    }
    
    
    for (int channel=0; channel < kNumChannels; channel++) {
        _masterGains[channel].setTargetValue(1.0f, 0.0f);
    }
    
    _seqDuration_ms = kDefaultSeqDuration_ms;
    _seqUpdateTotalDurationSamples();
    _seqSampleCount = 0;
    _seqEditingEvents = false;
    
    _soloCount = 0;
    
    _setupGain.setTargetValue(1.0f, 0.0f);
    _setupGain.setIsRunning(true);
    
    _synths[0].setDebugID(1);
    _tremolos[0].setDebugID(1);
    _shapeTremolos[0].setDebugID(2);
}

TWAudioEngine::~TWAudioEngine()
{
    _seqEvents.clear();
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        _seqNotes[sourceIdx].clear();
    }
    
    dispatch_release(_notificationQueue);
    _notificationQueue = nullptr;
}



//============================================================
// Audio I/O
//============================================================

void TWAudioEngine::prepare(float sampleRate)
{
    _setupGain.setTargetValue(0.0f, 0.0f);
    
    _sampleRate = sampleRate;
    
    _seqUpdateTotalDurationSamples();
    _seqSampleCount = 0;
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        _sourceBuffers[sourceIdx].leftSample  = 0.0f;
        _sourceBuffers[sourceIdx].rightSample = 0.0f;
        
        _seqEnvelopes[sourceIdx].prepare(sampleRate);
        
        _synths[sourceIdx].prepare(sampleRate);
        _biquads[sourceIdx].prepare(sampleRate);
        _tremolos[sourceIdx].prepare(sampleRate);
        _shapeTremolos[sourceIdx].prepare(sampleRate);
        
        _memoryPlayers[sourceIdx].prepare(sampleRate);
        
        _soloGains[sourceIdx].setIsRunning(true);
    }
    
    for (int channel=0; channel < kNumChannels; channel++) {
        _masterGains[channel].setIsRunning(true);
        _levelMeters[channel].prepare(sampleRate);
    }
    
    _setupGain.setTargetValue(1.0f, kDefaultRampTime_ms * _sampleRate / 1000.0f);
}


void TWAudioEngine::process(float *leftBuffer, float *rightBuffer, int frameCount)
{
    for (int frame=0; frame < frameCount; frame++) {
        
        leftBuffer[frame] = rightBuffer[frame] = 0.0f;
        
        if (!_seqEditingEvents) {
            for (std::vector<TWSeqEvent>::iterator iter = _seqEvents.begin(); iter != _seqEvents.end(); ++iter) {
                if ((_seqSampleCount == iter->sampleStartTime) && (_seqEnvelopes[iter->sourceIdx].getEnabled())) {
                    _synths[iter->sourceIdx].resetPhase(0.0);
//                    _tremolos[iter->sourceIdx].resetPhase();
//                    _biquads[iter->sourceIdx].resetLFOPhase();
                    _seqEnvelopes[iter->sourceIdx].start();
                }
            }
        }
        
        for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
            _synths[sourceIdx].getSample(_sourceBuffers[sourceIdx].leftSample, _sourceBuffers[sourceIdx].rightSample);
            _tremolos[sourceIdx].process(_sourceBuffers[sourceIdx].leftSample, _sourceBuffers[sourceIdx].rightSample);
            _shapeTremolos[sourceIdx].process(_sourceBuffers[sourceIdx].leftSample, _sourceBuffers[sourceIdx].rightSample);
            _biquads[sourceIdx].process(_sourceBuffers[sourceIdx].leftSample, _sourceBuffers[sourceIdx].rightSample);
            _seqEnvelopes[sourceIdx].process(_sourceBuffers[sourceIdx].leftSample, _sourceBuffers[sourceIdx].rightSample);
            
            _memoryPlayers[sourceIdx].getSample(_sourceBuffers[sourceIdx].leftSample, _sourceBuffers[sourceIdx].rightSample);
            
            float soloGain = _soloGains[sourceIdx].getCurrentValue();
            leftBuffer[frame]  += _sourceBuffers[sourceIdx].leftSample  * soloGain / kNumSources;
            rightBuffer[frame] += _sourceBuffers[sourceIdx].rightSample * soloGain / kNumSources;
        }
        
        // Master Gain
        leftBuffer[frame]  *= _masterGains[kLeftChannel].getCurrentValue();
        rightBuffer[frame] *= _masterGains[kRightChannel].getCurrentValue();
        
        // Setup Gain
        float finalGain = _setupGain.getCurrentValue();
        leftBuffer[frame]  *= finalGain;
        rightBuffer[frame] *= finalGain;
        
        // RMS Level Meters
        _levelMeters[kLeftChannel].process(leftBuffer[frame]);
        _levelMeters[kRightChannel].process(rightBuffer[frame]);
        
        _seqSampleCount = (_seqSampleCount + 1) % _seqDurationSamples;
    }
}


void TWAudioEngine::release()
{
    _setupGain.setTargetValue(0.0f, kDefaultRampTime_ms * _sampleRate / 1000.0f);
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        _seqEnvelopes[sourceIdx].release();
        _synths[sourceIdx].release();
        _biquads[sourceIdx].release();
        _tremolos[sourceIdx].release();
        _shapeTremolos[sourceIdx].release();
        _soloGains[sourceIdx].setIsRunning(false);
        _memoryPlayers[sourceIdx].release();
    }
    
    for (int channel=0; channel < kNumChannels; channel++) {
        _masterGains[channel].setIsRunning(false);
        _levelMeters[channel].release();
    }
}




//============================================================
// Master
//============================================================

void TWAudioEngine::setMasterGain(int channel, float gain, float rampTime_ms)
{
    _masterGains[channel].setTargetValue(gain, rampTime_ms * _sampleRate / 1000.0f);
}
float TWAudioEngine::getMasterGain(int channel)
{
    return _masterGains[channel].getTargetValue();
}

void TWAudioEngine::resetPhase(float rampTimeInSamples)
{
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        _synths[sourceIdx].resetPhase(rampTimeInSamples);
        _tremolos[sourceIdx].resetPhase(rampTimeInSamples);
        _shapeTremolos[sourceIdx].resetPhase(rampTimeInSamples);
        _biquads[sourceIdx].resetLFOPhase(rampTimeInSamples);
    }
    _seqSampleCount = 0;
}

float TWAudioEngine::getRMSLevel(int channel)
{
    return _levelMeters[channel].getCurrentLevel();
}


//============================================================
// Sequencer
//============================================================
#pragma mark - Sequencer

float TWAudioEngine::getSeqNormalizedProgress()
{
    return ((float)_seqSampleCount / (float)_seqDurationSamples);
}


void TWAudioEngine::setSeqEnabledAtSourceIdx(int sourceIdx, bool enabled)
{
    _seqEnvelopes[sourceIdx].setEnabled(enabled);
}
bool TWAudioEngine::getSeqEnabledAtSourceIdx(int sourceIdx)
{
    return _seqEnvelopes[sourceIdx].getEnabled();
}


void TWAudioEngine::setSeqIntervalAtSourceIdx(int sourceIdx, int interval)
{
    _seqSourceIntervals[sourceIdx] = interval;
    
    _seqNotes[sourceIdx].clear();
    for (int idx=0; idx < interval; idx++) {
        _seqNotes[sourceIdx].push_back(0);
    }
    
    _seqEditingEvents = true;
    std::vector<TWSeqEvent>::iterator iter = _seqEvents.begin();
    while (iter != _seqEvents.end()) {
        if (iter->sourceIdx == sourceIdx) {
            iter = _seqEvents.erase(iter);
        } else {
            ++iter;
        }
    }
    _seqEditingEvents = false;
    
    _printSeqSourceIntervals();
}

int TWAudioEngine::getSeqIntervalAtSourceIdx(int sourceIdx)
{
    return _seqSourceIntervals[sourceIdx];
}


void TWAudioEngine::setSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat, int note)
{
    _seqNotes[sourceIdx][beat] = note;
    _printSeqNotes();
    
    _seqEditingEvents = true;
    if (note == 0) {
        std::vector<TWSeqEvent>::iterator iter = _seqEvents.begin();
        while (iter != _seqEvents.end()) {
            if ((iter->sourceIdx == sourceIdx) && (iter->beat == beat)) {
                iter = _seqEvents.erase(iter);
                break;
            } else {
                ++iter;
            }
        }
    }
    else {
        TWSeqEvent newEvent;
        newEvent.sampleStartTime = _seqSampleTimeForIntervalAndBeat(_seqSourceIntervals[sourceIdx], beat);
        newEvent.interval        = _seqSourceIntervals[sourceIdx];
        newEvent.beat             = beat;
        newEvent.sourceIdx       = sourceIdx;
        _seqEvents.push_back(newEvent);
    }
    _seqEditingEvents = false;
    
    _printSeqEvents();
}

int TWAudioEngine::getSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat)
{
    return _seqNotes[sourceIdx][beat];
}


void TWAudioEngine::setSeqParameterAtSourceIdx(int sourceIdx, TWSeqParamID paramID, float value)
{
    switch (paramID) {
            
        case TWSeqParamID_Duration_ms:
            if (value <= 0.0f) {
                value = 1.0f;
            }
            _seqDuration_ms = value;
            _seqUpdateTotalDurationSamples();
            break;
            
        case TWSeqParamID_AmpAttackTime:
            _seqEnvelopes[sourceIdx].setAmpAttackTime_ms(value);
            break;
            
        case TWSeqParamID_AmpSustainTime:
            _seqEnvelopes[sourceIdx].setAmpSustainTime_ms(value);
            break;
            
        case TWSeqParamID_AmpReleaseTime:
            _seqEnvelopes[sourceIdx].setAmpReleaseTime_ms(value);
            break;
            
        case TWSeqParamID_FilterEnable:
            _seqEnvelopes[sourceIdx].setFltEnabled((bool)value);
            break;
            
        case TWSeqParamID_FilterType:
            _seqEnvelopes[sourceIdx].setFltType((TWBiquad::TWFilterType)value);
            break;
            
        case TWSeqParamID_FilterAttackTime:
            _seqEnvelopes[sourceIdx].setFltAttackTime_ms(value);
            break;
            
        case TWSeqParamID_FilterSustainTime:
            _seqEnvelopes[sourceIdx].setFltSustainTime_ms(value);
            break;
            
        case TWSeqParamID_FilterReleaseTime:
            _seqEnvelopes[sourceIdx].setFltReleaseTime_ms(value);
            break;
            
        case TWSeqParamID_FilterFromCutoff:
            _seqEnvelopes[sourceIdx].setFltFromCutoff(value);
            break;
            
        case TWSeqParamID_FilterToCutoff:
            _seqEnvelopes[sourceIdx].setFltToCutoff(value);
            break;
            
        case TWSeqParamID_FilterResonance:
            _seqEnvelopes[sourceIdx].setFltResonance(value, _rampTimes[sourceIdx]);
            break;
            
        default:
            printf("\nError(setSeqParameterAtSourceIdx): Unknown paramID: %d. For sourceIdx: %d\n", (int)paramID, sourceIdx);
            break;
    }
}

float TWAudioEngine::getSeqParameterAtSourceIdx(int sourceIdx, TWSeqParamID paramID)
{
    float value = 0.0f;
    
    switch (paramID) {
            
        case TWSeqParamID_Duration_ms:
            value = _seqDuration_ms;
            break;
            
        case TWSeqParamID_AmpAttackTime:
            value = _seqEnvelopes[sourceIdx].getAmpAttackTime_ms();
            break;
            
        case TWSeqParamID_AmpSustainTime:
            value = _seqEnvelopes[sourceIdx].getAmpSustainTime_ms();
            break;
            
        case TWSeqParamID_AmpReleaseTime:
            value = _seqEnvelopes[sourceIdx].getAmpReleaseTime_ms();
            break;
            
        case TWSeqParamID_FilterEnable:
            value = _seqEnvelopes[sourceIdx].getFltEnabled();
            break;
            
        case TWSeqParamID_FilterType:
            value = _seqEnvelopes[sourceIdx].getFltType();
            break;
            
        case TWSeqParamID_FilterAttackTime:
            value = _seqEnvelopes[sourceIdx].getFltAttackTime_ms();
            break;
            
        case TWSeqParamID_FilterSustainTime:
            value = _seqEnvelopes[sourceIdx].getFltSustainTime_ms();
            break;
            
        case TWSeqParamID_FilterReleaseTime:
            value = _seqEnvelopes[sourceIdx].getFltReleaseTime_ms();
            break;
            
        case TWSeqParamID_FilterFromCutoff:
            value = _seqEnvelopes[sourceIdx].getFltFromCutoff();
            break;
            
        case TWSeqParamID_FilterToCutoff:
            value = _seqEnvelopes[sourceIdx].getFltToCutoff();
            break;
            
        case TWSeqParamID_FilterResonance:
            value = _seqEnvelopes[sourceIdx].getFltResonance();
            break;
            
        default:
            printf("\nError(getSeqParameterAtSourceIdx): Unknown paramID: %d. For sourceIdx: %d\n", (int)paramID, sourceIdx);
            break;
    }
    
    return value;
}




//============================================================
// Oscillators and Effects
//============================================================
#pragma mark - Oscillators and Effects

void TWAudioEngine::setOscSoloEnabledAtSourceIdx(int sourceIdx, bool enabled)
{
    _solos[sourceIdx] = enabled;
    enabled ? _soloCount++ : _soloCount--;
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        if ((_soloCount == 0) || _solos[sourceIdx]) {
            _soloGains[sourceIdx].setTargetValue(1.0f, kSoloRampTime_ms / 1000.0f * _sampleRate);
        } else {
            _soloGains[sourceIdx].setTargetValue(0.0f, kSoloRampTime_ms / 1000.0f * _sampleRate);
        }
    }
}

bool TWAudioEngine::getOscSoloEnabledAtSourceIdx(int sourceIdx)
{
    return _solos[sourceIdx];
}



void TWAudioEngine::setOscParameterAtSourceIdx(int sourceIdx, TWOscParamID paramID, float value, float rampTime_ms)
{
    switch (paramID) {
            
            
        case TWOscParamID_RampTime_ms:
            _rampTimes[sourceIdx] = value;
            break;
            
            
            
        case TWOscParamID_OscWaveform:
            _synths[sourceIdx].setWaveform((TWOscillator::TWWaveform)value);
            break;
            
        case TWOscParamID_OscBaseFrequency:
            _synths[sourceIdx].setBaseFrequency(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscBeatFrequency:
            _synths[sourceIdx].setBeatFrequency(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscAmplitude:
            _synths[sourceIdx].setAmplitude(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscDutyCycle:
            _synths[sourceIdx].setDutyCycle(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscMononess:
            _synths[sourceIdx].setMononess(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscSoftClipp:
            _synths[sourceIdx].setSoftClipp(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscPhaseOffset:
            _synths[sourceIdx].setPhaseOffset(kLeftChannel, value, rampTime_ms);
            _synths[sourceIdx].setPhaseOffset(kRightChannel, value, rampTime_ms);
            break;
            
            
            
        case TWOscParamID_TremoloWaveform:
            _tremolos[sourceIdx].setWaveform((TWOscillator::TWWaveform)value);
            break;
            
        case TWOscParamID_TremoloFrequency:
            _tremolos[sourceIdx].setFrequency(value, rampTime_ms);
            break;
            
        case TWOscParamID_TremoloDepth:
            _tremolos[sourceIdx].setDepth(value, rampTime_ms);
            break;
            
        case TWOscParamID_TremoloPhaseOffset:
            _tremolos[sourceIdx].setPhaseOffset(value, rampTime_ms);
            break;
            
            
            
        case TWOscParamID_ShapeTremoloFrequency:
            _shapeTremolos[sourceIdx].setFrequency(value, rampTime_ms);
            break;
        
        case TWOscParamID_ShapeTremoloDepth:
            _shapeTremolos[sourceIdx].setDepth(value, rampTime_ms);
            break;
            
        case TWOscParamID_ShapeTremoloSoftClipp:
            _shapeTremolos[sourceIdx].setSoftClipp(value, rampTime_ms);
            break;
            
        case TWOscParamID_ShapeTremoloPhaseOffset:
            _shapeTremolos[sourceIdx].setPhaseOffset(value, rampTime_ms);
            break;
            
            
            
        case TWOscParamID_FilterEnable:
            _biquads[sourceIdx].setEnabled((bool)value);
            break;
            
        case TWOscParamID_FilterType:
            _biquads[sourceIdx].setFilterType((TWBiquad::TWFilterType)value);
            break;
            
        case TWOscParamID_FilterCutoff:
            _biquads[sourceIdx].setCutoffFrequency(value, rampTime_ms);
            break;
            
        case TWOscParamID_FilterResonance:
            _biquads[sourceIdx].setResonance(value, rampTime_ms);
            break;
            
        case TWOscParamID_FilterGain:
            _biquads[sourceIdx].setGain(value, rampTime_ms);
            break;
            
            
            
        case TWOscParamID_FilterLFOEnable:
            _biquads[sourceIdx].setLFOEnabled((bool)value);
            break;
            
        case TWOscParamID_FilterLFOWaveform:
            _biquads[sourceIdx].setLFOWaveform((TWOscillator::TWWaveform)value);
            break;
            
        case TWOscParamID_FilterLFOFrequency:
            _biquads[sourceIdx].setLFOFrequency(value, rampTime_ms);
            break;
            
        case TWOscParamID_FilterLFORange:
            _biquads[sourceIdx].setLFORange(value, rampTime_ms);
            break;
            
        case TWOscParamID_FilterLFOOffset:
            _biquads[sourceIdx].setLFOOffset(value, rampTime_ms);
            break;
            
            
            
        case TWOscParamID_OscFMWaveform:
            _synths[sourceIdx].setFMWaveform((TWOscillator::TWWaveform)value);
            break;
            
        case TWOscParamID_OscFMAmount:
            _synths[sourceIdx].setFMAmount(value, rampTime_ms);
            break;
            
        case TWOscParamID_OscFMFrequency:
            _synths[sourceIdx].setFMFrequency(value, rampTime_ms);
            break;
            
            
            
        default:
            printf("\nError(setOscParameterAtSourceIdx): Unknown paramID: %d. For sourceIdx: %d\n", (int)paramID, sourceIdx);
            break;
    }
}

float TWAudioEngine::getOscParameterAtSourceIdx(int sourceIdx, TWOscParamID paramID)
{
    float value = 0.0f;
    
    switch (paramID) {
            
            
        case TWOscParamID_RampTime_ms:
            value = _rampTimes[sourceIdx];
            break;
            
            
            
        case TWOscParamID_OscWaveform:
            value = _synths[sourceIdx].getWaveform();
            break;
            
        case TWOscParamID_OscBaseFrequency:
            value = _synths[sourceIdx].getBaseFrequency();
            break;
            
        case TWOscParamID_OscBeatFrequency:
            value = _synths[sourceIdx].getBeatFrequency();
            break;
            
        case TWOscParamID_OscAmplitude:
            value = _synths[sourceIdx].getAmplitude();
            break;
            
        case TWOscParamID_OscDutyCycle:
            value = _synths[sourceIdx].getDutyCycle();
            break;
            
        case TWOscParamID_OscMononess:
            value = _synths[sourceIdx].getMononess();
            break;
            
        case TWOscParamID_OscSoftClipp:
            value = _synths[sourceIdx].getSoftClipp();
            break;
            
            
            
        case TWOscParamID_TremoloWaveform:
            value = (float)_tremolos[sourceIdx].getWaveform();
            break;
            
        case TWOscParamID_TremoloFrequency:
            value = _tremolos[sourceIdx].getFrequency();
            break;
            
        case TWOscParamID_TremoloDepth:
            value = _tremolos[sourceIdx].getDepth();
            break;
            
            
            
        case TWOscParamID_ShapeTremoloFrequency:
            value = _shapeTremolos[sourceIdx].getFrequency();
            break;
            
        case TWOscParamID_ShapeTremoloDepth:
            value = _shapeTremolos[sourceIdx].getDepth();
            break;
            
        case TWOscParamID_ShapeTremoloSoftClipp:
            value = _shapeTremolos[sourceIdx].getSoftClipp();
            break;
            
            
            
        case TWOscParamID_FilterEnable:
            value = _biquads[sourceIdx].getEnabled();
            break;
            
        case TWOscParamID_FilterType:
            value = _biquads[sourceIdx].getFilterType();
            break;
            
        case TWOscParamID_FilterCutoff:
            value = _biquads[sourceIdx].getCutoffFrequency();
            break;
            
        case TWOscParamID_FilterResonance:
            value = _biquads[sourceIdx].getResonance();
            break;
            
        case TWOscParamID_FilterGain:
            value = _biquads[sourceIdx].getGain();
            break;
            
        case TWOscParamID_FilterLFOEnable:
            value = _biquads[sourceIdx].getLFOEnabled();
            break;
            
        case TWOscParamID_FilterLFOWaveform:
            value = (float)_biquads[sourceIdx].getLFOWaveform();
            break;
            
            
            
        case TWOscParamID_FilterLFOFrequency:
            value = _biquads[sourceIdx].getLFOFrequency();
            break;
            
        case TWOscParamID_FilterLFORange:
            value = _biquads[sourceIdx].getLFORange();
            break;
            
        case TWOscParamID_FilterLFOOffset:
            value = _biquads[sourceIdx].getLFOOffset();
            break;
            
            
            
        case TWOscParamID_OscFMWaveform:
            value = _synths[sourceIdx].getFMWaveform();
            break;
            
        case TWOscParamID_OscFMAmount:
            value = _synths[sourceIdx].getFMAmount();
            break;
            
        case TWOscParamID_OscFMFrequency:
            value = _synths[sourceIdx].getFMFrequency();
            break;
            
            
            
        default:
            printf("\nError(getOscParameterAtSourceIdx): Unknown paramID: %d. For sourceIdx: %d\n", (int)paramID, sourceIdx);
            break;
    }
    
    return value;
}



//============================================================
// Drum Pad
//============================================================
int TWAudioEngine::loadAudioFileAtSourceIdx(int sourceIdx, std::string filepath)
{
    return _memoryPlayers[sourceIdx].loadAudioFile(filepath);
}

void TWAudioEngine::startPlaybackAtSourceIdx(int sourceIdx, uint32_t sampleTime)
{
    _memoryPlayers[sourceIdx].start(sampleTime);
}

void TWAudioEngine::stopPlaybackAtSourceIdx(int sourceIdx, float fadeOut_ms)
{
    uint32_t fadeOutInSamples = fadeOut_ms * _sampleRate / 1000.0f;
    _memoryPlayers[sourceIdx].stop(fadeOutInSamples);
}

void TWAudioEngine::setPadParameterAtSourceIdx(int sourceIdx, TWPadParamID paramID, float value, float rampTime_ms = 0.0f)
{
    switch (paramID) {
        case TWPadParamID_Velocity:
            _memoryPlayers[sourceIdx].setCurrentVelocity(value, rampTime_ms);
            break;
            
        case TWPadParamID_MaxVolume:
            _memoryPlayers[sourceIdx].setMaxVolume(value, rampTime_ms);
            break;
            
        case TWPadParamID_DrumPadMode:
//            printf("DrumPadMode [%d] : %d\n", sourceIdx, (TWDrumPadMode)value);
            _memoryPlayers[sourceIdx].setDrumPadMode((TWDrumPadMode)value);
            break;
            
        case TWPadParamID_PlaybackDirection:
            _memoryPlayers[sourceIdx].setPlaybackDirection((TWPlaybackDirection)value);
            break;
            
        default:
            printf("\nError(setPadParameterAtSourceIdx): Unknown paramID: %d. For sourceIdx: %d\n", (int)paramID, sourceIdx);
            break;
    }
}

float TWAudioEngine::getPadParameterAtSourceIdx(int sourceIdx, TWPadParamID paramID)
{
    float returnValue = 0.0f;
    
    switch (paramID) {
        case TWPadParamID_Velocity:
            returnValue = _memoryPlayers[sourceIdx].getCurrentVelocity();
            break;
            
        case TWPadParamID_MaxVolume:
            returnValue = _memoryPlayers[sourceIdx].getMaxVolume();
            break;
            
        case TWPadParamID_DrumPadMode:
            returnValue = (float)_memoryPlayers[sourceIdx].getDrumPadMode();
            break;
            
        case TWPadParamID_PlaybackDirection:
            returnValue = (float)_memoryPlayers[sourceIdx].getPlaybackDirection();
            break;
            
        case TWPadParamID_PlaybackStatus:
            returnValue = (float)_memoryPlayers[sourceIdx].getPlaybackStatus();
            break;
            
        case TWPadParamID_NormalizedProgress:
            returnValue = _memoryPlayers[sourceIdx].getNormalizedPlaybackProgress();
            break;
            
        case TWPadParamID_LengthInSeconds:
            returnValue = _memoryPlayers[sourceIdx].getLengthInSeconds();
            break;
            
        default:
            printf("\nError(TWAudioEnging::getPadParameterAtSourceIdx): Unknown paramID: %d. For sourceIdx: %d\n", (int)paramID, sourceIdx);
            break;
    }
    
    return returnValue;
}

void TWAudioEngine::setPlaybackFinishedProc(std::function<void(int,int)> finishedPlaybackProc)
{
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        _memoryPlayers[sourceIdx].setPlaybackFinishedProc(finishedPlaybackProc);
    }
}

std::string TWAudioEngine::getAudioFileTitleAtSourceIdx(int sourceIdx)
{
    return _memoryPlayers[sourceIdx].getAudioFileTitle();
}




//============================================================
// Private
//============================================================

#pragma mark - Private Sequencer
void TWAudioEngine::_seqUpdateTotalDurationSamples()
{
    _seqDurationSamples = _seqDuration_ms * _sampleRate / 1000.0f;
    for (std::vector<TWSeqEvent>::iterator iter = _seqEvents.begin(); iter != _seqEvents.end(); ++iter) {
        iter->sampleStartTime = _seqSampleTimeForIntervalAndBeat(iter->interval, iter->beat);
    }
}

uint64_t TWAudioEngine::_seqSampleTimeForIntervalAndBeat(int interval, int beat)
{
    return (beat * _seqDuration_ms / interval) * _sampleRate / 1000.0f;
}




#pragma mark - Private Logging

void TWAudioEngine::_printSeqSourceIntervals()
{
#if PRINT_SEQ_INTERVALS
    printf("\n\nSeq Interval Notes:\n");
    for (int sourceIdx = 0; sourceIdx < kNumSources; sourceIdx++) {
        printf("%d : %d\n", sourceIdx, _seqSourceIntervals[sourceIdx]);
    }
#endif
}

void TWAudioEngine::_printSeqNotes()
{
#if PRINT_SEQ_NOTES
    printf("\n\n\nSeq Notes:\n");
    for (int sourceIdx = 0; sourceIdx < kNumSources; sourceIdx++) {
        printf("%d:\t", sourceIdx);
        for (int beat = 0; beat < _seqSourceIntervals[sourceIdx]; beat++) {
            printf("%d\t", _seqNotes[sourceIdx][beat]);
        }
        printf("\n");
    }
#endif
}

void TWAudioEngine::_printSeqEvents()
{
#if PRINT_SEQ_EVENTS
    printf("\n\nSeq Events:\n");
    for (std::vector<SeqEvent>::iterator iter = _seqEvents.begin(); iter != _seqEvents.end(); ++iter) {
        printf("%d, %d, %d, %llu\n", iter->sourceIdx+1, iter->interval, iter->beat, iter->sampleStartTime);
    }
#endif
}

void TWAudioEngine::_log(const char * format, ...)
{
#if DEBUG_PRINT
    va_list argptr;
    va_start(argptr, format);
    vfprintf(stderr, format, argptr);
    va_end(argptr);
#endif
}

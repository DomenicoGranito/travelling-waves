//
//  TWMixer.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/24/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWMixer.h"
#include <cstdarg>

#define DEBUG_PRINT         0

TWMixer::TWMixer()
{
    for (int idx = 0; idx < kNumSources; idx++) {
//        BinauralSynth* synth = new BinauralSynth();
//        _synths.push_back(synth);
//
//        Tremolo* tremolo = new Tremolo();
//        _tremolos.push_back(tremolo);
//
//        BinauralBiquad* biquad = new BinauralBiquad();
//        _biquads.push_back(biquad);
        
        _rampTimes[idx] = 200.0f;
        _solos[idx] = false;
        _soloGains[idx].setTargetValue(1.0f, 0.0f);
    }
    
    _soloCount = 0;
    _sampleRate = kDefaultSampleRate;
    _sequencer = new TWSequencer();
    
    
//    for (int i=0; i < kNumChannels; i++) {
//        Delay* delay = new Delay();
//        _delays.push_back(delay);
//    }
    
    _leftGain.setTargetValue(1.0f, 0.0f);
    _rightGain.setTargetValue(1.0f, 0.0f);
    _leftGain.setIsRunning(true);
    _rightGain.setIsRunning(true);
}

TWMixer::~TWMixer()
{
//    for (size_t idx = 0; idx < kNumSources; idx++) {
//        delete _synths[idx];
//        delete _biquads[idx];
//        delete _tremolos[idx];
//    }
    
//    for (size_t idx=0; idx < kNumChannels; idx++) {
//        delete _delays[idx];
//    }
    
    delete _sequencer;
    dispatch_release(_readQueue);
    
    delete _fileStream;
}




void TWMixer::prepare(float sampleRate)
{
    _leftGain.setTargetValue(0.0f, 0.0f);
    _rightGain.setTargetValue(0.0f, 0.0f);
    
    _sampleRate = sampleRate;
    
    for (size_t idx = 0; idx < kNumSources; idx++) {
        _synths[idx].prepare(sampleRate);
        _biquads[idx].prepare(sampleRate);
        _tremolos[idx].prepare(sampleRate);
        
        _sourceBuffers[idx].leftSample = 0.0f;
        _sourceBuffers[idx].rightSample = 0.0f;
        
        _soloGains[idx].setIsRunning(true);
    }
    
    _sequencer->prepare(sampleRate);
    
    _leftGain.setTargetValue(1.0f, kDefaultRampTime_ms * _sampleRate / 1000.0f);
    _rightGain.setTargetValue(1.0f, kDefaultRampTime_ms * _sampleRate / 1000.0f);
    
//    for (size_t idx=0; idx < kNumChannels; idx++) {
//        _delays[idx].prepare(sampleRate);
//    }
    
    _fileStream->prepare(sampleRate);
}

void TWMixer::process(float* leftBuffer, float* rightBuffer, int frameCount)
{
    for (int sample=0; sample < frameCount; sample++) {
        
        
        leftBuffer[sample] = rightBuffer[sample] = 0.0f;
        
        
        // Synth + Effects
        for (int idx=0; idx < kNumSources; idx++) {
            _synths[idx].getSample(_sourceBuffers[idx].leftSample, _sourceBuffers[idx].rightSample);
            _tremolos[idx].process(_sourceBuffers[idx].leftSample, _sourceBuffers[idx].rightSample);
            _biquads[idx].process(_sourceBuffers[idx].leftSample, _sourceBuffers[idx].rightSample);
            
            float soloGain = _soloGains[idx].getCurrentValue();
            
            _sourceBuffers[idx].leftSample  *= soloGain;
            _sourceBuffers[idx].rightSample *= soloGain;
        }
        
        
        // Sequencer + Envelope
        _sequencer->process(_sourceBuffers.data());
        
        
        // Mix
        for (int idx=0; idx < kNumSources; idx++) {
            leftBuffer[sample]  += _sourceBuffers[idx].leftSample  / kNumSources;
            rightBuffer[sample] += _sourceBuffers[idx].rightSample / kNumSources;
        }
        
        
        _fileStream->getSample(leftBuffer[sample], rightBuffer[sample]);
        
        
        // Master Gain
        leftBuffer[sample] *= _leftGain.getCurrentValue();
        rightBuffer[sample] *= _rightGain.getCurrentValue();
    }
}

void TWMixer::release()
{
    _leftGain.setTargetValue( 0.0f, kDefaultRampTime_ms * _sampleRate / 1000.0f);
    _rightGain.setTargetValue(0.0f, kDefaultRampTime_ms * _sampleRate / 1000.0f);
    
    for (size_t idx = 0; idx < kNumSources; idx++) {
        _synths[idx].release();
        _biquads[idx].release();
        _tremolos[idx].release();
        _soloGains[idx].setIsRunning(false);
    }
    
    _sequencer->release();
    
    _fileStream->release();
    
//    for (size_t idx=0; idx < kNumChannels; idx++) {
//        _delays[idx].release();
//    }
}



void TWMixer::setMasterLeftGain(float gain, float rampTime_ms)
{
    log("SetMstLeftGain: %f. %f\n", gain, rampTime_ms);
    _leftGain.setTargetValue(gain, rampTime_ms * _sampleRate / 1000.0f);
}

void TWMixer::setMasterRightGain(float gain, float rampTime_ms)
{
    log("SetMstRightGain: %f. %f\n", gain, rampTime_ms);
    _rightGain.setTargetValue(gain, rampTime_ms * _sampleRate / 1000.0f);
}

float TWMixer::getMasterLeftGain()
{
    return _leftGain.getTargetValue();
}

float TWMixer::getMasterRightGain()
{
    return _rightGain.getTargetValue();
}



void TWMixer::resetOscPhase(float rampTimeInSamples)
{
    for (int idx=0; idx < kNumSources; idx++) {
        _synths[idx].resetPhase(rampTimeInSamples);
        _tremolos[idx].resetPhase(rampTimeInSamples);
        _biquads[idx].resetLFOPhase(rampTimeInSamples);
    }
}

void TWMixer::setRampTimeAtSourceIdx(int idx, float rampTime_ms)
{
    log("SetRampTime[%d]: %f", idx, rampTime_ms);
    _rampTimes[idx] = rampTime_ms;
}

float TWMixer::getRampTimeAtSourceIdx(int idx)
{
    return _rampTimes[idx];
}


void TWMixer::setBinauralSolo(int idx, bool solo)
{
    log("setBinSolo[%d]: %d", idx, solo);
    _solos[idx] = solo;
    solo ? _soloCount++ : _soloCount--;
    for (int i=0; i < kNumSources; i++) {
        if ((_soloCount == 0) || _solos[i]) {
            _soloGains[i].setTargetValue(1.0f, kSoloRampTime_ms / 1000.0f * _sampleRate);
        } else {
            _soloGains[i].setTargetValue(0.0f, kSoloRampTime_ms / 1000.0f * _sampleRate);
        }
    }
}

bool TWMixer::getBinauralSolo(int idx)
{
    return _solos[idx];
}





#pragma mark - Oscillator Methods

void TWMixer::setBinauralWaveform(int idx, TWOscillator::TWWaveform type)
{
    log("SetBinWave[%d]: %d\n", idx, (int)type);
    _synths[idx].setWaveform(type);
}

void TWMixer::setBinauralBaseFrequency(int idx, float frequency, float rampTime_ms)
{
    log("SetBinBaseFreq[%d]: %f. %f\n", idx, frequency, rampTime_ms);
    _synths[idx].setBaseFrequency(frequency, rampTime_ms);
}

void TWMixer::setBinauralBeatFrequency(int idx, float frequency, float rampTime_ms)
{
     log("SetBinBeatFreq[%d]: %f. %f\n", idx, frequency, rampTime_ms);
    _synths[idx].setBeatFrequency(frequency, rampTime_ms);
}

void TWMixer::setBinauralAmplitude(int idx, float amplitude, float rampTime_ms)
{
    log("SetBinAmp[%d]: %f. %f\n", idx, amplitude, rampTime_ms);
    _synths[idx].setAmplitude(amplitude, rampTime_ms);
}

void TWMixer::setBinauralDutyCycle(int idx, float dutyCycle, float rampTime_ms)
{
    log("SetBinDuty[%d]: %f. %f\n", idx, dutyCycle, rampTime_ms);
    _synths[idx].setDutyCycle(dutyCycle, rampTime_ms);
}

void TWMixer::setBinauralMononess(int idx, float mononess, float rampTime_ms)
{
    log("SetBinMono[%d]: %f. %f\n", idx, mononess, rampTime_ms);
    _synths[idx].setMononess(mononess, rampTime_ms);
}


TWOscillator::TWWaveform TWMixer::getBinauralWaveform(int idx)
{
    return _synths[idx].getWaveform();
}

float TWMixer::getBinauralBaseFrequency(int idx)
{
    return _synths[idx].getBaseFrequency();
}

float TWMixer::getBinauralBeatFrequency(int idx)
{
    return _synths[idx].getBeatFrequency();
}

float TWMixer::getBinauralAmplitude(int idx)
{
    return _synths[idx].getAmplitude();
}

float TWMixer::getBinauralDutyCycle(int idx)
{
    return _synths[idx].getDutyCycle();
}

float TWMixer::getBinauralMononess(int idx)
{
    return _synths[idx].getMononess();
}


#pragma mark - Tremolo Methods

void TWMixer::setTremoloFrequency(int idx, float frequency, float rampTime_ms)
{
    log("SetTremFreq: %f. %f\n", frequency, rampTime_ms);
    _tremolos[idx].setFrequency(frequency, rampTime_ms);
}

void TWMixer::setTremoloDepth(int idx, float depth, float rampTime_ms)
{
    log("SetTremDpth: %f. %f\n", depth, rampTime_ms);
    _tremolos[idx].setDepth(depth, rampTime_ms);
}

float TWMixer::getTremoloFrequency(int idx)
{
    return _tremolos[idx].getFrequency();
}

float TWMixer::getTremoloDepth(int idx)
{
    return _tremolos[idx].getDepth();
}


#pragma mark - Filter Methods

void TWMixer::setFilterType(int idx, TWBiquad::TWFilterType type)
{
    log("SetFltType[%d]: %d\n", idx, (int)type);
    _biquads[idx].setFilterType(type);
}

void TWMixer::setFilterCutoff(int idx, float cutoff, float rampTime_ms)
{
    log("SetFltFc[%d]: %f. %f\n", idx, cutoff, rampTime_ms);
    _biquads[idx].setCutoffFrequency(cutoff, rampTime_ms);
}

void TWMixer::setFilterResonance(int idx, float resonance, float rampTime_ms)
{
    log("SetFltQ[%d]: %f. %f\n", idx, resonance, rampTime_ms);
    _biquads[idx].setResonance(resonance, rampTime_ms);
}

void TWMixer::setFilterGain(int idx, float gain, float rampTime_ms)
{
    log("SetFltG[%d]: %f. %f\n", idx, gain, rampTime_ms);
    _biquads[idx].setGain(gain, rampTime_ms);
}

void TWMixer::setFilterEnabled(int idx, bool enabled)
{
    log("SetFltEnabled[%d]: %d\n", idx, (int)enabled);
    _biquads[idx].setEnabled(enabled);
}


bool TWMixer::getFilterEnabled(int idx)
{
    return _biquads[idx].getEnabled();
}

TWBiquad::TWFilterType TWMixer::getFilterType(int idx)
{
    return _biquads[idx].getFilterType();
}

float TWMixer::getFilterCutoff(int idx)
{
    return _biquads[idx].getCutoffFrequency();
}

float TWMixer::getFilterResonance(int idx)
{
    return _biquads[idx].getResonance();
}

float TWMixer::getFilterGain(int idx)
{
    return _biquads[idx].getGain();
}



void TWMixer::setLFOEnabled(int idx, bool enabled)
{
    log("SetLFOEnabled[%d]: %d\n", idx, (int)enabled);
    _biquads[idx].setLFOEnabled(enabled);
}

void TWMixer::setLFOFrequency(int idx, float newFc, float rampTime_ms)
{
    log("SetLFOFreq[%d]: %f. %f\n", idx, newFc, rampTime_ms);
    _biquads[idx].setLFOFrequency(newFc, rampTime_ms);
}

void TWMixer::setLFORange(int idx, float newRange, float rampTime_ms)
{
    log("SetLFORange[%d]: %f. %f\n", idx, newRange, rampTime_ms);
    _biquads[idx].setLFORange(newRange, rampTime_ms);
}

void TWMixer::setLFOOffset(int idx, float offset, float rampTime_ms)
{
    log("SetLFOOffset[%d]: %f. %f\n", idx, offset, rampTime_ms);
    _biquads[idx].setLFOOffset(offset, rampTime_ms);
}


bool TWMixer::getLFOEnabled(int idx)
{
    return _biquads[idx].getLFOEnabled();
}

float TWMixer::getLFOFrequency(int idx)
{
    return _biquads[idx].getLFOFrequency();
}

float TWMixer::getLFORange(int idx)
{
    return _biquads[idx].getLFORange();
}

float TWMixer::getLFOOffset(int idx)
{
    return _biquads[idx].getLFOOffset();
}


#pragma mark - Delay Methods

void TWMixer::setDelayTime_ms(int idx, float delayTime_ms, float rampTime_ms)
{
//    _delays[idx].setDelayTime_ms(delayTime_ms, rampTime_ms);
}

void TWMixer::setDelayFeedback(int idx, float feedback, float rampTime_ms)
{
//    _delays[idx].setFeedback(feedback, rampTime_ms);
}

void TWMixer::setDelayDryWetRatio(int idx, float dryWetRatio, float rampTime_ms)
{
//    _delays[idx].setDryWetRatio(dryWetRatio, rampTime_ms);
}




#pragma mark - Sequencer

void TWMixer::setSeqDuration_ms(float duration_ms)
{
    log("SetSeqDur: %f\n", duration_ms);
    _sequencer->setDuration_ms(duration_ms);
}
float TWMixer::getSeqDuration_ms()
{
    return _sequencer->getDuration_ms();
}

float TWMixer::getSeqNormalizedTick()
{
    return _sequencer->getNormalizedTick();
}

void TWMixer::setSeqEnabledAtSourceIdx(int sourceIdx, bool enabled)
{
    log("SetSeqEnableAtSrc[%d] : %d\n", sourceIdx, enabled);
    _sequencer->setEnabledAtSourceIdx(sourceIdx, enabled);
}
bool TWMixer::getSeqEnabledAtSourceIdx(int sourceIdx)
{
    return _sequencer->getEnabledAtSourceIdx(sourceIdx);
}


void TWMixer::setSeqIntervalAtSourceIdx(int sourceIdx, int interval)
{
    log("SetSeqIntAtSrc[%d] : %d\n", sourceIdx, interval);
    _sequencer->setIntervalAtSourceIdx(sourceIdx, interval);
}
int TWMixer::getSeqIntervalAtSourceIdx(int sourceIdx)
{
    return _sequencer->getIntervalAtSourceIdx(sourceIdx);
}


void TWMixer::setSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat, int note)
{
    log("SetSeqNoteAtSrc[%d][%d] : %d\n", sourceIdx, beat, note);
    _sequencer->setNoteForBeatAtSourceIdx(sourceIdx, beat, note);
}
int TWMixer::getSeqNoteForBeatAtSourceIdx(int sourceIdx, int beat)
{
    return _sequencer->getNoteForBeatAtSourceIdx(sourceIdx, beat);
}


void TWMixer::setSeqAmpAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms)
{
    log("SetSeqAmpAttackTime[%d] : %f\n", sourceIdx, attackTime_ms);
    _sequencer->setAmpAttackTimeAtSourceIdx(sourceIdx, attackTime_ms);
}
float TWMixer::getSeqAmpAttackTimeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getAmpAttackTimeAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqAmpSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms)
{
    log("SetSeqAmpSustainTime[%d] : %f\n", sourceIdx, sustainTime_ms);
    _sequencer->setAmpSustainTimeAtSourceIdx(sourceIdx, sustainTime_ms);
}
float TWMixer::getSeqAmpSustainTimeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getAmpSustainTimeAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqAmpReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms)
{
    log("SetSeqAmpReleaseTime[%d] : %f\n", sourceIdx, releaseTime_ms);
    _sequencer->setAmpReleaseTimeAtSourceIdx(sourceIdx, releaseTime_ms);
}
float TWMixer::getSeqAmpReleaseTimeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getAmpReleaseTimeAtSourceIdx(sourceIdx);
}


void TWMixer::setSeqFltEnabledAtSourceIdx(int sourceIdx, bool enabled)
{
    log("SetSeqFltEnable[%d] : %d\n", sourceIdx, enabled);
    _sequencer->setFltEnabledAtSourceIdx(sourceIdx, enabled);
}
bool TWMixer::getSeqFltEnabledAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltEnabledAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltAttackTimeAtSourceIdx(int sourceIdx, float attackTime_ms)
{
    log("SetSeqFltAttackTime[%d] : %f\n", sourceIdx, attackTime_ms);
    _sequencer->setFltAttackTimeAtSourceIdx(sourceIdx, attackTime_ms);
}
float TWMixer::getSeqFltAttackTimeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltAttackTimeAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltSustainTimeAtSourceIdx(int sourceIdx, float sustainTime_ms)
{
    log("SetSeqFltSustainTime[%d] : %f\n", sourceIdx, sustainTime_ms);
    _sequencer->setFltSustainTimeAtSourceIdx(sourceIdx, sustainTime_ms);
}
float TWMixer::getSeqFltSustainTimeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltSustainTimeAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltReleaseTimeAtSourceIdx(int sourceIdx, float releaseTime_ms)
{
    log("SetSeqFltReleaseTime[%d] : %f\n", sourceIdx, releaseTime_ms);
    _sequencer->setFltReleaseTimeAtSourceIdx(sourceIdx, releaseTime_ms);
}
float TWMixer::getSeqFltReleaseTimeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltReleaseTimeAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltTypeAtSourceIdx(int sourceIdx, TWBiquad::TWFilterType type)
{
    log("SetSeqFltType[%d] : %d\n", sourceIdx, (int)type);
    _sequencer->setFltTypeAtSourceIdx(sourceIdx, type);
}
TWBiquad::TWFilterType TWMixer::getSeqFltTypeAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltTypeAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltFromCutoffAtSourceIdx(int sourceIdx, float fromCutoff)
{
    log("SetSeqFltFromCutoff[%d] : %f\n", sourceIdx, fromCutoff);
    _sequencer->setFltFromCutoffAtSourceIdx(sourceIdx, fromCutoff);
}
float TWMixer::getSeqFltFromCutoffAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltFromCutoffAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltToCutoffAtSourceIdx(int sourceIdx, float toCutoff)
{
    log("SetSeqFltToCutoff[%d] : %f\n", sourceIdx, toCutoff);
    _sequencer->setFltToCutoffAtSourceIdx(sourceIdx, toCutoff);
}
float TWMixer::getSeqFltToCutoffAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltToCutoffAtSourceIdx(sourceIdx);
}

void TWMixer::setSeqFltResonanceAtSourceIdx(int sourceIdx, float resonance, float rampTime_ms)
{
    log("SetSeqFltQ[%d] : %f\n", sourceIdx, resonance);
    _sequencer->setFltResonanceAtSourceIdx(sourceIdx, resonance, rampTime_ms);
}
float TWMixer::getSeqFltResonanceAtSourceIdx(int sourceIdx)
{
    return _sequencer->getFltResonanceAtSourceIdx(sourceIdx);
}



int TWMixer::loadAudioFileAtSourceIdx(int sourceIdx, std::string filepath)
{
    return _fileStream->loadAudioFile(filepath);
}

void TWMixer::startPlaybackAtSourceIdx(int sourceIdx, uint64_t sampleTime)
{
    
}

void TWMixer::stopPlaybackAtSourceIdx(int sourceIdx)
{
    _fileStream->stop();
}

void TWMixer::setPlaybackLoopingAtSourceIdx(int sourceIdx, bool isLooping)
{
    
}

bool TWMixer::getPlaybackLoopingAtSourceIdx(int sourceIdx)
{
    return false;
}

float TWMixer::getNormalizedPlaybackProgressAtSourceIdx(int sourceIdx)
{
    return _fileStream->getNormalizedPlaybackProgress();
}

bool TWMixer::getPlaybackStatusAtSourceIdx(int sourceIdx)
{
    return _fileStream->getIsRunning();
}


#pragma mark - Private

void TWMixer::log(const char * format, ...)
{
#if DEBUG_PRINT
    va_list argptr;
    va_start(argptr, format);
    vfprintf(stderr, format, argptr);
    va_end(argptr);
#endif
}

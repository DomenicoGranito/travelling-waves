//
//  TWHeader.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWHeader_h
#define TWHeader_h


#define kNumSources                                             16
#if (kNumSources % 2 == 1)
    #error Only even number of sources are supported
#endif

static const float  kDefaultSampleRate                          = 48000.0f;
static const int    kNumChannels                                = 2;
static const float  kDefaultBufferDuration_ms                   = 10.667f;

static const int    kOutputBus                                  = 0;
static const int    kInputBus                                   = 1;

static const int    kLeftChannel                                = 0;
static const int    kRightChannel                               = 1;

static const int    kNumerator                                  = 0;
static const int    kDenominator                                = 1;


/* Circular Sequencer */
#define kNumIntervals                                           32


/* User Interface */
static const float  kPortraitComponentHeight                    = 40.0f;
static const float  kLandscapePadComponentHeight                = 50.0f;
static const float  kLandscapePhoneComponentHeight              = 35.0f;

static const float  kTitleLabelWidth                            = 30.0f;
static const float  kValueLabelWidth                            = 44.0f;

static const float  kButtonXMargin                              = 2.0f;
static const float  kButtonYMargin                              = 3.0f;
static const float  kKeyboardAccessoryHeightPad                 = 50.0f;
static const float  kKeyboardAccessoryPortraitHeightPhone       = 40.0f;
static const float  kKeyboardAccessoryLandscapeHeightPhone      = 35.0f;
static const float  kHitFlashTime_s                             = 0.15f;


/* Defaults */
static const float  kDefaultRampTime_ms                         = 200.0f;
static const float  kDefaultFrequency                           = 256.0f;
static const float  kDefaultAmplitude                           = 0.5;
static const float  kDefaultTempo                               = 60.0;   // BPM

static const float  kSoloRampTime_ms                            = 100.0f;
static const float  kSeqEnableCrossfadeTime_ms                  = 500.0f;

static const float  kDefaultSeqDuration_ms                      = 2000.0f;
static const float  kDefaultBeatsPerBar                         = 4.0f;
static const float  kDefaultEnvAttackTime_ms                    = 10.0f;
static const float  kDefaultEnvSustainTime_ms                   = 0.0f;
static const float  kDefaultEnvReleaseTime_ms                   = 100.0f;
static const float  kDefaultFltAttackTime_ms                    = 100.0f;
static const float  kDefaultFltSustainTime_ms                   = 100.0f;
static const float  kDefaultFltReleaseTime_ms                   = 200.0f;
static const float  kDefaultRMSLevelWindow_ms                   = 40.0f;


/* Parameter Ranges */
static const float  kFrequencyMin                               = 1.0f;
static const float  kFrequencyMax                               = 20000.0f;

static const float  kResonanceMin                               = 0.4f;
static const float  kResonanceMax                               = 36.0f;

static const float  kAmplitudeMin                               = 0.0f;
static const float  kAmplitudeMax                               = 1.0f;

static const float  kLFORateMin                                 = 0.0f;
static const float  kLFORateMax                                 = 36.0f;


/* Audio File Playback Stream */
static const int    kMemoryPlayerMaxSizeFrames                  = 2880000;  // 60 seconds @ 48KHz
static const float  kAudioFilePlaybackFadeOutTime_ms            = 10.0f;



//#define kShouldUpdateOscViewOnTouch     1



/* Parameter IDs */

typedef enum : int {
    TWOscParamID_RampTime_ms                                    = 1,
    TWOscParamID_OscWaveform                                    = 2,
    TWOscParamID_OscBaseFrequency                               = 3,
    TWOscParamID_OscBeatFrequency                               = 4,
    TWOscParamID_OscAmplitude                                   = 5,
    TWOscParamID_OscDutyCycle                                   = 6,
    TWOscParamID_OscMononess                                    = 7,
    TWOscParamID_OscSoftClipp                                   = 8,
    TWOscParamID_OscPhaseOffset                                 = 9,
    TWOscParamID_TremoloWaveform                                = 10,
    TWOscParamID_TremoloFrequency                               = 11,
    TWOscParamID_TremoloDepth                                   = 12,
    TWOscParamID_TremoloPhaseOffset                             = 13,
    TWOscParamID_ShapeTremoloFrequency                          = 14,
    TWOscParamID_ShapeTremoloDepth                              = 15,
    TWOscParamID_ShapeTremoloSoftClipp                          = 16,
    TWOscParamID_ShapeTremoloPhaseOffset                        = 17,
    TWOscParamID_FilterEnable                                   = 18,
    TWOscParamID_FilterType                                     = 19,
    TWOscParamID_FilterCutoff                                   = 20,
    TWOscParamID_FilterResonance                                = 21,
    TWOscParamID_FilterGain                                     = 22,
    TWOscParamID_FilterLFOEnable                                = 23,
    TWOscParamID_FilterLFOWaveform                              = 24,
    TWOscParamID_FilterLFOFrequency                             = 25,
    TWOscParamID_FilterLFORange                                 = 26,
    TWOscParamID_FilterLFOOffset                                = 27,
    TWOscParamID_OscFMWaveform                                  = 28,
    TWOscParamID_OscFMAmount                                    = 29,
    TWOscParamID_OscFMFrequency                                 = 30
} TWOscParamID;

#define kOscNumParams                                           30


typedef enum : int {
    TWSeqParamID_Duration_ms                                    = 1,
    TWSeqParamID_AmpAttackTime                                  = 2,
    TWSeqParamID_AmpSustainTime                                 = 3,
    TWSeqParamID_AmpReleaseTime                                 = 4,
    TWSeqParamID_FilterEnable                                   = 5,
    TWSeqParamID_FilterType                                     = 6,
    TWSeqParamID_FilterAttackTime                               = 7,
    TWSeqParamID_FilterSustainTime                              = 8,
    TWSeqParamID_FilterReleaseTime                              = 9,
    TWSeqParamID_FilterFromCutoff                               = 10,
    TWSeqParamID_FilterToCutoff                                 = 11,
    TWSeqParamID_FilterResonance                                = 12
} TWSeqParamID;

#define kSeqNumParams                                           12


typedef enum : int {
    TWPadParamID_MaxVolume                                      = 1,
    TWPadParamID_DrumPadMode                                    = 2,
    TWPadParamID_PlaybackDirection                              = 3,
    TWPadParamID_Velocity                                       = 4,
    TWPadParamID_PlaybackStatus                                 = 5,      // Readonly
    TWPadParamID_NormalizedProgress                             = 6,      // Readonly
    TWPadParamID_LengthInSeconds                                = 7,      // Readonly
} TWPadParamID;

#define kPadNumSetParams                                        4




struct TWFrame {
    float leftSample;
    float rightSample;
};


typedef enum : int {
    TWDrumPadMode_OneShot                                       = 0,
    TWDrumPadMode_Momentary                                     = 1,
    TWDrumPadMode_Toggle                                        = 2,
    TWDrumPadMode_NumModes                                      = 3
} TWDrumPadMode;


typedef enum : int {
    TWTouchState_Up,
    TWTouchState_Down
} TWTouchState;


typedef enum : int {
    TWPlaybackStatus_Uninitialized                              = 0,
    TWPlaybackStatus_Stopped                                    = 1,
    TWPlaybackStatus_Playing                                    = 2,
    TWPlaybackStatus_Recording                                  = 3,
} TWPlaybackStatus;


typedef enum : int {
    TWPlaybackDirection_Forward                                 = 0,
    TWPlaybackDirection_Reverse                                 = 1
} TWPlaybackDirection;


typedef enum : int {
    TWPlaybackFinishedStatus_Success                            = 0,
    TWPlaybackFinishedStatus_Uninitialized                      = 1,
    TWPlaybackFinishedStatus_NoIORunning                        = 2
} TWPlaybackFinishedStatus;


typedef enum : int {
    TWTimeRatioControl_BaseFrequency                            = 0,
    TWTimeRatioControl_BeatFrequency                            = 1,
    TWTimeRatioControl_TremFrequency                            = 2,
    TWTimeRatioControl_ShapeTremFrequency                       = 3,
    TWTimeRatioControl_FilterLFOFrequency                       = 4
} TWTimeRatioControl;

#define kNumTimeRatioControls                                   5


//typedef enum : int {
//    TWParamSliderScale_Linear                                   = 0,
//    TWParamSliderScale_Log                                      = 1
//} TWParamSliderScale;


typedef enum : int {
    TWParamRange_Min                                            = 0,
    TWParamRange_Max                                            = 1,
    TWParamRange_Curve                                          = 2
} TWParamRange;

#endif /* TWHeader_h */

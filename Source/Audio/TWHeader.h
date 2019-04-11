//
//  TWHeader.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWHeader_h
#define TWHeader_h


#define kNumSources                             16
#if (kNumSources % 2 == 1)
    #error Only even number of sources are supported
#endif

static const float  kDefaultSampleRate                          = 48000.0f;
static const int    kNumChannels                                = 2;

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
static const float  kDefaultTempo                               = 60.0;       // BPM

static const float  kSoloRampTime_ms                            = 100.0f;
static const float  kSeqEnableCrossfadeTime_ms                  = 500.0f;

static const float  kDefaultSeqDuration_ms                      = 2000.0f;
static const float  kDefaultEnvAttackTime_ms                    = 10.0f;
static const float  kDefaultEnvSustainTime_ms                   = 0.0f;
static const float  kDefaultEnvReleaseTime_ms                   = 100.0f;
static const float  kDefaultFltAttackTime_ms                    = 100.0f;
static const float  kDefaultFltSustainTime_ms                   = 100.0f;
static const float  kDefaultFltReleaseTime_ms                   = 200.0f;
static const float  kDefaultRMSLevelWindow_ms                   = 40.0f;

static const float  kFrequencyMin                               = 1.0f;
static const float  kFrequencyMax                               = 20000.0f;

static const float  kResonanceMin                               = 0.4f;
static const float  kResonanceMax                               = 36.0f;


//#define kShouldUpdateOscViewOnTouch     1


/* Parameter IDs */
#define kOscParam_OscWaveform                   1
#define kOscParam_OscBaseFrequency              2
#define kOscParam_OscBeatFrequency              3
#define kOscParam_OscAmplitude                  4
#define kOscParam_OscDutyCycle                  5
#define kOscParam_OscMononess                   6
#define kOscParam_TremoloFrequency              7
#define kOscParam_TremoloDepth                  8
#define kOscParam_FilterEnable                  9
#define kOscParam_FilterType                    10
#define kOscParam_FilterCutoff                  11
#define kOscParam_FilterQ                       12
#define kOscParam_FilterGain                    13
#define kOscParam_LFOEnable                     14
#define kOscParam_LFOFrequency                  15
#define kOscParam_LFORange                      16
#define kOscParam_LFOOffset                     17
#define kOscParam_FMWaveform                    18
#define kOscParam_FMAmount                      19
#define kOscParam_FMFrequency                   20
#define kOscNumParams                           20

#define kSeqParam_AmpAttackTime                 1
#define kSeqParam_AmpSustainTime                2
#define kSeqParam_AmpReleaseTime                3
#define kSeqParam_FltEnable                     4
#define kSeqParam_FltType                       5
#define kSeqParam_FltAttackTime                 6
#define kSeqParam_FltSustainTime                7
#define kSeqParam_FltReleaseTime                8
#define kSeqParam_FltFromCutoff                 9
#define kSeqParam_FltToCutoff                   10
#define kSeqParam_FltQ                          11
#define kSeqNumParams                           11

#define kPlaybackParam_Velocity                 1
#define kPlaybackParam_MaxVolume                2
#define kPlaybackParam_DrumPadMode              3
#define kPlaybackParam_PlaybackDirection        4
#define kPlaybackParam_PlaybackStatus           5       // Readonly
#define kPlaybackParam_NormalizedProgress       6       // Readonly
#define kPlaybackParam_LengthInSeconds          7       // Readonly


/* Audio File Playback Stream */
#define kMemoryPlayerMaxSizeFrames              2880000     // 60 seconds @ 48KHz
#define kAudioFilePlaybackFadeOutTime_ms        10.0f



struct TWFrame {
    float leftSample;
    float rightSample;
};


typedef enum : int {
    TWDrumPadMode_OneShot                       = 0,
    TWDrumPadMode_Momentary                     = 1,
    TWDrumPadMode_Toggle                        = 2,
    TWDrumPadMode_NumModes                      = 3
} TWDrumPadMode;


typedef enum {
    TWTouchState_Up,
    TWTouchState_Down
} TWTouchState;


typedef enum {
    TWPlaybackStatus_Uninitialized              = 0,
    TWPlaybackStatus_Stopped                    = 1,
    TWPlaybackStatus_Playing                    = 2,
    TWPlaybackStatus_Recording                  = 3,
} TWPlaybackStatus;


typedef enum {
    TWPlaybackDirection_Forward                 = 0,
    TWPlaybackDirection_Reverse                 = 1
} TWPlaybackDirection;


typedef enum {
    TWPlaybackFinishedStatus_Success            = 0,
    TWPlaybackFinishedStatus_Uninitialized      = 1,
    TWPlaybackFinishedStatus_NoIORunning        = 2
} TWPlaybackFinishedStatus;


typedef enum {
    TWTimeRatioControl_BaseFrequency            = 0,
    TWTimeRatioControl_BeatFrequency            = 1,
    TWTimeRatioControl_TremFrequency            = 2,
    TWTimeRatioControl_FilterLFOFrequency       = 3
} TWTimeRatioControl;

#define kNumTimeRatioControls                   4

#endif /* TWHeader_h */

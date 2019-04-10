//
//  TWHeader.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWHeader_h
#define TWHeader_h

#define kDefaultSampleRate                      48000.0f

#define kNumSources                             16
#if (kNumSources % 2 == 1)
    #error Only even number of sources are supported
#endif

#define kNumChannels                            2

#define kOutputBus                              0
#define kInputBus                               1

#define kLeftChannel                            0
#define kRightChannel                           1

#define kNumerator                              0
#define kDenominator                            1

/* Circular Sequencer */
#define kNumIntervals                           32


/* User Interface */
#define kPortraitComponentHeight                40.0f
#define kLandscapePadComponentHeight            50.0f
#define kLandscapePhoneComponentHeight          35.0f
#define kTitleLabelWidth                        30.0f
#define kValueLabelWidth                        44.0f
#define kSliderOnWhiteColor                     0.6f
#define kButtonXMargin                          2.0f
#define kButtonYMargin                          3.0f
#define kKeyboardAccessoryHeightPad             50.0f
#define kKeyboardAccessoryPortraitHeightPhone   40.0f
#define kKeyboardAccessoryLandscapeHeightPhone  35.0f
#define kHitFlashTime_s                         0.15f


/* Defaults */
#define kDefaultRampTime_ms                     200.0f
#define kDefaultFrequency                       256.0f
#define kDefaultAmplitude                       0.5
#define kDefaultTempo                           60.0       // BPM

#define kSoloRampTime_ms                        100.0f
#define kSeqEnableCrossfadeTime_ms              500.0f

#define kDefaultSeqDuration_ms                  2000.0f
#define kDefaultEnvAttackTime_ms                10.0f
#define kDefaultEnvSustainTime_ms               0.0f
#define kDefaultEnvReleaseTime_ms               100.0f
#define kDefaultFltAttackTime_ms                100.0f
#define kDefaultFltSustainTime_ms               100.0f
#define kDefaultFltReleaseTime_ms               200.0f
#define kDefaultRMSLevelWindow_ms               40.0f

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

//
//  TWAudioController.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "TWHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TWAudioControllerDelegate<NSObject>
- (void)audioControllerDidStart;
- (void)audioControllerDidStop;
@end

typedef void (^TWAudioControllerPlaybackFinishedBlock)(int sourceIdx, int status);

@interface TWAudioController : NSObject

//===== AudioControl Methods =====//
+ (instancetype)sharedController;
- (void)start;
- (void)stop;
- (void)willEnterBackground;
- (void)willEnterForeground;

@property (nonatomic, readonly) BOOL isRunning;
- (void)addToDelegates:(id<TWAudioControllerDelegate>)delegate;


//===== Master Methods ====;=//
- (void)setMasterGain:(float)gain onChannel:(int)channel inTime:(float)rampTime_ms;
- (float)getMasterGainOnChannel:(int)channel;

- (void)resetPhaseInSamples:(float)samples;

- (float)getRMSLevelAtChannel:(int)channel;


//===== Sequencer Methods =====//
- (void)setSeqEnabled:(BOOL)enabled atSourceIdx:(int)sourceIdx;
- (BOOL)getSeqEnabledAtSourceIdx:(int)sourceIdx;

- (void)setSeqInterval:(int)interval atSourceIdx:(int)sourceIdx;
- (int)getSeqIntervalAtSourceIdx:(int)sourceIdx;

- (void)setSeqNote:(int)note atSourceIdx:(int)sourceIdx atBeat:(int)beat;
- (int)getSeqNoteAtSourceIdx:(int)sourceIdx atBeat:(int)beat;

- (void)setSeqParameter:(TWSeqParamID)paramID withValue:(float)value atSourceIdx:(int)sourceIdx;
- (float)getSeqParameter:(TWSeqParamID)paramID atSourceIdx:(int)sourceIdx;

- (float)getSeqNormalizedProgress;

- (void)clearSeqEvents;


//===== Oscillator and Effect Methods =====//
- (void)setOscSoloEnabled:(BOOL)enabled atSourceIdx:(int)sourceIdx;
- (BOOL)getOscSoloEnabledAtSourceIdx:(int)sourceIdx;

- (void)setOscParameter:(TWOscParamID)paramID withValue:(float)value atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms;
- (float)getOscParameter:(TWOscParamID)paramID atSourceIdx:(int)sourceIdx;



//===== Drum Pad Methods =====//
- (int)loadAudioFile:(NSString*)filepath atSourceIdx:(int)sourceIdx;
- (void)startPlaybackAtSourceIdx:(int)sourceIdx atSampleTime:(unsigned int)sampleTime;
- (void)stopPlaybackAtSourceIdx:(int)sourceIdx fadeOutTime:(float)fadeOut_ms;
- (void)setPadParameter:(TWPadParamID)paramID withValue:(float)value atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms;
- (float)getPadParameter:(TWPadParamID)paramID atSourceIdx:(int)sourceIdx;
- (NSString*)getAudioFileTitleAtSourceIdx:(int)sourceIdx;
@property(nonatomic, copy) TWAudioControllerPlaybackFinishedBlock playbackFinishedBlock;

@end

NS_ASSUME_NONNULL_END

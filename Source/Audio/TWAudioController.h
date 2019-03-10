//
//  TWAudioController.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWAudioControllerDelegate<NSObject>
- (void)audioControllerDidStart;
- (void)audioControllerDidStop;
@end


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

- (void)setRampTime:(float)rampTime_ms atSourceIdx:(int)sourceIdx;
- (float)getRampTimeAtSourceIdx:(int)sourceIdx;

- (float)getRMSLevelAtChannel:(int)channel;


//===== Sequencer Methods =====//
- (void)setSeqDuration_ms:(float)duration_ms;
- (float)getSeqDuration_ms;

- (void)setSeqEnabled:(BOOL)enabled atSourceIdx:(int)sourceIdx;
- (BOOL)getSeqEnabledAtSourceIdx:(int)sourceIdx;

- (void)setSeqInterval:(int)interval atSourceIdx:(int)sourceIdx;
- (int)getSeqIntervalAtSourceIdx:(int)sourceIdx;

- (void)setSeqNote:(int)note atSourceIdx:(int)sourceIdx atBeat:(int)beat;
- (int)getSeqNoteAtSourceIdx:(int)sourceIdx atBeat:(int)beat;

- (void)setSeqParameter:(int)paramID withValue:(float)value atSourceIdx:(int)sourceIdx;
- (float)getSeqParameter:(int)paramID atSourceIdx:(int)sourceIdx;

- (float)getSeqNormalizedProgress;


//===== Oscillator and Effect Methods =====//
- (void)setOscSoloEnabled:(BOOL)enabled atSourceIdx:(int)sourceIdx;
- (BOOL)getOscSoloEnabledAtSourceIdx:(int)sourceIdx;

- (void)setOscParameter:(int)paramID withValue:(float)value atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms;
- (float)getOscParameter:(int)paramID atSourceIdx:(int)sourceIdx;


@end

NS_ASSUME_NONNULL_END

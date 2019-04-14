//
//  TWAudioController.mm
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWAudioController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#include "TWAudioEngine.h"
#include "TWUtils.h"

#include <functional>


static TWAudioEngine* _engine;
static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    float* leftBuffer = (float*)ioData->mBuffers[0].mData;
    float* rightBuffer = (float*)ioData->mBuffers[1].mData;
    _engine->process(leftBuffer, rightBuffer, inNumberFrames);
    return noErr;
}


static void enginePlaybackFinishedProc(int sourceIdx, int status) {
    TWAudioControllerPlaybackFinishedBlock block = [[TWAudioController sharedController] playbackFinishedBlock];
    if (block != nil) {
        block(sourceIdx, status);
    }
}


@interface TWAudioController()
{
    AVAudioFormat*              _currentFormat;
    AudioComponentInstance      _audioUnit;
    NSMutableArray*             _delegates;
    BOOL                        _userInitiatedAudioRunningStatus;
}
@end


@implementation TWAudioController

#pragma mark - Init

- (id)init {
    
    if (self = [super init]) {
        [self _initializeAudioServices];
        [self _setupAudioEngine];
        _delegates = [[NSMutableArray alloc] init];
        _playbackFinishedBlock = nil;
    }
    
    return self;
}

- (void)_initializeAudioServices {
    [self _setupAudioSession];
    [self _setupAudioUnit];
    [self _setupMediaSession];
    [self _setupNowPlaying];
    _isRunning = NO;
    _userInitiatedAudioRunningStatus = NO;
}


+ (instancetype)sharedController {
    static dispatch_once_t onceToken;
    static TWAudioController* controller;
    dispatch_once(&onceToken, ^{
        controller = [[TWAudioController alloc] init];
    });
    return controller;
}


#pragma mark - AudioSession

- (void)_setupAudioSession {
    
    NSError* error;
    
    // Set Category Mode and Options
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Error setting audio session category, mode and options: %@", error.description);
    }
    
    // Set Preferred Sample Rate
    [[AVAudioSession sharedInstance] setPreferredSampleRate:kDefaultSampleRate error:&error];
    if (error) {
        NSLog(@"Error setting audio session preferred sample rate: %@", error.description);
    }
    
    // Set Preferred Number of Channels
    [[AVAudioSession sharedInstance] setPreferredOutputNumberOfChannels:kNumChannels error:&error];
    if (error) {
        NSLog(@"Error setting audio session preferred number of output channels: %@", error.description);
    }
    
    // Listen for Interruptions
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_audioSessionInterrupted:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];
    
    // Listen for Route Changes
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_audioSessionRouteChanged:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: [AVAudioSession sharedInstance]];
    
    // Listen for Media Services
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_audioSessionMediaServicesWereReset:)
                                                 name: AVAudioSessionMediaServicesWereResetNotification
                                               object: [AVAudioSession sharedInstance]];
    
    // Activate AudioSession
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"Error activating audio session: %@", error.description);
    }
}


- (void)_setupMediaSession {
    [[[MPRemoteCommandCenter sharedCommandCenter] togglePlayPauseCommand] setEnabled:YES];
    [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] setEnabled:YES];
    [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] setEnabled:YES];
    [[[MPRemoteCommandCenter sharedCommandCenter] stopCommand] setEnabled:YES];
    [[[MPRemoteCommandCenter sharedCommandCenter] nextTrackCommand] setEnabled:NO];
    [[[MPRemoteCommandCenter sharedCommandCenter] previousTrackCommand] setEnabled:NO];
    
    __block TWAudioController* myself = self;
    
    [[[MPRemoteCommandCenter sharedCommandCenter] togglePlayPauseCommand] addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [myself toggleStartStop];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [myself start];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [myself stop];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[[MPRemoteCommandCenter sharedCommandCenter] stopCommand] addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [myself stop];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}


- (void)_setupNowPlaying {
    [[MPNowPlayingInfoCenter defaultCenter]
     setNowPlayingInfo: @{
                          MPMediaItemPropertyTitle : @"Travelling Waves",
                          MPMediaItemPropertyAlbumTitle : @"",
                          MPMediaItemPropertyArtist : @"",
                          MPMediaItemPropertyPlaybackDuration : @(0),
                          MPNowPlayingInfoPropertyElapsedPlaybackTime : @(0)
                          }];
}


- (void)_audioSessionInterrupted:(NSNotification*)notification {
    
    AVAudioSessionInterruptionType interruption = (AVAudioSessionInterruptionType)[notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    switch (interruption) {
        case AVAudioSessionInterruptionTypeBegan:
            [self _stopEngine];
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
            AVAudioSessionInterruptionOptions options = (AVAudioSessionInterruptionOptions)[notification.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
            if (options == AVAudioSessionInterruptionOptionShouldResume) {
                if (_userInitiatedAudioRunningStatus) {
                    [self _startEngine];
                }
            }
            break;
    }
    
    NSLog(@"Interruption: %@", notification.userInfo);
}


- (void)_audioSessionRouteChanged:(NSNotification*)notification {
    if (![notification.name isEqualToString:AVAudioSessionRouteChangeNotification]) {
        return;
    }
    
    
    AVAudioSessionRouteChangeReason reason = (AVAudioSessionRouteChangeReason)[notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            
            break;
            
        default:
            break;
    }
    
    
    NSLog(@"Route Changed: %@", notification.userInfo);
}


- (void)_audioSessionMediaServicesWereReset:(NSNotification*)notification {
    NSLog(@"Media Services Were Reset: %@", notification.userInfo);
    [self stop];
    [self _initializeAudioServices];
}


- (void)_getSessionProperties {
    
    [[AVAudioSession sharedInstance] currentRoute];
    
    float sampleRate = [[AVAudioSession sharedInstance] sampleRate];
    NSLog(@"Current Session Sample Rate: %f", sampleRate);
    
    [[AVAudioSession sharedInstance] inputNumberOfChannels];
}


#pragma mark - AudioUnit

- (void)_setupAudioUnit {
    
    OSStatus status;
    
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    // Get component
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get RemoteI/O Audio Unit
    status = AudioComponentInstanceNew(outputComponent, &_audioUnit);
    [TWUtils checkOSStatus:status inContext:@"AudioComponentInstanceNew"];
    
    // Enable IO for playback
    UInt32 flag = 1;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    [TWUtils checkOSStatus:status inContext:@"AudioUnitSetProperty Output EnableIO"];
    
    // Create AudioFormat
    _currentFormat = nil;
    _currentFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                      sampleRate:kDefaultSampleRate
                                                        channels:kNumChannels
                                                     interleaved:NO];
    AudioStreamBasicDescription outASBD = *(_currentFormat.streamDescription);
    
    // Apply AudioFormat on Output Audio Unit
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &outASBD,
                                  sizeof(outASBD));
    [TWUtils checkOSStatus:status inContext:@"Set Output ASBD"];
    
    // Setup Output Audio Callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    [TWUtils checkOSStatus:status inContext:@"Setup Output Audio Callback"];
    
    // Initialize
    status = AudioUnitInitialize(_audioUnit);
    [TWUtils checkOSStatus:status inContext:@"AudioUnitInitialize"];
}


- (void)_setupAudioEngine {
    _engine = new TWAudioEngine();
    _engine->setPlaybackFinishedProc(enginePlaybackFinishedProc);
}


- (void)addToDelegates:(id<TWAudioControllerDelegate>)delegate {
    [_delegates addObject:delegate];
}


#pragma mark - Main

- (void)start {
    _userInitiatedAudioRunningStatus = YES;
    [self _startEngine];
}


- (void)_startEngine {
    _engine->prepare(_currentFormat.sampleRate);
    _engine->resetPhase(0.0);
    OSStatus status = AudioOutputUnitStart(_audioUnit);
    if([TWUtils checkOSStatus:status inContext:@"AudioOutputUnitStart"]) {
        _isRunning = YES;
        for (id<TWAudioControllerDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector:@selector(audioControllerDidStart)]) {
                [delegate audioControllerDidStart];
            }
        }
    }
}


- (void)stop {
    _userInitiatedAudioRunningStatus = NO;
    [self _stopEngine];
}


- (void)_stopEngine {
    _engine->release();
    __block AudioComponentInstance au = _audioUnit;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kDefaultRampTime_ms + 200.0f) * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        OSStatus status = AudioOutputUnitStop(au);
        if([TWUtils checkOSStatus:status inContext:@"AudioUnitStop"]) {
            self->_isRunning = NO;
            for (id<TWAudioControllerDelegate> delegate in self->_delegates) {
                if ([delegate respondsToSelector:@selector(audioControllerDidStop)]) {
                    [delegate audioControllerDidStop];
                }
            }
        }
    });
}


- (void)toggleStartStop {
    if (_isRunning) {
        [self stop];
    } else {
        [self start];
    }
}


- (void)dealloc {
    delete _engine;
    AudioComponentInstanceDispose(_audioUnit);
}



- (void)willEnterBackground {
    //    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)willEnterForeground {
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}




#pragma mark - Public

//===== Master Methods =====//

- (void)setMasterGain:(float)gain onChannel:(int)channel inTime:(float)rampTime_ms {
    _engine->setMasterGain(channel, gain, rampTime_ms);
}
- (float)getMasterGainOnChannel:(int)channel {
    return _engine->getMasterGain(channel);
}

- (void)resetPhaseInSamples:(float)samples {
    _engine->resetPhase(samples);
//    _engine->resetPhase(rampTimeInSamples);
}

- (float)getRMSLevelAtChannel:(int)channel {
    return _engine->getRMSLevel(channel);
}

//===== Sequencer Methods =====//

- (void)setSeqEnabled:(BOOL)enabled atSourceIdx:(int)sourceIdx {
    _engine->setSeqEnabledAtSourceIdx(sourceIdx, enabled);
}
- (BOOL)getSeqEnabledAtSourceIdx:(int)sourceIdx {
    return _engine->getSeqEnabledAtSourceIdx(sourceIdx);
}

- (void)setSeqInterval:(int)interval atSourceIdx:(int)sourceIdx {
    _engine->setSeqIntervalAtSourceIdx(sourceIdx, interval);
}
- (int)getSeqIntervalAtSourceIdx:(int)sourceIdx {
    return _engine->getSeqIntervalAtSourceIdx(sourceIdx);
}

- (void)setSeqNote:(int)note atSourceIdx:(int)sourceIdx atBeat:(int)beat {
    _engine->setSeqNoteForBeatAtSourceIdx(sourceIdx, beat, note);
}
- (int)getSeqNoteAtSourceIdx:(int)sourceIdx atBeat:(int)beat {
    return _engine->getSeqNoteForBeatAtSourceIdx(sourceIdx, beat);
}

- (void)setSeqParameter:(TWSeqParamID)paramID withValue:(float)value atSourceIdx:(int)sourceIdx {
    _engine->setSeqParameterAtSourceIdx(sourceIdx, paramID, value);
}
- (float)getSeqParameter:(TWSeqParamID)paramID atSourceIdx:(int)sourceIdx {
    return _engine->getSeqParameterAtSourceIdx(sourceIdx, paramID);
}

- (float)getSeqNormalizedProgress {
    return _engine->getSeqNormalizedProgress();
}


//===== Oscillator and Effect Methods =====//
- (void)setOscSoloEnabled:(BOOL)enabled atSourceIdx:(int)sourceIdx {
    _engine->setOscSoloEnabledAtSourceIdx(sourceIdx, enabled);
}
- (BOOL)getOscSoloEnabledAtSourceIdx:(int)sourceIdx {
    return _engine->getOscSoloEnabledAtSourceIdx(sourceIdx);
}

- (void)setOscParameter:(TWOscParamID)paramID withValue:(float)value atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms {
    _engine->setOscParameterAtSourceIdx(sourceIdx, paramID, value, rampTime_ms);
}
- (float)getOscParameter:(TWOscParamID)paramID atSourceIdx:(int)sourceIdx {
    return _engine->getOscParameterAtSourceIdx(sourceIdx, paramID);
}


//===== Drum Pad Methods =====//
- (int)loadAudioFile:(NSString*)filepath atSourceIdx:(int)sourceIdx {
    return _engine->loadAudioFileAtSourceIdx(sourceIdx, std::string([filepath UTF8String]));
}

- (void)startPlaybackAtSourceIdx:(int)sourceIdx atSampleTime:(unsigned int)sampleTime {
    _engine->startPlaybackAtSourceIdx(sourceIdx, sampleTime);
}

- (void)stopPlaybackAtSourceIdx:(int)sourceIdx fadeOutTime:(float)fadeOut_ms {
    _engine->stopPlaybackAtSourceIdx(sourceIdx, fadeOut_ms);
}

- (void)setPadParameter:(TWPadParamID)paramID withValue:(float)value atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms {
    _engine->setPadParameterAtSourceIdx(sourceIdx, paramID, value, rampTime_ms);
}

- (float)getPadParameter:(TWPadParamID)paramID atSourceIdx:(int)sourceIdx {
    return _engine->getPadParameterAtSourceIdx(sourceIdx, paramID);
}

- (NSString*)getAudioFileTitleAtSourceIdx:(int)sourceIdx {
    return [NSString stringWithUTF8String:_engine->getAudioFileTitleAtSourceIdx(sourceIdx).c_str()];
}

@end

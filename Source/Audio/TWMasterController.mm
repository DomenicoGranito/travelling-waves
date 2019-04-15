//
//  TWMasterController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/21/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWMasterController.h"
#import "TWAudioController.h"
#import "TWClock.h"

@interface TWMasterController()
{
    int         _timeControlRatios[kNumTimeRatioControls][2][kNumSources];
}
@end



@implementation TWMasterController


- (id)init {
    
    if (self = [super init]) {
        
        // Create and initialize TWAudioController
        [TWAudioController sharedController];
        [self initializeDefaults];
        
        // Initialize Clock
        [TWClock sharedClock];
        
        
        // Setup Project Directory
        NSError* error;
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        _projectsDirectory = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"Projects"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_projectsDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_projectsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                NSLog(@"Settings Init: Error! creating projectsDirectory: %@", error.description);
            }
        }
        
        [self loadOsterCurve];
        
        [self resetFrequencyChartCaches];
        
        _projectName = @"Default";
    }
    
    return self;
}



+ (instancetype)sharedController {
    static dispatch_once_t onceToken;
    static TWMasterController* controller;
    dispatch_once(&onceToken, ^{
        controller = [[TWMasterController alloc] init];
    });
    return controller;
}

- (void)initializeDefaults {
    
    _rootFrequency = kDefaultFrequency;
    _rampTime_ms = kDefaultRampTime_ms;
    _tempo = kDefaultTempo;
    
    for (int idx=0; idx < kNumSources; idx++) {
        for (int control = 0; control < kNumTimeRatioControls; control++) {
            
            int defaultNumerator = 1;
            if (control == TWTimeRatioControl_BeatFrequency) {
                defaultNumerator = 0;
            }
            _timeControlRatios[control][kNumerator][idx]      = defaultNumerator;
            _timeControlRatios[control][kDenominator][idx]    = 1;
            
            [self setValueForTimeControl:(TWTimeRatioControl)control atSourceIdx:idx];
        }
    }
    
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscAmplitude withValue:kDefaultAmplitude atSourceIdx:0 inTime:0.0f];
    
    for (int idx=1; idx < kNumSources; idx++) {
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscAmplitude withValue:0.0f atSourceIdx:idx inTime:0.0f];
    }
    
    _beatsPerBar = kDefaultBeatsPerBar;
    [self setSeqDurationFromTempo];
}


#pragma mark - API

- (BOOL)isAudioRunning {
    return [[TWAudioController sharedController] isRunning];
}


- (void)setRootFrequency:(float)rootFrequency {
    _rootFrequency = rootFrequency;
    for (int idx=0; idx < kNumSources; idx++) {
        [self setValueForTimeControl:TWTimeRatioControl_BaseFrequency atSourceIdx:idx];
    }
}


- (void)setRampTime_ms:(int)rampTime_ms {
    _rampTime_ms = rampTime_ms;
    for (int idx=0; idx < kNumSources; idx++) {
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_RampTime_ms withValue:_rampTime_ms atSourceIdx:idx inTime:0.0f];
    }
}


- (void)setTempo:(float)tempo {
    _tempo = tempo;
    for (int control = 1; control < kNumTimeRatioControls; control++) {
        for (int idx=0; idx < kNumSources; idx++) {
            [self setValueForTimeControl:(TWTimeRatioControl)control atSourceIdx:idx];
        }
    }
    [self setSeqDurationFromTempo];
}

- (void)setBeatsPerBar:(float)beatsPerBar {
    _beatsPerBar = beatsPerBar;
    [self setSeqDurationFromTempo];
}



- (int)incNumeratorRatioForControl:(TWTimeRatioControl)control atSourceIdx:(int)idx {
    ++_timeControlRatios[control][kNumerator][idx];
    [self setValueForTimeControl:control atSourceIdx:idx];
    return _timeControlRatios[control][kNumerator][idx];
}

- (int)decNumeratorRatioForControl:(TWTimeRatioControl)control atSourceIdx:(int)idx {
    int minValue = 1;
    if (control == TWTimeRatioControl_BeatFrequency) {
        minValue = 0;
    }
    if (--_timeControlRatios[control][kNumerator][idx] <= minValue) {
        _timeControlRatios[control][kNumerator][idx] = minValue;
    }
    [self setValueForTimeControl:control atSourceIdx:idx];
    return _timeControlRatios[control][kNumerator][idx];
}


- (int)incDenominatorRatioForControl:(TWTimeRatioControl)control atSourceIdx:(int)idx {
    ++_timeControlRatios[control][kDenominator][idx];
    [self setValueForTimeControl:control atSourceIdx:idx];
    return _timeControlRatios[control][kDenominator][idx];
}

- (int)decDenominatorRatioForControl:(TWTimeRatioControl)control atSourceIdx:(int)idx {
    if (--_timeControlRatios[control][kDenominator][idx] <= 1) {
        _timeControlRatios[control][kDenominator][idx] = 1;
    }
    [self setValueForTimeControl:control atSourceIdx:idx];
    return _timeControlRatios[control][kDenominator][idx];
}


- (void)setNumeratorRatioForControl:(TWTimeRatioControl)control withValue:(int)numerator atSourceIdx:(int)idx {
    if (numerator <= 1) {
        numerator = 1;
    }
    _timeControlRatios[control][kNumerator][idx] = numerator;
    [self setValueForTimeControl:control atSourceIdx:idx];
}

- (void)setDenominatorRatioForControl:(TWTimeRatioControl)control withValue:(int)denominator atSourceIdx:(int)idx {
    if (denominator <= 1) {
        denominator = 1;
    }
    _timeControlRatios[control][kDenominator][idx] = denominator;
    [self setValueForTimeControl:control atSourceIdx:idx];
}

- (int)getNumeratorRatioForControl:(TWTimeRatioControl)control atSourceIdx:(int)idx {
    return _timeControlRatios[control][kNumerator][idx];
}

- (int)getDenominatorRatioForControl:(TWTimeRatioControl)control atSourceIdx:(int)idx {
    return _timeControlRatios[control][kDenominator][idx];
}




#pragma mark - Project Parameter Saving

// TODO: Add Time Control Ratios to Project Settings

- (BOOL)saveProjectWithFilename:(NSString *)filename {
    NSError* error;
    NSString* filepath = [_projectsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", filename]];
    NSLog(@"Filepath: %@", filepath);
    _projectName = filename;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self getCurrentParametersAsDictionary] options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"Error in NSJSONSerialization: %@", error.description);
        return NO;
    }
    return [jsonData writeToFile:filepath atomically:NO];
}

- (BOOL)loadProjectFromFilename:(NSString *)filename {
    NSString* filepath = [_projectsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", filename]];
    NSLog(@"Filepath: %@", filepath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSData* data = [NSData dataWithContentsOfFile:filepath];
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (dictionary == nil) {
            return NO;
        }
        [self loadParametersFromDictionary:dictionary];
        [self resetFrequencyChartCaches];
        return YES;
    }
    return NO;
}

- (NSArray<NSString*>*)getListOfSavedFilenames {
    NSError* error;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_projectsDirectory error:&error];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSString* filepath in contents) {
        if ([[filepath pathExtension] isEqualToString:@"json"]) {
            NSString* filename = [filepath lastPathComponent];
            [array addObject:[filename stringByDeletingPathExtension]];
        }
    }
    return array;
}

- (BOOL)deleteProjectWithFilename:(NSString *)filename {
    NSString* filepath = [_projectsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", filename]];
    if ([[NSFileManager defaultManager] removeItemAtPath:filepath error:nil]) {
        return YES;
    }
    return NO;
}


- (NSArray<NSString*>*)getListOfPresetDrumPadSets {
    NSArray* array = [[NSArray alloc] initWithObjects:@"Minimal Percs", nil];
    return array;
}

#pragma mark - Private


- (NSDictionary*)getCurrentParametersAsDictionary {
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    
    @synchronized(self) {
        
        // Name
        dictionary[@"Name"] = _projectName;
        
        // Parameters
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        parameters[@"Root Frequency"] = @(_rootFrequency);
        parameters[@"Base RampTime_ms"] = @(_rampTime_ms);
        parameters[@"Num Sources"] = @(kNumSources);
        parameters[@"Tempo"] = @(_tempo);
        
        NSMutableArray* sources = [[NSMutableArray alloc] init];
        
        for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
            NSMutableDictionary* sourceParams = [[NSMutableDictionary alloc] init];
            sourceParams[@"Idx"] = @(sourceIdx);
            sourceParams[@"Tunings"] = @[@(_timeControlRatios[TWTimeRatioControl_BaseFrequency][kNumerator][sourceIdx]), @(_timeControlRatios[TWTimeRatioControl_BaseFrequency][kDenominator][sourceIdx])];
            sourceParams[@"Beat Freq Ratios"] = @[@(_timeControlRatios[TWTimeRatioControl_BeatFrequency][kNumerator][sourceIdx]), @(_timeControlRatios[TWTimeRatioControl_BeatFrequency][kDenominator][sourceIdx])];
            sourceParams[@"Trem Freq Ratios"] = @[@(_timeControlRatios[TWTimeRatioControl_TremFrequency][kNumerator][sourceIdx]), @(_timeControlRatios[TWTimeRatioControl_TremFrequency][kDenominator][sourceIdx])];
            sourceParams[@"Shape Trem Freq Ratios"] = @[@(_timeControlRatios[TWTimeRatioControl_ShapeTremFrequency][kNumerator][sourceIdx]), @(_timeControlRatios[TWTimeRatioControl_ShapeTremFrequency][kDenominator][sourceIdx])];
            sourceParams[@"Filter LFO Freq Ratios"] = @[@(_timeControlRatios[TWTimeRatioControl_FilterLFOFrequency][kNumerator][sourceIdx]), @(_timeControlRatios[TWTimeRatioControl_FilterLFOFrequency][kDenominator][sourceIdx])];
            for (int paramID = 1; paramID < kOscNumParams; paramID++) {
                NSString* key = [self keyForOscParamID:(TWOscParamID)paramID];
                sourceParams[key] = @([[TWAudioController sharedController] getOscParameter:(TWOscParamID)paramID atSourceIdx:sourceIdx]);
            }
            sourceParams[@"RampTime_ms"] = @((int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:sourceIdx]);
            [sources addObject:sourceParams];
        }
        parameters[@"Sources"] = sources;
        
        
        NSMutableDictionary* sequencer = [[NSMutableDictionary alloc] init];
        NSMutableArray* envelopes = [[NSMutableArray alloc] init];
        NSMutableArray* events = [[NSMutableArray alloc] init];
        for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
            NSMutableDictionary* envelope = [[NSMutableDictionary alloc] init];
            int interval = [[TWAudioController sharedController] getSeqIntervalAtSourceIdx:sourceIdx];
            envelope[@"Interval"] = @(interval);
            envelope[@"Enable"] = @([[TWAudioController sharedController] getSeqEnabledAtSourceIdx:sourceIdx]);
            for (int paramID=1; paramID < kSeqNumParams; paramID++) {
                NSString* key = [self keyForSeqParamID:(TWSeqParamID)paramID];
                envelope[key] = @([[TWAudioController sharedController] getSeqParameter:(TWSeqParamID)paramID atSourceIdx:sourceIdx]);
            }
            [envelopes addObject:envelope];
            for (int beat=0; beat < interval; beat++) {
                if ([[TWAudioController sharedController] getSeqNoteAtSourceIdx:sourceIdx atBeat:beat]) {
                    [events addObject:@{@"Src" : @(sourceIdx), @"Beat" : @(beat)}];
                }
            }
        }
        sequencer[@"Envelopes"] = envelopes;
        sequencer[@"Events"] = events;
        sequencer[@"Duration_ms"] = @([[TWAudioController sharedController] getSeqParameter:TWSeqParamID_Duration_ms atSourceIdx:-1]);
        
        parameters[@"Sequencer"] = sequencer;
        
        
        NSMutableDictionary* drumPad = [[NSMutableDictionary alloc] init];
        NSMutableArray* drumPadSourceParams = [[NSMutableArray alloc] init];
        
        for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
            
            NSMutableDictionary* padParams = [[NSMutableDictionary alloc] init];
            
            for (int paramID = 1; paramID < kPadNumSetParams; paramID++) {
                NSString* key = [self keyForPadParamID:(TWPadParamID)paramID];
                if (key != nil) {
                    padParams[key] = @([[TWAudioController sharedController] getPadParameter:(TWPadParamID)paramID atSourceIdx:sourceIdx]);
                }
            }
            
            NSString* filename = [[TWAudioController sharedController] getAudioFileTitleAtSourceIdx:sourceIdx];
            padParams[@"Filename"] = [filename stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            
            [drumPadSourceParams addObject:padParams];
        }
        drumPad[@"Sources"] = drumPadSourceParams;
        
        parameters[@"DrumPad"] = drumPad;
        
        
        dictionary[@"Parameters"] = parameters;
    }
    
    return dictionary;
}

- (void)loadParametersFromDictionary:(NSDictionary*)dictionary {
    
    // Name
    if ([dictionary objectForKey:@"Name"] != nil) {
        _projectName = dictionary[@"Name"];
    }
    
    // Parameters
    if ([dictionary objectForKey:@"Parameters"] != nil) {
        
        NSDictionary* parameters = dictionary[@"Parameters"];
        
        if ([parameters objectForKey:@"Root Frequency"] != nil) {
            _rootFrequency = [parameters[@"Root Frequency"] floatValue];
        }
        
        if ([parameters objectForKey:@"Base RampTime_ms"] != nil) {
            _rampTime_ms = [parameters[@"Base RampTime_ms"] intValue];
        }
        
        if ([parameters objectForKey:@"Tempo"] != nil) {
            _tempo = [parameters[@"Tempo"] floatValue];
        }
        
        int numSources = kNumSources;
        if ([parameters objectForKey:@"Num Sources"] != nil) {
            numSources = [parameters[@"Num Sources"] intValue];
            if (numSources > kNumSources) {
                numSources = kNumSources;
            }
        }
        
        if ([parameters objectForKey:@"Sources"] != nil) {
            
            NSArray* sources = parameters[@"Sources"];
            
            for (int sourceIdx=0; sourceIdx < numSources; sourceIdx++) {
                
                NSDictionary* sourceParams = sources[sourceIdx];
                if (sourceParams == nil) {
                    continue;
                }
                
                
                if ([sourceParams objectForKey:@"Tunings"]) {
                    _timeControlRatios[TWTimeRatioControl_BaseFrequency][kNumerator][sourceIdx] = [sourceParams[@"Tunings"][kNumerator] intValue];
                    _timeControlRatios[TWTimeRatioControl_BaseFrequency][kDenominator][sourceIdx] = [sourceParams[@"Tunings"][kDenominator] intValue];
                }
                
                if ([sourceParams objectForKey:@"Beat Freq Ratios"]) {
                    _timeControlRatios[TWTimeRatioControl_BeatFrequency][kNumerator][sourceIdx] = [sourceParams[@"Beat Freq Ratios"][kNumerator] intValue];
                    _timeControlRatios[TWTimeRatioControl_BeatFrequency][kDenominator][sourceIdx] = [sourceParams[@"Beat Freq Ratios"][kDenominator] intValue];
                }
                
                if ([sourceParams objectForKey:@"Trem Freq Ratios"]) {
                    _timeControlRatios[TWTimeRatioControl_TremFrequency][kNumerator][sourceIdx] = [sourceParams[@"Trem Freq Ratios"][kNumerator] intValue];
                    _timeControlRatios[TWTimeRatioControl_TremFrequency][kDenominator][sourceIdx] = [sourceParams[@"Trem Freq Ratios"][kDenominator] intValue];
                }
                
                if ([sourceParams objectForKey:@"Filter LFO Freq Ratios"]) {
                    _timeControlRatios[TWTimeRatioControl_FilterLFOFrequency][kNumerator][sourceIdx] = [sourceParams[@"Filter LFO Freq Ratios"][kNumerator] intValue];
                    _timeControlRatios[TWTimeRatioControl_FilterLFOFrequency][kDenominator][sourceIdx] = [sourceParams[@"Filter LFO Freq Ratios"][kDenominator] intValue];
                }
                
                if ([sourceParams objectForKey:@"Shape Trem Freq Ratios"]) {
                    _timeControlRatios[TWTimeRatioControl_ShapeTremFrequency][kNumerator][sourceIdx] = [sourceParams[@"Shape Trem Freq Ratios"][kNumerator] intValue];
                    _timeControlRatios[TWTimeRatioControl_ShapeTremFrequency][kDenominator][sourceIdx] = [sourceParams[@"Shape Trem Freq Ratios"][kDenominator] intValue];
                }
                
                
                
                int rampTime_ms = (int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:sourceIdx];
                if ([sourceParams objectForKey:@"RampTime_ms"]) {
                    rampTime_ms = [sourceParams[@"RampTime_ms"] intValue];
                }
                [[TWAudioController sharedController] setOscParameter:TWOscParamID_RampTime_ms withValue:rampTime_ms atSourceIdx:sourceIdx inTime:0.0f];
                
                for (int paramID = 1; paramID < kOscNumParams; paramID++) {
                    [self setOscParamValue:(TWOscParamID)paramID fromDictionary:sourceParams atSourceIdx:sourceIdx inTime:rampTime_ms];
                }
    
                for (int control=0; control < kNumTimeRatioControls; control++) {
                    [self setValueForTimeControl:(TWTimeRatioControl)control atSourceIdx:sourceIdx];
                }
            }
        }
        
        
        if ([parameters objectForKey:@"Sequencer"] != nil) {
            
            NSDictionary* sequencer = parameters[@"Sequencer"];
            
            if ([sequencer objectForKey:@"Duration_ms"]) {
                [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_Duration_ms withValue:[sequencer[@"Duration_ms"] floatValue] atSourceIdx:-1];
            }
            
            if ([sequencer objectForKey:@"Events"] != nil) {
                NSArray* events = sequencer[@"Events"];
                for (NSDictionary* event in events) {
                    [[TWAudioController sharedController] setSeqNote:1 atSourceIdx:[event[@"Src"] intValue] atBeat:[event[@"Beat"] intValue]];
                }
            }
            
            if ([sequencer objectForKey:@"Envelopes"] != nil) {
                NSArray* envelopes = sequencer[@"Envelopes"];
                
                for (int sourceIdx = 0; sourceIdx < numSources; sourceIdx++) {
                    NSDictionary* envelope = envelopes[sourceIdx];
                    
                    if (envelope == nil) {
                        continue;
                    }
                    
                    if ([envelope objectForKey:@"Interval"] != nil) {
                        [[TWAudioController sharedController] setSeqInterval:[envelope[@"Interval"] intValue] atSourceIdx:sourceIdx];
                    }
                    if ([envelope objectForKey:@"Enable"]) {
                        [[TWAudioController sharedController] setSeqEnabled:[envelope[@"Enable"] boolValue] atSourceIdx:sourceIdx];
                    }
                    for (int paramID = 1; paramID < kSeqNumParams; paramID++) {
                        [self setSeqParamValue:(TWSeqParamID)paramID fromDictionary:envelope atSourceIdx:sourceIdx];
                    }
                }
            }
        }
        
        
        if ([parameters objectForKey:@"DrumPad"] != nil) {
            
            NSDictionary* drumPad = parameters[@"DrumPad"];
            NSArray* drumPadSources = (NSArray*)drumPad[@"Sources"];
            
            for (int sourceIdx=0; sourceIdx < numSources; sourceIdx++) {
                
                NSDictionary* padParams = [drumPadSources objectAtIndex:sourceIdx];
                
                for (int i=1; i < kPadNumSetParams; i++) {
                    [self setPadParamValue:(TWPadParamID)i fromDictionary:padParams atSourceIdx:sourceIdx];
                }
                
                
                if ([padParams objectForKey:@"Filename"]) {
                    NSString* filename = padParams[@"Filename"];
                    if ((filename != nil) && (![filename isEqualToString:@""])) {
                        NSString* filepath = [[NSBundle mainBundle] pathForResource:filename ofType:@"wav"];
                        NSString* outfilepath = [filepath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                        [[TWAudioController sharedController] loadAudioFile:outfilepath atSourceIdx:sourceIdx];
                    }
                }
            }
        }
    }
}



- (void)loadOsterCurve {
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"OsterCurve" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    _osterCurve = [[NSArray alloc] initWithArray:dictionary[@"OsterCurve"]];
}






#pragma mark - Helper Methods


- (void)setOscParamValue:(TWOscParamID)paramID fromDictionary:(NSDictionary*)sourceDictionary atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms {
    NSString* key = [self keyForOscParamID:paramID];
    if ([sourceDictionary objectForKey:key]) {
        [[TWAudioController sharedController] setOscParameter:paramID withValue:[sourceDictionary[key] floatValue] atSourceIdx:sourceIdx inTime:rampTime_ms];
    }
}

- (void)setSeqParamValue:(TWSeqParamID)paramID fromDictionary:(NSDictionary*)sourceDictionary atSourceIdx:(int)sourceIdx {
    NSString* key = [self keyForSeqParamID:paramID];
    if ([sourceDictionary objectForKey:key]) {
        [[TWAudioController sharedController] setSeqParameter:paramID withValue:[sourceDictionary[key] floatValue] atSourceIdx:sourceIdx];
    }
}

- (void)setPadParamValue:(TWPadParamID)paramID fromDictionary:(NSDictionary*)sourceDictionary atSourceIdx:(int)sourceIdx {
    NSString* key = [self keyForPadParamID:paramID];
    if ([sourceDictionary objectForKey:key]) {
        [[TWAudioController sharedController] setPadParameter:paramID withValue:[sourceDictionary[key] floatValue] atSourceIdx:sourceIdx inTime:0.0];
    }
}



- (NSString*)keyForOscParamID:(TWOscParamID)paramID {
    
    NSString* key = nil;
    
    switch (paramID) {
        case TWOscParamID_OscWaveform:
            key = @"Osc Wave";
            break;
            
        case TWOscParamID_OscBaseFrequency:
            key = @"Osc Base Frequency";
            break;
            
        case TWOscParamID_OscBeatFrequency:
            key = @"Osc Beat Frequency";
            break;
            
        case TWOscParamID_OscAmplitude:
            key = @"Osc Amplitude";
            break;
            
        case TWOscParamID_OscDutyCycle:
            key = @"Osc Duty Cycle";
            break;
            
        case TWOscParamID_OscMononess:
            key = @"Osc Mononess";
            break;
            
        case TWOscParamID_OscSoftClipp:
            key = @"Osc Soft Clipp";
            break;
            
        case TWOscParamID_TremoloWaveform:
            key = @"Tremolo Waveform";
            break;
            
        case TWOscParamID_TremoloFrequency:
            key = @"Tremolo Frequency";
            break;
            
        case TWOscParamID_TremoloDepth:
            key = @"Tremolo Depth";
            break;
            
        case TWOscParamID_ShapeTremoloFrequency:
            key = @"Shape Tremolo Frequency";
            break;
            
        case TWOscParamID_ShapeTremoloDepth:
            key = @"Shape Tremolo Depth";
            break;
            
        case TWOscParamID_ShapeTremoloSoftClipp:
            key = @"Shape Tremolo Soft Clipp";
            break;
            
        case TWOscParamID_FilterEnable:
            key = @"Filter Enable";
            break;
            
        case TWOscParamID_FilterType:
            key = @"Filter Type";
            break;
            
        case TWOscParamID_FilterCutoff:
            key = @"Filter Cutoff";
            break;
            
        case TWOscParamID_FilterResonance:
            key = @"Filter Q";
            break;
            
        case TWOscParamID_FilterGain:
            key = @"Filter G";
            break;
            
        case TWOscParamID_FilterLFOEnable:
            key = @"Filter LFO Enable";
            break;
            
        case TWOscParamID_FilterLFOWaveform:
            key = @"Filter LFO Waveform";
            break;
            
        case TWOscParamID_FilterLFOFrequency:
            key = @"Filter LFO Rate";
            break;
            
        case TWOscParamID_FilterLFORange:
            key = @"Filter LFO Range";
            break;
            
        case TWOscParamID_FilterLFOOffset:
            key = @"Filter LFO Offset";
            break;
            
        case TWOscParamID_OscFMAmount:
            key = @"Osc FM Amount";
            break;
            
        case TWOscParamID_OscFMFrequency:
            key = @"Osc FM Frequency";
            break;
            
        case TWOscParamID_OscFMWaveform:
            key = @"Osc FM Waveform";
            break;
            
        default:
            key = nil;
            break;
    }
    
    return key;
}


- (NSString*)keyForSeqParamID:(TWSeqParamID)paramID {
    
    NSString* key = nil;
    
    switch (paramID) {
        case TWSeqParamID_AmpAttackTime:
            key = @"AmpAttackTime_ms";
            break;
            
        case TWSeqParamID_AmpSustainTime:
            key = @"AmpSustainTime_ms";
            break;
            
        case TWSeqParamID_AmpReleaseTime:
            key = @"AmpReleaseTime_ms";
            break;
            
        case TWSeqParamID_FilterEnable:
            key = @"FltEnable";
            break;
            
        case TWSeqParamID_FilterType:
            key = @"FltType";
            break;
            
        case TWSeqParamID_FilterAttackTime:
            key = @"FltAttackTime_ms";
            break;
            
        case TWSeqParamID_FilterSustainTime:
            key = @"FltSustainTime_ms";
            break;
            
        case TWSeqParamID_FilterReleaseTime:
            key = @"FltReleaseTime_ms";
            break;
            
        case TWSeqParamID_FilterFromCutoff:
            key = @"FltFromCutoff";
            break;
            
        case TWSeqParamID_FilterToCutoff:
            key = @"FltToCutoff";
            break;
            
        case TWSeqParamID_FilterResonance:
            key = @"FltQ";
            break;
            
        default:
            key = nil;
            break;
    }
    
    return key;
}

- (NSString*)keyForPadParamID:(TWPadParamID)paramID {
    
    NSString* key = nil;
    
    switch (paramID) {
        case TWPadParamID_DrumPadMode:
            key = @"Pad Mode";
            break;
            
        case TWPadParamID_MaxVolume:
            key = @"Pad Max Volume";
            break;
            
        case TWPadParamID_PlaybackDirection:
            key = @"Pad Direction";
            break;
            
        default:
            break;
    }
    
    return key;
}


- (void)setValueForTimeControl:(TWTimeRatioControl)control atSourceIdx:(int)sourceIdx {
    
    float numerator = (float)_timeControlRatios[control][kNumerator][sourceIdx];
    float denominator = (float)_timeControlRatios[control][kDenominator][sourceIdx];
    int rampTime_ms = (int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:sourceIdx];
    float value = 0.0f;
    
    switch (control) {
            
        case TWTimeRatioControl_BaseFrequency:
            value = _rootFrequency * numerator / denominator;
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBaseFrequency withValue:value atSourceIdx:sourceIdx inTime:rampTime_ms];
            break;
            
        case TWTimeRatioControl_BeatFrequency:
            value = (_tempo / 60.0f) * numerator / denominator;
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBeatFrequency withValue:value atSourceIdx:sourceIdx inTime:rampTime_ms];
            break;
            
        case TWTimeRatioControl_TremFrequency:
            value = (_tempo / 60.0f) * numerator / denominator;
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloFrequency withValue:value atSourceIdx:sourceIdx inTime:rampTime_ms];
            break;
            
        case TWTimeRatioControl_ShapeTremFrequency:
            value = (_tempo / 60.0f) * numerator / denominator;
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_ShapeTremoloFrequency withValue:value atSourceIdx:sourceIdx inTime:rampTime_ms];
            break;
            
        case TWTimeRatioControl_FilterLFOFrequency:
            value = (_tempo / 60.0f) * numerator / denominator;
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOFrequency withValue:value atSourceIdx:sourceIdx inTime:rampTime_ms];
            break;
    }
}


- (void)setSeqDurationFromTempo {
    float duration_ms = 60000.0f * _beatsPerBar / _tempo;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_Duration_ms withValue:duration_ms atSourceIdx:-1];
}



//#pragma mark - Drum Pad Projects
//
//- (BOOL)saveDrumPadProjectWithFilename:(NSString*)filename {
//
//}
//
//- (BOOL)loadDrumPadProjectWithFilename:(NSString*)filename {
//
//}
//
//- (NSArray<NSString*>*)getListOfSavedDrumPadProjects {
//
//}

- (void)resetFrequencyChartCaches {
    _equalTemperamentSelectedIndexPath = nil;
    _frequencyChartSelectedSegmentIndex = 0;
    _equalTemparementSelectedScrollPosition = CGPointMake(0.0f, 0.0f);
}

@end

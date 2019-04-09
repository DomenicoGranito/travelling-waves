//
//  TWMasterController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/21/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWMasterController.h"
#import "TWHeader.h"
#import "TWAudioController.h"

@interface TWMasterController()
{
    int         _tuningRatios[2][kNumSources];
}
@end



@implementation TWMasterController


- (id)init {
    
    if (self = [super init]) {
        
        // Create and initialize TWAudioController
        [TWAudioController sharedController];
        [self initializeDefaults];
        
        
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
    
    for (int idx=0; idx < kNumSources; idx++) {
        _tuningRatios[kNumerator][idx] = 1;
        _tuningRatios[kDenominator][idx] = 1;
        
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscBaseFrequency withValue:kDefaultFrequency atSourceIdx:idx inTime:0.0f];
    }
    _rootFrequency = kDefaultFrequency;
    _rampTime_ms = kDefaultRampTime_ms;
    
    
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscAmplitude withValue:kDefaultAmplitude atSourceIdx:0 inTime:0.0f];
    for (int idx=1; idx < kNumSources; idx++) {
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscAmplitude withValue:0.0f atSourceIdx:idx inTime:0.0f];
    }
}


#pragma mark - API

- (BOOL)isAudioRunning {
    return [[TWAudioController sharedController] isRunning];
}

- (void)setRootFrequency:(float)rootFrequency {
    _rootFrequency = rootFrequency;
    for (int idx=0; idx < kNumSources; idx++) {
        [self setFrequencyForRatioAt:idx];
    }
}

- (void)setRampTime_ms:(int)rampTime_ms {
    _rampTime_ms = rampTime_ms;
    for (int idx=0; idx < kNumSources; idx++) {
        [[TWAudioController sharedController] setRampTime:_rampTime_ms atSourceIdx:idx];
    }
}


- (int)incNumeratorRatioAt:(int)idx {
    ++_tuningRatios[kNumerator][idx];
    [self setFrequencyForRatioAt:idx];
    return _tuningRatios[kNumerator][idx];
}

- (int)decNumeratorRatioAt:(int)idx {
    if (--_tuningRatios[kNumerator][idx] <= 1) {
        _tuningRatios[kNumerator][idx] = 1;
    }
    [self setFrequencyForRatioAt:idx];
    return _tuningRatios[kNumerator][idx];
}



- (int)incDenominatorRatioAt:(int)idx {
    ++_tuningRatios[kDenominator][idx];
    [self setFrequencyForRatioAt:idx];
    return _tuningRatios[kDenominator][idx];
}

- (int)decDenominatorRatioAt:(int)idx {
    if (--_tuningRatios[kDenominator][idx] <= 1) {
        _tuningRatios[kDenominator][idx] = 1;
    }
    [self setFrequencyForRatioAt:idx];
    return _tuningRatios[kDenominator][idx];
}




- (void)setNumeratorRatio:(int)numerator at:(int)idx {
    _tuningRatios[kNumerator][idx] = numerator;
    [self setFrequencyForRatioAt:idx];

}

- (void)setDenominatorRatio:(int)denominator at:(int)idx {
    _tuningRatios[kDenominator][idx] = denominator;
    [self setFrequencyForRatioAt:idx];
}

- (int)getNumeratorRatioAt:(int)idx {
    return _tuningRatios[kNumerator][idx];
}

- (int)getDenominatorRatioAt:(int)idx {
    return _tuningRatios[kDenominator][idx];
}


- (void)setRootTempo:(float)rootTempo {
    _rootTempo = rootTempo;
}


#pragma mark - Project Parameter Saving

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

#pragma mark - Private

- (void)setFrequencyForRatioAt:(int)idx {
    float numerator = (float)_tuningRatios[kNumerator][idx];
    float denominator = (float)_tuningRatios[kDenominator][idx];;
    float frequency = _rootFrequency * numerator / denominator;
    float rampTime_ms = [[TWAudioController sharedController] getRampTimeAtSourceIdx:idx];
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscBaseFrequency withValue:frequency atSourceIdx:idx inTime:rampTime_ms];
}


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
        
        NSMutableArray* sources = [[NSMutableArray alloc] init];
        
        for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
            NSMutableDictionary* sourceParams = [[NSMutableDictionary alloc] init];
            sourceParams[@"Idx"] = @(sourceIdx);
            sourceParams[@"Tunings"] = @[@(_tuningRatios[kNumerator][sourceIdx]), @(_tuningRatios[kDenominator][sourceIdx])];
            for (int paramID = 1; paramID <= kOscNumParams; paramID++) {
                NSString* key = [self keyForOscParamID:paramID];
                sourceParams[key] = @([[TWAudioController sharedController] getOscParameter:paramID atSourceIdx:sourceIdx]);
            }
            sourceParams[@"RampTime_ms"] = @([[TWAudioController sharedController] getRampTimeAtSourceIdx:sourceIdx]);
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
            for (int paramID=0; paramID <= kSeqNumParams; paramID++) {
                NSString* key = [self keyForSeqParamID:paramID];
                envelope[key] = @([[TWAudioController sharedController] getSeqParameter:paramID atSourceIdx:sourceIdx]);
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
        sequencer[@"Duration_ms"] = @([[TWAudioController sharedController] getSeqDuration_ms]);
        
        parameters[@"Sequencer"] = sequencer;
        
        dictionary[@"Parameters"] = parameters;
    }
    
    return dictionary;
}

- (void)loadParametersFromDictionary:(NSDictionary*)dictionary {
    
    // Name
    _projectName = dictionary[@"Name"];
    
    // Parameters
    NSDictionary* parameters = dictionary[@"Parameters"];
    _rootFrequency = [parameters[@"Root Frequency"] floatValue];
    _rampTime_ms = [parameters[@"Base RampTime_ms"] intValue];
    
    int numSources = [parameters[@"Num Sources"] intValue];
    if (numSources > kNumSources) {
        numSources = kNumSources;
    }
    
    NSArray* sources = parameters[@"Sources"];
    NSDictionary* sequencer = parameters[@"Sequencer"];
    NSArray* envelopes = sequencer[@"Envelopes"];
    
    
    for (int sourceIdx=0; sourceIdx < numSources; sourceIdx++) {
        
        NSDictionary* sourceParams = sources[sourceIdx];
        _tuningRatios[kNumerator][sourceIdx] = [sourceParams[@"Tunings"][kNumerator] intValue];
        _tuningRatios[kDenominator][sourceIdx] = [sourceParams[@"Tunings"][kDenominator] intValue];
        
        float rampTime_ms = [[TWAudioController sharedController] getRampTimeAtSourceIdx:sourceIdx];
        
        for (int paramID = 1; paramID <= kOscNumParams; paramID++) {
            [self setOscParamValue:paramID fromDictionary:sourceParams atSourceIdx:sourceIdx inTime:rampTime_ms];
        }
        [self setFrequencyForRatioAt:sourceIdx];
        
        
        NSDictionary* envelope = envelopes[sourceIdx];
        if (envelope) {
            [[TWAudioController sharedController] setSeqInterval:[envelope[@"Interval"] intValue] atSourceIdx:sourceIdx];
            [[TWAudioController sharedController] setSeqEnabled:[envelope[@"Enable"] boolValue] atSourceIdx:sourceIdx];
            for (int paramID = 1; paramID <= kSeqNumParams; paramID++) {
                [self setSeqParamValue:paramID fromDictionary:envelope atSourceIdx:sourceIdx];
            }
        }
        
        rampTime_ms = [sourceParams[@"RampTime_ms"] intValue];
        [[TWAudioController sharedController] setRampTime:rampTime_ms atSourceIdx:sourceIdx];
    }
    
    if (sequencer) {
        [[TWAudioController sharedController] setSeqDuration_ms:[sequencer[@"Duration_ms"] floatValue]];
    }
    
    NSArray* events = sequencer[@"Events"];
    for (NSDictionary* event in events) {
        [[TWAudioController sharedController] setSeqNote:1 atSourceIdx:[event[@"Src"] intValue] atBeat:[event[@"Beat"] intValue]];
    }
}


- (void)loadOsterCurve {
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"OsterCurve" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    _osterCurve = [[NSArray alloc] initWithArray:dictionary[@"OsterCurve"]];
}






#pragma mark - Helper Methods


- (void)setOscParamValue:(int)paramID fromDictionary:(NSDictionary*)sourceDictionary atSourceIdx:(int)sourceIdx inTime:(float)rampTime_ms {
    NSString* key = [self keyForOscParamID:paramID];
    if ([sourceDictionary objectForKey:key]) {
        [[TWAudioController sharedController] setOscParameter:paramID withValue:[sourceDictionary[key] floatValue] atSourceIdx:sourceIdx inTime:rampTime_ms];
    }
}

- (void)setSeqParamValue:(int)paramID fromDictionary:(NSDictionary*)sourceDictionary atSourceIdx:(int)sourceIdx {
    NSString* key = [self keyForSeqParamID:paramID];
    if ([sourceDictionary objectForKey:key]) {
        [[TWAudioController sharedController] setSeqParameter:paramID withValue:[sourceDictionary[key] floatValue] atSourceIdx:sourceIdx];
    }
}



- (NSString*)keyForOscParamID:(int)paramID {
    
    NSString* key;
    
    switch (paramID) {
        case kOscParam_OscWaveform:
            key = @"Osc Wave";
            break;
            
        case kOscParam_OscBaseFrequency:
            key = @"Osc Base Frequency";
            break;
            
        case kOscParam_OscBeatFrequency:
            key = @"Osc Beat Frequency";
            break;
            
        case kOscParam_OscAmplitude:
            key = @"Osc Amplitude";
            break;
            
        case kOscParam_OscDutyCycle:
            key = @"Osc Duty Cycle";
            break;
            
        case kOscParam_OscMononess:
            key = @"Osc Mononess";
            break;
            
        case kOscParam_TremoloFrequency:
            key = @"Tremolo Frequency";
            break;
            
        case kOscParam_TremoloDepth:
            key = @"Tremolo Depth";
            break;
            
        case kOscParam_FilterEnable:
            key = @"Filter Enable";
            break;
            
        case kOscParam_FilterType:
            key = @"Filter Type";
            break;
            
        case kOscParam_FilterCutoff:
            key = @"Filter Cutoff";
            break;
            
        case kOscParam_FilterQ:
            key = @"Filter Q";
            break;
            
        case kOscParam_FilterGain:
            key = @"Filter G";
            break;
            
        case kOscParam_LFOEnable:
            key = @"Filter LFO Enable";
            break;
            
        case kOscParam_LFOFrequency:
            key = @"Filter LFO Rate";
            break;
            
        case kOscParam_LFORange:
            key = @"Filter LFO Range";
            break;
            
        case kOscParam_LFOOffset:
            key = @"Filter LFO Offset";
            break;
            
        default:
            key = @"Error";
            break;
    }
    
    return key;
}


- (NSString*)keyForSeqParamID:(int)paramID {
    
    NSString* key;
    
    switch (paramID) {
        case kSeqParam_AmpAttackTime:
            key = @"AmpAttackTime_ms";
            break;
            
        case kSeqParam_AmpSustainTime:
            key = @"AmpSustainTime_ms";
            break;
            
        case kSeqParam_AmpReleaseTime:
            key = @"AmpReleaseTime_ms";
            break;
            
        case kSeqParam_FltEnable:
            key = @"FltEnable";
            break;
            
        case kSeqParam_FltType:
            key = @"FltType";
            break;
            
        case kSeqParam_FltAttackTime:
            key = @"FltAttackTime_ms";
            break;
            
        case kSeqParam_FltSustainTime:
            key = @"FltSustainTime_ms";
            break;
            
        case kSeqParam_FltReleaseTime:
            key = @"FltReleaseTime_ms";
            break;
            
        case kSeqParam_FltFromCutoff:
            key = @"FltFromCutoff";
            break;
            
        case kSeqParam_FltToCutoff:
            key = @"FltToCutoff";
            break;
            
        case kSeqParam_FltQ:
            key = @"FltQ";
            break;
            
        default:
            key = @"Error";
            break;
    }
    
    return key;
}

@end

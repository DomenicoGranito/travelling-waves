//
//  TWMasterController.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/21/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWOscView.h"
#import "TWMixerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWMasterController : NSObject

+ (instancetype)sharedController;

- (BOOL)isAudioRunning;

@property (nonatomic, weak) NSArray<TWOscView*>* oscViews;
@property (nonatomic, weak) TWOscView* currentOscView;
@property (nonatomic, weak) TWMixerView* mixerView;

@property (nonatomic, assign) float rootFrequency;
@property (nonatomic, assign) float rootTempo;
@property (nonatomic, assign) int   rampTime_ms;

- (int)incNumeratorRatioAt:(int)idx;
- (int)decNumeratorRatioAt:(int)idx;
- (int)incDenominatorRatioAt:(int)idx;
- (int)decDenominatorRatioAt:(int)idx;

- (void)setNumeratorRatio:(int)ratio at:(int)idx;
- (void)setDenominatorRatio:(int)ratio at:(int)idx;
- (int)getNumeratorRatioAt:(int)idx;
- (int)getDenominatorRatioAt:(int)idx;


- (BOOL)saveProjectWithFilename:(NSString*)filename;
- (BOOL)loadProjectFromFilename:(NSString*)filename;
- (BOOL)deleteProjectWithFilename:(NSString*)filename;
- (NSArray<NSString*>*)getListOfSavedFilenames;
@property (nonatomic, readonly)NSString* projectsDirectory;
@property (nonatomic, strong)NSString* projectName;

@property (nonatomic, readonly)NSArray* osterCurve;

@end

NS_ASSUME_NONNULL_END

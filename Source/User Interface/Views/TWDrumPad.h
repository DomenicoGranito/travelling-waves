//
//  TWDrumPad.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/22/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWDrumPad : UIView

@property (nonatomic, assign) TWDrumPadMode drumPadMode;

@property (nonatomic, retain) NSString* titleText;

@property (nonatomic, retain) UIColor* onColor;

- (void)viewWillAppear;

- (void)playbackStopped:(int)status;

@end

NS_ASSUME_NONNULL_END

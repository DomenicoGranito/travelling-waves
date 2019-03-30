//
//  TWSlider.h
//  Travelling Waves
//
//  Created by Govinda Pingali on 2/17/16.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWSlider : UIControl

@property (nonatomic, assign) bool isHorizontal;

@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic) CGFloat value;
@property (nonatomic, retain) UIColor* onTrackColor;

@end

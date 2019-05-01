//
//  TWFillSlider.h
//  Travelling Waves
//
//  Created by Govinda Pingali on 2/17/16.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWFillSlider : UIControl

@property (nonatomic, assign) BOOL isHorizontal;
@property (nonatomic, assign) BOOL displayValueLabelInSlider;
//@property (nonatomic, assign) bool doubleTapValueEditor;

@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic) CGFloat value;

@property (nonatomic, retain) UIColor* onTrackColor;
@property (nonatomic, retain) UIColor* offTrackColor;
@property (nonatomic, retain) UIColor* valueLabelColor;

@property (nonatomic, assign) CGPoint UIFromTouchFrameInset;
@property (nonatomic, assign) CGFloat borderThickness;
@property (nonatomic, assign) CGFloat cornerRadius;

@end

//
//  TWDrumPad.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/22/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWDrumPad.h"
#import "TWAudioController.h"

#import <QuartzCore/QuartzCore.h>


@interface TWDrumPad()
{
    UILabel*                        _titleLabel;
    
    UIView*                         _touchView;
    UIView*                         _errorView;
    
    UIView*                         _hitView;
//    CAGradientLayer*                _hitViewGradient;
    
    TWTouchState                    _touchState;
    int                             _touchDownCount;
    BOOL                            _forceTouchAvailable;
    BOOL                            _toggleState;
    BOOL                            _touchesMovedIgnore;
}
@end



@implementation TWDrumPad

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [_titleLabel setTextColor:[UIColor colorWithWhite:0.2f alpha:0.5f]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setUserInteractionEnabled:NO];
    [self addSubview:_titleLabel];
    
    _touchView = [[UIView alloc] init];
    [_touchView setUserInteractionEnabled:NO];
    [_touchView setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    [_touchView setAlpha:0.0f];
    [self addSubview:_touchView];
    
    _errorView = [[UIView alloc] init];
    [_errorView setUserInteractionEnabled:NO];
    [_errorView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.1f blue:0.1f alpha:1.0f]];
    [_errorView setAlpha:0.0f];
    [self addSubview:_errorView];
    
//    _hitViewGradient = [CAGradientLayer layer];
//    NSArray* hitViewGradientColors = [NSArray arrayWithObjects:
//                                      [UIColor colorWithRed:0.75f green:0.15f blue:0.15f alpha:1.0f],
//                                      [UIColor colorWithWhite:0.5f alpha:1.0f],
//                                      nil];
//    [_hitViewGradient setColors:hitViewGradientColors];
//    [_hitViewGradient setType:kCAGradientLayerRadial];
    
    _hitView = [[UIView alloc] init];
    [_hitView setUserInteractionEnabled:NO];
    [_hitView setBackgroundColor:[UIColor colorWithRed:0.6f green:0.8f blue:0.15f alpha:0.6f]];
    [_hitView setAlpha:0.0f];
    [_hitView.layer setMasksToBounds:YES];
//    [_hitView.layer insertSublayer:_hitViewGradient atIndex:0];
    [self addSubview:_hitView];
    
    _touchState = TWTouchState_Up;
    _drumPadMode = TWDrumPadMode_OneShot;
    _toggleState = NO;
    _touchesMovedIgnore = NO;
    
    [self setMultipleTouchEnabled:YES];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0]];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        _forceTouchAvailable = (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable);
        _forceTouchAvailable = NO;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [_titleLabel setFrame:CGRectMake(0.0f, 0.0, frame.size.width, frame.size.height)];
    [_touchView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    [_errorView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
//    [_hitViewGradient setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    
    
    CGFloat hitViewMargin = 0.0f;
    
    CGFloat hitXPos = hitViewMargin * frame.size.width;
    CGFloat hitYPos = hitViewMargin * frame.size.height;
    CGFloat hitWidth = frame.size.width - (2.0f * hitXPos);
    CGFloat hitHeight = frame.size.width - (2.0f * hitYPos);
    CGFloat hitViewCornerRadius = hitViewMargin * frame.size.width;
    
    [_hitView.layer setCornerRadius:hitViewCornerRadius];
    [_hitView setFrame:CGRectMake(hitXPos, hitYPos, hitWidth, hitHeight)];
//    [_hitView.layer insertSublayer:_hitViewGradient atIndex:0];
}

- (void)viewWillAppear {
    _touchDownCount = 0;
    _touchState = TWTouchState_Up;
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    [_titleLabel setText:_titleText];
}

- (void)setOnColor:(UIColor *)onColor {
    _onColor = onColor;
    [_touchView setBackgroundColor:_onColor];
}

- (void)setDrumPadMode:(TWDrumPadMode)drumPadMode {
    _drumPadMode = drumPadMode;
    if (_drumPadMode != TWDrumPadMode_Toggle) {
        _toggleState = NO;
    }
    _touchesMovedIgnore = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - Touch Events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    _touchState = TWTouchState_Down;
    _touchDownCount++;
    
//    float velocity = 0.5f;
//    if (_forceTouchAvailable) {
//        UITouch* touch = [touches anyObject];
//        CGFloat force = touch.force;
//        NSLog(@"Began Touch Force: %f. Max: %f", force, touch.maximumPossibleForce);
//        velocity = force/touch.maximumPossibleForce;
//    }
    
    switch (_drumPadMode) {
            
        case TWDrumPadMode_Toggle:
            _toggleState = !_toggleState;
            if (_toggleState) {
                [[TWAudioController sharedController] startPlaybackAtSourceIdx:(int)self.tag atSampleTime:0];
                [_touchView setAlpha:1.0f];
            } else {
                [[TWAudioController sharedController] stopPlaybackAtSourceIdx:(int)self.tag fadeOutTime:kAudioFilePlaybackFadeOutTime_ms];
                [_touchView setAlpha:0.0f];
            }
            break;
            
        case TWDrumPadMode_OneShot:
            _touchesMovedIgnore = NO;
        case TWDrumPadMode_Momentary:
            [[TWAudioController sharedController] startPlaybackAtSourceIdx:(int)self.tag atSampleTime:0];
            [_touchView setAlpha:1.0f];
            break;
            
        default:
            break;
    }
    
    [_hitView setAlpha:1.0f];
    [UIView animateWithDuration:kHitFlashTime_s delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self->_hitView setAlpha:0.0f];
    } completion:^(BOOL finished) {}];
    
//    for (UITouch* touch in touches) {
//        NSLog(@"Began Touch: %@", touch);
//    }
//    NSLog(@"Began Event: %@", event);
    
//    [_forceView setFrame:_forceViewCenterRect];

//    if (!_forceTouchAvailable) {
//        _longPressTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressInterval_s repeats:YES block:^(NSTimer * _Nonnull timer) {
//            self->_longPressElapsedTime += kLongPressInterval_s;
//            [self processNormalizedForce:self->_longPressElapsedTime / kLongPressTime_s];
//        }];
//    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_touchesMovedIgnore) {
        return;
    }
    
    if ((_drumPadMode == TWDrumPadMode_Toggle) && (!_toggleState)) {
        return;
    }
    
    CGFloat velocity = 1.0f;
    
    if (_forceTouchAvailable) {
        UITouch* touch = [touches anyObject];
        CGFloat force = touch.force;
//        NSLog(@"Moved Touch Force: %f. Max: %f", force, touch.maximumPossibleForce);
        velocity = (force/touch.maximumPossibleForce);
    }
    
    
//    [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_Velocity withValue:velocity atSourceIdx:(int)self.tag inTime:10.0f];
    [_touchView setAlpha:velocity];
    
    
    
    
    
//    for (UITouch* touch in touches) {
//        NSLog(@"Moved Touch: %@", touch);
//    }
//    NSLog(@"Moved Event: %@", event);
    
//    if (_ignoreEvents) {
//        return;
//    }
//
//    if (!_forceTouchAvailable) {
//        return;
//    }
//
//    UITouch* touch = [touches anyObject];
//    CGFloat force = touch.force;
//    [self processNormalizedForce:force/touch.maximumPossibleForce];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    _touchDownCount--;
    if (_touchDownCount > 0) {
        return;
    }
    
    _touchState = TWTouchState_Up;
    _touchDownCount = 0;
    
    switch (_drumPadMode) {
            
        case TWDrumPadMode_Momentary:
            [[TWAudioController sharedController] stopPlaybackAtSourceIdx:(int)self.tag fadeOutTime:kAudioFilePlaybackFadeOutTime_ms];
            [_touchView setAlpha:0.0f];
            break;
            
        case TWDrumPadMode_OneShot:
        case TWDrumPadMode_Toggle:
            break;
            
        default:
            break;
    }
    
    
//    for (UITouch* touch in touches) {
//        NSLog(@"Ended Touch: %@", touch);
//    }
//    NSLog(@"Ended Event: %@", event);
    
//    if (!_forceTouchAvailable) {
//        _longPressElapsedTime = 0.0f;
//        [_longPressTimer invalidate];
//    }
//
//    if (!_ignoreEvents) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(forceButtonTouchUpInside:)]) {
//            [_delegate forceButtonTouchUpInside:self];
//        }
//    }
//    _ignoreEvents = NO;
//    [_forceView setFrame:CGRectZero];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (UITouch* touch in touches) {
//        NSLog(@"Cancelled Touch: %@", touch);
//    }
//    NSLog(@"Cancelled Event: %@", event);
    _touchDownCount = 0;
    _touchState = TWTouchState_Up;
}



- (void)playbackStopped:(int)status {
    
    if (_drumPadMode == TWDrumPadMode_OneShot) {
        [_touchView setAlpha:0.0f];
        _touchesMovedIgnore = YES;
    }
    
    
    BOOL success = YES;
    switch ((TWPlaybackFinishedStatus)status) {
        case TWPlaybackFinishedStatus_NoIORunning:
            [_errorView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.9f blue:0.1f alpha:1.0f]];
            _touchesMovedIgnore = YES;
            success = false;
            break;
            
        case TWPlaybackFinishedStatus_Uninitialized:
            [_errorView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.1f blue:0.1f alpha:1.0f]];
            _touchesMovedIgnore = YES;
            success = false;
            break;
            
        default:
            _touchesMovedIgnore = NO;
            break;
    }
    
    if (!success) {
        [_touchView setAlpha:0.0f];
        [_errorView setAlpha:1.0f];
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self->_errorView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            
        }];
    }
}

@end

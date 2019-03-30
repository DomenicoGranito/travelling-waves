//
//  TWDrumPad.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/22/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWDrumPad.h"
#import "TWAudioController.h"

@interface TWDrumPad()
{
    UILabel*                        _titleLabel;
    UIView*                         _touchView;
    TWTouchState                    _touchState;
    BOOL                            _forceTouchAvailable;
    BOOL                            _toggleState;
    BOOL                            _oneShotTouchIgnore;
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

    _touchState = TWTouchState_Up;
    _drumPadMode = TWDrumPadMode_OneShot;
    _toggleState = NO;
    _oneShotTouchIgnore = NO;
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0]];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        _forceTouchAvailable = (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable);
//        _forceTouchAvailable = NO;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [_titleLabel setFrame:CGRectMake(0.0f, 0.0, frame.size.width, frame.size.height)];
    [_touchView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
}

- (void)viewWillAppear {
    
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
    _oneShotTouchIgnore = NO;
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
                [[TWAudioController sharedController] stopPlaybackAtSourceIdx:(int)self.tag];
                [_touchView setAlpha:0.0f];
            }
            break;
            
        case TWDrumPadMode_OneShot:
            _oneShotTouchIgnore = NO;
        case TWDrumPadMode_Momentary:
            [[TWAudioController sharedController] startPlaybackAtSourceIdx:(int)self.tag atSampleTime:0];
            [_touchView setAlpha:1.0f];
            break;
            
        default:
            break;
    }
    
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
    
    if (_oneShotTouchIgnore) {
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
    
    _touchState = TWTouchState_Up;
    
    switch (_drumPadMode) {
            
        case TWDrumPadMode_Momentary:
            [[TWAudioController sharedController] stopPlaybackAtSourceIdx:(int)self.tag];
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
}



- (void)oneShotPlaybackStopped {
    if (_drumPadMode == TWDrumPadMode_OneShot) {
        [_touchView setAlpha:0.0f];
        _oneShotTouchIgnore = YES;
    }
}

@end

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


static const CGFloat kHitViewAreaInset                  = 0.05f;
static const CGFloat kTickViewWidth                     = 2.0f;
static const CGFloat kSourceIdxLabelSizeFraction        = 0.2f; // Fraction of frame
static const CGFloat kFileTitleLabelWidthFraction       = 1.0f; // Fraction of width
static const CGFloat kFileTitleLabelHeightFraction      = 0.2f; // Fraction of height

@implementation TWHitView

- (void)drawRect:(CGRect)rect {

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // Add the outer arc to the path (as if you wanted to fill the entire circle)
    CGPathMoveToPoint(path, nil, 0.0f, 0.0f);
    CGPathAddRect(path, nil, CGRectMake(0.0f, 0.0f, width, height));
    CGPathCloseSubpath(path);
    
    // Add the inner arc to the path (later used to substract the inner area)
    CGFloat xPos1 = (kHitViewAreaInset / 2.0f) * width;
    CGFloat yPos1 = (kHitViewAreaInset / 2.0f) * height;
    CGFloat inWidth = width * (1.0f - kHitViewAreaInset);
    CGFloat inHeight = height *  (1.0f - kHitViewAreaInset);
    CGPathMoveToPoint(path, nil, xPos1, yPos1);
    CGPathAddRect(path, nil, CGRectMake(xPos1, yPos1, inWidth, inHeight));
    CGPathCloseSubpath(path);
    
    // Add the path to the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path);
    
    // Fill the path using the even-odd fill rule
    CGContextSetGrayFillColor(context, 0.12, 1.0f);
    CGContextEOFillPath(context);
    
    CGPathRelease(path);
}

@end



@implementation TWTickView

- (void)drawRect:(CGRect)rect {
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake((rect.size.width - kTickViewWidth) / 2.0f, 0.0f, kTickViewWidth, rect.size.height / 2.0f)];
    [[UIColor colorWithWhite:0.4f alpha:0.8f] set];
    [path fill];
}

@end



@interface TWDrumPad()
{
    BOOL                            _forceTouchAvailable;
    
    UILabel*                        _sourceIdxLabel;
    UILabel*                        _fileTitleLabel;
    
    UIView*                         _touchView;
    UIView*                         _errorView;
    
    TWHitView*                      _hitView;
    
    TWTickView*                     _tickView;
    
    TWTouchState                    _touchState;
    
    int                             _touchDownCount;
    BOOL                            _toggleState;
    BOOL                            _touchesMovedIgnore;
    
    TWPlaybackStatus                _playbackStatus;
    
    BOOL                            _initTime;
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
    
    _initTime   = YES;
    
    _touchView = [[UIView alloc] init];
    [_touchView setUserInteractionEnabled:NO];
    [_touchView setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    [_touchView setAlpha:0.0f];
    [self addSubview:_touchView];
    
    _tickView = [[TWTickView alloc] init];
    [_tickView setUserInteractionEnabled:NO];
    [_tickView setBackgroundColor:[UIColor clearColor]];
    [_tickView setAlpha:0.0f];
    [self addSubview:_tickView];
    
    _errorView = [[UIView alloc] init];
    [_errorView setUserInteractionEnabled:NO];
    [_errorView setBackgroundColor:[UIColor colorWithRed:1.0f green:0.1f blue:0.1f alpha:1.0f]];
    [_errorView setAlpha:0.0f];
    [self addSubview:_errorView];
    
    _sourceIdxLabel = [[UILabel alloc] init];
    [_sourceIdxLabel setTextAlignment:NSTextAlignmentCenter];
    [_sourceIdxLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_sourceIdxLabel setTextColor:[UIColor colorWithWhite:0.1f alpha:0.5f]];
    [_sourceIdxLabel setBackgroundColor:[UIColor clearColor]];
    [_sourceIdxLabel setUserInteractionEnabled:NO];
    [self addSubview:_sourceIdxLabel];
    
    _fileTitleLabel = [[UILabel alloc] init];
    [_fileTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [_fileTitleLabel setFont:[UIFont systemFontOfSize:8.0f]];
    [_fileTitleLabel setTextColor:[UIColor colorWithWhite:0.1f alpha:0.45f]];
    [_fileTitleLabel setBackgroundColor:[UIColor clearColor]];
    [_fileTitleLabel setUserInteractionEnabled:NO];
    [self addSubview:_fileTitleLabel];
    
    _hitView = [[TWHitView alloc] init];
    [_hitView setUserInteractionEnabled:NO];
    [_hitView setBackgroundColor:[UIColor clearColor]];
    [_hitView setAlpha:0.0f];
    [self addSubview:_hitView];
    
    _touchState = TWTouchState_Up;
    _drumPadMode = TWDrumPadMode_OneShot;
    _playbackDirection = TWPlaybackDirection_Forward;
    _toggleState = NO;
    _touchesMovedIgnore = NO;
    _lengthInSeconds = 0.0f;
    _playbackStatus = TWPlaybackStatus_Uninitialized;
    
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
    
    CGFloat sourceIdxLabelWidth = frame.size.width * kSourceIdxLabelSizeFraction;
    CGFloat sourceIdxLabelHeight = frame.size.height * kSourceIdxLabelSizeFraction;
    CGFloat sourceIdxLabelXPos = frame.size.width - sourceIdxLabelWidth;
    CGFloat sourceIdxLabelYPos = 0.0f;
    [_sourceIdxLabel setFrame:CGRectMake(sourceIdxLabelXPos, sourceIdxLabelYPos, sourceIdxLabelWidth, sourceIdxLabelHeight)];
    
    CGFloat fileTitleLabelWidth = frame.size.width * kFileTitleLabelWidthFraction;
    CGFloat fileTitleLabelHeight = frame.size.height * kFileTitleLabelHeightFraction;
    CGFloat fileTitleLabelXPos = 4.0f;
    CGFloat fileTitleLabelYPos = frame.size.height - fileTitleLabelHeight;
    [_fileTitleLabel setFrame:CGRectMake(fileTitleLabelXPos, fileTitleLabelYPos, fileTitleLabelWidth, fileTitleLabelHeight)];
    
    [_touchView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    [_errorView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    [_hitView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    [_tickView setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
}


- (void)viewWillAppear {
    
    _initTime = YES;
    
    _touchDownCount = 0;
    _touchState = TWTouchState_Up;
    
    _drumPadMode = (TWDrumPadMode)[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_DrumPadMode atSourceIdx:(int)self.tag];
    
    _playbackDirection = (TWPlaybackDirection)[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_PlaybackDirection atSourceIdx:(int)self.tag];
    
    _playbackStatus = [[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_PlaybackStatus atSourceIdx:(int)self.tag];
    if (_playbackStatus == TWPlaybackStatus_Playing) {
        [_touchView setAlpha:1.0f];
        if (_drumPadMode == TWDrumPadMode_Toggle) {
            _toggleState = YES;
        }
    } else {
        [_touchView setAlpha:0.0f];
    }
    
    _lengthInSeconds = [[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_LengthInSeconds atSourceIdx:(int)self.tag];
    
    [self stopProgressAnimation];
}

- (void)viewDidAppear {
    _initTime = NO;
    if (_playbackStatus == TWPlaybackStatus_Playing) {
        [self startProgressAnimation];
    }
}


- (void)viewWillDisappear {
    [self stopProgressAnimation];
}

- (void)setFileTitleText:(NSString *)fileTitleText {
    _fileTitleText = fileTitleText;
    [_fileTitleLabel setText:_fileTitleText];
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    [_sourceIdxLabel setText:[NSString stringWithFormat:@"%d", (int)tag+1]];
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
    if (_playbackStatus == TWPlaybackStatus_Playing) {
        [self stopProgressAnimation];
        [self startProgressAnimation];
    }
}

- (void)setPlaybackDirection:(TWPlaybackDirection)playbackDirection {
    _playbackDirection = playbackDirection;
    if (_playbackStatus == TWPlaybackStatus_Playing) {
        [self stopProgressAnimation];
        [self startProgressAnimation];
    }
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
                _playbackStatus = TWPlaybackStatus_Playing;
                [self startProgressAnimation];
            } else {
                [[TWAudioController sharedController] stopPlaybackAtSourceIdx:(int)self.tag fadeOutTime:kAudioFilePlaybackFadeOutTime_ms];
                [_touchView setAlpha:0.0f];
                _playbackStatus = TWPlaybackStatus_Stopped;
                [self stopProgressAnimation];
            }
            break;
            
        case TWDrumPadMode_OneShot:
            _touchesMovedIgnore = NO;
        case TWDrumPadMode_Momentary:
            [[TWAudioController sharedController] startPlaybackAtSourceIdx:(int)self.tag atSampleTime:0];
            [_touchView setAlpha:1.0f];
            _playbackStatus = TWPlaybackStatus_Playing;
            [self startProgressAnimation];
            break;
            
        default:
            break;
    }
    
    
    [_hitView setAlpha:1.0f];
    [UIView animateWithDuration:kHitFlashTime_s delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self->_hitView setAlpha:0.0f];
    } completion:^(BOOL finished) {}];
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
            _playbackStatus = TWPlaybackStatus_Stopped;
            [self stopProgressAnimation];
            break;
            
        case TWDrumPadMode_OneShot:
        case TWDrumPadMode_Toggle:
            break;
            
        default:
            break;
    }
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
        _playbackStatus = TWPlaybackStatus_Stopped;
        [self stopProgressAnimation];
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
        _playbackStatus = TWPlaybackStatus_Uninitialized;
        [self stopProgressAnimation];
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self->_errorView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            
        }];
    }
}


//- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat {
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
//    rotationAnimation.duration = duration;
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = repeat ? HUGE_VALF : 0;
//
//    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
//}

- (void)startProgressAnimation {
    
    if (_initTime) {
        return;
    }
    
    [_tickView setAlpha:1.0f];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    float normalizedProgress = [[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_NormalizedProgress atSourceIdx:(int)self.tag];
    
    
    NSNumber* fromValue;
    NSNumber* toValue;
    
    switch (_playbackDirection) {
        case TWPlaybackDirection_Forward:
            fromValue = [NSNumber numberWithFloat:(2.0f * M_PI * normalizedProgress)];
            toValue = [NSNumber numberWithFloat:(2.0f * M_PI) * (1.0f + normalizedProgress)];
            break;
            
        case TWPlaybackDirection_Reverse:
            fromValue = [NSNumber numberWithFloat:(2.0f * M_PI * normalizedProgress)];
            toValue = [NSNumber numberWithFloat:(-2.0f * M_PI * (1 - normalizedProgress))];
            break;
            
        default:
            break;
    }
    
    float repeatCount = HUGE_VALF;
    switch (_drumPadMode) {
        case TWDrumPadMode_OneShot:
            repeatCount = 0.0f;
            break;
        default:
            break;
    }
    
//    NSLog(@"startProgressAnimation : from(%f), to(%f), duration(%f), repeat(%f)", [fromValue floatValue], [toValue floatValue], _lengthInSeconds, repeatCount);
    
    rotationAnimation.fromValue = fromValue;
    rotationAnimation.toValue = toValue;
    rotationAnimation.duration = _lengthInSeconds;
    rotationAnimation.cumulative = NO;
    rotationAnimation.repeatCount = repeatCount;
    
    [_tickView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopProgressAnimation {
    [_tickView.layer removeAllAnimations];
    [_tickView setAlpha:0.0f];
}

@end

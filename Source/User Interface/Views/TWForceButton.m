//
//  TWForceButton.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/15/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWForceButton.h"

static const CGFloat kTextLabelMargin       = 2.0f;
static const CGFloat kLongPressTime_s       = 1.0f;
static const CGFloat kLongPressInterval_s   = 0.05f;

typedef enum {
    TouchState_Up,
    TouchState_Down
} TWTouchState;

@interface TWForceButton()
{
    TWTouchState                    _touchState;
    BOOL                            _ignoreEvents;
    UIImpactFeedbackGenerator*      _feedbackGenerator;
    
    CGRect                          _forceViewCenterRect;
    UIView*                         _forceView;
    
    BOOL                            _forceTouchAvailable;
    NSTimer*                        _longPressTimer;
    float                           _longPressElapsedTime;
}
@end


@implementation TWForceButton

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _selected = NO;
    _touchState = TouchState_Up;
    _ignoreEvents = NO;
    
    _defaultBackgroundColor = [[UIColor alloc] initWithWhite:0.0f alpha:1.0f];
    _selectedBackgroundColor = [[UIColor alloc] initWithWhite:0.5f alpha:1.0f];
    
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_titleLabel];
    
    _forceView = [[UILabel alloc] init];
    [_forceView setUserInteractionEnabled:NO];
//    [_forceView setBackgroundColor:_selectedBackgroundColor];
    [_forceView setBackgroundColor:[UIColor colorWithRed:0.4f green:0.1f blue:0.1 alpha:0.2f]];
    [self addSubview:_forceView];
    
    _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    
    _forceTouchAvailable = (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable);
    _longPressElapsedTime = 0.0f;
//    NSLog(@"ForceTouchAvailable: %d", _forceTouchAvailable);
    
    [self setBackgroundColor:_defaultBackgroundColor];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_titleLabel setFrame:CGRectMake(kTextLabelMargin, kTextLabelMargin, frame.size.width - (2.0f * kTextLabelMargin), frame.size.height - (2.0f * kTextLabelMargin))];
    
    _forceViewCenterRect = CGRectMake(frame.size.width / 2.0f, frame.size.height / 2.0f, 0.0f, 0.0f);
    [_forceView setFrame:_forceViewCenterRect];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setBackgroundColor:(selected ? _selectedBackgroundColor : _defaultBackgroundColor)];
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
//    [_forceView setBackgroundColor:_selectedBackgroundColor];
}


#pragma mark - Touch Events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchState = TouchState_Down;
    [_feedbackGenerator prepare];
    [_forceView setFrame:_forceViewCenterRect];
    
    if (!_forceTouchAvailable) {
        _longPressTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressInterval_s repeats:YES block:^(NSTimer * _Nonnull timer) {
            self->_longPressElapsedTime += kLongPressInterval_s;
            [self processNormalizedForce:self->_longPressElapsedTime / kLongPressTime_s];
        }];
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (_ignoreEvents) {
        return;
    }
    
    if (!_forceTouchAvailable) {
        return;
    }
    
    UITouch* touch = [touches anyObject];
    CGFloat force = touch.force;
    [self processNormalizedForce:force/touch.maximumPossibleForce];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (!_forceTouchAvailable) {
        _longPressElapsedTime = 0.0f;
        [_longPressTimer invalidate];
    }
    
    if (!_ignoreEvents) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(forceButtonTouchUpInside:)]) {
            [_delegate forceButtonTouchUpInside:self];
        }
    }
    _ignoreEvents = NO;
    [_forceView setFrame:CGRectZero];
}


- (void)processNormalizedForce:(CGFloat)normalizedForce {
    
    __block UIView* forceView = _forceView;
    __block CGRect newFrame = CGRectInset(_forceViewCenterRect, -normalizedForce * self.frame.size.width / 2.0f, -normalizedForce * self.frame.size.height / 2.0f);
    
    [UIView animateWithDuration:0.001f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        [forceView setFrame:newFrame];
    } completion:^(BOOL finished) {}];
    
    if (normalizedForce >= 1.0f) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(forceButtonForcePressDown:)]) {
            [_delegate forceButtonForcePressDown:self];
            [_feedbackGenerator impactOccurred];
            [_forceView setFrame:_forceViewCenterRect];
            
            if (!_forceTouchAvailable) {
                _longPressElapsedTime = 0.0f;
                [_longPressTimer invalidate];
            }
        }
        
        _ignoreEvents = YES;
    }
}

@end

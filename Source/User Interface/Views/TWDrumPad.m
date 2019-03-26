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
    UILabel*        _titleLabel;
    TWTouchState    _touchState;
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
    [_titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_titleLabel setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setUserInteractionEnabled:NO];
    [self addSubview:_titleLabel];

    _touchState = TWTouchState_Up;
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0]];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [_titleLabel setFrame:CGRectMake(0.0f, 0.0, frame.size.width, frame.size.height)];
}

- (void)viewWillAppear {
    
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    [_titleLabel setText:_titleText];
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
    [[TWAudioController sharedController] startPlaybackAtSourceIdx:(int)self.tag atSampleTime:0];
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
    [[TWAudioController sharedController] stopPlaybackAtSourceIdx:(int)self.tag];
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


@end

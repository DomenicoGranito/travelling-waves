//
//  TWCycleStateButton.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/28/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWCycleStateButton.h"


@interface TWCycleStateButton ()
{
    NSUInteger     _maxNumberOfStates;
}
@end


@implementation TWCycleStateButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithNumberOfStates:(NSUInteger)numberOfStates {
    if (self = [super init]) {
        _maxNumberOfStates = numberOfStates;
        _currentState = 0;
        _stateTitles = nil;
        _stateColors = nil;
    }
    return self;
}


- (void)setStateColors:(NSArray<UIColor *> *)stateColors {
    NSAssert([stateColors count] == _maxNumberOfStates, @"setStateColors: array size must be equal to init number of states!");
    _stateColors = stateColors;
}


- (void)setStateTitles:(NSArray<NSString *> *)stateTitles {
    NSAssert([stateTitles count] == _maxNumberOfStates, @"setStateTitles: array size must be equal to init number of states!");
    _stateTitles = stateTitles;
}


- (void)incrementState {
    if (_maxNumberOfStates <= 0) {
        return;
    }
    _currentState = (_currentState + 1) % _maxNumberOfStates;
    [self _updateUIFromCurrentState];
}


- (void)decrementState {
    if (_maxNumberOfStates <= 0) {
        return;
    }
    _currentState = (_currentState - 1) % _maxNumberOfStates;
    [self _updateUIFromCurrentState];
}


- (void)setCurrentState:(NSUInteger)currentState {
    _currentState = currentState;
    [self _updateUIFromCurrentState];
}



- (void)_updateUIFromCurrentState {
    
    UIColor* backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    if (_stateColors != nil) {
        backgroundColor = (UIColor*)[_stateColors objectAtIndex:_currentState];
    }
    
    NSString* titleText = @"";
    if (_stateTitles != nil) {
        titleText = (NSString*)[_stateTitles objectAtIndex:_currentState];
    }
    
    [self setBackgroundColor:backgroundColor];
    [self setTitle:titleText forState:UIControlStateNormal];
}

@end

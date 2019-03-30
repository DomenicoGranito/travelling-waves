//
//  TWCycleStateButton.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/28/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface TWCycleStateButton : UIButton

- (instancetype)initWithNumberOfStates:(NSUInteger)numberOfStates;

@property (nonatomic, retain) NSArray <UIColor * > * stateColors;
@property (nonatomic, retain) NSArray <NSString * > * stateTitles;
@property (nonatomic, readwrite) NSUInteger currentState;

- (void)incrementState;
- (void)decrementState;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

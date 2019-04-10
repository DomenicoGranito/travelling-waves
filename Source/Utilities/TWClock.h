//
//  TWClock.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWClock : NSObject

+ (instancetype)sharedClock;

- (NSTimeInterval)getCurrentTime;

@end

NS_ASSUME_NONNULL_END

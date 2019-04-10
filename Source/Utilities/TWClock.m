//
//  TWClock.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWClock.h"

#include <mach/mach.h>
#include <mach/mach_time.h>


@interface TWClock()
{
    mach_timebase_info_data_t       _clock_timebase;
}
@end


@implementation TWClock

- (instancetype)init {
    if (self = [super init]) {
        mach_timebase_info(&_clock_timebase);
    }
    return self;
}


+ (instancetype)sharedClock {
    static dispatch_once_t onceToken;
    static TWClock* clock;
    dispatch_once(&onceToken, ^{
        clock = [[TWClock alloc] init];
    });
    return clock;
}


- (NSTimeInterval)getCurrentTime {
    uint64_t machtime = mach_absolute_time();
    return [self machAbsoluteToTimeInterval:machtime];
}

- (NSTimeInterval)machAbsoluteToTimeInterval:(uint64_t)machAbsolute {
    uint64_t nanos = (machAbsolute * _clock_timebase.numer) / _clock_timebase.denom;
    return nanos/1.0e9;
}

@end

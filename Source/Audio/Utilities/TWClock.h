//
//  TWClock.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWClock_h
#define TWClock_h

#include <stdio.h>

#include <mach/mach.h>
#include <mach/mach_time.h>

class TWClock {
    
    
public:
    
    TWClock();
    ~TWClock();
    
    float getCurrentAbsoluteTimeInSeconds();
    
private:
    mach_timebase_info_data_t       _clock_timebase;
    float _machAbsoluteTimeToSeconds(uint64_t machAbsoulteTime);
};

#endif /* TWClock_hpp */

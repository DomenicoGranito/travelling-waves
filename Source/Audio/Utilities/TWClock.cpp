//
//  TWClock.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWClock.h"


TWClock::TWClock()
{
    mach_timebase_info(&_clock_timebase);
}

TWClock::~TWClock()
{
    
}


float TWClock::getCurrentAbsoluteTimeInSeconds()
{
    uint64_t machtime = mach_absolute_time();
    return _machAbsoluteTimeToSeconds(machtime);
}

float TWClock::_machAbsoluteTimeToSeconds(uint64_t machAbsoulteTime)
{
    uint64_t nanos = (machAbsoulteTime * _clock_timebase.numer) / _clock_timebase.denom;
    return nanos/1.0e9;
}

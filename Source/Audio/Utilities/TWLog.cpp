//
//  TWLog.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/16/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#include "TWLog.h"
#include <cstdarg>


void TWLog::Log(TWLog::Scope scope, const char *format, ...)
{
    switch (scope) {
            
        case LOG_ERROR:
        case LOG_NOTICE:
        {
            va_list argptr;
            va_start(argptr, format);
            vfprintf(stderr, format, argptr);
            va_end(argptr);
        }
            break;
            
        default:
            break;
    }
}

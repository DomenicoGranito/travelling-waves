//
//  TWLog.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/16/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWLog_h
#define TWLog_h

#include <stdio.h>


class TWLog {
    
public:
    
    typedef enum {
        LOG_ERROR       = 0,
        LOG_WARNING     = 1,
        LOG_NOTICE      = 2,
        LOG_DEBUG       = 3
    } Scope;
    
    static void Log(TWLog::Scope scope, const char * format, ...);
    
};
#endif /* TWLog_h */

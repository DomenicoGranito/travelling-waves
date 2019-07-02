//
//  TWParameter.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWParameter_h
#define TWParameter_h

#include <stdio.h>


class TWParameter {
    
public:
    
    TWParameter();
    ~TWParameter();
    
    void setTargetValue(float targetValue, double rampTimeInSamples);
    float getTargetValue();
    
    float getCurrentValue();
    
    void setIsRunning(bool isRunning);
    bool getIsRunning();
    
    void setParameterID(int paramID);
    int getParameterID();
    
private:
    
    float       _targetValue;
    float       _rampTimeInSamples;
    
    float       _currentValue;
    float       _increment;
    
    bool        _isRunning;
    int         _paramID;
    
    int         _debugPrintCount;
    void        _debugPrint();
};

#endif /* TWParameter_h */

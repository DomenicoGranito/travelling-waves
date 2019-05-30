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
    
    void setParameterID(int parameterID);
    int getParameterID();
    
    void setTargetValue(float targetValue, float rampTimeInSamples);
    float getTargetValue();
    
    float getCurrentValue();
    
    void setMaxValue(float maxValue);
    float getMaxValue();
    
    void setMinValue(float minValue);
    float getMinValue();
    
    void updateDefaultValue(float defaultValue);
    float getDefaultValue();
    void setDefaultValue(float rampTimeInSamples);
    
    void setIsIORunning(bool isIORunning);
    bool getIsIORunning();
    
    
private:
    
    float       _targetValue;
    float       _rampTimeInSamples;
    
    float       _maxValue;
    float       _minValue;
    
    float       _defaultValue;
    
    float       _currentValue;
    float       _increment;
    
    bool        _isIORunning;
    int         _parameterID;
    
    int         _debugPrintCount;
    void        _debugPrint();
};

#endif /* TWParameter_h */

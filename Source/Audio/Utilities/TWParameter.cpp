//
//  TWParameter.cpp
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/23/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#include "TWParameter.h"
#include <math.h>

#define kDebugPrintSamples          100

#define DEBUG_PRINT_ParamID_55      0
#define DEBUG_PRINT_ParamID_99      0
#define DEBUG_PRINT_ParamID_66      0

TWParameter::TWParameter()
{
    _minValue           = 0.0f;
    _maxValue           = 1.0f;
    _defaultValue       = 0.0f;
    _targetValue        = 0.0f;
    _currentValue       = 0.0f;
    _rampTimeInSamples  = 0.0f;
    _isIORunning        = false;
    _parameterID        = 0;
    
    _debugPrintCount    = 0;
}

TWParameter::~TWParameter()
{
    
}




void TWParameter::setTargetValue(float targetValue, float rampTimeInSamples)
{
//    if (targetValue >= _maxValue) {
//        targetValue = _maxValue;
//    } else if (targetValue <= _minValue) {
//        targetValue = _minValue;
//    }
    
    _rampTimeInSamples = rampTimeInSamples;
    _targetValue = targetValue;
    
    if (!_isIORunning) {
        _currentValue = targetValue;
    }
    
    if (_rampTimeInSamples <= 0.0f) {
        _increment = 0.0f;
        _currentValue = targetValue;
    } else {
        _increment = (_targetValue - _currentValue) / _rampTimeInSamples;
    }
}

float TWParameter::getTargetValue()
{
    return _targetValue;
}

float TWParameter::getCurrentValue()
{
    if (fabs(_targetValue - _currentValue) >= fabs(_increment)) {
        _currentValue += _increment;
    } else {
        _currentValue = _targetValue;
    }
    
#if DEBUG_PRINT_ParamID_55
    if (_paramID == 55) {
        _debugPrint();
    }
#endif
    
#if DEBUG_PRINT_ParamID_99
    if (_paramID == 99) {
        _debugPrint();
    }
#endif
    
#if DEBUG_PRINT_ParamID_66
    if (_paramID == 66) {
        _debugPrint();
    }
#endif
    
    return _currentValue;
}




void TWParameter::setIsIORunning(bool isIORunning)
{
    _isIORunning = isIORunning;
}


bool TWParameter::getIsIORunning()
{
    return _isIORunning;
}




void TWParameter::setParameterID(int parameterID)
{
    _parameterID = parameterID;
}

int TWParameter::getParameterID()
{
    return _parameterID;
}



void TWParameter::setMaxValue(float maxValue)
{
    _maxValue = maxValue;
}

float TWParameter::getMaxValue()
{
    return _maxValue;
}


void TWParameter::setMinValue(float minValue)
{
    _minValue = minValue;
}

float TWParameter::getMinValue()
{
    return _minValue;
}


void TWParameter::updateDefaultValue(float defaultValue)
{
    _defaultValue = defaultValue;
}

void TWParameter::setDefaultValue(float rampTimeInSamples)
{
    setTargetValue(_defaultValue, rampTimeInSamples);
}

float TWParameter::getDefaultValue()
{
    return _defaultValue;
}


//void TWParameter::updateAlpha()
//{
//    /*
//      γ = 1 − (e^(2πfc/fs))
//     */
//    _alpha = 1.0 - exp(-2.0f * M_PI / _rampTimeInSamples);

// _currentValue = ((1.0 - _alpha) * _currentValue) + (_alpha * _targetValue);
//}



void TWParameter::_debugPrint()
{
    if (_debugPrintCount == kDebugPrintSamples) {
        printf("CV: %f. TV: %f. Inc: %f. Rn: %d. Prm: %d\n", _currentValue, _targetValue, _increment, _isIORunning, _parameterID);
        _debugPrintCount = 0;
    }
    _debugPrintCount++;
}

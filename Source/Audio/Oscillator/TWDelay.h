//
//  TWDelay.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/27/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWDelay_h
#define TWDelay_h

#include <stdio.h>
#include "TWRingBuffer.h"
#include "TWParameter.h"

class TWDelay {
    
public:
    
    TWDelay();
    ~TWDelay();
    
    void prepare(float sampleRate);
    float process(float inSample);
    void release();
    
    void setEnable(bool enable);
    void setDelayTime_ms(float delayTime_ms, float rampTime_ms);
    void setFeedback(float feedback, float rampTime_ms);
    void setDryWetRatio(float dryWetRatio, float rampTime_ms);
    
private:
    
    void            _setIsRunning(bool isRunning);
    
    TWRingBuffer*   _wetSignal;
    
    float           _sampleRate;
    
    bool            _enable;
    TWParameter     _delayTimeSamples;
    float           _delayTime_ms;
    TWParameter     _feedback;
    TWParameter     _dryWetRatio;
    
};
#endif /* TWDelay_h */

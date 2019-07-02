//
//  TWLevelMeter.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/26/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWLevelMeter_h
#define TWLevelMeter_h

#include <stdio.h>
#include <stdint.h>
#include <string.h>

class TWLevelMeter {
    
public:
    
    TWLevelMeter();
    ~TWLevelMeter();
    
    void prepare(float sampleRate);
    void process(float sample);
    void release();
    
    void setWindowSize_ms(float windowSize_ms);
    
    float getCurrentLevel();
    
    
private:
    
    float       _sampleRate;
    
    float       _windowSize_ms;
    uint32_t    _windowSize_samples;
    uint32_t    _sampleCount;
    float*      _buffer;
};

#endif /* TWLevelMeter_h */

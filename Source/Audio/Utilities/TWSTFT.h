//
//  TWSTFT.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/1/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#ifndef TWSTFT_h
#define TWSTFT_h

#include <stdio.h>


class TWSTFT {
    
    
public:
    
    TWSTFT();
    ~TWSTFT();
    
    void setFFTSizeInSamples(int fftSizeInSamples);
    
    void prepare(float sampleRate);
    float* process(float* inBuffer, int bufferSize);
    void release();
    
private:
    
    
    
};

#endif /* TWSTFT_h */

//
//  TWUIUtilities.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWUIUtilities.h"

@implementation TWUIUtilities


+ (float)scale:(float)inValue inMin:(float)inMin inMax:(float)inMax outMin:(float)outMin outMax:(float)outMax exponent:(float)exponent {
    
    if (exponent <= 0.0f) {
        exponent = 1.0f;
    }
    
    float inScaled = ((inValue - inMin) / (inMax - inMin));
    float exponentScaled = powf(inScaled, exponent);
    float outValue = (outMin + (exponentScaled * (outMax - outMin)));
    
    return outValue;
}


+ (float)logScaleFromLinear:(float)inValue outMin:(float)outMin outMax:(float)outMax {
    return expf(logf(outMin) + (inValue * (logf(outMax) - logf(outMin))));
}

+ (float)linearScaleFromLog:(float)inValue inMin:(float)inMin inMax:(float)inMax {
    return (logf(inValue) - logf(inMin)) / (logf(inMax) - logf(inMin));
}

@end

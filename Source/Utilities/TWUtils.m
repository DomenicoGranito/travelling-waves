//
//  TWUtils.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/10/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWUtils.h"
#include <math.h>

@implementation TWUtils

+ (BOOL)checkOSStatus:(OSStatus)status inContext:(NSString *)context {
    if(status != noErr) {
        printf("\n");
        NSLog(@"Error in %@: %d", context, status);
        printf("\n");
        return NO;
    }
    return YES;
}


+ (float)logScaleFromLinear:(float)inValue outMin:(float)outMin outMax:(float)outMax {
    return expf(logf(outMin) + (inValue * (logf(outMax) - logf(outMin))));
}

+ (float)linearScaleFromLog:(float)inValue inMin:(float)inMin inMax:(float)inMax {
    return (logf(inValue) - logf(inMin)) / (logf(inMax) - logf(inMin));
}

@end

//
//  TWUtils.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/10/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWUtils.h"

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

@end

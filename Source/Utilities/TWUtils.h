//
//  TWUtils.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/10/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWUtils : NSObject

+ (BOOL)checkOSStatus:(OSStatus)status inContext:(NSString*)context;

+ (float)logScaleFromLinear:(float)inValue outMin:(float)outMin outMax:(float)outMax;
+ (float)linearScaleFromLog:(float)inValue inMin:(float)inMin inMax:(float)inMax;

@end

NS_ASSUME_NONNULL_END

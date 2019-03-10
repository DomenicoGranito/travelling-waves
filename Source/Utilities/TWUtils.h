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

@end

NS_ASSUME_NONNULL_END

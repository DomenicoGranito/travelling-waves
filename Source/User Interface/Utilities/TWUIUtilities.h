//
//  TWUIUtilities.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 5/9/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWUIUtilities : NSObject

+ (float)scale:(float)inValue inMin:(float)inMin inMax:(float)inMax outMin:(float)outMin outMax:(float)outMax exponent:(float)exponent;

@end

NS_ASSUME_NONNULL_END

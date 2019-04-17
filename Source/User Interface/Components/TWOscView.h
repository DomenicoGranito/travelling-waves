//
//  TWOscView.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/11/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWOscView : UIView

@property (nonatomic, assign) int sourceIdx;

- (void)refreshParametersWithAnimation:(BOOL)animated;

@property(nonatomic, weak) id mixerView;

@end

NS_ASSUME_NONNULL_END

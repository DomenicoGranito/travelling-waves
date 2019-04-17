//
//  TWMixerView.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/13/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWMixerView : UIView

- (void)refreshParametersWithAnimation:(BOOL)animated;

@property(nonatomic, weak) id oscView;

@end

NS_ASSUME_NONNULL_END

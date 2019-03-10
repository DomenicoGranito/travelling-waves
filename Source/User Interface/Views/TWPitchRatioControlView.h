//
//  TWPitchRatioControlView.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/20/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWOscView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWPitchRatioControlView : UIView

- (void)viewWillAppear:(BOOL)animated;
@property(nonatomic, weak)TWOscView* oscView;

@end

NS_ASSUME_NONNULL_END

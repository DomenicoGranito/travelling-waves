//
//  TWSequencerViewController.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/5/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWViewController.h"
#import "TWOscView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWSequencerViewController : TWViewController

@property(nonatomic, weak)TWOscView* oscView;

@end

NS_ASSUME_NONNULL_END

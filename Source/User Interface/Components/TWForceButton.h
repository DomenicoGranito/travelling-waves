//
//  TWForceButton.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/15/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWForceButtonDelegate <NSObject>
- (void)forceButtonTouchUpInside:(id)sender;
- (void)forceButtonForcePressDown:(id)sender;
@end


@interface TWForceButton : UIView

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, weak) id <TWForceButtonDelegate> delegate;

@property (nonatomic, strong) UIColor* defaultBackgroundColor;
@property (nonatomic, strong) UIColor* selectedBackgroundColor;

@property (nonatomic, strong) UILabel* titleLabel;

@end

NS_ASSUME_NONNULL_END

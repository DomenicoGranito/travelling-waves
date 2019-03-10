//
//  TWKeyboardAccessoryView.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/12/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWKeyboardAccessoryViewDelegate <NSObject>
- (void)keyboardDoneButtonTapped:(id)sender;
- (void)keyboardCancelButtonTapped:(id)sender;
@end


@interface TWKeyboardAccessoryView : UIView

+ (instancetype)sharedView;

@property (nonatomic, strong) NSString* titleText;
@property (nonatomic, strong) NSString* valueText;
@property (nonatomic, weak) UITextField* currentResponder;

- (void)addToDelegates:(id<TWKeyboardAccessoryViewDelegate>)delegate;
- (void)updateLayout;

@end

NS_ASSUME_NONNULL_END

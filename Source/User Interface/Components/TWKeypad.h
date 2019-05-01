//
//  TWKeypad.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/10/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWKeypadDelegate <NSObject>
- (void)keypadDoneButtonTapped:(id)senderKeypad forComponent:(UIView*)responder withValue:(NSString*)inValue;
- (void)keypadCancelButtonTapped:(id)senderKeypad forComponent:(UIView*)responder;
@end



@interface TWKeypad : UIView

+ (instancetype)sharedKeypad;

//- (void)addToDelegates:(id<TWKeypadDelegate>)delegate;

- (void)showKeypad;
- (void)hideKeypad;

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* value;

@property (nonatomic, weak) UIView* currentResponder;
@property (nonatomic, weak) id<TWKeypadDelegate> currentDelegate;

@property (nonatomic, assign) CGRect showFrame;
@property (nonatomic, assign) CGRect hideFrame;

@property (nonatomic, readonly) BOOL keypadIsShowing;

@end

NS_ASSUME_NONNULL_END

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
- (void)keypadDoneButtonTapped:(UIButton*)responder withValue:(NSString*)value;
- (void)keypadCancelButtonTapped:(UIButton*)responder;
@end



@interface TWKeypad : UIView

+ (instancetype)sharedKeypad;

- (void)addToDelegates:(id<TWKeypadDelegate>)delegate;

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* value;

@property (nonatomic, weak) UIButton* currentResponder;

@property (nonatomic, assign) CGRect showFrame;
@property (nonatomic, assign) CGRect hideFrame;

@end

NS_ASSUME_NONNULL_END

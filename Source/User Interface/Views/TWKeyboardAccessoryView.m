//
//  TWKeyboardAccessoryView.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/12/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWKeyboardAccessoryView.h"
#import "TWHeader.h"

//static const CGFloat kAccessoryHeight   = 50.0f; // 40.0f for iPhone
static const CGFloat kButtonWidth       = 120.0f;

@interface TWKeyboardAccessoryView()
{
    UIButton*           _doneButton;
    UIButton*           _cancelButton;
    
    UILabel*            _paramTitleLabel;
    UILabel*            _paramValueLabel;
    NSMutableArray*     _delegates;
}
@end


@implementation TWKeyboardAccessoryView

+ (instancetype)sharedView {
    static dispatch_once_t onceToken;
    static TWKeyboardAccessoryView* view;
    dispatch_once(&onceToken, ^{
        view = [[TWKeyboardAccessoryView alloc] init];
    });
    return view;
}

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    _doneButton = [[UIButton alloc] init];
    [_doneButton setBackgroundColor:[UIColor clearColor]];
    [[_doneButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_doneButton setTitleColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
    [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    [_doneButton setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:_doneButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setBackgroundColor:[UIColor clearColor]];
    [[_cancelButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_cancelButton setTitleColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    [_cancelButton setBackgroundColor:[UIColor greenColor]];
    [self addSubview:_cancelButton];
    
    _paramTitleLabel = [[UILabel alloc] init];
    [_paramTitleLabel setBackgroundColor:[UIColor clearColor]];
    [_paramTitleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_paramTitleLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
    [_paramTitleLabel setTextAlignment:NSTextAlignmentRight];
    [_paramTitleLabel setText:@"<ParamTitle>"];
    [_paramTitleLabel setBackgroundColor:[UIColor clearColor]];
//    [_paramTitleLabel setBackgroundColor:[UIColor orangeColor]];
    [self addSubview:_paramTitleLabel];
    
    _paramValueLabel = [[UILabel alloc] init];
    [_paramValueLabel setBackgroundColor:[UIColor clearColor]];
    [_paramValueLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_paramValueLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
    [_paramValueLabel setTextAlignment:NSTextAlignmentLeft];
    [_paramValueLabel setText:@"<ParamLabel>"];
    [_paramValueLabel setBackgroundColor:[UIColor clearColor]];
//    [_paramValueLabel setBackgroundColor:[UIColor blueColor]];
    [self addSubview:_paramValueLabel];
    
    _delegates = [[NSMutableArray alloc] init];
    
    [self updateLayout];
    [self setBackgroundColor:[UIColor colorWithWhite:0.17f alpha:0.98f]];
}


- (void)updateLayout {
    
    CGRect screenRect       = [[[UIApplication sharedApplication] keyWindow] bounds];
    CGFloat xMargin         = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].left;
    CGFloat screenWidth     = screenRect.size.width - xMargin;
//    CGFloat yPos            = self.view.safeAreaInsets.top;
    CGFloat xPos            = xMargin;
//
//    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
//    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    NSLog(@"Keyboard. isLandscape: %d", isLandscape);
    CGFloat accessoryHeight = (isIPad ? kKeyboardAccessoryHeightPad : (isLandscape ? kKeyboardAccessoryLandscapeHeightPhone : kKeyboardAccessoryPortraitHeightPhone));
    
    [self setFrame:CGRectMake(xPos, 0.0f, screenWidth, accessoryHeight)];
    
    CGFloat leftOffset = 10.0f;
    CGFloat padding = 4.0f;
    CGFloat titleLabelWidth = ((screenWidth - (2.0f * kButtonWidth)) / 2.0f) + leftOffset - padding;
    CGFloat valueLabelWidth = ((screenWidth - (2.0f * kButtonWidth)) / 2.0f) - leftOffset - padding;
    
    [_cancelButton setFrame:CGRectMake(xPos, 0.0f, kButtonWidth, accessoryHeight)];
    [_paramTitleLabel setFrame:CGRectMake((screenWidth / 2.0f) - titleLabelWidth + leftOffset - padding, 0.0f, titleLabelWidth, accessoryHeight)];
    [_paramValueLabel setFrame:CGRectMake((screenWidth / 2.0f) + leftOffset + padding, 0.0f, valueLabelWidth, accessoryHeight)];
    [_doneButton setFrame:CGRectMake(screenWidth - kButtonWidth, 0.0f, kButtonWidth, accessoryHeight)];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addToDelegates:(id<TWKeyboardAccessoryViewDelegate>)delegate {
    [_delegates addObject:delegate];
}

- (void)doneButtonTapped {
    [self sanitizeTextField:_currentResponder];
    for (id<TWKeyboardAccessoryViewDelegate> delegate in _delegates) {
        [delegate keyboardDoneButtonTapped:self];
    }
}

- (void)cancelButtonTapped {
    for (id<TWKeyboardAccessoryViewDelegate> delegate in _delegates) {
        [delegate keyboardCancelButtonTapped:self];
    }
}


- (void)setTitleText:(NSString *)title {
    _titleText = title;
    [_paramTitleLabel setText:title];
}

- (void)setValueText:(NSString *)value {
    _valueText = value;
    [_paramValueLabel setText:value];
}


#pragma mark - Private

- (void)sanitizeTextField:(UITextField*)textField {
    if ([[textField text] isEqualToString:@""]) {
        [textField setText:@"0"];
    }
}

@end

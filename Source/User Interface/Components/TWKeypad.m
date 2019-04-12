//
//  TWKeypad.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/10/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWKeypad.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat    kKeyPaddingAmount                   = 0.1; // Percent of width
static const float      kKeypadAnimationTime_s              = 0.15f;


@interface TWKeypad()
{
    NSArray*                                _keyButtons;
    
    UIButton*                               _doneButton;
    UIButton*                               _cancelButton;
    UIButton*                               _backspaceButton;
    UIButton*                               _decimalPointButton;
    
    UILabel*                                _titleLabel;
    UILabel*                                _valueLabel;
    
    NSMutableString*                        _currentValue;
    
    UIColor*                                _downColor;
    UIColor*                                _upColor;
    UIColor*                                _editingColor;
    
    BOOL                                    _isFirstNumeral;
    BOOL                                    _decimalPointAlreadyTyped;
    
    NSMutableArray<id<TWKeypadDelegate>>*   _delegates;
}
@end



@implementation TWKeypad

- (id)init {
    
    if (self = [super init]) {
        
        _downColor = [[UIColor alloc] initWithWhite:0.265 alpha:1.0f];
        _upColor = [[UIColor alloc] initWithWhite:0.375 alpha:1.0f];
        
        _editingColor = [[UIColor alloc] initWithRed:0.1f green:0.2f blue:0.3f alpha:0.5f];
        
        
        NSMutableArray* keyButtons = [[NSMutableArray alloc] init];
        for (int i=0; i < 10; i++) {
            UIButton* keyButton = [[UIButton alloc] init];
            [keyButton setTag:i];
            [keyButton setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
            [keyButton setBackgroundColor:_upColor];
            [keyButton setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateNormal];
            [[keyButton titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
            [keyButton setClipsToBounds:YES];
            [keyButton addTarget:self action:@selector(keyButtonDown:) forControlEvents:UIControlEventTouchDown];
            [keyButton addTarget:self action:@selector(keyButtonUp:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:keyButton];
            [keyButtons addObject:keyButton];
        }
        _keyButtons = [[NSArray alloc] initWithArray:keyButtons];
        
        
        _backspaceButton = [[UIButton alloc] init];
        [_backspaceButton setTitle:[NSString stringWithFormat:@"\u232B"] forState:UIControlStateNormal];
        [_backspaceButton setBackgroundColor:_upColor];
        [_backspaceButton setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateNormal];
        [[_backspaceButton titleLabel] setFont:[UIFont systemFontOfSize:15.0f]];
        [_backspaceButton setClipsToBounds:YES];
        [_backspaceButton addTarget:self action:@selector(backspaceButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_backspaceButton addTarget:self action:@selector(backspaceButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backspaceButton];
        
        _decimalPointButton = [[UIButton alloc] init];
        [_decimalPointButton setTitle:[NSString stringWithFormat:@"."] forState:UIControlStateNormal];
        [_decimalPointButton setBackgroundColor:_upColor];
        [_decimalPointButton setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateNormal];
        [[_decimalPointButton titleLabel] setFont:[UIFont systemFontOfSize:14.0f]];
        [_decimalPointButton setClipsToBounds:YES];
        [_decimalPointButton addTarget:self action:@selector(decimalPointButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_decimalPointButton addTarget:self action:@selector(decimalPointButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_decimalPointButton];
        
        
        
        _doneButton = [[UIButton alloc] init];
        [_doneButton setTitle:[NSString stringWithFormat:@"Done"] forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor clearColor]];
        [_doneButton setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateNormal];
        [[_doneButton titleLabel] setFont:[UIFont systemFontOfSize:15.0f]];
//        [_doneButton addTarget:self action:@selector(doneButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_doneButton addTarget:self action:@selector(doneButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_doneButton];
        
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:[NSString stringWithFormat:@"Cancel"] forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor clearColor]];
        [_cancelButton setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateNormal];
        [[_cancelButton titleLabel] setFont:[UIFont systemFontOfSize:15.0f]];
//        [_cancelButton addTarget:self action:@selector(cancelButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_cancelButton addTarget:self action:@selector(cancelButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_titleLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
        [_titleLabel setTextAlignment:NSTextAlignmentRight];
        [_titleLabel setText:@"<ParamTitle> : "];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
//        [_titleLabel setBackgroundColor:[UIColor orangeColor]];
        [self addSubview:_titleLabel];
        
        _valueLabel = [[UILabel alloc] init];
        [_valueLabel setBackgroundColor:[UIColor clearColor]];
        [_valueLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_valueLabel setTextColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
//        [_valueLabel setTextAlignment:NSTextAlignmentLeft];
        [_valueLabel setTextAlignment:NSTextAlignmentCenter];
        [_valueLabel setText:@"<ParamValue>"];
        [_valueLabel setBackgroundColor:[UIColor clearColor]];
//        [_valueLabel setBackgroundColor:[UIColor blueColor]];
        [self addSubview:_valueLabel];
        
        _delegates = [[NSMutableArray alloc] init];
        
        _currentValue = [[NSMutableString alloc] init];
        
        _keypadIsShowing = NO;
        _isFirstNumeral = YES;
        _decimalPointAlreadyTyped = NO;
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.117 alpha:1.0f]];
    }
    
    return self;
}

+ (instancetype)sharedKeypad {
    static dispatch_once_t onceToken;
    static TWKeypad* keypad;
    dispatch_once(&onceToken, ^{
        keypad = [[TWKeypad alloc] init];
    });
    return keypad;
}


- (void)addToDelegates:(id<TWKeypadDelegate>)delegate {
    [_delegates addObject:delegate];
}


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
//    NSLog(@"Keypad SetFrame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    
    
    if (isIPad || isLandscape) {
        
        CGFloat numKeysInRow = 12;
        
        CGFloat keyButtonWidth = width / (((numKeysInRow+1) * kKeyPaddingAmount) + numKeysInRow);
        CGFloat keyButtonHeight = keyButtonWidth;
        CGFloat keyButtonPadding = kKeyPaddingAmount * keyButtonWidth;
        
        
        CGFloat numOptionsInRow = 4;
        CGFloat optionButtonWidth = width / (((numOptionsInRow+1) * kKeyPaddingAmount) + numOptionsInRow);
        CGFloat optionButtonHeight = height - (5.0f * keyButtonPadding) - keyButtonHeight;
        
        
        CGFloat optionButtonPadding = kKeyPaddingAmount * optionButtonWidth;
        
        CGFloat yPos = keyButtonPadding;
        CGFloat xPos = optionButtonPadding;
        
        [_cancelButton setFrame:CGRectMake(xPos, yPos, optionButtonWidth, optionButtonHeight)];
        xPos += optionButtonPadding + optionButtonWidth;
        
        [_titleLabel setFrame:CGRectMake(xPos, yPos, optionButtonWidth, optionButtonHeight)];
        xPos += optionButtonPadding + optionButtonWidth;
        
        [_valueLabel setFrame:CGRectMake(xPos, yPos, optionButtonWidth, optionButtonHeight)];
        xPos += optionButtonPadding + optionButtonWidth;
        
        [_doneButton setFrame:CGRectMake(xPos, yPos, optionButtonWidth, optionButtonHeight)];
        
        
        yPos += keyButtonPadding + optionButtonHeight;
        xPos = keyButtonPadding;
        
        CGFloat cornerRadius = 8.0f;
        
        for (int i=1; i < 10; i++) {
            UIButton* keyButton = [_keyButtons objectAtIndex:i];
            [keyButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
            [keyButton.layer setCornerRadius:cornerRadius];
            xPos += keyButtonPadding + keyButtonWidth;
        }
        
        UIButton* zeroButton = [_keyButtons objectAtIndex:0];
        [zeroButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
        [zeroButton.layer setCornerRadius:cornerRadius];
        xPos += keyButtonPadding + keyButtonWidth;
        
        [_decimalPointButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
        [_decimalPointButton.layer setCornerRadius:cornerRadius];
        xPos += keyButtonPadding + keyButtonWidth;
        
        [_backspaceButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
        [_backspaceButton.layer setCornerRadius:cornerRadius];
        
    }
    
    else {  // if iPhone Portrait
        
        CGFloat numKeysInRow = 6;
        
        CGFloat keyButtonWidth = width / (((numKeysInRow+1) * kKeyPaddingAmount) + numKeysInRow);
        CGFloat keyButtonHeight = keyButtonWidth;
        CGFloat keyButtonPadding = kKeyPaddingAmount * keyButtonWidth;
        
        
        CGFloat numOptionsInRow = 4;
        CGFloat optionButtonWidth = width / (((numOptionsInRow+1) * kKeyPaddingAmount) + numOptionsInRow);
        CGFloat optionButtonHeight = height - (10.0f * keyButtonPadding) - (2.0f * keyButtonHeight);
        
        
        CGFloat optionButtonPadding = kKeyPaddingAmount * optionButtonWidth;
        
        CGFloat yPos = keyButtonPadding;
        CGFloat xPos = optionButtonPadding;
        
        [_cancelButton setFrame:CGRectMake(xPos, yPos, optionButtonWidth - 20.0f, optionButtonHeight)];
        xPos += optionButtonPadding + optionButtonWidth - 20.0f;
        
        [_titleLabel setFrame:CGRectMake(xPos, yPos, optionButtonWidth + 60.0f, optionButtonHeight)];
        xPos += optionButtonPadding + optionButtonWidth + 60.0f;
        
        [_valueLabel setFrame:CGRectMake(xPos, yPos, optionButtonWidth - 20.0f, optionButtonHeight)];
        xPos += optionButtonPadding + optionButtonWidth - 20.0f;
        
        [_doneButton setFrame:CGRectMake(xPos, yPos, optionButtonWidth - 20.0f, optionButtonHeight)];
        
        
        yPos += keyButtonPadding + optionButtonHeight;
        xPos = keyButtonPadding;
        
        CGFloat cornerRadius = 6.0f;
        
        for (int i=1; i < 10; i++) {
            UIButton* keyButton = [_keyButtons objectAtIndex:i];
            [keyButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
            [keyButton.layer setCornerRadius:cornerRadius];
            xPos += keyButtonPadding + keyButtonWidth;
            
            if ((i % 6) == 0) {
                xPos = keyButtonPadding;
                yPos += keyButtonPadding + keyButtonHeight;
            }
        }
        
        UIButton* zeroButton = [_keyButtons objectAtIndex:0];
        [zeroButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
        [zeroButton.layer setCornerRadius:cornerRadius];
        xPos += keyButtonPadding + keyButtonWidth;
        
        [_decimalPointButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
        [_decimalPointButton.layer setCornerRadius:cornerRadius];
        xPos += keyButtonPadding + keyButtonWidth;
        
        [_backspaceButton setFrame:CGRectMake(xPos, yPos, keyButtonWidth, keyButtonHeight)];
        [_backspaceButton.layer setCornerRadius:cornerRadius];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)keyButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:_downColor];
}

- (void)keyButtonUp:(UIButton*)sender {
    
    if (_isFirstNumeral) {
        [_currentValue setString:@""];
        _isFirstNumeral = NO;
    }
    
    [_currentValue appendString:[NSString stringWithFormat:@"%d",(int)sender.tag]];
    [self updateValueLabel];
    [sender setBackgroundColor:_upColor];
}


- (void)decimalPointButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:_downColor];
}

- (void)decimalPointButtonUp:(UIButton*)sender {
    
    if (!_decimalPointAlreadyTyped) {
        
        if (_isFirstNumeral) {
            [_currentValue setString:@""];
            _isFirstNumeral = NO;
        }
        
        [_currentValue appendString:@"."];
        [self updateValueLabel];
        _decimalPointAlreadyTyped = YES;
        
    }
    
    [sender setBackgroundColor:_upColor];
}



- (void)backspaceButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:_downColor];
}

- (void)backspaceButtonUp:(UIButton*)sender {
    [_currentValue setString:@""];
    _decimalPointAlreadyTyped = NO;
    [self updateValueLabel];
    [sender setBackgroundColor:_upColor];
}





- (void)doneButtonDown:(UIButton*)sender {
    
}

- (void)doneButtonUp:(UIButton*)sender {
    _value = _currentValue;
    for (id<TWKeypadDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(keypadDoneButtonTapped:withValue:)]) {
            [delegate keypadDoneButtonTapped:_currentResponder withValue:_value];
        }
    }
    [_currentResponder setBackgroundColor:[UIColor clearColor]];
    [self hideKeypad];
}



- (void)cancelButtonDown:(UIButton*)sender {
    
}

- (void)cancelButtonUp:(UIButton*)sender {
    for (id<TWKeypadDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(keypadCancelButtonTapped:)]) {
            [delegate keypadCancelButtonTapped:_currentResponder];
        }
    }
    [_currentResponder setBackgroundColor:[UIColor clearColor]];
    [self hideKeypad];
}



- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleLabel setText:_title];
}

- (void)setValue:(NSString *)value {
    _value = value;
    [_currentValue setString:_value];
    [_valueLabel setText:_value];
}

- (void)setCurrentResponder:(UIButton *)currentResponder {
    [_currentResponder setBackgroundColor:[UIColor clearColor]];
    _currentResponder = currentResponder;
    [_currentResponder setBackgroundColor:_editingColor];
    if (!_keypadIsShowing) {
        [self showKeypad];
    }
}


- (void)updateValueLabel {
    [_valueLabel setText:_currentValue];
}





- (void)showKeypad {
    _decimalPointAlreadyTyped = NO;
    _isFirstNumeral = YES;
    [UIView animateWithDuration:kKeypadAnimationTime_s delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setFrame:self->_showFrame];
    } completion:^(BOOL finished) {
        self->_keypadIsShowing = YES;
    }];
}

- (void)hideKeypad {
    [UIView animateWithDuration:kKeypadAnimationTime_s delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setFrame:self->_hideFrame];
    } completion:^(BOOL finished) {
        self->_keypadIsShowing = NO;
    }];
}

@end

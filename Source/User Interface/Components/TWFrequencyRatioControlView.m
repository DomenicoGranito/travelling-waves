//
//  TWFrequencyRatioControlView.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/20/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWFrequencyRatioControlView.h"
#import "TWMasterController.h"
#import "TWHeader.h"
#import "TWKeyboardAccessoryView.h"
#import <QuartzCore/QuartzCore.h>

#define kLocalTitleLabelWidth      40.0f

@interface TWFrequencyRatioControlView() <UITextFieldDelegate, TWKeyboardAccessoryViewDelegate>
{
    UILabel*                    _rootFreqLabel;
    UISlider*                   _rootFreqSlider;
    UITextField*                _rootFreqField;
    
    UILabel*                    _rampTimeLabel;
    UISlider*                   _rampTimeSlider;
    UITextField*                _rampTimeField;
    
    UILabel*                    _rootTempoLabel;
    UISlider*                   _rootTempoSlider;
    UITextField*                _rootTempoField;
    UIButton*                   _tapTempoButton;
    
    
    NSArray*                    _textFields;
    
    NSArray*                    _idLabels;
    NSArray*                    _numIncButtons;
    NSArray*                    _numDecButtons;
    NSArray*                    _numBorders;
    NSArray*                    _denIncButtons;
    NSArray*                    _denDecButtons;
    NSArray*                    _denBorders;
}
@end




@implementation TWFrequencyRatioControlView

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {

    TWKeyboardAccessoryView* accView = [TWKeyboardAccessoryView sharedView];
    [accView addToDelegates:self];
    
//    UIColor* textFieldBackground = [UIColor colorWithWhite:0.5f alpha:0.1f];
    UIColor* textFieldBackground = [UIColor clearColor];
    
    
    _rootFreqLabel = [[UILabel alloc] init];
    [_rootFreqLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rootFreqLabel setText:@"Root F:"];
    [_rootFreqLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_rootFreqLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_rootFreqLabel];
    
    _rootFreqSlider = [[UISlider alloc] init];
    [_rootFreqSlider setMinimumValue:20.0f];
    [_rootFreqSlider setMaximumValue:2000.0f];
    [_rootFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rootFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_rootFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rootFreqSlider addTarget:self action:@selector(rootFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rootFreqSlider];
    
    _rootFreqField = [[UITextField alloc] init];
    [_rootFreqField setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rootFreqField setFont:[UIFont systemFontOfSize:10.0f]];
    [_rootFreqField setTextAlignment:NSTextAlignmentCenter];
    [_rootFreqField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_rootFreqField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_rootFreqField setInputAccessoryView:accView];
    [_rootFreqField setBackgroundColor:textFieldBackground];
    [_rootFreqField setDelegate:self];
    [self addSubview:_rootFreqField];
    
    _rampTimeLabel = [[UILabel alloc] init];
    [_rampTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rampTimeLabel setText:@"Ramp:"];
    [_rampTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_rampTimeLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_rampTimeLabel];
    
    
    _rampTimeSlider = [[UISlider alloc] init];
    [_rampTimeSlider setMinimumValue:0];
    [_rampTimeSlider setMaximumValue:16000];
    [_rampTimeSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rampTimeSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_rampTimeSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rampTimeSlider addTarget:self action:@selector(rampTimeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rampTimeSlider];
    
    _rampTimeField = [[UITextField alloc] init];
    [_rampTimeField setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rampTimeField setFont:[UIFont systemFontOfSize:10.0f]];
    [_rampTimeField setTextAlignment:NSTextAlignmentCenter];
    [_rampTimeField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_rampTimeField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_rampTimeField setInputAccessoryView:accView];
    [_rampTimeField setBackgroundColor:textFieldBackground];
    [_rampTimeField setDelegate:self];
    [self addSubview:_rampTimeField];
    
    
    
    _rootTempoLabel = [[UILabel alloc] init];
    [_rootTempoLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rootTempoLabel setText:@"Tempo:"];
    [_rootTempoLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_rootTempoLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_rootTempoLabel];
    
    _rootTempoSlider = [[UISlider alloc] init];
    [_rootTempoSlider setMinimumValue:20.0f];
    [_rootTempoSlider setMaximumValue:400.0f];
    [_rootTempoSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rootTempoSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_rootTempoSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rootTempoSlider addTarget:self action:@selector(rootFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rootTempoSlider];
    
    _rootTempoField = [[UITextField alloc] init];
    [_rootTempoField setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rootTempoField setFont:[UIFont systemFontOfSize:10.0f]];
    [_rootTempoField setTextAlignment:NSTextAlignmentCenter];
    [_rootTempoField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_rootTempoField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_rootTempoField setInputAccessoryView:accView];
    [_rootTempoField setBackgroundColor:textFieldBackground];
    [_rootTempoField setDelegate:self];
    [self addSubview:_rootTempoField];
    
    
    _tapTempoButton = [[UIButton alloc] init];
    [_tapTempoButton setTitle:@"Tap Tempo" forState:UIControlStateNormal];
    [_tapTempoButton setBackgroundColor:[UIColor colorWithWhite:0.24 alpha:0.8]];
    [_tapTempoButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_tapTempoButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
    [_tapTempoButton addTarget:self action:@selector(tapTempoButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_tapTempoButton addTarget:self action:@selector(tapTempoButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tapTempoButton];

    
    
    
    
    NSMutableArray* numTextFields = [[NSMutableArray alloc] init];
    NSMutableArray* denTextFields = [[NSMutableArray alloc] init];
    
    NSMutableArray* idLabels = [[NSMutableArray alloc] init];
    NSMutableArray* numIncButtons = [[NSMutableArray alloc] init];
    NSMutableArray* numDecButtons = [[NSMutableArray alloc] init];
    NSMutableArray* numBorders = [[NSMutableArray alloc] init];
    NSMutableArray* denIncButtons = [[NSMutableArray alloc] init];
    NSMutableArray* denDecButtons = [[NSMutableArray alloc] init];
    NSMutableArray* denBorders = [[NSMutableArray alloc] init];
    
    for (int idx=0; idx < kNumSources; idx++) {
        
        UILabel* idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [idLabel setText:[NSString stringWithFormat:@"%d", idx+1]];
        [idLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [idLabel setTextAlignment:NSTextAlignmentCenter];
        [idLabel setTextColor:[UIColor colorWithWhite:0.4f alpha:0.6f]];
        [idLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:idLabel];
        [idLabels addObject:idLabel];
        
        UIButton* numIncButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [numIncButton setTitle:@"NI" forState:UIControlStateNormal];
        [numIncButton addTarget:self action:@selector(incNumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [numIncButton setBackgroundColor:[UIColor colorWithWhite:0.18f alpha:1.0f]];
        [numIncButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
        [[numIncButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [numIncButton setTag:idx];
        [self addSubview:numIncButton];
        [numIncButtons addObject:numIncButton];
        
        UITextField* numTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [numTextField setTextColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
        [numTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [numTextField setTextAlignment:NSTextAlignmentCenter];
        [numTextField setKeyboardType:UIKeyboardTypeDecimalPad];
        [numTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [numTextField setInputAccessoryView:accView];
        [numTextField setBackgroundColor:textFieldBackground];
        [numTextField setTag:(idx * 2)];
        [numTextField setDelegate:self];
        [self addSubview:numTextField];
        [numTextFields addObject:numTextField];
        
        UIButton* numDecButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [numDecButton setTitle:@"ND" forState:UIControlStateNormal];
        [numDecButton addTarget:self action:@selector(decNumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [numDecButton setBackgroundColor:[UIColor colorWithWhite:0.18f alpha:1.0f]];
        [numDecButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
        [[numDecButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [numDecButton setTag:idx];
        [self addSubview:numDecButton];
        [numDecButtons addObject:numDecButton];
        
        UIButton* denIncButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [denIncButton setTitle:@"DI" forState:UIControlStateNormal];
        [denIncButton addTarget:self action:@selector(incDenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [denIncButton setBackgroundColor:[UIColor colorWithWhite:0.18f alpha:1.0f]];
        [denIncButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
        [[denIncButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [denIncButton setTag:idx];
        [self addSubview:denIncButton];
        [denIncButtons addObject:denIncButton];
        
        UITextField* denTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [denTextField setTextColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
        [denTextField setFont:[UIFont systemFontOfSize:12.0f]];
        [denTextField setTextAlignment:NSTextAlignmentCenter];
        [denTextField setKeyboardType:UIKeyboardTypeDecimalPad];
        [denTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [denTextField setInputAccessoryView:accView];
        [denTextField setBackgroundColor:textFieldBackground];
        [denTextField setTag:(idx * 2) + 1];
        [denTextField setDelegate:self];
        [self addSubview:denTextField];
        [denTextFields addObject:denTextField];
        
        UIButton* denDecButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [denDecButton setTitle:@"DD" forState:UIControlStateNormal];
        [denDecButton addTarget:self action:@selector(decDenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [denDecButton setBackgroundColor:[UIColor colorWithWhite:0.18f alpha:1.0f]];
        [denDecButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
        [[denDecButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [denDecButton setTag:idx];
        [self addSubview:denDecButton];
        [denDecButtons addObject:denDecButton];
        
        UIView *numBorderView = [[UIView alloc] init];
        [numBorderView setUserInteractionEnabled:NO];
        [numBorderView.layer setBorderColor:[UIColor colorWithWhite:0.3f alpha:1.0f].CGColor];
        [numBorderView.layer setBorderWidth:0.8f];
        [self addSubview:numBorderView];
        [numBorders addObject:numBorderView];
        
        UIView *denBorderView = [[UIView alloc] init];
        [denBorderView.layer setBorderColor:[UIColor colorWithWhite:0.3f alpha:1.0f].CGColor];
        [denBorderView.layer setBorderWidth:0.8f];
        [denBorderView setUserInteractionEnabled:NO];
        [self addSubview:denBorderView];
        [denBorders addObject:denBorderView];
    }
    
    _textFields     = [[NSArray alloc] initWithObjects:numTextFields, denTextFields, nil];
    
    _idLabels       = [[NSArray alloc] initWithArray:idLabels];
    _numIncButtons  = [[NSArray alloc] initWithArray:numIncButtons];
    _numDecButtons  = [[NSArray alloc] initWithArray:numDecButtons];
    _numBorders     = [[NSArray alloc] initWithArray:numBorders];
    _denIncButtons  = [[NSArray alloc] initWithArray:denIncButtons];
    _denDecButtons  = [[NSArray alloc] initWithArray:denDecButtons];
    _denBorders     = [[NSArray alloc] initWithArray:denBorders];
    
    
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.16f alpha:1.0f]];
}


- (void)viewWillAppear:(BOOL)animated {
    float frequency = [[TWMasterController sharedController] rootFrequency];
    [_rootFreqSlider setValue:frequency animated:animated];
    [_rootFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    
    int rampTime_ms = [[TWMasterController sharedController] rampTime_ms];
    [_rampTimeSlider setValue:rampTime_ms animated:animated];
    [_rampTimeField setText:[NSString stringWithFormat:@"%d", rampTime_ms]];
    
    float tempo = [[TWMasterController sharedController] rootTempo];
    [_rootTempoSlider setValue:tempo animated:animated];
    [_rootTempoField setText:[NSString stringWithFormat:@"%.2f", tempo]];
    
    for (int idx=0; idx < kNumSources; idx++) {
        int numerator = [[TWMasterController sharedController] getNumeratorRatioAt:idx];
        UITextField* numTextField = (UITextField*)_textFields[kNumerator][idx];
        [numTextField setText:[NSString stringWithFormat:@"%d", numerator]];
        
        int denominator = [[TWMasterController sharedController] getDenominatorRatioAt:idx];
        UITextField* denTextField = (UITextField*)_textFields[kDenominator][idx];
        [denTextField setText:[NSString stringWithFormat:@"%d", denominator]];
    }

}


- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    CGFloat yPos = 0.0f;
    CGFloat xPos = 0.0f;
    CGFloat sliderWidth = (frame.size.width - (2.0f * (kLocalTitleLabelWidth + kValueLabelWidth))) / 2.0f;
    
    
    [_rootFreqLabel setFrame:CGRectMake(xPos, yPos, kLocalTitleLabelWidth, componentHeight)];
    
    xPos += kLocalTitleLabelWidth;
    [_rootFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += sliderWidth;
    [_rootFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _rootFreqField.frame.size.width;
    [_rampTimeLabel setFrame:CGRectMake(xPos, yPos, kLocalTitleLabelWidth, componentHeight)];
    
    xPos += kLocalTitleLabelWidth;
    [_rampTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _rampTimeSlider.frame.size.width;
    [_rampTimeField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_rootTempoLabel setFrame:CGRectMake(xPos, yPos, kLocalTitleLabelWidth, componentHeight)];
    
    xPos += kLocalTitleLabelWidth;
    [_rootTempoSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += sliderWidth;
    [_rootTempoField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _rootTempoField.frame.size.width;
    CGFloat tapTempoButtonWidth = frame.size.width - xPos;
    [_tapTempoButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, tapTempoButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
    
    
    
    yPos += componentHeight;
    CGFloat idLabelWidth = 12.0f;
    CGFloat textFieldWidth = 16.0f;
    CGFloat buttonYMargin = kButtonYMargin;
    
    CGFloat buttonWidth;
    if (isLandscape) {
        buttonWidth = (self.frame.size.width - (6.0f * idLabelWidth) - (8.0f * textFieldWidth)) / 16.0;
        yPos -= buttonYMargin;
    } else {
        buttonWidth = (self.frame.size.width - (3.0f * idLabelWidth) - (4.0f * textFieldWidth)) / 8.0;
    }
    
    CGFloat viewWidth = (2.0f * (buttonWidth - kButtonXMargin)) + textFieldWidth;
    
    for (int idx=0; idx < kNumSources; idx++) {
        
        UILabel* idLabel = (UILabel*)_idLabels[idx];
        UIView* numBorderView = (UIView*)_numBorders[idx];
        UIButton* numIncButton = (UIButton*)_numIncButtons[idx];
        UITextField* numTextField = (UITextField*)_textFields[kNumerator][idx];
        UIButton* numDecButton = (UIButton*)_numDecButtons[idx];
        UIView* denBorderView = (UIView*)_denBorders[idx];
        UITextField* denTextField = (UITextField*)_textFields[kDenominator][idx];
        UIButton* denIncButton = (UIButton*)_denIncButtons[idx];
        UIButton* denDecButton = (UIButton*)_denDecButtons[idx];
        
        
        if (isLandscape) {
            
            int column = idx % 4;
            
            switch (column) {
                case 0:
                case 1:
                    xPos = (column == 0) ? 0.0f : (idLabelWidth + (4.0f * buttonWidth) + (2.0f * textFieldWidth) + (3.0f * kButtonXMargin));
                    [idLabel setFrame:CGRectMake(xPos, yPos, idLabelWidth, componentHeight)];
                    xPos += idLabelWidth;
                    [numBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                    [numIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    xPos += buttonWidth;
                    [numTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                    xPos += textFieldWidth;
                    [numDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    xPos += buttonWidth;
                    [denBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                    [denIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    xPos += buttonWidth;
                    [denTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                    xPos += textFieldWidth;
                    [denDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    break;
                    
                case 2:
                case 3:
                    xPos = (column == 2) ? (self.frame.size.width - (2.0f * idLabelWidth) - (4.0f * buttonWidth) - (2.0f * textFieldWidth) - (3.0f * kButtonXMargin)) : (self.frame.size.width - idLabelWidth);
                    [idLabel setFrame:CGRectMake(xPos, yPos, idLabelWidth, componentHeight)];
                    xPos -= buttonWidth;
                    [denDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    xPos -= textFieldWidth;
                    [denTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                    xPos -= buttonWidth;
                    [denIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    [denBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                    xPos -= buttonWidth;
                    [numDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    xPos -= textFieldWidth;
                    [numTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                    xPos -= buttonWidth;
                    [numIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                    [numBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                    if (column == 3) {
                        yPos += componentHeight;
                    }
                    break;
                    
                default:
                    break;
            }
        }
        
        
        else { // if portrait orientation
            if ((idx % 2) == 0) {
                xPos = 0.0f;
                [idLabel setFrame:CGRectMake(xPos, yPos, idLabelWidth, componentHeight)];
                xPos += idLabelWidth;
                [numBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                [numIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                xPos += buttonWidth;
                [numTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                xPos += textFieldWidth;
                [numDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                xPos += buttonWidth;
                [denBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                [denIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                xPos += buttonWidth;
                [denTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                xPos += textFieldWidth;
                [denDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
            } else {
                xPos = self.frame.size.width - idLabelWidth;
                [idLabel setFrame:CGRectMake(xPos, yPos, idLabelWidth, componentHeight)];
                xPos -= buttonWidth;
                [denDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                xPos -= textFieldWidth;
                [denTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                xPos -= buttonWidth;
                [denIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                [denBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                xPos -= buttonWidth;
                [numDecButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                xPos -= textFieldWidth;
                [numTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
                xPos -= buttonWidth;
                [numIncButton setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, buttonWidth - (2.0f * kButtonXMargin), componentHeight - (2.0f * buttonYMargin))];
                [numBorderView setFrame:CGRectMake(xPos + kButtonXMargin, yPos + buttonYMargin, viewWidth, componentHeight - (2.0f * buttonYMargin))];
                
                yPos += componentHeight;
            }
        }
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)rootFreqSliderChanged {
    float frequency = _rootFreqSlider.value;
    [[TWMasterController sharedController] setRootFrequency:frequency];
    [_rootFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    [_oscView refreshParametersWithAnimation:YES];
}

- (void)rampTimeSliderChanged {
    int rampTime_ms = _rampTimeSlider.value;
    [[TWMasterController sharedController] setRampTime_ms:rampTime_ms];
    [_rampTimeField setText:[NSString stringWithFormat:@"%d", rampTime_ms]];
    [_oscView refreshParametersWithAnimation:YES];
}


- (void)incNumButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] incNumeratorRatioAt:sourceIdx];
    UITextField* textField = (UITextField*)_textFields[kNumerator][sourceIdx];
    [textField setText:[NSString stringWithFormat:@"%d", newRatio]];
    [self updateOscView:sourceIdx];
}

- (void)decNumButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] decNumeratorRatioAt:sourceIdx];
    UITextField* textField = (UITextField*)_textFields[kNumerator][sourceIdx];
    [textField setText:[NSString stringWithFormat:@"%d", newRatio]];
    [self updateOscView:sourceIdx];
}

- (void)incDenButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] incDenominatorRatioAt:sourceIdx];
    UITextField* textField = (UITextField*)_textFields[kDenominator][sourceIdx];
    [textField setText:[NSString stringWithFormat:@"%d", newRatio]];
    [self updateOscView:sourceIdx];
}

- (void)decDenButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] decDenominatorRatioAt:sourceIdx];
    UITextField* textField = (UITextField*)_textFields[kDenominator][sourceIdx];
    [textField setText:[NSString stringWithFormat:@"%d", newRatio]];
    [self updateOscView:sourceIdx];
}


- (void)tapTempoButtonDown:(UIButton*)sender {
    [_tapTempoButton setBackgroundColor:[UIColor colorWithWhite:0.14 alpha:0.9]];
}

- (void)tapTempoButtonUp:(UIButton*)sender {
    [_tapTempoButton setBackgroundColor:[UIColor colorWithWhite:0.24 alpha:0.8]];
}

#pragma - UITextFieldDelegate

- (void)keyboardDoneButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    if (currentResponder == _rootFreqField) {
        float frequency = [[_rootFreqField text] floatValue];
        [[TWMasterController sharedController] setRootFrequency:frequency];
        [_rootFreqSlider setValue:frequency animated:YES];
        [_oscView refreshParametersWithAnimation:YES];
    }
    
    else if (currentResponder == _rampTimeField) {
        int rampTime_ms = [[_rampTimeField text] intValue];
        [[TWMasterController sharedController] setRampTime_ms:rampTime_ms];
        [_rampTimeSlider setValue:rampTime_ms animated:YES];
        [_oscView refreshParametersWithAnimation:YES];
    }
    
    else {
        for (UITextField* numTextField in _textFields[kNumerator]) {
            if (numTextField == currentResponder) {
                int sourceIdx = (int)(currentResponder.tag / 2.0f);
                int ratio = [[currentResponder text] intValue];
                [[TWMasterController sharedController] setNumeratorRatio:ratio at:sourceIdx];
                [self updateOscView:sourceIdx];
                break;
            }
        }
        for (UITextField* denTextField in _textFields[kDenominator]) {
            if (denTextField == currentResponder) {
                int sourceIdx = (int)(currentResponder.tag / 2.0f);
                int ratio = [[currentResponder text] intValue];
                [[TWMasterController sharedController] setDenominatorRatio:ratio at:sourceIdx];
                [self updateOscView:sourceIdx];
                break;
            }
        }
    }
    
    [currentResponder resignFirstResponder];
}


- (void)keyboardCancelButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    if (currentResponder == _rootFreqField) {
        float frequency = [_rootFreqSlider value];
        [_rootFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    }
    
    else if (currentResponder == _rampTimeField) {
        int rampTime_ms = (int)[_rampTimeSlider value];
        [_rampTimeField setText:[NSString stringWithFormat:@"%d", rampTime_ms]];
    }
    
    else {
        for (UITextField* numTextField in _textFields[kNumerator]) {
            if (numTextField == currentResponder) {
                int sourceIdx = (int)(currentResponder.tag / 2.0f);
                int ratio = [[TWMasterController sharedController] getNumeratorRatioAt:sourceIdx];
                [currentResponder setText:[NSString stringWithFormat:@"%d", ratio]];
                [self updateOscView:sourceIdx];
                break;
            }
        }
        for (UITextField* denTextField in _textFields[kDenominator]) {
            if (denTextField == currentResponder) {
                int sourceIdx = (int)(currentResponder.tag / 2.0f);
                int ratio = [[TWMasterController sharedController] getDenominatorRatioAt:sourceIdx];
                [currentResponder setText:[NSString stringWithFormat:@"%d", ratio]];
                [self updateOscView:sourceIdx];
                break;
            }
        }
    }
    
    [currentResponder resignFirstResponder];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[TWKeyboardAccessoryView sharedView] setValueText:[textField text]];
    NSString* titleText;
    if (textField == _rootFreqField) {
        titleText = @"Root Freq: ";
    } else if (textField == _rampTimeField) {
        titleText = @"Ramp Time: ";
    } else {
        int tag = (int)textField.tag;
        int oscID = (int)tag / 2.0f;
        int denOrNum = tag % 2;
        titleText = denOrNum ? [NSString stringWithFormat:@"Osc[%d]. Den: ", oscID+1] : [NSString stringWithFormat:@"Osc[%d]. Num: ", oscID+1];
    }
    [[TWKeyboardAccessoryView sharedView] setTitleText:titleText];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField selectAll:nil];
    [[TWKeyboardAccessoryView sharedView] setCurrentResponder:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [[TWKeyboardAccessoryView sharedView] setValueText:[[textField text] stringByReplacingCharactersInRange:range withString:string]];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}



- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}





- (void)updateNumeratorTextFiedWithRatio:(int)ratio atIdx:(int)idx {
    
}

- (void)updateDenominatorTextFiedWithRatio:(int)ratio atIdx:(int)idx {
    
}



- (void)updateOscView:(int)sourceIdx {
    if ([_oscView respondsToSelector:@selector(setOscID:)]) {
        [_oscView setOscID:sourceIdx];
    }
}

@end

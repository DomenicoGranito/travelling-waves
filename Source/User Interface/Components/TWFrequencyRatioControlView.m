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
#import "TWClock.h"
#import "TWUtils.h"
#import "TWKeypad.h"
#import "UIColor+Additions.h"

#import <QuartzCore/QuartzCore.h>

#define kLocalTitleLabelWidth      40.0f

@interface TWFrequencyRatioControlView() <TWKeypadDelegate>
{
    UILabel*                    _rootFreqLabel;
    UISlider*                   _rootFreqSlider;
    UIButton*                   _rootFreqField;
    
    UILabel*                    _rampTimeLabel;
    UISlider*                   _rampTimeSlider;
    UIButton*                   _rampTimeField;
    
    UILabel*                    _tempoLabel;
    UISlider*                   _tempoSlider;
    UIButton*                   _tempoField;
    
    UIButton*                   _tapTempoButton;
    int                         _tapTempoCount;
    NSTimeInterval              _tapTempoCurrentTime;
    double                      _movingAverageTempo;
    
    UISegmentedControl*         _segmentedControl;
    TWTimeRatioControl          _currentControl;
    NSArray<UIColor*>*          _segmentTintColors;
    NSArray<UIColor*>*          _segmentBackColors;
    UIView*                     _segmentBackView;
    
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

//    [[TWKeypad sharedKeypad] addToDelegates:self];
    
    
    _rootFreqLabel = [[UILabel alloc] init];
    [_rootFreqLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_rootFreqLabel setText:@"Root F:"];
    [_rootFreqLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_rootFreqLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_rootFreqLabel];
    
    _rootFreqSlider = [[UISlider alloc] init];
    [_rootFreqSlider setMinimumValue:0.0f];
    [_rootFreqSlider setMaximumValue:1.0f];
    [_rootFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_rootFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_rootFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_rootFreqSlider addTarget:self action:@selector(rootFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rootFreqSlider];
    
    _rootFreqField = [[UIButton alloc] init];
    [_rootFreqField setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [_rootFreqField.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_rootFreqField setBackgroundColor:[UIColor clearColor]];
    [_rootFreqField addTarget:self action:@selector(rootFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
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
    [_rampTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_rampTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_rampTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_rampTimeSlider addTarget:self action:@selector(rampTimeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rampTimeSlider];
    
    _rampTimeField = [[UIButton alloc] init];
    [_rampTimeField setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [_rampTimeField.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_rampTimeField setBackgroundColor:[UIColor clearColor]];
    [_rampTimeField addTarget:self action:@selector(rampTimeFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rampTimeField];
    
    
    
    _tempoLabel = [[UILabel alloc] init];
    [_tempoLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_tempoLabel setText:@"Tempo:"];
    [_tempoLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_tempoLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:_tempoLabel];
    
    _tempoSlider = [[UISlider alloc] init];
    [_tempoSlider setMinimumValue:20.0f];
    [_tempoSlider setMaximumValue:400.0f];
    [_tempoSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tempoSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tempoSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tempoSlider addTarget:self action:@selector(tempoSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_tempoSlider];
    
    _tempoField = [[UIButton alloc] init];
    [_tempoField setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [_tempoField.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_tempoField setBackgroundColor:[UIColor clearColor]];
    [_tempoField addTarget:self action:@selector(tempoFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tempoField];

    
    
    _tapTempoButton = [[UIButton alloc] init];
    [_tapTempoButton setTitle:@"Tap Tempo" forState:UIControlStateNormal];
    [_tapTempoButton setBackgroundColor:[UIColor colorWithWhite:0.24 alpha:0.8]];
    [_tapTempoButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_tapTempoButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
    [_tapTempoButton setTag:999];
    [_tapTempoButton addTarget:self action:@selector(tapTempoButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_tapTempoButton addTarget:self action:@selector(tapTempoButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tapTempoButton];

    
    _segmentTintColors = [[NSArray alloc] initWithArray:[UIColor timeRatioControlTintColors]];
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    NSArray* segments = @[@"Base", @"Beat", @"Tremolo", @"Shape Tremolo", @"Filter LFO"];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
    [_segmentedControl setBackgroundColor:[UIColor colorWithWhite:0.16f alpha:1.0f]];
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_segmentedControl setTintColor:[UIColor segmentedControlTintColor]];
    [_segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_segmentedControl];
    
    
    _segmentBackColors = [[NSArray alloc] initWithArray:[UIColor timeRatioControlBackColors]];
    _segmentBackView = [[UIView alloc] init];
    [_segmentBackView setBackgroundColor:[UIColor frequencyRatioControlBackgroundColor]];
    [_segmentBackView setUserInteractionEnabled:NO];
    [self addSubview:_segmentBackView];
    
    
    
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
        
        UIButton* numTextField = [[UIButton alloc] initWithFrame:CGRectZero];
        [numTextField setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        [numTextField.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [numTextField setBackgroundColor:[UIColor clearColor]];
        [numTextField setTag:(idx * 2)];
        [numTextField addTarget:self action:@selector(ratioFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
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
        
        UIButton* denTextField = [[UIButton alloc] initWithFrame:CGRectZero];
        [denTextField setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.0f] forState:UIControlStateNormal];
        [denTextField.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [denTextField setBackgroundColor:[UIColor clearColor]];
        [denTextField setTag:(idx * 2) + 1];
        [denTextField addTarget:self action:@selector(ratioFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    
    
    [self setBackgroundColor:[UIColor frequencyRatioControlBackgroundColor]];
}


- (void)refreshParametersWithAnimation:(BOOL)animated {
    float frequency = [[TWMasterController sharedController] rootFrequency];
    [self setRootFrequencySlider:frequency];
    [_rootFreqField setTitle:[NSString stringWithFormat:@"%.2f", frequency] forState:UIControlStateNormal];
    
    int rampTime_ms = [[TWMasterController sharedController] rampTime_ms];
    [_rampTimeSlider setValue:rampTime_ms animated:animated];
    [_rampTimeField setTitle:[NSString stringWithFormat:@"%d", rampTime_ms] forState:UIControlStateNormal];
    
    float tempo = [[TWMasterController sharedController] tempo];
    [_tempoSlider setValue:tempo animated:animated];
    [_tempoField setTitle:[NSString stringWithFormat:@"%.2f", tempo] forState:UIControlStateNormal];
    
    [_segmentedControl setSelectedSegmentIndex:0];
    _currentControl = TWTimeRatioControl_BaseFrequency;
    
    [self refreshControlUI];
    
    _tapTempoCount          = 0;
    _tapTempoCurrentTime    = 0.0f;
    _movingAverageTempo     = tempo;
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
    [_tempoLabel setFrame:CGRectMake(xPos, yPos, kLocalTitleLabelWidth, componentHeight)];
    
    xPos += kLocalTitleLabelWidth;
    [_tempoSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += sliderWidth;
    [_tempoField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _tempoField.frame.size.width;
    CGFloat tapTempoButtonWidth = frame.size.width - xPos;
    [_tapTempoButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, tapTempoButtonWidth - 5.0f, componentHeight - (2.0f * kButtonYMargin))];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_segmentedControl setFrame:CGRectMake(xPos, yPos + 5.0f, frame.size.width, componentHeight - 10.0f)];
    
    
    yPos += componentHeight;
    
    [_segmentBackView setFrame:CGRectMake(xPos, yPos - 5.0f, frame.size.width, frame.size.height - yPos)];
    
    
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
    float value = [TWUtils logScaleFromLinear:_rootFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWMasterController sharedController] setRootFrequency:value];
    [_rootFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
    [_oscView refreshParametersWithAnimation:YES];
}

- (void)rampTimeSliderChanged {
    int rampTime_ms = _rampTimeSlider.value;
    [[TWMasterController sharedController] setRampTime_ms:rampTime_ms];
    [_rampTimeField setTitle:[NSString stringWithFormat:@"%d", rampTime_ms] forState:UIControlStateNormal];
    [_oscView refreshParametersWithAnimation:YES];
}

- (void)tempoSliderChanged {
    float tempo = _tempoSlider.value;
    [[TWMasterController sharedController] setTempo:tempo];
    [_tempoField setTitle:[NSString stringWithFormat:@"%.2f", tempo] forState:UIControlStateNormal];
    [_oscView refreshParametersWithAnimation:YES];
}


- (void)incNumButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] incNumeratorRatioForControl:_currentControl atSourceIdx:sourceIdx];
    UIButton* field = (UIButton*)_textFields[kNumerator][sourceIdx];
    [field setTitle:[NSString stringWithFormat:@"%d", newRatio] forState:UIControlStateNormal];
    [self updateOscView:sourceIdx];
}

- (void)decNumButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] decNumeratorRatioForControl:_currentControl atSourceIdx:sourceIdx];
    UIButton* field = (UIButton*)_textFields[kNumerator][sourceIdx];
    [field setTitle:[NSString stringWithFormat:@"%d", newRatio] forState:UIControlStateNormal];
    [self updateOscView:sourceIdx];
}

- (void)incDenButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] incDenominatorRatioForControl:_currentControl atSourceIdx:sourceIdx];
    UIButton* field = (UIButton*)_textFields[kDenominator][sourceIdx];
    [field setTitle:[NSString stringWithFormat:@"%d", newRatio] forState:UIControlStateNormal];
    [self updateOscView:sourceIdx];
}

- (void)decDenButtonTapped:(UIButton*)sender {
    int sourceIdx = (int)sender.tag;
    int newRatio = [[TWMasterController sharedController] decDenominatorRatioForControl:_currentControl atSourceIdx:sourceIdx];
    UIButton* field = (UIButton*)_textFields[kDenominator][sourceIdx];
    [field setTitle:[NSString stringWithFormat:@"%d", newRatio] forState:UIControlStateNormal];
    [self updateOscView:sourceIdx];
}


- (void)tapTempoButtonDown:(UIButton*)sender {
    [self tapTempo];
    [_tapTempoButton setBackgroundColor:[UIColor colorWithWhite:0.14 alpha:0.9]];
}

- (void)tapTempoButtonUp:(UIButton*)sender {
    [_tapTempoButton setBackgroundColor:[UIColor colorWithWhite:0.24 alpha:0.8]];
}

- (void)segmentValueChanged:(UISegmentedControl*)sender {
    _currentControl = (TWTimeRatioControl)sender.selectedSegmentIndex;
    [self refreshControlUI];
}



- (void)updateNumeratorTextFiedWithRatio:(int)ratio atIdx:(int)idx {
    
}

- (void)updateDenominatorTextFiedWithRatio:(int)ratio atIdx:(int)idx {
    
}



- (void)updateOscView:(int)sourceIdx {
    if ([_oscView respondsToSelector:@selector(setSourceIdx:)]) {
        [_oscView setSourceIdx:sourceIdx];
    }
}



- (void)refreshControlUI {
    for (int idx=0; idx < kNumSources; idx++) {
        int numerator = [[TWMasterController sharedController] getNumeratorRatioForControl:_currentControl atSourceIdx:idx];
        UIButton* numTextField = (UIButton*)_textFields[kNumerator][idx];
        [numTextField setTitle:[NSString stringWithFormat:@"%d", numerator] forState:UIControlStateNormal];
        
        int denominator = [[TWMasterController sharedController] getDenominatorRatioForControl:_currentControl atSourceIdx:idx];
        UIButton* denTextField = (UIButton*)_textFields[kDenominator][idx];
        [denTextField setTitle:[NSString stringWithFormat:@"%d", denominator] forState:UIControlStateNormal];
    }
    [_segmentedControl setTintColor:[_segmentTintColors objectAtIndex:(int)_currentControl]];
    [_segmentBackView setBackgroundColor:[_segmentBackColors objectAtIndex:(int)_currentControl]];
}

- (void)tapTempo {
    NSTimeInterval currentTime = [[TWClock sharedClock] getCurrentTime];
    NSTimeInterval elapsedTime = currentTime - _tapTempoCurrentTime;
//    NSLog(@"CurrentTime: %f. ElapsedTime: %f", currentTime, elapsedTime);
    
    if (elapsedTime > 3.0f) {
        _tapTempoCount = 0;
        _movingAverageTempo = [[TWMasterController sharedController] tempo];
    } else {
        _movingAverageTempo = (_movingAverageTempo + (60.0f / elapsedTime)) / 2.0f;
    }
    
//    NSLog(@"Moving Average Tempo: %f", _movingAverageTempo);
    
    _tapTempoCount++;
    _tapTempoCurrentTime = currentTime;
    
    if (_tapTempoCount >= 3) {
        [[TWMasterController sharedController] setTempo:_movingAverageTempo];
        [_tempoSlider setValue:_movingAverageTempo animated:YES];
        [_tempoField setTitle:[NSString stringWithFormat:@"%.2f", _movingAverageTempo] forState:UIControlStateNormal];
        [_oscView refreshParametersWithAnimation:YES];
    }
}


- (void)setRootFrequencySlider:(float)value {
    [_rootFreqSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
}


#pragma mark - TWKeypadDelegate

- (void)keypadDoneButtonTapped:(id)senderKeypad forComponent:(UIView *)responder withValue:(NSString *)inValue {
//- (void)keypadDoneButtonTapped:(UIButton *)responder withValue:(NSString *)inValue {
    
    if (responder == _rootFreqField) {
        float frequency = [inValue floatValue];
        [[TWMasterController sharedController] setRootFrequency:frequency];
        [_rootFreqField setTitle:[NSString stringWithFormat:@"%.2f", frequency] forState:UIControlStateNormal];
        [self setRootFrequencySlider:frequency];
        [_oscView refreshParametersWithAnimation:YES];
    }
    
    else if (responder == _rampTimeField) {
        int rampTime_ms = [inValue intValue];
        [[TWMasterController sharedController] setRampTime_ms:rampTime_ms];
        [_rampTimeField setTitle:[NSString stringWithFormat:@"%d", rampTime_ms] forState:UIControlStateNormal];
        [_rampTimeSlider setValue:rampTime_ms animated:YES];
        [_oscView refreshParametersWithAnimation:YES];
    }
    
    else if (responder == _tempoField) {
        float tempo = [inValue floatValue];
        [[TWMasterController sharedController] setTempo:tempo];
        [_tempoField setTitle:[NSString stringWithFormat:@"%.2f", tempo] forState:UIControlStateNormal];
        [_tempoSlider setValue:tempo animated:YES];
        [_oscView refreshParametersWithAnimation:YES];
    }
    
    else {
        for (UIButton* numField in _textFields[kNumerator]) {
            if (responder == numField) {
                int sourceIdx = (int)(numField.tag / 2.0f);
                int ratio = [[[TWKeypad sharedKeypad] value] intValue];
                [[TWMasterController sharedController] setNumeratorRatioForControl:_currentControl withValue:ratio atSourceIdx:sourceIdx];
                [numField setTitle:[NSString stringWithFormat:@"%d", ratio] forState:UIControlStateNormal];
                [self updateOscView:sourceIdx];
                break;
            }
        }
        for (UIButton* denField in _textFields[kDenominator]) {
            if (responder == denField) {
                int sourceIdx = (int)(denField.tag / 2.0f);
                int ratio = [[[TWKeypad sharedKeypad] value] intValue];
                [[TWMasterController sharedController] setDenominatorRatioForControl:_currentControl withValue:ratio atSourceIdx:sourceIdx];
                [denField setTitle:[NSString stringWithFormat:@"%d", ratio] forState:UIControlStateNormal];
                [self updateOscView:sourceIdx];
                break;
            }
        }
    }
}

- (void)keypadCancelButtonTapped:(id)senderKeypad forComponent:(UIView *)responder {
//- (void)keypadCancelButtonTapped:(UIButton *)responder {
    
    if (responder == _rootFreqField) {
        float frequency = [[TWMasterController sharedController] rootFrequency];
        [_rootFreqField setTitle:[NSString stringWithFormat:@"%.2f", frequency] forState:UIControlStateNormal];
    }
    
    else if (responder == _rampTimeField) {
        int rampTime_ms = [[TWMasterController sharedController] rampTime_ms];
        [_rampTimeField setTitle:[NSString stringWithFormat:@"%d", rampTime_ms] forState:UIControlStateNormal];
    }
    
    else if (responder == _tempoField) {
        float tempo = [[TWMasterController sharedController] tempo];
        [_tempoField setTitle:[NSString stringWithFormat:@"%.2f", tempo] forState:UIControlStateNormal];
    }
    
    else {
        for (UIButton* numField in _textFields[kNumerator]) {
            if (responder == numField) {
                int sourceIdx = (int)(responder.tag / 2.0f);
                int ratio = [[TWMasterController sharedController] getNumeratorRatioForControl:_currentControl atSourceIdx:sourceIdx];
                [numField setTitle:[NSString stringWithFormat:@"%d", ratio] forState:UIControlStateNormal];
                [self updateOscView:sourceIdx];
                break;
            }
        }
        for (UIButton* denField in _textFields[kDenominator]) {
            if (responder == denField) {
                int sourceIdx = (int)(responder.tag / 2.0f);
                int ratio = [[TWMasterController sharedController] getDenominatorRatioForControl:_currentControl atSourceIdx:sourceIdx];
                [denField setTitle:[NSString stringWithFormat:@"%d", ratio] forState:UIControlStateNormal];
                [self updateOscView:sourceIdx];
                break;
            }
        }
    }
}



- (void)rootFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Root Frequency (Hz): "];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWMasterController sharedController] rootFrequency]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:_rootFreqField];
}

- (void)rampTimeFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Ramp Time (ms): "];
    [keypad setValue:[NSString stringWithFormat:@"%d", [[TWMasterController sharedController] rampTime_ms]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:_rampTimeField];
}

- (void)tempoFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Tempo: "];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWMasterController sharedController] tempo]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:_tempoField];
}

- (void)ratioFieldTapped:(UIButton*)sender {
    
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    
    int tag = (int)sender.tag;
    int sourceIdx = (int)tag / 2.0f;
    int denOrNum = tag % 2;
    
    
    NSString* titleText;
    
    switch (_currentControl) {
            
        case TWTimeRatioControl_BaseFrequency:
            titleText = denOrNum ? [NSString stringWithFormat:@"Osc[%d] Den: ", sourceIdx+1] : [NSString stringWithFormat:@"Osc[%d] Num: ", sourceIdx+1];
            break;
            
        case TWTimeRatioControl_BeatFrequency:
            titleText = denOrNum ? [NSString stringWithFormat:@"Beat[%d] Den: ", sourceIdx+1] : [NSString stringWithFormat:@"Beat[%d] Num: ", sourceIdx+1];
            break;
            
        case TWTimeRatioControl_TremFrequency:
            titleText = denOrNum ? [NSString stringWithFormat:@"Tremolo[%d] Den: ", sourceIdx+1] : [NSString stringWithFormat:@"Tremolo[%d] Num: ", sourceIdx+1];
            break;
            
        case TWTimeRatioControl_FilterLFOFrequency:
            titleText = denOrNum ? [NSString stringWithFormat:@"Filter LFO[%d] Den: ", sourceIdx+1] : [NSString stringWithFormat:@"Filter LFO[%d] Num: ", sourceIdx+1];
            break;
            
        default:
            break;
    }
    
    [keypad setTitle:titleText];
    
    
    int value = 0;
    if (denOrNum) {
        value = [[TWMasterController sharedController] getDenominatorRatioForControl:_currentControl atSourceIdx:sourceIdx];
    } else {
        value = [[TWMasterController sharedController] getNumeratorRatioForControl:_currentControl atSourceIdx:sourceIdx];
    }
    
    [keypad setValue:[NSString stringWithFormat:@"%d", value]];
    
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:sender];
}

@end

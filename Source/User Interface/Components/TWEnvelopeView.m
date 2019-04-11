//
//  TWEnvelopeView.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/10/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWEnvelopeView.h"
#import "TWAudioController.h"
#import "TWHeader.h"
#import "TWKeyboardAccessoryView.h"
#import "UIColor+Additions.h"

@interface TWEnvelopeView() <UITextFieldDelegate, TWKeyboardAccessoryViewDelegate>
{
    UILabel*                    _ampATLabel;
    UISlider*                   _ampAttackTimeSlider;
    UITextField*                _ampAttackTimeTextField;
    
    UILabel*                    _ampSTLabel;
    UISlider*                   _ampSustainTimeSlider;
    UITextField*                _ampSustainTimeTextField;
    
    UILabel*                    _ampRTLabel;
    UISlider*                   _ampReleaseTimeSlider;
    UITextField*                _ampReleaseTimeTextField;
    
    
    
    UISwitch*                   _filterEnableSwitch;
    UISegmentedControl*         _filterSelector;
    UISlider*                   _resonanceSlider;
    UITextField*                _resonanceField;
    
    UISlider*                   _fromCutoffFreqSlider;
    UITextField*                _fromCutoffFreqField;
    
    UISlider*                   _toCutoffFreqSlider;
    UITextField*                _toCutoffFreqField;
    
    
    UILabel*                    _fltATLabel;
    UISlider*                   _fltAttackTimeSlider;
    UITextField*                _fltAttackTimeTextField;
    
    UILabel*                    _fltSTLabel;
    UISlider*                   _fltSustainTimeSlider;
    UITextField*                _fltSustainTimeTextField;
    
    UILabel*                    _fltRTLabel;
    UISlider*                   _fltReleaseTimeSlider;
    UITextField*                _fltReleaseTimeTextField;
    
    
    
    UILabel*                    _intervalLabel;
    UISegmentedControl*         _intervalSelectorRow1;
    UISegmentedControl*         _intervalSelectorRow2;
}
@end


@implementation TWEnvelopeView

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    TWKeyboardAccessoryView* accView = [TWKeyboardAccessoryView sharedView];
    [accView addToDelegates:self];
    
    
    // Amplitude Envelope
    
    _ampATLabel = [[UILabel alloc] init];
    [_ampATLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_ampATLabel setText:@"AAt:"];
    [_ampATLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_ampATLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_ampATLabel];
    
    _ampAttackTimeSlider = [[UISlider alloc] init];
    [_ampAttackTimeSlider setMinimumValue:1.0f];
    [_ampAttackTimeSlider setMaximumValue:500.0f];
    [_ampAttackTimeSlider addTarget:self action:@selector(ampAttackTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_ampAttackTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_ampAttackTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_ampAttackTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_ampAttackTimeSlider];
    
    _ampAttackTimeTextField = [[UITextField alloc] init];
    [_ampAttackTimeTextField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_ampAttackTimeTextField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_ampAttackTimeTextField setFont:[UIFont systemFontOfSize:11.0f]];
    [_ampAttackTimeTextField setTextAlignment:NSTextAlignmentCenter];
    [_ampAttackTimeTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_ampAttackTimeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_ampAttackTimeTextField setInputAccessoryView:accView];
    [_ampAttackTimeTextField setBackgroundColor:[UIColor clearColor]];
    [_ampAttackTimeTextField setDelegate:self];
    [self addSubview:_ampAttackTimeTextField];
    
    
    _ampSTLabel = [[UILabel alloc] init];
    [_ampSTLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_ampSTLabel setText:@"ASt:"];
    [_ampSTLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_ampSTLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_ampSTLabel];
    
    _ampSustainTimeSlider = [[UISlider alloc] init];
    [_ampSustainTimeSlider setMinimumValue:1.0f];
    [_ampSustainTimeSlider setMaximumValue:2000.0f];
    [_ampSustainTimeSlider addTarget:self action:@selector(ampSustainTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_ampSustainTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_ampSustainTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_ampSustainTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_ampSustainTimeSlider];
    
    _ampSustainTimeTextField = [[UITextField alloc] init];
    [_ampSustainTimeTextField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_ampSustainTimeTextField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_ampSustainTimeTextField setFont:[UIFont systemFontOfSize:11.0f]];
    [_ampSustainTimeTextField setTextAlignment:NSTextAlignmentCenter];
    [_ampSustainTimeTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_ampSustainTimeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_ampSustainTimeTextField setInputAccessoryView:accView];
    [_ampSustainTimeTextField setBackgroundColor:[UIColor clearColor]];
    [_ampSustainTimeTextField setDelegate:self];
    [self addSubview:_ampSustainTimeTextField];
    
    _ampRTLabel = [[UILabel alloc] init];
    [_ampRTLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_ampRTLabel setText:@"ARt:"];
    [_ampRTLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_ampRTLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_ampRTLabel];
    
    _ampReleaseTimeSlider = [[UISlider alloc] init];
    [_ampReleaseTimeSlider setMinimumValue:1.0f];
    [_ampReleaseTimeSlider setMaximumValue:4000.0f];
    [_ampReleaseTimeSlider addTarget:self action:@selector(ampReleaseTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_ampReleaseTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_ampReleaseTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_ampReleaseTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_ampReleaseTimeSlider];
    
    _ampReleaseTimeTextField = [[UITextField alloc] init];
    [_ampReleaseTimeTextField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_ampReleaseTimeTextField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_ampReleaseTimeTextField setFont:[UIFont systemFontOfSize:11.0f]];
    [_ampReleaseTimeTextField setTextAlignment:NSTextAlignmentCenter];
    [_ampReleaseTimeTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_ampReleaseTimeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_ampReleaseTimeTextField setInputAccessoryView:accView];
    [_ampReleaseTimeTextField setBackgroundColor:[UIColor clearColor]];
    [_ampReleaseTimeTextField setDelegate:self];
    [self addSubview:_ampReleaseTimeTextField];
    
    
    
    
    // Filter Envelope
    
    _filterEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_filterEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch addTarget:self action:@selector(filterEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterEnableSwitch];
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    _filterSelector = [[UISegmentedControl alloc] initWithItems:@[@"LPF", @"HPF", @"BPF1", @"BPF2", @"Ntch"]];
    [_filterSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_filterSelector setTintColor:[UIColor sliderOnColor]];
    [_filterSelector setBackgroundColor:[UIColor sliderOffColor]];
    [_filterSelector addTarget:self action:@selector(filterTypeChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterSelector];
    
    _resonanceSlider = [[UISlider alloc] init];
    [_resonanceSlider setMinimumValue:0.0f];
    [_resonanceSlider setMaximumValue:6.0f];
    [_resonanceSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_resonanceSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_resonanceSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_resonanceSlider addTarget:self action:@selector(resonanceSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_resonanceSlider];
    
    _resonanceField = [[UITextField alloc] init];
    [_resonanceField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_resonanceField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_resonanceField setFont:[UIFont systemFontOfSize:11.0f]];
    [_resonanceField setTextAlignment:NSTextAlignmentCenter];
    [_resonanceField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_resonanceField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_resonanceField setInputAccessoryView:accView];
    [_resonanceField setBackgroundColor:[UIColor clearColor]];
    [_resonanceField setDelegate:self];
    [self addSubview:_resonanceField];
    
    _fromCutoffFreqSlider = [[UISlider alloc] init];
    [_fromCutoffFreqSlider setMinimumValue:1.0f];
    [_fromCutoffFreqSlider setMaximumValue:600.0f];
    [_fromCutoffFreqSlider addTarget:self action:@selector(fromCuttoffSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_fromCutoffFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fromCutoffFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fromCutoffFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_fromCutoffFreqSlider];
    
    _fromCutoffFreqField = [[UITextField alloc] init];
    [_fromCutoffFreqField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_fromCutoffFreqField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_fromCutoffFreqField setFont:[UIFont systemFontOfSize:11.0f]];
    [_fromCutoffFreqField setTextAlignment:NSTextAlignmentCenter];
    [_fromCutoffFreqField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_fromCutoffFreqField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_fromCutoffFreqField setInputAccessoryView:accView];
    [_fromCutoffFreqField setBackgroundColor:[UIColor clearColor]];
    [_fromCutoffFreqField setDelegate:self];
    [self addSubview:_fromCutoffFreqField];
    
    _toCutoffFreqSlider = [[UISlider alloc] init];
    [_toCutoffFreqSlider setMinimumValue:1.0f];
    [_toCutoffFreqSlider setMaximumValue:4000.0f];
    [_toCutoffFreqSlider addTarget:self action:@selector(toCuttoffSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_toCutoffFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_toCutoffFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_toCutoffFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_toCutoffFreqSlider];
    
    _toCutoffFreqField = [[UITextField alloc] init];
    [_toCutoffFreqField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_toCutoffFreqField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_toCutoffFreqField setFont:[UIFont systemFontOfSize:11.0f]];
    [_toCutoffFreqField setTextAlignment:NSTextAlignmentCenter];
    [_toCutoffFreqField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_toCutoffFreqField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_toCutoffFreqField setInputAccessoryView:accView];
    [_toCutoffFreqField setBackgroundColor:[UIColor clearColor]];
    [_toCutoffFreqField setDelegate:self];
    [self addSubview:_toCutoffFreqField];
    
    _fltATLabel = [[UILabel alloc] init];
    [_fltATLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_fltATLabel setText:@"FAt:"];
    [_fltATLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_fltATLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_fltATLabel];
    
    _fltAttackTimeSlider = [[UISlider alloc] init];
    [_fltAttackTimeSlider setMinimumValue:1.0f];
    [_fltAttackTimeSlider setMaximumValue:500.0f];
    [_fltAttackTimeSlider addTarget:self action:@selector(fltAttackTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_fltAttackTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fltAttackTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fltAttackTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_fltAttackTimeSlider];
    
    _fltAttackTimeTextField = [[UITextField alloc] init];
    [_fltAttackTimeTextField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_fltAttackTimeTextField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_fltAttackTimeTextField setFont:[UIFont systemFontOfSize:11.0f]];
    [_fltAttackTimeTextField setTextAlignment:NSTextAlignmentCenter];
    [_fltAttackTimeTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_fltAttackTimeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_fltAttackTimeTextField setInputAccessoryView:accView];
    [_fltAttackTimeTextField setBackgroundColor:[UIColor clearColor]];
    [_fltAttackTimeTextField setDelegate:self];
    [self addSubview:_fltAttackTimeTextField];
    
    
    _fltSTLabel = [[UILabel alloc] init];
    [_fltSTLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_fltSTLabel setText:@"FSt:"];
    [_fltSTLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_fltSTLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_fltSTLabel];
    
    _fltSustainTimeSlider = [[UISlider alloc] init];
    [_fltSustainTimeSlider setMinimumValue:1.0f];
    [_fltSustainTimeSlider setMaximumValue:2000.0f];
    [_fltSustainTimeSlider addTarget:self action:@selector(fltSustainTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_fltSustainTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fltSustainTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fltSustainTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_fltSustainTimeSlider];
    
    _fltSustainTimeTextField = [[UITextField alloc] init];
    [_fltSustainTimeTextField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_fltSustainTimeTextField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_fltSustainTimeTextField setFont:[UIFont systemFontOfSize:11.0f]];
    [_fltSustainTimeTextField setTextAlignment:NSTextAlignmentCenter];
    [_fltSustainTimeTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_fltSustainTimeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_fltSustainTimeTextField setInputAccessoryView:accView];
    [_fltSustainTimeTextField setBackgroundColor:[UIColor clearColor]];
    [_fltSustainTimeTextField setDelegate:self];
    [self addSubview:_fltSustainTimeTextField];
    
    _fltRTLabel = [[UILabel alloc] init];
    [_fltRTLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_fltRTLabel setText:@"FRt:"];
    [_fltRTLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_fltRTLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_fltRTLabel];
    
    _fltReleaseTimeSlider = [[UISlider alloc] init];
    [_fltReleaseTimeSlider setMinimumValue:1.0f];
    [_fltReleaseTimeSlider setMaximumValue:4000.0f];
    [_fltReleaseTimeSlider addTarget:self action:@selector(fltReleaseTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_fltReleaseTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fltReleaseTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fltReleaseTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self addSubview:_fltReleaseTimeSlider];
    
    _fltReleaseTimeTextField = [[UITextField alloc] init];
    [_fltReleaseTimeTextField setTextColor:[UIColor valueTextDarkWhiteColor]];
    [_fltReleaseTimeTextField setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_fltReleaseTimeTextField setFont:[UIFont systemFontOfSize:11.0f]];
    [_fltReleaseTimeTextField setTextAlignment:NSTextAlignmentCenter];
    [_fltReleaseTimeTextField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_fltReleaseTimeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_fltReleaseTimeTextField setInputAccessoryView:accView];
    [_fltReleaseTimeTextField setBackgroundColor:[UIColor clearColor]];
    [_fltReleaseTimeTextField setDelegate:self];
    [self addSubview:_fltReleaseTimeTextField];
    
    
    
    
    
    // Interval Selection
    
    _intervalLabel = [[UILabel alloc] init];
    [_intervalLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_intervalLabel setText:@"Int:"];
    [_intervalLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_intervalLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_intervalLabel];
    
    
    NSMutableArray* segmentsRow1 = [[NSMutableArray alloc] init];
    NSMutableArray* segmentsRow2 = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumIntervals / 2; i++) {
        [segmentsRow1 addObject:[NSString stringWithFormat:@"%d", i+1]];
        [segmentsRow2 addObject:[NSString stringWithFormat:@"%d", i + 1 + (kNumIntervals/2)]];
    }
    _intervalSelectorRow1 = [[UISegmentedControl alloc] initWithItems:segmentsRow1];
    [_intervalSelectorRow1 setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_intervalSelectorRow1 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [_intervalSelectorRow1 setTintColor:[UIColor colorWithWhite:0.3f alpha:1.0f]];
    [_intervalSelectorRow1 setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_intervalSelectorRow1 addTarget:self action:@selector(intervalSelectorChangedRow1) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_intervalSelectorRow1];
    
    _intervalSelectorRow2 = [[UISegmentedControl alloc] initWithItems:segmentsRow2];
    [_intervalSelectorRow2 setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    [_intervalSelectorRow2 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [_intervalSelectorRow2 setTintColor:[UIColor colorWithWhite:0.3f alpha:1.0f]];
    [_intervalSelectorRow2 setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_intervalSelectorRow2 addTarget:self action:@selector(intervalSelectorChangedRow2) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_intervalSelectorRow2];
    
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
}


- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    CGFloat xPos = 0.0f;
    CGFloat yPos = 0.0f;
    CGFloat titleLabelWidth = 30.0f;
    CGFloat textFieldWidth = 50.0f;
    CGFloat sliderWidth = frame.size.width - titleLabelWidth - textFieldWidth;
    
    
    // Amplitude Envelope
    
    [_ampATLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_ampAttackTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_ampAttackTimeTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_ampSTLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_ampSustainTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_ampSustainTimeTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_ampRTLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_ampReleaseTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_ampReleaseTimeTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    
    // Filter Envelope
    xPos = 0.0f;
    yPos += componentHeight;
    [_filterEnableSwitch setFrame:CGRectMake(xPos, yPos + ((componentHeight - _filterEnableSwitch.frame.size.height) / 2.0f), 0.0f, 0.0f)];
    
    xPos += _filterEnableSwitch.frame.size.width;
    [_filterSelector setFrame:CGRectMake(xPos, yPos + 5.0f, 160.0f, componentHeight - 10.0f)];
    
    xPos += _filterSelector.frame.size.width;
    [_resonanceSlider setFrame:CGRectMake(xPos, yPos, frame.size.width - xPos - textFieldWidth, componentHeight)];
    
    xPos += _resonanceSlider.frame.size.width;
    [_resonanceField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0;
    CGFloat cutoffSliderWidth = (frame.size.width - (2.0 * textFieldWidth)) / 2.0f;
    [_fromCutoffFreqField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    xPos += textFieldWidth;
    [_fromCutoffFreqSlider setFrame:CGRectMake(xPos, yPos, cutoffSliderWidth, componentHeight)];
    xPos += cutoffSliderWidth;
    [_toCutoffFreqSlider setFrame:CGRectMake(xPos, yPos, cutoffSliderWidth, componentHeight)];
    xPos += cutoffSliderWidth;
    [_toCutoffFreqField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_fltATLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_fltAttackTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_fltAttackTimeTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_fltSTLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_fltSustainTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_fltSustainTimeTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_fltRTLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_fltReleaseTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_fltReleaseTimeTextField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    // Interval Selection
    yPos += componentHeight;
    xPos = 0.0f;
    [_intervalLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_intervalSelectorRow1 setFrame:CGRectMake(xPos, yPos + 5.0f, frame.size.width - titleLabelWidth, componentHeight - 5.0f)];
    yPos += componentHeight;
    [_intervalSelectorRow2 setFrame:CGRectMake(xPos, yPos, frame.size.width - titleLabelWidth, componentHeight - 5.0f)];
}


- (void)setSourceIdx:(int)sourceIdx {
    _sourceIdx = sourceIdx;
    
    // Amplitude Envelope
    int ampAttackTime_ms = [[TWAudioController sharedController] getSeqParameter:kSeqParam_AmpAttackTime atSourceIdx:sourceIdx];
    [_ampAttackTimeSlider setValue:ampAttackTime_ms animated:NO];
    [_ampAttackTimeTextField setText:[NSString stringWithFormat:@"%d", ampAttackTime_ms]];
    
    int ampSustainTime_ms = [[TWAudioController sharedController] getSeqParameter:kSeqParam_AmpSustainTime atSourceIdx:sourceIdx];
    [_ampSustainTimeSlider setValue:ampSustainTime_ms animated:NO];
    [_ampSustainTimeTextField setText:[NSString stringWithFormat:@"%d", ampSustainTime_ms]];
    
    int ampReleaseTime_ms = [[TWAudioController sharedController] getSeqParameter:kSeqParam_AmpReleaseTime atSourceIdx:sourceIdx];
    [_ampReleaseTimeSlider setValue:ampReleaseTime_ms animated:NO];
    [_ampReleaseTimeTextField setText:[NSString stringWithFormat:@"%d", ampReleaseTime_ms]];
    
    
    // Filter Envelope
    [_filterEnableSwitch setOn:[[TWAudioController sharedController] getSeqParameter:kSeqParam_FltEnable atSourceIdx:sourceIdx]];
    [_filterSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getSeqParameter:kSeqParam_FltType atSourceIdx:sourceIdx]];
    
    float resonance = [[TWAudioController sharedController] getSeqParameter:kSeqParam_FltQ atSourceIdx:sourceIdx];
    [_resonanceSlider setValue:resonance animated:NO];
    [_resonanceField setText:[NSString stringWithFormat:@"%.2f", resonance]];
    
    float fromCuttoff = [[TWAudioController sharedController] getSeqParameter:kSeqParam_FltFromCutoff atSourceIdx:sourceIdx];
    [_fromCutoffFreqSlider setValue:fromCuttoff animated:NO];
    [_fromCutoffFreqField setText:[NSString stringWithFormat:@"%.2f", fromCuttoff]];
    
    float toCuttoff = [[TWAudioController sharedController] getSeqParameter:kSeqParam_FltToCutoff atSourceIdx:sourceIdx];
    [_toCutoffFreqSlider setValue:toCuttoff animated:NO];
    [_toCutoffFreqField setText:[NSString stringWithFormat:@"%.2f", toCuttoff]];
    
    
    int fltAttackTime_ms = [[TWAudioController sharedController] getSeqParameter:kSeqParam_FltAttackTime atSourceIdx:sourceIdx];
    [_fltAttackTimeSlider setValue:fltAttackTime_ms animated:NO];
    [_fltAttackTimeTextField setText:[NSString stringWithFormat:@"%d", fltAttackTime_ms]];
    
    int fltSustainTime_ms = [[TWAudioController sharedController] getSeqParameter:kSeqParam_FltSustainTime atSourceIdx:sourceIdx];
    [_fltSustainTimeSlider setValue:fltSustainTime_ms animated:NO];
    [_fltSustainTimeTextField setText:[NSString stringWithFormat:@"%d", fltSustainTime_ms]];
    
    int fltReleaseTime_ms = [[TWAudioController sharedController] getSeqParameter:kSeqParam_FltReleaseTime atSourceIdx:sourceIdx];
    [_fltReleaseTimeSlider setValue:fltReleaseTime_ms animated:NO];
    [_fltReleaseTimeTextField setText:[NSString stringWithFormat:@"%d", fltReleaseTime_ms]];
    
    
    // Interval
    int interval = [[TWAudioController sharedController] getSeqIntervalAtSourceIdx:sourceIdx];
    if (interval <= (kNumIntervals / 2)) {
        [_intervalSelectorRow1 setSelectedSegmentIndex:interval - 1];
        [_intervalSelectorRow2 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    } else {
        [_intervalSelectorRow1 setSelectedSegmentIndex:UISegmentedControlNoSegment];
        [_intervalSelectorRow2 setSelectedSegmentIndex:interval - (kNumIntervals / 2) - 1];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)ampAttackTimeSliderValueChanged {
    int value = _ampAttackTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_AmpAttackTime withValue:value atSourceIdx:_sourceIdx];
    [_ampAttackTimeTextField setText:[NSString stringWithFormat:@"%d", value]];
}

- (void)ampSustainTimeSliderValueChanged {
    int value = _ampSustainTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_AmpSustainTime withValue:value atSourceIdx:_sourceIdx];
    [_ampSustainTimeTextField setText:[NSString stringWithFormat:@"%d", value]];
}

- (void)ampReleaseTimeSliderValueChanged {
    int value = _ampReleaseTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_AmpReleaseTime withValue:value atSourceIdx:_sourceIdx];
    [_ampReleaseTimeTextField setText:[NSString stringWithFormat:@"%d", value]];
}

- (void)filterEnableSwitchChanged {
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltEnable withValue:_filterEnableSwitch.on atSourceIdx:_sourceIdx];
}

- (void)filterTypeChanged {
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltType withValue:_filterSelector.selectedSegmentIndex atSourceIdx:_sourceIdx];
}

- (void)resonanceSliderChanged {
    float value = _resonanceSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltQ withValue:value atSourceIdx:_sourceIdx];
    [_resonanceField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)fromCuttoffSliderValueChanged {
    float value = _fromCutoffFreqSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltFromCutoff withValue:value atSourceIdx:_sourceIdx];
    [_fromCutoffFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)toCuttoffSliderValueChanged {
    float value = _toCutoffFreqSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltToCutoff withValue:value atSourceIdx:_sourceIdx];
    [_toCutoffFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)fltAttackTimeSliderValueChanged {
    int value = _fltAttackTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltAttackTime withValue:value atSourceIdx:_sourceIdx];
    [_fltAttackTimeTextField setText:[NSString stringWithFormat:@"%d", value]];
}

- (void)fltSustainTimeSliderValueChanged {
    int value = _fltSustainTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltSustainTime withValue:value atSourceIdx:_sourceIdx];
    [_fltSustainTimeTextField setText:[NSString stringWithFormat:@"%d", value]];
}

- (void)fltReleaseTimeSliderValueChanged {
    int value = _fltReleaseTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltReleaseTime withValue:value atSourceIdx:_sourceIdx];
    [_fltReleaseTimeTextField setText:[NSString stringWithFormat:@"%d", value]];
}


- (void)intervalSelectorChangedRow1 {
    [_intervalSelectorRow2 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [[TWAudioController sharedController] setSeqInterval:((int)_intervalSelectorRow1.selectedSegmentIndex + 1) atSourceIdx:_sourceIdx];
    if ([_delegate respondsToSelector:@selector(intervalUpdated:)]) {
        [_delegate intervalUpdated:self];
    }
}

- (void)intervalSelectorChangedRow2 {
    [_intervalSelectorRow1 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    int interval = (int)_intervalSelectorRow2.selectedSegmentIndex + (kNumIntervals / 2) + 1;
    [[TWAudioController sharedController] setSeqInterval:interval atSourceIdx:_sourceIdx];
    if ([_delegate respondsToSelector:@selector(intervalUpdated:)]) {
        [_delegate intervalUpdated:self];
    }
}


#pragma mark - UITextFieldDelegate

- (void)keyboardDoneButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    if (currentResponder == _ampAttackTimeTextField) {
        int value = [[_ampAttackTimeTextField text] intValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_AmpAttackTime withValue:value atSourceIdx:_sourceIdx];
        [_ampAttackTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _ampSustainTimeTextField) {
        int value = [[_ampSustainTimeTextField text] intValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_AmpSustainTime withValue:value atSourceIdx:_sourceIdx];
        [_ampSustainTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _ampReleaseTimeTextField) {
        int value = [[_ampReleaseTimeTextField text] intValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_AmpReleaseTime withValue:value atSourceIdx:_sourceIdx];
        [_ampReleaseTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _fltAttackTimeTextField) {
        int value = [[_fltAttackTimeTextField text] intValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltAttackTime withValue:value atSourceIdx:_sourceIdx];
        [_fltAttackTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _fltSustainTimeTextField) {
        int value = [[_fltSustainTimeTextField text] intValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltSustainTime withValue:value atSourceIdx:_sourceIdx];
        [_fltSustainTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _fltReleaseTimeTextField) {
        int value = [[_fltReleaseTimeTextField text] intValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltReleaseTime withValue:value atSourceIdx:_sourceIdx];
        [_fltReleaseTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _resonanceField) {
        float value = [[_resonanceField text] floatValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltQ withValue:value atSourceIdx:_sourceIdx];
        [_resonanceSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _fromCutoffFreqField) {
        float value = [[_fromCutoffFreqField text] floatValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltFromCutoff withValue:value atSourceIdx:_sourceIdx];
        [_fromCutoffFreqSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _toCutoffFreqField) {
        float value = [[_toCutoffFreqField text] floatValue];
        [[TWAudioController sharedController] setSeqParameter:kSeqParam_FltToCutoff withValue:value atSourceIdx:_sourceIdx];
        [_toCutoffFreqSlider setValue:value animated:YES];
    }
    
    [currentResponder resignFirstResponder];
}


- (void)keyboardCancelButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    if (currentResponder == _ampAttackTimeTextField) {
        float time_ms = [_ampAttackTimeSlider value];
        [_ampAttackTimeTextField setText:[NSString stringWithFormat:@"%d", (int)time_ms]];
    }
    
    else if (currentResponder == _ampSustainTimeTextField) {
        float time_ms = [_ampSustainTimeSlider value];
        [_ampSustainTimeTextField setText:[NSString stringWithFormat:@"%d", (int)time_ms]];
    }
    
    else if (currentResponder == _ampReleaseTimeTextField) {
        float time_ms = [_ampReleaseTimeSlider value];
        [_ampReleaseTimeTextField setText:[NSString stringWithFormat:@"%d", (int)time_ms]];
    }
    
    else if (currentResponder == _fltAttackTimeTextField) {
        float time_ms = [_fltAttackTimeSlider value];
        [_fltAttackTimeTextField setText:[NSString stringWithFormat:@"%d", (int)time_ms]];
    }
    
    else if (currentResponder == _fltSustainTimeTextField) {
        float time_ms = [_fltSustainTimeSlider value];
        [_fltSustainTimeTextField setText:[NSString stringWithFormat:@"%d", (int)time_ms]];
    }
    
    else if (currentResponder == _fltReleaseTimeTextField) {
        float time_ms = [_fltReleaseTimeSlider value];
        [_fltReleaseTimeTextField setText:[NSString stringWithFormat:@"%d", (int)time_ms]];
    }
    
    else if (currentResponder == _resonanceField) {
        float resonance = [_resonanceSlider value];
        [_fltReleaseTimeTextField setText:[NSString stringWithFormat:@"%.2f", resonance]];
    }
    
    else if (currentResponder == _fromCutoffFreqField) {
        float fc = [_fromCutoffFreqSlider value];
        [_fromCutoffFreqField setText:[NSString stringWithFormat:@"%.2f", fc]];
    }
    
    else if (currentResponder == _toCutoffFreqField) {
        float fc = [_toCutoffFreqSlider value];
        [_toCutoffFreqField setText:[NSString stringWithFormat:@"%.2f", fc]];
    }
    
    [currentResponder resignFirstResponder];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[TWKeyboardAccessoryView sharedView] setValueText:[textField text]];
    NSString* titleText;
    if (textField == _ampAttackTimeTextField) {
        titleText = @"Amp Attack Time ms: ";
    } else if (textField == _ampSustainTimeTextField) {
        titleText = @"Amp Sustain Tims ms: ";
    } else if (textField == _ampReleaseTimeTextField) {
        titleText = @"Amp Release Time ms: ";
    } else if (textField == _fltAttackTimeTextField) {
        titleText = @"Flt Attack Time ms: ";
    } else if (textField == _fltSustainTimeTextField) {
        titleText = @"Flt Sustain Tims ms: ";
    } else if (textField == _fltReleaseTimeTextField) {
        titleText = @"Flt Release Time ms: ";
    } else if (textField == _resonanceField) {
        titleText = @"Flt Resonance: ";
    } else if (textField == _fromCutoffFreqField) {
        titleText = @"Flt From Fc: ";
    } else if (textField == _toCutoffFreqField) {
        titleText = @"Flt To Fc: ";
    }
    [[TWKeyboardAccessoryView sharedView] setTitleText:titleText];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField selectAll:textField];
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

@end

//
//  TWOscView.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/11/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWOscView.h"
#import "TWHeader.h"
#import "TWAudioController.h"
#import "TWKeyboardAccessoryView.h"


static const float kCutoffFrequencyMin = 20.0f;
static const float kCutoffFrequencyMax = 20000.0f;

@interface TWOscView() <UITextFieldDelegate, TWKeyboardAccessoryViewDelegate>
{
    
    UISegmentedControl*         _segmentedControl;
    
    
    // Oscillator
    UIView*                     _oscBackView;
    
    UISegmentedControl*         _waveformSelector;
    
    UILabel*                    _bfLabel;
    UISlider*                   _baseFreqSlider;
    UITextField*                _baseFreqField;
    
    UISlider*                   _beatFreqSlider;
    UITextField*                _beatFreqField;
    
    UILabel*                    _mLabel;
    UISlider*                   _mononessSlider;
    UITextField*                _mononessField;
    
    
    // Tremolo
    UIView*                     _tremBackView;
    
    UILabel*                    _tremFLabel;
    UISlider*                   _tremoloFreqSlider;
    UITextField*                _tremoloFreqField;
    
    UILabel*                    _tremDLabel;
    UISlider*                   _tremoloDepthSlider;
    UITextField*                _tremoloDepthField;
    
    
    // Filter
    UIView*                      _filterBackView;
    
    UISegmentedControl*         _filterSelector;
    
    UILabel*                    _fcLabel;
    UISlider*                   _cutoffFreqSlider;
    UITextField*                _cutoffFreqField;
    
    UISwitch*                   _filterEnableSwitch;
    UISwitch*                   _lfoEnableSwitch;
    
    UILabel*                    _resonanceLabel;
    UISlider*                   _resonanceSlider;
    UITextField*                _resonanceField;
    
    UILabel*                    _filterGainLabel;
    UISlider*                   _filterGainSlider;
    UITextField*                _filterGainField;
    
    UILabel*                    _lfoFLabel;
    UISlider*                   _lfoFreqSlider;
    UITextField*                _lfoFreqField;
    
    UILabel*                    _lfoRLabel;
    UISlider*                   _lfoRangeSlider;
    UITextField*                _lfoRangeField;
    
    UILabel*                    _ofstLabel;
    UISlider*                   _lfoOffsetSlider;
    UITextField*                _lfoOffsetField;
    
    
    // General
    UILabel*                    _rTLabel;
    UISlider*                   _rampTimeSlider;
    UITextField*                _rampTimeField;
    
    
    // FM
    UILabel*                    _fmAmountLabel;
    UISlider*                   _fmAmountSlider;
    UITextField*                _fmAmountField;
    
    UILabel*                    _fmFreqLabel;
    UISlider*                   _fmFreqSlider;
    UITextField*                _fmFreqField;
}
@end


@implementation TWOscView

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    [[TWKeyboardAccessoryView sharedView] addToDelegates:self];
    
    
    NSMutableArray* segments = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumSources; i++) {
        [segments addObject:[NSString stringWithFormat:@"%d", i+1]];
    }
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
    [_segmentedControl setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl setTintColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    [_segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_segmentedControl];
    
    
    // Oscillator
    
    _oscBackView = [[UIView alloc] init];
    [_oscBackView setUserInteractionEnabled:NO];
    [_oscBackView setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.2f]];
    [self addSubview:_oscBackView];
    
    _bfLabel = [[UILabel alloc] init];
    [_bfLabel setText:@"Freq:"];
    [self setupLabelProperties:_bfLabel];
    [self addSubview:_bfLabel];
    
    _baseFreqSlider = [[UISlider alloc] init];
    [_baseFreqSlider setMinimumValue:20.0f];
    [_baseFreqSlider setMaximumValue:2000.0f];
    [_baseFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_baseFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_baseFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_baseFreqSlider addTarget:self action:@selector(baseFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_baseFreqSlider];
    
    _baseFreqField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_baseFreqField];
    [_baseFreqField setDelegate:self];
    [self addSubview:_baseFreqField];
    
    _beatFreqSlider = [[UISlider alloc] init];
    [_beatFreqSlider setMinimumValue:0.0f];
    [_beatFreqSlider setMaximumValue:32.0f];
    [_beatFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_beatFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_beatFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_beatFreqSlider addTarget:self action:@selector(beatFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_beatFreqSlider];
    
    _beatFreqField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_beatFreqField];
    [_beatFreqField setDelegate:self];
    [self addSubview:_beatFreqField];
    
    
    _mLabel = [[UILabel alloc] init];
    [_mLabel setText:@"Mono:"];
    [self setupLabelProperties:_mLabel];
    [self addSubview:_mLabel];
    
    _mononessSlider = [[UISlider alloc] init];
    [_mononessSlider setMinimumValue:0.0f];
    [_mononessSlider setMaximumValue:1.0f];
    [_mononessSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_mononessSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_mononessSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_mononessSlider addTarget:self action:@selector(mononessSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_mononessSlider];
    
    _mononessField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_mononessField];
    [_mononessField setDelegate:self];
    [self addSubview:_mononessField];
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    _waveformSelector = [[UISegmentedControl alloc] initWithItems:@[@"Sine", @"Saw", @"Square", @"Noise"]];
    [_waveformSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_waveformSelector setTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_waveformSelector setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [_waveformSelector addTarget:self action:@selector(waveformChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_waveformSelector];
    
    
    
    // Tremolo
    
    _tremBackView = [[UIView alloc] init];
    [_tremBackView setUserInteractionEnabled:NO];
    [_tremBackView setBackgroundColor:[UIColor colorWithWhite:0.06f alpha:0.2f]];
    [self addSubview:_tremBackView];
    
    _tremFLabel = [[UILabel alloc] init];
    [_tremFLabel setText:@"TrRt:"];
    [self setupLabelProperties:_tremFLabel];
    [self addSubview:_tremFLabel];
    
    _tremoloFreqSlider = [[UISlider alloc] init];
    [_tremoloFreqSlider setMinimumValue:0.0f];
    [_tremoloFreqSlider setMaximumValue:24.0f];
    [_tremoloFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_tremoloFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_tremoloFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_tremoloFreqSlider addTarget:self action:@selector(tremFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_tremoloFreqSlider];
    
    _tremoloFreqField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_tremoloFreqField];
    [_tremoloFreqField setDelegate:self];
    [self addSubview:_tremoloFreqField];
    
    _tremDLabel = [[UILabel alloc] init];
    [_tremDLabel setText:@"TrDp:"];
    [self setupLabelProperties:_tremDLabel];
    [self addSubview:_tremDLabel];
    
    _tremoloDepthSlider = [[UISlider alloc] init];
    [_tremoloDepthSlider setMinimumValue:0.0f];
    [_tremoloDepthSlider setMaximumValue:1.0f];
    [_tremoloDepthSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_tremoloDepthSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_tremoloDepthSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_tremoloDepthSlider addTarget:self action:@selector(tremDepthSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_tremoloDepthSlider];
    
    _tremoloDepthField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_tremoloDepthField];
    [_tremoloDepthField setDelegate:self];
    [self addSubview:_tremoloDepthField];
    
    
    
    // Filter
    
    _filterBackView = [[UIView alloc] init];
    [_filterBackView setUserInteractionEnabled:NO];
    [_filterBackView setBackgroundColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];
    [self addSubview:_filterBackView];
    
    _fcLabel = [[UILabel alloc] init];
    [_fcLabel setText:@"Fc:"];
    [self setupLabelProperties:_fcLabel];
    [self addSubview:_fcLabel];
    
    _cutoffFreqSlider = [[UISlider alloc] init];
    [_cutoffFreqSlider setMinimumValue:kCutoffFrequencyMin];
    [_cutoffFreqSlider setMaximumValue:kCutoffFrequencyMax];
    [_cutoffFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_cutoffFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_cutoffFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_cutoffFreqSlider addTarget:self action:@selector(cutoffFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_cutoffFreqSlider];
    
    _cutoffFreqField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_cutoffFreqField];
    [_cutoffFreqField setDelegate:self];
    [self addSubview:_cutoffFreqField];
    
    _filterSelector = [[UISegmentedControl alloc] initWithItems:@[@"LPF", @"HPF", @"BPF1", @"BPF2", @"Ntch"]];
    [_filterSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_filterSelector setTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_filterSelector setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [_filterSelector addTarget:self action:@selector(filterTypeChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterSelector];
    
    _filterEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterEnableSwitch setOnTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor-0.25f alpha:1.0f]];
    [_filterEnableSwitch setTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_filterEnableSwitch setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_filterEnableSwitch addTarget:self action:@selector(filterEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterEnableSwitch];
    
    _lfoEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_lfoEnableSwitch setOnTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor-0.25f alpha:1.0f]];
    [_lfoEnableSwitch setTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoEnableSwitch setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoEnableSwitch addTarget:self action:@selector(lfoEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_lfoEnableSwitch];
    
    
    _resonanceLabel = [[UILabel alloc] init];
    [_resonanceLabel setText:@"Q:"];
    [self setupLabelProperties:_resonanceLabel];
    [self addSubview:_resonanceLabel];
    
    _resonanceSlider = [[UISlider alloc] init];
    [_resonanceSlider setMinimumValue:0.0f];
    [_resonanceSlider setMaximumValue:6.0f];
    [_resonanceSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_resonanceSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_resonanceSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_resonanceSlider addTarget:self action:@selector(resonanceSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_resonanceSlider];
    
    _resonanceField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_resonanceField];
    [_resonanceField setDelegate:self];
    [self addSubview:_resonanceField];
    
    _filterGainLabel = [[UILabel alloc] init];
    [_filterGainLabel setText:@"G:"];
    [self setupLabelProperties:_filterGainLabel];
    [self addSubview:_filterGainLabel];
    
    _filterGainSlider = [[UISlider alloc] init];
    [_filterGainSlider setMinimumValue:1.0f];
    [_filterGainSlider setMaximumValue:5.0f];
    [_filterGainSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_filterGainSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_filterGainSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_filterGainSlider addTarget:self action:@selector(filterGainSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterGainSlider];
    
    _filterGainField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_filterGainField];
    [_filterGainField setDelegate:self];
    [self addSubview:_filterGainField];
    
    _lfoFLabel = [[UILabel alloc] init];
    [_lfoFLabel setText:@"LFrt:"];
    [self setupLabelProperties:_lfoFLabel];
    [self addSubview:_lfoFLabel];
    
    _lfoFreqSlider = [[UISlider alloc] init];
    [_lfoFreqSlider setMinimumValue:0.0f];
    [_lfoFreqSlider setMaximumValue:24.0f];
    [_lfoFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_lfoFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoFreqSlider addTarget:self action:@selector(lfoFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_lfoFreqSlider];
    
    _lfoFreqField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_lfoFreqField];
    [_lfoFreqField setDelegate:self];
    [self addSubview:_lfoFreqField];
    
    _lfoRLabel = [[UILabel alloc] init];
    [_lfoRLabel setText:@"Rnge:"];
    [self setupLabelProperties:_lfoRLabel];
    [self addSubview:_lfoRLabel];
    
    _lfoRangeSlider = [[UISlider alloc] init];
    [_lfoRangeSlider setMinimumValue:0.0f];
    [_lfoRangeSlider setMaximumValue:400.0f];
    [_lfoRangeSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoRangeSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_lfoRangeSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoRangeSlider addTarget:self action:@selector(lfoRangeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_lfoRangeSlider];
    
    _lfoRangeField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_lfoRangeField];
    [_lfoRangeField setDelegate:self];
    [self addSubview:_lfoRangeField];
    
    _ofstLabel = [[UILabel alloc] init];
    [_ofstLabel setText:@"Ofst:"];
    [self setupLabelProperties:_ofstLabel];
    [self addSubview:_ofstLabel];
    
    _lfoOffsetSlider = [[UISlider alloc] init];
    [_lfoOffsetSlider setMinimumValue:0.0f];
    [_lfoOffsetSlider setMaximumValue:2.0f * M_PI];
    [_lfoOffsetSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoOffsetSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_lfoOffsetSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_lfoOffsetSlider addTarget:self action:@selector(lfoOffsetSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_lfoOffsetSlider];
    
    _lfoOffsetField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_lfoOffsetField];
    [_lfoOffsetField setDelegate:self];
    [self addSubview:_lfoOffsetField];
    
    
    
    // Ramp Time
    
    _rTLabel = [[UILabel alloc] init];
    [_rTLabel setText:@"Ramp:"];
    [self setupLabelProperties:_rTLabel];
    [self addSubview:_rTLabel];
    
    _rampTimeSlider = [[UISlider alloc] init];
    [_rampTimeSlider setMinimumValue:0.0f];
    [_rampTimeSlider setMaximumValue:8000.0f];
    [_rampTimeSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rampTimeSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_rampTimeSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_rampTimeSlider addTarget:self action:@selector(rampTimeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rampTimeSlider];
    
    _rampTimeField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_rampTimeField];
    [_rampTimeField setDelegate:self];
    [self addSubview:_rampTimeField];
    
    
    
    // FM
    
    _fmAmountLabel = [[UILabel alloc] init];
    [_fmAmountLabel setText:@"FM-G:"];
    [self setupLabelProperties:_fmAmountLabel];
    [self addSubview:_fmAmountLabel];
    
    _fmAmountSlider = [[UISlider alloc] init];
    [_fmAmountSlider setMinimumValue:0.0f];
    [_fmAmountSlider setMaximumValue:1.0f];
    [_fmAmountSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_fmAmountSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_fmAmountSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_fmAmountSlider addTarget:self action:@selector(fmAmountSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_fmAmountSlider];
    
    _fmAmountField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_fmAmountField];
    [_fmAmountField setDelegate:self];
    [self addSubview:_fmAmountField];
    
    
    _fmFreqLabel = [[UILabel alloc] init];
    [_fmFreqLabel setText:@"FM-F:"];
    [self setupLabelProperties:_fmFreqLabel];
    [self addSubview:_fmFreqLabel];
    
    _fmFreqSlider = [[UISlider alloc] init];
    [_fmFreqSlider setMinimumValue:0.001f];
    [_fmFreqSlider setMaximumValue:200.0f];
    [_fmFreqSlider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_fmFreqSlider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
    [_fmFreqSlider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
    [_fmFreqSlider addTarget:self action:@selector(fmFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_fmFreqSlider];
    
    _fmFreqField = [[UITextField alloc] init];
    [self setupTextFieldProperties:_fmFreqField];
    [_fmFreqField setDelegate:self];
    [self addSubview:_fmFreqField];
    
    
    
    _oscID = 0;
    [self refreshParametersWithAnimation:YES];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0]];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = isLandscape ? kLandscapeComponentHeight : kPortraitComponentHeight;
    
    CGFloat xPos = 0.0f;
    CGFloat yPos = 0.0f;
    CGFloat sliderWidth = (frame.size.width - kTitleLabelWidth - (2.0f * kValueLabelWidth)) / 2.0f;
    
    
    [_segmentedControl setFrame:CGRectMake(xPos, yPos, frame.size.width, componentHeight)];
    
    
    // Oscillator
    yPos += componentHeight;
    [_oscBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 2.0f * componentHeight)];
    [_bfLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += kTitleLabelWidth;
    [_baseFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += sliderWidth;
    [_baseFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += kValueLabelWidth;
    [_beatFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += sliderWidth;
    [_beatFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_mLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += kTitleLabelWidth;
    sliderWidth -= 20.0f;
    [_mononessSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _mononessSlider.frame.size.width;
    [_mononessField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _mononessField.frame.size.width;
    [_waveformSelector setFrame:CGRectMake(xPos, yPos + 5.0f, frame.size.width - xPos, componentHeight - 10.0f)];
    
    
    
    // Tremolo
    
    yPos += componentHeight;
    xPos = 0.0f;
    sliderWidth = (frame.size.width - (2.0f * kValueLabelWidth) - (2.0f * kTitleLabelWidth)) / 2.0f;
    
    [_tremBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 1.0f * componentHeight)];
    [_tremFLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _tremFLabel.frame.size.width;
    [_tremoloFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _tremoloFreqSlider.frame.size.width;
    [_tremoloFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _tremoloFreqField.frame.size.width;
    [_tremDLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _tremDLabel.frame.size.width;
    [_tremoloDepthSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _tremoloDepthSlider.frame.size.width;
    [_tremoloDepthField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    // Filter
    
    yPos += componentHeight;
    xPos = 0.0f;
    
    [_filterBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 5.0f * componentHeight)];
    
    
    [_filterEnableSwitch setFrame:CGRectMake(xPos, yPos + ((componentHeight - _filterEnableSwitch.frame.size.height) / 2.0f), 0.0f, 0.0f)];
    
    xPos += _filterEnableSwitch.frame.size.width;
    [_lfoEnableSwitch setFrame:CGRectMake(xPos, yPos + ((componentHeight - _filterEnableSwitch.frame.size.height) / 2.0f), 0.0f, 0.0f)];
    
    xPos += _lfoEnableSwitch.frame.size.width;
    [_filterSelector setFrame:CGRectMake(xPos, yPos + 5.0f, frame.size.width - xPos, componentHeight - 10.0f)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_fcLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    sliderWidth = frame.size.width - kValueLabelWidth - kTitleLabelWidth;
    xPos += _fcLabel.frame.size.width;
    [_cutoffFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _cutoffFreqSlider.frame.size.width;
    [_cutoffFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_resonanceLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _resonanceLabel.frame.size.width;
    sliderWidth = (frame.size.width - (2.0f * (kTitleLabelWidth + kValueLabelWidth))) / 2.0f;
    [_resonanceSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _resonanceSlider.frame.size.width;
    [_resonanceField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _resonanceField.frame.size.width;
    [_filterGainLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _resonanceLabel.frame.size.width;
    [_filterGainSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterGainSlider.frame.size.width;
    [_filterGainField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    sliderWidth = (frame.size.width - (2.0f * (kValueLabelWidth + kTitleLabelWidth))) / 2.0f;
    
    [_lfoFLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _lfoFLabel.frame.size.width;
    [_lfoFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _lfoFreqSlider.frame.size.width;
    [_lfoFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _lfoFreqField.frame.size.width;
    [_lfoRLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _lfoRLabel.frame.size.width;
    [_lfoRangeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _lfoRangeSlider.frame.size.width;
    [_lfoRangeField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_ofstLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _ofstLabel.frame.size.width;
    [_lfoOffsetSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _lfoOffsetSlider.frame.size.width;
    [_lfoOffsetField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _lfoOffsetField.frame.size.width;
    [_rTLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _lfoRLabel.frame.size.width;
    [_rampTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _rampTimeSlider.frame.size.width;
    [_rampTimeField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    // FM
    yPos += componentHeight;
    xPos = 0.0f;
    [_fmAmountLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _fmAmountLabel.frame.size.width;
    [_fmAmountSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _fmAmountSlider.frame.size.width;
    [_fmAmountField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _fmAmountField.frame.size.width;
    [_fmFreqLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _fmFreqLabel.frame.size.width;
    [_fmFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _fmFreqSlider.frame.size.width;
    [_fmFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
}


- (void)setOscID:(int)oscID {
    _oscID = oscID;
    [_segmentedControl setSelectedSegmentIndex:_oscID];
    [self refreshParametersWithAnimation:YES];
}

- (void)segmentValueChanged:(UISegmentedControl*)sender {
    _oscID = (int)sender.selectedSegmentIndex;
    [self refreshParametersWithAnimation:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateBaseFrequencyUIWithValue:(float)frequency {
    [_baseFreqSlider setValue:frequency animated:YES];
    [_baseFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
}

- (void)updateBeatFrequencyUIWithValue:(float)frequency {
    [_beatFreqSlider setValue:frequency animated:YES];
    [_beatFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
}

- (void)updateRampTimeValueUIWithValue:(int)rampTime_ms {
    [_rampTimeSlider setValue:rampTime_ms];
    [_rampTimeField setText:[NSString stringWithFormat:@"%d", rampTime_ms]];
}


#pragma mark - UISliders

- (void)baseFreqSliderChanged {
    float value = _baseFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscBaseFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_baseFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)beatFreqSliderChanged {
    float value = _beatFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscBeatFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_beatFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)mononessSliderChanged {
    float value = _mononessSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscMononess withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_mononessField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)waveformChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_oscID inTime:0];
}



- (void)tremFreqSliderChanged {
    float value = _tremoloFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_tremoloFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)tremDepthSliderChanged {
    float value = _tremoloDepthSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloDepth withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_tremoloDepthField setText:[NSString stringWithFormat:@"%.2f", value]];
}



- (void)filterEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterEnable withValue:_filterEnableSwitch.on atSourceIdx:_oscID inTime:0];
}

- (void)filterTypeChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterType withValue:_filterSelector.selectedSegmentIndex atSourceIdx:_oscID inTime:0];
}

- (void)cutoffFreqSliderChanged {
    [self setCutoffFrequencyParameter:_cutoffFreqSlider.value];
}

- (void)lfoEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFOEnable withValue:_lfoEnableSwitch.on atSourceIdx:_oscID inTime:0];
}

- (void)resonanceSliderChanged {
    float value = _resonanceSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterQ withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_resonanceField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)filterGainSliderChanged {
    float value = _filterGainSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterGain withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_filterGainField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)lfoFreqSliderChanged {
    float value = _lfoFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFOFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_lfoFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)lfoRangeSliderChanged {
    float value = _lfoRangeSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFORange withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_lfoRangeField setText:[NSString stringWithFormat:@"%.1f", value]];
}

- (void)lfoOffsetSliderChanged {
    float value = _lfoOffsetSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFOOffset withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_lfoOffsetField setText:[NSString stringWithFormat:@"%.2f", value]];
}


- (void)rampTimeSliderChanged {
    int value = (int)_rampTimeSlider.value;
    [[TWAudioController sharedController] setRampTime:value atSourceIdx:_oscID];
    [_rampTimeField setText:[NSString stringWithFormat:@"%d", value]];
}


- (void)fmAmountSliderChanged {
    float value = _fmAmountSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FMAmount withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_fmAmountField setText:[NSString stringWithFormat:@"%.2f", value]];
}

- (void)fmFreqSliderChanged {
    float value = _fmFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FMFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_fmFreqField setText:[NSString stringWithFormat:@"%.2f", value]];
}


#pragma - UITextFieldDelegate

- (void)keyboardDoneButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    if (currentResponder == _baseFreqField) {
        float value = [[_baseFreqField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscBaseFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_baseFreqSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _beatFreqField) {
        float value = [[_beatFreqField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscBeatFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_beatFreqSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _mononessField) {
        float value = [[_mononessField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscMononess withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_mononessSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _tremoloFreqField) {
        float value = [[_tremoloFreqField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_tremoloFreqSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _tremoloDepthField) {
        float value = [[_tremoloDepthField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloDepth withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_tremoloDepthSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _cutoffFreqField) {
        float value = [[_cutoffFreqField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FilterCutoff withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [self setCutoffFrequencySlider:value];
    }
    
    else if (currentResponder == _resonanceField) {
        float value = [[_resonanceField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FilterQ withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_resonanceSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _filterGainField) {
        float value = [[_filterGainField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FilterGain withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_filterGainSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _lfoFreqField) {
        float value = [[_lfoFreqField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_LFOFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_lfoFreqSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _lfoOffsetField) {
        float value = [[_lfoOffsetField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_LFOOffset withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_lfoOffsetSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _lfoRangeField) {
        float value = [[_lfoRangeField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_LFORange withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_lfoRangeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _rampTimeField) {
        int value = [[_rampTimeField text] intValue];
        [[TWAudioController sharedController] setRampTime:value atSourceIdx:_oscID];
        [_rampTimeSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _fmAmountField) {
        float value = [[_fmAmountField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FMAmount withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_fmAmountSlider setValue:value animated:YES];
    }
    
    else if (currentResponder == _fmFreqField) {
        float value = [[_fmFreqField text] floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FMFrequency withValue:value atSourceIdx:_oscID inTime:_rampTimeSlider.value];
        [_fmFreqSlider setValue:value animated:YES];
    }
    
    [self endEditing:YES];
//    [_currentResponder resignFirstResponder];
}


- (void)keyboardCancelButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    if (currentResponder == _baseFreqField) {
        float frequency = [_baseFreqSlider value];
        [_baseFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    }

    else if (currentResponder == _beatFreqField) {
        float frequency = [_beatFreqSlider value];
        [_beatFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    }

    else if (currentResponder == _mononessField) {
        float mononess = [_mononessSlider value];
        [_mononessField setText:[NSString stringWithFormat:@"%.2f", mononess]];
    }

    else if (currentResponder == _tremoloFreqField) {
        float frequency = [_tremoloFreqSlider value];
        [_tremoloFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    }

    else if (currentResponder == _tremoloDepthField) {
        float depth = [_tremoloDepthSlider value];
        [_tremoloDepthField setText:[NSString stringWithFormat:@"%.2f", depth]];
    }

    else if (currentResponder == _cutoffFreqField) {
        float frequency = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterCutoff atSourceIdx:_oscID];
        [_cutoffFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    }

    else if (currentResponder == _resonanceField) {
        float resonance = [_resonanceSlider value];
        [_resonanceField setText:[NSString stringWithFormat:@"%.2f", resonance]];
    }

    else if (currentResponder == _filterGainField) {
        float gain = [_filterGainSlider value];
        [_filterGainField setText:[NSString stringWithFormat:@"%.2f", gain]];
    }

    else if (currentResponder == _lfoFreqField) {
        float frequency = [_lfoFreqSlider value];
        [_lfoFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
    }

    else if (currentResponder == _lfoOffsetField) {
        float offset = [_lfoOffsetSlider value];
        [_lfoOffsetField setText:[NSString stringWithFormat:@"%.2f", offset]];
    }

    else if (currentResponder == _lfoRangeField) {
        float range = [_lfoRangeSlider value];
        [_lfoRangeField setText:[NSString stringWithFormat:@"%.2f", range]];
    }

    else if (currentResponder == _rampTimeField) {
        int rampTime_ms = (int)[_rampTimeSlider value];
        [_rampTimeField setText:[NSString stringWithFormat:@"%d", rampTime_ms]];
    }
    
    else if (currentResponder == _fmAmountField) {
        float range = [_fmAmountSlider value];
        [_fmAmountField setText:[NSString stringWithFormat:@"%.2f", range]];
    }
    
    else if (currentResponder == _fmFreqField) {
        float range = [_fmFreqSlider value];
        [_fmFreqField setText:[NSString stringWithFormat:@"%.2f", range]];
    }
    
    [self endEditing:YES];
//    [_currentResponder resignFirstResponder];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    NSLog(@"GRP: ShouldBeginEditing: %p", textField);
    
    TWKeyboardAccessoryView* accView = [TWKeyboardAccessoryView sharedView];
    [accView setValueText:[textField text]];

    NSString* titleText;
    if (textField == _baseFreqField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Base Frequency:", _oscID];
    } else if (textField == _beatFreqField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Beat Frequency:", _oscID];
    } else if (textField == _mononessField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Mononess:", _oscID];
    } else if (textField == _tremoloFreqField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Tremolo Frequency:", _oscID];
    } else if (textField == _tremoloDepthField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Tremolo Depth:", _oscID];
    } else if (textField == _cutoffFreqField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Filter Cutoff Frequency:", _oscID];
    } else if (textField == _resonanceField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Filter Resonance:", _oscID];
    } else if (textField == _filterGainField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Filter Gain:", _oscID];
    } else if (textField == _lfoFreqField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. LFO Frequency:", _oscID];
    } else if (textField == _lfoOffsetField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. LFO Stereo Offset:", _oscID];
    } else if (textField == _lfoRangeField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. LFO Range:", _oscID];
    } else if (textField == _rampTimeField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. Ramp Time:", _oscID];
    } else if (textField == _fmAmountField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. FM Amount:", _oscID];
    } else if (textField == _fmFreqField) {
        titleText = [NSString stringWithFormat:@"Osc[%d]. FM Frequency:", _oscID];
    }
    
    [accView setTitleText:titleText];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    NSLog(@"GRP: DidBeginEditing: %p", textField);
    [textField selectAll:textField];
    [[TWKeyboardAccessoryView sharedView] setCurrentResponder:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [[TWKeyboardAccessoryView sharedView] setValueText:[[textField text] stringByReplacingCharactersInRange:range withString:string]];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSLog(@"GRP: ShouldEndEditing: %p", textField);
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    NSLog(@"GRP: DidEndEditing: %p", textField);
    [textField resignFirstResponder];
}



- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    NSLog(@"GRP: ShouldClear: %p", textField);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSLog(@"GRP: ShouldReturn: %p", textField);
    return YES;
}


#pragma mark - Private

- (void)refreshParametersWithAnimation:(BOOL)animated {
    
    float baseFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_OscBaseFrequency atSourceIdx:_oscID];
    [self updateBaseFrequencyUIWithValue:baseFreq];
    
    float beatFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_OscBeatFrequency atSourceIdx:_oscID];
    [self updateBeatFrequencyUIWithValue:beatFreq];
    
    float mononess = [[TWAudioController sharedController] getOscParameter:kOscParam_OscMononess atSourceIdx:_oscID];
    [_mononessSlider setValue:mononess animated:animated];
    [_mononessField setText:[NSString stringWithFormat:@"%.2f", mononess]];
    
    [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:kOscParam_OscWaveform atSourceIdx:_oscID]];
    
    
    
    float tremFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloFrequency atSourceIdx:_oscID];
    [_tremoloFreqSlider setValue:tremFreq animated:animated];
    [_tremoloFreqField setText:[NSString stringWithFormat:@"%.2f", tremFreq]];
    
    float tremDepth = [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloDepth atSourceIdx:_oscID];
    [_tremoloDepthSlider setValue:tremDepth animated:animated];
    [_tremoloDepthField setText:[NSString stringWithFormat:@"%.2f", tremDepth]];
    
    
    
    float Fc = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterCutoff atSourceIdx:_oscID];
    [self setCutoffFrequencySlider:Fc];
    [_cutoffFreqField setText:[NSString stringWithFormat:@"%.2f", Fc]];
    
    [_filterSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:kOscParam_FilterType atSourceIdx:_oscID]];
    [_filterEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:kOscParam_FilterEnable atSourceIdx:_oscID]];
    [_lfoEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:kOscParam_LFOEnable atSourceIdx:_oscID]];
    
    float gain = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterGain atSourceIdx:_oscID];
    [_filterGainSlider setValue:gain animated:YES];
    [_filterGainField setText:[NSString stringWithFormat:@"%.2f", gain]];
    
    float res = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterQ atSourceIdx:_oscID];
    [_resonanceSlider setValue:res animated:YES];
    [_resonanceField setText:[NSString stringWithFormat:@"%.2f", res]];
    
    float range = [[TWAudioController sharedController] getOscParameter:kOscParam_LFORange atSourceIdx:_oscID];
    [_lfoRangeSlider setValue:range animated:animated];
    [_lfoRangeField setText:[NSString stringWithFormat:@"%.1f", range]];
    
    float lfoFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_LFOFrequency atSourceIdx:_oscID];
    [_lfoFreqSlider setValue:lfoFreq animated:animated];
    [_lfoFreqField setText:[NSString stringWithFormat:@"%.2f", lfoFreq]];
    
    float lfoOffset = [[TWAudioController sharedController] getOscParameter:kOscParam_LFOOffset atSourceIdx:_oscID];
    [_lfoOffsetSlider setValue:lfoOffset animated:animated];
    [_lfoOffsetField setText:[NSString stringWithFormat:@"%.2f", lfoOffset]];
    
    int rampTime_ms = [[TWAudioController sharedController] getRampTimeAtSourceIdx:_oscID];
    [self updateRampTimeValueUIWithValue:rampTime_ms];
    
    float fmAmount = [[TWAudioController sharedController] getOscParameter:kOscParam_FMAmount atSourceIdx:_oscID];
    [_fmAmountSlider setValue:fmAmount animated:animated];
    [_fmAmountField setText:[NSString stringWithFormat:@"%.2f", fmAmount]];
    
    float fmFrequency = [[TWAudioController sharedController] getOscParameter:kOscParam_FMFrequency atSourceIdx:_oscID];
    [_fmFreqSlider setValue:fmFrequency animated:animated];
    [_fmFreqField setText:[NSString stringWithFormat:@"%.2f", fmFrequency]];
}



- (void)setupTextFieldProperties:(UITextField*)textField {
    [textField setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [textField setFont:[UIFont systemFontOfSize:9.0f]];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setKeyboardType:UIKeyboardTypeDecimalPad];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setInputAccessoryView:[TWKeyboardAccessoryView sharedView]];
//    [textField setBackgroundColor:[UIColor orangeColor]];
    [textField setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:0.05f]];
}

- (void)setupLabelProperties:(UILabel*)label {
    [label setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [label setFont:[UIFont systemFontOfSize:9.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
//    [label setBackgroundColor:[UIColor yellowColor]];
    [label setBackgroundColor:[UIColor clearColor]];
}


- (void)setCutoffFrequencyParameter:(float)sliderValue {
    // y = a * exp(b*x);
    // if x1 = 0.5, y1 = 0.1; 0.1 = a * exp(0.5b); a = 0.1 / exp(0.5b);
    // if x2 = 1.0, y2 = 1.0; 1.0 = a * exp(b); exp(b) = 1 / a;
    // b = log(y1/y2) / (x1-x2). b = 2;
    // a = 0.1 / exp(0.5b); a = 0.1 / exp(1). a = 0.01;
//    float value = 0.01 * powf(10.0f, 2.0f * sliderValue);
//    float frequency = (value * (kCutoffFrequencyMax - kCutoffFrequencyMin)) + kCutoffFrequencyMin;
//    printf("\n\nIn: %f. Out: %f. Freq: %f\n", sliderValue, value, frequency);
    
//    float frequency = 0.0f;
    float frequency = sliderValue;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterCutoff withValue:frequency atSourceIdx:_oscID inTime:_rampTimeSlider.value];
    [_cutoffFreqField setText:[NSString stringWithFormat:@"%.2f", frequency]];
}

- (void)setCutoffFrequencySlider:(float)cutoff {
    [_cutoffFreqSlider setValue:cutoff animated:YES];
}
    
@end

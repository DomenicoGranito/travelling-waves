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
#import "TWKeypad.h"
#import "TWUtils.h"
#import "UIColor+Additions.h"


@interface TWOscView() <TWKeypadDelegate>
{
    
    UISegmentedControl*         _segmentedControl;
    
    
    // Oscillator
    UIView*                     _oscBackView;
    
    UISegmentedControl*         _waveformSelector;
    
    UILabel*                    _bfLabel;
    UISlider*                   _baseFreqSlider;
//    UITextField*                _baseFreqField;
    UIButton*                   _baseFreqField;
    
    UISlider*                   _beatFreqSlider;
//    UITextField*                _beatFreqField;
    UIButton*                   _beatFreqField;
    
    UILabel*                    _mLabel;
    UISlider*                   _mononessSlider;
    UIButton*                   _mononessField;
    
    
    // Tremolo
    UIView*                     _tremBackView;
    
    UILabel*                    _tremFLabel;
    UISlider*                   _tremoloFreqSlider;
    UIButton*                   _tremoloFreqField;
    
    UILabel*                    _tremDLabel;
    UISlider*                   _tremoloDepthSlider;
    UIButton*                   _tremoloDepthField;
    
    
    // Filter
    UIView*                      _filterBackView;
    
    UISegmentedControl*         _filterSelector;
    
    UILabel*                    _fcLabel;
    UISlider*                   _cutoffFreqSlider;
    UIButton*                   _cutoffFreqField;
    
    UISwitch*                   _filterEnableSwitch;
    UISwitch*                   _lfoEnableSwitch;
    
    UILabel*                    _resonanceLabel;
    UISlider*                   _resonanceSlider;
    UIButton*                   _resonanceField;
    
    UILabel*                    _filterGainLabel;
    UISlider*                   _filterGainSlider;
    UIButton*                    _filterGainField;
    
    UILabel*                    _lfoFLabel;
    UISlider*                   _lfoFreqSlider;
    UIButton*                   _lfoFreqField;
    
    UILabel*                    _lfoRLabel;
    UISlider*                   _lfoRangeSlider;
    UIButton*                   _lfoRangeField;
    
    UILabel*                    _ofstLabel;
    UISlider*                   _lfoOffsetSlider;
    UIButton*                   _lfoOffsetField;
    
    
    // General
    UILabel*                    _rTLabel;
    UISlider*                   _rampTimeSlider;
    UIButton*                   _rampTimeField;
    
    
    // FM
    UILabel*                    _fmAmountLabel;
    UISlider*                   _fmAmountSlider;
    UIButton*                   _fmAmountField;
    
    UILabel*                    _fmFreqLabel;
    UISlider*                   _fmFreqSlider;
    UIButton*                   _fmFreqField;
    
    UIView*                     _fmBackView;
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
    
    NSMutableArray* segments = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumSources; i++) {
        [segments addObject:[NSString stringWithFormat:@"%d", i+1]];
    }
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
    [_segmentedControl setBackgroundColor:[UIColor segmentedControlColor]];
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
    [_baseFreqSlider setMinimumValue:0.0f];
    [_baseFreqSlider setMaximumValue:1.0f];
    [_baseFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_baseFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_baseFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_baseFreqSlider addTarget:self action:@selector(baseFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_baseFreqSlider setTag:kOscParam_OscBaseFrequency];
    [self addSubview:_baseFreqSlider];
    
    _baseFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_baseFreqField];
    [_baseFreqField addTarget:self action:@selector(baseFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_baseFreqField setTag:kOscParam_OscBaseFrequency];
    [self addSubview:_baseFreqField];
    
    
    _beatFreqSlider = [[UISlider alloc] init];
    [_beatFreqSlider setMinimumValue:0.0f];
    [_beatFreqSlider setMaximumValue:32.0f];
    [_beatFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_beatFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_beatFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_beatFreqSlider addTarget:self action:@selector(beatFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_beatFreqSlider setTag:kOscParam_OscBeatFrequency];
    [self addSubview:_beatFreqSlider];
    
    _beatFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_beatFreqField];
    [_beatFreqField addTarget:self action:@selector(beatFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_beatFreqField setTag:kOscParam_OscBeatFrequency];
    [self addSubview:_beatFreqField];
    
    
    
    _mLabel = [[UILabel alloc] init];
    [_mLabel setText:@"Mono:"];
    [self setupLabelProperties:_mLabel];
    [self addSubview:_mLabel];
    
    _mononessSlider = [[UISlider alloc] init];
    [_mononessSlider setMinimumValue:0.0f];
    [_mononessSlider setMaximumValue:1.0f];
    [_mononessSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_mononessSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_mononessSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_mononessSlider addTarget:self action:@selector(mononessSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_mononessSlider setTag:kOscParam_OscMononess];
    [self addSubview:_mononessSlider];
    
    _mononessField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_mononessField];
    [_mononessField addTarget:self action:@selector(mononessFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_mononessField setTag:kOscParam_OscMononess];
    [self addSubview:_mononessField];
    
    
    
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    _waveformSelector = [[UISegmentedControl alloc] initWithItems:@[@"Sine", @"Saw", @"Square", @"Noise"]];
    [_waveformSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_waveformSelector setTintColor:[UIColor sliderOnColor]];
    [_waveformSelector setBackgroundColor:[UIColor segmentedControlColor]];
    [_waveformSelector addTarget:self action:@selector(waveformChanged) forControlEvents:UIControlEventValueChanged];
    [_waveformSelector setTag:kOscParam_OscWaveform];
    [self addSubview:_waveformSelector];
    
    
    
    // Tremolo
    
    _tremBackView = [[UIView alloc] init];
    [_tremBackView setUserInteractionEnabled:NO];
    [_tremBackView setBackgroundColor:[UIColor colorWithWhite:0.06f alpha:0.3f]];
    [self addSubview:_tremBackView];
    
    _tremFLabel = [[UILabel alloc] init];
    [_tremFLabel setText:@"TrRt:"];
    [self setupLabelProperties:_tremFLabel];
    [self addSubview:_tremFLabel];
    
    _tremoloFreqSlider = [[UISlider alloc] init];
    [_tremoloFreqSlider setMinimumValue:0.0f];
    [_tremoloFreqSlider setMaximumValue:24.0f];
    [_tremoloFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tremoloFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tremoloFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tremoloFreqSlider addTarget:self action:@selector(tremFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_tremoloFreqSlider setTag:kOscParam_TremoloFrequency];
    [self addSubview:_tremoloFreqSlider];
    
    _tremoloFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_tremoloFreqField];
    [_tremoloFreqField addTarget:self action:@selector(tremFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_tremoloFreqField setTag:kOscParam_TremoloFrequency];
    [self addSubview:_tremoloFreqField];
    
    
    _tremDLabel = [[UILabel alloc] init];
    [_tremDLabel setText:@"TrDp:"];
    [self setupLabelProperties:_tremDLabel];
    [self addSubview:_tremDLabel];
    
    _tremoloDepthSlider = [[UISlider alloc] init];
    [_tremoloDepthSlider setMinimumValue:0.0f];
    [_tremoloDepthSlider setMaximumValue:1.0f];
    [_tremoloDepthSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tremoloDepthSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tremoloDepthSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tremoloDepthSlider addTarget:self action:@selector(tremDepthSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_tremoloDepthSlider setTag:kOscParam_TremoloDepth];
    [self addSubview:_tremoloDepthSlider];
    
    _tremoloDepthField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_tremoloDepthField];
    [_tremoloDepthField addTarget:self action:@selector(tremDepthFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_tremoloDepthField setTag:kOscParam_TremoloDepth];
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
    [_cutoffFreqSlider setMinimumValue:0.0f];
    [_cutoffFreqSlider setMaximumValue:1.0f];
    [_cutoffFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_cutoffFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_cutoffFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_cutoffFreqSlider addTarget:self action:@selector(cutoffFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_cutoffFreqSlider setTag:kOscParam_FilterCutoff];
    [self addSubview:_cutoffFreqSlider];
    
    _cutoffFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_cutoffFreqField];
    [_cutoffFreqField addTarget:self action:@selector(cutoffFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cutoffFreqField setTag:kOscParam_FilterCutoff];
    [self addSubview:_cutoffFreqField];
    
    
    _filterSelector = [[UISegmentedControl alloc] initWithItems:@[@"LPF", @"HPF", @"BPF1", @"BPF2", @"Ntch"]];
    [_filterSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_filterSelector setTintColor:[UIColor sliderOnColor]];
    [_filterSelector setBackgroundColor:[UIColor segmentedControlColor]];
    [_filterSelector addTarget:self action:@selector(filterTypeChanged) forControlEvents:UIControlEventValueChanged];
    [_filterSelector setTag:kOscParam_FilterType];
    [self addSubview:_filterSelector];
    
    _filterEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_filterEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch addTarget:self action:@selector(filterEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [_filterEnableSwitch setTag:kOscParam_FilterEnable];
    [self addSubview:_filterEnableSwitch];
    
    _lfoEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_lfoEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_lfoEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_lfoEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoEnableSwitch addTarget:self action:@selector(lfoEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoEnableSwitch setTag:kOscParam_LFOEnable];
    [self addSubview:_lfoEnableSwitch];
    
    
    _resonanceLabel = [[UILabel alloc] init];
    [_resonanceLabel setText:@"Q:"];
    [self setupLabelProperties:_resonanceLabel];
    [self addSubview:_resonanceLabel];
    
    _resonanceSlider = [[UISlider alloc] init];
    [_resonanceSlider setMinimumValue:0.0f];
    [_resonanceSlider setMaximumValue:1.0f];
    [_resonanceSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_resonanceSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_resonanceSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_resonanceSlider addTarget:self action:@selector(resonanceSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_resonanceSlider setTag:kOscParam_FilterResonance];
    [self addSubview:_resonanceSlider];
    
    _resonanceField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_resonanceField];
    [_resonanceField addTarget:self action:@selector(resonanceFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_resonanceField setTag:kOscParam_FilterResonance];
    [self addSubview:_resonanceField];
    
    
    _filterGainLabel = [[UILabel alloc] init];
    [_filterGainLabel setText:@"G:"];
    [self setupLabelProperties:_filterGainLabel];
    [self addSubview:_filterGainLabel];
    
    _filterGainSlider = [[UISlider alloc] init];
    [_filterGainSlider setMinimumValue:1.0f];
    [_filterGainSlider setMaximumValue:5.0f];
    [_filterGainSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterGainSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterGainSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterGainSlider addTarget:self action:@selector(filterGainSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_filterGainSlider setTag:kOscParam_FilterGain];
    [self addSubview:_filterGainSlider];
    
    _filterGainField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterGainField];
    [_filterGainField addTarget:self action:@selector(filterGainFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_filterGainField setTag:kOscParam_FilterGain];
    [self addSubview:_filterGainField];
    
    
    
    _lfoFLabel = [[UILabel alloc] init];
    [_lfoFLabel setText:@"LFrt:"];
    [self setupLabelProperties:_lfoFLabel];
    [self addSubview:_lfoFLabel];
    
    _lfoFreqSlider = [[UISlider alloc] init];
    [_lfoFreqSlider setMinimumValue:0.0f];
    [_lfoFreqSlider setMaximumValue:24.0f];
    [_lfoFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_lfoFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_lfoFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoFreqSlider addTarget:self action:@selector(lfoFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoFreqSlider setTag:kOscParam_LFOFrequency];
    [self addSubview:_lfoFreqSlider];
    
    _lfoFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_lfoFreqField];
    [_lfoFreqField addTarget:self action:@selector(lfoFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_lfoFreqField setTag:kOscParam_LFOFrequency];
    [self addSubview:_lfoFreqField];
    
    
    _lfoRLabel = [[UILabel alloc] init];
    [_lfoRLabel setText:@"Rnge:"];
    [self setupLabelProperties:_lfoRLabel];
    [self addSubview:_lfoRLabel];
    
    _lfoRangeSlider = [[UISlider alloc] init];
    [_lfoRangeSlider setMinimumValue:0.0f];
    [_lfoRangeSlider setMaximumValue:1.0f];
    [_lfoRangeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_lfoRangeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_lfoRangeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoRangeSlider addTarget:self action:@selector(lfoRangeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoRangeSlider setTag:kOscParam_LFORange];
    [self addSubview:_lfoRangeSlider];
    
    _lfoRangeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_lfoRangeField];
    [_lfoRangeField addTarget:self action:@selector(lfoRangeFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_lfoRangeField setTag:kOscParam_LFORange];
    [self addSubview:_lfoRangeField];
    
    
    _ofstLabel = [[UILabel alloc] init];
    [_ofstLabel setText:@"Ofst:"];
    [self setupLabelProperties:_ofstLabel];
    [self addSubview:_ofstLabel];
    
    _lfoOffsetSlider = [[UISlider alloc] init];
    [_lfoOffsetSlider setMinimumValue:0.0f];
    [_lfoOffsetSlider setMaximumValue:2.0f * M_PI];
    [_lfoOffsetSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_lfoOffsetSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_lfoOffsetSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoOffsetSlider addTarget:self action:@selector(lfoOffsetSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoOffsetSlider setTag:kOscParam_LFOOffset];
    [self addSubview:_lfoOffsetSlider];
    
    _lfoOffsetField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_lfoOffsetField];
    [_lfoOffsetField addTarget:self action:@selector(lfoOffsetFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_lfoOffsetField setTag:kOscParam_LFOOffset];
    [self addSubview:_lfoOffsetField];
    
    
    
    // Ramp Time
    
    _rTLabel = [[UILabel alloc] init];
    [_rTLabel setText:@"Ramp:"];
    [self setupLabelProperties:_rTLabel];
    [self addSubview:_rTLabel];
    
    _rampTimeSlider = [[UISlider alloc] init];
    [_rampTimeSlider setMinimumValue:0.0f];
    [_rampTimeSlider setMaximumValue:8000.0f];
    [_rampTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_rampTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_rampTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_rampTimeSlider addTarget:self action:@selector(rampTimeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_rampTimeSlider setTag:kOscParam_RampTime_ms];
    [self addSubview:_rampTimeSlider];
    
    _rampTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_rampTimeField];
    [_rampTimeField addTarget:self action:@selector(rampTimeFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_rampTimeField setTag:kOscParam_RampTime_ms];
    [self addSubview:_rampTimeField];
    
    
    
    // FM
    
    _fmBackView = [[UIView alloc] init];
    [_fmBackView setUserInteractionEnabled:NO];
    [_fmBackView setBackgroundColor:[UIColor colorWithWhite:0.06f alpha:0.3f]];
    [self addSubview:_fmBackView];
    
    
    _fmAmountLabel = [[UILabel alloc] init];
    [_fmAmountLabel setText:@"FM-G:"];
    [self setupLabelProperties:_fmAmountLabel];
    [self addSubview:_fmAmountLabel];
    
    _fmAmountSlider = [[UISlider alloc] init];
    [_fmAmountSlider setMinimumValue:0.0f];
    [_fmAmountSlider setMaximumValue:1.0f];
    [_fmAmountSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fmAmountSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fmAmountSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_fmAmountSlider addTarget:self action:@selector(fmAmountSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_fmAmountSlider setTag:kOscParam_FMAmount];
    [self addSubview:_fmAmountSlider];
    
    _fmAmountField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_fmAmountField];
    [_fmAmountField addTarget:self action:@selector(fmAmountFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_fmAmountField setTag:kOscParam_FMAmount];
    [self addSubview:_fmAmountField];
    
    
    _fmFreqLabel = [[UILabel alloc] init];
    [_fmFreqLabel setText:@"FM-F:"];
    [self setupLabelProperties:_fmFreqLabel];
    [self addSubview:_fmFreqLabel];
    
    _fmFreqSlider = [[UISlider alloc] init];
    [_fmFreqSlider setMinimumValue:0.001f];
    [_fmFreqSlider setMaximumValue:200.0f];
    [_fmFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fmFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fmFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_fmFreqSlider addTarget:self action:@selector(fmFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_fmFreqSlider setTag:kOscParam_FMFrequency];
    [self addSubview:_fmFreqSlider];
    
    _fmFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_fmFreqField];
    [_fmFreqField addTarget:self action:@selector(fmFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_fmFreqField setTag:kOscParam_FMFrequency];
    [self addSubview:_fmFreqField];
    
    
    
    [[TWKeypad sharedKeypad] addToDelegates:self];
    
    _sourceIdx = 0;
    [self refreshParametersWithAnimation:YES];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:1.0]];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
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
    [_fmBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 1.0f * componentHeight)];
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


- (void)setSourceIdx:(int)sourceIdx {
    _sourceIdx = sourceIdx;
    [_segmentedControl setSelectedSegmentIndex:_sourceIdx];
    [self refreshParametersWithAnimation:YES];
}


- (void)segmentValueChanged:(UISegmentedControl*)sender {
    _sourceIdx = (int)sender.selectedSegmentIndex;
    [self refreshParametersWithAnimation:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - UISliders

- (void)baseFreqSliderChanged {
    float value = [TWUtils logScaleFromLinear:_baseFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscBaseFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateBaseFreqFieldWithValue:value];
}

- (void)beatFreqSliderChanged {
    float value = _beatFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscBeatFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateBeatFreqFieldWithValue:value];
}

- (void)mononessSliderChanged {
    float value = _mononessSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscMononess withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateMononessFieldWithValue:value];
}

- (void)waveformChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
}



- (void)tremFreqSliderChanged {
    float value = _tremoloFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateTremFreqFieldWithValue:value];
}

- (void)tremDepthSliderChanged {
    float value = _tremoloDepthSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloDepth withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateTremDepthFieldWithValue:value];
}



- (void)filterEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterEnable withValue:_filterEnableSwitch.on atSourceIdx:_sourceIdx inTime:0];
}

- (void)filterTypeChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterType withValue:_filterSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
}

- (void)cutoffFreqSliderChanged {
    float frequency = [TWUtils logScaleFromLinear:_cutoffFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterCutoff withValue:frequency atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterCutoffFieldWithValue:frequency];
}

- (void)lfoEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFOEnable withValue:_lfoEnableSwitch.on atSourceIdx:_sourceIdx inTime:0];
}

- (void)resonanceSliderChanged {
    float value = [TWUtils logScaleFromLinear:_resonanceSlider.value outMin:kResonanceMin outMax:kResonanceMax];
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterResonance withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterResonanceFieldWithValue:value];
}

- (void)filterGainSliderChanged {
    float value = _filterGainSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FilterGain withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterGainFieldWithValue:value];
}

- (void)lfoFreqSliderChanged {
    float value = _lfoFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFOFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterLFOFrequencyFieldWithValue:value];
}

- (void)lfoRangeSliderChanged {
    float value = [TWUtils logScaleFromLinear:_lfoRangeSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFORange withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterLFORangeFieldWithValue:value];
}

- (void)lfoOffsetSliderChanged {
    float value = _lfoOffsetSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_LFOOffset withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterLFOOffsetFieldWithValue:value];
}


- (void)rampTimeSliderChanged {
    int value = (int)_rampTimeSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_RampTime_ms withValue:(float)value atSourceIdx:_sourceIdx inTime:0.0f];
    [self updateRampTimeFieldWithValue:value];
}


- (void)fmAmountSliderChanged {
    float value = _fmAmountSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FMAmount withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFMAmountFieldWithValue:value];
}

- (void)fmFreqSliderChanged {
    float value = _fmFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:kOscParam_FMFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFMFrequencyFieldWithValue:value];
}





#pragma mark - Private


- (void)updateBaseFrequencyUIWithValue:(float)frequency {
    [self setOscBaseFrequencySlider:frequency];
    [self updateBaseFreqFieldWithValue:frequency];
}

- (void)updateBeatFrequencyUIWithValue:(float)frequency {
    [_beatFreqSlider setValue:frequency animated:YES];
    [self updateBeatFreqFieldWithValue:frequency];
}

- (void)updateRampTimeValueUIWithValue:(int)rampTime_ms {
    [_rampTimeSlider setValue:rampTime_ms];
    [self updateRampTimeFieldWithValue:rampTime_ms];
}


- (void)updateBaseFreqFieldWithValue:(float)value {
    [_baseFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateBeatFreqFieldWithValue:(float)value {
    [_beatFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateMononessFieldWithValue:(float)value {
    [_mononessField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateTremFreqFieldWithValue:(float)value {
    [_tremoloFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateTremDepthFieldWithValue:(float)value {
    [_tremoloDepthField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFilterCutoffFieldWithValue:(float)value {
    [_cutoffFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFilterResonanceFieldWithValue:(float)value {
    [_resonanceField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFilterGainFieldWithValue:(float)value {
    [_filterGainField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFilterLFOFrequencyFieldWithValue:(float)value {
    [_lfoFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFilterLFORangeFieldWithValue:(float)value {
    [_lfoRangeField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFilterLFOOffsetFieldWithValue:(float)value {
    [_lfoOffsetField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateRampTimeFieldWithValue:(int)value {
    [_rampTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
}

- (void)updateFMAmountFieldWithValue:(float)value {
    [_fmAmountField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateFMFrequencyFieldWithValue:(float)value {
    [_fmFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}


- (void)refreshParametersWithAnimation:(BOOL)animated {
    
    float baseFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_OscBaseFrequency atSourceIdx:_sourceIdx];
    [self updateBaseFrequencyUIWithValue:baseFreq];
    
    float beatFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_OscBeatFrequency atSourceIdx:_sourceIdx];
    [self updateBeatFrequencyUIWithValue:beatFreq];
    
    float mononess = [[TWAudioController sharedController] getOscParameter:kOscParam_OscMononess atSourceIdx:_sourceIdx];
    [_mononessSlider setValue:mononess animated:animated];
    [self updateMononessFieldWithValue:mononess];
    
    
    [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:kOscParam_OscWaveform atSourceIdx:_sourceIdx]];
    
    
    
    float tremFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloFrequency atSourceIdx:_sourceIdx];
    [_tremoloFreqSlider setValue:tremFreq animated:animated];
    [self updateTremFreqFieldWithValue:tremFreq];
    
    float tremDepth = [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloDepth atSourceIdx:_sourceIdx];
    [_tremoloDepthSlider setValue:tremDepth animated:animated];
    [self updateTremDepthFieldWithValue:tremDepth];
    
    
    
    float Fc = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterCutoff atSourceIdx:_sourceIdx];
    [self setCutoffFrequencySlider:Fc];
    [self updateFilterCutoffFieldWithValue:Fc];
    
    
    [_filterSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:kOscParam_FilterType atSourceIdx:_sourceIdx]];
    [_filterEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:kOscParam_FilterEnable atSourceIdx:_sourceIdx]];
    [_lfoEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:kOscParam_LFOEnable atSourceIdx:_sourceIdx]];
    
    
    float gain = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterGain atSourceIdx:_sourceIdx];
    [_filterGainSlider setValue:gain animated:YES];
    [self updateFilterGainFieldWithValue:gain];
    
    float res = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterResonance atSourceIdx:_sourceIdx];
    [self setResonanceSlider:res];
    [self updateFilterResonanceFieldWithValue:res];
    
    float range = [[TWAudioController sharedController] getOscParameter:kOscParam_LFORange atSourceIdx:_sourceIdx];
    [self setFilterLFORangeSlider:range];
    [self updateFilterLFORangeFieldWithValue:range];
    
    float lfoFreq = [[TWAudioController sharedController] getOscParameter:kOscParam_LFOFrequency atSourceIdx:_sourceIdx];
    [_lfoFreqSlider setValue:lfoFreq animated:animated];
    [self updateFilterLFOFrequencyFieldWithValue:lfoFreq];
    
    float lfoOffset = [[TWAudioController sharedController] getOscParameter:kOscParam_LFOOffset atSourceIdx:_sourceIdx];
    [_lfoOffsetSlider setValue:lfoOffset animated:animated];
    [self updateFilterLFOOffsetFieldWithValue:lfoOffset];
    
    int rampTime_ms = (int)[[TWAudioController sharedController] getOscParameter:kOscParam_RampTime_ms atSourceIdx:_sourceIdx];
    [self updateRampTimeValueUIWithValue:rampTime_ms];
    
    float fmAmount = [[TWAudioController sharedController] getOscParameter:kOscParam_FMAmount atSourceIdx:_sourceIdx];
    [_fmAmountSlider setValue:fmAmount animated:animated];
    [self updateFMAmountFieldWithValue:fmAmount];
    
    float fmFrequency = [[TWAudioController sharedController] getOscParameter:kOscParam_FMFrequency atSourceIdx:_sourceIdx];
    [_fmFreqSlider setValue:fmFrequency animated:animated];
    [self updateFMFrequencyFieldWithValue:fmFrequency];
}



- (void)setupButtonFieldProperties:(UIButton*)field {
    [field setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [field.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [field setBackgroundColor:[UIColor clearColor]];
}


- (void)setupLabelProperties:(UILabel*)label {
    [label setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [label setFont:[UIFont systemFontOfSize:9.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
//    [label setBackgroundColor:[UIColor yellowColor]];
    [label setBackgroundColor:[UIColor clearColor]];
}



#pragma mark - Parameter Scaling

- (void)setOscBaseFrequencySlider:(float)value {
    [_baseFreqSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
}

- (void)setCutoffFrequencySlider:(float)value {
    [_cutoffFreqSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
}

- (void)setResonanceSlider:(float)value {
    [_resonanceSlider setValue:[TWUtils linearScaleFromLog:value inMin:kResonanceMin inMax:kResonanceMax] animated:YES];
}

- (void)setFilterLFORangeSlider:(float)value {
    [_lfoRangeSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
}


#pragma mark - TWKeypad

- (void)keypadDoneButtonTapped:(UIButton *)responder withValue:(NSString *)inValue {
    
    if (responder == _baseFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscBaseFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateBaseFreqFieldWithValue:value];
        [self setOscBaseFrequencySlider:value];
    }
    
    else if (responder == _beatFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscBeatFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateBeatFreqFieldWithValue:value];
        [_beatFreqSlider setValue:value animated:YES];
    }
    
    else if (responder == _mononessField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_OscMononess withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateMononessFieldWithValue:value];
        [_mononessSlider setValue:value animated:YES];
    }
    
    else if (responder == _tremoloFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateTremFreqFieldWithValue:value];
        [_tremoloFreqSlider setValue:value animated:YES];
    }
    
    else if (responder == _tremoloDepthField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_TremoloDepth withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateTremDepthFieldWithValue:value];
        [_tremoloDepthSlider setValue:value animated:YES];
    }
    
    else if (responder == _cutoffFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FilterCutoff withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterCutoffFieldWithValue:value];
        [self setCutoffFrequencySlider:value];
    }
    
    else if (responder == _resonanceField) {
        float value = [inValue floatValue];
        if (value <= kResonanceMin) {
            value = kResonanceMin;
        }
        [[TWAudioController sharedController] setOscParameter:kOscParam_FilterResonance withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterResonanceFieldWithValue:value];
        [self setResonanceSlider:value];
    }
    
    else if (responder == _filterGainField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FilterGain withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterGainFieldWithValue:value];
        [_filterGainSlider setValue:value animated:YES];
    }
    
    else if (responder == _lfoFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_LFOFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFOFrequencyFieldWithValue:value];
        [_lfoFreqSlider setValue:value animated:YES];
    }
    
    else if (responder == _lfoOffsetField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_LFOOffset withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFOOffsetFieldWithValue:value];
        [_lfoOffsetSlider setValue:value animated:YES];
    }
    
    else if (responder == _lfoRangeField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_LFORange withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFORangeFieldWithValue:value];
        [self setFilterLFORangeSlider:value];
    }
    
    else if (responder == _rampTimeField) {
        int value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_RampTime_ms withValue:value atSourceIdx:_sourceIdx inTime:0.0f];
        [_rampTimeSlider setValue:value animated:YES];
        [self updateRampTimeFieldWithValue:value];
    }
    
    else if (responder == _fmAmountField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FMAmount withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFMAmountFieldWithValue:value];
        [_fmAmountSlider setValue:value animated:YES];
    }
    
    else if (responder == _fmFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:kOscParam_FMFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFMFrequencyFieldWithValue:value];
        [_fmFreqSlider setValue:value animated:YES];
    }
}


- (void)keypadCancelButtonTapped:(UIButton *)responder {
    
    if (responder == _baseFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_OscBaseFrequency atSourceIdx:_sourceIdx];
        [self updateBaseFreqFieldWithValue:value];
    }
    
    else if (responder == _beatFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_OscBeatFrequency atSourceIdx:_sourceIdx];
        [self updateBeatFreqFieldWithValue:value];
    }
    
    else if (responder == _mononessField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_OscMononess atSourceIdx:_sourceIdx];
        [self updateMononessFieldWithValue:value];
    }
    
    else if (responder == _tremoloFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloFrequency atSourceIdx:_sourceIdx];
        [self updateTremFreqFieldWithValue:value];
    }
    
    else if (responder == _tremoloDepthField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloDepth atSourceIdx:_sourceIdx];
        [self updateTremDepthFieldWithValue:value];
    }
    
    else if (responder == _cutoffFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterCutoff atSourceIdx:_sourceIdx];
        [self updateFilterCutoffFieldWithValue:value];
    }
    
    else if (responder == _resonanceField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterResonance atSourceIdx:_sourceIdx];
        [self updateFilterResonanceFieldWithValue:value];
    }
    
    else if (responder == _filterGainField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_FilterGain atSourceIdx:_sourceIdx];
        [self updateFilterGainFieldWithValue:value];
    }
    
    else if (responder == _lfoFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_LFOFrequency atSourceIdx:_sourceIdx];
        [self updateFilterLFOFrequencyFieldWithValue:value];
    }
    
    else if (responder == _lfoOffsetField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_LFOOffset atSourceIdx:_sourceIdx];
        [self updateFilterLFOOffsetFieldWithValue:value];
    }
    
    else if (responder == _lfoRangeField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_LFORange atSourceIdx:_sourceIdx];
        [self updateFilterLFORangeFieldWithValue:value];
    }
    
    else if (responder == _rampTimeField) {
        int value = (int)(int)[[TWAudioController sharedController] getOscParameter:kOscParam_RampTime_ms atSourceIdx:_sourceIdx];
        [self updateRampTimeFieldWithValue:value];
    }
    
    else if (responder == _fmAmountField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_FMAmount atSourceIdx:_sourceIdx];
        [self updateFMAmountFieldWithValue:value];
    }
    
    else if (responder == _fmFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:kOscParam_FMFrequency atSourceIdx:_sourceIdx];
        [self updateFMFrequencyFieldWithValue:value];
    }
}





- (void)baseFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Base Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_OscBaseFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_baseFreqField];
}

- (void)beatFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Beat Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_OscBeatFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_beatFreqField];
}

- (void)mononessFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Mononess: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_OscMononess atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_mononessField];
}

- (void)tremFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Trem Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_tremoloFreqField];
}

- (void)tremDepthFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Trem Depth (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_TremoloDepth atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_tremoloDepthField];
}

- (void)cutoffFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter Fc (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_FilterCutoff atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_cutoffFreqField];
}

- (void)resonanceFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Resonance (Q): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_FilterResonance atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_resonanceField];
}

- (void)filterGainFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter Gain: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_FilterGain atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_filterGainField];
}

- (void)lfoFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_LFOFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_lfoFreqField];
}

- (void)lfoRangeFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Range (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_LFORange atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_lfoRangeField];
}

- (void)lfoOffsetFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Offset (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_LFOOffset atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_lfoOffsetField];
}

- (void)rampTimeFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Ramp Time (ms): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%d", (int)(int)[[TWAudioController sharedController] getOscParameter:kOscParam_RampTime_ms atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_rampTimeField];
}

- (void)fmAmountFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] FM Amount: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_FMAmount atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_fmAmountField];
}

- (void)fmFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] FM Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:kOscParam_FMFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_fmFreqField];
}



    
@end

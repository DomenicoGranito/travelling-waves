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
    UISegmentedControl*         _componentWaveformSelector;
    
    UILabel*                    _baseFreqLabel;
    UISlider*                   _baseFreqSlider;
    UIButton*                   _baseFreqField;
    
    UISlider*                   _beatFreqSlider;
    UIButton*                   _beatFreqField;
    
    UILabel*                    _mononessLabel;
    UISlider*                   _mononessSlider;
    UIButton*                   _mononessField;
    
    UILabel*                    _softClipLabel;
    UISlider*                   _softClipSlider;
    UIButton*                   _softClipField;
    
    
    // Tremolo
    UIView*                     _tremBackView;
    
    UILabel*                    _tremFreqLabel;
    UISlider*                   _tremoloFreqSlider;
    UIButton*                   _tremoloFreqField;
    
    UILabel*                    _tremDepthLabel;
    UISlider*                   _tremoloDepthSlider;
    UIButton*                   _tremoloDepthField;
    
    
    // Shape Tremolo
    UILabel*                    _shapeTremFreqLabel;
    UISlider*                   _shapeTremoloFreqSlider;
    UIButton*                   _shapeTremoloFreqField;
    
    UILabel*                    _shapeTremDepthLabel;
    UISlider*                   _shapeTremoloDepthSlider;
    UIButton*                   _shapeTremoloDepthField;
    
    UILabel*                    _shapeTremShapeLabel;
    UISlider*                   _shapeTremoloShapeSlider;
    UIButton*                   _shapeTremoloShapeField;
    
    
    
    // Filter
    UIView*                     _filterBackView;
    
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
    UILabel*                    _rampTimeLabel;
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
    
    
    NSDictionary*               _paramSliders;
    NSDictionary*               _paramFields;
    NSDictionary*               _paramLongTitles;
    NSDictionary*               _paramSliderScales;
    NSDictionary*               _paramRanges;
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
    [_segmentedControl setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_segmentedControl setSelectedSegmentIndex:0];
    [_segmentedControl setTintColor:[UIColor segmentedControlTintColor]];
    [_segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_segmentedControl];
    
    
    
    NSMutableDictionary* paramSliders = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* paramFields = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* paramLongTitles = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* paramSliderScales = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* paramRanges = [[NSMutableDictionary alloc] init];
    
    
    // Oscillator
    
    _oscBackView = [[UIView alloc] init];
    [_oscBackView setUserInteractionEnabled:NO];
    [_oscBackView setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.2f]];
    [self addSubview:_oscBackView];
    
    
    
    _baseFreqLabel = [[UILabel alloc] init];
    [_baseFreqLabel setText:@"Freq:"];
    [paramLongTitles setObject:@"Base Freq (Hz)" forKey:@(TWOscParamID_OscBaseFrequency)];
    [self setupLabelProperties:_baseFreqLabel];
    [self addSubview:_baseFreqLabel];
    
    
    _baseFreqSlider = [[UISlider alloc] init];
    [_baseFreqSlider setMinimumValue:0.0f];
    [_baseFreqSlider setMaximumValue:1.0f];
    [_baseFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_baseFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_baseFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_baseFreqSlider addTarget:self action:@selector(baseFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_baseFreqSlider setTag:TWOscParamID_OscBaseFrequency];
    [paramSliders setObject:_baseFreqSlider forKey:@(TWOscParamID_OscBaseFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_OscBaseFrequency)];
    [paramRanges setObject:@[@(kFrequencyMin), @(kFrequencyMax)] forKey:@(TWOscParamID_OscBaseFrequency)];
    [self addSubview:_baseFreqSlider];
    
    _baseFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_baseFreqField];
    [_baseFreqField addTarget:self action:@selector(baseFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_baseFreqField setTag:TWOscParamID_OscBaseFrequency];
    [paramFields setObject:_baseFreqField forKey:@(TWOscParamID_OscBaseFrequency)];
    [self addSubview:_baseFreqField];
    
    
    _beatFreqSlider = [[UISlider alloc] init];
    [_beatFreqSlider setMinimumValue:0.0f];
    [_beatFreqSlider setMaximumValue:32.0f];
    [_beatFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_beatFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_beatFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_beatFreqSlider addTarget:self action:@selector(beatFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_beatFreqSlider setTag:TWOscParamID_OscBeatFrequency];
    [paramSliders setObject:_beatFreqSlider forKey:@(TWOscParamID_OscBeatFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscBeatFrequency)];
    [self addSubview:_beatFreqSlider];
    
    [paramLongTitles setObject:@"Beat Freq (Hz)" forKey:@(TWOscParamID_OscBeatFrequency)];
    
    _beatFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_beatFreqField];
    [_beatFreqField addTarget:self action:@selector(beatFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_beatFreqField setTag:TWOscParamID_OscBeatFrequency];
    [paramFields setObject:_beatFreqField forKey:@(TWOscParamID_OscBeatFrequency)];
    [self addSubview:_beatFreqField];
    
    
    
    _mononessLabel = [[UILabel alloc] init];
    [_mononessLabel setText:@"Mono:"];
    [self setupLabelProperties:_mononessLabel];
    [self addSubview:_mononessLabel];
    
    [paramLongTitles setObject:@"Mononess" forKey:@(TWOscParamID_OscMononess)];
    
    _mononessSlider = [[UISlider alloc] init];
    [_mononessSlider setMinimumValue:0.0f];
    [_mononessSlider setMaximumValue:1.0f];
    [_mononessSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_mononessSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_mononessSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_mononessSlider addTarget:self action:@selector(mononessSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_mononessSlider setTag:TWOscParamID_OscMononess];
    [paramSliders setObject:_mononessSlider forKey:@(TWOscParamID_OscMononess)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscMononess)];
    [self addSubview:_mononessSlider];
    
    _mononessField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_mononessField];
    [_mononessField addTarget:self action:@selector(mononessFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_mononessField setTag:TWOscParamID_OscMononess];
    [paramFields setObject:_mononessField forKey:@(TWOscParamID_OscMononess)];
    [self addSubview:_mononessField];

    
    
    
    _softClipLabel = [[UILabel alloc] init];
    [_softClipLabel setText:@"Clip:"];
    [self setupLabelProperties:_softClipLabel];
    [self addSubview:_softClipLabel];
    
    [paramLongTitles setObject:@"Soft Clip" forKey:@(TWOscParamID_OscSoftClipp)];
    
    _softClipSlider = [[UISlider alloc] init];
    [_softClipSlider setMinimumValue:0.0f];
    [_softClipSlider setMaximumValue:1.0f];
    [_softClipSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_softClipSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_softClipSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_softClipSlider addTarget:self action:@selector(softClipSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_softClipSlider setTag:TWOscParamID_OscSoftClipp];
    [paramSliders setObject:_softClipSlider forKey:@(TWOscParamID_OscSoftClipp)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscSoftClipp)];
    [self addSubview:_softClipSlider];
    
    _softClipField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_softClipField];
    [_softClipField addTarget:self action:@selector(softClipFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_softClipField setTag:TWOscParamID_OscSoftClipp];
    [paramFields setObject:_softClipField forKey:@(TWOscParamID_OscSoftClipp)];
    [self addSubview:_softClipField];

    
    
    
    
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    _waveformSelector = [[UISegmentedControl alloc] initWithItems:@[@"Sine", @"Saw", @"Square", @"Noise", @"Random"]];
    [_waveformSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_waveformSelector setTintColor:[UIColor sliderOnColor]];
    [_waveformSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_waveformSelector addTarget:self action:@selector(waveformChanged) forControlEvents:UIControlEventValueChanged];
    [_waveformSelector setTag:TWOscParamID_OscWaveform];
    [self addSubview:_waveformSelector];
    
    _componentWaveformSelector = [[UISegmentedControl alloc] initWithItems:@[@"Osc", @"Tremolo", @"Filter LFO", @"FM"]];
    [_componentWaveformSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_componentWaveformSelector setTintColor:[UIColor sliderOnColor]];
    [_componentWaveformSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_componentWaveformSelector setSelectedSegmentIndex:0];
    [_componentWaveformSelector addTarget:self action:@selector(waveformComponentChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_componentWaveformSelector];
    
    
    
    // Tremolo
    
    _tremBackView = [[UIView alloc] init];
    [_tremBackView setUserInteractionEnabled:NO];
    [_tremBackView setBackgroundColor:[UIColor colorWithWhite:0.06f alpha:0.3f]];
    [self addSubview:_tremBackView];
    
    _tremFreqLabel = [[UILabel alloc] init];
    [_tremFreqLabel setText:@"TrRt:"];
    [self setupLabelProperties:_tremFreqLabel];
    [self addSubview:_tremFreqLabel];
    
    [paramLongTitles setObject:@"Trem Rate (Hz)" forKey:@(TWOscParamID_TremoloFrequency)];
    
    _tremoloFreqSlider = [[UISlider alloc] init];
    [_tremoloFreqSlider setMinimumValue:0.0f];
    [_tremoloFreqSlider setMaximumValue:24.0f];
    [_tremoloFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tremoloFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tremoloFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tremoloFreqSlider addTarget:self action:@selector(tremFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_tremoloFreqSlider setTag:TWOscParamID_TremoloFrequency];
    [paramSliders setObject:_tremoloFreqSlider forKey:@(TWOscParamID_TremoloFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_TremoloFrequency)];
    [self addSubview:_tremoloFreqSlider];
    
    _tremoloFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_tremoloFreqField];
    [_tremoloFreqField addTarget:self action:@selector(tremFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_tremoloFreqField setTag:TWOscParamID_TremoloFrequency];
    [paramFields setObject:_tremoloFreqField forKey:@(TWOscParamID_TremoloFrequency)];
    [self addSubview:_tremoloFreqField];
    
    
    _tremDepthLabel = [[UILabel alloc] init];
    [_tremDepthLabel setText:@"TrDp:"];
    [self setupLabelProperties:_tremDepthLabel];
    [self addSubview:_tremDepthLabel];
    
    [paramLongTitles setObject:@"Trem Depth" forKey:@(TWOscParamID_TremoloDepth)];
    
    _tremoloDepthSlider = [[UISlider alloc] init];
    [_tremoloDepthSlider setMinimumValue:0.0f];
    [_tremoloDepthSlider setMaximumValue:1.0f];
    [_tremoloDepthSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tremoloDepthSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tremoloDepthSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tremoloDepthSlider addTarget:self action:@selector(tremDepthSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_tremoloDepthSlider setTag:TWOscParamID_TremoloDepth];
    [paramSliders setObject:_tremoloDepthSlider forKey:@(TWOscParamID_TremoloDepth)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_TremoloDepth)];
    [self addSubview:_tremoloDepthSlider];
    
    _tremoloDepthField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_tremoloDepthField];
    [_tremoloDepthField addTarget:self action:@selector(tremDepthFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_tremoloDepthField setTag:TWOscParamID_TremoloDepth];
    [paramFields setObject:_tremoloDepthField forKey:@(TWOscParamID_TremoloDepth)];
    [self addSubview:_tremoloDepthField];
    
    
    
    // Shape Tremolo
    
    _shapeTremFreqLabel = [[UILabel alloc] init];
    [_shapeTremFreqLabel setText:@"STRt:"];
    [self setupLabelProperties:_shapeTremFreqLabel];
    [self addSubview:_shapeTremFreqLabel];
    
    [paramLongTitles setObject:@"Shape Trem Rate (Hz)" forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    
    _shapeTremoloFreqSlider = [[UISlider alloc] init];
    [_shapeTremoloFreqSlider setMinimumValue:0.0f];
    [_shapeTremoloFreqSlider setMaximumValue:24.0f];
    [_shapeTremoloFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_shapeTremoloFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloFreqSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_shapeTremoloFreqSlider setTag:TWOscParamID_ShapeTremoloFrequency];
    [paramSliders setObject:_shapeTremoloFreqSlider forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    [self addSubview:_shapeTremoloFreqSlider];
    
    _shapeTremoloFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_shapeTremoloFreqField];
    [_shapeTremoloFreqField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_shapeTremoloFreqField setTag:TWOscParamID_ShapeTremoloFrequency];
    [paramFields setObject:_shapeTremoloFreqField forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    [self addSubview:_shapeTremoloFreqField];
    
    
    _shapeTremDepthLabel = [[UILabel alloc] init];
    [_shapeTremDepthLabel setText:@"STDp:"];
    [self setupLabelProperties:_shapeTremDepthLabel];
    [self addSubview:_shapeTremDepthLabel];
    
    [paramLongTitles setObject:@"Shape Trem Depth" forKey:@(TWOscParamID_ShapeTremoloDepth)];
    
    _shapeTremoloDepthSlider = [[UISlider alloc] init];
    [_shapeTremoloDepthSlider setMinimumValue:0.0f];
    [_shapeTremoloDepthSlider setMaximumValue:1.0f];
    [_shapeTremoloDepthSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloDepthSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_shapeTremoloDepthSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloDepthSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_shapeTremoloDepthSlider setTag:TWOscParamID_ShapeTremoloDepth];
    [paramSliders setObject:_shapeTremoloDepthSlider forKey:@(TWOscParamID_ShapeTremoloDepth)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_ShapeTremoloDepth)];
    [self addSubview:_shapeTremoloDepthSlider];
    
    _shapeTremoloDepthField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_shapeTremoloDepthField];
    [_shapeTremoloDepthField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_shapeTremoloDepthField setTag:TWOscParamID_ShapeTremoloDepth];
    [paramFields setObject:_shapeTremoloDepthField forKey:@(TWOscParamID_ShapeTremoloDepth)];
    [self addSubview:_shapeTremoloDepthField];
    
    
    _shapeTremShapeLabel = [[UILabel alloc] init];
    [_shapeTremShapeLabel setText:@"STSp:"];
    [self setupLabelProperties:_shapeTremShapeLabel];
    [self addSubview:_shapeTremShapeLabel];
    
    [paramLongTitles setObject:@"Shape Trem Shape" forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    
    _shapeTremoloShapeSlider = [[UISlider alloc] init];
    [_shapeTremoloShapeSlider setMinimumValue:0.0f];
    [_shapeTremoloShapeSlider setMaximumValue:1.0f];
    [_shapeTremoloShapeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloShapeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_shapeTremoloShapeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloShapeSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_shapeTremoloDepthSlider setTag:TWOscParamID_ShapeTremoloSoftClipp];
    [paramSliders setObject:_shapeTremoloShapeSlider forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    [self addSubview:_shapeTremoloShapeSlider];
    
    _shapeTremoloShapeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_shapeTremoloShapeField];
    [_shapeTremoloShapeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_shapeTremoloShapeField setTag:TWOscParamID_ShapeTremoloSoftClipp];
    [paramFields setObject:_shapeTremoloShapeField forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    [self addSubview:_shapeTremoloShapeField];
    
    
    
    
    // Filter
    
    _filterBackView = [[UIView alloc] init];
    [_filterBackView setUserInteractionEnabled:NO];
    [_filterBackView setBackgroundColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];
    [self addSubview:_filterBackView];
    
    _fcLabel = [[UILabel alloc] init];
    [_fcLabel setText:@"Fc:"];
    [self setupLabelProperties:_fcLabel];
    [self addSubview:_fcLabel];
    
    [paramLongTitles setObject:@"Filter Fc (Hz)" forKey:@(TWOscParamID_FilterCutoff)];
    
    _cutoffFreqSlider = [[UISlider alloc] init];
    [_cutoffFreqSlider setMinimumValue:0.0f];
    [_cutoffFreqSlider setMaximumValue:1.0f];
    [_cutoffFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_cutoffFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_cutoffFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_cutoffFreqSlider addTarget:self action:@selector(cutoffFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_cutoffFreqSlider setTag:TWOscParamID_FilterCutoff];
    [paramSliders setObject:_cutoffFreqSlider forKey:@(TWOscParamID_FilterCutoff)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_FilterCutoff)];
    [paramRanges setObject:@[@(kFrequencyMin), @(kFrequencyMax)] forKey:@(TWOscParamID_FilterCutoff)];
    [self addSubview:_cutoffFreqSlider];
    
    _cutoffFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_cutoffFreqField];
    [_cutoffFreqField addTarget:self action:@selector(cutoffFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cutoffFreqField setTag:TWOscParamID_FilterCutoff];
    [paramFields setObject:_shapeTremoloShapeField forKey:@(TWOscParamID_FilterCutoff)];
    [self addSubview:_cutoffFreqField];
    
    
    _filterSelector = [[UISegmentedControl alloc] initWithItems:@[@"LPF", @"HPF", @"BPF1", @"BPF2", @"Ntch"]];
    [_filterSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_filterSelector setTintColor:[UIColor sliderOnColor]];
    [_filterSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_filterSelector addTarget:self action:@selector(filterTypeChanged) forControlEvents:UIControlEventValueChanged];
    [_filterSelector setTag:TWOscParamID_FilterType];
    [self addSubview:_filterSelector];
    
    _filterEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_filterEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch addTarget:self action:@selector(filterEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [_filterEnableSwitch setTag:TWOscParamID_FilterEnable];
    [self addSubview:_filterEnableSwitch];
    
    _lfoEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_lfoEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_lfoEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_lfoEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoEnableSwitch addTarget:self action:@selector(lfoEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoEnableSwitch setTag:TWOscParamID_FilterLFOEnable];
    [self addSubview:_lfoEnableSwitch];
    
    
    _resonanceLabel = [[UILabel alloc] init];
    [_resonanceLabel setText:@"Q:"];
    [self setupLabelProperties:_resonanceLabel];
    [self addSubview:_resonanceLabel];
    
    [paramLongTitles setObject:@"Resonance (Q)" forKey:@(TWOscParamID_FilterResonance)];
    
    _resonanceSlider = [[UISlider alloc] init];
    [_resonanceSlider setMinimumValue:0.0f];
    [_resonanceSlider setMaximumValue:1.0f];
    [_resonanceSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_resonanceSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_resonanceSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_resonanceSlider addTarget:self action:@selector(resonanceSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_resonanceSlider setTag:TWOscParamID_FilterResonance];
    [paramSliders setObject:_resonanceSlider forKey:@(TWOscParamID_FilterResonance)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_FilterResonance)];
    [paramRanges setObject:@[@(kResonanceMin), @(kResonanceMax)] forKey:@(TWOscParamID_FilterResonance)];
    [self addSubview:_resonanceSlider];
    
    _resonanceField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_resonanceField];
    [_resonanceField addTarget:self action:@selector(resonanceFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_resonanceField setTag:TWOscParamID_FilterResonance];
    [paramFields setObject:_resonanceField forKey:@(TWOscParamID_FilterResonance)];
    [self addSubview:_resonanceField];
    
    
    _filterGainLabel = [[UILabel alloc] init];
    [_filterGainLabel setText:@"G:"];
    [self setupLabelProperties:_filterGainLabel];
    [self addSubview:_filterGainLabel];
    
    [paramLongTitles setObject:@"Filter Gain" forKey:@(TWOscParamID_FilterGain)];
    
    _filterGainSlider = [[UISlider alloc] init];
    [_filterGainSlider setMinimumValue:1.0f];
    [_filterGainSlider setMaximumValue:5.0f];
    [_filterGainSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterGainSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterGainSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterGainSlider addTarget:self action:@selector(filterGainSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_filterGainSlider setTag:TWOscParamID_FilterGain];
    [paramSliders setObject:_filterGainSlider forKey:@(TWOscParamID_FilterGain)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FilterGain)];
    [self addSubview:_filterGainSlider];
    
    _filterGainField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterGainField];
    [_filterGainField addTarget:self action:@selector(filterGainFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_filterGainField setTag:TWOscParamID_FilterGain];
    [paramFields setObject:_filterGainField forKey:@(TWOscParamID_FilterGain)];
    [self addSubview:_filterGainField];
    
    
    
    _lfoFLabel = [[UILabel alloc] init];
    [_lfoFLabel setText:@"LFrt:"];
    [self setupLabelProperties:_lfoFLabel];
    [self addSubview:_lfoFLabel];
    
    [paramLongTitles setObject:@"Filter LFO Freq (Hz)" forKey:@(TWOscParamID_FilterLFOFrequency)];
    
    _lfoFreqSlider = [[UISlider alloc] init];
    [_lfoFreqSlider setMinimumValue:0.0f];
    [_lfoFreqSlider setMaximumValue:24.0f];
    [_lfoFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_lfoFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_lfoFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoFreqSlider addTarget:self action:@selector(lfoFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoFreqSlider setTag:TWOscParamID_FilterLFOFrequency];
    [paramSliders setObject:_lfoFreqSlider forKey:@(TWOscParamID_FilterLFOFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FilterLFOFrequency)];
    [self addSubview:_lfoFreqSlider];
    
    _lfoFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_lfoFreqField];
    [_lfoFreqField addTarget:self action:@selector(lfoFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_lfoFreqField setTag:TWOscParamID_FilterLFOFrequency];
    [paramFields setObject:_lfoFreqField forKey:@(TWOscParamID_FilterLFOFrequency)];
    [self addSubview:_lfoFreqField];
    
    
    _lfoRLabel = [[UILabel alloc] init];
    [_lfoRLabel setText:@"Rnge:"];
    [self setupLabelProperties:_lfoRLabel];
    [self addSubview:_lfoRLabel];
    
    [paramLongTitles setObject:@"Filter LFO Range (Hz)" forKey:@(TWOscParamID_FilterLFORange)];
    
    _lfoRangeSlider = [[UISlider alloc] init];
    [_lfoRangeSlider setMinimumValue:0.0f];
    [_lfoRangeSlider setMaximumValue:1.0f];
    [_lfoRangeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_lfoRangeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_lfoRangeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoRangeSlider addTarget:self action:@selector(lfoRangeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoRangeSlider setTag:TWOscParamID_FilterLFORange];
    [paramSliders setObject:_lfoRangeSlider forKey:@(TWOscParamID_FilterLFORange)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_FilterLFORange)];
    [paramRanges setObject:@[@(kFrequencyMin), @(kFrequencyMax)] forKey:@(TWOscParamID_FilterLFORange)];
    [self addSubview:_lfoRangeSlider];
    
    _lfoRangeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_lfoRangeField];
    [_lfoRangeField addTarget:self action:@selector(lfoRangeFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_lfoRangeField setTag:TWOscParamID_FilterLFORange];
    [paramFields setObject:_lfoRangeField forKey:@(TWOscParamID_FilterLFORange)];
    [self addSubview:_lfoRangeField];
    
    
    _ofstLabel = [[UILabel alloc] init];
    [_ofstLabel setText:@"Ofst:"];
    [self setupLabelProperties:_ofstLabel];
    [self addSubview:_ofstLabel];
    
    [paramLongTitles setObject:@"Filter LFO Offset" forKey:@(TWOscParamID_FilterLFOOffset)];
    
    _lfoOffsetSlider = [[UISlider alloc] init];
    [_lfoOffsetSlider setMinimumValue:0.0f];
    [_lfoOffsetSlider setMaximumValue:2.0f * M_PI];
    [_lfoOffsetSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_lfoOffsetSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_lfoOffsetSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_lfoOffsetSlider addTarget:self action:@selector(lfoOffsetSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_lfoOffsetSlider setTag:TWOscParamID_FilterLFOOffset];
    [paramSliders setObject:_lfoOffsetSlider forKey:@(TWOscParamID_FilterLFOOffset)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FilterLFOOffset)];
    [self addSubview:_lfoOffsetSlider];
    
    _lfoOffsetField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_lfoOffsetField];
    [_lfoOffsetField addTarget:self action:@selector(lfoOffsetFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_lfoOffsetField setTag:TWOscParamID_FilterLFOOffset];
    [paramFields setObject:_lfoOffsetField forKey:@(TWOscParamID_FilterLFOOffset)];
    [self addSubview:_lfoOffsetField];
    
    
    
    // Ramp Time
    
    _rampTimeLabel = [[UILabel alloc] init];
    [_rampTimeLabel setText:@"Ramp:"];
    [self setupLabelProperties:_rampTimeLabel];
    [self addSubview:_rampTimeLabel];
    
    [paramLongTitles setObject:@"Ramp Time (ms)" forKey:@(TWOscParamID_RampTime_ms)];
    
    _rampTimeSlider = [[UISlider alloc] init];
    [_rampTimeSlider setMinimumValue:0.0f];
    [_rampTimeSlider setMaximumValue:8000.0f];
    [_rampTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_rampTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_rampTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_rampTimeSlider addTarget:self action:@selector(rampTimeSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_rampTimeSlider setTag:TWOscParamID_RampTime_ms];
    [paramSliders setObject:_rampTimeSlider forKey:@(TWOscParamID_RampTime_ms)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_RampTime_ms)];
    [self addSubview:_rampTimeSlider];
    
    _rampTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_rampTimeField];
    [_rampTimeField addTarget:self action:@selector(rampTimeFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_rampTimeField setTag:TWOscParamID_RampTime_ms];
    [paramFields setObject:_rampTimeField forKey:@(TWOscParamID_RampTime_ms)];
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
    
    [paramLongTitles setObject:@"FM Amount" forKey:@(TWOscParamID_FMAmount)];
    
    _fmAmountSlider = [[UISlider alloc] init];
    [_fmAmountSlider setMinimumValue:0.0f];
    [_fmAmountSlider setMaximumValue:1.0f];
    [_fmAmountSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fmAmountSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fmAmountSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_fmAmountSlider addTarget:self action:@selector(fmAmountSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_fmAmountSlider setTag:TWOscParamID_FMAmount];
    [paramSliders setObject:_fmAmountSlider forKey:@(TWOscParamID_FMAmount)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FMAmount)];
    [self addSubview:_fmAmountSlider];
    
    _fmAmountField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_fmAmountField];
    [_fmAmountField addTarget:self action:@selector(fmAmountFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_fmAmountField setTag:TWOscParamID_FMAmount];
    [paramFields setObject:_fmAmountField forKey:@(TWOscParamID_FMAmount)];
    [self addSubview:_fmAmountField];
    
    
    _fmFreqLabel = [[UILabel alloc] init];
    [_fmFreqLabel setText:@"FM-F:"];
    [self setupLabelProperties:_fmFreqLabel];
    [self addSubview:_fmFreqLabel];
    
    [paramLongTitles setObject:@"FM Freq" forKey:@(TWOscParamID_FMFrequency)];
    
    _fmFreqSlider = [[UISlider alloc] init];
    [_fmFreqSlider setMinimumValue:0.001f];
    [_fmFreqSlider setMaximumValue:200.0f];
    [_fmFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_fmFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_fmFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_fmFreqSlider addTarget:self action:@selector(fmFreqSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_fmFreqSlider setTag:TWOscParamID_FMFrequency];
    [paramSliders setObject:_fmFreqSlider forKey:@(TWOscParamID_FMFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FMFrequency)];
    [self addSubview:_fmFreqSlider];
    
    _fmFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_fmFreqField];
    [_fmFreqField addTarget:self action:@selector(fmFreqFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [_fmFreqField setTag:TWOscParamID_FMFrequency];
    [paramFields setObject:_fmFreqField forKey:@(TWOscParamID_FMFrequency)];
    [self addSubview:_fmFreqField];
    
    
    _paramSliders = [[NSDictionary alloc] initWithDictionary:paramSliders];
    _paramFields = [[NSDictionary alloc] initWithDictionary:paramFields];
    _paramLongTitles = [[NSDictionary alloc] initWithDictionary:paramLongTitles];
    _paramSliderScales = [[NSDictionary alloc] initWithDictionary:paramSliderScales];
    _paramRanges = [[NSDictionary alloc] initWithDictionary:paramRanges];
    
    
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
    
    xPos = 0.0f;
    [_baseFreqLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
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
    
    sliderWidth = (frame.size.width - (2.0f * (kTitleLabelWidth + kValueLabelWidth))) / 2.0f;
    
    [_mononessLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += kTitleLabelWidth;
    [_mononessSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _mononessSlider.frame.size.width;
    [_mononessField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _mononessField.frame.size.width;
    [_softClipLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _softClipLabel.frame.size.width;
    [_softClipSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _softClipSlider.frame.size.width;
    [_softClipField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    CGFloat waveformSelectorsWidth = (frame.size.width - (2.0f * kButtonXMargin)) / 2.0f;
    [_componentWaveformSelector setFrame:CGRectMake(xPos, yPos + 5.0f, waveformSelectorsWidth, componentHeight - 10.0f)];
    xPos += waveformSelectorsWidth + (2.0f * kButtonXMargin);
    [_waveformSelector setFrame:CGRectMake(xPos, yPos + 5.0f, waveformSelectorsWidth, componentHeight - 10.0f)];
    
    
    
    // Tremolo
    
    yPos += componentHeight;
    xPos = 0.0f;
    
    sliderWidth = (frame.size.width - (2.0f * (kTitleLabelWidth + kValueLabelWidth))) / 2.0f;
    
    [_tremBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 2.0f * componentHeight)];
    
    [_tremFreqLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _tremFreqLabel.frame.size.width;
    [_tremoloFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _tremoloFreqSlider.frame.size.width;
    [_tremoloFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _tremoloFreqField.frame.size.width;
    [_tremDepthLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _tremDepthLabel.frame.size.width;
    [_tremoloDepthSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _tremoloDepthSlider.frame.size.width;
    [_tremoloDepthField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    // Shape Tremolo
    
    yPos += componentHeight;
    xPos = 0.0f;
    
    sliderWidth = (frame.size.width - (3.0f * (kTitleLabelWidth + kValueLabelWidth))) / 3.0f;
    
    [_shapeTremFreqLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _shapeTremFreqLabel.frame.size.width;
    [_shapeTremoloFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _shapeTremoloFreqSlider.frame.size.width;
    [_shapeTremoloFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    xPos += _shapeTremoloFreqField.frame.size.width;
    [_shapeTremDepthLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _shapeTremDepthLabel.frame.size.width;
    [_shapeTremoloDepthSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _shapeTremoloDepthSlider.frame.size.width;
    [_shapeTremoloDepthField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    [_shapeTremShapeLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _shapeTremShapeLabel.frame.size.width;
    [_shapeTremoloShapeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _shapeTremoloShapeSlider.frame.size.width;
    [_shapeTremoloShapeField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
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
    [_rampTimeLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
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


#pragma mark - User Interface

- (void)paramSliderChanged:(UISlider*)sender {
    
    TWOscParamID paramID = (TWOscParamID)sender.tag;
    TWParamSliderScale scale = (TWParamSliderScale)[_paramSliderScales objectForKey:@(paramID)];
    float value = 0.0f;
    
    switch (scale) {
        case TWParamSliderScale_Linear:
            value = sender.value;
            break;
            
        case TWParamSliderScale_Log:
        {
            float min = [[_paramRanges objectForKey:@(paramID)][TWParamRange_Min] floatValue];
            float max = [[_paramRanges objectForKey:@(paramID)][TWParamRange_Max] floatValue];
            value = [TWUtils logScaleFromLinear:sender.value outMin:min outMax:max];
        }
            break;
            
        default:
            break;
    }
    
    [[TWAudioController sharedController] setOscParameter:paramID withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    
    UIButton* paramField = [_paramFields objectForKey:@(paramID)];
    [self updateParamField:paramField withValue:value];
}

- (void)paramFieldTapped:(UIButton*)sender {
    TWOscParamID paramID = (TWOscParamID)sender.tag;
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    float value = [[TWAudioController sharedController] getOscParameter:paramID atSourceIdx:_sourceIdx];
    NSString* fieldTitle = (NSString*)[_paramLongTitles objectForKey:@(paramID)];
    [keypad setTitle:[fieldTitle stringByAppendingString:[NSString stringWithFormat:@" [%d] : ", _sourceIdx]]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", value]];
    [keypad setCurrentResponder:sender];
}

- (void)updateParamField:(UIButton*)field withValue:(float)value {
    [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}







- (void)baseFreqSliderChanged {
    float value = [TWUtils logScaleFromLinear:_baseFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBaseFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateBaseFreqFieldWithValue:value];
}

- (void)beatFreqSliderChanged {
    float value = _beatFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBeatFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateBeatFreqFieldWithValue:value];
}

- (void)mononessSliderChanged {
    float value = _mononessSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscMononess withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateMononessFieldWithValue:value];
}

- (void)softClipSliderChanged {
    float value = _softClipSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscSoftClipp withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateSoftClipFieldWithValue:value];
}

- (void)waveformChanged {
    switch ([_componentWaveformSelector selectedSegmentIndex]) {
        case 0:
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
            break;
        case 1:
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
            break;
        case 2:
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
            break;
        case 3:
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_FMWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
            break;
        default:
            break;
    }
}

- (void)waveformComponentChanged {
    [self updateWaveformFromComponent];
}



- (void)tremFreqSliderChanged {
    float value = _tremoloFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateTremFreqFieldWithValue:value];
}

- (void)tremDepthSliderChanged {
    float value = _tremoloDepthSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloDepth withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateTremDepthFieldWithValue:value];
}


- (void)shapeTremFreqSliderChanged {
    float value = _shapeTremoloFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_ShapeTremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateTremDepthFieldWithValue:value];
}


- (void)filterEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterEnable withValue:_filterEnableSwitch.on atSourceIdx:_sourceIdx inTime:0];
}

- (void)filterTypeChanged {
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterType withValue:_filterSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
}

- (void)cutoffFreqSliderChanged {
    float frequency = [TWUtils logScaleFromLinear:_cutoffFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterCutoff withValue:frequency atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterCutoffFieldWithValue:frequency];
}

- (void)lfoEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOEnable withValue:_lfoEnableSwitch.on atSourceIdx:_sourceIdx inTime:0];
}

- (void)resonanceSliderChanged {
    float value = [TWUtils logScaleFromLinear:_resonanceSlider.value outMin:kResonanceMin outMax:kResonanceMax];
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterResonance withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterResonanceFieldWithValue:value];
}

- (void)filterGainSliderChanged {
    float value = _filterGainSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterGain withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterGainFieldWithValue:value];
}

- (void)lfoFreqSliderChanged {
    float value = _lfoFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterLFOFrequencyFieldWithValue:value];
}

- (void)lfoRangeSliderChanged {
    float value = [TWUtils logScaleFromLinear:_lfoRangeSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFORange withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterLFORangeFieldWithValue:value];
}

- (void)lfoOffsetSliderChanged {
    float value = _lfoOffsetSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOOffset withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFilterLFOOffsetFieldWithValue:value];
}


- (void)rampTimeSliderChanged {
    int value = (int)_rampTimeSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_RampTime_ms withValue:(float)value atSourceIdx:_sourceIdx inTime:0.0f];
    [self updateRampTimeFieldWithValue:value];
}


- (void)fmAmountSliderChanged {
    float value = _fmAmountSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FMAmount withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    [self updateFMAmountFieldWithValue:value];
}

- (void)fmFreqSliderChanged {
    float value = _fmFreqSlider.value;
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FMFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
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

- (void)updateSoftClipFieldWithValue:(float)value {
    [_softClipField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateTremFreqFieldWithValue:(float)value {
    [_tremoloFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateTremDepthFieldWithValue:(float)value {
    [_tremoloDepthField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateShapeTremFreqFieldWithValue:(float)value {
    [_shapeTremoloFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateShapeTremDepthFieldWithValue:(float)value {
    [_shapeTremoloDepthField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)updateShapeTremShapeFieldWithValue:(float)value {
    [_shapeTremoloShapeField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
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
    
    NSArray* paramSliderKeys = [_paramSliders allKeys];
    
    for (NSNumber* parameter in paramSliderKeys) {
        
        TWOscParamID paramID = (TWOscParamID)[parameter intValue];
        TWParamSliderScale scale = (TWParamSliderScale)[_paramSliderScales objectForKey:@(paramID)];
        
        float value = [[TWAudioController sharedController] getOscParameter:paramID atSourceIdx:_sourceIdx];
        
        UISlider* slider = [_paramSliders objectForKey:@(paramID)];
        
        switch (scale) {
            case TWParamSliderScale_Linear:
                [slider setValue:value animated:YES];
                break;
                
            case TWParamSliderScale_Log:
            {
                float min = [[_paramRanges objectForKey:@(paramID)][TWParamRange_Min] floatValue];
                float max = [[_paramRanges objectForKey:@(paramID)][TWParamRange_Max] floatValue];
                [slider setValue:[TWUtils linearScaleFromLog:value inMin:min inMax:max] animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
    float baseFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBaseFrequency atSourceIdx:_sourceIdx];
    [self updateBaseFrequencyUIWithValue:baseFreq];
    
    float beatFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBeatFrequency atSourceIdx:_sourceIdx];
    [self updateBeatFrequencyUIWithValue:beatFreq];
    
    float mononess = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscMononess atSourceIdx:_sourceIdx];
    [_mononessSlider setValue:mononess animated:animated];
    [self updateMononessFieldWithValue:mononess];
    
    float softClip = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscSoftClipp atSourceIdx:_sourceIdx];
    [_softClipSlider setValue:softClip animated:animated];
    [self updateSoftClipFieldWithValue:softClip];
    
    
    [self updateWaveformFromComponent];
    
    
    float tremFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloFrequency atSourceIdx:_sourceIdx];
    [_tremoloFreqSlider setValue:tremFreq animated:animated];
    [self updateTremFreqFieldWithValue:tremFreq];
    
    float tremDepth = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloDepth atSourceIdx:_sourceIdx];
    [_tremoloDepthSlider setValue:tremDepth animated:animated];
    [self updateTremDepthFieldWithValue:tremDepth];
    
    
    
    float Fc = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterCutoff atSourceIdx:_sourceIdx];
    [self setCutoffFrequencySlider:Fc];
    [self updateFilterCutoffFieldWithValue:Fc];
    
    
    [_filterSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterType atSourceIdx:_sourceIdx]];
    [_filterEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterEnable atSourceIdx:_sourceIdx]];
    [_lfoEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOEnable atSourceIdx:_sourceIdx]];
    
    
    float gain = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterGain atSourceIdx:_sourceIdx];
    [_filterGainSlider setValue:gain animated:YES];
    [self updateFilterGainFieldWithValue:gain];
    
    float res = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterResonance atSourceIdx:_sourceIdx];
    [self setResonanceSlider:res];
    [self updateFilterResonanceFieldWithValue:res];
    
    float range = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFORange atSourceIdx:_sourceIdx];
    [self setFilterLFORangeSlider:range];
    [self updateFilterLFORangeFieldWithValue:range];
    
    float lfoFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOFrequency atSourceIdx:_sourceIdx];
    [_lfoFreqSlider setValue:lfoFreq animated:animated];
    [self updateFilterLFOFrequencyFieldWithValue:lfoFreq];
    
    float lfoOffset = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOOffset atSourceIdx:_sourceIdx];
    [_lfoOffsetSlider setValue:lfoOffset animated:animated];
    [self updateFilterLFOOffsetFieldWithValue:lfoOffset];
    
    int rampTime_ms = (int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:_sourceIdx];
    [self updateRampTimeValueUIWithValue:rampTime_ms];
    
    float fmAmount = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FMAmount atSourceIdx:_sourceIdx];
    [_fmAmountSlider setValue:fmAmount animated:animated];
    [self updateFMAmountFieldWithValue:fmAmount];
    
    float fmFrequency = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FMFrequency atSourceIdx:_sourceIdx];
    [_fmFreqSlider setValue:fmFrequency animated:animated];
    [self updateFMFrequencyFieldWithValue:fmFrequency];
}


- (void)updateWaveformFromComponent {
    switch ([_componentWaveformSelector selectedSegmentIndex]) {
        case 0:
            [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_OscWaveform atSourceIdx:_sourceIdx]];
            break;
        case 1:
            [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloWaveform atSourceIdx:_sourceIdx]];
            break;
        case 2:
            [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOWaveform atSourceIdx:_sourceIdx]];
            break;
        case 3:
            [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FMWaveform atSourceIdx:_sourceIdx]];
            break;
        default:
            break;
    }
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
    
    TWOscParamID paramID = (TWOscParamID)responder.tag;
    float value = [inValue floatValue];
    [[TWAudioController sharedController] setOscParameter:paramID withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    
    UISlider* slider = (UISlider*)[_paramSliders objectForKey:@(paramID)];
    [slider setValue:value];
    
    UIButton* field = (UIButton*)[_paramFields objectForKey:@(paramID)];
    [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
    
    
    /*
    
    if (responder == _baseFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBaseFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateBaseFreqFieldWithValue:value];
        [self setOscBaseFrequencySlider:value];
    }
    
    else if (responder == _beatFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBeatFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateBeatFreqFieldWithValue:value];
        [_beatFreqSlider setValue:value animated:YES];
    }
    
    else if (responder == _mononessField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscMononess withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateMononessFieldWithValue:value];
        [_mononessSlider setValue:value animated:YES];
    }
    
    else if (responder == _softClipField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscSoftClipp withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateSoftClipFieldWithValue:value];
        [_softClipSlider setValue:value animated:YES];
    }
    
    else if (responder == _tremoloFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateTremFreqFieldWithValue:value];
        [_tremoloFreqSlider setValue:value animated:YES];
    }
    
    else if (responder == _tremoloDepthField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloDepth withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateTremDepthFieldWithValue:value];
        [_tremoloDepthSlider setValue:value animated:YES];
    }
    
    else if (responder == _cutoffFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterCutoff withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterCutoffFieldWithValue:value];
        [self setCutoffFrequencySlider:value];
    }
    
    else if (responder == _resonanceField) {
        float value = [inValue floatValue];
        if (value <= kResonanceMin) {
            value = kResonanceMin;
        }
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterResonance withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterResonanceFieldWithValue:value];
        [self setResonanceSlider:value];
    }
    
    else if (responder == _filterGainField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterGain withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterGainFieldWithValue:value];
        [_filterGainSlider setValue:value animated:YES];
    }
    
    else if (responder == _lfoFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFOFrequencyFieldWithValue:value];
        [_lfoFreqSlider setValue:value animated:YES];
    }
    
    else if (responder == _lfoOffsetField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOOffset withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFOOffsetFieldWithValue:value];
        [_lfoOffsetSlider setValue:value animated:YES];
    }
    
    else if (responder == _lfoRangeField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFORange withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFORangeFieldWithValue:value];
        [self setFilterLFORangeSlider:value];
    }
    
    else if (responder == _rampTimeField) {
        int value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_RampTime_ms withValue:value atSourceIdx:_sourceIdx inTime:0.0f];
        [_rampTimeSlider setValue:value animated:YES];
        [self updateRampTimeFieldWithValue:value];
    }
    
    else if (responder == _fmAmountField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FMAmount withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFMAmountFieldWithValue:value];
        [_fmAmountSlider setValue:value animated:YES];
    }
    
    else if (responder == _fmFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FMFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFMFrequencyFieldWithValue:value];
        [_fmFreqSlider setValue:value animated:YES];
    }
     */
}


- (void)keypadCancelButtonTapped:(UIButton *)responder {
    
    TWOscParamID paramID = (TWOscParamID)responder.tag;
    float value = [[TWAudioController sharedController] getOscParameter:paramID atSourceIdx:_sourceIdx];
    
    UIButton* field = (UIButton*)[_paramFields objectForKey:@(paramID)];
    [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
    
    /*
    if (responder == _baseFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBaseFrequency atSourceIdx:_sourceIdx];
        [self updateBaseFreqFieldWithValue:value];
    }
    
    else if (responder == _beatFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBeatFrequency atSourceIdx:_sourceIdx];
        [self updateBeatFreqFieldWithValue:value];
    }
    
    else if (responder == _mononessField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscMononess atSourceIdx:_sourceIdx];
        [self updateMononessFieldWithValue:value];
    }
    
    else if (responder == _softClipField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscSoftClipp atSourceIdx:_sourceIdx];
        [self updateSoftClipFieldWithValue:value];
    }
    
    else if (responder == _tremoloFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloFrequency atSourceIdx:_sourceIdx];
        [self updateTremFreqFieldWithValue:value];
    }
    
    else if (responder == _tremoloDepthField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloDepth atSourceIdx:_sourceIdx];
        [self updateTremDepthFieldWithValue:value];
    }
    
    else if (responder == _cutoffFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterCutoff atSourceIdx:_sourceIdx];
        [self updateFilterCutoffFieldWithValue:value];
    }
    
    else if (responder == _resonanceField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterResonance atSourceIdx:_sourceIdx];
        [self updateFilterResonanceFieldWithValue:value];
    }
    
    else if (responder == _filterGainField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterGain atSourceIdx:_sourceIdx];
        [self updateFilterGainFieldWithValue:value];
    }
    
    else if (responder == _lfoFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOFrequency atSourceIdx:_sourceIdx];
        [self updateFilterLFOFrequencyFieldWithValue:value];
    }
    
    else if (responder == _lfoOffsetField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOOffset atSourceIdx:_sourceIdx];
        [self updateFilterLFOOffsetFieldWithValue:value];
    }
    
    else if (responder == _lfoRangeField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFORange atSourceIdx:_sourceIdx];
        [self updateFilterLFORangeFieldWithValue:value];
    }
    
    else if (responder == _rampTimeField) {
        int value = (int)(int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:_sourceIdx];
        [self updateRampTimeFieldWithValue:value];
    }
    
    else if (responder == _fmAmountField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FMAmount atSourceIdx:_sourceIdx];
        [self updateFMAmountFieldWithValue:value];
    }
    
    else if (responder == _fmFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FMFrequency atSourceIdx:_sourceIdx];
        [self updateFMFrequencyFieldWithValue:value];
    }
     */
}





- (void)baseFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Base Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBaseFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_baseFreqField];
}

- (void)beatFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Beat Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBeatFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_beatFreqField];
}

- (void)mononessFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Mononess: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscMononess atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_mononessField];
}

- (void)softClipFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Soft Clip: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscSoftClipp atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_softClipField];
}

- (void)tremFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Trem Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_tremoloFreqField];
}

- (void)tremDepthFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Trem Depth (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloDepth atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_tremoloDepthField];
}

- (void)cutoffFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter Fc (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterCutoff atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_cutoffFreqField];
}

- (void)resonanceFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Resonance (Q): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterResonance atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_resonanceField];
}

- (void)filterGainFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter Gain: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterGain atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_filterGainField];
}

- (void)lfoFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_lfoFreqField];
}

- (void)lfoRangeFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Range (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFORange atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_lfoRangeField];
}

- (void)lfoOffsetFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Offset (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOOffset atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_lfoOffsetField];
}

- (void)rampTimeFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] Ramp Time (ms): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%d", (int)(int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_rampTimeField];
}

- (void)fmAmountFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] FM Amount: ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FMAmount atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_fmAmountField];
}

- (void)fmFreqFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"[%d] FM Freq (Hz): ", _sourceIdx]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FMFrequency atSourceIdx:_sourceIdx]]];
    [keypad setCurrentResponder:_fmFreqField];
}



    
@end

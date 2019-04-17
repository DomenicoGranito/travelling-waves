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
#import "TWMasterController.h"
#import "TWKeypad.h"
#import "TWUtils.h"
#import "TWMixerView.h"
#import "UIColor+Additions.h"


@interface TWOscView() <TWKeypadDelegate, UIGestureRecognizerDelegate>
{
    
    UISegmentedControl*         _sourceIdxSelector;
    
    // Copy Paste View
    UIView*                     _editActionView;
    UILabel*                    _editSourceLabel;
    UIButton*                   _copyButton;
    UIButton*                   _pasteButton;
    UIButton*                   _cancelButton;
    int                         _editActionSourceIdx;
//    CGRect                      _editActionRect;
    
    
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
    UIView*                     _tremoloBackView;
    
    UILabel*                    _tremoloRateLabel;
    UISlider*                   _tremoloRateSlider;
    UIButton*                   _tremoloRateField;
    
    UILabel*                    _tremoloDepthLabel;
    UISlider*                   _tremoloDepthSlider;
    UIButton*                   _tremoloDepthField;
    
    
    // Shape Tremolo
    UILabel*                    _shapeTremoloRateLabel;
    UISlider*                   _shapeTremoloRateSlider;
    UIButton*                   _shapeTremoloRateField;
    
    UILabel*                    _shapeTremDepthLabel;
    UISlider*                   _shapeTremoloDepthSlider;
    UIButton*                   _shapeTremoloDepthField;
    
    UILabel*                    _shapeTremShapeLabel;
    UISlider*                   _shapeTremoloShapeSlider;
    UIButton*                   _shapeTremoloShapeField;
    
    
    
    // Filter
    UIView*                     _filterBackView;
    
    UISegmentedControl*         _filterSelector;
    
    UILabel*                    _filterCutoffFreqLabel;
    UISlider*                   _filterCutoffFreqSlider;
    UIButton*                   _filterCutoffFreqField;
    
    UISwitch*                   _filterEnableSwitch;
    UISwitch*                   _filterLFOEnableSwitch;
    
    UILabel*                    _filterResonanceLabel;
    UISlider*                   _filterResonanceSlider;
    UIButton*                   _filterResonanceField;
    
    UILabel*                    _filterGainLabel;
    UISlider*                   _filterGainSlider;
    UIButton*                   _filterGainField;
    
    UILabel*                    _filterLFOLabel;
    UISlider*                   _filterLFORateSlider;
    UIButton*                   _filterLFORateField;
    
    UILabel*                    _filterLFORangeLabel;
    UISlider*                   _filterLFORangeSlider;
    UIButton*                   _filterLFORangeField;
    
    UILabel*                    _filterLFOOffsetLabel;
    UISlider*                   _filterLFOOffsetSlider;
    UIButton*                   _filterLFOOffsetField;
    
    
    // General
    UILabel*                    _rampTimeLabel;
    UISlider*                   _rampTimeSlider;
    UIButton*                   _rampTimeField;
    
    
    // FM
    UILabel*                    _oscFMAmountLabel;
    UISlider*                   _oscFMAmountSlider;
    UIButton*                   _oscFMAmountField;
    
    UILabel*                    _oscFMFreqLabel;
    UISlider*                   _oscFMFreqSlider;
    UIButton*                   _oscFMFreqField;
    
    UIView*                     _oscFMBackView;
    
    
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
    _sourceIdxSelector = [[UISegmentedControl alloc] initWithItems:segments];
    [_sourceIdxSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_sourceIdxSelector setSelectedSegmentIndex:0];
    [_sourceIdxSelector setTintColor:[UIColor segmentedControlTintColor]];
    [_sourceIdxSelector addTarget:self action:@selector(sourceIdxSelectorChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_sourceIdxSelector];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceIdxDoubleTap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:2];
    [_sourceIdxSelector addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer setDelegate:self];
    
    
    _editActionView = [[UIView alloc] init];
    [_editActionView setBackgroundColor:[UIColor colorWithWhite:0.26f alpha:1.0f]];
    [self addSubview:_editActionView];
    
    _editSourceLabel = [[UILabel alloc] init];
    [_editSourceLabel setText:@"[x] : "];
    [_editSourceLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_editSourceLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_editSourceLabel setTextAlignment:NSTextAlignmentCenter];
    [_editSourceLabel setBackgroundColor:[UIColor copyButtonColor]];
    [_editActionView addSubview:_editSourceLabel];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_cancelButton setBackgroundColor:[UIColor cancelButtonColor]];
    [_cancelButton addTarget:self action:@selector(cancelButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_cancelButton addTarget:self action:@selector(cancelButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [_editActionView addSubview:_cancelButton];
    
    _copyButton = [[UIButton alloc] init];
    [_copyButton setTitle:@"Copy" forState:UIControlStateNormal];
    [_copyButton setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [_copyButton.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_copyButton setBackgroundColor:[UIColor copyButtonColor]];
    [_copyButton addTarget:self action:@selector(copyButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_copyButton addTarget:self action:@selector(copyButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [_editActionView addSubview:_copyButton];
    
    _pasteButton = [[UIButton alloc] init];
    [_pasteButton setTitle:@"Paste" forState:UIControlStateNormal];
    [_pasteButton setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [_pasteButton.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_pasteButton setBackgroundColor:[UIColor pasteButtonColor]];
    [_pasteButton addTarget:self action:@selector(pasteButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_pasteButton addTarget:self action:@selector(pasteButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [_pasteButton setAlpha:0.1f];
    [_pasteButton setUserInteractionEnabled:NO];
    [_editActionView addSubview:_pasteButton];
    
    
    
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
    [_baseFreqSlider setTag:TWOscParamID_OscBaseFrequency];
    [_baseFreqSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_baseFreqSlider forKey:@(TWOscParamID_OscBaseFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_OscBaseFrequency)];
    [paramRanges setObject:@[@(kFrequencyMin), @(kFrequencyMax)] forKey:@(TWOscParamID_OscBaseFrequency)];
    [self addSubview:_baseFreqSlider];
    
    _baseFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_baseFreqField];
    [_baseFreqField setTag:TWOscParamID_OscBaseFrequency];
    [_baseFreqField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_baseFreqField forKey:@(TWOscParamID_OscBaseFrequency)];
    [self addSubview:_baseFreqField];
    
    
    _beatFreqSlider = [[UISlider alloc] init];
    [_beatFreqSlider setMinimumValue:0.0f];
    [_beatFreqSlider setMaximumValue:32.0f];
    [_beatFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_beatFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_beatFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_beatFreqSlider setTag:TWOscParamID_OscBeatFrequency];
    [_beatFreqSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_beatFreqSlider forKey:@(TWOscParamID_OscBeatFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscBeatFrequency)];
    [self addSubview:_beatFreqSlider];
    
    [paramLongTitles setObject:@"Beat Freq (Hz)" forKey:@(TWOscParamID_OscBeatFrequency)];
    
    _beatFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_beatFreqField];
    [_beatFreqField setTag:TWOscParamID_OscBeatFrequency];
    [_beatFreqField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    [_mononessSlider setTag:TWOscParamID_OscMononess];
    [_mononessSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_mononessSlider forKey:@(TWOscParamID_OscMononess)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscMononess)];
    [self addSubview:_mononessSlider];
    
    _mononessField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_mononessField];
    [_mononessField setTag:TWOscParamID_OscMononess];
    [_mononessField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    [_softClipSlider setTag:TWOscParamID_OscSoftClipp];
    [_softClipSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_softClipSlider forKey:@(TWOscParamID_OscSoftClipp)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscSoftClipp)];
    [self addSubview:_softClipSlider];
    
    _softClipField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_softClipField];
    [_softClipField setTag:TWOscParamID_OscSoftClipp];
    [_softClipField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_softClipField forKey:@(TWOscParamID_OscSoftClipp)];
    [self addSubview:_softClipField];

    
    
    
    
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    _waveformSelector = [[UISegmentedControl alloc] initWithItems:@[@"Sine", @"Saw", @"Square", @"Noise", @"Random"]];
    [_waveformSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_waveformSelector setTintColor:[UIColor sliderOnColor]];
    [_waveformSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_waveformSelector setTag:TWOscParamID_OscWaveform];
    [_waveformSelector addTarget:self action:@selector(waveformChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_waveformSelector];
    
    _componentWaveformSelector = [[UISegmentedControl alloc] initWithItems:@[@"Osc", @"Tremolo", @"Filter LFO", @"FM"]];
    [_componentWaveformSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_componentWaveformSelector setTintColor:[UIColor sliderOnColor]];
    [_componentWaveformSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_componentWaveformSelector setSelectedSegmentIndex:0];
    [_componentWaveformSelector addTarget:self action:@selector(waveformComponentChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_componentWaveformSelector];
    
    
    
    // Tremolo
    
    _tremoloBackView = [[UIView alloc] init];
    [_tremoloBackView setUserInteractionEnabled:NO];
    [_tremoloBackView setBackgroundColor:[UIColor colorWithWhite:0.06f alpha:0.3f]];
    [self addSubview:_tremoloBackView];
    
    _tremoloRateLabel = [[UILabel alloc] init];
    [_tremoloRateLabel setText:@"TrRt:"];
    [self setupLabelProperties:_tremoloRateLabel];
    [self addSubview:_tremoloRateLabel];
    
    [paramLongTitles setObject:@"Trem Rate (Hz)" forKey:@(TWOscParamID_TremoloFrequency)];
    
    _tremoloRateSlider = [[UISlider alloc] init];
    [_tremoloRateSlider setMinimumValue:kLFORateMin];
    [_tremoloRateSlider setMaximumValue:kLFORateMax];
    [_tremoloRateSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tremoloRateSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tremoloRateSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tremoloRateSlider setTag:TWOscParamID_TremoloFrequency];
    [_tremoloRateSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_tremoloRateSlider forKey:@(TWOscParamID_TremoloFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_TremoloFrequency)];
    [self addSubview:_tremoloRateSlider];
    
    _tremoloRateField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_tremoloRateField];
    [_tremoloRateField setTag:TWOscParamID_TremoloFrequency];
    [_tremoloRateField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_tremoloRateField forKey:@(TWOscParamID_TremoloFrequency)];
    [self addSubview:_tremoloRateField];
    
    
    _tremoloDepthLabel = [[UILabel alloc] init];
    [_tremoloDepthLabel setText:@"TrDp:"];
    [self setupLabelProperties:_tremoloDepthLabel];
    [self addSubview:_tremoloDepthLabel];
    
    [paramLongTitles setObject:@"Trem Depth" forKey:@(TWOscParamID_TremoloDepth)];
    
    _tremoloDepthSlider = [[UISlider alloc] init];
    [_tremoloDepthSlider setMinimumValue:0.0f];
    [_tremoloDepthSlider setMaximumValue:1.0f];
    [_tremoloDepthSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_tremoloDepthSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_tremoloDepthSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_tremoloDepthSlider setTag:TWOscParamID_TremoloDepth];
    [_tremoloDepthSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_tremoloDepthSlider forKey:@(TWOscParamID_TremoloDepth)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_TremoloDepth)];
    [self addSubview:_tremoloDepthSlider];
    
    _tremoloDepthField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_tremoloDepthField];
    [_tremoloDepthField setTag:TWOscParamID_TremoloDepth];
    [_tremoloDepthField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_tremoloDepthField forKey:@(TWOscParamID_TremoloDepth)];
    [self addSubview:_tremoloDepthField];
    
    
    
    // Shape Tremolo
    
    _shapeTremoloRateLabel = [[UILabel alloc] init];
    [_shapeTremoloRateLabel setText:@"STRt:"];
    [self setupLabelProperties:_shapeTremoloRateLabel];
    [self addSubview:_shapeTremoloRateLabel];
    
    [paramLongTitles setObject:@"Shape Trem Rate (Hz)" forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    
    _shapeTremoloRateSlider = [[UISlider alloc] init];
    [_shapeTremoloRateSlider setMinimumValue:kLFORateMin];
    [_shapeTremoloRateSlider setMaximumValue:kLFORateMax];
    [_shapeTremoloRateSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloRateSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_shapeTremoloRateSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_shapeTremoloRateSlider setTag:TWOscParamID_ShapeTremoloFrequency];
    [_shapeTremoloRateSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_shapeTremoloRateSlider forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    [self addSubview:_shapeTremoloRateSlider];
    
    _shapeTremoloRateField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_shapeTremoloRateField];
    [_shapeTremoloRateField setTag:TWOscParamID_ShapeTremoloFrequency];
    [_shapeTremoloRateField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_shapeTremoloRateField forKey:@(TWOscParamID_ShapeTremoloFrequency)];
    [self addSubview:_shapeTremoloRateField];
    
    
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
    [_shapeTremoloDepthSlider setTag:TWOscParamID_ShapeTremoloDepth];
    [_shapeTremoloDepthSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_shapeTremoloDepthSlider forKey:@(TWOscParamID_ShapeTremoloDepth)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_ShapeTremoloDepth)];
    [self addSubview:_shapeTremoloDepthSlider];
    
    _shapeTremoloDepthField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_shapeTremoloDepthField];
    [_shapeTremoloDepthField setTag:TWOscParamID_ShapeTremoloDepth];
    [_shapeTremoloDepthField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    [_shapeTremoloShapeSlider setTag:TWOscParamID_ShapeTremoloSoftClipp];
    [_shapeTremoloShapeSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_shapeTremoloShapeSlider forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    [self addSubview:_shapeTremoloShapeSlider];
    
    _shapeTremoloShapeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_shapeTremoloShapeField];
    [_shapeTremoloShapeField setTag:TWOscParamID_ShapeTremoloSoftClipp];
    [_shapeTremoloShapeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_shapeTremoloShapeField forKey:@(TWOscParamID_ShapeTremoloSoftClipp)];
    [self addSubview:_shapeTremoloShapeField];
    
    
    
    
    // Filter
    
    _filterBackView = [[UIView alloc] init];
    [_filterBackView setUserInteractionEnabled:NO];
    [_filterBackView setBackgroundColor:[UIColor colorWithWhite:0.15f alpha:0.2f]];
    [self addSubview:_filterBackView];
    
    _filterCutoffFreqLabel = [[UILabel alloc] init];
    [_filterCutoffFreqLabel setText:@"Fc:"];
    [self setupLabelProperties:_filterCutoffFreqLabel];
    [self addSubview:_filterCutoffFreqLabel];
    
    [paramLongTitles setObject:@"Filter Fc (Hz)" forKey:@(TWOscParamID_FilterCutoff)];
    
    _filterCutoffFreqSlider = [[UISlider alloc] init];
    [_filterCutoffFreqSlider setMinimumValue:0.0f];
    [_filterCutoffFreqSlider setMaximumValue:1.0f];
    [_filterCutoffFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterCutoffFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterCutoffFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterCutoffFreqSlider setTag:TWOscParamID_FilterCutoff];
    [_filterCutoffFreqSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_filterCutoffFreqSlider forKey:@(TWOscParamID_FilterCutoff)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_FilterCutoff)];
    [paramRanges setObject:@[@(kFrequencyMin), @(kFrequencyMax)] forKey:@(TWOscParamID_FilterCutoff)];
    [self addSubview:_filterCutoffFreqSlider];
    
    _filterCutoffFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterCutoffFreqField];
    [_filterCutoffFreqField setTag:TWOscParamID_FilterCutoff];
    [_filterCutoffFreqField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_filterCutoffFreqField forKey:@(TWOscParamID_FilterCutoff)];
    [self addSubview:_filterCutoffFreqField];
    
    
    _filterSelector = [[UISegmentedControl alloc] initWithItems:@[@"LPF", @"HPF", @"BPF1", @"BPF2", @"Ntch"]];
    [_filterSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_filterSelector setTintColor:[UIColor sliderOnColor]];
    [_filterSelector setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_filterSelector setTag:TWOscParamID_FilterType];
    [_filterSelector addTarget:self action:@selector(filterTypeChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterSelector];
    
    _filterEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_filterEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch setTag:TWOscParamID_FilterEnable];
    [_filterEnableSwitch addTarget:self action:@selector(filterEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterEnableSwitch];
    
    _filterLFOEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterLFOEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_filterLFOEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_filterLFOEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_filterLFOEnableSwitch setTag:TWOscParamID_FilterLFOEnable];
    [_filterLFOEnableSwitch addTarget:self action:@selector(lfoEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_filterLFOEnableSwitch];
    
    
    _filterResonanceLabel = [[UILabel alloc] init];
    [_filterResonanceLabel setText:@"Q:"];
    [self setupLabelProperties:_filterResonanceLabel];
    [self addSubview:_filterResonanceLabel];
    
    [paramLongTitles setObject:@"Resonance (Q)" forKey:@(TWOscParamID_FilterResonance)];
    
    _filterResonanceSlider = [[UISlider alloc] init];
    [_filterResonanceSlider setMinimumValue:0.0f];
    [_filterResonanceSlider setMaximumValue:1.0f];
    [_filterResonanceSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterResonanceSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterResonanceSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterResonanceSlider setTag:TWOscParamID_FilterResonance];
    [_filterResonanceSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_filterResonanceSlider forKey:@(TWOscParamID_FilterResonance)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_FilterResonance)];
    [paramRanges setObject:@[@(kResonanceMin), @(kResonanceMax)] forKey:@(TWOscParamID_FilterResonance)];
    [self addSubview:_filterResonanceSlider];
    
    _filterResonanceField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterResonanceField];
    [_filterResonanceField setTag:TWOscParamID_FilterResonance];
    [_filterResonanceField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_filterResonanceField forKey:@(TWOscParamID_FilterResonance)];
    [self addSubview:_filterResonanceField];
    
    
    _filterGainLabel = [[UILabel alloc] init];
    [_filterGainLabel setText:@"G:"];
    [self setupLabelProperties:_filterGainLabel];
    [self addSubview:_filterGainLabel];
    
    [paramLongTitles setObject:@"Filter Gain" forKey:@(TWOscParamID_FilterGain)];
    
    _filterGainSlider = [[UISlider alloc] init];
    [_filterGainSlider setMinimumValue:1.0f];
    [_filterGainSlider setMaximumValue:6.0f];
    [_filterGainSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterGainSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterGainSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterGainSlider setTag:TWOscParamID_FilterGain];
    [_filterGainSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_filterGainSlider forKey:@(TWOscParamID_FilterGain)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FilterGain)];
    [self addSubview:_filterGainSlider];
    
    _filterGainField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterGainField];
    [_filterGainField setTag:TWOscParamID_FilterGain];
    [_filterGainField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_filterGainField forKey:@(TWOscParamID_FilterGain)];
    [self addSubview:_filterGainField];
    
    
    
    _filterLFOLabel = [[UILabel alloc] init];
    [_filterLFOLabel setText:@"LFrt:"];
    [self setupLabelProperties:_filterLFOLabel];
    [self addSubview:_filterLFOLabel];
    
    [paramLongTitles setObject:@"Filter LFO Freq (Hz)" forKey:@(TWOscParamID_FilterLFOFrequency)];
    
    _filterLFORateSlider = [[UISlider alloc] init];
    [_filterLFORateSlider setMinimumValue:kLFORateMin];
    [_filterLFORateSlider setMaximumValue:kLFORateMax];
    [_filterLFORateSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterLFORateSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterLFORateSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterLFORateSlider setTag:TWOscParamID_FilterLFOFrequency];
    [_filterLFORateSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_filterLFORateSlider forKey:@(TWOscParamID_FilterLFOFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FilterLFOFrequency)];
    [self addSubview:_filterLFORateSlider];
    
    _filterLFORateField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterLFORateField];
    [_filterLFORateField setTag:TWOscParamID_FilterLFOFrequency];
    [_filterLFORateField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_filterLFORateField forKey:@(TWOscParamID_FilterLFOFrequency)];
    [self addSubview:_filterLFORateField];
    
    
    _filterLFORangeLabel = [[UILabel alloc] init];
    [_filterLFORangeLabel setText:@"Rnge:"];
    [self setupLabelProperties:_filterLFORangeLabel];
    [self addSubview:_filterLFORangeLabel];
    
    [paramLongTitles setObject:@"Filter LFO Range (Hz)" forKey:@(TWOscParamID_FilterLFORange)];
    
    _filterLFORangeSlider = [[UISlider alloc] init];
    [_filterLFORangeSlider setMinimumValue:0.0f];
    [_filterLFORangeSlider setMaximumValue:1.0f];
    [_filterLFORangeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterLFORangeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterLFORangeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterLFORangeSlider setTag:TWOscParamID_FilterLFORange];
    [_filterLFORangeSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_filterLFORangeSlider forKey:@(TWOscParamID_FilterLFORange)];
    [paramSliderScales setObject:@(TWParamSliderScale_Log) forKey:@(TWOscParamID_FilterLFORange)];
    [paramRanges setObject:@[@(kFrequencyMin), @(kFrequencyMax)] forKey:@(TWOscParamID_FilterLFORange)];
    [self addSubview:_filterLFORangeSlider];
    
    _filterLFORangeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterLFORangeField];
    [_filterLFORangeField setTag:TWOscParamID_FilterLFORange];
    [_filterLFORangeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_filterLFORangeField forKey:@(TWOscParamID_FilterLFORange)];
    [self addSubview:_filterLFORangeField];
    
    
    _filterLFOOffsetLabel = [[UILabel alloc] init];
    [_filterLFOOffsetLabel setText:@"Ofst:"];
    [self setupLabelProperties:_filterLFOOffsetLabel];
    [self addSubview:_filterLFOOffsetLabel];
    
    [paramLongTitles setObject:@"Filter LFO Offset" forKey:@(TWOscParamID_FilterLFOOffset)];
    
    _filterLFOOffsetSlider = [[UISlider alloc] init];
    [_filterLFOOffsetSlider setMinimumValue:0.0f];
    [_filterLFOOffsetSlider setMaximumValue:2.0f * M_PI];
    [_filterLFOOffsetSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterLFOOffsetSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterLFOOffsetSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterLFOOffsetSlider setTag:TWOscParamID_FilterLFOOffset];
    [_filterLFOOffsetSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_filterLFOOffsetSlider forKey:@(TWOscParamID_FilterLFOOffset)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_FilterLFOOffset)];
    [self addSubview:_filterLFOOffsetSlider];
    
    _filterLFOOffsetField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterLFOOffsetField];
    [_filterLFOOffsetField setTag:TWOscParamID_FilterLFOOffset];
    [_filterLFOOffsetField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_filterLFOOffsetField forKey:@(TWOscParamID_FilterLFOOffset)];
    [self addSubview:_filterLFOOffsetField];
    
    
    
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
    [_rampTimeSlider setTag:TWOscParamID_RampTime_ms];
    [_rampTimeSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_rampTimeSlider forKey:@(TWOscParamID_RampTime_ms)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_RampTime_ms)];
    [self addSubview:_rampTimeSlider];
    
    _rampTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_rampTimeField];
    [_rampTimeField setTag:TWOscParamID_RampTime_ms];
    [_rampTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_rampTimeField forKey:@(TWOscParamID_RampTime_ms)];
    [self addSubview:_rampTimeField];
    
    
    
    // FM
    
    _oscFMBackView = [[UIView alloc] init];
    [_oscFMBackView setUserInteractionEnabled:NO];
    [_oscFMBackView setBackgroundColor:[UIColor colorWithWhite:0.06f alpha:0.3f]];
    [self addSubview:_oscFMBackView];
    
    
    _oscFMAmountLabel = [[UILabel alloc] init];
    [_oscFMAmountLabel setText:@"FM-G:"];
    [self setupLabelProperties:_oscFMAmountLabel];
    [self addSubview:_oscFMAmountLabel];
    
    [paramLongTitles setObject:@"FM Amount" forKey:@(TWOscParamID_OscFMAmount)];
    
    _oscFMAmountSlider = [[UISlider alloc] init];
    [_oscFMAmountSlider setMinimumValue:0.0f];
    [_oscFMAmountSlider setMaximumValue:1.0f];
    [_oscFMAmountSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_oscFMAmountSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_oscFMAmountSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_oscFMAmountSlider setTag:TWOscParamID_OscFMAmount];
    [_oscFMAmountSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_oscFMAmountSlider forKey:@(TWOscParamID_OscFMAmount)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscFMAmount)];
    [self addSubview:_oscFMAmountSlider];
    
    _oscFMAmountField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_oscFMAmountField];
    [_oscFMAmountField setTag:TWOscParamID_OscFMAmount];
    [_oscFMAmountField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_oscFMAmountField forKey:@(TWOscParamID_OscFMAmount)];
    [self addSubview:_oscFMAmountField];
    
    
    _oscFMFreqLabel = [[UILabel alloc] init];
    [_oscFMFreqLabel setText:@"FM-F:"];
    [self setupLabelProperties:_oscFMFreqLabel];
    [self addSubview:_oscFMFreqLabel];
    
    [paramLongTitles setObject:@"FM Freq" forKey:@(TWOscParamID_OscFMFrequency)];
    
    _oscFMFreqSlider = [[UISlider alloc] init];
    [_oscFMFreqSlider setMinimumValue:0.001f];
    [_oscFMFreqSlider setMaximumValue:200.0f];
    [_oscFMFreqSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_oscFMFreqSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_oscFMFreqSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_oscFMFreqSlider setTag:TWOscParamID_OscFMFrequency];
    [_oscFMFreqSlider addTarget:self action:@selector(paramSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [paramSliders setObject:_oscFMFreqSlider forKey:@(TWOscParamID_OscFMFrequency)];
    [paramSliderScales setObject:@(TWParamSliderScale_Linear) forKey:@(TWOscParamID_OscFMFrequency)];
    [self addSubview:_oscFMFreqSlider];
    
    _oscFMFreqField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_oscFMFreqField];
    [_oscFMFreqField setTag:TWOscParamID_OscFMFrequency];
    [_oscFMFreqField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [paramFields setObject:_oscFMFreqField forKey:@(TWOscParamID_OscFMFrequency)];
    [self addSubview:_oscFMFreqField];
    
    
    _paramSliders = [[NSDictionary alloc] initWithDictionary:paramSliders];
    _paramFields = [[NSDictionary alloc] initWithDictionary:paramFields];
    _paramLongTitles = [[NSDictionary alloc] initWithDictionary:paramLongTitles];
    _paramSliderScales = [[NSDictionary alloc] initWithDictionary:paramSliderScales];
    _paramRanges = [[NSDictionary alloc] initWithDictionary:paramRanges];
    
    
    [self bringSubviewToFront:_editActionView];
    [_editActionView setAlpha:0.0f];
//    [[TWKeypad sharedKeypad] addToDelegates:self];
    
    _sourceIdx = 0;
    _editActionSourceIdx = 0;
    
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
    
    
    [_sourceIdxSelector setFrame:CGRectMake(xPos, yPos, frame.size.width, componentHeight)];
    
    
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
    
    [_tremoloBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 2.0f * componentHeight)];
    
    [_tremoloRateLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _tremoloRateLabel.frame.size.width;
    [_tremoloRateSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _tremoloRateSlider.frame.size.width;
    [_tremoloRateField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _tremoloRateField.frame.size.width;
    [_tremoloDepthLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _tremoloDepthLabel.frame.size.width;
    [_tremoloDepthSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _tremoloDepthSlider.frame.size.width;
    [_tremoloDepthField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    // Shape Tremolo
    
    yPos += componentHeight;
    xPos = 0.0f;
    
    sliderWidth = (frame.size.width - (3.0f * (kTitleLabelWidth + kValueLabelWidth))) / 3.0f;
    
    [_shapeTremoloRateLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _shapeTremoloRateLabel.frame.size.width;
    [_shapeTremoloRateSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _shapeTremoloRateSlider.frame.size.width;
    [_shapeTremoloRateField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    xPos += _shapeTremoloRateField.frame.size.width;
    [_shapeTremDepthLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _shapeTremDepthLabel.frame.size.width;
    [_shapeTremoloDepthSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _shapeTremoloDepthSlider.frame.size.width;
    [_shapeTremoloDepthField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _shapeTremoloDepthField.frame.size.width;
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
    [_filterLFOEnableSwitch setFrame:CGRectMake(xPos, yPos + ((componentHeight - _filterEnableSwitch.frame.size.height) / 2.0f), 0.0f, 0.0f)];
    
    xPos += _filterLFOEnableSwitch.frame.size.width;
    [_filterSelector setFrame:CGRectMake(xPos, yPos + 5.0f, frame.size.width - xPos, componentHeight - 10.0f)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_filterCutoffFreqLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    sliderWidth = frame.size.width - kValueLabelWidth - kTitleLabelWidth;
    xPos += _filterCutoffFreqLabel.frame.size.width;
    [_filterCutoffFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterCutoffFreqSlider.frame.size.width;
    [_filterCutoffFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_filterResonanceLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _filterResonanceLabel.frame.size.width;
    sliderWidth = (frame.size.width - (2.0f * (kTitleLabelWidth + kValueLabelWidth))) / 2.0f;
    [_filterResonanceSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterResonanceSlider.frame.size.width;
    [_filterResonanceField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _filterResonanceField.frame.size.width;
    [_filterGainLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _filterResonanceLabel.frame.size.width;
    [_filterGainSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterGainSlider.frame.size.width;
    [_filterGainField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    sliderWidth = (frame.size.width - (2.0f * (kValueLabelWidth + kTitleLabelWidth))) / 2.0f;
    
    [_filterLFOLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _filterLFOLabel.frame.size.width;
    [_filterLFORateSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterLFORateSlider.frame.size.width;
    [_filterLFORateField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _filterLFORateField.frame.size.width;
    [_filterLFORangeLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _filterLFORangeLabel.frame.size.width;
    [_filterLFORangeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterLFORangeSlider.frame.size.width;
    [_filterLFORangeField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_filterLFOOffsetLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _filterLFOOffsetLabel.frame.size.width;
    [_filterLFOOffsetSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _filterLFOOffsetSlider.frame.size.width;
    [_filterLFOOffsetField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _filterLFOOffsetField.frame.size.width;
    [_rampTimeLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _filterLFORangeLabel.frame.size.width;
    [_rampTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _rampTimeSlider.frame.size.width;
    [_rampTimeField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    // FM
    yPos += componentHeight;
    xPos = 0.0f;
    [_oscFMBackView setFrame:CGRectMake(xPos, yPos, frame.size.width, 1.0f * componentHeight)];
    [_oscFMAmountLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _oscFMAmountLabel.frame.size.width;
    [_oscFMAmountSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _oscFMAmountSlider.frame.size.width;
    [_oscFMAmountField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    xPos += _oscFMAmountField.frame.size.width;
    [_oscFMFreqLabel setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth, componentHeight)];
    
    xPos += _oscFMFreqLabel.frame.size.width;
    [_oscFMFreqSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    
    xPos += _oscFMFreqSlider.frame.size.width;
    [_oscFMFreqField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    
    
    
    CGFloat editActionViewWidth = sliderWidth;
    CGFloat editActionViewHeight = componentHeight;
//    _editActionRect = CGRectMake((frame.size.width - editActionViewWidth) / 2.0f, componentHeight, editActionViewWidth, editActionViewHeight);
    [_editActionView setFrame:CGRectMake((frame.size.width - editActionViewWidth) / 2.0f, componentHeight, editActionViewWidth, editActionViewHeight)];
    
    CGFloat editActionMargin = 2.0f;
    xPos = editActionMargin;
    yPos = editActionMargin;
    
    CGFloat editSourceLabelWidth = 0.5f; // 50%
    // width = 5*m + 3*b + e*b
    // width = 5*m + b*(3+e)
    // b = width - 5m / (3 + e)
    CGFloat editActionButtonWidth = (editActionViewWidth - (5.0f * editActionMargin)) / (3.0f + editSourceLabelWidth);
    CGFloat editActionButtonHeight = editActionViewHeight - (2.0f * editActionMargin);
    
    [_editSourceLabel setFrame:CGRectMake(xPos, yPos, editSourceLabelWidth * editActionButtonWidth, editActionButtonHeight)];
    xPos += editActionMargin + (editSourceLabelWidth * editActionButtonWidth);
    [_cancelButton setFrame:CGRectMake(xPos, yPos, editActionButtonWidth, editActionButtonHeight)];
    xPos += editActionMargin + editActionButtonWidth;
    [_copyButton setFrame:CGRectMake(xPos, yPos, editActionButtonWidth, editActionButtonHeight)];
    xPos += editActionMargin + editActionButtonWidth;
    [_pasteButton setFrame:CGRectMake(xPos, yPos, editActionButtonWidth, editActionButtonHeight)];
}


- (void)setSourceIdx:(int)sourceIdx {
    _sourceIdx = sourceIdx;
    [_sourceIdxSelector setSelectedSegmentIndex:_sourceIdx];
    [self refreshParametersWithAnimation:YES];
}


- (void)sourceIdxSelectorChanged:(UISegmentedControl*)sender {
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
    TWParamSliderScale scale = (TWParamSliderScale)[[_paramSliderScales objectForKey:@(paramID)] intValue];
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
    
    UIButton* paramField = (UIButton*)[_paramFields objectForKey:@(paramID)];
    [self updateParamField:paramField withValue:value];
}

- (void)paramFieldTapped:(UIButton*)sender {
    TWOscParamID paramID = (TWOscParamID)sender.tag;
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    float value = [[TWAudioController sharedController] getOscParameter:paramID atSourceIdx:_sourceIdx];
    NSString* fieldTitle = (NSString*)[_paramLongTitles objectForKey:@(paramID)];
    [keypad setTitle:[fieldTitle stringByAppendingString:[NSString stringWithFormat:@" [%d] : ", _sourceIdx]]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", value]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:sender];
}

- (void)updateParamField:(UIButton*)field withValue:(float)value {
    [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}


- (void)updateSlider:(UISlider*)slider withValue:(float)value {
    
    TWOscParamID paramID = (TWOscParamID)slider.tag;
    TWParamSliderScale scale = (TWParamSliderScale)[[_paramSliderScales objectForKey:@(paramID)] intValue];
    
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


- (void)sourceIdxDoubleTap:(UITapGestureRecognizer*)recognizer {
    
    CGPoint location = [recognizer locationInView:_sourceIdxSelector];
    CGFloat boxWidth = _sourceIdxSelector.frame.size.width / kNumSources;
    _editActionSourceIdx = (int)floorf(location.x / boxWidth);
    [_editSourceLabel setText:[NSString stringWithFormat:@"%d", _editActionSourceIdx+1]];
//    CGRect outRect = CGRectMake(location.x, _editActionRect.origin.y, _editActionRect.size.width, _editActionRect.size.height);
//    [_editActionView setFrame:outRect];
    [self toggleEditActionView:YES];
}




- (void)cancelButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorFromUIColor:[UIColor cancelButtonColor] withBrightnessOffset:0.01f]];
}

- (void)cancelButtonUp:(UIButton*)sender {
    [self toggleEditActionView:NO];
    [sender setBackgroundColor:[UIColor cancelButtonColor]];
}

- (void)copyButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorFromUIColor:[UIColor copyButtonColor] withBrightnessOffset:0.01f]];
}
- (void)copyButtonUp:(UIButton*)sender {
    [[TWMasterController sharedController] copyOscParamsAtSourceIdx:_editActionSourceIdx];
    [_pasteButton setAlpha:1.0f];
    [_pasteButton setUserInteractionEnabled:YES];
    [self toggleEditActionView:NO];
    [sender setBackgroundColor:[UIColor copyButtonColor]];
}

- (void)pasteButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorFromUIColor:[UIColor pasteButtonColor] withBrightnessOffset:0.01f]];
}
- (void)pasteButtonUp:(UIButton*)sender {
    [[TWMasterController sharedController] pasteOscParamsAtSourceIdx:_editActionSourceIdx];
    [_mixerView refreshParametersWithAnimation:YES];
    [self toggleEditActionView:NO];
    [sender setBackgroundColor:[UIColor pasteButtonColor]];
}



- (void)setMixerView:(id)mixerView {
    _mixerView = (TWMixerView*)mixerView;
}
//- (void)sourceIdxSelectorLongPress:(UILongPressGestureRecognizer*)gestureRecognizer {
//    gestureRecognizer.loca
//}




//- (void)baseFreqSliderChanged {
//    float value = [TWUtils logScaleFromLinear:_baseFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBaseFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateBaseFreqFieldWithValue:value];
//}
//
//- (void)beatFreqSliderChanged {
//    float value = _beatFreqSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscBeatFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateBeatFreqFieldWithValue:value];
//}
//
//- (void)mononessSliderChanged {
//    float value = _mononessSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscMononess withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateMononessFieldWithValue:value];
//}
//
//- (void)softClipSliderChanged {
//    float value = _softClipSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscSoftClipp withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateSoftClipFieldWithValue:value];
//}

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
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscFMWaveform withValue:_waveformSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
            break;
        default:
            break;
    }
}

- (void)waveformComponentChanged {
    [self updateWaveformFromComponent];
}




//- (void)tremFreqSliderChanged {
//    float value = _tremoloRateSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateTremFreqFieldWithValue:value];
//}
//
//- (void)tremDepthSliderChanged {
//    float value = _tremoloDepthSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloDepth withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateTremDepthFieldWithValue:value];
//}
//
//
//- (void)shapeTremFreqSliderChanged {
//    float value = _shapeTremoloRateSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_ShapeTremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateTremDepthFieldWithValue:value];
//}


- (void)filterEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterEnable withValue:_filterEnableSwitch.on atSourceIdx:_sourceIdx inTime:0];
}

- (void)filterTypeChanged {
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterType withValue:_filterSelector.selectedSegmentIndex atSourceIdx:_sourceIdx inTime:0];
}

//- (void)cutoffFreqSliderChanged {
//    float frequency = [TWUtils logScaleFromLinear:_filterCutoffFreqSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterCutoff withValue:frequency atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFilterCutoffFieldWithValue:frequency];
//}

- (void)lfoEnableSwitchChanged {
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOEnable withValue:_filterLFOEnableSwitch.on atSourceIdx:_sourceIdx inTime:0];
}

//- (void)resonanceSliderChanged {
//    float value = [TWUtils logScaleFromLinear:_filterResonanceSlider.value outMin:kResonanceMin outMax:kResonanceMax];
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterResonance withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFilterResonanceFieldWithValue:value];
//}
//
//- (void)filterGainSliderChanged {
//    float value = _filterGainSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterGain withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFilterGainFieldWithValue:value];
//}
//
//- (void)lfoFreqSliderChanged {
//    float value = _filterLFORateSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFilterLFOFrequencyFieldWithValue:value];
//}
//
//- (void)lfoRangeSliderChanged {
//    float value = [TWUtils logScaleFromLinear:_filterLFORangeSlider.value outMin:kFrequencyMin outMax:kFrequencyMax];
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFORange withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFilterLFORangeFieldWithValue:value];
//}
//
//- (void)lfoOffsetSliderChanged {
//    float value = _filterLFOOffsetSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOOffset withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFilterLFOOffsetFieldWithValue:value];
//}
//
//
//- (void)rampTimeSliderChanged {
//    int value = (int)_rampTimeSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_RampTime_ms withValue:(float)value atSourceIdx:_sourceIdx inTime:0.0f];
//    [self updateRampTimeFieldWithValue:value];
//}
//
//
//- (void)fmAmountSliderChanged {
//    float value = _oscFMAmountSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscFMAmount withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFMAmountFieldWithValue:value];
//}
//
//- (void)fmFreqSliderChanged {
//    float value = _oscFMFreqSlider.value;
//    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscFMFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
//    [self updateFMFrequencyFieldWithValue:value];
//}





#pragma mark - Private


//- (void)updateBaseFrequencyUIWithValue:(float)frequency {
//    [self setOscBaseFrequencySlider:frequency];
//    [self updateBaseFreqFieldWithValue:frequency];
//}
//
//- (void)updateBeatFrequencyUIWithValue:(float)frequency {
//    [_beatFreqSlider setValue:frequency animated:YES];
//    [self updateBeatFreqFieldWithValue:frequency];
//}
//
//- (void)updateRampTimeValueUIWithValue:(int)rampTime_ms {
//    [_rampTimeSlider setValue:rampTime_ms];
//    [self updateRampTimeFieldWithValue:rampTime_ms];
//}
//
//
//- (void)updateBaseFreqFieldWithValue:(float)value {
//    [_baseFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateBeatFreqFieldWithValue:(float)value {
//    [_beatFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateMononessFieldWithValue:(float)value {
//    [_mononessField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateSoftClipFieldWithValue:(float)value {
//    [_softClipField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateTremFreqFieldWithValue:(float)value {
//    [_tremoloRateField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateTremDepthFieldWithValue:(float)value {
//    [_tremoloDepthField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateShapeTremFreqFieldWithValue:(float)value {
//    [_shapeTremoloRateField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateShapeTremDepthFieldWithValue:(float)value {
//    [_shapeTremoloDepthField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateShapeTremShapeFieldWithValue:(float)value {
//    [_shapeTremoloShapeField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFilterCutoffFieldWithValue:(float)value {
//    [_filterCutoffFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFilterResonanceFieldWithValue:(float)value {
//    [_filterResonanceField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFilterGainFieldWithValue:(float)value {
//    [_filterGainField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFilterLFOFrequencyFieldWithValue:(float)value {
//    [_filterLFORateField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFilterLFORangeFieldWithValue:(float)value {
//    [_filterLFORangeField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFilterLFOOffsetFieldWithValue:(float)value {
//    [_filterLFOOffsetField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateRampTimeFieldWithValue:(int)value {
//    [_rampTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFMAmountFieldWithValue:(float)value {
//    [_oscFMAmountField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}
//
//- (void)updateFMFrequencyFieldWithValue:(float)value {
//    [_oscFMFreqField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//}

- (void)refreshParametersWithAnimation:(BOOL)animated {
    
    NSArray* paramSliderKeys = [_paramSliders allKeys];
    
    for (NSNumber* parameter in paramSliderKeys) {
        
        TWOscParamID paramID = (TWOscParamID)[parameter intValue];
        
        float value = [[TWAudioController sharedController] getOscParameter:paramID atSourceIdx:_sourceIdx];
        
        UISlider* slider = [_paramSliders objectForKey:@(paramID)];
        [self updateSlider:slider withValue:value];
        
        
        UIButton* field = (UIButton*)[_paramFields objectForKey:@(paramID)];
        [self updateParamField:field withValue:value];
    }
    
    
    [self updateWaveformFromComponent];
    
    [_filterSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterType atSourceIdx:_sourceIdx]];
    [_filterEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterEnable atSourceIdx:_sourceIdx]];
    [_filterLFOEnableSwitch setOn:[[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOEnable atSourceIdx:_sourceIdx]];
    
    
//    float baseFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBaseFrequency atSourceIdx:_sourceIdx];
//    [self updateBaseFrequencyUIWithValue:baseFreq];
//
//    float beatFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBeatFrequency atSourceIdx:_sourceIdx];
//    [self updateBeatFrequencyUIWithValue:beatFreq];
//
//    float mononess = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscMononess atSourceIdx:_sourceIdx];
//    [_mononessSlider setValue:mononess animated:animated];
//    [self updateMononessFieldWithValue:mononess];
//
//    float softClip = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscSoftClipp atSourceIdx:_sourceIdx];
//    [_softClipSlider setValue:softClip animated:animated];
//    [self updateSoftClipFieldWithValue:softClip];
    
//    float tremFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloFrequency atSourceIdx:_sourceIdx];
//    [_tremoloRateSlider setValue:tremFreq animated:animated];
//    [self updateTremFreqFieldWithValue:tremFreq];
//
//    float tremDepth = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloDepth atSourceIdx:_sourceIdx];
//    [_tremoloDepthSlider setValue:tremDepth animated:animated];
//    [self updateTremDepthFieldWithValue:tremDepth];
//
//
//
//    float Fc = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterCutoff atSourceIdx:_sourceIdx];
//    [self setCutoffFrequencySlider:Fc];
//    [self updateFilterCutoffFieldWithValue:Fc];
    
    
    
    
    
//    float gain = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterGain atSourceIdx:_sourceIdx];
//    [_filterGainSlider setValue:gain animated:YES];
//    [self updateFilterGainFieldWithValue:gain];
//
//    float res = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterResonance atSourceIdx:_sourceIdx];
//    [self setResonanceSlider:res];
//    [self updateFilterResonanceFieldWithValue:res];
//
//    float range = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFORange atSourceIdx:_sourceIdx];
//    [self setFilterLFORangeSlider:range];
//    [self updateFilterLFORangeFieldWithValue:range];
//
//    float lfoFreq = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOFrequency atSourceIdx:_sourceIdx];
//    [_filterLFORateSlider setValue:lfoFreq animated:animated];
//    [self updateFilterLFOFrequencyFieldWithValue:lfoFreq];
//
//    float lfoOffset = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOOffset atSourceIdx:_sourceIdx];
//    [_filterLFOOffsetSlider setValue:lfoOffset animated:animated];
//    [self updateFilterLFOOffsetFieldWithValue:lfoOffset];
//
//    int rampTime_ms = (int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:_sourceIdx];
//    [self updateRampTimeValueUIWithValue:rampTime_ms];
//
//    float fmAmount = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMAmount atSourceIdx:_sourceIdx];
//    [_oscFMAmountSlider setValue:fmAmount animated:animated];
//    [self updateFMAmountFieldWithValue:fmAmount];
//
//    float fmFrequency = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMFrequency atSourceIdx:_sourceIdx];
//    [_oscFMFreqSlider setValue:fmFrequency animated:animated];
//    [self updateFMFrequencyFieldWithValue:fmFrequency];
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
            [_waveformSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMWaveform atSourceIdx:_sourceIdx]];
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



//#pragma mark - Parameter Scaling
//
//- (void)setOscBaseFrequencySlider:(float)value {
//    [_baseFreqSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
//}
//
//- (void)setCutoffFrequencySlider:(float)value {
//    [_filterCutoffFreqSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
//}
//
//- (void)setResonanceSlider:(float)value {
//    [_filterResonanceSlider setValue:[TWUtils linearScaleFromLog:value inMin:kResonanceMin inMax:kResonanceMax] animated:YES];
//}
//
//- (void)setFilterLFORangeSlider:(float)value {
//    [_filterLFORangeSlider setValue:[TWUtils linearScaleFromLog:value inMin:kFrequencyMin inMax:kFrequencyMax] animated:YES];
//}


#pragma mark - TWKeypad

- (void)keypadDoneButtonTapped:(UIButton *)responder withValue:(NSString *)inValue {
    
    TWOscParamID paramID = (TWOscParamID)responder.tag;
    float value = [inValue floatValue];
    [[TWAudioController sharedController] setOscParameter:paramID withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
    
    UISlider* slider = (UISlider*)[_paramSliders objectForKey:@(paramID)];
    [self updateSlider:slider withValue:value];
    
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
    
    else if (responder == _tremoloRateField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateTremFreqFieldWithValue:value];
        [_tremoloRateSlider setValue:value animated:YES];
    }
    
    else if (responder == _tremoloDepthField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_TremoloDepth withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateTremDepthFieldWithValue:value];
        [_tremoloDepthSlider setValue:value animated:YES];
    }
    
    else if (responder == _filterCutoffFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterCutoff withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterCutoffFieldWithValue:value];
        [self setCutoffFrequencySlider:value];
    }
    
    else if (responder == _filterResonanceField) {
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
    
    else if (responder == _filterLFORateField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFOFrequencyFieldWithValue:value];
        [_filterLFORateSlider setValue:value animated:YES];
    }
    
    else if (responder == _filterLFOOffsetField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_FilterLFOOffset withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFilterLFOOffsetFieldWithValue:value];
        [_filterLFOOffsetSlider setValue:value animated:YES];
    }
    
    else if (responder == _filterLFORangeField) {
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
    
    else if (responder == _oscFMAmountField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscFMAmount withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFMAmountFieldWithValue:value];
        [_oscFMAmountSlider setValue:value animated:YES];
    }
    
    else if (responder == _oscFMFreqField) {
        float value = [inValue floatValue];
        [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscFMFrequency withValue:value atSourceIdx:_sourceIdx inTime:_rampTimeSlider.value];
        [self updateFMFrequencyFieldWithValue:value];
        [_oscFMFreqSlider setValue:value animated:YES];
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
    
    else if (responder == _tremoloRateField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloFrequency atSourceIdx:_sourceIdx];
        [self updateTremFreqFieldWithValue:value];
    }
    
    else if (responder == _tremoloDepthField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloDepth atSourceIdx:_sourceIdx];
        [self updateTremDepthFieldWithValue:value];
    }
    
    else if (responder == _filterCutoffFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterCutoff atSourceIdx:_sourceIdx];
        [self updateFilterCutoffFieldWithValue:value];
    }
    
    else if (responder == _filterResonanceField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterResonance atSourceIdx:_sourceIdx];
        [self updateFilterResonanceFieldWithValue:value];
    }
    
    else if (responder == _filterGainField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterGain atSourceIdx:_sourceIdx];
        [self updateFilterGainFieldWithValue:value];
    }
    
    else if (responder == _filterLFORateField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOFrequency atSourceIdx:_sourceIdx];
        [self updateFilterLFOFrequencyFieldWithValue:value];
    }
    
    else if (responder == _filterLFOOffsetField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOOffset atSourceIdx:_sourceIdx];
        [self updateFilterLFOOffsetFieldWithValue:value];
    }
    
    else if (responder == _filterLFORangeField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFORange atSourceIdx:_sourceIdx];
        [self updateFilterLFORangeFieldWithValue:value];
    }
    
    else if (responder == _rampTimeField) {
        int value = (int)(int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:_sourceIdx];
        [self updateRampTimeFieldWithValue:value];
    }
    
    else if (responder == _oscFMAmountField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMAmount atSourceIdx:_sourceIdx];
        [self updateFMAmountFieldWithValue:value];
    }
    
    else if (responder == _oscFMFreqField) {
        float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMFrequency atSourceIdx:_sourceIdx];
        [self updateFMFrequencyFieldWithValue:value];
    }
     */
}





//- (void)baseFreqFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Base Freq (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBaseFrequency atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_baseFreqField];
//}
//
//- (void)beatFreqFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Beat Freq (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscBeatFrequency atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_beatFreqField];
//}
//
//- (void)mononessFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Mononess: ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscMononess atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_mononessField];
//}
//
//- (void)softClipFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Soft Clip: ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscSoftClipp atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_softClipField];
//}
//
//- (void)tremFreqFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Trem Freq (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloFrequency atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_tremoloRateField];
//}
//
//- (void)tremDepthFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Trem Depth (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_TremoloDepth atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_tremoloDepthField];
//}
//
//- (void)cutoffFreqFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter Fc (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterCutoff atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_filterCutoffFreqField];
//}
//
//- (void)resonanceFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Resonance (Q): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterResonance atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_filterResonanceField];
//}
//
//- (void)filterGainFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter Gain: ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterGain atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_filterGainField];
//}
//
//- (void)lfoFreqFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Freq (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOFrequency atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_filterLFORateField];
//}
//
//- (void)lfoRangeFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Range (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFORange atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_filterLFORangeField];
//}
//
//- (void)lfoOffsetFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Filter LFO Offset (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_FilterLFOOffset atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_filterLFOOffsetField];
//}
//
//- (void)rampTimeFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] Ramp Time (ms): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%d", (int)(int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_rampTimeField];
//}
//
//- (void)fmAmountFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] FM Amount: ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMAmount atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_oscFMAmountField];
//}
//
//- (void)fmFreqFieldTapped {
//    TWKeypad* keypad = [TWKeypad sharedKeypad];
//    [keypad setTitle:[NSString stringWithFormat:@"[%d] FM Freq (Hz): ", _sourceIdx]];
//    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscFMFrequency atSourceIdx:_sourceIdx]]];
//    [keypad setCurrentResponder:_oscFMFreqField];
//}


- (void)toggleEditActionView:(BOOL)toggle {
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self->_editActionView setAlpha:(CGFloat)toggle];
    } completion:^(BOOL finished) {}];
}

    
@end

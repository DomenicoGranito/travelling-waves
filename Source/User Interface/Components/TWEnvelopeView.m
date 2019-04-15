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
#import "TWKeypad.h"
#import "UIColor+Additions.h"

@interface TWEnvelopeView() <TWKeypadDelegate>
{
    UILabel*                    _ampAttackTimeLabel;
    UISlider*                   _ampAttackTimeSlider;
    UIButton*                   _ampAttackTimeField;
    
    UILabel*                    _ampSustainTimeLabel;
    UISlider*                   _ampSustainTimeSlider;
    UIButton*                   _ampSustainTimeField;
    
    UILabel*                    _ampReleaseTimeLabel;
    UISlider*                   _ampReleaseTimeSlider;
    UIButton*                   _ampReleaseTimeField;
    
    
    
    UISwitch*                   _filterEnableSwitch;
    
    UISegmentedControl*         _filterSelector;
    
    UISlider*                   _filterResonanceSlider;
    UIButton*                   _filterResonanceField;
    
    UISlider*                   _filterFromCutoffFrequencySlider;
    UIButton*                   _filterFromCutoffFrequencyField;
    
    UISlider*                   _filterToCutoffFrequencySlider;
    UIButton*                   _filterToCutoffFrequencyField;
    
    
    UILabel*                    _filterAttackTimeLabel;
    UISlider*                   _filterAttackTimeSlider;
    UIButton*                   _filterAttackTimeField;
    
    UILabel*                    _filterSustainTimeLabel;
    UISlider*                   _filterSustainTimeSlider;
    UIButton*                   _filterSustainTimeField;
    
    UILabel*                    _filterReleaseTimeLabel;
    UISlider*                   _filterReleaseTimeSlider;
    UIButton*                   _filterReleaseTimeField;
    
    
    
    UILabel*                    _intervalLabel;
    UISegmentedControl*         _intervalSelectorRow1;
    UISegmentedControl*         _intervalSelectorRow2;
    
    NSDictionary*               _paramSliders;
    NSDictionary*               _paramFields;
    NSDictionary*               _paramTitles;
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
    
    
    NSMutableDictionary* paramSliders = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* paramFields = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* paramTitles = [[NSMutableDictionary alloc] init];
    
    // Amplitude Envelope
    
    
    _ampAttackTimeLabel = [[UILabel alloc] init];
    [_ampAttackTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_ampAttackTimeLabel setText:@"AAt:"];
    [_ampAttackTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_ampAttackTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_ampAttackTimeLabel];
    
    _ampAttackTimeSlider = [[UISlider alloc] init];
    [_ampAttackTimeSlider setMinimumValue:1.0f];
    [_ampAttackTimeSlider setMaximumValue:500.0f];
    [_ampAttackTimeSlider addTarget:self action:@selector(ampAttackTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_ampAttackTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_ampAttackTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_ampAttackTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_ampAttackTimeSlider setTag:TWSeqParamID_AmpAttackTime];
    [paramSliders setObject:_ampAttackTimeSlider forKey:@(TWSeqParamID_AmpAttackTime)];
    [self addSubview:_ampAttackTimeSlider];
    
    _ampAttackTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_ampAttackTimeField];
    [_ampAttackTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_ampAttackTimeField setTag:TWSeqParamID_AmpAttackTime];
    [paramFields setObject:_ampAttackTimeField forKey:@(TWSeqParamID_AmpAttackTime)];
    [self addSubview:_ampAttackTimeField];
    
    [paramTitles setObject:@"Amp Attack Time (ms): " forKey:@(TWSeqParamID_AmpAttackTime)];
    
    
    
    _ampSustainTimeLabel = [[UILabel alloc] init];
    [_ampSustainTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_ampSustainTimeLabel setText:@"ASt:"];
    [_ampSustainTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_ampSustainTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_ampSustainTimeLabel];
    
    _ampSustainTimeSlider = [[UISlider alloc] init];
    [_ampSustainTimeSlider setMinimumValue:1.0f];
    [_ampSustainTimeSlider setMaximumValue:2000.0f];
    [_ampSustainTimeSlider addTarget:self action:@selector(ampSustainTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_ampSustainTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_ampSustainTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_ampSustainTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_ampSustainTimeSlider setTag:TWSeqParamID_AmpSustainTime];
    [paramSliders setObject:_ampSustainTimeSlider forKey:@(TWSeqParamID_AmpSustainTime)];
    [self addSubview:_ampSustainTimeSlider];
    
    _ampSustainTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_ampSustainTimeField];
    [_ampSustainTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_ampSustainTimeField setTag:TWSeqParamID_AmpSustainTime];
    [paramFields setObject:_ampSustainTimeField forKey:@(TWSeqParamID_AmpSustainTime)];
    [self addSubview:_ampSustainTimeField];
    
    [paramTitles setObject:@"Amp Sustain Time (ms): " forKey:@(TWSeqParamID_AmpSustainTime)];
    
    
    
    _ampReleaseTimeLabel = [[UILabel alloc] init];
    [_ampReleaseTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_ampReleaseTimeLabel setText:@"ARt:"];
    [_ampReleaseTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_ampReleaseTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_ampReleaseTimeLabel];
    
    _ampReleaseTimeSlider = [[UISlider alloc] init];
    [_ampReleaseTimeSlider setMinimumValue:1.0f];
    [_ampReleaseTimeSlider setMaximumValue:4000.0f];
    [_ampReleaseTimeSlider addTarget:self action:@selector(ampReleaseTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_ampReleaseTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_ampReleaseTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_ampReleaseTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_ampReleaseTimeSlider setTag:TWSeqParamID_AmpReleaseTime];
    [paramSliders setObject:_ampReleaseTimeSlider forKey:@(TWSeqParamID_AmpReleaseTime)];
    [self addSubview:_ampReleaseTimeSlider];
    
    _ampReleaseTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_ampReleaseTimeField];
    [_ampReleaseTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_ampReleaseTimeField setTag:TWSeqParamID_AmpReleaseTime];
    [paramFields setObject:_ampReleaseTimeField forKey:@(TWSeqParamID_AmpReleaseTime)];
    [self addSubview:_ampReleaseTimeField];
    
    [paramTitles setObject:@"Amp Release Time (ms): " forKey:@(TWSeqParamID_AmpReleaseTime)];
    
    
    
    // Filter Envelope
    
    _filterEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_filterEnableSwitch setOnTintColor:[UIColor switchOnColor]];
    [_filterEnableSwitch setTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch setThumbTintColor:[UIColor sliderOnColor]];
    [_filterEnableSwitch addTarget:self action:@selector(filterEnableSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [_filterEnableSwitch setTag:TWSeqParamID_FilterEnable];
    [self addSubview:_filterEnableSwitch];
    
    
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:10.0f] forKey:NSFontAttributeName];
    _filterSelector = [[UISegmentedControl alloc] initWithItems:@[@"LPF", @"HPF", @"BPF1", @"BPF2", @"Ntch"]];
    [_filterSelector setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_filterSelector setTintColor:[UIColor sliderOnColor]];
    [_filterSelector setBackgroundColor:[UIColor sliderOffColor]];
    [_filterSelector addTarget:self action:@selector(filterTypeChanged) forControlEvents:UIControlEventValueChanged];
    [_filterSelector setTag:TWSeqParamID_FilterType];
    [self addSubview:_filterSelector];
    
    
    
    _filterResonanceSlider = [[UISlider alloc] init];
    [_filterResonanceSlider setMinimumValue:0.0f];
    [_filterResonanceSlider setMaximumValue:6.0f];
    [_filterResonanceSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterResonanceSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterResonanceSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterResonanceSlider addTarget:self action:@selector(filterResonanceSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_filterResonanceSlider setTag:TWSeqParamID_FilterResonance];
    [paramSliders setObject:_filterResonanceSlider forKey:@(TWSeqParamID_FilterResonance)];
    [self addSubview:_filterResonanceSlider];
    
    _filterResonanceField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterResonanceField];
    [_filterResonanceField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_filterResonanceField setTag:TWSeqParamID_FilterResonance];
    [paramFields setObject:_filterResonanceField forKey:@(TWSeqParamID_FilterResonance)];
    [self addSubview:_filterResonanceField];
    
    [paramTitles setObject:@"Filter Resonance (Q): " forKey:@(TWSeqParamID_FilterResonance)];
    
    
    
    _filterFromCutoffFrequencySlider = [[UISlider alloc] init];
    [_filterFromCutoffFrequencySlider setMinimumValue:1.0f];
    [_filterFromCutoffFrequencySlider setMaximumValue:600.0f];
    [_filterFromCutoffFrequencySlider addTarget:self action:@selector(filterFromCuttoffSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_filterFromCutoffFrequencySlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterFromCutoffFrequencySlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterFromCutoffFrequencySlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterFromCutoffFrequencySlider setTag:TWSeqParamID_FilterFromCutoff];
    [paramSliders setObject:_filterFromCutoffFrequencySlider forKey:@(TWSeqParamID_FilterFromCutoff)];
    [self addSubview:_filterFromCutoffFrequencySlider];
    
    _filterFromCutoffFrequencyField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterFromCutoffFrequencyField];
    [_filterFromCutoffFrequencyField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_filterFromCutoffFrequencyField setTag:TWSeqParamID_FilterFromCutoff];
    [paramFields setObject:_filterFromCutoffFrequencyField forKey:@(TWSeqParamID_FilterFromCutoff)];
    [self addSubview:_filterFromCutoffFrequencyField];
    
    [paramTitles setObject:@"Flt Env From Cutoff (Hz): " forKey:@(TWSeqParamID_FilterFromCutoff)];
    
    
    
    _filterToCutoffFrequencySlider = [[UISlider alloc] init];
    [_filterToCutoffFrequencySlider setMinimumValue:1.0f];
    [_filterToCutoffFrequencySlider setMaximumValue:4000.0f];
    [_filterToCutoffFrequencySlider addTarget:self action:@selector(filterToCuttoffSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_filterToCutoffFrequencySlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterToCutoffFrequencySlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterToCutoffFrequencySlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterToCutoffFrequencySlider setTag:TWSeqParamID_FilterToCutoff];
    [paramSliders setObject:_filterToCutoffFrequencySlider forKey:@(TWSeqParamID_FilterToCutoff)];
    [self addSubview:_filterToCutoffFrequencySlider];
    
    _filterToCutoffFrequencyField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterToCutoffFrequencyField];
    [_filterToCutoffFrequencyField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_filterToCutoffFrequencyField setTag:TWSeqParamID_FilterToCutoff];
    [paramFields setObject:_filterToCutoffFrequencyField forKey:@(TWSeqParamID_FilterToCutoff)];
    [self addSubview:_filterToCutoffFrequencyField];
    
    [paramTitles setObject:@"Flt Env To Cutoff (Hz): " forKey:@(TWSeqParamID_FilterToCutoff)];
    
    
    
    _filterAttackTimeLabel = [[UILabel alloc] init];
    [_filterAttackTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_filterAttackTimeLabel setText:@"FAt:"];
    [_filterAttackTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_filterAttackTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_filterAttackTimeLabel];
    
    _filterAttackTimeSlider = [[UISlider alloc] init];
    [_filterAttackTimeSlider setMinimumValue:1.0f];
    [_filterAttackTimeSlider setMaximumValue:500.0f];
    [_filterAttackTimeSlider addTarget:self action:@selector(filterAttackTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_filterAttackTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterAttackTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterAttackTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterAttackTimeSlider setTag:TWSeqParamID_FilterAttackTime];
    [paramSliders setObject:_filterAttackTimeSlider forKey:@(TWSeqParamID_FilterAttackTime)];
    [self addSubview:_filterAttackTimeSlider];
    
    _filterAttackTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterAttackTimeField];
    [_filterAttackTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_filterAttackTimeField setTag:TWSeqParamID_FilterAttackTime];
    [paramFields setObject:_filterAttackTimeField forKey:@(TWSeqParamID_FilterAttackTime)];
    [self addSubview:_filterAttackTimeField];
    
    [paramTitles setObject:@"Flt Attack Time (ms): " forKey:@(TWSeqParamID_FilterAttackTime)];
    
    
    
    _filterSustainTimeLabel = [[UILabel alloc] init];
    [_filterSustainTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_filterSustainTimeLabel setText:@"FSt:"];
    [_filterSustainTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_filterSustainTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_filterSustainTimeLabel];
    
    _filterSustainTimeSlider = [[UISlider alloc] init];
    [_filterSustainTimeSlider setMinimumValue:1.0f];
    [_filterSustainTimeSlider setMaximumValue:2000.0f];
    [_filterSustainTimeSlider addTarget:self action:@selector(filterSustainTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_filterSustainTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterSustainTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterSustainTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterSustainTimeSlider setTag:TWSeqParamID_FilterSustainTime];
    [paramSliders setObject:_filterSustainTimeSlider forKey:@(TWSeqParamID_FilterSustainTime)];
    [self addSubview:_filterSustainTimeSlider];
    
    _filterSustainTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterSustainTimeField];
    [_filterSustainTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_filterSustainTimeField setTag:TWSeqParamID_FilterSustainTime];
    [paramFields setObject:_filterSustainTimeField forKey:@(TWSeqParamID_FilterSustainTime)];
    [self addSubview:_filterSustainTimeField];
    
    [paramTitles setObject:@"Flt Sustain Time (ms): " forKey:@(TWSeqParamID_FilterSustainTime)];
    
    
    
    _filterReleaseTimeLabel = [[UILabel alloc] init];
    [_filterReleaseTimeLabel setTextColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [_filterReleaseTimeLabel setText:@"FRt:"];
    [_filterReleaseTimeLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_filterReleaseTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_filterReleaseTimeLabel];
    
    _filterReleaseTimeSlider = [[UISlider alloc] init];
    [_filterReleaseTimeSlider setMinimumValue:1.0f];
    [_filterReleaseTimeSlider setMaximumValue:4000.0f];
    [_filterReleaseTimeSlider addTarget:self action:@selector(filterReleaseTimeSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_filterReleaseTimeSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_filterReleaseTimeSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_filterReleaseTimeSlider setThumbTintColor:[UIColor sliderOnColor]];
    [_filterReleaseTimeSlider setTag:TWSeqParamID_FilterReleaseTime];
    [paramSliders setObject:_filterReleaseTimeSlider forKey:@(TWSeqParamID_FilterReleaseTime)];
    [self addSubview:_filterReleaseTimeSlider];
    
    _filterReleaseTimeField = [[UIButton alloc] init];
    [self setupButtonFieldProperties:_filterReleaseTimeField];
    [_filterReleaseTimeField addTarget:self action:@selector(paramFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_filterReleaseTimeField setTag:TWSeqParamID_FilterReleaseTime];
    [paramFields setObject:_filterReleaseTimeField forKey:@(TWSeqParamID_FilterReleaseTime)];
    [self addSubview:_filterReleaseTimeField];
    
    [paramTitles setObject:@"Flt Release Time (ms): " forKey:@(TWSeqParamID_FilterReleaseTime)];
    
    
    
    _paramSliders = [[NSDictionary alloc] initWithDictionary:paramSliders];
    _paramFields = [[NSDictionary alloc] initWithDictionary:paramFields];
    _paramTitles = [[NSDictionary alloc] initWithDictionary:paramTitles];
    
    
    
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
    
    
//    [[TWKeypad sharedKeypad] addToDelegates:self];
    
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
    
    [_ampAttackTimeLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_ampAttackTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_ampAttackTimeField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_ampSustainTimeLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_ampSustainTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_ampSustainTimeField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_ampReleaseTimeLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_ampReleaseTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_ampReleaseTimeField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    
    // Filter Envelope
    xPos = 0.0f;
    yPos += componentHeight;
    [_filterEnableSwitch setFrame:CGRectMake(xPos, yPos + ((componentHeight - _filterEnableSwitch.frame.size.height) / 2.0f), 0.0f, 0.0f)];
    
    xPos += _filterEnableSwitch.frame.size.width;
    [_filterSelector setFrame:CGRectMake(xPos, yPos + 5.0f, 160.0f, componentHeight - 10.0f)];
    
    xPos += _filterSelector.frame.size.width;
    [_filterResonanceSlider setFrame:CGRectMake(xPos, yPos, frame.size.width - xPos - textFieldWidth, componentHeight)];
    
    xPos += _filterResonanceSlider.frame.size.width;
    [_filterResonanceField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0;
    CGFloat cutoffSliderWidth = (frame.size.width - (2.0 * textFieldWidth)) / 2.0f;
    [_filterFromCutoffFrequencyField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    xPos += textFieldWidth;
    [_filterFromCutoffFrequencySlider setFrame:CGRectMake(xPos, yPos, cutoffSliderWidth, componentHeight)];
    xPos += cutoffSliderWidth;
    [_filterToCutoffFrequencySlider setFrame:CGRectMake(xPos, yPos, cutoffSliderWidth, componentHeight)];
    xPos += cutoffSliderWidth;
    [_filterToCutoffFrequencyField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_filterAttackTimeLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_filterAttackTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_filterAttackTimeField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_filterSustainTimeLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_filterSustainTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_filterSustainTimeField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    yPos += componentHeight;
    xPos = 0.0f;
    [_filterReleaseTimeLabel setFrame:CGRectMake(xPos, yPos, titleLabelWidth, componentHeight)];
    xPos += titleLabelWidth;
    [_filterReleaseTimeSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += sliderWidth;
    [_filterReleaseTimeField setFrame:CGRectMake(xPos, yPos, textFieldWidth, componentHeight)];
    
    
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
    int ampAttackTime_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_AmpAttackTime atSourceIdx:sourceIdx];
    [_ampAttackTimeSlider setValue:ampAttackTime_ms animated:NO];
    [_ampAttackTimeField setTitle:[NSString stringWithFormat:@"%d", ampAttackTime_ms] forState:UIControlStateNormal];
    
    int ampSustainTime_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_AmpSustainTime atSourceIdx:sourceIdx];
    [_ampSustainTimeSlider setValue:ampSustainTime_ms animated:NO];
    [_ampSustainTimeField setTitle:[NSString stringWithFormat:@"%d", ampSustainTime_ms] forState:UIControlStateNormal];
    
    int ampReleaseTime_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_AmpReleaseTime atSourceIdx:sourceIdx];
    [_ampReleaseTimeSlider setValue:ampReleaseTime_ms animated:NO];
    [_ampReleaseTimeField setTitle:[NSString stringWithFormat:@"%d", ampReleaseTime_ms] forState:UIControlStateNormal];
    
    
    // Filter Envelope
    [_filterEnableSwitch setOn:[[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterEnable atSourceIdx:sourceIdx]];
    [_filterSelector setSelectedSegmentIndex:[[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterType atSourceIdx:sourceIdx]];
    
    float resonance = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterResonance atSourceIdx:sourceIdx];
    [_filterResonanceSlider setValue:resonance animated:NO];
    [_filterResonanceField setTitle:[NSString stringWithFormat:@"%.2f", resonance] forState:UIControlStateNormal];
    
    float fromCuttoff = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterFromCutoff atSourceIdx:sourceIdx];
    [_filterFromCutoffFrequencySlider setValue:fromCuttoff animated:NO];
    [_filterFromCutoffFrequencyField setTitle:[NSString stringWithFormat:@"%.2f", fromCuttoff] forState:UIControlStateNormal];
    
    float toCuttoff = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterToCutoff atSourceIdx:sourceIdx];
    [_filterToCutoffFrequencySlider setValue:toCuttoff animated:NO];
    [_filterToCutoffFrequencyField setTitle:[NSString stringWithFormat:@"%.2f", toCuttoff] forState:UIControlStateNormal];
    
    
    int fltAttackTime_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterAttackTime atSourceIdx:sourceIdx];
    [_filterAttackTimeSlider setValue:fltAttackTime_ms animated:NO];
    [_filterAttackTimeField setTitle:[NSString stringWithFormat:@"%d", fltAttackTime_ms] forState:UIControlStateNormal];
    
    int fltSustainTime_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterSustainTime atSourceIdx:sourceIdx];
    [_filterSustainTimeSlider setValue:fltSustainTime_ms animated:NO];
    [_filterSustainTimeField setTitle:[NSString stringWithFormat:@"%d", fltSustainTime_ms] forState:UIControlStateNormal];
    
    int fltReleaseTime_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_FilterReleaseTime atSourceIdx:sourceIdx];
    [_filterReleaseTimeSlider setValue:fltReleaseTime_ms animated:NO];
    [_filterReleaseTimeField setTitle:[NSString stringWithFormat:@"%d", fltReleaseTime_ms] forState:UIControlStateNormal];
    
    
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


- (void)setupButtonFieldProperties:(UIButton*)field {
    [field setTitleColor:[UIColor valueTextLightWhiteColor] forState:UIControlStateNormal];
    [field.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [field setBackgroundColor:[UIColor clearColor]];
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
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_AmpAttackTime withValue:value atSourceIdx:_sourceIdx];
    [_ampAttackTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
}

- (void)ampSustainTimeSliderValueChanged {
    int value = _ampSustainTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_AmpSustainTime withValue:value atSourceIdx:_sourceIdx];
    [_ampSustainTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
}

- (void)ampReleaseTimeSliderValueChanged {
    int value = _ampReleaseTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_AmpReleaseTime withValue:value atSourceIdx:_sourceIdx];
    [_ampReleaseTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
}

- (void)filterEnableSwitchChanged {
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterEnable withValue:_filterEnableSwitch.on atSourceIdx:_sourceIdx];
}

- (void)filterTypeChanged {
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterType withValue:_filterSelector.selectedSegmentIndex atSourceIdx:_sourceIdx];
}

- (void)filterResonanceSliderChanged {
    float value = _filterResonanceSlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterResonance withValue:value atSourceIdx:_sourceIdx];
    [_filterResonanceField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)filterFromCuttoffSliderValueChanged {
    float value = _filterFromCutoffFrequencySlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterFromCutoff withValue:value atSourceIdx:_sourceIdx];
    [_filterFromCutoffFrequencyField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)filterToCuttoffSliderValueChanged {
    float value = _filterToCutoffFrequencySlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterToCutoff withValue:value atSourceIdx:_sourceIdx];
    [_filterToCutoffFrequencyField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)filterAttackTimeSliderValueChanged {
    int value = _filterAttackTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterAttackTime withValue:value atSourceIdx:_sourceIdx];
    [_filterAttackTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
}

- (void)filterSustainTimeSliderValueChanged {
    int value = _filterSustainTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterSustainTime withValue:value atSourceIdx:_sourceIdx];
    [_filterSustainTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
}

- (void)filterReleaseTimeSliderValueChanged {
    int value = _filterReleaseTimeSlider.value;
    [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_FilterReleaseTime withValue:value atSourceIdx:_sourceIdx];
    [_filterReleaseTimeField setTitle:[NSString stringWithFormat:@"%d", value] forState:UIControlStateNormal];
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



#pragma mark - TWKeypad

- (void)keypadDoneButtonTapped:(UIButton *)responder withValue:(NSString *)inValue {
    TWSeqParamID paramID = (TWSeqParamID)responder.tag;
    
    float value = [inValue floatValue];
    [[TWAudioController sharedController] setSeqParameter:paramID withValue:value atSourceIdx:_sourceIdx];
    
    UISlider* slider = (UISlider*)[_paramSliders objectForKey:@(paramID)];
    [slider setValue:value];
    
    UIButton* field = (UIButton*)[_paramFields objectForKey:@(paramID)];
    [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)keypadCancelButtonTapped:(UIButton *)responder {
    int paramID = (int)responder.tag;
    float value = [[TWAudioController sharedController] getSeqParameter:paramID atSourceIdx:_sourceIdx];
    
    UIButton* field = (UIButton*)[_paramFields objectForKey:@(paramID)];
    [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

- (void)paramFieldTapped:(UIButton*)sender {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    int paramID = (int)sender.tag;
    [keypad setTitle:(NSString*)[_paramTitles objectForKey:@(paramID)]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getSeqParameter:paramID atSourceIdx:_sourceIdx]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:sender];
}


@end

//
//  TWMixerView.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/13/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWMixerView.h"
#import "TWHeader.h"
#import "TWAudioController.h"
#import "TWKeypad.h"
#import "TWFillSlider.h"
#import "TWOscView.h"
#import "UIColor+Additions.h"

//static const CGFloat kGainValueLabelWidth   = 28.0f;
static const CGFloat kIDLabelWidth          = 12.0f;
static const CGFloat kSoloButtonWidth       = 28.0f;

@interface TWMixerView() <TWKeypadDelegate>
{
    NSArray*    _gainSliders;
//    NSArray*    _gainTextFields;
    NSArray*    _soloButtons;
    NSArray*    _idLabels;
}
@end



@implementation TWMixerView

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    NSMutableArray* sliders = [[NSMutableArray alloc] init];
//    NSMutableArray* textFields  = [[NSMutableArray alloc] init];
    NSMutableArray* soloButtons = [[NSMutableArray alloc] init];
    NSMutableArray* idLabels = [[NSMutableArray alloc] init];
    
    
    
//    [[TWKeypad sharedKeypad] addToDelegates:self];
    
    
//    CGFloat yPos = 0.0f;
//    CGFloat xPos = 0.0f;
//    CGFloat sliderWidth = (self.frame.size.width - (2.0f * (kGainValueWidthLabel + kIDLabelWidth + kSoloButtonWidth))) / 2.0f;
    
    for (int idx=0; idx < kNumSources; idx++) {
        
//        UISlider* slider = [[UISlider alloc] initWithFrame:CGRectZero];
//        [slider setMinimumValue:kAmplitudeMin];
//        [slider setMaximumValue:kAmplitudeMax];
//        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//        [slider addTarget:self action:@selector(sliderEndEditing:) forControlEvents:UIControlEventTouchUpInside];
//        [slider addTarget:self action:@selector(sliderEndEditing:) forControlEvents:UIControlEventTouchUpOutside];
//        [slider setMinimumTrackTintColor:[UIColor sliderOnColor]];
//        [slider setMaximumTrackTintColor:[UIColor sliderOffColor]];
//        [slider setThumbTintColor:[UIColor sliderOnColor]];
//        [slider setTag:idx];
        
        TWFillSlider* slider = [[TWFillSlider alloc] init];
        [slider setIsHorizontal:YES];
        [slider setDisplayValueLabelInSlider:YES];
        [slider setMinimumValue:kAmplitudeMin];
        [slider setMaximumValue:kAmplitudeMax];
        [slider setTag:idx];
//        [slider setOnTrackColor:[UIColor colorWithRed:0.2 green:0.5 blue:0.2 alpha:0.5]];
        [slider setOnTrackColor:[UIColor sliderOnColor]];
        [slider setOffTrackColor:[UIColor sliderOffColor]];
        [slider setValueLabelColor:[UIColor colorWithWhite:0.04f alpha:1.0f]];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderEndEditing:) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderEndEditing:) forControlEvents:UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(sliderDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];

        
        
//        UITextField* textField = [[UITextField alloc] init];
//        [textField setTextColor:[UIColor valueTextWhiteColor]];
//        [textField setFont:[UIFont systemFontOfSize:11.0f]];
//        [textField setTextAlignment:NSTextAlignmentCenter];
//        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
//        [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
//        [textField setInputAccessoryView:sharedView];
//        [textField setBackgroundColor:[UIColor clearColor]];
//        [textField setTag:idx];
//        [textField setDelegate:self];
        
//        UIButton* textField = [[UIButton alloc] init];
//        [textField setTag:idx];
//        [textField setTitleColor:[UIColor valueTextDarkWhiteColor] forState:UIControlStateNormal];
//        [textField.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
//        [textField setBackgroundColor:[UIColor clearColor]];
//        [textField addTarget:self action:@selector(textFieldTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [idLabel setText:[NSString stringWithFormat:@"%d", idx+1]];
        [idLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [idLabel setTextAlignment:NSTextAlignmentCenter];
        [idLabel setTextColor:[UIColor colorWithWhite:0.4f alpha:0.6f]];
        [idLabel setTextAlignment:NSTextAlignmentCenter];
        [idLabel setBackgroundColor:[UIColor clearColor]];
        
        UIButton* soloButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [soloButton setTitle:@"S" forState:UIControlStateNormal];
        [soloButton addTarget:self action:@selector(soloButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [soloButton setBackgroundColor:[UIColor soloDisableColor]];
        [soloButton setTitleColor:[UIColor colorWithWhite:0.5f alpha:0.6f] forState:UIControlStateNormal];
        [[soloButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [soloButton setTag:idx];
        
//        if ((idx % 2) == 0) {
//            xPos = 0.0f;
//            [idLabel setFrame:CGRectMake(xPos, yPos, kIDLabelWidth, kComponentHeight)];
//            xPos += idLabel.frame.size.width;
//            [soloButton setFrame:CGRectMake(xPos , yPos + kButtonYMargin, kSoloButtonWidth, kComponentHeight - (2.0f * kButtonYMargin))];
//            xPos += soloButton.frame.size.width;
//            [textField setFrame:CGRectMake(xPos, yPos, kGainValueWidthLabel, kComponentHeight)];
//            [textField setTextAlignment:NSTextAlignmentLeft];
//            xPos += textField.frame.size.width;
//            [slider setFrame:CGRectMake(xPos, yPos, sliderWidth, kComponentHeight)];
//        } else {
//            xPos = self.frame.size.width - kIDLabelWidth;
//            [idLabel setFrame:CGRectMake(xPos, yPos, kIDLabelWidth, kComponentHeight)];
//            xPos -= kSoloButtonWidth;
//            [soloButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kSoloButtonWidth, kComponentHeight - (2.0f * kButtonYMargin))];
//            xPos -= kGainValueWidthLabel;
//            [textField setFrame:CGRectMake(xPos, yPos, kGainValueWidthLabel, kComponentHeight)];
//            [textField setTextAlignment:NSTextAlignmentRight];
//            xPos -= sliderWidth;
//            [slider setFrame:CGRectMake(xPos, yPos, sliderWidth, kComponentHeight)];
//
//            yPos += kComponentHeight;
//        }
        
        [sliders addObject:slider];
//        [textFields addObject:textField];
        [soloButtons addObject:soloButton];
        [idLabels addObject:idLabel];
        [self addSubview:slider];
        [self addSubview:idLabel];
//        [self addSubview:textField];
        [self addSubview:soloButton];
    }
    
    _gainSliders = [[NSArray alloc] initWithArray:sliders];
//    _gainTextFields  = [[NSArray alloc] initWithArray:textFields];
    _soloButtons = [[NSArray alloc] initWithArray:soloButtons];
    _idLabels = [[NSArray alloc] initWithArray:idLabels];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)refreshParametersWithAnimation:(BOOL)animated {
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        float amplitude = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscAmplitude atSourceIdx:sourceIdx];
        TWFillSlider* slider = [_gainSliders objectAtIndex:sourceIdx];
//        UIButton* textField = [_gainTextFields objectAtIndex:sourceIdx];
        [slider setValue:amplitude];
//        [textField setTitle:[NSString stringWithFormat:@"%.2f", amplitude] forState:UIControlStateNormal];
        
        BOOL seqEnabled = [[TWAudioController sharedController] getSeqEnabledAtSourceIdx:sourceIdx];
        UILabel* idLabel = (UILabel*)_idLabels[sourceIdx];
        [idLabel setBackgroundColor:(seqEnabled ? [UIColor sequencerEnableColor] : [UIColor clearColor])];
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
    
    CGFloat sliderWidth, sliderHeight, cornerRadius;
    CGPoint sliderUIInset;
    
    if (isLandscape) {
//        sliderWidth = (frame.size.width - (4.0f * (kGainValueLabelWidth + kIDLabelWidth + kSoloButtonWidth))) / 4.0f;
        sliderWidth = (frame.size.width - (4.0f * (kIDLabelWidth + kSoloButtonWidth))) / 4.0f;
        sliderHeight = componentHeight;
        sliderUIInset = CGPointMake(4.0f, 14.0f);
        cornerRadius = 0.8f;
    } else {
//        sliderWidth = (frame.size.width - (2.0f * (kGainValueLabelWidth + kIDLabelWidth + kSoloButtonWidth))) / 2.0f;
        sliderWidth = (frame.size.width - (2.0f * (kIDLabelWidth + kSoloButtonWidth))) / 2.0f;
        sliderHeight = componentHeight;
        sliderUIInset = CGPointMake(4.0f, 10.0f);
        cornerRadius = 0.8f;
    }
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {

        TWFillSlider* slider = (TWFillSlider*)[_gainSliders objectAtIndex:sourceIdx];
        [slider setUIFromTouchFrameInset:sliderUIInset];
        [slider setCornerRadius:cornerRadius];
        
//        UIButton* field = (UIButton*)[_gainTextFields objectAtIndex:sourceIdx];
        UILabel* idLabel = (UILabel*)[_idLabels objectAtIndex:sourceIdx];
        UIButton* soloButton = (UIButton*)[_soloButtons objectAtIndex:sourceIdx];
        
        if (isLandscape) {
            
            int column = sourceIdx % 4;
            
            switch (column) {
                case 0:
                case 1:
                    xPos = (column == 0) ? 0.0f : (kIDLabelWidth + kSoloButtonWidth /* + kGainValueLabelWidth*/ + sliderWidth);
                    [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos += idLabel.frame.size.width;
                    [soloButton setFrame:CGRectMake(xPos , yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos += soloButton.frame.size.width;
//                    [field setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
//                    [field.titleLabel setTextAlignment:NSTextAlignmentLeft];
//                    xPos += field.frame.size.width;
                    [slider setFrame:CGRectMake(xPos, yPos + ((componentHeight - sliderHeight) / 2.0f), sliderWidth, sliderHeight)];
                    break;
                    
                case 2:
                case 3:
                    xPos = (column == 2) ? (frame.size.width - kIDLabelWidth - kSoloButtonWidth /* - kGainValueLabelWidth*/ - sliderWidth - kIDLabelWidth) : (frame.size.width - kIDLabelWidth);
                    [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos -= kSoloButtonWidth;
                    [soloButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
//                    xPos -= kGainValueLabelWidth;
//                    [field setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
//                    [field.titleLabel setTextAlignment:NSTextAlignmentRight];
                    xPos -= sliderWidth;
                    [slider setFrame:CGRectMake(xPos, yPos + ((componentHeight - sliderHeight) / 2.0f), sliderWidth, sliderHeight)];
                    if (column == 3) {
                        yPos += componentHeight;
                    }
                default:
                    break;
            }
        }
        
        
        else { // if portrait orientation
            if ((sourceIdx % 2) == 0) {
                xPos = 0.0f;
                [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                xPos += idLabel.frame.size.width;
                [soloButton setFrame:CGRectMake(xPos , yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
                xPos += soloButton.frame.size.width;
//                [field setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
//                [field.titleLabel setTextAlignment:NSTextAlignmentLeft];
//                xPos += field.frame.size.width;
                [slider setFrame:CGRectMake(xPos, yPos + ((componentHeight - sliderHeight) / 2.0f), sliderWidth, sliderHeight)];
            } else {
                xPos = frame.size.width - kIDLabelWidth;
                [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                xPos -= kSoloButtonWidth;
                [soloButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
//                xPos -= kGainValueLabelWidth;
//                [field setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
//                [field.titleLabel setTextAlignment:NSTextAlignmentRight];
                xPos -= sliderWidth;
                [slider setFrame:CGRectMake(xPos, yPos + ((componentHeight - sliderHeight) / 2.0f), sliderWidth, sliderHeight)];
                
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


- (void)sliderValueChanged:(TWFillSlider*)sender {
    float amplitude = sender.value;
    int sourceIdx = (int)sender.tag;
    int rampTime_ms = (int)[[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:sourceIdx];
    [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscAmplitude withValue:amplitude atSourceIdx:sourceIdx inTime:rampTime_ms];
//    UIButton* textField = [_gainTextFields objectAtIndex:sourceIdx];
//    [textField setTitle:[NSString stringWithFormat:@"%.2f", amplitude] forState:UIControlStateNormal];
}

- (void)sliderEndEditing:(TWFillSlider*)sender {
    int sourceIdx = (int)sender.tag;
    [self updateOscView:sourceIdx];
}

- (void)sliderDoubleTapped:(TWFillSlider*)sender {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    int sourceIdx = (int)sender.tag;
    [keypad setTitle:[NSString stringWithFormat:@"Osc[%d]. Gain:", sourceIdx+1]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscAmplitude atSourceIdx:(int)sender.tag]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:sender];
    [self updateOscView:sourceIdx];
}



- (void)soloButtonTapped:(UIButton*)sender {
    if ([sender isSelected]) {
        [[TWAudioController sharedController] setOscSoloEnabled:NO atSourceIdx:(int)sender.tag];
        [sender setBackgroundColor:[UIColor soloDisableColor]];
        [sender setSelected:NO];
    }
    
    else {
        [[TWAudioController sharedController] setOscSoloEnabled:YES atSourceIdx:(int)sender.tag];
        [sender setBackgroundColor:[UIColor soloEnableColor]];
        [sender setSelected:YES];
        [self updateOscView:(int)sender.tag];
    }
}




- (void)updateOscView:(int)sourceIdx {
    if ([_oscView respondsToSelector:@selector(setSourceIdx:)]) {
        [_oscView setSourceIdx:sourceIdx];
    }
}

- (void)setOscView:(id)oscView {
    _oscView = (TWOscView*)oscView;
}


#pragma mark - TWKeypad

- (void)keypadDoneButtonTapped:(id)senderKeypad forComponent:(UIView*)responder withValue:(NSString *)inValue {
    
    for (TWFillSlider* slider in _gainSliders) {
        
        if (responder == slider) {
            
            int sourceIdx = (int)slider.tag;
            
            int rampTime_ms = [[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:sourceIdx];
            
            float amplitude = [inValue floatValue];
            amplitude >= kAmplitudeMax ? amplitude = kAmplitudeMax : amplitude <= kAmplitudeMin ? amplitude = kAmplitudeMin : amplitude;
            
            [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscAmplitude withValue:amplitude atSourceIdx:sourceIdx inTime:rampTime_ms];
            
            [slider setValue:amplitude];
            
            break;
        }
    }
    
//    for (UIButton* field in _gainTextFields) {
//
//        if (responder == field) {
//
//            int sourceIdx = (int)field.tag;
//
//            int rampTime_ms = [[TWAudioController sharedController] getOscParameter:TWOscParamID_RampTime_ms atSourceIdx:sourceIdx];
//
//            float amplitude = [inValue floatValue];
//            amplitude >= kAmplitudeMax ? amplitude = kAmplitudeMax : amplitude <= kAmplitudeMin ? amplitude = kAmplitudeMin : amplitude;
//
//            [[TWAudioController sharedController] setOscParameter:TWOscParamID_OscAmplitude withValue:amplitude atSourceIdx:sourceIdx inTime:rampTime_ms];
//
//            TWFillSlider* slider = [_gainSliders objectAtIndex:sourceIdx];
//            [slider setValue:amplitude];
//            [field setTitle:[NSString stringWithFormat:@"%.2f", amplitude] forState:UIControlStateNormal];
//            [self updateOscView:sourceIdx];
//
//            break;
//        }
//    }
}


- (void)keypadCancelButtonTapped:(id)senderKeypad forComponent:(UIView*)responder {
//    for (TWFillSlider* slider in _gainSliders) {
//        if (responder == slider) {
//            int sourceIdx = (int)slider.tag;
//            float value = [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscAmplitude atSourceIdx:sourceIdx];
//            [field setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
//            [self updateOscView:sourceIdx];
//            break;
//        }
//    }
}


- (void)textFieldTapped:(UIButton*)sender {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:[NSString stringWithFormat:@"Osc[%d]. Gain:", (int)sender.tag+1]];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getOscParameter:TWOscParamID_OscAmplitude atSourceIdx:(int)sender.tag]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:sender];
}

@end

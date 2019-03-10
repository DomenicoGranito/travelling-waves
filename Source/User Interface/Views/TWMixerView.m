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
#import "TWKeyboardAccessoryView.h"

static const CGFloat kGainValueLabelWidth   = 24.0f;
static const CGFloat kIDLabelWidth          = 12.0f;
static const CGFloat kSoloButtonWidth       = 28.0f;

@interface TWMixerView() <UITextFieldDelegate, TWKeyboardAccessoryViewDelegate>
{
    NSArray*    _sliders;
    NSArray*    _textFields;
    NSArray*    _soloButtons;
    NSArray*    _idLabels;
    
    UIColor*    _soloOffColor;
    UIColor*    _soloOnColor;
    
    UIColor*    _seqOnColor;
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
    NSMutableArray* textFields  = [[NSMutableArray alloc] init];
    NSMutableArray* soloButtons = [[NSMutableArray alloc] init];
    NSMutableArray* idLabels = [[NSMutableArray alloc] init];
    
    _soloOffColor = [[UIColor alloc] initWithWhite:0.2f alpha:0.2f];
    _soloOnColor = [[UIColor alloc] initWithRed:0.5f green:0.5f blue:0.1f alpha:0.3f];
    
    _seqOnColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.2 alpha:0.4];
    
    TWKeyboardAccessoryView* sharedView = [TWKeyboardAccessoryView sharedView];
    [sharedView addToDelegates:self];
    
//    CGFloat yPos = 0.0f;
//    CGFloat xPos = 0.0f;
//    CGFloat sliderWidth = (self.frame.size.width - (2.0f * (kGainValueWidthLabel + kIDLabelWidth + kSoloButtonWidth))) / 2.0f;
    
    for (int idx=0; idx < kNumSources; idx++) {
        
        UISlider* slider = [[UISlider alloc] initWithFrame:CGRectZero];
        [slider setMinimumValue:0.0f];
        [slider setMaximumValue:1.0f];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderEndEditing:) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(sliderEndEditing:) forControlEvents:UIControlEventTouchUpOutside];
        [slider setMinimumTrackTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
        [slider setMaximumTrackTintColor:[UIColor colorWithWhite:0.25f alpha:1.0f]];
        [slider setThumbTintColor:[UIColor colorWithWhite:kSliderOnWhiteColor alpha:1.0f]];
        [slider setTag:idx];
        
        UITextField* textField = [[UITextField alloc] init];
        [textField setTextColor:[UIColor colorWithWhite:0.4f alpha:1.0f]];
        [textField setFont:[UIFont systemFontOfSize:11.0f]];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [textField setInputAccessoryView:sharedView];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setTag:idx];
        [textField setDelegate:self];
        
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
        [soloButton setBackgroundColor:_soloOffColor];
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
        [textFields addObject:textField];
        [soloButtons addObject:soloButton];
        [idLabels addObject:idLabel];
        [self addSubview:slider];
        [self addSubview:idLabel];
        [self addSubview:textField];
        [self addSubview:soloButton];
    }
    
    _sliders = [[NSArray alloc] initWithArray:sliders];
    _textFields  = [[NSArray alloc] initWithArray:textFields];
    _soloButtons = [[NSArray alloc] initWithArray:soloButtons];
    _idLabels = [[NSArray alloc] initWithArray:idLabels];
    
    [self setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        float amplitude = [[TWAudioController sharedController] getOscParameter:kOscParam_OscAmplitude atSourceIdx:sourceIdx];
        UISlider* slider = [_sliders objectAtIndex:sourceIdx];
        UITextField* textField = [_textFields objectAtIndex:sourceIdx];
        [slider setValue:amplitude animated:animated];
        [textField setText:[NSString stringWithFormat:@"%.2f", amplitude]];
        
        BOOL seqEnabled = [[TWAudioController sharedController] getSeqEnabledAtSourceIdx:sourceIdx];
        UILabel* idLabel = (UILabel*)_idLabels[sourceIdx];
        [idLabel setBackgroundColor:(seqEnabled ? _seqOnColor : [UIColor clearColor])];
    }
}


- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = isLandscape ? kLandscapeComponentHeight : kPortraitComponentHeight;
    
    CGFloat yPos = 0.0f;
    CGFloat xPos = 0.0f;
    
    CGFloat sliderWidth;
    if (isLandscape) {
        sliderWidth = (frame.size.width - (4.0f * (kGainValueLabelWidth + kIDLabelWidth + kSoloButtonWidth))) / 4.0f;
    } else {
        sliderWidth = (frame.size.width - (2.0f * (kGainValueLabelWidth + kIDLabelWidth + kSoloButtonWidth))) / 2.0f;
    }
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {

        UISlider* slider = (UISlider*)[_sliders objectAtIndex:sourceIdx];
        UILabel* label = (UILabel*)[_textFields objectAtIndex:sourceIdx];
        UILabel* idLabel = (UILabel*)[_idLabels objectAtIndex:sourceIdx];
        UIButton* soloButton = (UIButton*)[_soloButtons objectAtIndex:sourceIdx];
        
        if (isLandscape) {
            
            int column = sourceIdx % 4;
            
            switch (column) {
                case 0:
                case 1:
                    xPos = (column == 0) ? 0.0f : (kIDLabelWidth + kSoloButtonWidth + kGainValueLabelWidth + sliderWidth);
                    [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos += idLabel.frame.size.width;
                    [soloButton setFrame:CGRectMake(xPos , yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos += soloButton.frame.size.width;
                    [label setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
                    [label setTextAlignment:NSTextAlignmentLeft];
                    xPos += label.frame.size.width;
                    [slider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
                    break;
                    
                case 2:
                case 3:
                    xPos = (column == 2) ? (frame.size.width - kIDLabelWidth - kSoloButtonWidth - kGainValueLabelWidth - sliderWidth - kIDLabelWidth) : (frame.size.width - kIDLabelWidth);
                    [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos -= kSoloButtonWidth;
                    [soloButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
                    xPos -= kGainValueLabelWidth;
                    [label setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
                    [label setTextAlignment:NSTextAlignmentRight];
                    xPos -= sliderWidth;
                    [slider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
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
                [label setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
                [label setTextAlignment:NSTextAlignmentLeft];
                xPos += label.frame.size.width;
                [slider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
            } else {
                xPos = frame.size.width - kIDLabelWidth;
                [idLabel setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kIDLabelWidth, componentHeight - (2.0f * kButtonYMargin))];
                xPos -= kSoloButtonWidth;
                [soloButton setFrame:CGRectMake(xPos, yPos + kButtonYMargin, kSoloButtonWidth, componentHeight - (2.0f * kButtonYMargin))];
                xPos -= kGainValueLabelWidth;
                [label setFrame:CGRectMake(xPos, yPos, kGainValueLabelWidth, componentHeight)];
                [label setTextAlignment:NSTextAlignmentRight];
                xPos -= sliderWidth;
                [slider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
                
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


- (void)sliderValueChanged:(UISlider*)sender {
    float amplitude = sender.value;
    int sourceIdx = (int)sender.tag;
    int rampTime_ms = [[TWAudioController sharedController] getRampTimeAtSourceIdx:sourceIdx];
    [[TWAudioController sharedController] setOscParameter:kOscParam_OscAmplitude withValue:amplitude atSourceIdx:sourceIdx inTime:rampTime_ms];
    UITextField* textField = [_textFields objectAtIndex:sourceIdx];
    [textField setText:[NSString stringWithFormat:@"%.2f", amplitude]];
}

- (void)sliderEndEditing:(UISlider*)sender {
    int sourceIdx = (int)sender.tag;
    [self updateOscView:sourceIdx];
}



- (void)soloButtonTapped:(UIButton*)sender {
    if ([sender isSelected]) {
        [[TWAudioController sharedController] setOscSoloEnabled:NO atSourceIdx:(int)sender.tag];
        [sender setBackgroundColor:_soloOffColor];
        [sender setSelected:NO];
    }
    
    else {
        [[TWAudioController sharedController] setOscSoloEnabled:YES atSourceIdx:(int)sender.tag];
        [sender setBackgroundColor:_soloOnColor];
        [sender setSelected:YES];
        [self updateOscView:(int)sender.tag];
    }
}



#pragma - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[TWKeyboardAccessoryView sharedView] setValueText:[textField text]];
    [[TWKeyboardAccessoryView sharedView] setTitleText:[NSString stringWithFormat:@"Osc[%d]. Gain:", (int)textField.tag]];
    return  YES;
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


- (void)keyboardDoneButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    for (UITextField* textField in _textFields) {
        if (currentResponder == textField) {
            int sourceIdx = (int)textField.tag;
            float value = [[currentResponder text] floatValue];
            int rampTime_ms = [[TWAudioController sharedController] getRampTimeAtSourceIdx:sourceIdx];
            [[TWAudioController sharedController] setOscParameter:kOscParam_OscAmplitude withValue:value atSourceIdx:sourceIdx inTime:rampTime_ms];
            UISlider* slider = [_sliders objectAtIndex:sourceIdx];
            [slider setValue:value animated:YES];
            [self updateOscView:sourceIdx];
        }
    }
    
    [currentResponder resignFirstResponder];
}

- (void)keyboardCancelButtonTapped:(id)sender {
    
    UITextField* currentResponder = [[TWKeyboardAccessoryView sharedView] currentResponder];
    
    for (UITextField* textField in _textFields) {
        if (currentResponder == textField) {
            UISlider* slider = [_sliders objectAtIndex:(int)textField.tag];
            [textField setText:[NSString stringWithFormat:@"%.2f", slider.value]];
            [self updateOscView:(int)textField.tag];
        }
    }
    
    [currentResponder resignFirstResponder];
}


- (void)updateOscView:(int)sourceIdx {
    if ([_oscView respondsToSelector:@selector(setOscID:)]) {
        [_oscView setOscID:sourceIdx];
    }
}

@end

//
//  TWHomeViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 8/20/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWHomeViewController.h"

#import "TWSynthView.h"

#import "TWOscView.h"
#import "TWMixerView.h"
#import "TWFrequencyRatioControlView.h"
#import "TWMasterController.h"
#import "TWAudioController.h"
#import "TWHeader.h"

#import "TWLoadProjectViewController.h"
#import "TWFrequencyChartViewController.h"
#import "TWSequencerViewController.h"
#import "TWDrumPadViewController.h"
#import "TWLevelMeterView.h"

#import "TWKeypad.h"
#import "UIColor+Additions.h"


@interface TWHomeScrollView : UIScrollView
@end

@implementation TWHomeScrollView

- (instancetype)init {
    if (self = [super init]) {
        [self setDelaysContentTouches:NO];
        [self setCanCancelContentTouches:YES];
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}

@end




@interface TWHomeViewController () <TWKeypadDelegate>
{
    UIButton*                       _ioButton;
    UIButton*                       _viewSequencerButton;
    UIButton*                       _viewDrumPadButton;
    UIButton*                       _resetPhaseButton;
    
    TWMixerView*                    _mixerView;
    
    TWHomeScrollView*               _verticalScrollView;
    
    TWOscView*                      _oscView;
    
    TWFrequencyRatioControlView*    _pitchRatioControlView;
    
    UIButton*                       _loadFreqChartButton;
    UIButton*                       _saveProjectButton;
    UIButton*                       _loadProjectButton;
    
    UISlider*                       _masterLeftSlider;
    UIButton*                       _masterLeftField;
    UISlider*                       _masterRightSlider;
    UIButton*                       _masterRightField;
    
    NSTimer*                        _levelMeterTimer;
    TWLevelMeterView*               _leftLevelMeterView;
    TWLevelMeterView*               _rightLevelMeterView;
}

@end

@implementation TWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ioButton = [[UIButton alloc] init];
    [_ioButton setTitle:@"Start Audio I/O" forState:UIControlStateNormal];
    [_ioButton setTitle:@"Stop Audio I/O" forState:UIControlStateSelected];
    [_ioButton setBackgroundColor:[UIColor colorWithWhite:0.06 alpha:1.0]];
    [_ioButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_ioButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_ioButton addTarget:self action:@selector(ioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_ioButton];
    
    _viewSequencerButton = [[UIButton alloc] init];
    [_viewSequencerButton setTitle:@"Sequencer >" forState:UIControlStateNormal];
    [_viewSequencerButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    [_viewSequencerButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_viewSequencerButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_viewSequencerButton addTarget:self action:@selector(viewSequencerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_viewSequencerButton];
    
    _viewDrumPadButton = [[UIButton alloc] init];
    [_viewDrumPadButton setTitle:@"Drum Pad >" forState:UIControlStateNormal];
    [_viewDrumPadButton setBackgroundColor:[UIColor colorWithWhite:0.13 alpha:1.0]];
    [_viewDrumPadButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_viewDrumPadButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_viewDrumPadButton addTarget:self action:@selector(viewDrumPadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_viewDrumPadButton];
    
    
    _mixerView = [[TWMixerView alloc] init];
    [self.view addSubview:_mixerView];
    
    
    
    _verticalScrollView = [[TWHomeScrollView alloc] init];
    [_verticalScrollView setScrollsToTop:NO];
    [_verticalScrollView setBounces:YES];
    [_verticalScrollView setShowsVerticalScrollIndicator:NO];
//    [_verticalScrollView setDelaysContentTouches:YES];
    [_verticalScrollView setBackgroundColor:[UIColor colorWithWhite:0.26f alpha:1.0f]];
    [self.view addSubview:_verticalScrollView];
    
    
    // Enter Vertical Scroll View
    
     _pitchRatioControlView = [[TWFrequencyRatioControlView alloc] init];
    [_verticalScrollView addSubview:_pitchRatioControlView];
    
    _oscView = [[TWOscView alloc] init];
    [_verticalScrollView addSubview:_oscView];
    [_mixerView setOscView:_oscView];
    [_pitchRatioControlView setOscView:_oscView];
    
    
    _loadFreqChartButton = [[UIButton alloc] init];
    [_loadFreqChartButton setTitle:@"Freq Charts >" forState:UIControlStateNormal];
    [_loadFreqChartButton setBackgroundColor:[UIColor colorWithWhite:0.13 alpha:1.0]];
    [_loadFreqChartButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_loadFreqChartButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_loadFreqChartButton addTarget:self action:@selector(loadFreqChartButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_verticalScrollView addSubview:_loadFreqChartButton];
    
    _saveProjectButton = [[UIButton alloc] init];
    [_saveProjectButton setTitle:@"Save" forState:UIControlStateNormal];
    [_saveProjectButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0]];
    [_saveProjectButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_saveProjectButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_saveProjectButton addTarget:self action:@selector(saveProjectButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_saveProjectButton addTarget:self action:@selector(saveProjectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_verticalScrollView addSubview:_saveProjectButton];
    
    _loadProjectButton = [[UIButton alloc] init];
    [_loadProjectButton setTitle:@"Load >" forState:UIControlStateNormal];
    [_loadProjectButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    [_loadProjectButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_loadProjectButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_loadProjectButton addTarget:self action:@selector(loadProjectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_verticalScrollView addSubview:_loadProjectButton];
    
    _resetPhaseButton = [[UIButton alloc] init];
    [_resetPhaseButton setTitle:@"Reset Phase" forState:UIControlStateNormal];
    [_resetPhaseButton setBackgroundColor:[UIColor colorWithWhite:0.14 alpha:1.0]];
    [_resetPhaseButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_resetPhaseButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_resetPhaseButton addTarget:self action:@selector(resetButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_resetPhaseButton addTarget:self action:@selector(resetButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [_verticalScrollView addSubview:_resetPhaseButton];
    
    
    // Exit Vertical Scroll View
    
    
    
    
    
    // Master Gain
    
    _masterLeftField = [[UIButton alloc] init];
    [_masterLeftField setTitleColor:[UIColor valueTextDarkWhiteColor] forState:UIControlStateNormal];
    [_masterLeftField.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [_masterLeftField setBackgroundColor:[UIColor clearColor]];
    [_masterLeftField addTarget:self action:@selector(masterLeftFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_masterLeftField];
    
    _masterLeftSlider = [[UISlider alloc] init];
    [_masterLeftSlider setMinimumValue:0.0f];
    [_masterLeftSlider setMaximumValue:1.0f];
    [_masterLeftSlider addTarget:self action:@selector(masterLeftSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_masterLeftSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_masterLeftSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_masterLeftSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self.view addSubview:_masterLeftSlider];
    
    _masterRightSlider = [[UISlider alloc] init];
    [_masterRightSlider setMinimumValue:0.0f];
    [_masterRightSlider setMaximumValue:1.0f];
    [_masterRightSlider addTarget:self action:@selector(masterRightSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_masterRightSlider setMinimumTrackTintColor:[UIColor sliderOnColor]];
    [_masterRightSlider setMaximumTrackTintColor:[UIColor sliderOffColor]];
    [_masterRightSlider setThumbTintColor:[UIColor sliderOnColor]];
    [self.view addSubview:_masterRightSlider];
    
    _masterRightField = [[UIButton alloc] init];
    [_masterRightField setTitleColor:[UIColor valueTextDarkWhiteColor] forState:UIControlStateNormal];
    [_masterRightField.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [_masterRightField setBackgroundColor:[UIColor clearColor]];
    [_masterRightField addTarget:self action:@selector(masterRightFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_masterRightField];
    
    
    // Level Meters
    _leftLevelMeterView = [[TWLevelMeterView alloc] init];
    [_leftLevelMeterView setUserInteractionEnabled:NO];
    [self.view addSubview:_leftLevelMeterView];
    
    _rightLevelMeterView = [[TWLevelMeterView alloc] init];
    [_rightLevelMeterView setUserInteractionEnabled:NO];
    [self.view addSubview:_rightLevelMeterView];
    
    [self startLevelMeterTimer];
    
    [[TWKeypad sharedKeypad] addToDelegates:self];
    [self.view addSubview:[TWKeypad sharedKeypad]];
    
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}


- (void)viewDidLayoutSubviews {
    
    // Layout UI
    CGFloat xMargin         = self.view.safeAreaInsets.left;
    CGFloat yPos            = self.view.safeAreaInsets.top;
    CGFloat xPos            = xMargin;
    
    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    CGFloat titleButtonWidth = screenWidth / 3.0f;
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    
    
    // Row 1
    [_ioButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_viewSequencerButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_viewDrumPadButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    
    
    // Mixer
    xPos = xMargin;
    yPos += componentHeight;
    CGFloat mixerHeight = isLandscape ? (componentHeight * kNumSources / 4.0f) : (componentHeight * kNumSources / 2.0f);
    [_mixerView setFrame:CGRectMake(xMargin, yPos, screenWidth, mixerHeight)];
    
    
    // Vertical Scroll View
    yPos += _mixerView.frame.size.height;
    CGFloat scrollViewHeight = screenHeight - yPos - componentHeight;
    [_verticalScrollView setFrame:CGRectMake(xMargin, yPos, screenWidth, scrollViewHeight)];
    
    CGFloat scrollViewContentHeight = isLandscape ? (3.0f * kButtonYMargin) + (((kNumSources / 4.0f) + 14.0f) * componentHeight) : (4.0f * kButtonYMargin) + (((kNumSources / 2.0f) + 14.0f) * componentHeight);
    [_verticalScrollView setContentSize:CGSizeMake(screenWidth, scrollViewContentHeight)];
    
    
    // Enter Vertical Scroll View
    yPos = 0.0f;
    CGFloat pitchRatioControlViewHeight = isLandscape ? ((3.0f * kButtonYMargin) + (componentHeight * ((kNumSources / 4.0f) + 3))) : ((4.0f * kButtonYMargin) + (componentHeight * ((kNumSources / 2.0f) + 3)));
    [_pitchRatioControlView setFrame:CGRectMake(0.0f, yPos, screenWidth, pitchRatioControlViewHeight)];
    
    yPos += _pitchRatioControlView.frame.size.height;
    xPos = 0.0f;
    CGFloat oscViewHeight = componentHeight * 10.0f;
    [_oscView setFrame:CGRectMake(xPos, yPos, screenWidth, oscViewHeight)];
    
    
    titleButtonWidth = screenWidth / 4.0f;
    xPos = 0.0f;
    yPos = _verticalScrollView.contentSize.height - componentHeight;
    [_loadFreqChartButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_saveProjectButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_loadProjectButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_resetPhaseButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    // Exit Vertical Scroll View
    
    
    
    
    // Master Gain
    CGFloat sliderWidth = (screenWidth - (2.0f * kValueLabelWidth)) / 2.0f;
    yPos = screenHeight - componentHeight;
    xPos = xMargin;
    [_masterLeftField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    xPos += _masterLeftField.frame.size.width;
    [_masterLeftSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += _masterLeftSlider.frame.size.width;
    [_masterRightSlider setFrame:CGRectMake(xPos, yPos, sliderWidth, componentHeight)];
    xPos += _masterRightSlider.frame.size.width;
    [_masterRightField setFrame:CGRectMake(xPos, yPos, kValueLabelWidth, componentHeight)];
    
    [_leftLevelMeterView setFrame:_masterLeftSlider.frame];
    [_rightLevelMeterView setFrame:_masterRightSlider.frame];
    
    
    CGFloat keypadHeight = 3.5f * componentHeight;
    CGRect keypadHideFrame = CGRectMake(0.0f, screenHeight, screenWidth, keypadHeight);
    [[TWKeypad sharedKeypad] setFrame:keypadHideFrame];
    [[TWKeypad sharedKeypad] setHideFrame:keypadHideFrame];
    [[TWKeypad sharedKeypad] setShowFrame:CGRectMake(keypadHideFrame.origin.x, keypadHideFrame.origin.y - keypadHeight, keypadHideFrame.size.width, keypadHideFrame.size.height)];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
//    [_oscView setOscID:0];
    
    [self updateIOButtonState:[[TWAudioController sharedController] isRunning]];
    
    [_mixerView viewWillAppear:animated];
    [_pitchRatioControlView viewWillAppear:animated];
    
    CGFloat masterLeftGain = [[TWAudioController sharedController] getMasterGainOnChannel:kLeftChannel];
    [_masterLeftSlider setValue:masterLeftGain animated:animated];
    [_masterLeftField setTitle:[NSString stringWithFormat:@"%.2f", masterLeftGain] forState:UIControlStateNormal];

    CGFloat masterRightGain = [[TWAudioController sharedController] getMasterGainOnChannel:kRightChannel];
    [_masterRightSlider setValue:masterRightGain animated:animated];
    [_masterRightField setTitle:[NSString stringWithFormat:@"%.2f", masterRightGain] forState:UIControlStateNormal];
}


- (void)willEnterForeground {
    [self startLevelMeterTimer];
    [self updateIOButtonState:[[TWMasterController sharedController] isAudioRunning]];
}

- (void)willEnterBackground {
    [self stopLevelMeterTimer];
}



#pragma mark - UI


- (void)ioButtonTapped:(UIButton*)sender {
    
    if ([sender isSelected]) {
        [[TWAudioController sharedController] stop];
        [self updateIOButtonState:NO];
    } else {
        [[TWAudioController sharedController] start];
        [self updateIOButtonState:YES];
    }
}


- (void)resetButtonTouchDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
}

- (void)resetButtonTouchUp:(UIButton*)sender {
    [[TWAudioController sharedController] resetPhaseInSamples:100];
    [sender setBackgroundColor:[UIColor colorWithWhite:0.14 alpha:1.0]];
}


- (void)masterLeftSliderValueChanged:(UISlider*)sender {
    float gain = sender.value;
    [[TWAudioController sharedController] setMasterGain:gain onChannel:kLeftChannel inTime:kDefaultRampTime_ms];
    [_masterLeftField setTitle:[NSString stringWithFormat:@"%.2f", gain] forState:UIControlStateNormal];
}

- (void)masterRightSliderValueChanged:(UISlider*)sender {
    float gain = sender.value;
    [[TWAudioController sharedController] setMasterGain:gain onChannel:kRightChannel inTime:kDefaultRampTime_ms];
    [_masterRightField setTitle:[NSString stringWithFormat:@"%.2f", gain] forState:UIControlStateNormal];
}




- (void)saveProjectButtonTouchDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorWithWhite:0.24f alpha:1.0f]];
}

- (void)saveProjectButtonTapped:(UIButton*)sender {
    [self launchSaveProjectDialog];
    [sender setBackgroundColor:[UIColor colorWithWhite:0.09 alpha:1.0]];
}

- (void)loadProjectButtonTapped:(UIButton*)sender {
    [self.navigationController pushViewController:[[TWLoadProjectViewController alloc] init] animated:YES];
}

- (void)loadFreqChartButtonTapped:(UIButton*)sender {
    [self.navigationController pushViewController:[[TWFrequencyChartViewController alloc] init] animated:YES];
}

- (void)viewSequencerButtonTapped:(UIButton*)sender {
    TWSequencerViewController* vc = [[TWSequencerViewController alloc] init];
    [vc setOscView:_oscView];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDrumPadButtonTapped:(UIButton*)sender {
    TWDrumPadViewController* vc = [[TWDrumPadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}




#pragma mark - Internal

- (void)updateIOButtonState:(BOOL)selected {
    if (selected) {
        [_ioButton setSelected:YES];
        [_ioButton setBackgroundColor:[UIColor colorWithWhite:0.14 alpha:1.0]];
    } else {
        [_ioButton setSelected:NO];
        [_ioButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0]];
    }
}





#pragma mark - Project Stuff


- (void)saveProject:(NSString*)name {
    if (![[TWMasterController sharedController] saveProjectWithFilename:name]) {
        [self launchError:@"Could not save project :("];
    }
}

- (void)launchSaveProjectDialog {
    
    NSString* message = @"Save settings as ...";
    UIAlertController* saveDialog = [UIAlertController alertControllerWithTitle:@"Save Project?"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSString* text = saveDialog.textFields.firstObject.text;
                                                           if ([self isExistingProjectName:text]) {
                                                               [self launchOverwriteConfirmation:text];
                                                           } else {
                                                               [self saveProject:text];
                                                           }
                                                       }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    
    [saveDialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setClearButtonMode:UITextFieldViewModeAlways];
        [textField setText:[[TWMasterController sharedController] projectName]];
        [textField selectAll:nil];
    }];
    [saveDialog addAction:saveAction];
    [saveDialog addAction:cancelAction];
    
    [self presentViewController:saveDialog animated:YES completion:nil];
}


- (BOOL)isExistingProjectName:(NSString*)name {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* projectsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Projects"];
    NSString* filepath = [projectsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", name]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        return YES;
    }
    return NO;
}

- (void)launchOverwriteConfirmation:(NSString*)name {
    NSString* message = [NSString stringWithFormat:@"Project '%@' already exists", name];
    UIAlertController* confirmDialog = [UIAlertController alertControllerWithTitle:@"Confirm Overwrite?"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self saveProject:name];
                                                       }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    [confirmDialog addAction:saveAction];
    [confirmDialog addAction:cancelAction];
    
    [self presentViewController:confirmDialog animated:YES completion:nil];
}



- (void)launchError:(NSString*)message {
    
    UIAlertController* dialog = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [dialog addAction:okAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
}




#pragma mark - Level Meters

- (void)updateLevelMeter {
    float leftLevel = [[TWAudioController sharedController] getRMSLevelAtChannel:kLeftChannel];
    float rightLevel = [[TWAudioController sharedController] getRMSLevelAtChannel:kRightChannel];
    [_leftLevelMeterView setLevel:leftLevel];
    [_rightLevelMeterView setLevel:rightLevel];
}


- (void)startLevelMeterTimer {
    if (!_levelMeterTimer) {
        _levelMeterTimer = [NSTimer scheduledTimerWithTimeInterval:(kDefaultRMSLevelWindow_ms / 1000.0f)
                                                            target:self
                                                          selector:@selector(updateLevelMeter)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}

- (void)stopLevelMeterTimer {
    if ([_levelMeterTimer isValid]) {
        [_levelMeterTimer invalidate];
    }
    _levelMeterTimer = nil;
}




#pragma mark - TWKeypad

- (void)keypadDoneButtonTapped:(UIButton *)responder withValue:(NSString *)value {
    
    if (responder == _masterLeftField) {
        float gain = [value floatValue];
        [[TWAudioController sharedController] setMasterGain:gain onChannel:kLeftChannel inTime:kDefaultRampTime_ms];
        [_masterLeftField setTitle:[NSString stringWithFormat:@"%.2f", gain] forState:UIControlStateNormal];
        [_masterLeftSlider setValue:gain animated:YES];
    }
    
    else if (responder == _masterRightField) {
        float gain = [value floatValue];
        [[TWAudioController sharedController] setMasterGain:gain onChannel:kRightChannel inTime:kDefaultRampTime_ms];
        [_masterRightField setTitle:[NSString stringWithFormat:@"%.2f", gain] forState:UIControlStateNormal];
        [_masterRightSlider setValue:gain animated:YES];
    }
}


- (void)keypadCancelButtonTapped:(UIButton*)responder {
    
    if (responder == _masterLeftField) {
        float gain = [[TWAudioController sharedController] getMasterGainOnChannel:kLeftChannel];
        [_masterLeftField setTitle:[NSString stringWithFormat:@"%.2f", gain] forState:UIControlStateNormal];
    }
    
    else if (responder == _masterRightField) {
        float gain = [[TWAudioController sharedController] getMasterGainOnChannel:kRightChannel];
        [_masterRightField setTitle:[NSString stringWithFormat:@"%.2f", gain] forState:UIControlStateNormal];
    }
}


#pragma mark - Button Keypad Fields

- (void)masterLeftFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Left Master: "];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getMasterGainOnChannel:kLeftChannel]]];
    [keypad setCurrentResponder:_masterLeftField];
}

- (void)masterRightFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Right Master: "];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getMasterGainOnChannel:kRightChannel]]];
    [keypad setCurrentResponder:_masterRightField];
}


@end

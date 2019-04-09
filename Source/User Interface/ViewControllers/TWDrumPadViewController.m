//
//  TWDrumPadViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/22/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWDrumPadViewController.h"
#import "TWDrumPad.h"
#import "TWFillSlider.h"
#import "TWHeader.h"
#import "TWCycleStateButton.h"
#import "TWAudioController.h"

@interface TWDrumPadViewController ()
{
    UIButton*                   _backButton;
    UIButton*                   _ioButton;
    UIButton*                   _loadProjectButton;
    
//    UIView*                     _testView;
    
    NSArray*                    _drumPads;
    NSArray*                    _velocitySliders;
    NSArray*                    _drumPadModeButtons;
    NSArray*                    _playbackDirectionButtons;
    NSArray*                    _loadAudioFileButtons;
    
    UIButton*                   _toggleVelocityButton;
    UIButton*                   _toggleDrumPadModeButton;
    UIButton*                   _togglePlaybackDirectionButton;
    UIButton*                   _toggleLoadAudioFileButton;
    
    UIButton*                   _editingAllButton;
    BOOL                        _editingAllToggle;
    
    int                         _debugCount;
}
@end

@implementation TWDrumPadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _backButton = [[UIButton alloc] init];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor colorWithWhite:0.06 alpha:1.0f]];
    [_backButton setTitleColor:[UIColor colorWithWhite:0.4f alpha:1.0f] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    _ioButton = [[UIButton alloc] init];
    [_ioButton setTitle:@"Start Audio I/O" forState:UIControlStateNormal];
    [_ioButton setTitle:@"Stop Audio I/O" forState:UIControlStateSelected];
    [_ioButton setBackgroundColor:[UIColor colorWithWhite:0.06 alpha:1.0]];
    [_ioButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_ioButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_ioButton addTarget:self action:@selector(ioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_ioButton];
    
    _loadProjectButton = [[UIButton alloc] init];
    [_loadProjectButton setTitle:@"Load >" forState:UIControlStateNormal];
    [_loadProjectButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
    [_loadProjectButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_loadProjectButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_loadProjectButton addTarget:self action:@selector(loadProjectButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_loadProjectButton addTarget:self action:@selector(loadProjectButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loadProjectButton];
    
//    _testView = [[UIView alloc] init];
//    [_testView setBackgroundColor:[UIColor yellowColor]];
//    [_testView setUserInteractionEnabled:NO];
//    [self.view addSubview:_testView];
    
    NSArray<NSString*>* drumPadModeTitles = @[@"1-Shot", @"Momentary", @"Toggle"];
    NSArray<UIColor*>* drumPadModeColors = @[[UIColor colorWithRed:0.4f green:0.2f blue:0.2f alpha:0.7f],
                                             [UIColor colorWithRed:0.2f green:0.32f blue:0.2f alpha:0.7f],
                                             [UIColor colorWithRed:0.2f green:0.2f blue:0.46f alpha:0.7f]];
    
    NSArray<NSString*>* playbackDirectionTitles = @[@"Forward", @"Reverse"];
    NSArray<UIColor*>* playbackDirectionColors = @[[UIColor colorWithRed:0.3f green:0.2f blue:0.1f alpha:0.7f],
                                             [UIColor colorWithRed:0.1f green:0.2f blue:0.3f alpha:0.7f]];
    
    
    NSMutableArray* drumPads = [[NSMutableArray alloc] init];
    NSMutableArray* velocitySliders = [[NSMutableArray alloc] init];
    NSMutableArray* drumPadModeButtons = [[NSMutableArray alloc] init];
    NSMutableArray* playbackDirectionButtons = [[NSMutableArray alloc] init];
    NSMutableArray* loadAudioFileButtons = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumSources; i++) {
        TWDrumPad* drumPad = [[TWDrumPad alloc] init];
        [drumPad setTag:i];
        [drumPad setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
        [drumPad setOnColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.9f alpha:0.9f]];
        [self.view addSubview:drumPad];
        [drumPads addObject:drumPad];
        
        TWFillSlider* velocitySlider = [[TWFillSlider alloc] init];
        [velocitySlider setTag:i];
        [velocitySlider addTarget:self action:@selector(velocitySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [velocitySlider setOnTrackColor:[UIColor colorWithRed:0.2 green:0.5 blue:0.2 alpha:0.5]];
        [velocitySlider setHidden:YES];
        [self.view addSubview:velocitySlider];
        [velocitySliders addObject:velocitySlider];
        
        TWCycleStateButton* drumPadModeButton = [[TWCycleStateButton alloc] initWithNumberOfStates:TWDrumPadMode_NumModes];
        [drumPadModeButton setTag:i];
        [drumPadModeButton setStateColors:drumPadModeColors];
        [drumPadModeButton setStateTitles:drumPadModeTitles];
        [drumPadModeButton setTitleColor:[UIColor colorWithWhite:0.06f alpha:1.0f] forState:UIControlStateNormal];
        [[drumPadModeButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [drumPadModeButton addTarget:self action:@selector(drumPadModeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [drumPadModeButton setHidden:YES];
        [self.view addSubview:drumPadModeButton];
        [drumPadModeButtons addObject:drumPadModeButton];
        
        TWCycleStateButton* playbackDirectionButton = [[TWCycleStateButton alloc] initWithNumberOfStates:2];
        [playbackDirectionButton setTag:i];
        [playbackDirectionButton setStateColors:playbackDirectionColors];
        [playbackDirectionButton setStateTitles:playbackDirectionTitles];
        [playbackDirectionButton setTitleColor:[UIColor colorWithWhite:0.06f alpha:1.0f] forState:UIControlStateNormal];
        [[playbackDirectionButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [playbackDirectionButton addTarget:self action:@selector(playbackDirectionChanged:) forControlEvents:UIControlEventTouchUpInside];
        [playbackDirectionButton setHidden:YES];
        [self.view addSubview:playbackDirectionButton];
        [playbackDirectionButtons addObject:playbackDirectionButton];
        
        UIButton* loadAudioFileButton = [[UIButton alloc] init];
        [loadAudioFileButton setTag:i];
        [loadAudioFileButton setTitleColor:[UIColor colorWithWhite:0.06f alpha:1.0f] forState:UIControlStateNormal];
        [[loadAudioFileButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [loadAudioFileButton setBackgroundColor:[UIColor colorWithRed:0.4 green:0.2f blue:0.6f alpha:0.4f]];
        [loadAudioFileButton addTarget:self action:@selector(loadAudioFileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [loadAudioFileButton setHidden:YES];
        [self.view addSubview:loadAudioFileButton];
        [loadAudioFileButtons addObject:loadAudioFileButton];
    }
    _drumPads = [[NSArray alloc] initWithArray:drumPads];
    _velocitySliders = [[NSArray alloc] initWithArray:velocitySliders];
    _drumPadModeButtons = [[NSArray alloc] initWithArray:drumPadModeButtons];
    _playbackDirectionButtons = [[NSArray alloc] initWithArray:playbackDirectionButtons];
    _loadAudioFileButtons = [[NSArray alloc] initWithArray:loadAudioFileButtons];
    
    
    _toggleVelocityButton = [[UIButton alloc] init];
    [_toggleVelocityButton setTitle:@"Velocity" forState:UIControlStateNormal];
    [_toggleVelocityButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
    [_toggleVelocityButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:0.8f] forState:UIControlStateNormal];
    [[_toggleVelocityButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [_toggleVelocityButton addTarget:self action:@selector(toggleVelocityButtonDown:) forControlEvents:UIControlEventTouchDown];
    [_toggleVelocityButton addTarget:self action:@selector(toggleVelocityButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toggleVelocityButton];
    
    _toggleDrumPadModeButton = [[UIButton alloc] init];
    [_toggleDrumPadModeButton setTitle:@"Pad Mode" forState:UIControlStateNormal];
    [_toggleDrumPadModeButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
    [_toggleDrumPadModeButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:0.8f] forState:UIControlStateNormal];
    [[_toggleDrumPadModeButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [_toggleDrumPadModeButton addTarget:self action:@selector(toggleDrumPadModeDown:) forControlEvents:UIControlEventTouchDown];
    [_toggleDrumPadModeButton addTarget:self action:@selector(toggleDrumPadModeUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toggleDrumPadModeButton];
    
    _togglePlaybackDirectionButton = [[UIButton alloc] init];
    [_togglePlaybackDirectionButton setTitle:@"Direction" forState:UIControlStateNormal];
    [_togglePlaybackDirectionButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
    [_togglePlaybackDirectionButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:0.8f] forState:UIControlStateNormal];
    [[_togglePlaybackDirectionButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [_togglePlaybackDirectionButton addTarget:self action:@selector(togglePlaybackDirectionDown:) forControlEvents:UIControlEventTouchDown];
    [_togglePlaybackDirectionButton addTarget:self action:@selector(togglePlaybackDirectionUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_togglePlaybackDirectionButton];
    
    _toggleLoadAudioFileButton = [[UIButton alloc] init];
    [_toggleLoadAudioFileButton setTitle:@"Load File" forState:UIControlStateNormal];
    [_toggleLoadAudioFileButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
    [_toggleLoadAudioFileButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:0.8f] forState:UIControlStateNormal];
    [[_toggleLoadAudioFileButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [_toggleLoadAudioFileButton addTarget:self action:@selector(toggleLoadAudioFileDown:) forControlEvents:UIControlEventTouchDown];
    [_toggleLoadAudioFileButton addTarget:self action:@selector(toggleLoadAudioFileUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toggleLoadAudioFileButton];
    
    _editingAllButton = [[UIButton alloc] init];
    [_editingAllButton setTitle:@"Edit All" forState:UIControlStateNormal];
    [_editingAllButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
    [_editingAllButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:0.8f] forState:UIControlStateNormal];
    [[_editingAllButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [_editingAllButton addTarget:self action:@selector(editingAllButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_editingAllButton addTarget:self action:@selector(editingAllButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editingAllButton];
    _editingAllToggle = NO;
    
    [[TWAudioController sharedController] setPlaybackFinishedBlock:^(int sourceIdx, int status) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            TWDrumPad* drumPad = [self->_drumPads objectAtIndex:sourceIdx];
            [drumPad playbackStopped:status];
        });
    }];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
    
    _debugCount = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    for (int i=0; i < kNumSources; i++) {
        TWDrumPad* drumPad = (TWDrumPad*)[_drumPads objectAtIndex:i];
        [drumPad viewWillAppear];
        [drumPad setFileTitleText:[[TWAudioController sharedController] getAudioFileTitleAtSourceIdx:i]];
        
        TWFillSlider* velocitySlider = (TWFillSlider*)[_velocitySliders objectAtIndex:i];
        [velocitySlider setValue:[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_MaxVolume atSourceIdx:i]];
        
        TWCycleStateButton* drumPadModeButton = (TWCycleStateButton*)[_drumPadModeButtons objectAtIndex:i];
        TWDrumPadMode currentMode = (TWDrumPadMode)[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_DrumPadMode atSourceIdx:i];
        [drumPadModeButton setCurrentState:(NSUInteger)currentMode];
        [drumPad setDrumPadMode:currentMode];
        
        TWCycleStateButton* playbackDirectionButton = (TWCycleStateButton*)[_playbackDirectionButtons objectAtIndex:i];
        TWPlaybackDirection direction = (TWPlaybackDirection)[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_PlaybackDirection atSourceIdx:i];
        [playbackDirectionButton setCurrentState:(NSUInteger)direction];
    }
    
    [self updateIOButtonState:[[TWAudioController sharedController] isRunning]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (TWDrumPad* drumPad in _drumPads) {
        [drumPad viewDidAppear];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (TWDrumPad* drumPad in _drumPads) {
        [drumPad viewWillDisappear];
    }
}

- (void)viewDidLayoutSubviews {
    
    // Layout UI
    CGFloat xMargin         = self.view.safeAreaInsets.left;
    CGFloat yMargin         = self.view.safeAreaInsets.top;
    CGFloat yPos            = yMargin;
    CGFloat xPos            = xMargin;
    
    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    
    CGFloat titleButtonWidth = screenWidth / 3.0f;
    
    [_backButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_ioButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_loadProjectButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    yPos += componentHeight;
    
    CGFloat padPadRatio = 0.1f;
    CGFloat padSize = 0.0f;
    CGFloat padPad = 0.0f;
    
    if (isLandscape) {
        padSize = (screenHeight - yPos) / (4.0 + (5.0f * padPadRatio));
    } else {
        padSize = (screenWidth - xMargin) / (4.0 + (5.0f * padPadRatio));
    }
    
    padPad = padPadRatio * padSize;
    yPos = yMargin + componentHeight + (4.0f * padPad) + (3.0f * padSize);
    xPos = xMargin + padPad;
    
    for (int i=0; i < kNumSources; i++) {
//        int row = (int)(i / 4);
        int column = i % 4;
        
        TWDrumPad* pad = [_drumPads objectAtIndex:i];
        [pad setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        TWFillSlider* velocitySlider = (TWFillSlider*)[_velocitySliders objectAtIndex:i];
        [velocitySlider setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        TWCycleStateButton* drumPadModeButton = (TWCycleStateButton*)[_drumPadModeButtons objectAtIndex:i];
        [drumPadModeButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        TWCycleStateButton* playbackDirectionButton = (TWCycleStateButton*)[_playbackDirectionButtons objectAtIndex:i];
        [playbackDirectionButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        UIButton* loadAudioFileButton = (UIButton*)[_loadAudioFileButtons objectAtIndex:i];
        [loadAudioFileButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        xPos += padSize + padPad;
        if (column == 3) {
            yPos -= padSize + padPad;
            xPos = xMargin + padPad;
        }
    }
    
    
    //----- Options / Properties Buttons ---//
    
    CGFloat optionsButtonHeight = 0.0f;
    CGFloat optionsButtonWidth = 0.0f;
    
    if (isLandscape) {
        optionsButtonHeight = padSize;
        optionsButtonWidth = (screenWidth - (4.0 * padSize) - (7.0f * padPad)) / 2.0f;
        if (optionsButtonWidth > padSize) {
            optionsButtonWidth = padSize;
        }
        
        xPos = xMargin + (4.0 * padSize) + (5.0f * padPad);
        yPos = yMargin + componentHeight + padPad;
        [_toggleVelocityButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        yPos += padPad + optionsButtonHeight;
        [_toggleDrumPadModeButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        yPos += padPad + optionsButtonHeight;
        [_togglePlaybackDirectionButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        yPos += padPad + optionsButtonHeight;
        [_toggleLoadAudioFileButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        xPos += padPad + optionsButtonWidth;
        yPos = yMargin + componentHeight + padPad;
        [_editingAllButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
    } else {
        optionsButtonHeight = (screenHeight - yMargin - componentHeight - (4.0 * padSize) - (7.0f * padPad)) / 2.0f;
        if (optionsButtonHeight > padSize) {
            optionsButtonHeight = padSize;
        }
        optionsButtonWidth = padSize;
        
        xPos = xMargin + padPad;
        yPos = yMargin + componentHeight + (4.0 * padSize) + (5.0 * padPad);
        [_toggleVelocityButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        xPos += optionsButtonWidth + padPad;
        [_toggleDrumPadModeButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        xPos += optionsButtonWidth + padPad;
        [_togglePlaybackDirectionButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        xPos += optionsButtonWidth + padPad;
        [_toggleLoadAudioFileButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
        
        xPos = xMargin + padPad;
        yPos += padPad + optionsButtonHeight;
        [_editingAllButton setFrame:CGRectMake(xPos, yPos, optionsButtonWidth, optionsButtonHeight)];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UI

- (void)backButtonTapped:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ioButtonTapped:(UIButton*)sender {
    if ([sender isSelected]) {
        [[TWAudioController sharedController] stop];
        [self updateIOButtonState:NO];
    } else {
        [[TWAudioController sharedController] start];
        [self updateIOButtonState:YES];
    }
}


- (void)loadProjectButtonDown:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0f]];
}

- (void)loadProjectButtonUp:(UIButton*)sender {
    [self testInit];
    [sender setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
}



//===== Velocity =====//

- (void)velocitySliderValueChanged:(TWFillSlider*)sender {
    if (_editingAllToggle) {
        for (TWFillSlider* velocitySlider in _velocitySliders) {
            if (velocitySlider != sender) {
                [velocitySlider setValue:sender.value];
                [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_MaxVolume withValue:sender.value atSourceIdx:(int)velocitySlider.tag inTime:0.0f];
            }
        }
    }
    [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_MaxVolume withValue:sender.value atSourceIdx:(int)sender.tag inTime:0.0f];
}

- (void)toggleVelocityButtonDown:(UIButton*)sender {
    for (TWFillSlider* velocitySlider in _velocitySliders) {
        [velocitySlider setHidden:NO];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
}

- (void)toggleVelocityButtonUp:(UIButton*)sender {
    for (TWFillSlider* velocitySlider in _velocitySliders) {
        [velocitySlider setHidden:YES];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
}



//===== Drum Pad Mode =====//

- (void)toggleDrumPadModeDown:(UIButton*)sender {
    for (TWCycleStateButton* drumPadModeButton in _drumPadModeButtons) {
        [drumPadModeButton setHidden:NO];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
}

- (void)toggleDrumPadModeUp:(UIButton*)sender {
    for (TWCycleStateButton* drumPadModeButton in _drumPadModeButtons) {
        [drumPadModeButton setHidden:YES];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
}

- (void)drumPadModeChanged:(TWCycleStateButton*)sender {
    
    [sender incrementState];
    NSUInteger currentState = [sender currentState];
    
    [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_DrumPadMode withValue:(float)currentState atSourceIdx:(int)sender.tag inTime:0.0f];
    
    TWDrumPad* drumPad = [_drumPads objectAtIndex:sender.tag];
    [drumPad setDrumPadMode:(TWDrumPadMode)currentState];
    
    if (_editingAllToggle) {
        for (TWCycleStateButton* drumPadModeButton in _drumPadModeButtons) {
            if (drumPadModeButton != sender) {
                [drumPadModeButton setCurrentState:currentState];
                [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_DrumPadMode withValue:(float)currentState atSourceIdx:(int)drumPadModeButton.tag inTime:0.0f];
                
                TWDrumPad* drumPad = [_drumPads objectAtIndex:drumPadModeButton.tag];
                [drumPad setDrumPadMode:(TWDrumPadMode)currentState];
            }
        }
    }
}


//--- Playback Direction ---//

- (void)togglePlaybackDirectionDown:(UIButton*)sender {
    for (TWCycleStateButton* playbackDirectionButton in _playbackDirectionButtons) {
        [playbackDirectionButton setHidden:NO];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
}

- (void)togglePlaybackDirectionUp:(UIButton*)sender {
    for (TWCycleStateButton* playbackDirectionButton in _playbackDirectionButtons) {
        [playbackDirectionButton setHidden:YES];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
}

- (void)playbackDirectionChanged:(TWCycleStateButton*)sender {
    [sender incrementState];
    NSUInteger currentState = [sender currentState];
    
    [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_PlaybackDirection withValue:(float)currentState atSourceIdx:(int)sender.tag inTime:0.0f];
    TWDrumPad* drumPad = (TWDrumPad*)[_drumPads objectAtIndex:(int)sender.tag];
    [drumPad setPlaybackDirection:(TWPlaybackDirection)currentState];
    
    if (_editingAllToggle) {
        for (TWCycleStateButton* playbackDirectionButton in _playbackDirectionButtons) {
            if (playbackDirectionButton != sender) {
                [playbackDirectionButton setCurrentState:currentState];
                [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_PlaybackDirection withValue:(float)currentState atSourceIdx:(int)playbackDirectionButton.tag inTime:0.0f];
                
                TWDrumPad* pad = (TWDrumPad*)[_drumPads objectAtIndex:(int)playbackDirectionButton.tag];
                [pad setPlaybackDirection:(TWPlaybackDirection)currentState];
            }
        }
    }
}



//----- Load Audio File -----//

- (void)toggleLoadAudioFileDown:(UIButton*)sender {
    for (UIButton* loadAudioFileButton in _loadAudioFileButtons) {
        [loadAudioFileButton setHidden:NO];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
}

- (void)toggleLoadAudioFileUp:(UIButton*)sender {
    for (UIButton* loadAudioFileButton in _loadAudioFileButtons) {
        [loadAudioFileButton setHidden:YES];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0]];
}

- (void)loadAudioFileButtonTapped:(UIButton*)sender {
    
}

//===== All Button =====//
- (void)editingAllButtonTouchDown:(UIButton*)sender {
    _editingAllToggle = YES;
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0f]];
}
- (void)editingAllButtonTouchUp:(UIButton*)sender {
    _editingAllToggle = NO;
    [sender setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
}


#pragma mark - Private

- (void)testInit {
    
//    NSString* string;
//
//    switch (_debugCount) {
//        case 0:
//            string = @"Embryo Synth";
//            break;
//
//        case 1:
//            string = @"LRTest";
//            break;
//
//        case 2:
//            string = @"TestKick";
//            break;
//
//        default:
//            break;
//    }
//
//    NSString* sampleURL = [[NSBundle mainBundle] pathForResource:string ofType:@"wav"];
//    NSString* outSampleURL = [sampleURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    if (sampleURL != nil) {
//        [[TWAudioController sharedController] loadAudioFile:outSampleURL atSourceIdx:0];
//    } else {
//        NSLog(@"Error! SampleURL is nil!");
//    }
//
//    _debugCount = (_debugCount + 1) % 3;
    
//    TWDrumPad* drumPad = (TWDrumPad*)[_drumPads objectAtIndex:0];
//    [drumPad setLengthInSeconds:[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_LengthInSeconds atSourceIdx:0]];
    
    
    
    
    NSString* sampleURL1 = [[NSBundle mainBundle] pathForResource:@"Embryo Synth" ofType:@"wav"];
    NSString* outSampleURL1 = [sampleURL1 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (sampleURL1 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL1 atSourceIdx:0];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
    TWDrumPad* drumPad = (TWDrumPad*)[_drumPads objectAtIndex:0];
    [drumPad setLengthInSeconds:[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_LengthInSeconds atSourceIdx:0]];
    [drumPad setFileTitleText:[[TWAudioController sharedController] getAudioFileTitleAtSourceIdx:0]];


    NSString* sampleURL2 = [[NSBundle mainBundle] pathForResource:@"LRTest" ofType:@"wav"];
    NSString* outSampleURL2 = [sampleURL2 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (sampleURL2 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL2 atSourceIdx:1];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
    drumPad = (TWDrumPad*)[_drumPads objectAtIndex:1];
    [drumPad setLengthInSeconds:[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_LengthInSeconds atSourceIdx:1]];
    [drumPad setFileTitleText:[[TWAudioController sharedController] getAudioFileTitleAtSourceIdx:1]];

    
    NSString* sampleURL3 = [[NSBundle mainBundle] pathForResource:@"TestKick" ofType:@"wav"];
    NSString* outSampleURL3 = [sampleURL3 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (sampleURL3 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL3 atSourceIdx:2];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
    drumPad = (TWDrumPad*)[_drumPads objectAtIndex:2];
    [drumPad setLengthInSeconds:[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_LengthInSeconds atSourceIdx:2]];
    [drumPad setFileTitleText:[[TWAudioController sharedController] getAudioFileTitleAtSourceIdx:2]];
}


- (void)updateIOButtonState:(BOOL)selected {
    if (selected) {
        [_ioButton setSelected:YES];
        [_ioButton setBackgroundColor:[UIColor colorWithWhite:0.14 alpha:1.0]];
    } else {
        [_ioButton setSelected:NO];
        [_ioButton setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0]];
    }
}

@end

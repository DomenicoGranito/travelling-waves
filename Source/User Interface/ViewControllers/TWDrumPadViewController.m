//
//  TWDrumPadViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/22/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWDrumPadViewController.h"
#import "TWDrumPad.h"
#import "TWSlider.h"
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
    
    UIButton*                   _toggleVelocityButton;
    UIButton*                   _toggleDrumPadModeButton;
    
    UIButton*                   _editingAllButton;
    BOOL                        _editingAllToggle;
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
    [_loadProjectButton addTarget:self action:@selector(loadProjectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loadProjectButton];
    
//    _testView = [[UIView alloc] init];
//    [_testView setBackgroundColor:[UIColor yellowColor]];
//    [_testView setUserInteractionEnabled:NO];
//    [self.view addSubview:_testView];
    
    NSArray<NSString*>* drumPadModeTitles = @[@"1-Shot", @"Momentary", @"Toggle"];
    NSArray<UIColor*>* drumPadModeColors = @[[UIColor colorWithRed:0.4f green:0.2f blue:0.2f alpha:0.8f],
                                             [UIColor colorWithRed:0.2f green:0.32f blue:0.2f alpha:0.8f],
                                             [UIColor colorWithRed:0.2f green:0.2f blue:0.46f alpha:0.8f]];
    
    NSMutableArray* drumPads = [[NSMutableArray alloc] init];
    NSMutableArray* velocitySliders = [[NSMutableArray alloc] init];
    NSMutableArray* drumPadModeButtons = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumSources; i++) {
        TWDrumPad* drumPad = [[TWDrumPad alloc] init];
        [drumPad setTag:i];
        [drumPad setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
        [drumPad setTitleText:[NSString stringWithFormat:@"%i", i]];
        [drumPad setOnColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.9f alpha:0.9f]];
        [self.view addSubview:drumPad];
        [drumPads addObject:drumPad];
        
        TWSlider* velocitySlider = [[TWSlider alloc] init];
        [velocitySlider setTag:i];
        [velocitySlider addTarget:self action:@selector(velocitySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [velocitySlider setOnTrackColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:0.5]];
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
    }
    _drumPads = [[NSArray alloc] initWithArray:drumPads];
    _velocitySliders = [[NSArray alloc] initWithArray:velocitySliders];
    _drumPadModeButtons = [[NSArray alloc] initWithArray:drumPadModeButtons];
    
    
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
    
    _editingAllButton = [[UIButton alloc] init];
    [_editingAllButton setTitle:@"Edit One" forState:UIControlStateNormal];
    [_editingAllButton setTitle:@"Edit All" forState:UIControlStateSelected];
    [_editingAllButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
    [_editingAllButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:0.8f] forState:UIControlStateNormal];
    [[_editingAllButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [_editingAllButton addTarget:self action:@selector(editingAllButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editingAllButton];
    _editingAllToggle = NO;
    
    [[TWAudioController sharedController] setPlaybackDidEndBlock:^(int sourceIdx) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            TWDrumPad* drumPad = [self->_drumPads objectAtIndex:sourceIdx];
            [drumPad oneShotPlaybackStopped];
        });
    }];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    for (int i=0; i < kNumSources; i++) {
        TWDrumPad* drumPad = (TWDrumPad*)[_drumPads objectAtIndex:i];
        [drumPad viewWillAppear];
        
        TWSlider* velocitySlider = (TWSlider*)[_velocitySliders objectAtIndex:i];
        [velocitySlider setValue:[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_MaxVolume atSourceIdx:i]];
        
        TWCycleStateButton* drumPadModeButton = (TWCycleStateButton*)[_drumPadModeButtons objectAtIndex:i];
        TWDrumPadMode currentMode = (TWDrumPadMode)[[TWAudioController sharedController] getPlaybackParameter:kPlaybackParam_DrumPadMode atSourceIdx:i];
        [drumPadModeButton setCurrentState:(NSUInteger)currentMode];
        [drumPad setDrumPadMode:currentMode];
    }
    
    [self updateIOButtonState:[[TWAudioController sharedController] isRunning]];
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
    yPos += padPad;
    xPos = xMargin + padPad;
    
    for (int i=0; i < kNumSources; i++) {
//        int row = (int)(i / 4);
        int column = i % 4;
        
        TWDrumPad* pad = [_drumPads objectAtIndex:i];
        [pad setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        TWSlider* velocitySlider = (TWSlider*)[_velocitySliders objectAtIndex:i];
        [velocitySlider setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        TWCycleStateButton* drumPadModeButton = (TWCycleStateButton*)[_drumPadModeButtons objectAtIndex:i];
        [drumPadModeButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        xPos += padSize + padPad;
        if (column == 3) {
            yPos += padSize + padPad;
            xPos = xMargin + padPad;
        }
    }
    
    
    if (isLandscape) {
        
        xPos += (4.0 * (padSize + padPad)) + componentHeight;
        yPos = componentHeight + padPad;
        [_toggleVelocityButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        yPos += padPad + padSize;
        [_toggleDrumPadModeButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        xPos += padPad + padSize;
        yPos = componentHeight + padPad;
        [_editingAllButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
    } else {
        
        xPos = xMargin + padPad;
        yPos = yMargin + (2.0f * componentHeight) + (4.0 * padSize) + (5.0 * padPad);
        [_toggleVelocityButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        xPos += padSize + padPad;
        [_toggleDrumPadModeButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        xPos = xMargin + padPad;
        yPos += padPad + padSize;
        [_editingAllButton setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
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

- (void)loadProjectButtonTapped:(UIButton*)sender {
    [self testInit];
}



//===== Velocity =====//

- (void)velocitySliderValueChanged:(TWSlider*)sender {
    if (_editingAllToggle) {
        for (TWSlider* velocitySlider in _velocitySliders) {
            if (velocitySlider != sender) {
                [velocitySlider setValue:sender.value];
                [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_MaxVolume withValue:sender.value atSourceIdx:(int)velocitySlider.tag inTime:0.0f];
            }
        }
    }
    [[TWAudioController sharedController] setPlaybackParameter:kPlaybackParam_MaxVolume withValue:sender.value atSourceIdx:(int)sender.tag inTime:0.0f];
}

- (void)toggleVelocityButtonDown:(UIButton*)sender {
    for (TWSlider* velocitySlider in _velocitySliders) {
        [velocitySlider setHidden:NO];
    }
    [sender setBackgroundColor:[UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:0.5]];
}

- (void)toggleVelocityButtonUp:(UIButton*)sender {
    for (TWSlider* velocitySlider in _velocitySliders) {
        [velocitySlider setHidden:YES];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0f]];
}



//===== Drum Pad Mode =====//

- (void)toggleDrumPadModeDown:(UIButton*)sender {
    for (UIButton* drumPadModeButton in _drumPadModeButtons) {
        [drumPadModeButton setHidden:NO];
    }
    [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
}

- (void)toggleDrumPadModeUp:(UIButton*)sender {
    for (UIButton* drumPadModeButton in _drumPadModeButtons) {
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


//===== All Button =====//
- (void)editingAllButtonTapped:(UIButton*)sender {
    if ([sender isSelected]) {
        _editingAllToggle = NO;
        [sender setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
        [sender setSelected:NO];
    } else {
        _editingAllToggle = YES;
        [sender setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0f]];
        [sender setSelected:YES];
    }
}


#pragma mark - Private

- (void)testInit {
    
    NSString* sampleURL1 = [[NSBundle mainBundle] pathForResource:@"Embryo Synth" ofType:@"wav"];
    NSString* outSampleURL1 = [sampleURL1 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (sampleURL1 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL1 atSourceIdx:0];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
    
    NSString* sampleURL2 = [[NSBundle mainBundle] pathForResource:@"LRTest" ofType:@"wav"];
    NSString* outSampleURL2 = [sampleURL2 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (sampleURL2 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL2 atSourceIdx:1];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
    
    NSString* sampleURL3 = [[NSBundle mainBundle] pathForResource:@"TestKick" ofType:@"wav"];
    NSString* outSampleURL3 = [sampleURL3 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (sampleURL3 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL3 atSourceIdx:2];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
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

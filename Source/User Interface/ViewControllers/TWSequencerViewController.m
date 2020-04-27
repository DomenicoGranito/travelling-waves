//
//  TWSequencerViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/5/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWSequencerViewController.h"
#import "TWHeader.h"
#import "TWMasterController.h"
#import "TWAudioController.h"
#import "TWSeqNoteButton.h"
#import "TWEnvelopeView.h"
#import "TWForceButton.h"
#import "TWKeypad.h"
#import "UIColor+Additions.h"
#import <QuartzCore/QuartzCore.h>


static const CGFloat kSourceIDLabelWidth            = 12.0f;

static const CGFloat kProgressBarWidth              = 5.0f;
static const CGFloat kProgressBarUpdateInterval     = 0.1f;  // 50ms


@interface TWSequencerViewController () <TWKeypadDelegate,
                                        TWForceButtonDelegate,
                                        TWEnvelopeViewDelegate,
                                        TWAudioControllerDelegate>
{
    UIColor*                    _seqNoteButtonOffColor;
    UIColor*                    _seqNoteButtonOnColor;
    
    UIButton*                   _durationField;
    UIButton*                   _beatsPerBarField;
    UIView*                     _beatsPerBarBackView;
    
    NSArray*                    _sourceEnableButtons;
    
    UIScrollView*               _scrollView;
    NSArray*                    _sourceIdxLabels;
    
    CGFloat                     _seqNoteButtonHeight;
    CGFloat                     _seqScrollWidth;
    
    NSMutableArray*             _seqNoteButtons;
    
    
    TWEnvelopeView*             _floatingEnvelopeView;
    BOOL                        _showingEnvelopeView;
    int                         _currentEnvelopeSourceIdx;
    
    UIView*                     _progressBarView;
    CGRect                      _progressRect;
    NSTimer*                    _progressBarTimer;
    
    UIButton*                   _backButton;
    UIButton*                   _ioButton;
    UIButton*                   _clearAllButton;
}

@end

@implementation TWSequencerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _seqNoteButtonOffColor = [[UIColor alloc] initWithWhite:0.14f alpha:1.0f];
    _seqNoteButtonOnColor = [[UIColor alloc] initWithWhite:0.4f alpha:1.0f];
    
    
    _backButton = [[UIButton alloc] init];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1.0f]];
    [_backButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
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

    _durationField = [[UIButton alloc] init];
    [_durationField setTitleColor:[UIColor valueTextDarkWhiteColor] forState:UIControlStateNormal];
    [_durationField.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [_durationField setBackgroundColor:[UIColor clearColor]];
    [_durationField setTag:(int)TWSeqParamID_Duration_ms];
    [_durationField addTarget:self action:@selector(durationFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_durationField];
    
    
    _beatsPerBarBackView = [[UIView alloc] init];
    [_beatsPerBarBackView setUserInteractionEnabled:NO];
    [_beatsPerBarBackView setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.8f]];
    [self.view addSubview:_beatsPerBarBackView];
    
    _beatsPerBarField = [[UIButton alloc] init];
    [_beatsPerBarField setTitleColor:[UIColor valueTextDarkWhiteColor] forState:UIControlStateNormal];
    [_beatsPerBarField.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [_beatsPerBarField setBackgroundColor:[UIColor clearColor]];
    [_beatsPerBarField addTarget:self action:@selector(beatsPerBarFieldTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_beatsPerBarField];
    
    _clearAllButton = [[UIButton alloc] init];
    [_clearAllButton setBackgroundColor:[UIColor colorWithWhite:0.06 alpha:1.0f]];
    [_clearAllButton setTitle:@"Clear All" forState:UIControlStateNormal];
    [_clearAllButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_clearAllButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_clearAllButton addTarget:self action:@selector(clearAllButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_clearAllButton];
    
    
    // Sequencer Enable Buttons
    NSMutableArray* sourceEnableButtons = [[NSMutableArray alloc] init];
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        TWForceButton* enableButton = [[TWForceButton alloc] init];
        [enableButton setDelegate:self];
        [enableButton setDefaultBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.5f]];
        [enableButton setSelectedBackgroundColor:[UIColor colorWithWhite:0.25f alpha:0.5f]];
//        [enableButton addTarget:self action:@selector(enableButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [enableButton addTarget:self action:@selector(enableButtonRepeat:) forControlEvents:UIControlEventTouchDownRepeat];
        [enableButton setTag:sourceIdx];
        [[enableButton titleLabel] setText:[NSString stringWithFormat:@"%d", sourceIdx+1]];
        [[enableButton titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
        [[enableButton titleLabel] setTextColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
        [[enableButton layer] setBorderWidth:1.0f];
        [[enableButton layer] setBorderColor:[UIColor colorWithWhite:0.0f alpha:1.0f].CGColor];
        [self.view addSubview:enableButton];
        [sourceEnableButtons addObject:enableButton];
    }
    _sourceEnableButtons = [[NSArray alloc] initWithArray:sourceEnableButtons];
    
    
    
    // Floating Envelope View
    _floatingEnvelopeView = [[TWEnvelopeView alloc] init];
    [_floatingEnvelopeView setUserInteractionEnabled:NO];
    [_floatingEnvelopeView setAlpha:0.0f];
    [_floatingEnvelopeView setDelegate:self];
    
    
    
    // Sequencer Note Scroll View and Buttons
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setPagingEnabled:NO];
    [_scrollView setScrollEnabled:YES];
    [_scrollView setDelaysContentTouches:YES];
    [_scrollView setBackgroundColor:[UIColor colorWithWhite:0.18f alpha:1.0f]];
    [self.view addSubview:_scrollView];
    
    
    NSMutableArray* idLabels = [[NSMutableArray alloc] init];
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        UILabel* idLabel = [[UILabel alloc] init];
        [idLabel setText:[NSString stringWithFormat:@"%d", sourceIdx+1]];
        [idLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [idLabel setTextAlignment:NSTextAlignmentCenter];
        [idLabel setTextColor:[UIColor colorWithWhite:0.4f alpha:0.6f]];
        [idLabel setTextAlignment:NSTextAlignmentCenter];
        [idLabel setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:idLabel];
        [idLabels addObject:idLabel];
    }
    _sourceIdxLabels = [[NSArray alloc] initWithArray:idLabels];
    
    
    _seqNoteButtons = [[NSMutableArray alloc] init];
    
    _progressBarView = [[UIView alloc] init];
    [_progressBarView setBackgroundColor:[UIColor colorWithWhite:0.4f alpha:0.4f]];
    [_progressBarView setUserInteractionEnabled:NO];
    [_scrollView addSubview:_progressBarView];
    
    _showingEnvelopeView = NO;
    _currentEnvelopeSourceIdx = 0;
    [self.view addSubview:_floatingEnvelopeView];
    
    [[TWAudioController sharedController] addToDelegates:self];
    
//    [[TWKeypad sharedKeypad] addToDelegates:self];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self updateIOButtonState:[[TWAudioController sharedController] isRunning]];
    
    for (int sourceIdx = 0; sourceIdx < kNumSources; sourceIdx++) {
        [self updateSourceEnableButton:_sourceEnableButtons[sourceIdx] withState:[[TWAudioController sharedController] getSeqEnabledAtSourceIdx:sourceIdx]];
    }
    
    float duration_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_Duration_ms atSourceIdx:-1];
    [_durationField setTitle:[NSString stringWithFormat:@"%.2f", duration_ms] forState:UIControlStateNormal];
    
    float beatsPerBar = [[TWMasterController sharedController] beatsPerBar];
    [_beatsPerBarField setTitle:[NSString stringWithFormat:@"%.2f", beatsPerBar] forState:UIControlStateNormal];
    
    
    if ([[TWAudioController sharedController] isRunning]) {
        [self startProgressAnimation];
    }
    
    [self updateAllSeqNoteButtons];
    
    [self.view addSubview:[TWKeypad sharedKeypad]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[TWKeypad sharedKeypad] removeFromSuperview];
    [super viewWillDisappear:animated];
}



- (void)viewDidLayoutSubviews {

    // Layout UI
    CGFloat xMargin         = self.view.safeAreaInsets.left;
    CGFloat yPos            = self.view.safeAreaInsets.top;
    CGFloat xPos            = xMargin;
    
    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    CGFloat titleButtonWidth = screenWidth / 5.0f;
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    
    
    [_backButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_ioButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_durationField setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_beatsPerBarField setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    [_beatsPerBarBackView setFrame:_beatsPerBarField.frame];
    
    xPos += titleButtonWidth;
    [_clearAllButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    
    
    CGFloat sourceEnableButtonWidth;
    if (isLandscape) {
        sourceEnableButtonWidth = screenWidth / kNumSources;
    } else {
        sourceEnableButtonWidth = screenWidth / (kNumSources / 2.0f);
    }
    
    xPos = xMargin;
    yPos += componentHeight;
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        TWForceButton* enableButton = (TWForceButton*)_sourceEnableButtons[sourceIdx];
        
        if (isLandscape) {
           [enableButton setFrame:CGRectMake(xPos, yPos, sourceEnableButtonWidth, componentHeight)];
            xPos += sourceEnableButtonWidth;
        } else {
            float column = sourceIdx % 2;
            [enableButton setFrame:CGRectMake(xPos, yPos + (column * componentHeight), sourceEnableButtonWidth, componentHeight)];
            if (column == 1.0f) {
                xPos += sourceEnableButtonWidth;
            }
        }
    }
    
    if (isLandscape) {
        yPos += componentHeight;
    } else {
        yPos += 2.0f * componentHeight;
    }
    xPos = xMargin;
    [_floatingEnvelopeView setFrame:CGRectMake(xPos, yPos , screenWidth, 10.0f * componentHeight)];
    // TODO: Fix this for iPhone Landscape
    
    
    
    // Sequencer Notes Scroll View and Buttons
    
    CGFloat seqNoteScrollViewWidth = screenWidth - kSourceIDLabelWidth;
    _seqScrollWidth = isLandscape ? seqNoteScrollViewWidth : 2.0f * seqNoteScrollViewWidth;

    _seqNoteButtonHeight = (screenHeight - yPos) / kNumSources;
    CGFloat seqNoteScrollViewHeight = _seqNoteButtonHeight * (kNumIntervals / 2.0f);
    
    xPos = xMargin + kSourceIDLabelWidth;
    [_scrollView setFrame:CGRectMake(xPos, yPos, seqNoteScrollViewWidth, seqNoteScrollViewHeight)];
    [_scrollView setContentSize:CGSizeMake(_seqScrollWidth, seqNoteScrollViewHeight)];
    
    xPos = xMargin;
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        UILabel* idLabel1 = (UILabel*)_sourceIdxLabels[sourceIdx];
        [idLabel1 setFrame:CGRectMake(xPos + (0 * screenWidth), yPos, kSourceIDLabelWidth, _seqNoteButtonHeight)];
        
//        UILabel* idLabel2 = (UILabel*)_sourceIdxLabels[sourceIdx+1];
//        [idLabel2 setFrame:CGRectMake(xPos + (1 * screenWidth), yPos, kSourceIDLabelWidth, _seqNoteButtonHeight)];
        yPos += _seqNoteButtonHeight;
    }
    
    [self layoutAllSeqNoteButtons];
//    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
//        [self updateAndLayoutSeqNoteButtonsForSource:sourceIdx];
//    }
    
    [_progressBarView setFrame:CGRectMake(0.0f, 0.0f, kProgressBarWidth, _scrollView.frame.size.height)];
    _progressRect = _progressBarView.frame;
    
    
    
    
    
    CGFloat keypadHeight;
    CGFloat keypadShowYOffset;
    if (isIPad) {
        keypadHeight = 3.5f * componentHeight;
        keypadShowYOffset = 0.0f;
    } else if (isLandscape) {
        keypadHeight = 3.5f * componentHeight;
        keypadShowYOffset = 0.5 * componentHeight;
    } else {
        keypadHeight = 6.0f * componentHeight;
        keypadShowYOffset = 0.0f;
    }
    
    CGRect keypadHideFrame = CGRectMake(xMargin, self.view.frame.size.height, screenWidth, keypadHeight);
    CGRect keypadShowFrame = CGRectMake(keypadHideFrame.origin.x, keypadHideFrame.origin.y - keypadHeight - keypadShowYOffset, keypadHideFrame.size.width, keypadHideFrame.size.height);
    
    [[TWKeypad sharedKeypad] setHideFrame:keypadHideFrame];
    [[TWKeypad sharedKeypad] setShowFrame:keypadShowFrame];
    
    if ([[TWKeypad sharedKeypad] keypadIsShowing]) {
        [[TWKeypad sharedKeypad] setFrame:keypadShowFrame];
    } else {
        [[TWKeypad sharedKeypad] setFrame:keypadHideFrame];
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

- (void)clearAllButtonTapped {
    for (NSArray* srcArray in _seqNoteButtons) {
        for (TWSeqNoteButton* button in srcArray) {
            [[TWAudioController sharedController] setSeqNote:0 atSourceIdx:button.sourceIdx atBeat:button.beat];
            [self updateSeqNoteButton:button withNote:0];
        }
    }
}


#pragma mark - Private

- (void)updateAllSeqNoteButtons {
    
    for (NSArray* srcArray in _seqNoteButtons) {
        for (TWSeqNoteButton* button in srcArray) {
            [button removeFromSuperview];
        }
    }
    [_seqNoteButtons removeAllObjects];
    
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        int interval = [[TWAudioController sharedController] getSeqIntervalAtSourceIdx:sourceIdx];
        NSMutableArray* sourceSeqArray = [[NSMutableArray alloc] init];
        for (int beat=0; beat < interval; beat++) {
            TWSeqNoteButton* button = [[TWSeqNoteButton alloc] init];
            [button setSourceIdx:sourceIdx];
            [button setBeat:beat];
            [button addTarget:self action:@selector(seqNoteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:[NSString stringWithFormat:@"%d", beat+1] forState:UIControlStateNormal];
            [[button titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
            [button setTitleColor:[UIColor colorWithWhite:0.5f alpha:1.0f] forState:UIControlStateNormal];
            [[button layer] setBorderWidth:1.0f];
            [[button layer] setBorderColor:[UIColor colorWithWhite:0.0f alpha:0.8f].CGColor];
            [button setBackgroundColor:_seqNoteButtonOffColor];
            [_scrollView addSubview:button];
            [sourceSeqArray addObject:button];
            
            int note = [[TWAudioController sharedController] getSeqNoteAtSourceIdx:sourceIdx atBeat:beat];
            [self updateSeqNoteButton:button withNote:note];
        }
        [_seqNoteButtons addObject:sourceSeqArray];
        [_scrollView bringSubviewToFront:_progressBarView];
    }
}

- (void)layoutAllSeqNoteButtons {
    CGFloat xPos = 0.0f;
    CGFloat yPos = 0.0f;
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        NSArray* sourceSeqArray = (NSArray*)_seqNoteButtons[sourceIdx];
        int interval = [[TWAudioController sharedController] getSeqIntervalAtSourceIdx:sourceIdx];
        xPos = 0.0f;
        CGFloat seqNoteButtonWidth = _seqScrollWidth / (float)interval;
        for (int beat=0; beat < interval; beat++) {
            TWSeqNoteButton* button = (TWSeqNoteButton*)sourceSeqArray[beat];
            [button setFrame:CGRectMake(xPos, yPos, seqNoteButtonWidth, _seqNoteButtonHeight)];
            xPos += seqNoteButtonWidth;
        }
        yPos += _seqNoteButtonHeight;
    }
}

/*
- (void)updateAndLayoutSeqNoteButtonsForSource:(int)sourceIdx {
    
    NSMutableArray* srcArray = (NSMutableArray*)[_seqNoteButtons objectAtIndex:sourceIdx];
    for (SeqNoteButton* button in srcArray) {
        [button removeFromSuperview];
    }
    [srcArray removeAllObjects];
    printf("\n\n\n\n\nSeqNoteButtons:\n\n");
    NSLog(@"%@", _seqNoteButtons);
    printf("\n\n\n\n\n");
    
    CGFloat xPos = 0.0f;
    CGFloat yPos = 0.0f;
    for (int sourceIdx=0; sourceIdx < kNumSources; sourceIdx++) {
        int interval = [[TWAudioController sharedController] getSeqIntervalAtSourceIdx:sourceIdx];
        NSMutableArray* sourceSeqArray = [[NSMutableArray alloc] init];
        xPos = 0.0f;
        for (int beat=0; beat < interval; beat++) {
            SeqNoteButton* button = [[SeqNoteButton alloc] init];
            [button setSelected:NO];
            [button setSourceIdx:sourceIdx];
            [button setBeat:beat];
            [button addTarget:self action:@selector(seqNoteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:[NSString stringWithFormat:@"%d", beat+1] forState:UIControlStateNormal];
            [[button titleLabel] setFont:[UIFont systemFontOfSize:11.0f]];
            [button setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
            [[button layer] setBorderWidth:1.0f];
            [[button layer] setBorderColor:[UIColor colorWithWhite:0.0f alpha:0.8f].CGColor];
            [button setBackgroundColor:_seqNoteButtonOffColor];
            [_scrollView addSubview:button];
            [sourceSeqArray addObject:button];
            
            [button setFrame:CGRectMake(xPos, yPos, _seqNoteButtonSize, _seqNoteButtonSize)];
            xPos += _seqNoteButtonSize;
        }
        yPos += _seqNoteButtonSize;
        [_seqNoteButtons addObject:sourceSeqArray];
    }
}
*/

- (void)seqNoteButtonTapped:(TWSeqNoteButton*)button {
    int note = [button isSelected] ? 0 : 1;
    [[TWAudioController sharedController] setSeqNote:note atSourceIdx:button.sourceIdx atBeat:button.beat];
    [self updateSeqNoteButton:button withNote:note];
    [self updateOscView:button.sourceIdx];
}


- (void)updateSeqNoteButton:(TWSeqNoteButton*)button withNote:(int)note {
    [button setSelected:(note!=0)];
    [button setBackgroundColor:((note==0) ? _seqNoteButtonOffColor : _seqNoteButtonOnColor)];
}

- (void)intervalUpdated:(TWEnvelopeView*)sender {
    [self updateAllSeqNoteButtons];
    [self layoutAllSeqNoteButtons];
//    [self updateAndLayoutSeqNoteButtonsForSource:sender.sourceIdx];
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

#pragma mark - ForceButtonDelegate

// Sequencer Osc Enable Buttons

- (void)forceButtonTouchUpInside:(TWForceButton*)sender {
    BOOL newEnableState = ![sender isSelected];
    int sourceIdx = (int)sender.tag;
    [[TWAudioController sharedController] setSeqEnabled:newEnableState atSourceIdx:sourceIdx];
    [self updateSourceEnableButton:sender withState:newEnableState];
    [self updateOscView:sourceIdx];
}


- (void)forceButtonForcePressDown:(TWForceButton*)sender {
    
    int newSourceIdx = (int)sender.tag;
    [_floatingEnvelopeView setSourceIdx:newSourceIdx];
    [self updateOscView:newSourceIdx];
    
    
    if (newSourceIdx == _currentEnvelopeSourceIdx) {
        BOOL newState = !_showingEnvelopeView;
        [self toggleEnvelopeView:newState forInterval:newSourceIdx];
        _showingEnvelopeView = newState;
        
        TWForceButton* button = (TWForceButton*)_sourceEnableButtons[newSourceIdx];
        if (_showingEnvelopeView) {
            [[button layer] setBorderColor:[UIColor colorWithRed:0.5f green:0.1f blue:0.1f alpha:1.0f].CGColor];
        } else {
            [[button layer] setBorderColor:[UIColor colorWithWhite:0.0f alpha:1.0f].CGColor];
        }
    }
    
    else {
        _showingEnvelopeView = YES;
        [self toggleEnvelopeView:_showingEnvelopeView forInterval:newSourceIdx];
        
        TWForceButton* oldButton = (TWForceButton*)_sourceEnableButtons[_currentEnvelopeSourceIdx];
        [[oldButton layer] setBorderColor:[UIColor colorWithWhite:0.0f alpha:1.0f].CGColor];
        
        TWForceButton* newButton = (TWForceButton*)_sourceEnableButtons[newSourceIdx];
        [[newButton layer] setBorderColor:[UIColor colorWithRed:0.5f green:0.1f blue:0.1f alpha:1.0f].CGColor];
        
        _currentEnvelopeSourceIdx = newSourceIdx;
    }
}


- (void)updateSourceEnableButton:(TWForceButton*)button withState:(BOOL)state {
    [button setSelected:state];
}


- (void)toggleEnvelopeView:(BOOL)show forInterval:(int)interval {
    __block TWEnvelopeView* view = _floatingEnvelopeView;
    [UIView animateWithDuration:0.5f animations:^{
        [view setAlpha:(CGFloat)show];
    } completion:^(BOOL finished) {
        [view setUserInteractionEnabled:show];
    }];
}




#pragma mark - TWKeypad

- (void)keypadDoneButtonTapped:(id)senderKeypad forComponent:(UIView *)responder withValue:(NSString *)inValue {
    
    UIButton* fieldButton = (UIButton*)responder;
    
    if (responder == _durationField) {
        float duration_ms = [inValue floatValue];
        [[TWAudioController sharedController] setSeqParameter:TWSeqParamID_Duration_ms withValue:duration_ms atSourceIdx:-1];
        [fieldButton setTitle:[NSString stringWithFormat:@"%.2f", duration_ms] forState:UIControlStateNormal];
    }
    
    else if (responder == _beatsPerBarField) {
        float beatsPerBar = [inValue floatValue];
        [[TWMasterController sharedController] setBeatsPerBar:beatsPerBar];
        [fieldButton setTitle:[NSString stringWithFormat:@"%.2f", beatsPerBar] forState:UIControlStateNormal];
        [self updateSeqDurationFieldWithValue:[[TWAudioController sharedController] getSeqParameter:TWSeqParamID_Duration_ms atSourceIdx:-1]];
    }
    
}

- (void)keypadCancelButtonTapped:(id)senderKeypad forComponent:(UIView *)responder {
    
    UIButton* fieldButton = (UIButton*)responder;
    
    if (responder == _durationField) {
        float duration_ms = [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_Duration_ms atSourceIdx:-1];
        [fieldButton setTitle:[NSString stringWithFormat:@"%.2f", duration_ms] forState:UIControlStateNormal];
    }
    
    else if (responder == _beatsPerBarField) {
        float beatsPerBar = [[TWMasterController sharedController] beatsPerBar];
        [fieldButton setTitle:[NSString stringWithFormat:@"%.2f", beatsPerBar] forState:UIControlStateNormal];
    }
}

- (void)durationFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Seq Duration (ms): "];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWAudioController sharedController] getSeqParameter:TWSeqParamID_Duration_ms atSourceIdx:-1]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:_durationField];
}

- (void)beatsPerBarFieldTapped {
    TWKeypad* keypad = [TWKeypad sharedKeypad];
    [keypad setTitle:@"Beats Per Bar: "];
    [keypad setValue:[NSString stringWithFormat:@"%.2f", [[TWMasterController sharedController] beatsPerBar]]];
    [keypad setCurrentDelegate:self];
    [keypad setCurrentResponder:_beatsPerBarField];
}

- (void)updateSeqDurationFieldWithValue:(float)value {
    [_durationField setTitle:[NSString stringWithFormat:@"%.2f", value] forState:UIControlStateNormal];
}

#pragma mark - TWAudioController Delegate

- (void)audioControllerDidStart {
    [self startProgressAnimation];
}

- (void)audioControllerDidStop {
    [self stopProgressAnimation];
}


#pragma mark - Seq Seek Animation

- (void)startProgressAnimation {
    if (!_progressBarTimer) {
        _progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:kProgressBarUpdateInterval
                                                             target:self
                                                           selector:@selector(updateProgressBar)
                                                           userInfo:nil
                                                            repeats:YES];
    }
}

- (void)stopProgressAnimation {
    if ([_progressBarTimer isValid]) {
        [_progressBarTimer invalidate];
    }
    _progressBarTimer = nil;
}

- (void)updateProgressBar {
    _progressRect.origin.x = (_seqScrollWidth) * [[TWAudioController sharedController] getSeqNormalizedProgress];
    [UIView animateWithDuration:kProgressBarUpdateInterval
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self->_progressBarView setFrame:self->_progressRect];
                     }
                     completion:^(BOOL finished) {}];
}



- (void)updateOscView:(int)sourceIdx {
    if ([_oscView respondsToSelector:@selector(setSourceIdx:)]) {
        [_oscView setSourceIdx:sourceIdx];
    }
}
                             
@end

//
//  TWDrumPadViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/22/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWDrumPadViewController.h"
#import "TWDrumPad.h"
#import "TWHeader.h"
#import "TWAudioController.h"

@interface TWDrumPadViewController ()
{
    UIButton*                   _backButton;
    UIButton*                   _loadProjectButton;
    
//    UIView*                     _testView;
    
    NSArray*                    _drumPads;
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
    
    NSMutableArray* drumPads = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumSources; i++) {
        TWDrumPad* drumPad = [[TWDrumPad alloc] init];
        [drumPad setTag:i];
        [drumPad setBackgroundColor:[UIColor colorWithWhite:0.08 alpha:1.0]];
        [drumPad setTitleText:[NSString stringWithFormat:@"%i", i]];
        [self.view addSubview:drumPad];
        [drumPads addObject:drumPad];
    }
    _drumPads = [[NSArray alloc] initWithArray:drumPads];
    
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    for (TWDrumPad* drumPad in _drumPads) {
        [drumPad viewWillAppear];
    }
}

- (void)viewDidLayoutSubviews {
    
    // Layout UI
    CGFloat xMargin      = 0.0f;
    CGFloat yPos         = self.view.safeAreaInsets.top;
    CGFloat xPos         = xMargin;
    
    CGFloat screenWidth  = self.view.frame.size.width - (2.0f * xMargin);
    CGFloat screenHeight  = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = isLandscape ? kLandscapeComponentHeight : kPortraitComponentHeight;
    
    
    CGFloat titleButtonWidth = screenWidth / 4.0f;
    
    [_backButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    xPos += titleButtonWidth;
    [_loadProjectButton setFrame:CGRectMake(xPos, yPos, titleButtonWidth, componentHeight)];
    
    
    
    yPos += componentHeight;
    
    CGFloat padPadRatio = 0.1f;
    CGFloat padSize = 0.0f;
    CGFloat padPad = 0.0f;
    
    if (isLandscape) {
        padSize = (screenHeight - yPos) / (4.0 + (5.0f * padPadRatio));
        padPad = padPadRatio * padSize;
    } else {
        padSize = 120.0f;
        padPad = 12.0f;
    }
    
    yPos += padPad;
    xPos = padPad;
    
    for (int i=0; i < kNumSources; i++) {
//        int row = (int)(i / 4);
        int column = i % 4;
        
        TWDrumPad* pad = [_drumPads objectAtIndex:i];
        [pad setFrame:CGRectMake(xPos, yPos, padSize, padSize)];
        
        xPos += padSize + padPad;
        if (column == 3) {
            yPos += padSize + padPad;
            xPos = padPad;
        }
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

- (void)loadProjectButtonTapped:(UIButton*)sender {
    [self testInit];
}

- (void)testInit {
//    NSString* sampleURL1 = [[NSBundle mainBundle] pathForResource:@"Embryo Synth" ofType:@"wav"];
//    NSString* outSampleURL1 = [sampleURL1 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//
//    if (sampleURL1 != nil) {
//        [[TWAudioController sharedController] loadAudioFile:outSampleURL1 atSourceIdx:0];
//    } else {
//        NSLog(@"Error! SampleURL is nil!");
//    }
    
    NSString* sampleURL2 = [[NSBundle mainBundle] pathForResource:@"LRTest" ofType:@"wav"];
    NSString* outSampleURL2 = [sampleURL2 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    if (sampleURL2 != nil) {
        [[TWAudioController sharedController] loadAudioFile:outSampleURL2 atSourceIdx:1];
    } else {
        NSLog(@"Error! SampleURL is nil!");
    }
}

@end

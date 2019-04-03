//
//  TWTestViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 3/28/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWTestViewController.h"
#import "TWAudioController.h"

@interface TWTestViewController ()
{
    UIButton* _testButton;
}

@end

@implementation TWTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _testButton = [[UIButton alloc] init];
    [_testButton setTitle:@"Test!" forState:UIControlStateNormal];
    [_testButton setBackgroundColor:[UIColor colorWithWhite:0.06 alpha:1.0]];
    [_testButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_testButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_testButton addTarget:self action:@selector(testButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_testButton];
    
    [[TWAudioController sharedController] setPlaybackFinishedBlock:^(int sourceIdx, int status) {
        NSLog(@"Dayumn! [%d], [%d]", sourceIdx, status);
    }];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLayoutSubviews {
    
    CGFloat xMargin         = self.view.safeAreaInsets.left;
//    CGFloat yPos            = self.view.safeAreaInsets.top;
    CGFloat xPos            = xMargin;
    
    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    CGFloat height = 80.0f;
    [_testButton setFrame:CGRectMake(xPos, (screenHeight - height) / 2.0f , screenWidth, height)];
    
}

- (void)testButtonTapped:(UIButton*)sender {
    [[TWAudioController sharedController] startPlaybackAtSourceIdx:0 atSampleTime:0];
}

@end

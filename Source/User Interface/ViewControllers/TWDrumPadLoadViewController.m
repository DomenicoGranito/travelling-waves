//
//  TWDrumPadLoadViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/14/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "TWDrumPadLoadViewController.h"
#import "TWMasterController.h"
#import "TWAudioController.h"

@interface TWDrumPadLoadViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIButton*                   _backButton;
    
    UITableView*                _tableView;
    
    NSArray<NSString*>*         _sampleSetsList;
}
@end

@implementation TWDrumPadLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _backButton = [[UIButton alloc] init];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor blueColor]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView setAllowsSelection:YES];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    _sampleSetsList = nil;
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _sampleSetsList = [[TWMasterController sharedController] getListOfPresetDrumPadSets];
//    [_chartSelector setSelectedSegmentIndex:kOsterCurveChart];
    [_tableView reloadData];
}


- (void)viewDidLayoutSubviews {
    
    // Layout UI
    CGFloat xMargin         = self.view.safeAreaInsets.left;
    CGFloat yPos            = self.view.safeAreaInsets.top;
    CGFloat xPos            = xMargin;
    
    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    
    [_backButton setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth * 2.0f, componentHeight)];
    
    
    yPos += componentHeight;
    [_tableView setFrame:CGRectMake(xPos, yPos, screenWidth, screenHeight - yPos)];
    [_tableView setRowHeight:componentHeight];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)backButtonTapped:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_sampleSetsList count];
//
//    switch (_currentLibrary) {
//        case LocalLibrary:
//            return [_currentLocalList count];
//            break;
//
//        case RemoteLibrary:
//            return 0;
//            break;
//    }
//    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ProjectIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setIndentationLevel:1];
        [[cell textLabel] setTextColor:[UIColor colorWithWhite:0.64f alpha:1.0f]];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:12.0f]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIView* selectionColor = [[UIView alloc] init];
        [selectionColor setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.15f]];
        [cell setSelectedBackgroundView: selectionColor];
    }
    
    [[cell textLabel] setText:[_sampleSetsList objectAtIndex:indexPath.row]];
//    if (_currentLibrary == LocalLibrary) {
//        [[cell textLabel] setText:[_currentLocalList objectAtIndex:indexPath.row]];
//    } else if (_currentLibrary == RemoteLibrary) {
//        [[cell textLabel] setText:@"Test123"];
//    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString* sampleSet = _sampleSetsList[indexPath.row];

    if (sampleSet != nil) {
        NSString* filepath = [[NSBundle mainBundle] pathForResource:sampleSet ofType:@"plist"];
        if (filepath != nil) {

            NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:filepath];
            NSArray* samples = dictionary[@"Samples"];

            if (samples != nil) {

                for (int sourceIdx = 0; sourceIdx < (int)samples.count; sourceIdx++) {
                    NSString* sampleName = samples[sourceIdx];
                    NSString* samplePath = [[NSBundle mainBundle] pathForResource:sampleName ofType:@"wav"];
                    [[TWAudioController sharedController] loadAudioFile:[samplePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"] atSourceIdx:sourceIdx];
                }
            }
        }
    }
}

@end

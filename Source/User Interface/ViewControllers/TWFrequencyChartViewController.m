//
//  TWFrequencyChartViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/1/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWFrequencyChartViewController.h"
#import "TWHeader.h"
#import "TWMasterController.h"
#import "UIColor+Additions.h"

#define kNumNotes                       88
#define kEqualTemperamentFreqRef        440.0f
#define kEqualTemparamentPitchRef       44



typedef enum : NSUInteger {
    kOsterCurveChart            = 0,
    kEqualTemperamentChart      = 1
} TWFrequencyChart;


@interface TWFrequencyChartViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UISegmentedControl*         _chartSelector;
    UITableView*                _tableView;
    
    NSArray*                    _equalTemperamentArray;
    CGFloat                     _cellWidth;
    
    UIButton*                   _backButton;
}

@end

@implementation TWFrequencyChartViewController

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
    
    _chartSelector = [[UISegmentedControl alloc] initWithItems:@[@"Oster Curve", @"Equal Temperament"]];
    [_chartSelector setBackgroundColor:[UIColor segmentedControlColor]];
    [_chartSelector setSelectedSegmentIndex:0];
    [_chartSelector setTintColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    [_chartSelector addTarget:self action:@selector(chartSelectorChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_chartSelector];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView setAllowsSelection:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    // Equal Temperament Chart
    [self loadEqualTemperamentChart];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_chartSelector setSelectedSegmentIndex:kOsterCurveChart];
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
    [_chartSelector setFrame:CGRectMake(xPos - 3.0f, yPos, screenWidth + 6.0f, componentHeight)];
    
    yPos += componentHeight;
    [_tableView setFrame:CGRectMake(xMargin, yPos, screenWidth, screenHeight - yPos)];
    [_tableView setRowHeight:componentHeight];
    _cellWidth = _tableView.frame.size.width;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (float)equalTemperamentFrequency:(int)index referenceFreq:(float)fRef {
    float fn = powf(2.0f, (float)index / 12.0f) * fRef;
//    printf("%d : %f\n", index, fn);
//    NSLog(@"EqTmpFreq (%d): %f", index, fn);
    return fn;
}



- (void)backButtonTapped:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)chartSelectorChanged:(UISegmentedControl*)sender {
    [_tableView reloadData];
}


#pragma mark - Internal

- (void)loadEqualTemperamentChart {
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"EqualTemperament" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filepath];
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    _equalTemperamentArray = [[NSArray alloc] initWithArray:dictionary[@"EqualTemperament"]];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_chartSelector.selectedSegmentIndex == kOsterCurveChart) {
        return [[[TWMasterController sharedController] osterCurve] count];
    } else if (_chartSelector.selectedSegmentIndex == kEqualTemperamentChart) {
        return _equalTemperamentArray.count;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FreqChartCellID";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setIndentationLevel:2];
        [[cell textLabel] setTextColor:[UIColor colorWithWhite:0.64f alpha:1.0f]];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:12.0f]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        CGFloat labelWidth = _cellWidth / 2.0f;
        
        UILabel* section0Label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, labelWidth, cell.frame.size.height)];
        [section0Label setTextAlignment:NSTextAlignmentCenter];
        [section0Label setFont:[UIFont systemFontOfSize:12.0f]];
        [section0Label setTextColor:[UIColor colorWithWhite:0.64f alpha:1.0f]];
        [section0Label setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.25f]];
        [section0Label setTag:0];
        [cell addSubview:section0Label];
        
        UILabel* section1Label = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth, 0.0f, labelWidth, cell.frame.size.height)];
        [section1Label setTextAlignment:NSTextAlignmentCenter];
        [section1Label setFont:[UIFont systemFontOfSize:12.0f]];
        [section1Label setTextColor:[UIColor colorWithWhite:0.64f alpha:1.0f]];
        [section1Label setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.25f]];
        [section1Label setTag:1];
        [cell addSubview:section1Label];
    }
    
    
    UILabel* section0Label = [cell viewWithTag:0];
    UILabel* section1Label = [cell viewWithTag:1];
    if (_chartSelector.selectedSegmentIndex == kOsterCurveChart) {
        [section0Label setText:[NSString stringWithFormat:@"%.3f", [[[TWMasterController sharedController] osterCurve][indexPath.row][0] floatValue]]];
        [section1Label setText:[NSString stringWithFormat:@"%.3f", [[[TWMasterController sharedController] osterCurve][indexPath.row][1] floatValue]]];
    } else if (_chartSelector.selectedSegmentIndex == kEqualTemperamentChart) {
        [section0Label setText:(NSString*)_equalTemperamentArray[indexPath.row][0]];
        [section1Label setText:[NSString stringWithFormat:@"%.3f", [_equalTemperamentArray[indexPath.row][1] floatValue]]];
    }
    
    return cell;
}


@end

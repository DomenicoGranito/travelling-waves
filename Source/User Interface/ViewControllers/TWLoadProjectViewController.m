//
//  TWLoadProjectViewController.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 9/24/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWLoadProjectViewController.h"
#import "TWHeader.h"
#import "TWMasterController.h"
#import "UIColor+Additions.h"

typedef enum : NSUInteger {
    LocalLibrary    = 0,
    RemoteLibrary   = 1,
} TWProjectsLibrary;


@interface TWLoadProjectViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView*                _tableView;
    NSArray<NSString*>*         _currentLocalList;
    
    UISegmentedControl*         _segmentedControl;
    
    UIButton*                   _backButton;
    
    UIView*                         _busyBackgroundView;
    UILabel*                        _busyLabel;
    UIActivityIndicatorView*        _activityView;
    
    TWProjectsLibrary               _currentLibrary;
}

@end

@implementation TWLoadProjectViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _backButton = [[UIButton alloc] init];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.0f] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:13.0f]];
    [_backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    
    NSDictionary* attribute = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:11.0f] forKey:NSFontAttributeName];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Local", @"Remote"]];
    [_segmentedControl setTitleTextAttributes:attribute forState:UIControlStateNormal];
    [_segmentedControl setTintColor:[UIColor segmentedControlTintColor]];
    [_segmentedControl setBackgroundColor:[UIColor segmentedControlBackgroundColor]];
    [_segmentedControl addTarget:self action:@selector(projectsSourceChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    
    
    // Table View
    _tableView = [[UITableView alloc] init];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_tableView];
    
    _busyBackgroundView = [[UIView alloc] init];
    [_busyBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.7f]];
    [_busyBackgroundView setAlpha:0.0f];
    [self.view addSubview:_busyBackgroundView];
    
    _busyLabel = [[UILabel alloc] init];
    [_busyLabel setTextColor:[UIColor colorWithWhite:0.3f alpha:1.0f]];
    [_busyLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [_busyLabel setTextAlignment:NSTextAlignmentCenter];
    [_busyLabel setText:@"Gathering Remote Projects..."];
    [_busyLabel setBackgroundColor:[UIColor clearColor]];
    [_busyBackgroundView addSubview:_busyLabel];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityView setHidesWhenStopped:YES];
    [_busyBackgroundView addSubview:_activityView];
    
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.12f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self updateLocalProjectsList];
    _currentLibrary = LocalLibrary;
    [_segmentedControl setSelectedSegmentIndex:_currentLibrary];
}

- (void)viewDidLayoutSubviews {
    
    // Layout UI
    CGFloat xMargin         = self.view.safeAreaInsets.left;
    CGFloat yPos            = self.view.safeAreaInsets.top;
    CGFloat xPos            = xMargin;
    
    CGFloat screenWidth     = self.view.frame.size.width - self.view.safeAreaInsets.right - self.view.safeAreaInsets.left;
    CGFloat screenHeight    = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
    CGFloat busyLabelHeight = 40.0f;
    
    
    bool isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    bool isLandscape = (orienation == UIInterfaceOrientationLandscapeLeft) || (orienation == UIInterfaceOrientationLandscapeRight);
    CGFloat componentHeight = (isLandscape ? (isIPad ? kLandscapePadComponentHeight : kLandscapePhoneComponentHeight) : kPortraitComponentHeight);
    
    
    [_backButton setFrame:CGRectMake(xPos, yPos, kTitleLabelWidth * 2.0f, componentHeight)];
    
    yPos += componentHeight;
    [_segmentedControl setFrame:CGRectMake(xPos, yPos, screenWidth, componentHeight)];
    
    yPos += componentHeight;
    [_tableView setFrame:CGRectMake(xPos, yPos, screenWidth, screenHeight - yPos)];
    [_tableView setRowHeight:componentHeight];
    
    yPos = self.view.safeAreaInsets.top;
    [_busyBackgroundView setFrame:CGRectMake(xPos, yPos, screenWidth, screenHeight)];
    [_activityView setCenter:CGPointMake(_busyBackgroundView.center.x, _busyBackgroundView.center.y - (2.0 * busyLabelHeight))];
    yPos = _busyBackgroundView.center.y - (4.0 * busyLabelHeight);
    [_busyLabel setFrame:CGRectMake(xPos, yPos, screenWidth, busyLabelHeight)];
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



- (void)projectsSourceChanged {
    
    _currentLibrary = (TWProjectsLibrary)_segmentedControl.selectedSegmentIndex;
    
    if (_currentLibrary == LocalLibrary) {
        
    }
    
    else if (_currentLibrary == RemoteLibrary) {
        [self startLoadingAnimation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopLoadingAnimation];
        });
    }
    
    [_tableView reloadData];
}






#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (_currentLibrary) {
        case LocalLibrary:
            return [_currentLocalList count];
            break;
            
        case RemoteLibrary:
            return 0;
            break;
    }
    return 0;
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
        
        UIView* selectionView = [[UIView alloc] init];
        [selectionView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.15f]];
        [cell setSelectedBackgroundView: selectionView];
    }
    
    if (_currentLibrary == LocalLibrary) {
        [[cell textLabel] setText:[_currentLocalList objectAtIndex:indexPath.row]];
    } else if (_currentLibrary == RemoteLibrary) {
        [[cell textLabel] setText:@"Test123"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* filename = _currentLocalList[indexPath.row];
    int error = [[TWMasterController sharedController] loadProjectFromFilename:filename];
    if (error == -1) {
        [self launchError:[NSString stringWithFormat:@"Selected project file (\"%@\") does not exist or is corrupted.", filename]];
    } else if (error == -2) {
        [self launchError:[NSString stringWithFormat:@"Selected project file (\"%@\") is of an incorrect format or is an older unsupported version.", filename]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __block NSString* filename = _currentLocalList[indexPath.row];
    __block TWLoadProjectViewController* myself = self;
    UITableViewRowAction* delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[TWMasterController sharedController] deleteProjectWithFilename:filename];
        [myself updateLocalProjectsList];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [delete setBackgroundColor:[UIColor colorWithRed:0.2f green:0.1f blue:0.1f alpha:0.5f]];
    [delete setBackgroundEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    UITableViewRowAction* share = share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self launchShareActionSheet:filename];
    }];
    [share setBackgroundColor:[UIColor colorWithRed:0.1f green:0.2f blue:0.1f alpha:0.5f]];
    [share setBackgroundEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    NSArray* array = [NSArray arrayWithObjects:delete, share, nil];
    return array;
}


#pragma mark - Private

- (void)launchError:(NSString*)message {
    
    UIAlertController* dialog = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [dialog addAction:okAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)launchShareActionSheet:(NSString*)filename {
    
    NSString* filepath = [[[TWMasterController sharedController] projectsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", filename]];
    
    NSString* message = [NSString stringWithFormat:@"\"%@\"\n", filename];
    NSURL* fileUrl = [NSURL fileURLWithPath:filepath isDirectory:NO];
    NSArray* items = @[message, fileUrl];
    
    UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    activityController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeOpenInIBooks,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePrint,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeMarkupAsPDF];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [activityController setModalPresentationStyle:UIModalPresentationPopover];
        [activityController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionUp];
        [activityController.popoverPresentationController setSourceView:self.view];
        [activityController.popoverPresentationController setSourceRect:CGRectMake(0.0, 40.0f, self.view.frame.size.width - 0.0f, self.view.frame.size.height - 80.0f)];
    }
    
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)updateLocalProjectsList {
    _currentLocalList = [[TWMasterController sharedController] getListOfSavedFilenames];
}


#pragma mark - Remote Projects

- (void)checkServerForListOfProjects {
    
}

- (void)startLoadingAnimation {
    __block UIView* busyBackgroundView = _busyBackgroundView;
    __block UIActivityIndicatorView* activityView = _activityView;
    [UIView animateWithDuration:0.1 animations:^{
        [busyBackgroundView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [activityView startAnimating];
    }];
}

- (void)stopLoadingAnimation {
    __block UIView* busyBackgroundView = _busyBackgroundView;
    __block UIActivityIndicatorView* activityView = _activityView;
    [UIView animateWithDuration:0.1 animations:^{
        [busyBackgroundView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [activityView stopAnimating];
    }];
}

@end

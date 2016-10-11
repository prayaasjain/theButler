//
//  SettingsViewController.m
//  thebutler
//
//  Created by Prayaas Jain on 10/21/15.
//  Copyright © 2015 Prayaas Jain. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingState.h"

@interface SettingsViewController ()

@property (nonatomic ,strong) UITableView* homeTable;
@property (nonatomic, strong) NSArray *cellTitles;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[AppColor butlerBlackBackgroundColor]];
    
    self.homeTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.homeTable.scrollsToTop = NO;
    self.homeTable.delegate = self;
    self.homeTable.dataSource = self;
    self.homeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.homeTable.scrollEnabled = NO;
    self.homeTable.backgroundColor = [AppColor butlerBlackBackgroundColor];
    
    self.cellTitles = @[@"Change My Title", @"Change My Butler"];
    
    UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-80.0, self.view.bounds.size.width*2/3, 80.0)];
    [bottomBar setBarStyle:UIBarStyleBlack];
    [bottomBar setBarTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeButtonPressed)];
    [closeButton setTintColor:[AppColor butlerSalmonPinkTextColor]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [bottomBar setItems:[NSArray arrayWithObjects:flexibleSpace, closeButton, flexibleSpace, nil] animated:YES];
    
    [self.view addSubview:self.homeTable];
    [self.view addSubview:bottomBar];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [AppColor butlerBlackBackgroundColor];
    
    UILabel *options = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width*2/3, cell.frame.size.height)];
    [options setText:[self.cellTitles objectAtIndex:indexPath.row]];
    [options setTextAlignment:NSTextAlignmentCenter];
    [options setFont:[UIFont fontWithName:AppFont_Lato_Regular size:15.0f]];
    [options setTextColor:[AppColor butlerSalmonPinkTextColor]];
    
    [cell addSubview:options];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingState *ss = [[SettingState alloc] init];
    
    switch (indexPath.row) {
        case 0:
            ss.settingType = OWNER;
            break;
            
        case 1:
            ss.settingType = BUTLER;
            break;
            
        default:
            NSLog(@"Control shouldn't reach here. Dismissing settings view.");
            [self closeButtonPressed];
            break;
    }
    
    [self presentUpdateViewForState:ss];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cellTitles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 200.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    footerView.backgroundColor = [AppColor butlerBackgroundColor];
    
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Settings";
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [profileImageView setImage:[UIImage imageNamed:@"akiprofile.jpg"]];
    profileImageView.layer.cornerRadius = 45;
    profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    profileImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    profileImageView.layer.borderWidth = .5;
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    [profileImageView setClipsToBounds:YES];
    
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectZero];
    headerView.backgroundColor = [AppColor butlerBackgroundColor];
    [headerView addSubview:profileImageView];
    
    NSLayoutConstraint *profileImageCenterYConstraint = [NSLayoutConstraint
                                                         constraintWithItem:profileImageView attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:headerView
                                                         attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    NSLayoutConstraint *profileImageCenterXConstraint  = [NSLayoutConstraint
                                                          constraintWithItem:profileImageView attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual toItem:headerView
                                                          attribute:NSLayoutAttributeCenterX multiplier:0.67 constant:0];
    
    NSLayoutConstraint *profileImageWidthConstraint  = [NSLayoutConstraint
                                                        constraintWithItem:profileImageView attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual toItem:nil
                                                        attribute:NSLayoutAttributeWidth multiplier:1 constant:90];
    
    NSLayoutConstraint *profileImageHeightConstraint  = [NSLayoutConstraint
                                                         constraintWithItem:profileImageView attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:profileImageView
                                                         attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    
    [headerView addConstraints:@[profileImageCenterXConstraint,profileImageCenterYConstraint,profileImageWidthConstraint,profileImageHeightConstraint]];
    
    return headerView;
}

- (void)presentUpdateViewForState:(SettingState *)state {
    [self.delegate didRequestUpdateForState:state];
}

- (void)closeButtonPressed {
    [self.delegate didDismissSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

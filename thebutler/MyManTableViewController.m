//
//  MyManTableViewController.m
//  thebutler
//
//  Created by Prayaas Jain on 8/27/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import "MyManTableViewController.h"

@interface MyManTableViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *cellTitles;

@end

@implementation MyManTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigationController];
    self.tableView.backgroundColor = [AppColor butlerBlackBackgroundColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cellTitles = @[@"Call Him",@"Text Him",@"I need to see his face!",@"Teleport him to me now!"];
    
}

-(void)setUpNavigationController {
    
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.leftBarButtonItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationItem setTitle:@"Prius"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [AppColor butlerBlackBackgroundColor];
    
    UILabel *options = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, cell.frame.size.height)];
    [options setText:[self.cellTitles objectAtIndex:indexPath.row]];
    [options setTextAlignment:NSTextAlignmentCenter];
    [options setFont:[UIFont fontWithName:AppFont_Lato_Regular size:15.0f]];
    [options setTextColor:[AppColor butlerWhiteTextColor]];
    
    [cell addSubview:options];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIApplication *myApp = [UIApplication sharedApplication];
    NSString *taskString = [NSString new];
    
    
    switch (indexPath.row) {
        case 0:
            NSLog(@"Custom action to be performed - show action sheet.");
            break;
        
        case 1:
            taskString = [NSString stringWithFormat:@"sms:1-562-537-0475"];
            break;
            
        case 2:
            taskString = [NSString stringWithFormat:@"facetime://prayaasjain@gmail.com"];
            break;
            
        case 3: {
            UIAlertView *sorryAlert = [[UIAlertView alloc] initWithTitle:@"Coming Soon"
                                                                 message:@"The Butler R&D team is working hard to finalize this feature!"
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
            [sorryAlert show];
        }
            
        default:
            break;
    }
    
    if(indexPath.row != 3 && indexPath.row != 0) {
        [myApp openURL:[NSURL URLWithString:taskString]];
    }
    else if (indexPath.row == 0) {
        
        UIAlertController *callActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSString *taskString2 = [NSString stringWithFormat:@"tel:1-562-537-0475"];
                                                                  [myApp openURL:[NSURL URLWithString:taskString2]];
                                                                  
                                                              }];
        UIAlertAction *ftAudioAction = [UIAlertAction actionWithTitle:@"Face Time Audio" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSString *taskString2 = [NSString stringWithFormat:@"facetime-audio://prayaasjain@gmail.com"];
                                                                  [myApp openURL:[NSURL URLWithString:taskString2]];
                                                              }];
        
        [callActionSheet addAction:callAction];
        [callActionSheet addAction:ftAudioAction];
        [callActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:callActionSheet animated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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
    [profileImageView setImage:[UIImage imageNamed:@"profile2.jpg"]];
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
                                                          attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
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

@end

//
//  ServicesViewController.m
//  thebutler
//
//  Created by Prayaas Jain on 8/21/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import "ServicesViewController.h"
#import "MyManTableViewController.h"
#import "RemindMeTableViewController.h"

#define BUTTON_ALPHA 0.8
#define LabelFontSize 18.0
#define ButtonFontSize 20.0

@interface ServicesViewController () {
    NSString *currentButler;
    NSString *currentOwner;
}

@property (nonatomic, strong) UIButton *getMyManButton;
@property (nonatomic, strong) UIButton *getMeFoodButton;
@property (nonatomic, strong) UIButton *remindMeButton;

@property (nonatomic, strong) UILabel *myManLabel;
@property (nonatomic, strong) UILabel *foodLabel;
@property (nonatomic, strong) UILabel *remindMeLabel;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) People *currentPeople;

@property (nonatomic, strong) MyManTableViewController *myManTableViewController;
@property (nonatomic, strong) RemindMeTableViewController *remindMeTableViewController;

@property (assign, nonatomic) BOOL showingSettingsView;

@end

static NSString *defaultButler = @"The Butler";
static NSString *defaultOwner = @"madam";

@implementation ServicesViewController

- (id)initWithPeople:(People *)people {
    
    if(self = [super init]) {
        self.currentPeople = people;
        currentButler = self.currentPeople.butler;
        currentOwner = self.currentPeople.owner;
    }
    
    return self;
}

- (void)updateServicesViewWithPeople:(People *)people {
    self.currentPeople = people;
    currentButler = self.currentPeople.butler;
    currentOwner = self.currentPeople.owner;
    
    [self updateDescriptorLabels];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[AppColor butlerBlackBackgroundColor]];
    
    if(currentButler == nil) {
        currentButler = [[NSString alloc] initWithString:defaultButler];
    }
    if(currentOwner == nil) {
        currentOwner = [[NSString alloc] initWithString:defaultOwner];
    }
        
    [self setupMainViewObjects];
    [self setUpNavigationController];
    
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.getMyManButton];
    [self.scrollView addSubview:self.getMeFoodButton];
    [self.scrollView addSubview:self.remindMeButton];
    [self.scrollView addSubview:self.myManLabel];
    [self.scrollView addSubview:self.foodLabel];
    [self.scrollView addSubview:self.remindMeLabel];
    
}

- (void)viewDidLayoutSubviews {
    [self setupConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)setUpNavigationController {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"settings-filled"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 32, 32)];
    [button addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [addBarButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = addBarButton;
}

- (void)setupMainViewObjects {
    self.scrollView  = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [AppColor butlerBlackBackgroundColor];
    self.scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    
    self.getMyManButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.getMyManButton addTarget:self
                              action:@selector(getMyManButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.getMyManButton setTitle:@"Get Me My Man" forState:UIControlStateNormal];
    [self.getMyManButton setEnabled:YES];
    [self.getMyManButton setBackgroundColor:[UIColor clearColor]];
    [self.getMyManButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
    [self.getMyManButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:ButtonFontSize]];
    [self.getMyManButton setAlpha:BUTTON_ALPHA];
    [[self.getMyManButton layer] setBorderWidth:1.0f];
    [[self.getMyManButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
    self.getMyManButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.getMeFoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.getMeFoodButton addTarget:self
                            action:@selector(getMeFoodButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.getMeFoodButton setTitle:@"Get Me Food" forState:UIControlStateNormal];
    [self.getMeFoodButton setEnabled:YES];
    [self.getMeFoodButton setBackgroundColor:[UIColor clearColor]];
    [self.getMeFoodButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
    [self.getMeFoodButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:ButtonFontSize]];
    [self.getMeFoodButton setAlpha:BUTTON_ALPHA];
    [[self.getMeFoodButton layer] setBorderWidth:1.0f];
    [[self.getMeFoodButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
    self.getMeFoodButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.remindMeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.remindMeButton addTarget:self
                            action:@selector(remindMeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.remindMeButton setTitle:@"Remind Me" forState:UIControlStateNormal];
    [self.remindMeButton setEnabled:YES];
    [self.remindMeButton setBackgroundColor:[UIColor clearColor]];
    [self.remindMeButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
    [self.remindMeButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:ButtonFontSize]];
    [self.remindMeButton setAlpha:BUTTON_ALPHA];
    [[self.remindMeButton layer] setBorderWidth:1.0f];
    [[self.remindMeButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
    self.remindMeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.myManLabel = [UILabel new];
    [self.myManLabel setText:[NSString stringWithFormat:@"%@ will get %@ her main man, no matter what it takes.", currentButler, currentOwner]];
    [self.myManLabel setTextColor:[AppColor butlerWhiteTextColor]];
    [self.myManLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myManLabel setFont:[UIFont fontWithName:AppFont_Lato_ThinItalic size:LabelFontSize]];
    [self.myManLabel setNumberOfLines:0];
    self.myManLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.foodLabel = [UILabel new];
    [self.foodLabel setText:[NSString stringWithFormat:@"%@ will find %@ her favorite food, as close as possible.", currentButler, currentOwner]];
    [self.foodLabel setTextColor:[AppColor butlerWhiteTextColor]];
    [self.foodLabel setTextAlignment:NSTextAlignmentCenter];
    [self.foodLabel setFont:[UIFont fontWithName:AppFont_Lato_ThinItalic size:LabelFontSize]];
    [self.foodLabel setNumberOfLines:0];
    self.foodLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.remindMeLabel = [UILabel new];
    [self.remindMeLabel setText:[NSString stringWithFormat:@"%@ will remind %@ of things to do, whenever needed.", currentButler, currentOwner]];
    [self.remindMeLabel setTextColor:[AppColor butlerWhiteTextColor]];
    [self.remindMeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.remindMeLabel setFont:[UIFont fontWithName:AppFont_Lato_ThinItalic size:LabelFontSize]];
    [self.remindMeLabel setNumberOfLines:0];
    self.remindMeLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateDescriptorLabels {
    [self.myManLabel setText:[NSString stringWithFormat:@"%@ will get %@ her main man, no matter what it takes.", currentButler, currentOwner]];
    [self.foodLabel setText:[NSString stringWithFormat:@"%@ will find %@ her favorite food, as close as possible.", currentButler, currentOwner]];
    [self.remindMeLabel setText:[NSString stringWithFormat:@"%@ will remind %@ of things to do, whenever needed.", currentButler, currentOwner]];
}

- (void)setupConstraints {
    
    id views = @{@"scrollView":self.scrollView,
                 @"myManButton":self.getMyManButton,
                 @"myManLabel": self.myManLabel,
                 @"foodButton":self.getMeFoodButton,
                 @"foodLabel":self.foodLabel,
                 @"remindButton":self.remindMeButton,
                 @"remindLabel":self.remindMeLabel
                 };
    
    id metrics = @{@"topMargin":@100,
                   @"bottomMargin":@100,
                   @"labelheight":@60,
                   @"leftMargin":@20,
                   @"rightMargin":@20,
                   @"labelButtonSpacing":@40,
                   @"buttonLabelSpacing":@0
                   };
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:metrics views:views]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[myManButton]-buttonLabelSpacing-[myManLabel]-labelButtonSpacing-[foodButton]-buttonLabelSpacing-[foodLabel]-labelButtonSpacing-[remindButton]-buttonLabelSpacing-[remindLabel]|" options:0 metrics:metrics views:views]];
    
    
    NSLayoutConstraint *getMyManButtonCenterXConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self.getMyManButton attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                             attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    NSLayoutConstraint *getMyManButtonCenterYConstraint = [NSLayoutConstraint
//                                                             constraintWithItem:self.getMyManButton attribute:NSLayoutAttributeCenterY
//                                                             relatedBy:NSLayoutRelationEqual toItem:self.scrollView
//                                                             attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *getMyManButtonHeightConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.getMyManButton attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                            attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
    NSLayoutConstraint *getMyManButtonWidthConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.getMyManButton attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                           attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
    
    NSLayoutConstraint *getMeFoodButtonCenterXConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.getMeFoodButton attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                           attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    NSLayoutConstraint *getMeFoodButtonCenterYConstraint = [NSLayoutConstraint
//                                                           constraintWithItem:self.getMeFoodButton attribute:NSLayoutAttributeCenterY
//                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
//                                                           attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *getMeFoodButtonHeightConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.getMeFoodButton attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                          attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
    NSLayoutConstraint *getMeFoodButtonWidthConstraint = [NSLayoutConstraint
                                                         constraintWithItem:self.getMeFoodButton attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                         attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
    
    NSLayoutConstraint *remindMeButtonCenterXConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.remindMeButton attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                           attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    NSLayoutConstraint *remindMeButtonCenterYConstraint = [NSLayoutConstraint
//                                                           constraintWithItem:self.remindMeButton attribute:NSLayoutAttributeCenterY
//                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
//                                                           attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *remindMeButtonHeightConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.remindMeButton attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                          attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
    NSLayoutConstraint *remindMeButtonWidthConstraint = [NSLayoutConstraint
                                                         constraintWithItem:self.remindMeButton attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                         attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
    
    NSLayoutConstraint *myManLabelCenterXConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.myManLabel attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                           attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    NSLayoutConstraint *myManLabelCenterYConstraint = [NSLayoutConstraint
//                                                           constraintWithItem:self.myManLabel attribute:NSLayoutAttributeCenterY
//                                                           relatedBy:NSLayoutRelationEqual toItem:self.scrollView
//                                                           attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *myManLabelHeightConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.myManLabel attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                          attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
    NSLayoutConstraint *myManLabelWidthConstraint = [NSLayoutConstraint
                                                         constraintWithItem:self.myManLabel attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                         attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0];
    
    NSLayoutConstraint *foodLabelCenterXConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.foodLabel attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                       attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    NSLayoutConstraint *foodLabelCenterYConstraint = [NSLayoutConstraint
//                                                       constraintWithItem:self.foodLabel attribute:NSLayoutAttributeCenterY
//                                                       relatedBy:NSLayoutRelationEqual toItem:self.scrollView
//                                                       attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *foodLabelHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.foodLabel attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                      attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
    NSLayoutConstraint *foodLabelWidthConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.foodLabel attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                     attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0];
    
    NSLayoutConstraint *remindLabelCenterXConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.remindMeLabel attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                       attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//    NSLayoutConstraint *remindLabelCenterYConstraint = [NSLayoutConstraint
//                                                       constraintWithItem:self.remindMeLabel attribute:NSLayoutAttributeCenterY
//                                                       relatedBy:NSLayoutRelationEqual toItem:self.scrollView
//                                                       attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *remindLabelHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.remindMeLabel attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                      attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
    NSLayoutConstraint *remindLabelWidthConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.remindMeLabel attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual toItem:self.scrollView
                                                     attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0];
    
    [self.scrollView addConstraints:@[getMyManButtonCenterXConstraint, getMyManButtonHeightConstraint, getMyManButtonWidthConstraint,
                                      getMeFoodButtonCenterXConstraint, getMeFoodButtonHeightConstraint, getMeFoodButtonWidthConstraint,
                                      remindMeButtonCenterXConstraint, remindMeButtonHeightConstraint, remindMeButtonWidthConstraint,
                                      myManLabelCenterXConstraint, myManLabelHeightConstraint, myManLabelWidthConstraint,
                                      foodLabelCenterXConstraint, foodLabelHeightConstraint, foodLabelWidthConstraint,
                                      remindLabelCenterXConstraint, remindLabelHeightConstraint, remindLabelWidthConstraint
                                      ]];
    
}



#pragma mark - Button Delegate Methods

- (IBAction)getMyManButtonPressed:(id)sender {    
    if(self.myManTableViewController == nil) {
        MyManTableViewController *mvc = [[MyManTableViewController alloc] init];
        self.myManTableViewController = mvc;
    }
    [self.navigationController pushViewController:self.myManTableViewController animated:YES];
}

- (IBAction)getMeFoodButtonPressed:(id)sender {
    UIAlertView *sorryAlert = [[UIAlertView alloc] initWithTitle:@"Our Apologies"
                                                          message:@"The Butler team is developing this feature. Sorry!"
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
    [sorryAlert show];
}

- (IBAction)remindMeButtonPressed:(id)sender {
//    if(self.remindMeTableViewController == nil) {
//        RemindMeTableViewController *rvc = [[RemindMeTableViewController alloc] init];
//        self.remindMeTableViewController = rvc;
//    }
    RemindMeTableViewController *rvc = [[RemindMeTableViewController alloc] init];
    self.remindMeTableViewController = rvc;
    [self.navigationController pushViewController:self.remindMeTableViewController animated:YES];
}

- (IBAction)settingsButtonPressed:(id)sender {
    [self.delegate didPressSettingsButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

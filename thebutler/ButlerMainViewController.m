//
//  ButlerMainViewController.m
//  thebutler
//
//  Created by Prayaas Jain on 10/24/15.
//  Copyright © 2015 Prayaas Jain. All rights reserved.
//

#import "ButlerMainViewController.h"
#import "MyManTableViewController.h"
#import "RemindMeTableViewController.h"
#import "SettingsViewController.h"
#import "ServicesViewController.h"
#import "ButlerCoreDataController.h"

#define SLIDE_TIMING .25
#define PANEL_OFFSET 100

typedef enum : NSInteger {
    ButlerNameTag = 0,
    YourNameTag,
} Tags;

static NSString *const butlerNamePlaceholder = @"Alfred";
static NSString *const yourNamePlaceholder = @"Batman";

@interface ButlerMainViewController () <ServicesViewControllerDelegate, SettingsViewControllerDelegate, UITextFieldDelegate> {
    NSString *currentButler;
    NSString *currentOwner;
    NSString *nameToUpdate;
    
    SettingState *currentState;
    
    BOOL shouldUpdateCoreDataRecord;
}

@property (strong, nonatomic) UIView *backgroundOverlayView;
@property (strong, nonatomic) UIView *settingsUpdateView;
@property (strong, nonatomic) UIVisualEffectView *blurView;

@property (nonatomic, strong) UILabel *settingsNameLabel;
@property (nonatomic, strong) UITextField *settingsNameField;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) NSArray *nameRecords;

@property (nonatomic, strong) People *currentPeople;
@property (nonatomic, strong) People *updatedPeople;

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) ServicesViewController *servicesViewController;
@property (nonatomic, strong) SettingsViewController *settingsViewController;

@property (assign, nonatomic) BOOL showingSettingsView;

@end

static NSString *defaultButler = @"The Butler";
static NSString *defaultOwner = @"madam";

@implementation ButlerMainViewController

- (id)initWithPeople:(People *)people {
    
    if(self = [super init]) {
        self.currentPeople = people;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[ButlerCoreDataController sharedInstance] masterManagedObjectContext];
    
    [self.view setBackgroundColor:[AppColor butlerBlackBackgroundColor]];
    
    self.servicesViewController = [[ServicesViewController alloc] initWithPeople:self.currentPeople];
    self.servicesViewController.title = @"Services";
    self.servicesViewController.delegate = self;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.servicesViewController];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:AppFont_Lato_Bold size:20.0], NSFontAttributeName,
                                [AppColor butlerSalmonPinkTextColor], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [self.view addSubview:self.navigationController.view];
    [self setNeedsStatusBarAppearanceUpdate];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Core Data Methods

- (void)fetchFromCoreData {
    
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext reset];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"People" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"butler" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        self.nameRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            
        }
        else {
            NSLog(@"Fetched record: %@", self.nameRecords);
        }
    }];
    
    NSLog(@"Number of records found: %lu", (unsigned long)[self.nameRecords count]);
    
    if([self.nameRecords count] > 0) {
        self.updatedPeople = [self.nameRecords objectAtIndex:0];
        NSLog(@"Record to update - Owner: %@, Butler: %@", self.updatedPeople.owner, self.updatedPeople.butler);
    }
    else {
        NSLog(@"No records in core data. Need user preferences.");
    }
}


#pragma mark - Settings View Manager Methods

- (UIView *)getSlideInViewRight {
    if (_settingsViewController == nil) {
        
        self.settingsViewController = [[SettingsViewController alloc] init];
        self.settingsViewController.delegate = self;
        
        [self.view addSubview:self.settingsViewController.view];
        
        [self addChildViewController:self.settingsViewController];
        [_settingsViewController didMoveToParentViewController:self];
        
        _settingsViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingSettingsView = YES;
    
    UIView *view = self.settingsViewController.view;
    return view;
}

- (void)slideInPanelFromRight {
    
    
    UIView *childView = [self getSlideInViewRight];
    [self.view bringSubviewToFront:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _settingsViewController.view.frame = CGRectMake(0 + self.view.frame.size.width/3, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }
     ];
    
}

- (void)slideOutPanelToRight {
    [self removeBackgroundOverlay];
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _settingsViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.showingSettingsView = NO;
                         }
                     }];
}

- (void)addBackgroundOverlay {
    if(_backgroundOverlayView == nil) {
        self.backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [_backgroundOverlayView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
        [self.view addSubview:self.backgroundOverlayView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideOutPanelToRight)];
        [self.backgroundOverlayView addGestureRecognizer:tap];
    }
    
    [_backgroundOverlayView setAlpha:0.0];
    [_backgroundOverlayView setHidden:NO];
    
    [self.view bringSubviewToFront:self.backgroundOverlayView];
    
    [UIView animateWithDuration:SLIDE_TIMING
                     animations:^{
                         [_backgroundOverlayView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
}

- (void)removeBackgroundOverlay {
    [UIView animateWithDuration:SLIDE_TIMING
                     animations:^{
                         [_backgroundOverlayView setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [_backgroundOverlayView setHidden:YES];
                     }
     ];
}

#pragma mark - UI Update Methods for Settings

- (void)presentSettingsUpdateView {
    
    self.settingsUpdateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.settingsUpdateView setAlpha:0.0];
    [self.view addSubview:self.settingsUpdateView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.settingsUpdateView addGestureRecognizer:tap];
    
    self.settingsNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.settingsNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.settingsNameLabel setTextColor:[AppColor butlerWhiteTextColor]];
    [self.settingsNameLabel setFont:[UIFont fontWithName:AppFont_Lato_Regular size:20]];
    [self.settingsNameLabel setNumberOfLines:0];
    self.settingsNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.settingsNameField = [[UITextField alloc] init];
    self.settingsNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.settingsNameField setBackgroundColor:[UIColor whiteColor]];
    
    if(currentState.settingType == OWNER) {
        [self.settingsNameLabel setText:@"How would you like your butler to address you?"];
        [self setTextFieldProperties:self.settingsNameField withPlaceholder:yourNamePlaceholder withTag:YourNameTag];
    }
    else if(currentState.settingType == BUTLER) {
        [self.settingsNameLabel setText:@"How would you like to address your butler?"];
        [self setTextFieldProperties:self.settingsNameField withPlaceholder:butlerNamePlaceholder withTag:ButlerNameTag];
    }
    else {
        NSLog(@"This should technically never be true. Oops.");
    }
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton addTarget:self
                        action:@selector(doneButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton setEnabled:YES];
    [self.doneButton setBackgroundColor:[UIColor clearColor]];
    [self.doneButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
    [self.doneButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:20]];
    [self.doneButton setAlpha:0.8];
    [[self.doneButton layer] setBorderWidth:1.0f];
    [[self.doneButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.settingsUpdateView addSubview:self.settingsNameLabel];
    [self.settingsUpdateView addSubview:self.settingsNameField];
    [self.settingsUpdateView addSubview:self.doneButton];
    
    [self setupConstraintsForSettingsUpdateView];
    
    UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-80.0, self.view.bounds.size.width, 80.0)];
    [bottomBar setBarStyle:UIBarStyleBlack];
    [bottomBar setTintColor:[UIColor clearColor]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeButtonPressed)];
    [closeButton setTintColor:[AppColor butlerSalmonPinkTextColor]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [bottomBar setItems:[NSArray arrayWithObjects:flexibleSpace, closeButton, flexibleSpace, nil] animated:YES];
    
    [self.settingsUpdateView addSubview:bottomBar];
    
    [UIView animateWithDuration:SLIDE_TIMING
                     animations:^{
                         [self.settingsUpdateView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

- (void)setupConstraintsForSettingsUpdateView {
    
    NSLayoutConstraint *settingsNameLabelCenterXConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.settingsNameLabel attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                            attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *settingsNameLabelCenterYConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.settingsNameLabel attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                            attribute:NSLayoutAttributeCenterY multiplier:0.8 constant:0];
    
    NSLayoutConstraint *settingsNameLabelHeightConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.settingsNameLabel attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                           attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
    NSLayoutConstraint *settingsNameLabelWidthConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.settingsNameLabel attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                          attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *settingsNameFieldCenterXConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.settingsNameField attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                            attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *settingsNameFieldCenterYConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.settingsNameField attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                            attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *settingsNameFieldHeightConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.settingsNameField attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                           attribute:NSLayoutAttributeHeight multiplier:0.06 constant:0];
    NSLayoutConstraint *settingsNameFieldWidthConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.settingsNameField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                          attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *doneButtonCenterXConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                       attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *doneButtonCenterYConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                       attribute:NSLayoutAttributeCenterY multiplier:1.2 constant:0];
    
    NSLayoutConstraint *doneButtonHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.doneButton attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                      attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
    NSLayoutConstraint *doneButtonWidthConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.doneButton attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual toItem:self.settingsUpdateView
                                                     attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
    
    [self.view addConstraints:@[settingsNameLabelCenterXConstraint,settingsNameLabelCenterYConstraint,settingsNameLabelHeightConstraint,settingsNameLabelWidthConstraint,
                                settingsNameFieldCenterXConstraint,settingsNameFieldCenterYConstraint,settingsNameFieldHeightConstraint,settingsNameFieldWidthConstraint,
                                doneButtonCenterXConstraint,doneButtonCenterYConstraint,doneButtonHeightConstraint,doneButtonWidthConstraint]];
}

- (void)addBlurView {
    if(_blurView == nil) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [self.blurView setAlpha:1.0];
        [self.blurView setFrame:self.view.bounds];
        [self.view addSubview:self.blurView];
    }
    
    [_blurView setAlpha:0.0];
    [_blurView setHidden:NO];
    
    [self.view bringSubviewToFront:self.backgroundOverlayView];
    
    [UIView animateWithDuration:SLIDE_TIMING
                     animations:^{
                         [_blurView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

- (void)removeBlurView {
    [UIView animateWithDuration:SLIDE_TIMING
                     animations:^{
                         [_blurView setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [_blurView setHidden:YES];
                     }
     ];
}

- (void)removeSettingsUpdateView {
    [UIView animateWithDuration:SLIDE_TIMING
                     animations:^{
                         [self.settingsUpdateView setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [self.settingsUpdateView setHidden:YES];
                         self.settingsUpdateView = nil;
                     }
     ];
}

- (void)setTextFieldProperties:(UITextField *)inputField withPlaceholder:(NSString*)placeholder withTag:(NSInteger)tag {
    inputField.text = placeholder;
    inputField.textColor = [UIColor lightGrayColor];
    inputField.font = [UIFont fontWithName:AppFont_Lato_Light size:18.0f];
    inputField.textAlignment = NSTextAlignmentCenter;
    inputField.translatesAutoresizingMaskIntoConstraints = NO;
    inputField.layer.cornerRadius = 0;
    inputField.clipsToBounds = YES;
    inputField.tag = tag;
    inputField.delegate = self;
    [inputField setReturnKeyType:UIReturnKeyDone];
    [inputField setKeyboardAppearance:UIKeyboardAppearanceDark];
    
}

#pragma mark - Text Field Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        [self doneButtonPressed:nil];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if([textField.text isEqualToString:butlerNamePlaceholder] || [textField.text isEqualToString:yourNamePlaceholder])
    {
        textField.text = @"";
        textField.textColor = [UIColor blackColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField.text isEqualToString:@""]) {
        
        if(textField.tag == ButlerNameTag) {
            textField.text = butlerNamePlaceholder;
            textField.textColor = [UIColor grayColor];
        }
        else if (textField.tag == YourNameTag) {
            textField.text = yourNamePlaceholder;
            textField.textColor = [UIColor grayColor];
        }
        
        [textField resignFirstResponder];
    }
}

- (void)dismissKeyboard {
    [self.settingsNameField resignFirstResponder];
}

#pragma mark - ServicesViewControllerDelegate Methods

- (void)didPressSettingsButton {
    [self addBackgroundOverlay];
    [self slideInPanelFromRight];
}

#pragma mark - SettingsViewControllerDelegate Methods

- (void)didDismissSettings {
    [self slideOutPanelToRight];
}

- (void)didRequestUpdateForState:(SettingState *)state {
    
    currentState = state;
    
    [self fetchFromCoreData];
    
    [self slideOutPanelToRight];
    [self addBlurView];
    [self presentSettingsUpdateView];
    
    NSLog(@"Update state: %d", state.settingType);
    
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissKeyboard];
    [self removeSettingsUpdateView];
    [self removeBlurView];
    
    nameToUpdate = self.settingsNameField.text;
    
    if(![nameToUpdate isEqualToString:@""]) {
        shouldUpdateCoreDataRecord = TRUE;
        
        if(currentState.settingType == OWNER) {
            [self.updatedPeople setOwner:nameToUpdate];
            NSLog(@"Updated owner name set: %@", self.updatedPeople.owner);
        }
        else if(currentState.settingType == BUTLER) {
            [self.updatedPeople setButler:nameToUpdate];
            NSLog(@"Updated butler name set: %@", self.updatedPeople.butler);
        }
        else {
            NSLog(@"Control shouldn't reach here while updating. We have a problem.");
        }
    }
    else {
        NSLog(@"User didn't set a value, not updating core data record.");
        shouldUpdateCoreDataRecord = FALSE;
    }
    
    if(shouldUpdateCoreDataRecord) {
        [[ButlerCoreDataController sharedInstance] saveMasterContext];
        [self.servicesViewController updateServicesViewWithPeople:self.updatedPeople];
    }
    else {
        NSLog(@"Not updating core data record. Complete values not received from user.");
    }
}

- (void)closeButtonPressed {
    [self removeSettingsUpdateView];
    [self removeBlurView];
    
    NSLog(@"User closed update settings view. No need for changes.");
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

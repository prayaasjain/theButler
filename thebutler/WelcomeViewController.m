//
//  ViewController.m
//  thebutler
//
//  Created by Prayaas Jain on 8/4/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ServicesViewController.h"
#import "ButlerCoreDataController.h"
#import "ButlerMainViewController.h"
#import "People.h"

typedef enum : NSInteger {
    ButlerNameTag = 0,
    YourNameTag,
} Tags;

static NSString *const butlerNamePlaceholder = @"Alfred";
static NSString *const yourNamePlaceholder = @"Batman";

@interface WelcomeViewController () <UITextFieldDelegate> {
    UIView *backgroundOverlayView;
    
    UIImageView *backgroundView;
    UIImageView *backgroundView2;
    UIImageView *currentView;
    UIImageView *previousView;
    
    UILabel *appTitle;
    UILabel *welcomeLabel;
    
    NSTimer *backgroundImageTimer;
    
    NSString *butlerName;
    NSString *ownerName;
    
    int imageIndex;
    
    BOOL shouldSaveToCoreData;
    BOOL userPreferencesAvailable;
}

@property (nonatomic, strong) ButlerMainViewController *mainViewController;

@property (nonatomic, strong) NSArray *backgroundImages;
@property (nonatomic, strong) NSArray *nameRecords;

@property (nonatomic, strong) UIButton *getStartedButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *continueButton;

@property (nonatomic, strong) UIView *welcomeScreen1;
@property (nonatomic, strong) UIView *welcomeScreen2;
@property (nonatomic, strong) UIView *welcomeScreen3;

@property (nonatomic, strong) UILabel *welcomeBackLabel;
@property (nonatomic, strong) UILabel *nameYourButlerLabel;
@property (nonatomic, strong) UILabel *yourCallNameLabel;

@property (nonatomic, strong) UITextField *butlerNameField;
@property (nonatomic, strong) UITextField *yourNameField;

@property (nonatomic, strong) People *currentPeople;

@end

@implementation WelcomeViewController

static float bgImageAlpha = 1.00;
static float overlayAlpha = 0.60;
static float titleLabelHeight = 100.0;
static float titleSize = 60.0;
static float spacing_large = 100;

static NSString *welcomeText = @"";

@synthesize backgroundImages, getStartedButton, welcomeScreen1, welcomeScreen2, welcomeScreen3;
@synthesize mainViewController;
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [[ButlerCoreDataController sharedInstance] masterManagedObjectContext];
    
    shouldSaveToCoreData = FALSE;
    userPreferencesAvailable = FALSE;
    
    [self fetchFromCoreData];
    [self setupBackground];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self.welcomeScreen2 addGestureRecognizer:tap];
    [self.welcomeScreen3 addGestureRecognizer:tap];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
        
//        [request setSortDescriptors:[NSArray arrayWithObject:
//                                     [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"author = %@", @"Akhil"];
//        NSPredicate *predicate3 =[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate1, predicate2,nil]];
//        
//        [request setPredicate:predicate3];
        
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
        self.currentPeople = [self.nameRecords objectAtIndex:0];
        NSLog(@"Owner: %@, Butler: %@", self.currentPeople.owner, self.currentPeople.butler);
        userPreferencesAvailable = TRUE;
    }
    else {
        userPreferencesAvailable = FALSE;
        NSLog(@"No records in core data. Need user preferences.");
    }
}

#pragma mark - Background UI Update Methods

- (void)setupBackground {
    
    backgroundImages = @[@"bg1.jpeg",
                         @"bg2.jpeg",
                         @"bg3.jpeg",
                         @"bg4.jpeg",
                         @"bg5.jpeg",
                         @"bg6.jpeg",
                         @"bg7.jpeg",
                         @"bg8.jpeg"];
    
    srand(getppid());
    imageIndex = (rand()%176)/25;
    
    backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [backgroundView setImage:[UIImage imageNamed:[backgroundImages objectAtIndex:imageIndex]]];
    [backgroundView setAlpha:bgImageAlpha];
    [self.view addSubview:backgroundView];
    
    backgroundView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backgroundView2 setBackgroundColor:[UIColor clearColor]];
    [backgroundView2 setImage:[UIImage imageNamed:[backgroundImages objectAtIndex:imageIndex]]];
    [backgroundView2 setAlpha:0.00];
    [self.view addSubview:backgroundView2];
    
    backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backgroundOverlayView setBackgroundColor:[UIColor blackColor]];
    [backgroundOverlayView setAlpha:overlayAlpha];
    [self.view addSubview:backgroundOverlayView];
    
    currentView = backgroundView;
    previousView = backgroundView2;
    
    backgroundImageTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(updateBackgroundImage) userInfo:nil repeats:YES];
    
    [self setupBackgroundOverlayView];
}

- (void)setupBackgroundOverlayView {
    
    appTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, titleLabelHeight)];
    [appTitle setText:@"The Butler"];
    [appTitle setTextColor:[UIColor whiteColor]];
    [appTitle setTextAlignment:NSTextAlignmentCenter];
    [appTitle setFont:[UIFont fontWithName:AppFont_Bellerose size:titleSize]];
    [appTitle setAlpha:0.0];
    [self.view addSubview:appTitle];
    
    [self animateAppTitle];
}

- (void)animateAppTitle {
    
    float newY = (self.view.frame.size.height/2 - appTitle.frame.size.height - spacing_large*2);
    CGRect newFrame = CGRectMake(0, newY, self.view.frame.size.width, titleLabelHeight);
    
    [self setupFirstWelcomeScreen];
    [UIView animateWithDuration:2.0
                     animations:^(void) {
                         [appTitle setFrame:newFrame];
                         [appTitle setAlpha:1.0];
                         
                         if(userPreferencesAvailable) {
                             [self.welcomeBackLabel setAlpha:1.0];
                             [self.continueButton setAlpha:0.8];
                         }
                         else {
                             [self.getStartedButton setAlpha:0.8];
                         }
                         
                     }completion:^(BOOL finished) {
                         
                     }];
}

- (void)updateBackgroundImage {
    if(imageIndex >= [backgroundImages count]-1)
        imageIndex = 0;
    else
        imageIndex++;
    
    [previousView setImage:[UIImage imageNamed:[backgroundImages objectAtIndex:imageIndex]]];
    [self swapBackgroundViews];
    
    [UIView animateWithDuration:2.0
                     animations:^(void) {
                         [currentView setAlpha:bgImageAlpha];
                         [previousView setAlpha:0.00];
                     }completion:^(BOOL finished) {
                         
                     }];
}

- (void)swapBackgroundViews {
    UIImageView *temp;
    temp = currentView;
    currentView = previousView;
    previousView = temp;
}

#pragma mark - Welcome Setup Methods

- (void)setupFirstWelcomeScreen {
    
    self.welcomeScreen1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.welcomeScreen1];
    
    if(userPreferencesAvailable) {
        
        self.welcomeBackLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.welcomeBackLabel setText:[NSString stringWithFormat:@"Welcome back %@", self.currentPeople.owner]];
        [self.welcomeBackLabel setTextAlignment:NSTextAlignmentCenter];
        [self.welcomeBackLabel setTextColor:[AppColor butlerWhiteTextColor]];
        [self.welcomeBackLabel setFont:[UIFont fontWithName:AppFont_Lato_Regular size:25]];
        [self.welcomeBackLabel setNumberOfLines:0];
        [self.welcomeBackLabel setAlpha:0.0];
        self.welcomeBackLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.continueButton addTarget:self
                            action:@selector(doneButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [self.continueButton setEnabled:YES];
        [self.continueButton setBackgroundColor:[UIColor clearColor]];
        [self.continueButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
        [self.continueButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:20]];
        [self.continueButton setAlpha:0.0];
        [[self.continueButton layer] setBorderWidth:1.0f];
        [[self.continueButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
        self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.welcomeScreen1 addSubview:self.welcomeBackLabel];
        [self.welcomeScreen1 addSubview:self.continueButton];
        
    }
    else {
       
        self.getStartedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.getStartedButton addTarget:self
                                  action:@selector(getStartedButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
        [self.getStartedButton setTitle:@"Get Started" forState:UIControlStateNormal];
        [self.getStartedButton setEnabled:YES];
        [self.getStartedButton setBackgroundColor:[UIColor clearColor]];
        [self.getStartedButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
        [self.getStartedButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:20]];
        [self.getStartedButton setAlpha:0.0];
        [[self.getStartedButton layer] setBorderWidth:1.0f];
        [[self.getStartedButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
        self.getStartedButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.welcomeScreen1 addSubview:self.getStartedButton];
        
    }

    [self setupConstraintsForWelcome1];
    
}

- (void)setupConstraintsForWelcome1 {
    
    if(userPreferencesAvailable) {
        
        NSLayoutConstraint *welcomeBackLabelCenterXConstraint = [NSLayoutConstraint
                                                                constraintWithItem:self.welcomeBackLabel attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *welcomeBackLabelCenterYConstraint = [NSLayoutConstraint
                                                                constraintWithItem:self.welcomeBackLabel attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                attribute:NSLayoutAttributeCenterY multiplier:0.9 constant:0];
        
        NSLayoutConstraint *welcomeBackLabelHeightConstraint = [NSLayoutConstraint
                                                               constraintWithItem:self.welcomeBackLabel attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                               attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
        NSLayoutConstraint *welcomeBackLabelWidthConstraint = [NSLayoutConstraint
                                                              constraintWithItem:self.welcomeBackLabel attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                              attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
        
        NSLayoutConstraint *continueButtonCenterXConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.continueButton attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                 attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *continueButtonCenterYConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.continueButton attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                 attribute:NSLayoutAttributeCenterY multiplier:1.1 constant:0];
        
        NSLayoutConstraint *continueButtonHeightConstraint = [NSLayoutConstraint
                                                                constraintWithItem:self.continueButton attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
        NSLayoutConstraint *continueButtonWidthConstraint = [NSLayoutConstraint
                                                               constraintWithItem:self.continueButton attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                               attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
        
        [self.view addConstraints:@[welcomeBackLabelCenterXConstraint,welcomeBackLabelCenterYConstraint,welcomeBackLabelHeightConstraint,welcomeBackLabelWidthConstraint,
                                    continueButtonCenterXConstraint,continueButtonCenterYConstraint,continueButtonHeightConstraint,continueButtonWidthConstraint]];
    }
    else {
        
        NSLayoutConstraint *getStartedButtonCenterXConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.getStartedButton attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                 attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *getStartedButtonCenterYConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.getStartedButton attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                 attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        NSLayoutConstraint *getStartedButtonHeightConstraint = [NSLayoutConstraint
                                                                constraintWithItem:self.getStartedButton attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                                attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
        NSLayoutConstraint *getStartedButtonWidthConstraint = [NSLayoutConstraint
                                                               constraintWithItem:self.getStartedButton attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen1
                                                               attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
        
        [self.view addConstraints:@[getStartedButtonCenterXConstraint,getStartedButtonCenterYConstraint,getStartedButtonHeightConstraint,getStartedButtonWidthConstraint]];
        
    }
    
}

- (void)setupSecondWelcomeScreen {
    
    self.welcomeScreen2 = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.welcomeScreen2];
    
    self.nameYourButlerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.nameYourButlerLabel setText:@"How would you like to address your butler?"];
    [self.nameYourButlerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.nameYourButlerLabel setTextColor:[AppColor butlerWhiteTextColor]];
    [self.nameYourButlerLabel setFont:[UIFont fontWithName:AppFont_Lato_Regular size:20]];
    [self.nameYourButlerLabel setNumberOfLines:0];
    self.nameYourButlerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.butlerNameField = [[UITextField alloc] init];
    self.butlerNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.butlerNameField setBackgroundColor:[UIColor whiteColor]];
    [self setTextFieldProperties:self.butlerNameField withPlaceholder:butlerNamePlaceholder withTag:ButlerNameTag];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton addTarget:self
                              action:@selector(nextButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton setEnabled:YES];
    [self.nextButton setBackgroundColor:[UIColor clearColor]];
    [self.nextButton setTitleColor:[AppColor butlerWhiteButtonColor] forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:AppFont_Lato_Light size:20]];
    [self.nextButton setAlpha:0.8];
    [[self.nextButton layer] setBorderWidth:1.0f];
    [[self.nextButton layer] setBorderColor:((UIColor *)[AppColor butlerWhiteButtonColor]).CGColor];
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.welcomeScreen2 addSubview:self.nameYourButlerLabel];
    [self.welcomeScreen2 addSubview:self.butlerNameField];
    [self.welcomeScreen2 addSubview:self.nextButton];
    
    [self setupConstraintsForWelcome2];
}

- (void)setupConstraintsForWelcome2 {
    
    NSLayoutConstraint *nameButlerLabelCenterXConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.nameYourButlerLabel attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                       attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *nameButlerLabelCenterYConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.nameYourButlerLabel attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                       attribute:NSLayoutAttributeCenterY multiplier:0.8 constant:0];
    
    NSLayoutConstraint *nameButlerLabelHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.nameYourButlerLabel attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                      attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
    NSLayoutConstraint *nameButlerLabelWidthConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.nameYourButlerLabel attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                     attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *butlerTextFieldCenterXConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.butlerNameField attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                            attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *butlerTextFieldCenterYConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.butlerNameField attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                            attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *butlerTextFieldHeightConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.butlerNameField attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                           attribute:NSLayoutAttributeHeight multiplier:0.06 constant:0];
    NSLayoutConstraint *butlerTextFieldWidthConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.butlerNameField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                          attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *nextButtonCenterXConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self.nextButton attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                             attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *nextButtonCenterYConstraint = [NSLayoutConstraint
                                                             constraintWithItem:self.nextButton attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                             attribute:NSLayoutAttributeCenterY multiplier:1.2 constant:0];
    
    NSLayoutConstraint *nextButtonHeightConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.nextButton attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                            attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
    NSLayoutConstraint *nextButtonWidthConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.nextButton attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen2
                                                           attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
    
    [self.view addConstraints:@[nameButlerLabelCenterXConstraint,nameButlerLabelCenterYConstraint,nameButlerLabelHeightConstraint,nameButlerLabelWidthConstraint,
                                butlerTextFieldCenterXConstraint,butlerTextFieldCenterYConstraint,butlerTextFieldHeightConstraint,butlerTextFieldWidthConstraint,
                                nextButtonCenterXConstraint,nextButtonCenterYConstraint,nextButtonHeightConstraint,nextButtonWidthConstraint]];
}

- (void)setupThirdWelcomeScreen {
    
    self.welcomeScreen3 = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.welcomeScreen3];
    
    self.yourCallNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.yourCallNameLabel setText:@"How would you like your butler to address you?"];
    [self.yourCallNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.yourCallNameLabel setTextColor:[AppColor butlerWhiteTextColor]];
    [self.yourCallNameLabel setFont:[UIFont fontWithName:AppFont_Lato_Regular size:20]];
    [self.yourCallNameLabel setNumberOfLines:0];
    self.yourCallNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.yourNameField = [[UITextField alloc] init];
    self.yourNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.yourNameField setBackgroundColor:[UIColor whiteColor]];
    [self setTextFieldProperties:self.yourNameField withPlaceholder:yourNamePlaceholder withTag:YourNameTag];
    
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
    
    [self.welcomeScreen3 addSubview:self.yourCallNameLabel];
    [self.welcomeScreen3 addSubview:self.yourNameField];
    [self.welcomeScreen3 addSubview:self.doneButton];
    
    [self setupConstraintsForWelcome3];
}

- (void)setupConstraintsForWelcome3 {
    
    NSLayoutConstraint *yourNameLabelCenterXConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.yourCallNameLabel attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                            attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *yourNameLabelCenterYConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.yourCallNameLabel attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                            attribute:NSLayoutAttributeCenterY multiplier:0.8 constant:0];
    
    NSLayoutConstraint *yourNameLabelHeightConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.yourCallNameLabel attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                           attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0];
    NSLayoutConstraint *yourNameLabelWidthConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.yourCallNameLabel attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                          attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *yourNameTextFieldCenterXConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.yourNameField attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                            attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *yourNameTextFieldCenterYConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.yourNameField attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                            attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *yourNameTextFieldHeightConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.yourNameField attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                           attribute:NSLayoutAttributeHeight multiplier:0.06 constant:0];
    NSLayoutConstraint *yourNameTextFieldWidthConstraint = [NSLayoutConstraint
                                                          constraintWithItem:self.yourNameField attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                          attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    
    NSLayoutConstraint *doneButtonCenterXConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                       attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *doneButtonCenterYConstraint = [NSLayoutConstraint
                                                       constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                       attribute:NSLayoutAttributeCenterY multiplier:1.2 constant:0];
    
    NSLayoutConstraint *doneButtonHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.doneButton attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                      attribute:NSLayoutAttributeHeight multiplier:0.05 constant:0];
    NSLayoutConstraint *doneButtonWidthConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.doneButton attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual toItem:self.welcomeScreen3
                                                     attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0];
    
    [self.view addConstraints:@[yourNameLabelCenterXConstraint,yourNameLabelCenterYConstraint,yourNameLabelHeightConstraint,yourNameLabelWidthConstraint,
                                yourNameTextFieldCenterXConstraint,yourNameTextFieldCenterYConstraint,yourNameTextFieldHeightConstraint,yourNameTextFieldWidthConstraint,
                                doneButtonCenterXConstraint,doneButtonCenterYConstraint,doneButtonHeightConstraint,doneButtonWidthConstraint]];
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
    [self.butlerNameField resignFirstResponder];
    [self.yourNameField resignFirstResponder];
}

#pragma mark - Button Pressed Methods

- (IBAction)getStartedButtonPressed:(id)sender {

    [self setupSecondWelcomeScreen];
    
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         [self.welcomeScreen1 setFrame:CGRectMake(0-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
                         [self.welcomeScreen2 setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
    
}

- (IBAction)nextButtonPressed:(id)sender {
    
    butlerName = self.butlerNameField.text;
    
    [self dismissKeyboard];
    [self setupThirdWelcomeScreen];
    
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         [self.welcomeScreen2 setFrame:CGRectMake(0-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
                         [self.welcomeScreen3 setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }
     ];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if(!userPreferencesAvailable) {
        ownerName = self.yourNameField.text;
        
        self.currentPeople = [NSEntityDescription insertNewObjectForEntityForName:@"People" inManagedObjectContext:self.managedObjectContext];
        
        if(![butlerName isEqualToString:@""]) {
            [self.currentPeople setButler:butlerName];
            shouldSaveToCoreData = TRUE;
            
            NSLog(@"New butler name set: %@", self.currentPeople.butler);
        }
        if(![ownerName isEqualToString:@""]) {
            [self.currentPeople setOwner:ownerName];
            shouldSaveToCoreData = TRUE;
            
            NSLog(@"New owner name set: %@", self.currentPeople.owner);
        }
        if([butlerName isEqualToString:@""] || [ownerName isEqualToString:@""]) {
            NSLog(@"User didn't set one or both the values, not updating core data record.");
            shouldSaveToCoreData = FALSE;
        }
        
        if(shouldSaveToCoreData) {
            [[ButlerCoreDataController sharedInstance] saveMasterContext];
        }
        else {
            NSLog(@"Not creating core data record. Complete values not received from user.");
        }
        
        [self dismissKeyboard];
    }
    
    mainViewController = [[ButlerMainViewController alloc] initWithPeople:self.currentPeople];

    [mainViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:mainViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

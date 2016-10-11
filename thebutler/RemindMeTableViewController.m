//
//  RemindMeTableViewController.m
//  thebutler
//
//  Created by Prayaas Jain on 9/1/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

@import EventKit;

#import "RemindMeTableViewController.h"
#import "UIAlertView+RWBlock.h"
#import "UIButton+RWBlock.h"

@interface RemindMeTableViewController ()

// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;

// Indicates whether app has access to event store.
@property (nonatomic) BOOL isAccessToEventStoreGranted;

// The data source for the table view
@property (strong, nonatomic) NSMutableArray *todoItems;

@property (strong, nonatomic) EKCalendar *calendar;

@property (copy, nonatomic) NSArray *reminders;

@end

@implementation RemindMeTableViewController

- (NSMutableArray *)todoItems {
    if (!_todoItems) {
        _todoItems = [@[@"Get Milk!", @"Go To The Gym", @"Breakfast With P!", @"Call Maa", @"Pick Up Food"] mutableCopy];
    }
    return _todoItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [AppColor butlerBlackBackgroundColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 20)];
    
    [self setUpNavigationController];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self updateAuthorizationStatusToAccessEventStore];
    
    [self fetchReminders];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchReminders)
                                                 name:EKEventStoreChangedNotification object:nil];
    
}

-(void)setUpNavigationController {
    
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.leftBarButtonItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationItem setTitle:@"Reminders"];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    [addBarButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = addBarButton;
    
}

#pragma mark - EventKit Methods

- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void)updateAuthorizationStatusToAccessEventStore {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted: {
            self.isAccessToEventStoreGranted = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                message:@"This app doesn't have access to your Reminders." delegate:nil
                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            [self.tableView reloadData];
            break;
        }
            
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            [self.tableView reloadData];
            break;
            
        case EKAuthorizationStatusNotDetermined: {
            __weak RemindMeTableViewController *weakSelf = self;
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    weakSelf.isAccessToEventStoreGranted = granted;
                                                    [weakSelf.tableView reloadData];
                                                });
                                            }];
            break;
        }
    }
}

- (EKCalendar *)calendar {
    if (!_calendar) {
        
        NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        NSString *calendarTitle = @"Butler's List";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
        NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
        
        if ([filtered count]) {
            _calendar = [filtered firstObject];
        } else {
            
            _calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventStore];
            _calendar.title = @"Butler's List";
            _calendar.source = self.eventStore.defaultCalendarForNewReminders.source;
            
            NSError *calendarErr = nil;
            BOOL calendarSuccess = [self.eventStore saveCalendar:_calendar commit:YES error:&calendarErr];
            if (!calendarSuccess) {
                // Handle error
                NSLog(@"Error creating list!");
            }
        }
    }
    return _calendar;
}

- (void)addReminderForToDoItem:(NSString *)item {
    if (!self.isAccessToEventStoreGranted)
        return;
    
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
    reminder.title = item;
    reminder.calendar = self.calendar;
//    reminder.dueDateComponents = [self dateComponentsForDefaultDueDate];
    
    NSError *error = nil;
    BOOL success = [self.eventStore saveReminder:reminder commit:YES error:&error];
    if (!success) {
        // Handle error.
        NSLog(@"Error saving reminder!");
    }
    
    NSString *message = (success) ? @"Reminder Added!" : @"Failed to add reminder!";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alertView show];
}

- (void)fetchReminders {
    if (self.isAccessToEventStoreGranted) {
        NSPredicate *predicate =
        [self.eventStore predicateForRemindersInCalendars:@[self.calendar]];
        
        [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminders) {
            self.reminders = reminders;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)deleteReminderForToDoItem:(NSString *)item {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", item];
    NSArray *results = [self.reminders filteredArrayUsingPredicate:predicate];
    
    if ([results count]) {
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSError *error = nil;
            BOOL success = [self.eventStore removeReminder:obj commit:NO error:&error];
            if (!success) {
                // Handle delete error
                NSLog(@"Delete reminder error!");
            }
        }];
        
        NSError *commitErr = nil;
        BOOL success = [self.eventStore commit:&commitErr];
        if (!success) {
            // Handle commit error.
            NSLog(@"Delete reminder commit error!");
        }
    }
}

- (BOOL)itemHasReminder:(NSString *)item {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", item];
    NSArray *filtered = [self.reminders filteredArrayUsingPredicate:predicate];
    return (self.isAccessToEventStoreGranted && [filtered count]);
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.todoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *kIdentifier = @"Cell Identifier";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
    
    // Update cell content from data source.
    NSString *object = self.todoItems[indexPath.row];
    cell.backgroundColor = [AppColor butlerBlackBackgroundColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = object;
    [cell.textLabel setFont:[UIFont fontWithName:AppFont_Lato_Regular size:15.0f]];
    [cell.textLabel setTextColor:[AppColor butlerWhiteTextColor]];
    
    if (![self itemHasReminder:object]) {
        // Add a button as accessory view that says 'Add Reminder'.
        UIButton *addReminderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addReminderButton.frame = CGRectMake(0.0, 0.0, 100.0, 30.0);
        [addReminderButton setTitle:@"Add Reminder" forState:UIControlStateNormal];
        [addReminderButton setTitleColor:[AppColor butlerSalmonPinkTextColor] forState:UIControlStateNormal];
        
        [addReminderButton addActionblock:^(UIButton *sender) {
            [self addReminderForToDoItem:object];
        } forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = addReminderButton;
        
    } else {
        cell.accessoryView = nil;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", object];
        NSArray *reminders = [self.reminders filteredArrayUsingPredicate:predicate];
        EKReminder *reminder = [reminders firstObject];
        cell.imageView.image = (reminder.isCompleted) ? [UIImage imageNamed:@"checkmarkON"] : [UIImage imageNamed:@"checkmarkOFF"];
        
        if (reminder.dueDateComponents) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *dueDate = [calendar dateFromComponents:reminder.dueDateComponents];
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:dueDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *toDoItem = self.todoItems[indexPath.row];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", toDoItem];
    
    // Assume there are no duplicates...
    NSArray *results = [self.reminders filteredArrayUsingPredicate:predicate];
    EKReminder *reminder = [results firstObject];
    reminder.completed = !reminder.isCompleted;
    
    NSError *error;
    [self.eventStore saveReminder:reminder commit:YES error:&error];
    if (error) {
        // Handle error
    }
    
    cell.imageView.image = (reminder.isCompleted) ? [UIImage imageNamed:@"checkmarkON"] : [UIImage imageNamed:@"checkmarkOFF"];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *todoItem = self.todoItems[indexPath.row];
    
    // Remove to-do item.
    [self.todoItems removeObject:todoItem];
    [self deleteReminderForToDoItem:todoItem];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - IBActions

- (IBAction)addButtonPressed:(id)sender {
    
    // Display an alert view with a text input.
    UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"Add a new to-do item:" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Add", nil];
    
    inputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    __weak RemindMeTableViewController *weakSelf = self;
    
    // Add a completion block (using our category to UIAlertView).
    [inputAlertView setCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        // If user pressed 'Add'...
        if (buttonIndex == 1) {
            
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *string = [textField.text capitalizedString];
            [weakSelf.todoItems addObject:string];
            
            NSUInteger row = [weakSelf.todoItems count] - 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    [inputAlertView show];
}

- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Black out.
                    cell.backgroundColor = [UIColor blackColor];
                } completion:nil];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self.todoItems exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo the black-out effect we did.
                cell.backgroundColor = [AppColor butlerBlackBackgroundColor];
                
            } completion:^(BOOL finished) {
                
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            sourceIndexPath = nil;
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (NSDateComponents *)dateComponentsForDefaultDueDate {
    NSDateComponents *oneDayComponents = [[NSDateComponents alloc] init];
    oneDayComponents.day = 1;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *tomorrow = [gregorianCalendar dateByAddingComponents:oneDayComponents toDate:[NSDate date] options:0];
    
    NSUInteger unitFlags = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *tomorrowAt12PM = [gregorianCalendar components:unitFlags fromDate:tomorrow];
    tomorrowAt12PM.hour = 12;
    tomorrowAt12PM.minute = 0;
    tomorrowAt12PM.second = 0;
    
    return tomorrowAt12PM;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

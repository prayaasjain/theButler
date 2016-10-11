//
//  SettingsViewController.h
//  thebutler
//
//  Created by Prayaas Jain on 10/21/15.
//  Copyright © 2015 Prayaas Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingState.h"

@protocol SettingsViewControllerDelegate <NSObject>

- (void)didDismissSettings;
- (void)didRequestUpdateForState:(SettingState *)state;

@end

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id<SettingsViewControllerDelegate> delegate;

@end

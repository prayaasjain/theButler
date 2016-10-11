//
//  ServicesViewController.h
//  thebutler
//
//  Created by Prayaas Jain on 8/21/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "People.h"

@protocol ServicesViewControllerDelegate <NSObject>

- (void)didPressSettingsButton;


@end

@interface ServicesViewController : UIViewController

@property (weak, nonatomic) id<ServicesViewControllerDelegate> delegate;

- (id)initWithPeople:(People *)people;
- (void)updateServicesViewWithPeople:(People *)people;

@end

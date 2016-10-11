//
//  ButlerMainViewController.h
//  thebutler
//
//  Created by Prayaas Jain on 10/24/15.
//  Copyright © 2015 Prayaas Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "People.h"

@interface ButlerMainViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

- (id)initWithPeople:(People *)people;

@end

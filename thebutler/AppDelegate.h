//
//  AppDelegate.h
//  thebutler
//
//  Created by Prayaas Jain on 8/4/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end


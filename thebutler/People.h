//
//  People.h
//  thebutler
//
//  Created by Prayaas Jain on 8/31/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface People : NSManagedObject

@property (nonatomic, retain) NSString * butler;
@property (nonatomic, retain) NSString * owner;

@end

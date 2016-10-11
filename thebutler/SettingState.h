//
//  SettingState.h
//  thebutler
//
//  Created by Prayaas Jain on 10/25/15.
//  Copyright © 2015 Prayaas Jain. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum settingType {OWNER, BUTLER} settingType;

@interface SettingState : NSObject

@property (nonatomic, assign) settingType settingType;

@end

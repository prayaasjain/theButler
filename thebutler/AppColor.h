//
//  AppColor.h
//  thebutler
//
//  Created by Prayaas Jain on 8/21/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppColor : UIColor

+ (id)butlerGrayTextColor;
+ (id)butlerBackgroundColor;
+ (id)butlerWhiteTextColor;
+ (id)butlerWhiteButtonColor;
+ (id)butlerBlackBackgroundColor;
+ (id)butlerSilverTextColor;
+ (id)butlerSalmonPinkTextColor;
+ (id)butlerAppFontColor;

+ (UIColor *)butlerUIColorFromRGB:(NSUInteger)rgbValue;

@end

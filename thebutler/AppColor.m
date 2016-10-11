//
//  AppColor.m
//  thebutler
//
//  Created by Prayaas Jain on 8/21/15.
//  Copyright (c) 2015 Prayaas Jain. All rights reserved.
//

#import "AppColor.h"

@implementation AppColor

+ (UIColor *)butlerUIColorFromRGB:(NSUInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

+ (id)butlerGrayTextColor {
    return [AppColor butlerUIColorFromRGB:0x565758];
}

+ (id)butlerBackgroundColor {
    return [AppColor butlerUIColorFromRGB:0xF2F4F5];
}

+ (id)butlerWhiteButtonColor {
    return [AppColor butlerUIColorFromRGB:0xFFFFFF];
}

+ (id)butlerWhiteTextColor {
    return [AppColor butlerUIColorFromRGB:0xFFFFFF];
}

+ (id)butlerBlackBackgroundColor {
    return [AppColor butlerUIColorFromRGB:0x201D1D];
}

+ (id)butlerSilverTextColor {
    return [AppColor butlerUIColorFromRGB:0xD6D5D5];
}

+ (id)butlerSalmonPinkTextColor {
    return [AppColor butlerUIColorFromRGB:0xFF6680];
}

+ (id)butlerAppFontColor {
    return [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.4];
}

@end

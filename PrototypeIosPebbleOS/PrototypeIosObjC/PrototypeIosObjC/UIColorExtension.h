//
//  UIColorExtension.h
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 20/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIColor (Extensions)

#pragma mark - Exposed class function

+ (UIColor *)colorFromHex:(NSString *) rgba;

@end
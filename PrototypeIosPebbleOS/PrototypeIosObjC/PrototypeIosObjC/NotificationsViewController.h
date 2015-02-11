//
//  NotificationsViewController.h
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 27/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController

#pragma mark - UI elements

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end


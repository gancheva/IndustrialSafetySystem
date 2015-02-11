//
//  NotificationsViewController.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 27/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NotificationsViewController.h"
#import "UIColorExtension.h"
#import "PebbleController.h"

@interface NotificationsViewController ()
@end

@implementation NotificationsViewController

#pragma mark - UIViewController method(s)

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorFromHex:@"#242d3cff"];
    
    self.textField.layer.cornerRadius = 10.0f;
    self.textField.backgroundColor = [UIColor colorFromHex: @"#7b818a"];
    self.textField.textColor = [UIColor whiteColor];

    [super viewDidLoad];
}

#pragma mark - IB actions

- (IBAction)notifyWatch:(id)sender {
    // send the user input to Pebble, notify the app user for the result by showing a popup
    [self.view endEditing:YES];
    
    NSString *popupMessage = @"\n\nPebble is not connected and notification couldn't be sent!\n\n";
    if ([[PebbleController sharedInstance] updateWatch:self.textField.text]) {
        popupMessage = @"\n\nNotification was sent.\n\n";
    }
    [self showPopup:popupMessage];
}

#pragma mark - Method for showing popup view

- (void)showPopup:(NSString *)popupMessage {
    UIAlertView *popup = [[UIAlertView alloc] initWithTitle:nil
                                                    message:popupMessage
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [popup show];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)); // 1.0 indicates the delay in seconds
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [popup dismissWithClickedButtonIndex:0 animated:YES];
        // after dismissing the popup, show previous view
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    });
}

@end



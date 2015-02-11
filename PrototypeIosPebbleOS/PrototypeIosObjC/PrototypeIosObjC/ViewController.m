//
//  ViewController.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 20/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "UIColorExtension.h"
#import "LocationController.h"
#import "PebbleController.h"

@interface ViewController ()
@end

@implementation ViewController

#pragma mark - UIViewController method(s)

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorFromHex:@"#242d3cff"];
    
    self.commTracker.layer.cornerRadius = 20.0f;
    self.commTracker.layer.backgroundColor = [[UIColor colorFromHex: @"#7b818a"] CGColor];
    self.commTracker.text = @"\n\nUpdating location ...";
    
    // use key value observing for detecting changes in 'receivedMessage' and 'currentLocation'.
    [[PebbleController sharedInstance] addObserver:self forKeyPath:@"receivedMessage" options:NSKeyValueObservingOptionNew context:nil];
    [[LocationController sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [super viewDidLoad];
}

#pragma mark - Key-value observer method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        NSLog(@"Detected change in the current location.");
        [self showLocation:nil];
    }
    if([keyPath isEqualToString:@"receivedMessage"]) {
        NSLog(@"Received new message from Pebble.");
        self.commTracker.text = [@"\n\n" stringByAppendingString: [PebbleController sharedInstance].receivedMessage];
    }
}

#pragma mark - IB actions

- (IBAction)showLocation:(id)sender {
    NSString *message = @"Current location still unknown. Please wait ...";
    // check if a new location update has been detected
    if (![[LocationController sharedInstance].currentLocation hasSuffix:@"Please wait ..."]) {
        // check if the button was pressed or key-value observer triggered the location update
        if (sender) {
            message = [@"Last known location: " stringByAppendingString:[LocationController sharedInstance].currentLocation];
        } else {
            message = [@"New current location: " stringByAppendingString:[LocationController sharedInstance].currentLocation];
        }
        [self showOnWatch:message andOnPhone:message];
    } else {
        [self showOnWatch:message andOnPhone:[@"\n\n" stringByAppendingString: message]];
    }
}

- (IBAction)alarmWatch:(id)sender {
    if ([[PebbleController sharedInstance] updateWatch:@"ALARM! Evacuate through the nearest exit."]) {
        self.commTracker.text = @"\n\nAlarm was sent!";
    } else {
        self.commTracker.text = @"\n\nAlarm couldn't be sent to Pebble.";
    }
}

- (IBAction)checkAir:(id)sender {
    [self showOnWatch:@"Air pollution in norm. Wind direction: north." andOnPhone:@"\n\nAir pollution in norm. Wind direction: north."];
}

- (IBAction)checkRadiation:(id)sender {
    [self showOnWatch:@"Radiation level in norm." andOnPhone:@"\n\nRadiation level in norm."];
}

- (IBAction)checkChemicals:(id)sender {
    [self showOnWatch:@"No dangerous chemical substances." andOnPhone:@"\n\nNo dangerous chemical substances."];
}

#pragma mark - Help method(s)

- (void)showOnWatch:(NSString *)watchUpdate andOnPhone:(NSString *)phoneUpdate {
    // update the watch with the given message and show it on the phone
    [[PebbleController sharedInstance] updateWatch:watchUpdate];
    self.commTracker.text = phoneUpdate;
}

- (void)showPopup:(NSString *)popupMessage {
    // show popup with the given message and after a short delay dismiss it
    UIAlertView *popup = [[UIAlertView alloc] initWithTitle:nil
                                                    message:popupMessage
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [popup show];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)); // 1.0 indicates the delay in seconds
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [popup dismissWithClickedButtonIndex:0 animated:YES];
    });
}

@end

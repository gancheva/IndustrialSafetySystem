//
//  AppDelegate.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 20/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PebbleController.h"
#import "LocationController.h"


@interface AppDelegate ()
@end

@implementation AppDelegate {
    ViewController *mainViewController;
}

#pragma mark - App lifecycle methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    mainViewController = (ViewController *)self.window.rootViewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[LocationController sharedInstance] allowLocationUpdates:NO];
    [[LocationController sharedInstance] stopUpdatingLocation];
    [[PebbleController sharedInstance] stopWatchapp];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    mainViewController.commTracker.text = @"\n\nPlease wait ...";
    
    /* This is the recommended place to close the communication session with Pebble but due to the purposes of this prototype this will be 
     * done in applicationWillTerminate instead.
     * Not closing the communication session here will allow Pebble to send notifications to the current mobile app even when it is closed.
     * The opposite situation is managed in PebbleMessageQueue.m when an error by sending an update to Pebble occurs.
     * [[PebbleController sharedInstance] closeCommunicationSession];
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![[PebbleController sharedInstance] startWatchapp]) {
        [mainViewController showPopup:@"\n\nPebble is not connected!\n\n"];
    }
    [[LocationController sharedInstance] allowLocationUpdates:YES];
    [[LocationController sharedInstance] startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PebbleController sharedInstance] closeCommunicationSession];
}

@end

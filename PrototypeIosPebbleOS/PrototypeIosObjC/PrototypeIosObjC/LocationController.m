//
//  LocationController.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 25/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import "LocationController.h"

@implementation LocationController {
    CLLocationManager *locationManager;
    BOOL canStartUpdatingLocation;
    NSArray *instArray;
}

#pragma mark - Methods implementing Singleton pattern

+ (LocationController *)sharedInstance {
    static LocationController *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        // For the purposes of this prototype the desiredAccuracy and distanceFilter properties were set to kCLLocationAccuracyBest and 3 meters accordingly.
        // These values can be changed for activity specific cases.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 3; // in meters
        if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        
        self.currentLocation = @"Current location still unknown. Please wait ...";
        canStartUpdatingLocation = NO;
        // init an array that holds all example instructions for each random area
        instArray = [NSArray arrayWithObjects:  @"\nDo not use flammable liquids or solids in this area.",
                     @"\nWear lumbar support belts when moving large items.",
                     @"\nDo not walk, work, or stand under suspended loads.",
                     @"\nKeep hands and feet clear of crushing or pinching points.",
                     @"\nWear protective steel-toed shoes while working.",
                     @"\nUse mechanical assistance when lifting heavy loads.",
                     nil];
    }
    return self;
}

#pragma mark - Methods for starting and stopping location updates

- (void)startUpdatingLocation {
    NSLog(@"Starting location updates after a delay ...");
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)); // delay = 10.0 seconds
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"%@ %@", @"After the delay the location updates can be started: ", canStartUpdatingLocation? @"Yes" : @"No");
        // check if location updates can be started
        if (canStartUpdatingLocation) {
            [locationManager startUpdatingLocation];
            NSLog(@"Location updates have been started.");
        }
    });
}

- (void)stopUpdatingLocation {
    [locationManager stopUpdatingLocation];
    NSLog(@"Location updates have been stopped.");
  
}

#pragma mark - Help method(s)

- (void)allowLocationUpdates:(BOOL)canStart {
    // Help method for allowing the location updates. It's needed because the start of the location updates is delayed
    // and in some cases can follow the method for stopping the location updates. Set to YES in AppDelegate only when app is active.
    canStartUpdatingLocation = canStart;
}

#pragma mark - Location manager methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    if(newLocation != nil) {
        // the location was updated, so for the purposes of the prototype choose a random area with instructions for it
        NSLog(@"New location: latitude: %+.6f & longitude: %+.6f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        int random = arc4random_uniform(5); // from #include <stdlib.h>
        self.currentLocation = [[NSString stringWithFormat:@"Area %d", ++random] stringByAppendingString:instArray[random]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed with error: %@", error.debugDescription);
}

@end


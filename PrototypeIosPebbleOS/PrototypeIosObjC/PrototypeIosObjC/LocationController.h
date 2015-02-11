//
//  LocationController.h
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 25/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>


@interface LocationController : NSObject <CLLocationManagerDelegate>

#pragma mark - Properties

@property (strong, nonatomic) NSString *currentLocation;

#pragma mark - Method implementing the Singleton pattern

+ (LocationController *)sharedInstance;

#pragma mark - Exposed methods

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)allowLocationUpdates:(BOOL)canStart;

@end

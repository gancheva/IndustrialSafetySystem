//
//  LocationControllerTests.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 02/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LocationController.h"

@interface LocationControllerTests : XCTestCase
@end

@implementation LocationControllerTests {
    LocationController *sharedInstance, *newInstance;
}

#pragma mark - Methods of XCTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    sharedInstance = [LocationController sharedInstance];
    newInstance = [[LocationController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    sharedInstance = nil;
    newInstance = nil;
    [super tearDown];
}

#pragma mark - Test Singleton's sharedInstance

- (void)testSingletonCreatesSharedInstance {
    XCTAssertNotNil([LocationController sharedInstance]);
}

- (void)testSingletonReturnsSameSharedInstance {
    XCTAssertEqual(sharedInstance, [LocationController sharedInstance]);
}

- (void)testSharedInstanceSeparateFromNewInstance {
    XCTAssertNotEqual(sharedInstance, newInstance);
}

- (void)testSingletonReturnsSeparateUniqueInstances {
    XCTAssertNotEqual(newInstance, [[LocationController alloc] init]);
}

#pragma mark - Performance tests

 - (void)testPerformanceOfStratUpdatingLocation {
    [self measureBlock:^{
        [sharedInstance startUpdatingLocation];
    }];
 }
 
 - (void)testPerformanceOfStopUpdatingLocation {
    [self measureBlock:^{
        [sharedInstance stopUpdatingLocation];
    }];
 }

@end

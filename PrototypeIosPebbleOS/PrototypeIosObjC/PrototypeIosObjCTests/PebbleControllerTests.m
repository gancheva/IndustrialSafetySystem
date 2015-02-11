//
//  PebbleControllerTests.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 02/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import <OCMockObject.h>
#import "PebbleController.h"


@interface PebbleControllerTests : XCTestCase
@end

@implementation PebbleControllerTests {
    PebbleController *sharedInstance, *newInstance;
}

#pragma mark - Methods of XCTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    sharedInstance = [PebbleController sharedInstance];
    newInstance = [[PebbleController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    sharedInstance = nil;
    newInstance = nil;
    [super tearDown];
}

#pragma mark - Test Singleton's sharedInstance

- (void)testSingletonCreatesSharedInstance {
    XCTAssertNotNil([PebbleController sharedInstance]);
}

- (void)testSingletonReturnsSameSharedInstance {
    XCTAssertEqual(sharedInstance, [PebbleController sharedInstance]);
}

- (void)testSharedInstanceSeparateFromNewInstance {
    XCTAssertNotEqual(sharedInstance, newInstance);
}

- (void)testSingletonReturnsSeparateUniqueInstances {
    XCTAssertNotEqual(newInstance, [[PebbleController alloc] init]);
}

#pragma mark - Performance tests

- (void)testPerformanceOfStartingWatchapp {
    [self measureBlock:^{
        [sharedInstance startWatchapp];
    }];
}

- (void)testPerformanceOfStoppingWatchapp {
    [self measureBlock:^{
        [sharedInstance stopWatchapp];
    }];
}

@end

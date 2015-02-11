//
//  ViewControllerTests.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 04/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface ViewControllerTests : XCTestCase
@end

@implementation ViewControllerTests {
    ViewController *viewController;
}

#pragma mark - Methods of XCTestCase

- (void)setUp {
    [super setUp];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    viewController = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    [viewController view];
}

- (void)tearDown {
    viewController = nil;
    [super tearDown];
}

#pragma mark - Test existence of ViewController's View

- (void)testViewOfViewControllerExists {
    XCTAssertNotNil(viewController.view, @"ViewController has a view.");
}

#pragma mark - IB actions tests

- (void)testAlarmButton {
    [self compareShownTextWith:@"\n\nAlarm was sent!" afterPressing:viewController.alarmButton];
}

- (void)testAirButton {
    [self compareShownTextWith:@"\n\nAir pollution in norm. Wind direction: north." afterPressing:viewController.airButton];
}

- (void)testRadiationButton {
    [self compareShownTextWith:@"\n\nRadiation level in norm." afterPressing:viewController.radiationButton];
}

- (void)testChemicalsButton {
    [self compareShownTextWith:@"\n\nNo dangerous chemical substances." afterPressing:viewController.chemicalsButton];
}

- (void)testLocateButton {
    [viewController.locateButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    BOOL found = NO;
    NSString *expectedText = @"Current location still unknown. Please wait ...";
    if ([viewController.commTracker.text rangeOfString:expectedText].location != NSNotFound) {
        found = YES;
    }
    expectedText = @"Area";
    if ([viewController.commTracker.text rangeOfString:expectedText].location != NSNotFound) {
        found = YES;
    }
    XCTAssert(found);
}

#pragma mark - Help method(s)

- (void)compareShownTextWith:(NSString *)expectedText afterPressing:(UIButton *)button {
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(viewController.commTracker.text, expectedText);
}

#pragma mark - Performance tests

- (void)testPerformanceOfLoadView {
    [self measureBlock:^{
        [viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    }];
}

@end


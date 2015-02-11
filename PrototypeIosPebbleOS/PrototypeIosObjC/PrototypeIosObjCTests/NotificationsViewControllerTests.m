//
//  NotificationsViewControllerTests.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 08/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NotificationsViewController.h"

@interface NotificationsViewControllerTests : XCTestCase
@end

@implementation NotificationsViewControllerTests {
    NotificationsViewController *notificationsViewController;
}

#pragma mark - Methods of XCTestCase

- (void)setUp {
    [super setUp];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    notificationsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    [notificationsViewController view];
}

- (void)tearDown {
    notificationsViewController = nil;
    [super tearDown];
}

#pragma mark - Test existence of NotificationsViewController's View

- (void)testViewOfNotificationsViewControllerExists {
    XCTAssertNotNil(notificationsViewController.view, @"NotificationsViewController has a view.");
}

#pragma mark - IB actions tests

- (void)testNotifyWatch {
    [notificationsViewController.sendButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqualObjects(notificationsViewController.textField.text, @"");
}

- (void)testChangeOfView {
    // test if the view currently managed by the root view controller changes after pressing the button
    UIView *topViewBefore = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    UIView *topViewAfter = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    
    XCTAssertEqualObjects(topViewBefore, topViewAfter);
    
    [notificationsViewController.sendButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    sleep(2);

    topViewAfter = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    
    XCTAssertNotEqualObjects(topViewBefore, topViewAfter);
}

#pragma mark - Performance tests

- (void)testPerformanceOfLoadView {
    [self measureBlock:^{
        [notificationsViewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    }];
}

@end


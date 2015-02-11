//
//  PebbleMessageQueueTests.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 05/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PebbleKit/PebbleKit.h>
#import <OCMock.h>
#import <OCMockObject.h>
#import "PebbleMessageQueue.h"


@interface PebbleMessageQueueTests : XCTestCase
@end

@implementation PebbleMessageQueueTests {
    id mockWatch;
    PebbleMessageQueue *pebbleMessageQueue;
    NSDictionary *dictionary;
}

#pragma mark - Methods of XCTestCase

- (void)setUp {
    [super setUp];
    // mock the PBWatch class
    mockWatch = OCMClassMock([PBWatch class]);
    pebbleMessageQueue = [[PebbleMessageQueue alloc] initWithWatch:mockWatch];
    dictionary = @{ @(0):[NSNumber numberWithUint8:0], @(1):@"Test message ..."};
}

- (void)tearDown {
    // stop mocking
    [mockWatch stopMocking];
    pebbleMessageQueue = nil;
    dictionary = nil;
    [super tearDown];
}

#pragma mark - Tests for the asynchronous method appMessagesPushUpdateOnSent

 - (void)testPushUpdateOnSent {
     NSLog(@"Testing appMessagesPushUpdate:OnSent: ...");
     
     [[[mockWatch stub] andReturnValue:[NSNumber numberWithBool:YES]] isConnected];
     
     [[[mockWatch stub] andDo:^(NSInvocation *invoke) {
         // declare a block with same signature as the one which needs to be invoked
         void(^onSentStubResponse)(PBWatch *watch, NSDictionary *update, NSError *error);
         
         // link argument 3 with the block
         // in Objective-C the first two parameters passed to any function are ‘self’ and ‘_cmd’
         [invoke getArgument:&onSentStubResponse atIndex:3];
         
         // invoke the block with pre-defined input
         // this input will simulate a successful update of the watchapp
         onSentStubResponse(nil, nil, nil);
         
     }]appMessagesPushUpdate:dictionary onSent:[OCMArg any]];
     
     // call the tested method
     [pebbleMessageQueue queueUp:@"Test message ..."];
     
     // verify
     [mockWatch verify];
 }

- (void)testErrorHandlingInPushUpdateOnSent {
    NSLog(@"Testing error handling in appMessagesPushUpdate:OnSent: ...");
    
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    [details setValue:@"private test error" forKey:NSLocalizedDescriptionKey];
    // initialize the error object which will be used for the test
    NSError *testError = [NSError errorWithDomain:@"test error" code:999 userInfo:details];
    
    [[[mockWatch stub] andReturnValue:[NSNumber numberWithBool:YES]] isConnected];
    
    [[[mockWatch stub] andDo:^(NSInvocation *invoke) {
        // declare a block with same signature as the one which needs to be invoked
        void(^onSentStubResponse)(PBWatch *watch, NSDictionary *update, NSError *error);
        
        // link argument 3 with the block
        // in Objective-C the first two parameters passed to any function are ‘self’ and ‘_cmd’
        [invoke getArgument:&onSentStubResponse atIndex:3];
        
        // invoke the block with pre-defined input
        // this input will simulate a failure occured during the watchapp update
        // and will result in retrying to update the watchapp in total 3 times
        onSentStubResponse(nil, nil, testError);
        
    }]appMessagesPushUpdate:dictionary onSent:[OCMArg any]];
    
    // call the tested method
    [pebbleMessageQueue queueUp:@"Test message ..."];
    
    // verify
    [mockWatch verify];
}

@end


//
//  PebbleController.h
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 25/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import <PebbleKit/PebbleKit.h>

typedef void (^UnitOfWork)();
typedef void (^AppMessagesBlock)(PBWatch *watch, NSError *error);

@interface PebbleController : NSObject <PBPebbleCentralDelegate>

#pragma mark - Properties

@property (strong, nonatomic) NSString *receivedMessage;

#pragma mark - Method implementing the Singleton pattern

+ (PebbleController *)sharedInstance;

#pragma mark - Exposed methods

- (BOOL)updateWatch:(NSString *)message;
- (BOOL)startWatchapp;
- (void)stopWatchapp;
- (void)closeCommunicationSession;

@end



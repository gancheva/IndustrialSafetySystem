//
//  PebbleController.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 25/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import "PebbleController.h"
#import "PebbleMessageQueue.h"


@implementation PebbleController {
    PBWatch *targetWatch;
    PebbleMessageQueue *pebbleMessageQueue;
    PebbleController * __weak weakSelf; //by using weakSelf strong reference cycles in blocks can be avoided
}

#pragma mark - Methods implementing Singleton pattern

+ (PebbleController *)sharedInstance {
    static PebbleController *instance = nil;
    static dispatch_once_t onceToken;
    
    // allow the dispatch to init the class only once
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        weakSelf = self;
        [[PBPebbleCentral defaultCentral] setDelegate:self];
        [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
        pebbleMessageQueue = [[PebbleMessageQueue alloc] initWithWatch:targetWatch];
    }
    return self;
}

#pragma mark - Methods for initializing/closing a communication session with Pebble

- (void)setTargetWatch:(PBWatch*)watch {
    targetWatch = watch;
    
    if (targetWatch == nil) {
        NSLog(@"Target watch is nil.");
        return;
    }
    
    // Test if the Pebble's firmware supports AppMessage. If yes, pass the UUID of the watchapp to the PBPebbleCentral,
    // add ReceiveUpdateHandler to watch and initialize PebbleMessageQueue.
    // Calling appMessagesGetIsSupported will implicitely open the communication session that is shared between all 3rd party iOS apps.
    [targetWatch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            NSLog(@"Target watch supports AppMessage.");
            
            // configure the communications channel to target the companion watchapp on Pebble
            uuid_t myAppUUIDbytes;
            NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"b2362f93-ad5d-4600-9beb-ce1cd9cccb47"];
            [myAppUUID getUUIDBytes:myAppUUIDbytes];
            [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
            
            // add ReceiveUpdateHandler
            [self addReceiveUpdateHandlerTo:watch];
        } else {
            NSLog(@"Target watch does not support AppMessage.");
        }
    }];
}

- (void)addReceiveUpdateHandlerTo:(PBWatch *)watch {
    // add ReceiveUpdateHandler
    [watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        if (update != nil) {
            self.receivedMessage = [NSString stringWithFormat:@"Received %@ from Pebble.",[[update allValues] objectAtIndex:0]];
        } else {
            NSLog(@"Nil notification received from target watch.");
        }
        return YES;
    }];
}

- (void)closeCommunicationSession {
    // It's important to close the communication session with Pebble when not using the mobile app
    // in order to allow other devices use the communication session. For the purposes of this prototype
    // this won't be done on the right place. Check AppDelegate.m for more details.
    [targetWatch closeSession:nil];
    NSLog(@"The communication session with Pebble was closed");
}

#pragma mark - Methods for controlling the companion watchapp and its content

- (BOOL)startWatchapp {
    if (![self isTargetWatchConnected]) {
        NSLog(@"Target watch is nil or not connected.");
        return NO;
    }
    
    AppMessagesBlock appMessagesLaunchBlock = ^(PBWatch *watch, NSError *error){
        if (error) {
            NSLog(@"%@", [@"Error by launching watchapp on target watch: " stringByAppendingString: error.debugDescription]);
        } else {
            NSLog(@"Watchapp has been successfully launched on target watch.");
        }
    };
    
    UnitOfWork startingWatchappBlock = ^{
        NSLog(@"The block for starting the watchapp will be executed ...");
        [weakSelf->targetWatch appMessagesLaunch:appMessagesLaunchBlock];
    };
    
    // Try and launch watchapp after a short delay. The delay is needed for a correct communication flow.
    [self afterADelayOf:0.5 execute:startingWatchappBlock];
    
    return YES;
}

- (void)stopWatchapp {
    if ([self isTargetWatchConnected]) {
        AppMessagesBlock appMessagesKillBlock =  ^(PBWatch *watch, NSError *error){
            if (error) {
                NSLog(@"%@", [@"Error by stopping watchapp on target watch: " stringByAppendingString: error.debugDescription]);
            } else {
                NSLog(@"Watchapp has been successfully stopped on target watch.");
            }
        };
        
        UnitOfWork stoppingWatchappBlock = ^{
            NSLog(@"The block for stopping the watchapp will be executed ...");
            // before closing the watchapp clear all messages in the queue
            [weakSelf->pebbleMessageQueue clearQueue];
            [weakSelf->targetWatch appMessagesKill:appMessagesKillBlock];
        };
        
        // Close the watchapp after a short delay. The delay ensures that the watchapp won't be closed before it's opened.
        [self afterADelayOf:0.5 execute:stoppingWatchappBlock];
    } else {
        NSLog(@"Watchapp couldn't be stopped because it's nil or not connected.");
    }
}

- (BOOL)updateWatch:(NSString *)message {
    if ([self isTargetWatchConnected]) {
        // simply add the message to the queue
        [pebbleMessageQueue queueUp:message];
        return YES;
    } else {
        NSLog(@"There is no connected watch!");
        return NO;
    }
}

#pragma mark - Help method(s)

- (BOOL)isTargetWatchConnected {
    // check if target watch is connected before using any method for controlling the watchapp or its content
    if (targetWatch == nil || targetWatch.connected == false) {
        return NO;
    } else {
        return YES;
    }
}

- (void)afterADelayOf:(double)seconds execute:(UnitOfWork)thisBlock {
    NSLog(@"Delay the execution of the given block");
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        thisBlock();
    });
}

#pragma mark - PBPebbleCentral delegate methods

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Target watch has just connected.");
    // change the target watch and pass its reference to the pebbleMessageQueue
    [self setTargetWatch:watch];
    [pebbleMessageQueue changeTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Target watch has just disconnected.");
    // set target watch to nil in case it's disconnected
    if (targetWatch == watch || [watch isEqual:targetWatch]) {
        [self setTargetWatch:nil];
        [pebbleMessageQueue changeTargetWatch:nil];
    }
}

@end

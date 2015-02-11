//
//  PebbleMessageQueue.m
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 05/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import "PebbleMessageQueue.h"

@implementation PebbleMessageQueue {
    PBWatch *targetWatch;
    NSMutableArray *queue;  // the queue containing all messages which must be send to the companion watchapp
    BOOL requestIsActive;   // check if there is a currently active request
    NSInteger failureCount; // count the failures by sending a message
}

#pragma mark - Initialization methods

- (id)init {
    return [self initWithWatch:nil];
}

- (id)initWithWatch:(PBWatch *) watch {
    self = [super init];
    if (self) {
        requestIsActive = NO;
        failureCount = 0;
        queue = [[NSMutableArray alloc] init];
        targetWatch = watch;
        NSLog(@"Queue set up.");
    }
    return self;
}

#pragma mark - Method changing the target watch

- (void)changeTargetWatch:(PBWatch *)newTargetWatch {
    targetWatch = newTargetWatch;
}

#pragma mark - Exposed methods

- (void)clearQueue {
    // synchronize the queue before removing all its elements in order to ensure
    // that this won't be done while there is an active request
    @synchronized(queue) {
        NSLog(@"All pending messages will be dropped ...");
        [queue removeAllObjects];
        requestIsActive = NO;
        failureCount = 0;
    }
}

- (void)queueUp:(NSString *)message {
    if(!message) return;
    
    // NB: - The maximum buffer size for AppMessage is currently 124 bytes which means that the 'update' can not be bigger than that.
    NSDictionary *dict = @{ @(0):[NSNumber numberWithUint8:0], @(1):message};
    
    // add message to the queue and send it to the watchapp
    @synchronized(queue) {
        [queue addObject:dict];
        [self sendRequest];
    }
}

#pragma mark - Method for pushing updates to Pebble

- (void)sendRequest {
    // This method uses a single recursion to send all messages in the queue to the watchapp. In the worst case each message will be send 4 times.
    // When the updates get rejected by Pebble for the 3rd time a request for launching the watchapp will be sent to Pebble.
    @synchronized(queue) {
        
        // checks for assuring that the current request can be sent
        // they are also used for stopping the recursion
        if (requestIsActive) {
            NSLog(@"There is an active request.");
            return;
        }
        if ([queue count] == 0) {
            NSLog(@"Queue is empty.");
            return;
        }
        if (targetWatch==nil || !targetWatch.connected) {
            NSLog(@"Target watch is nil or not connected.");
            requestIsActive = NO;
            return;
        }
        
        NSLog(@"Sending message from queue ...");
        requestIsActive = YES;
        
        // try to send the message and react on the error accordingly
        [targetWatch appMessagesPushUpdate:[queue objectAtIndex:0] onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if(!error) {
                [queue removeObjectAtIndex:0];
                failureCount = 0;
                NSLog(@"Successfully pushed notification.");
            } else {
                NSLog(@"Sending message failed with error: %@", error.description);
                failureCount++;
                if (failureCount == 3) {
                    // If the user closes the watchapp, all updates sent after that become rejected. To ensure that this isn't the case, the watchapp is opened again.
                    // There is no way of checking which watchapp is currently active on Pebble and therefore this workaround was chosen.
                    // The other possible solutions of this problem include the writing of more and complexer code on both watch and phone apps.
                    [self restartWatchapp];
                    sleep(1);
                } else if (failureCount == 4) {
                    failureCount = 0;
                    [queue removeObjectAtIndex:0];
                    NSLog(@"Update failed for 4th time, therefore it was aborted!");
                }
            }
            requestIsActive = NO;
            [self sendRequest];
        }];
        
    }
}

#pragma mark - Method for launching the watchapp

- (void)restartWatchapp {
    if (targetWatch && targetWatch.connected) {
        [targetWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
            if (error) {
                NSLog(@"%@", [@"Error by launching watchapp on target watch: " stringByAppendingString: error.debugDescription]);
            }
        }];
    }
}

@end


//
//  PebbleMessageQueue.h
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 05/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>

@interface PebbleMessageQueue: NSObject

#pragma mark - Initialization method

- (id)initWithWatch:(PBWatch *) watch;

#pragma mark - Exposed methods

- (void)queueUp:(NSString *)message;
- (void)clearQueue;
- (void)changeTargetWatch:(PBWatch *)newTargetWatch;

@end 

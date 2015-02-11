//
//  PebbleMessageQueue.swift
//  PrototypeIosSwift
//
//  Created by Kristina Gancheva on 18/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import Foundation

class PebbleMessageQueue: NSObject {
    
    var targetWatch: PBWatch!
    var queue: NSMutableArray!      // the queue containing all messages which must be send to the companion watchapp
    var requestIsActive: Bool       // check if there is a currently active request
    var failureCount: int_fast16_t  // count the failures by sending a message
    let lockQueue = dispatch_queue_create("Lock for PebbleMessageQueue", nil)   // since Swift does not support @synchronized GCD will be used
    
    //MARK: Initialization methods
    
    convenience override init() {
        self.init(watch: nil)
    }
    
    init(watch: PBWatch!) {
        requestIsActive = false
        failureCount = 0
        queue = NSMutableArray()
        targetWatch = watch
        NSLog("Queue set up.")
    }
    
    //MARK: Method changing the target watch
    
    func changeTargetWatch(newTargetWatch: PBWatch!) {
        targetWatch = newTargetWatch
    }
    
    //MARK: Exposed methods
    
    func clearQueue() {
        // synchronize the queue before removing all its elements in order to ensure
        // that this won't be done while there is an active request
        dispatch_sync(lockQueue) {
            NSLog("All pending messages will be dropped ...")
            self.queue.removeAllObjects()
            self.requestIsActive = false
            self.failureCount = 0
        }
    }
    
    func queueUp(message: String) {
        // NB: - The maximum buffer size for AppMessage is currently 124 bytes which means that the 'update' can not be bigger than that.
        var dict: NSDictionary = [0:message]
        
        // add message to the queue and send it to the watchapp
        //TODO: Check this one    - using sync here and in sendRequest!!!  probably its double ****************
        dispatch_sync(lockQueue) {
            self.queue.addObject(dict)
            self.sendRequest()
        }
    }
    
    //MARK: Method for pushing updates to Pebble

    private func sendRequest() {
        // This method uses a single recursion to send all messages in the queue to the watchapp. In the worst case each message will be send 4 times.
        // When the updates get rejected by Pebble for the 3rd time a request for launching the watchapp will be sent to Pebble.
        dispatch_sync(lockQueue) {
            // checks for assuring that the current request can be sent
            // they are also used for stopping the recursion
            if self.requestIsActive {
                NSLog("There is an active request.")
                return
            }
            if self.queue.count == 0 {
                NSLog("Queue is empty.")
                return
            }
            if self.targetWatch == nil || !self.targetWatch.connected {
                NSLog("Target watch is nil or not connected.")
                self.requestIsActive = false
                return
            }
            
            NSLog("Sending message from queue ...")
            self.requestIsActive = true
            
            // try to send the message and react on the error accordingly
            self.targetWatch.appMessagesPushUpdate(self.queue.objectAtIndex(0) as [NSObject : AnyObject], onSent: { (watch: PBWatch!, update: [NSObject : AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    self.queue.removeObjectAtIndex(0)
                    self.failureCount = 0
                    NSLog("Successfully pushed notification.")
                } else {
                    NSLog("Sending message failed with error: \(error.description)")
                    self.failureCount++
                    
                    if self.failureCount == 3 {
                        // If the user closes the watchapp, all updates sent after that become rejected. To ensure that this isn't the case, the watchapp is opened again.
                        // There is no way of checking which watchapp is currently active on Pebble and therefore this workaround was chosen.
                        // The other possible solutions of this problem include the writing of more and complexer code on both watch and phone apps.
                        self.restartWatchapp()
                        sleep(1)
                    } else if self.failureCount == 4 {
                        self.failureCount = 0
                        self.queue.removeObjectAtIndex(0)
                        NSLog("Update failed for 4th time, therefore it was aborted!")
                    }
                }
                self.requestIsActive = false
                self.sendRequest()
            })
        }
    }
    
    //MARK: Method for launching the watchapp
    
    private func restartWatchapp() {
        if targetWatch != nil && targetWatch.connected {
            targetWatch.appMessagesLaunch({ (watch: PBWatch!, error: NSError!) -> Void in
                if error != nil {
                    NSLog("Error by launching watchapp on target watch: \(error.debugDescription)")
                }
            })
        }
    }

}
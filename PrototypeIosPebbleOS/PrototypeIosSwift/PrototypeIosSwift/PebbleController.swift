//
//  PebbleController.swift
//  PrototypeIosSwift
//
//  Created by Kristina Gancheva on 18/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import Foundation

typealias UnitOfWork = () -> ()
typealias AppMessagesBlock = (watch:PBWatch!, error:NSError!) -> ()

class PebbleController: NSObject, PBPebbleCentralDelegate {

    private var targetWatch: PBWatch!
    var receivedMessage: String!
    var pebbleMessageQueue: PebbleMessageQueue!
    weak var weakSelf: PebbleController? // by using weakSelf strong reference cycles in blocks can be avoided
    
    
    //MARK: Methods implementing Singleton pattern
    
    class var sharedInstance : PebbleController {
        struct Singleton {
            static let instance : PebbleController = PebbleController()
        }
        return Singleton.instance
    }
    
    override private init() {
        super.init()
        weakSelf = self
        PBPebbleCentral.defaultCentral().delegate = self
        setTargetWatch(PBPebbleCentral.defaultCentral().lastConnectedWatch())
        //pebbleMessageQueue = PebbleMessageQueue(targetWatch)
    }
    
    //MARK: - Methods for initializing/closing a communication session with Pebble
    
    private func setTargetWatch(watch: PBWatch!) {
        targetWatch = watch
        
        if targetWatch == nil {
            NSLog("Target watch is nil!")
            return
        }
        
        // Test if the Pebble's firmware supports AppMessage which is true for every Pebble watch with firmware hiegher than 1.10. 
        // If yes, pass the UUID of the watchapp to the PBPebbleCentral and add ReceiveUpdateHandler to watch.
        // Calling appMessagesGetIsSupported will implicitely open the communication session that is shared between all 3rd party iOS apps.
        targetWatch.appMessagesGetIsSupported {(watch: PBWatch!, isAppMessageSupported: Bool) -> Void in
            if (isAppMessageSupported) {
                NSLog("Target watch supports AppMessage.")
                
                // Configure the communications channel to target the companion watchapp on Pebble.
                let appUuid: NSUUID = NSUUID(UUIDString: "b2362f93-ad5d-4600-9beb-ce1cd9cccb47")!
                var appUuidBytes: UInt8 = 0
                appUuid.getUUIDBytes(&appUuidBytes)
                (PBPebbleCentral.defaultCentral()).appUUID = NSData(bytes: &appUuidBytes, length: 16)
                
                // add ReceivedUpdateHandler
                self.addReceiveUpdateHandlerTo(watch)
                
                // initialize pebbleMessageQueue
                self.pebbleMessageQueue = PebbleMessageQueue(watch: watch)
                
            } else {
                NSLog("Target watch does not support AppMessage.")
            }
        }
    }
    
    private func addReceiveUpdateHandlerTo(watch: PBWatch!) {
        // add ReceiveUpdateHandler
        watch.appMessagesAddReceiveUpdateHandler {(watch: PBWatch!, update: [NSObject : AnyObject]!) -> Bool in
            if (update != nil) {
                self.receivedMessage = "Received \(update.values.first!) from Pebble."
            } else {
                NSLog("Nil notification received from target watch.")
            }
            return true
        }
    }
    
    func closeCommunicationSession() {
        // It's important to close the communication session with Pebble when not using the mobile app
        // in order to allow other devices use the communication session. For the purposes of this prototype
        // this won't be done on the right place. Check AppDelegate.m for more details.
        targetWatch.closeSession(nil)
        NSLog("The communication session with Pebble was closed")
    }
    
    //MARK: Methods for controlling the companion watchapp and its content

    func startWatchapp() -> Bool {
        if !isTargetWatchConnected() {
            NSLog("Target watch is nil or not connected.")
            return false
        }
        
        var appMessagesLaunchBlock: AppMessagesBlock = { (watch: PBWatch!, error: NSError!) in
            if error != nil {
                NSLog("Error by launching watchapp on target watch: \(error.debugDescription)")
            } else {
                NSLog("Watchapp has been successfully launched on target watch.")
            }
        }
        
        var startingWatchappBlock: UnitOfWork = { () in
            NSLog("The block for starting the watchapp will be executed ...")
            self.weakSelf?.targetWatch.appMessagesLaunch(appMessagesLaunchBlock)
        }
        
        // Try and launch watchapp after a short delay. The delay is needed for a correct communication flow.
        afterADelayExecute(startingWatchappBlock)
        
        return true
    }
    
    func stopWatchapp() {
        if isTargetWatchConnected() {
            
            var appMessagesKillBlock: AppMessagesBlock = { (watch: PBWatch!, error: NSError!) in
                if error != nil {
                    NSLog("Error by stopping watchapp on target watch: \(error.debugDescription)")
                } else {
                    NSLog("Watchapp has been successfully stopped on target watch.")
                }
            }
            
            var stoppingWatchappBlock: UnitOfWork = { () in
                NSLog("The block for stopping the watchapp will be executed ...")
                // before closing the watchapp clear all messages in the queue
                self.weakSelf?.pebbleMessageQueue.clearQueue()
                self.weakSelf?.targetWatch.appMessagesKill(appMessagesKillBlock)
            }
            
            // Close the watchapp after a short delay. The delay ensures that the watchapp won't be closed before it's opened.
            afterADelayExecute(stoppingWatchappBlock)
            
        } else {
            NSLog("Watchapp couldn't be stopped because it's nil or not connected.")
        }
    }
    
    func updateWatch(message: String) -> Bool {
        if isTargetWatchConnected() {
            // simply add the message to the queue
            pebbleMessageQueue.queueUp(message)
            return true
        } else {
            NSLog("There is no connected watch!")
            return false
        }
    }
    
    //MARK: Help method(s)
    
    private func isTargetWatchConnected() -> Bool {
        // check if target watch is connected before using any method for controlling the watchapp or its content
        if (targetWatch == nil || targetWatch.connected == false) {
            return false
        } else {
            return true
        }
    }

    private func afterADelayExecute(block: UnitOfWork) {
        NSLog("Delay the execution of the given block")
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))) // a delay of 0.5 sec is chosen
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            block()
        }
    }
    
    //MARK: PBPebbleCentral delegate methods
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidConnect watch: PBWatch!, isNew: Bool) {
        NSLog("Target watch has just connected.")
        // change the target watch and pass its reference to the pebbleMessageQueue
        setTargetWatch(watch)
        pebbleMessageQueue.changeTargetWatch(watch)
    }
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidDisconnect watch: PBWatch!) {
        NSLog("Target watch has just disconnected.")
        // set target watch to nil in case it's disconnected
        if targetWatch == watch || watch.isEqual(targetWatch) {
            setTargetWatch(nil)
            pebbleMessageQueue.changeTargetWatch(nil)
        }
    }

}
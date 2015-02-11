//
//  AppDelegate.swift
//  PrototypeIosSwift
//
//  Created by Kristina Gancheva on 18/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController:ViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainViewController = window?.rootViewController as ViewController
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        LocationController.sharedInstance.allowLocationUpdates(false)
        LocationController.sharedInstance.stopUpdatingLocation()
        PebbleController.sharedInstance.stopWatchapp()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        mainViewController.commTracker.text = "\n\nPlease wait ..."
        
        /* This is the recommended place to close the communication session with Pebble but due to the purposes of this prototype this will be
        * done in applicationWillTerminate instead.
        * Not closing the communication session here will allow Pebble to send notifications to the current mobile app even when it is closed.
        * The opposite situation is managed in PebbleMessageQueue.m when an error by sending an update to Pebble occurs.
        * [[PebbleController sharedInstance] closeCommunicationSession];
        */
    }

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {       
        if !PebbleController.sharedInstance.startWatchapp() {
            mainViewController.showPopup("\n\nPebble is not connected!\n\n")
        }
        LocationController.sharedInstance.allowLocationUpdates(true)
        LocationController.sharedInstance.startUpdatingLocation()
    }

    func applicationWillTerminate(application: UIApplication) {
        PebbleController.sharedInstance.closeCommunicationSession()
    }
    
}


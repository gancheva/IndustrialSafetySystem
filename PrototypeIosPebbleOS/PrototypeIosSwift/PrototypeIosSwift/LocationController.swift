//
//  LocationController.swift
//  PrototypeIosSwift
//
//  Created by Kristina Gancheva on 18/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import Foundation
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    private var canStartUpdatingLocation: Bool!
    private var instArray: [String]!
    var currentLocation: String!

    class var sharedInstance : LocationController {
        struct Singleton {
            static let instance : LocationController = LocationController()
        }
        return Singleton.instance
    }
    
    override private init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // For the purposes of this prototype the desiredAccuracy and distanceFilter properties were set to kCLLocationAccuracyBest and 3 meters accordingly.
        // These values can be changed for activity specific cases.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3 // in meters
        locationManager.requestAlwaysAuthorization()
        
        currentLocation = "Current location still unknown. Please wait ..."
        canStartUpdatingLocation = false
        // init an array that holds all example instructions for each random area
        instArray = ["\nDo not use flammable liquids or solids in this area.",
                     "\nWear lumbar support belts when moving large items.",
                     "\nDo not walk, work, or stand under suspended loads.",
                     "\nKeep hands and feet clear of crushing or pinching points.",
                     "\nWear protective steel-toed shoes while working.",
                     "\nUse mechanical assistance when lifting heavy loads."]
    }

    //MARK: Methods for starting and stopping location updates
    
    func startUpdatingLocation(){
        NSLog("Starting location updates after a delay ...")
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))) // 1.0 indicates the delay in seconds
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            NSLog("After the delay the location updates can be started: %@", self.canStartUpdatingLocation);
            // check if location updates can be started
            if self.canStartUpdatingLocation == true {
                self.locationManager.startUpdatingLocation()
                NSLog("Location updates have been started.")
            }
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
         NSLog("Location updates have been stopped.")
    }
    
    //MARK: Help method(s)

    func allowLocationUpdates(canStart: Bool) {
        // Help method for allowing the location updates. It's needed because the start of the location updates is delayed
        // and in some cases can follow the method for stopping the location updates. Set to YES in AppDelegate only when app is active.
        canStartUpdatingLocation = canStart
    }
    
    //MARK: Location manager methods
 
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation = locations.last as CLLocation
        // the location was updated, so for the purposes of the prototype choose a random area with instructions for it
        NSLog("New location: latitude: \(newLocation.coordinate.latitude) and longitude: \(newLocation.coordinate.longitude)")
        var random = Int(arc4random_uniform(6)) // from #include <stdlib.h>
        self.currentLocation = "Area \(++random) \(instArray[--random])"
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Location manager failed with error: %@", error.debugDescription)
    }

}
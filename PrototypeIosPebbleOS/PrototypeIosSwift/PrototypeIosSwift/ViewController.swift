//
//  ViewController.swift
//  PrototypeIosSwift
//
//  Created by Kristina Gancheva on 18/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var commTracker: UITextView!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var airButton: UIButton!
    @IBOutlet weak var radiationButton: UIButton!
    @IBOutlet weak var chemicalsButton: UIButton!
    

    //MARK: UIViewController method(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgba: "#242d3cff")
        
        commTracker.layer.cornerRadius = 20.0
        commTracker.layer.backgroundColor = UIColor(rgba: "#7b818a").CGColor
        commTracker.text = "\n\nUpdating location ..."
        
        // use key value observing for detecting changes in 'receivedMessage' and 'currentLocation'.
        PebbleController.sharedInstance .addObserver(self, forKeyPath: "receivedMessage", options: NSKeyValueObservingOptions.New, context: nil)
        LocationController.sharedInstance .addObserver(self, forKeyPath: "currentLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Key-value observer method
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentLocation" {
            NSLog("Detected change in the current location.")
            showLocation(object)
        }
        if keyPath == "receivedMessage" {
            NSLog("Received new message from Pebble.")
            commTracker.text = "\n\n" + PebbleController.sharedInstance.receivedMessage
        }
    }
    
    //MARK: IB actions
    
    @IBAction func showLocation(sender: AnyObject) {
        var message = "Current location still unknown. Please wait ..."
        // check if a new location update has been detected
        if LocationController.sharedInstance.currentLocation.hasSuffix("Please wait ...") {
            // check if the button was pressed or key-value observer triggered the location update
            if sender is UIButton {
                message = "Last known location: " + LocationController.sharedInstance.currentLocation
            } else {
                message = "New current location: " + LocationController.sharedInstance.currentLocation
            }
            showOnWatchAndOnPhone(message, phoneUpdate: message)
            
        } else {
            showOnWatchAndOnPhone(message, phoneUpdate: "\n\n" + message)
        }
    }
    
    @IBAction func alarmWatch(sender: AnyObject) {
        if PebbleController.sharedInstance.updateWatch("ALARM! Evacuate through the nearest exit.") {
            commTracker.text = "\n\nAlarm was sent!"
        } else {
            commTracker.text = "\n\nAlarm couldn't be sent to Pebble."
        }
    }
    
    @IBAction func checkAir(sender: AnyObject) {
        showOnWatchAndOnPhone("Air pollution in norm. Wind direction: north.", phoneUpdate: "\n\nAir pollution in norm. Wind direction: north.")
    }
    
    @IBAction func checkRadiation(sender: AnyObject) {
        showOnWatchAndOnPhone("Radiation level in norm.", phoneUpdate: "\n\nRadiation level in norm.")
    }

    @IBAction func checkChemicals(sender: AnyObject) {
        showOnWatchAndOnPhone("No dangerous chemical substances.", phoneUpdate: "\n\nNo dangerous chemical substances.")
    }
    
    private func showOnWatchAndOnPhone(watchUpdate:NSString, phoneUpdate:NSString) {
        // update the watch with the given message and show it on the phone
        PebbleController.sharedInstance.updateWatch(watchUpdate)
        commTracker.text = phoneUpdate
    }
    
    func showPopup(popupMessage:String) {
        // show popup with the given message and after a short delay dismiss it
        var popup = UIAlertController(title: nil, message: popupMessage, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(popup, animated: true, completion: nil)
   
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))) // 1.0 indicates the delay in seconds
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}


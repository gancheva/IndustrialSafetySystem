//
//  NotificationsViewController.swift
//  PrototypeIosSwift
//
//  Created by Kristina Gancheva on 18/12/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: UIViewController method(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(rgba: "#242d3cff")
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = UIColor(rgba: "#7b818a")
        textField.textColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: IB actions
    
    @IBAction func notifyWatch(sender: AnyObject) {
        // send the user input to Pebble, notify the app user for the result by showing a popup
        self.view.endEditing(true)
        
        var popupMessage = "\n\nPebble is not connected and notification couldn't be sent!\n\n"
        if PebbleController.sharedInstance.updateWatch(self.textField.text) {
            popupMessage = "\n\nNotification was sent.\n\n"
        }
        
        self.showPopup(popupMessage)
    }
    
    //MARK: Method for showing popup view
    private func showPopup(popupMessage: String) {
        var popup = UIAlertController(title: nil, message: popupMessage, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(popup, animated: true, completion: nil)
        
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))) // 1.0 indicates the delay in seconds
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            // after dismissing the popup, show previous view
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
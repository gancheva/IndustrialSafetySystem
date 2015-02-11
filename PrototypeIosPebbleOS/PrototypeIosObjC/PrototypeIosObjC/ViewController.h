//
//  ViewController.h
//  PrototypeIosObjC
//
//  Created by Kristina Gancheva on 20/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

#pragma mark - UI elements

@property (weak, nonatomic) IBOutlet UITextView *commTracker;
@property (weak, nonatomic) IBOutlet UIButton *notifyButton;
@property (weak, nonatomic) IBOutlet UIButton *alarmButton;
@property (weak, nonatomic) IBOutlet UIButton *locateButton;
@property (weak, nonatomic) IBOutlet UIButton *airButton;
@property (weak, nonatomic) IBOutlet UIButton *radiationButton;
@property (weak, nonatomic) IBOutlet UIButton *chemicalsButton;

#pragma mark - Exposed by ViewController method(s)

- (void)showPopup:(NSString *)popupMessage;

@end


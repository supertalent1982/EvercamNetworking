//
//  LoginViewController.h
//  EvercamNetwork Demo
//
//  Created by jw on 6/3/15.
//  Copyright (c) 2015 jinlongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *txt_username;
@property (nonatomic, weak) IBOutlet UITextField *txt_password;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *btn_Signup;

- (IBAction)onLogin:(id)sender;
@end


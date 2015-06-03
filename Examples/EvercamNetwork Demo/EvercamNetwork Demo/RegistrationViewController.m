//
//  RegistrationViewController.m
//  EvercamNetwork Demo
//
//  Created by jw on 6/3/15.
//  Copyright (c) 2015 jinlongwei. All rights reserved.
//

#import "RegistrationViewController.h"
#import "EvercamUser.h"
#import "EvercamShell.h"

@interface RegistrationViewController ()
{
    UITextField *activeTextField;
}
@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.contentView.contentSize = self.contentView.bounds.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark Validation
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
#pragma mark -
#pragma mark Alert
- (void) alertWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = tag;
    [alert show];
}

#pragma mark -
#pragma mark Action
- (IBAction)onCreateAccount:(id)sender
{
    EvercamUser *user = [EvercamUser new];
    NSString *firstname = _txt_firstname.text;
    NSString *lastname = _txt_lastname.text;
    NSString *email = _txt_email.text;
    NSString *username = _txt_username.text;
    NSString *password = _txt_password.text;
    NSString *repassword = _txt_confirmPassword.text;
    
    [self.view endEditing:YES];

    // firstname
    if ([firstname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        [self alertWithTitle:@"Sign up" message:@"First name required" tag:101];
        return;
    }
    user.firstname = firstname;
    
    // lastname
    if ([lastname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        [self alertWithTitle:@"Sign up" message:@"Last name required" tag:102];
        return;
    }
    user.lastname = lastname;
    
    // username
    if ([username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        [self alertWithTitle:@"Sign up" message:@"User name required" tag:103];
        return;
    }
    else if ([username containsString:@" "])
    {
        [self alertWithTitle:@"Sign up" message:@"Invalid user name" tag:103];
        return;
    }
    else if (username.length < 3)
    {
        [self alertWithTitle:@"Sign up" message:@"Username is too short" tag:103];
        return;
    }
    user.username = username;
 
    // email
    if ([email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        [self alertWithTitle:@"Sign up" message:@"Email required" tag:104];
        return;
    }
    else if ([self NSStringIsValidEmail:email] == NO)
    {
        [self alertWithTitle:@"Sign up" message:@"Invalid email" tag:104];
        return;
    }
    user.email = email;
    
    // Password
    if (password.length <= 0)
    {
        [self alertWithTitle:@"Sign up" message:@"Password required" tag:105];
        return;
    }
    else if (repassword.length <= 0)
    {
        [self alertWithTitle:@"Sign up" message:@"Password required" tag:106];
        return;
    }
    else if ([password isEqualToString:repassword] == NO)
    {
        [self alertWithTitle:@"Sign up" message:@"Password not match" tag:105];
        return;
    }
    else if ([password rangeOfString:@" "].location != NSNotFound) {
        [self alertWithTitle:@"Sign up" message:@"Password should not contain space" tag:106];
        return;
    }
    user.password = password;
    
    [_activityIndicator startAnimating];
    [[EvercamShell shell] createUser:user WithBlock:^(EvercamUser *newuser, NSError *error) {
        [_activityIndicator stopAnimating];
        if (error == nil)
        {
            if (newuser)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_activityIndicator startAnimating];
                    [[EvercamShell shell] requestEvercamAPIKeyFromEvercamUser:username Password:password WithBlock:^(EvercamApiKeyPair *userKeyPair, NSError *error) {
                        if (error == nil)
                        {
                            [[EvercamShell shell] getUserFromId:username withBlock:^(EvercamUser *newuser, NSError *error) {
                                [_activityIndicator stopAnimating];
                                if (error == nil) {
                                    [self alertWithTitle:@"Sign up" message:@"Congratulations, you're now logged in with your Evercam account.\n\nWe've added a demo camera for you - add your own from the menu" tag:0];
                                } else {
                                    [self alertWithTitle:@"Sign up" message:error.localizedDescription tag:0];
                                }
                            }];
                        }
                        else
                        {
                            [_activityIndicator stopAnimating];
                            [self alertWithTitle:@"Sign up" message:error.localizedDescription tag:0];
                        }
                    }];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertWithTitle:@"Sign up" message:error.localizedDescription tag:0];
            });
        }
    }];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 101:
            [_txt_firstname becomeFirstResponder];
            break;
        case 102:
            [_txt_lastname becomeFirstResponder];
            break;
        case 103:
            [_txt_username becomeFirstResponder];
            break;
        case 104:
            [_txt_email becomeFirstResponder];
            break;
        case 105:
            [_txt_password becomeFirstResponder];
            break;
        case 106:
            [_txt_confirmPassword becomeFirstResponder];
            break;
        default:
            break;
    }
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == self.txt_firstname)
    {
        [self.txt_lastname becomeFirstResponder];
    }
    else if (textField == self.txt_lastname)
    {
        [self.txt_username becomeFirstResponder];
    }
    else if (textField == self.txt_username)
    {
        [self.txt_email becomeFirstResponder];
    }
    else if (textField == self.txt_email)
    {
        [self.txt_password becomeFirstResponder];
    }
    else if (textField == self.txt_password)
    {
        [self.txt_confirmPassword becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}

#pragma mark - UIKeyboard events
// Called when UIKeyboardWillShowNotification is sent
- (void)onKeyboardShow:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    
    // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrameInWindow fromView:nil];
    
    CGRect scrollViewKeyboardIntersection = CGRectIntersection(_contentView.frame, keyboardFrameInView);
    UIEdgeInsets newContentInsets = UIEdgeInsetsMake(0, 0, scrollViewKeyboardIntersection.size.height, 0);
    
    // this is an old animation method, but the only one that retains compaitiblity between parameters (duration, curve) and the values contained in the userInfo-Dictionary.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    _contentView.contentInset = newContentInsets;
    _contentView.scrollIndicatorInsets = newContentInsets;
    
    /*
     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
     * that should be visible, e.g. a purchase button below an amount text field
     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
     */
    if (activeTextField) {
        CGRect controlFrameInScrollView = [_contentView convertRect:activeTextField.bounds fromView:activeTextField]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
        controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10); // replace 10 with any nice visual offset between control and keyboard or control and top of the scroll view.
        
        CGFloat controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - _contentView.contentOffset.y;
        CGFloat controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height;
        
        // this is the visible part of the scroll view that is not hidden by the keyboard
        CGFloat scrollViewVisibleHeight = _contentView.frame.size.height - scrollViewKeyboardIntersection.size.height;
        
        if (controlVisualBottom > scrollViewVisibleHeight) { // check if the keyboard will hide the control in question
            // scroll up until the control is in place
            CGPoint newContentOffset = _contentView.contentOffset;
            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight);
            
            // make sure we don't set an impossible offset caused by the "nice visual offset"
            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
            newContentOffset.y = MIN(newContentOffset.y, _contentView.contentSize.height - scrollViewVisibleHeight);
            
            [_contentView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        } else if (controlFrameInScrollView.origin.y < _contentView.contentOffset.y) {
            // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
            CGPoint newContentOffset = _contentView.contentOffset;
            newContentOffset.y = controlFrameInScrollView.origin.y;
            
            [_contentView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        }
    }
    
    [UIView commitAnimations];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)onKeyboardHide:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    // undo all that keyboardWillShow-magic
    // the scroll view will adjust its contentOffset apropriately
    _contentView.contentInset = UIEdgeInsetsZero;
    _contentView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}


@end

//
//  LoginViewController.m
//  EvercamNetwork Demo
//
//  Created by jw on 6/3/15.
//  Copyright (c) 2015 jinlongwei. All rights reserved.
//

#import "LoginViewController.h"
#import "EvercamShell.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
#pragma mark Action

- (IBAction)onLogin:(id)sender
{
    NSString *username = _txt_username.text;
    NSString *password = _txt_password.text;

    [self.view endEditing:YES];
    
    if ([username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        [self alertWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"Username required", nil) tag:101];
        return;
    }
    else if ([username containsString:@" "])
    {
        [self alertWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"Invalid username", nil) tag:101];
        return;
    }
    else if (password.length <= 0)
    {
        [self alertWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"Password required", nil) tag:102];
        return;
    }
    
    [_activityIndicator startAnimating];
    
    [[EvercamShell shell] requestEvercamAPIKeyFromEvercamUser:username Password:password WithBlock:^(EvercamApiKeyPair *userKeyPair, NSError *error) {
        if (error == nil)
        {
            [[EvercamShell shell] getUserFromId:username withBlock:^(EvercamUser *newuser, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_activityIndicator stopAnimating];
                    if (error == nil) {
                        [self alertWithTitle:NSLocalizedString(@"Log in", nil) message:@"Great! Login success" tag:0];
                    } else {
                        [self alertWithTitle:NSLocalizedString(@"Log in", nil) message:error.localizedDescription tag:0];
                    }
                });
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
                [self alertWithTitle:NSLocalizedString(@"Log in", nil) message:error.localizedDescription tag:0];
            });
        }
    }];
}

#pragma mark -
#pragma mark Alert
- (void) alertWithTitle:(NSString *)title message:(NSString *)message tag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = tag;
    [alert show];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        [_txt_username becomeFirstResponder];
    }
    else if (alertView.tag == 102)
    {
        [_txt_password becomeFirstResponder];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txt_username)
    {
        [self.txt_password becomeFirstResponder];
    }
    else if (textField == self.txt_password)
    {
        [self.txt_password resignFirstResponder];
    }
    
    return YES;
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
    CGRect controlFrameInScrollView = [_contentView convertRect:_btn_Signup.bounds fromView:_btn_Signup]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
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
    
    // the scroll view will adjust its contentOffset apropriately
    _contentView.contentInset = UIEdgeInsetsZero;
    _contentView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

@end

//
//  LoginViewController.swift
//  liften
//
//  Created by Trent Rand on 2/27/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
        
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func btnRegisterPressed(sender: AnyObject) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == emailTextField) {
            // Move user to password field
            passwordTextField.select(textField)
        } else {
            // Hide keyboard
            self.view.endEditing(true)
            
            // Attempt to login w/ parse
            PFUser.logInWithUsernameInBackground(emailTextField.text.lowercaseString, password:passwordTextField.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if user != nil {
                    // Present LiftenViewController
                    let liftenVC = self.storyboard?.instantiateViewControllerWithIdentifier("liftenView") as LiftenViewController
                    self.presentViewController(liftenVC, animated: true, completion: nil)
                } else {
                    // The login failed. Check error to see why.
                    let errorString = error.userInfo?["error"] as NSString
                    var alert = UIAlertController(title: "There was a problem", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        return true
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        // Set permissions required from the facebook user account
        let permissionsArray = ["user_about_me", "user_relationships", "user_birthday", "user_location"]
        
        // Login PFUser using Facebook
        PFFacebookUtils.logInWithPermissions(permissionsArray, block: {
            (user: PFUser!, error: NSError!) in
            if (user.isEqual(nil)) {
                var errorMessage: String = ""
                if (error.isEqual(nil)) {
                    NSLog("Uh oh. The user cancelled the Facebook login")
                    errorMessage = "Uh oh. The user cancelled the Facebook login"
                } else {
                    NSLog("Uh oh. An error occurred: \(error)")
                }
                let alert: UIAlertView = UIAlertView(title: "Login Error", message: errorMessage, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Dismiss")
                alert.show()
            } else {
                if (user.isNew) {
                    NSLog("User with facebook signed up and logged in!")
                } else {
                    NSLog("User with facebook logged in")
                }
                NSLog("User with facebook logged in!")
                // Present LiftenViewController
                let liftenVC = self.storyboard?.instantiateViewControllerWithIdentifier("liftenView") as LiftenViewController
                self.presentViewController(liftenVC, animated: true, completion: nil)
            }
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // When view is clicked, resign text field
        textField.resignFirstResponder()
    }
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
}

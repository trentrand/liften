//
//  RegisterViewController.swift
//  liften
//
//  Created by Trent Rand on 3/1/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func unwind(sender: AnyObject) {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginView") as LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == emailTextField) {
            passwordTextField.select(textField)
        } else {
            registerUser(emailTextField.text, password: passwordTextField.text)
        }
        return true
    }
    
    func registerUser(email: String, password: String) {
        var user = PFUser()
        user.username = email
        user.password = password
        user.email = email
        
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                // Registration Successful
                NSLog("User registration successful with credentials \(email) / \(password)")
                // Present LiftenViewController
                let liftenVC = self.storyboard?.instantiateViewControllerWithIdentifier("liftenView") as LiftenViewController
                self.presentViewController(liftenVC, animated: true, completion: nil)
            } else {
                // Show the errorString somewhere and let the user try again.
                var alert = UIAlertController(title: "There was a problem", message: "\(error.userInfo)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        btnDone.enabled = true
    }

    @IBAction func doneButton(sender: AnyObject) {
        btnDone.enabled = false
        registerUser(emailTextField.text, password: passwordTextField.text)
    }
}
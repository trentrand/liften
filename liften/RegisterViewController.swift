//
//  RegisterViewController.swift
//  liften
//
//  Created by Trent Rand on 3/1/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation

<<<<<<< HEAD
class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
=======
class RegisterViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
>>>>>>> origin/master
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
<<<<<<< HEAD
                // TODO switch to map view
//                let viewController: ViewController = ViewController()
//                self.showViewController(viewController, sender: self)
=======
                let viewController: ViewController = ViewController()
                self.showViewController(viewController, sender: self)
>>>>>>> origin/master
            } else {
                // Show the errorString somewhere and let the user try again.
                var alert = UIAlertController(title: "There was a problem", message: "\(error.userInfo)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
<<<<<<< HEAD
        btnDone.enabled = true
    }

    @IBAction func doneButton(sender: AnyObject) {
        btnDone.enabled = false
        registerUser(emailTextField.text, password: passwordTextField.text)
=======
    }

    @IBAction func doneButton(sender: AnyObject) {
            registerUser(emailTextField.text, password: passwordTextField.text)
>>>>>>> origin/master
    }
}
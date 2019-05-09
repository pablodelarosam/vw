//
//  LoginViewController.swift
//  YoSoyVW
//
//  Created by Pablo de la Rosa Michicol on 5/8/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSCognitoIdentityProvider


class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordInput: UITextField?
    @IBOutlet weak var usernameInput: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var mfaSettings:[AWSCognitoIdentityProviderMFAOptionType]?
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Enable MFA
        let settings = AWSCognitoIdentityUserSettings()

        let mfaOptions = AWSCognitoIdentityUserMFAOption()
        mfaOptions.attributeName = "phone_number"
        mfaOptions.deliveryMedium = .sms
        settings.mfaOptions = [mfaOptions]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.usernameInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if (self.usernameInput?.text == nil || self.passwordInput?.text == nil) {
            return
        }
        
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameInput!.text!, password: self.passwordInput!.text! )
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    @IBAction func forgotPasswordPressed(_ sender: AnyObject) {
        if (self.usernameInput?.text == nil || self.usernameInput!.text!.isEmpty) {
            let alertController = UIAlertController(title: "Enter Username",
                                                    message: "Please enter your username and then select Forgot Password if you want to reset your password.",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(retryAction)
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        self.performSegue(withIdentifier: "ForgotPasswordSegue", sender: self)
    }
    
    @objc func inputDidChange(_ sender:AnyObject) {
        if (self.usernameInput?.text != nil && self.passwordInput?.text != nil) {
            self.loginButton?.isEnabled = true
        } else {
            self.loginButton?.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForgotPasswordSegue" {
            let forgotPasswordController = segue.destination as! ForgotPasswordViewController
      //      forgotPasswordController.emailAddress = self.usernameInput!.text!
        }
    }
    
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameInput?.text == nil) {
                self.usernameInput?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                let alertController = UIAlertController(title: "Cannot Login",
                                                        message: (error! as NSError).userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: {
                    self.usernameInput?.text = nil
                    self.passwordInput?.text = nil
                })
            }
        }
    }
    
}

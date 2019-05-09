//
//  SignInViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/7/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSMobileClient


class SignInViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var password: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var usernameText: String?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var mfaSettings:[AWSCognitoIdentityProviderMFAOptionType]?
    var initview: ViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.password.text = nil
        self.username.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
           self.pool = AWSCognitoIdentityUserPool.init(forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)
       
        setUpUI()
    }
    
    private func setUpUI() {
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor(hex: "004666").cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //setUpMFA()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       // setUpMFA()

    }
    
    private func setUpMFA() {
        // Enable MFA
        let settings = AWSCognitoIdentityUserSettings()
        self.user = self.pool?.getUser(self.usernameText ?? "")

        let mfaOptions = AWSCognitoIdentityUserMFAOption()
        mfaOptions.attributeName = "phone_number"
        mfaOptions.deliveryMedium = .sms
        settings.mfaOptions = [mfaOptions]
        user?.setUserSettings(settings)
            .continueOnSuccessWith(block: { (response) -> Any? in
                if response.error != nil {
                    let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion:nil)
                    //   self.resetAttributeValues()
                } else {
                    //   self.fetchUserAttributes()
                }
                return nil
            })
    }
    
    @IBAction func signInPressed(_ sender: AnyObject) {
        if (self.username.text != nil && self.password.text != nil) {
            setUpMFA()
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.username.text!, password: self.password.text! )
            
            self.passwordAuthenticationCompletion?.set(result: authDetails)
        
        } else {
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
        }
    }
}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    private func handlerAction() {
        let callActionHandler = { (action:UIAlertAction!) -> Void in
            AWSMobileClient.sharedInstance().confirmSignIn(challengeResponse: "S") { (signInResult, error) in
                if let signInResult = signInResult {
                    switch(signInResult.signInState) {
                    case .signedIn:
                        print("User signed in successfully.")
                    case .smsMFA:
                        print("Code was sent via SMS to \(signInResult.codeDetails!.destination!)")
                    case .newPasswordRequired:
                        print("New password required")
                    default:
                        print("Other signIn state: \(signInResult.signInState)")
                    }
                } else if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                }
            }
            
           // self.presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpConfirmationViewController = segue.destination as? ConfirmSignUpViewController {
           // signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.pool?.getUser(self.username.text!)
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil )
                alertController.addAction(retryAction)
                self.present(alertController, animated: true, completion: nil )
            } else {
         
              
                self.username.text = nil
                self.dismiss(animated: true, completion: {
                    //self.initview?.setUpMFA()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mfa"), object: nil, userInfo: nil)

                })
            print( self.user?.getDetails().result?.userAttributes![3].value)
// show me what you want ok
                
        
            
            }
        }
    }
}

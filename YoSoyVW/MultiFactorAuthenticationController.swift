//
//  MultiFactorAuthenticationController.swift
//  CognitoApplication
//
//  Created by David Tucker on 8/1/17.
//  Copyright © 2017 David Tucker. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class MultiFactorAuthenticationController: UIViewController {
    
    @IBOutlet weak var authenticationCode: UITextField!
    @IBOutlet weak var submitCodeButton: UIButton!
    
    var mfaCompletionSource:AWSTaskCompletionSource<NSString>?
    var signin: SignInViewController?
    @IBAction func submitCodePressed(_ sender: AnyObject) {
        self.mfaCompletionSource?.set(result: NSString(string: authenticationCode.text!))
    }
    
}
//let me show you again
// what next

extension MultiFactorAuthenticationController: AWSCognitoIdentityMultiFactorAuthentication {
    
    func getCode(_ authenticationInput: AWSCognitoIdentityMultifactorAuthenticationInput, mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>) {
        self.mfaCompletionSource = mfaCodeCompletionSource
    }
    
    func didCompleteMultifactorAuthenticationStepWithError(_ error: Error?) {
        DispatchQueue.main.async(execute: {
            if let error = error as NSError? {
                
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                  var storyboard: UIStoryboard?
                  storyboard = UIStoryboard(name: "Main", bundle: nil)
                let next = storyboard?.instantiateViewController(withIdentifier: "WelcomeScreen") as? UINavigationController
                self.dismiss(animated: true, completion: nil)
               // self.present(next!, animated: true, completion: nil)
           

            }
        })
}
}

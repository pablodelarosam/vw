//
//  ForceChangePasswordViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/8/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSCognitoIdentityProvider


class ForceChangePasswordViewController: UIViewController {
    
    var newPasswordCompletion: AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>?
    var currentUserAttributes:[String:String]?

    @IBOutlet weak var newPasswordButton: UIButton!
    @IBOutlet weak var newPasswordInput: UITextField!
//    @IBOutlet weak var firstNameInput: UITextField!
//    @IBOutlet weak var lastNameInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  self.newPasswordInput.text = nil
     //   self.newPasswordInput.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
//        self.firstNameInput.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
//        self.lastNameInput.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    @objc func inputDidChange(_ sender:AnyObject) {
        if (self.newPasswordInput.text != nil) {
            self.newPasswordButton.isEnabled = true
        } else {
            self.newPasswordButton.isEnabled = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ForceChangePasswordViewController: AWSCognitoIdentityNewPasswordRequired {
    
    func getNewPasswordDetails(_ newPasswordRequiredInput: AWSCognitoIdentityNewPasswordRequiredInput, newPasswordRequiredCompletionSource:
        AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>) {
        self.newPasswordCompletion = newPasswordRequiredCompletionSource
    }
    
    func didCompleteNewPasswordStepWithError(_ error: Error?) {
        if let error = error as? NSError {
            // Handle error
        } else {
            // Handle success, in my case simply dismiss the view controller
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

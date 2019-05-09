//
//  ViewController.swift
//  YoSoyVW
//
//  Created by Hugo Juárez on 5/7/19.
//  Copyright © 2019 Hugo Juárez. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSMobileClient


class ViewController: UIViewController {
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var mfaSettings:[AWSCognitoIdentityProviderMFAOptionType]?
    var signin: SignInViewController?
    var flag = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
   

        // Do any additional setup after loading the view.
//        AWSMobileClient.sharedInstance().initialize { (userState, error) in
//            if let userState = userState {
//                switch(userState){
//                case .signedIn:
//                    print("Logged In")
//                case .signedOut:
//                    AWSMobileClient.sharedInstance().showSignIn(navigationController: self.navigationController!, { (userState, error) in
//                        if(error == nil){       //Successful signin
//                            print("Logged In")
//                        }
//                    })
//                default:
//                    AWSMobileClient.sharedInstance().signOut()
//                }
//
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
//        }
        self.pool = AWSCognitoIdentityUserPool(forKey: Constants.AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
         self.refresh()
        //setUpMFA()
        loadUserValues()
    }
    
    func loadUserValues () {
        self.resetAttributeValues()
        self.fetchUserAttributes()
    }
    
    func fetchUserAttributes() {
        self.resetAttributeValues()
        user = AppDelegate.defaultUserPool().currentUser()
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            self.userAttributes = task.result?.userAttributes
            self.mfaSettings = task.result?.mfaOptions
            self.userAttributes?.forEach({ (attribute) in
                print("Name: " + attribute.name!)
            })
            DispatchQueue.main.async {
                self.setAttributeValues()
            }
            return nil
        })
    }
    
    func isEmailMFAEnabled() -> Bool {
        let values = self.mfaSettings?.filter { $0.deliveryMedium == AWSCognitoIdentityProviderDeliveryMediumType.sms }
        if values?.first != nil {
            return true
        }
        return false
    }
    
    func setAttributeValues() {
        DispatchQueue.main.async {
            
            if self.mfaSettings == nil {
               // self.mfaSwitch.setOn(false, animated: false)
            } else {
                self.setUpMFA(bo: self.isEmailMFAEnabled())
            }
        }
    }
    
    func resetAttributeValues() {
        DispatchQueue.main.async {
            self.flag = false
            self.setUpMFA(bo: false)
        }
    }
    
    func setUpMFA(bo: Bool) {
        // Enable MFA
        let settings = AWSCognitoIdentityUserSettings()

        if bo {
            
            let mfaOptions = AWSCognitoIdentityUserMFAOption()
            mfaOptions.attributeName = "phone_number"
            mfaOptions.deliveryMedium = .sms
            settings.mfaOptions = [mfaOptions]
       
        } else {
            // Disable MFA
            settings.mfaOptions = []
        }
        user?.setUserSettings(settings)
            .continueOnSuccessWith(block: { (response) -> Any? in
                if response.error != nil {
                    let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion:nil)
                    self.resetAttributeValues()
                } else {
                    self.fetchUserAttributes()
                }
                return nil
            })
  
    }

    @IBAction func logout(_ sender: Any) {
        print("dadw")
        if signin != nil {
            signin?.dismiss(animated: false, completion: nil)
        }
        self.user?.signOut()
        self.title = nil
        self.response = nil
        self.refresh()
        AWSMobileClient.sharedInstance().signOut()
      //  signIn()
        

    }

    
    func refresh() {
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                self.title = self.user?.username
            //    self.tableView.reloadData()
            })
            return nil
        }
    }
    
}


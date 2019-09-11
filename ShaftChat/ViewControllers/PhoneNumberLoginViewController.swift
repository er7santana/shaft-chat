//
//  PhoneNumberLoginViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 10/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class PhoneNumberLoginViewController: UIViewController {
    
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var requestButton: UIButton!
    
    var phoneNumber: String!
    var verificationId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countryCodeTextField.text = CountryCode().currentCode
    }
    
    //MARK: - IBActions
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        
        //register
        if verificationId != nil {
            registerUser()
            return
        }
        
        //request code
        if mobileNumberTextField.text != "" && countryCodeTextField.text != "" {
            
            let fullNumber = countryCodeTextField.text! + mobileNumberTextField.text!
            PhoneAuthProvider.provider().verifyPhoneNumber(fullNumber, uiDelegate: nil) { (_verificationId, error) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
                self.verificationId = _verificationId
                self.updateUI()
            }
        } else {
            ProgressHUD.showError("Phone number is required")
        }
    }
    
    //MARK: - Helpers
    
    func updateUI() {
        requestButton.setTitle("Submit", for: .normal)
        phoneNumber = countryCodeTextField.text! + mobileNumberTextField.text!
        countryCodeTextField.isEnabled = false
        mobileNumberTextField.isEnabled = false
        mobileNumberTextField.placeholder = mobileNumberTextField.text!
        mobileNumberTextField.text = ""
        codeTextField.isHidden = false
    }
    
    func registerUser() {
        if codeTextField.text != "" && verificationId != nil {
            FUser.registerUserWith(phoneNumber: phoneNumber, verificationCode: codeTextField.text!, verificationId: verificationId) { (error, shouldLogin) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
                if shouldLogin {
                    self.goToApp()
                } else {
                    self.performSegue(withIdentifier: "welcomeToFinishSegue", sender: self)
                }
            }
        } else {
            ProgressHUD.showError("Please insert the code!")
        }
        
    }
    
    func goToApp() {
        
    }
    
}

//
//  ViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 03/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }

    
    
    //MARK: - Actions

    @IBAction func loginButtonPressed(_ sender: UIButton) {
    
        dismissKeyboard()
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email.isEmpty || password.isEmpty {
            ProgressHUD.showError("Invalid credentials")
            return
        }
        
        loginUser()
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
    
        dismissKeyboard()
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let repeatPassword = repeatPasswordTextField.text ?? ""
        
        if email.isEmpty || password.isEmpty || repeatPassword.isEmpty {
            ProgressHUD.showError("All fields are required")
            return
        }
        
        if repeatPassword != password {
            ProgressHUD.showError("Passwords fields do not match")
            return
        }
        
        registerUser()
        
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    
    //MARK: - Helper functions
    
    func loginUser(){
        
        ProgressHUD.show("Signing in...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!, completion: { (error) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            //present the app
        })
        
    }
    
    func registerUser(){
        print("register user")
    }
    
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func clearTextFields(){
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
}


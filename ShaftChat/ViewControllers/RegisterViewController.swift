//
//  RegisterViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 19/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Actions
    
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
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        clearTextFields()
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    
    //MARK: - Helper functions
    
    func registerUser(){
        
        performSegue(withIdentifier: "welcomeToFinishRegistration", sender: self)
        
        clearTextFields()
        dismissKeyboard()
        
    }
    
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func clearTextFields(){
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "welcomeToFinishRegistration" {
            
            let viewController = segue.destination as! FinishRegistrationViewController
            viewController.email = emailTextField.text!.lowercased()
            viewController.password = passwordTextField.text!
        }
        
    }
}

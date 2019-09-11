//
//  FinishRegistrationViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 04/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class FinishRegistrationViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet var AvatarTapGesture: UITapGestureRecognizer!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(AvatarTapGesture)
    }
    
    //MARK: - Actions
    
    @IBAction func avatarImageTap(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        dismissKeyboard()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        clearTextFields()
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        let name = nameTextField.text ?? ""
        let surname = surnameTextField.text ?? ""
        let country = countryTextField.text ?? ""
        let city = cityTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        
        if name.isEmpty || surname.isEmpty || country.isEmpty || city.isEmpty || phone.isEmpty {
            
            ProgressHUD.showError("All fields are required")
            return
        }
        
//        FUser.registerUserWith(email: email!, password: password!, firstName: name, lastName: surname) { (error) in
//
//            if error != nil {
//                ProgressHUD.dismiss()
//                ProgressHUD.showError(error!.localizedDescription)
//                return
//            }
//
//            self.registerUser(name: name, surname: surname, country: country, city: city, phone: phone)
//
//        }
        
        self.registerUser()
    }
    
    //MARK: - Helper functions
    
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func clearTextFields(){
        nameTextField.text = ""
        surnameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
    
    func registerUser() {
        
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDictionary : Dictionary = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : fullName, kCOUNTRY : countryTextField.text!, kCITY : cityTextField.text!, kPHONE : phoneTextField.text!] as [String : Any]
        
        
        if avatarImage == nil {
            
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.2)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary)
            }
            
            
            
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.2)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDictionary[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDictionary)
        }
        
    }
    
    func registerUser(name: String, surname: String, country: String, city: String, phone: String){
        
        let fullname = "\(name) \(surname)"
        
        var tempDictionary : Dictionary = [ kNAME: name, kLASTNAME: surname, kFULLNAME: fullname, kCOUNTRY: country, kCITY: city, kPHONE: phone] as [String: Any]
        
        var avatar = ""
        if avatarImage == nil {
            
            imageFromInitials(firstName: name, lastName: surname) {
                (avatarInitials) in
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.5)
                avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
        } else {
            let avatarData = avatarImage!.jpegData(compressionQuality: 0.2)
            avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        }
        
        tempDictionary[kAVATAR] = avatar
        print(tempDictionary)
        self.finishRegistration(withValues: tempDictionary)
        
    }
    
    func finishRegistration(withValues: [String : Any]){
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
            }
            
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func goToApp(){
        
        clearTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.present(mainController, animated: true, completion: nil)
    }
    
    //MARK: ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        if images.count > 0 {
            avatarImage = images.first!
            avatarImageView.image = avatarImage?.circleMasked
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

}

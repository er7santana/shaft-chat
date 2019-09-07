//
//  EditProfileTableViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 03/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class EditProfileTableViewController: UITableViewController, ImagePickerDelegate {
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var avatarTapGestureRecognizer: UITapGestureRecognizer!
    
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    
    //MARK: - IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if firstNameTextField.text != "" && surnameTextField.text != "" && emailTextField.text != "" {
            
            ProgressHUD.show("Saving...")
            
            //block save button
            saveButtonOutlet.isEnabled = false
            
            let fullName = firstNameTextField.text! + " " + surnameTextField.text!
            
            var withValues = [kFIRSTNAME : firstNameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : fullName, kEMAIL : emailTextField.text!]
            
            if avatarImage != nil {
                
                let avatarData = avatarImage!.jpegData(compressionQuality: 0.2)!
                let avatarString = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                withValues[kAVATAR] = avatarString
            }
            
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error!.localizedDescription)
                        print("couldnt update user \(error!.localizedDescription)")
                    }
                    
                    self.saveButtonOutlet.isEnabled = true
                    return
                }
                
                ProgressHUD.showSuccess("Saved")
                self.saveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    @IBAction func avatarTap(_ sender: Any) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: - SetupUI
    
    func setupUI() {
        
        let currentUser = FUser.currentUser()!
        avatarImageView.isUserInteractionEnabled = true
        
        firstNameTextField.text = currentUser.firstname
        surnameTextField.text = currentUser.lastname
        emailTextField.text = currentUser.email
        
        if currentUser.avatar != "" {
            
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    
                    avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    //MARK: - ImagePicker delegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        if images.count > 0 {
            avatarImage = images.first!
            avatarImageView.image = avatarImage!.circleMasked
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    


}

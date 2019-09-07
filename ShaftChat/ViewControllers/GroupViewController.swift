//
//  GroupViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 05/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class GroupViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet weak var cameraButtonOutlet: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet var cameraTapGestureRecognizer: UITapGestureRecognizer!
    
    var group: NSDictionary!
    var groupIcon: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButtonOutlet.isUserInteractionEnabled = true
        cameraButtonOutlet.addGestureRecognizer(cameraTapGestureRecognizer)

        setupUI()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Invite Users", style: .plain, target: self, action: #selector(self.inviteUsers))]
    }
    
    //MARK: - Actions
    
    @IBAction func cameraIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        var withValues: [String : Any]!
        
        if groupNameTextField.text != "" {
            withValues = [kNAME : groupNameTextField.text!]
        } else {
            ProgressHUD.showError("Subject is required")
            return
        }
        
        let avatarData = cameraButtonOutlet.image?.jpegData(compressionQuality: 0.2)
        let avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        withValues = [kNAME : groupNameTextField.text!, kAVATAR : avatarString!]
        
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        
        withValues = [kWITHUSERFULLNAME : groupNameTextField.text!, kAVATAR : avatarString]
        
        updateExistingRecentWithNewValues(chatRoomId: group[kGROUPID] as! String, memberIds: group[kMEMBERS] as! [String], withValues: withValues)
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func inviteUsers() {
        
        let userViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "inviteUserTableView") as! InviteUsersTableViewController
        userViewController.group = group
        navigationController?.pushViewController(userViewController, animated: true)
    }
    
    //MARK: - Helpers
    
    func setupUI() {
        title = "Group"
        
        groupNameTextField.text = group[kNAME] as? String
        imageFromData(pictureData: group[kAVATAR] as! String) { (avatarImage) in
            
            if avatarImage != nil {
                self.cameraButtonOutlet.image = avatarImage!.circleMasked
            }
        }
    }
    
    
    func showIconOptions() {
        
        let optionMenu = UIAlertController(title: "Choose group icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/choose photo", style: .default) { (alert) in
            
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageLimit = 1
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAlert) in
            
        }
        
        if groupIcon != nil {
            
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (resetAlert) in
                
                self.groupIcon = nil
                self.cameraButtonOutlet.image = UIImage(named: "cameraIcon")
                self.editButtonOutlet.isHidden = true
            }
            
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        //for iPad not to crash
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverPresentationController = optionMenu.popoverPresentationController {
                currentPopoverPresentationController.sourceView = editButtonOutlet
                currentPopoverPresentationController.sourceRect = editButtonOutlet.bounds
                
                currentPopoverPresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        if images.count > 0 {
            groupIcon = images.first!
            cameraButtonOutlet.image = groupIcon!.circleMasked
            editButtonOutlet.isHidden = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

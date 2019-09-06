//
//  GroupViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 05/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD

class GroupViewController: UIViewController {

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
    }
    
    @objc func inviteUsers() {
        
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
            
            print("camera")
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
    
}

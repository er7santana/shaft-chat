//
//  NewGroupViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 05/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class NewGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupMemberCollectionViewCellDelegate, ImagePickerDelegate {

    @IBOutlet weak var editAvatarButtonOutlet: UIButton!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        groupIconImageView.isUserInteractionEnabled = true
        groupIconImageView.addGestureRecognizer(iconTapGesture)
        
        updateParticipantsLabel()
    }

    //MARK: - Collection View data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupMemberCell", for: indexPath) as! GroupMemberCollectionViewCell
        
        cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    //MARK: IBActions
    
    @objc func createButtonPressed(_ sender: Any) {
        
        if groupSubjectTextField.text != "" {
            memberIds.append(FUser.currentId())
            
            let avatarData = UIImage(named: "groupIcon")!.jpegData(compressionQuality: 0.2)!
            var avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            if groupIcon != nil {
                
                let avatarData = groupIcon!.jpegData(compressionQuality: 0.2)!
                avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            
            let groupId = UUID().uuidString
            
            let group = Group(groupId: groupId, subject: groupSubjectTextField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar)
            
            group.saveGroup()
            
            startGroupChat(group: group)
            
            let chatViewController = ChatViewController()
            chatViewController.titleName = (group.groupDictionary[kNAME] as? String)
            chatViewController.memberIds = (group.groupDictionary[kMEMBERS] as! [String])
            chatViewController.membersToPush = (group.groupDictionary[kMEMBERS] as! [String])
            chatViewController.chatRoomId = groupId
            chatViewController.isGroup = true
            chatViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatViewController, animated: true)
            
        } else {
            ProgressHUD.showError("Subject is required")
        }
    }
    
    @IBAction func groupIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showIconOptions()
    }
    
    //MARK: - GroupMemberCollectionViewCellDelegate
    
    func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        
        collectionView.reloadData()
        updateParticipantsLabel()
    }
    
    //MARK: - Helper Functions
    
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
                self.groupIconImageView.image = UIImage(named: "cameraIcon")
                self.editAvatarButtonOutlet.isHidden = true
            }
            
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        //for iPad not to crash
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let currentPopoverPresentationController = optionMenu.popoverPresentationController {
                currentPopoverPresentationController.sourceView = editAvatarButtonOutlet
                currentPopoverPresentationController.sourceRect = editAvatarButtonOutlet.bounds
                
                currentPopoverPresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func updateParticipantsLabel() {
        
        participantsLabel.text = "Participants: \(allMembers.count)"
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }
    
    //MARK: - ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            groupIcon = images.first!
            groupIconImageView.image = groupIcon!.circleMasked
            editAvatarButtonOutlet.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

}

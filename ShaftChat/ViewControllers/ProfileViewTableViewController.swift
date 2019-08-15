//
//  ProfileViewTableViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 14/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockUserOutlet: UIButton!
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func blockUserPressed(_ sender: Any) {
        
        var currentBlockedUserIds = FUser.currentUser()!.blockedUsers
        
        if currentBlockedUserIds.contains(user!.objectId) {
            currentBlockedUserIds.remove(at: currentBlockedUserIds.firstIndex(of: user!.objectId)!)
        }
        else {
            currentBlockedUserIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID: currentBlockedUserIds]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            self.updateBlockStatus()
        }
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    //MARK: - Methods
    
    func setupUI() {
        if user != nil {
            self.title = "Profile"
            fullNameLabel.text = user!.fullname
            phoneLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        
        if user!.objectId == FUser.currentId() {
            callButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            blockUserOutlet.isHidden = true
        } else {
            callButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            blockUserOutlet.isHidden = false
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockUserOutlet.setTitle("Unblock User", for: .normal)
            blockUserOutlet.setTitleColor(UIColor.black, for: .normal)
        } else {
            blockUserOutlet.setTitle("Block User", for: .normal)
            blockUserOutlet.setTitleColor(UIColor.red, for: .normal)
        }
        
    }
}

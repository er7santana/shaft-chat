//
//  InviteUsersTableViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 05/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class InviteUsersTableViewController: UITableViewController, UserTableViewCellDelegate {
    

    @IBOutlet weak var headerView: UIView!
    
    var allUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String: [FUser]]
    var sectionTitleList: [String] = []
    
    var newMemberIds: [String] = []
    var currentMemberIds: [String] = []
    var group: NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers(filter: kCITY)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ProgressHUD.dismiss()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Users"
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonPressed))]
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        currentMemberIds = group[kMEMBERS] as! [String]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return allUsersGroupped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitleList[section]
        let users = allUsersGroupped[sectionTitle]
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTableViewCell", for: indexPath) as! UserTableViewCell
        
        let user = getSelectedUser(indexPath)
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        
        cell.delegate = self
        
        return cell
    }
    
    //MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleList[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUser = getSelectedUser(indexPath)
        
        if currentMemberIds.contains(selectedUser.objectId) {
            ProgressHUD.showError("Already in the group")
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        
        //add/remove users
        let selected = newMemberIds.contains(selectedUser.objectId)
        if selected {
            newMemberIds.remove(at: newMemberIds.firstIndex(of: selectedUser.objectId)!)
        } else {
            newMemberIds.append(selectedUser.objectId)
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = newMemberIds.count > 0
    }
    
    //MARK: Load Users
    
    
    func loadUsers(filter: String){
        
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        
                        self.allUsers.append(fUser)
                    }
                }
                
                self.splitDataIntoSection()
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
    }

    
    //MARK: Helper Functions
    
    
    fileprivate func splitDataIntoSection(){
        
        var sectionTitle = ""
        
        for i in 0..<allUsers.count {
            let currentUser = allUsers[i]
            let firstChar = currentUser.firstname.first!
            let firstCharString = "\(firstChar)"
            
            if firstCharString != sectionTitle {
                
                sectionTitle = firstCharString
                
                self.allUsersGroupped[sectionTitle] = []
                
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
            }
            
            self.allUsersGroupped[firstCharString]?.append(currentUser)
        }
    }
    
    fileprivate func getSelectedUser(_ indexPath: IndexPath) -> FUser {
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGroupped[sectionTitle]
        return users![indexPath.row]
    }

    
    //MARK: - IBActions
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.loadUsers(filter: kCITY)
        case 1:
            self.loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    @objc func doneButtonPressed() {
        
    }
    
    //MARK: - UsersTableViewCellDelegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        profileViewController.user = getSelectedUser(indexPath)
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
}

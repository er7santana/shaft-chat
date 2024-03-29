//
//  ChatsViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 13/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecentChatsTableViewCellDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadRecentChats()
        tableView.tableFooterView = UIView()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        recentListener.remove()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        
        setHeaderTableView()
    }
    
    //MARK: - Actions
    
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        
        selectUserForChat(isGroup: false)
    }
    
    //MARK: - TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        }
        
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentChatCell", for: indexPath) as! RecentChatsTableViewCell
        
        let recentChat = getSelectedChat(indexPath: indexPath)
        
        cell.generateCell(recentChat: recentChat, indexPath: indexPath)
        
        cell.delegate = self
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let tempRecent = getSelectedChat(indexPath: indexPath)
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
            deleteRecentChat(recentChatDictionary: tempRecent)
            self.tableView.reloadData()
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            
            self.updatePushMembers(recent: tempRecent, mute: mute)
        }
        muteAction.backgroundColor = #colorLiteral(red: 0.06357951079, green: 0.7035536149, blue: 1, alpha: 1)
        
        return [deleteAction, muteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let recentChat = getSelectedChat(indexPath: indexPath)
        
        //restart chat
        restartRecentChat(recent: recentChat)
        
        //show chat controller
        let chatViewController = ChatViewController()
        chatViewController.hidesBottomBarWhenPushed = true
        
        chatViewController.isGroup = (recentChat[kTYPE] as! String) == kGROUP
        chatViewController.membersToPush = (recentChat[kMEMBERSTOPUSH] as? [String])!
        chatViewController.memberIds = (recentChat[kMEMBERS] as? [String])!
        chatViewController.chatRoomId = (recentChat[kCHATROOMID] as? String)!
        chatViewController.titleName = (recentChat[kWITHUSERFULLNAME] as? String)!
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    //MARK: - Get Recent Chats
    
    func loadRecentChats() {
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] as! String != "" && recent[kRECENTID] as! String != "" {
                        
                        self.recentChats.append(recent)
                    }
                }
                
//                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            
        })
        
    }
    
    // MARK: - Helper functions
    
    func selectUserForChat(isGroup: Bool) {
        
        let contactsViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactsView") as! ContactsTableViewController
        
        contactsViewController.isGroup = isGroup
        
        self.navigationController?.pushViewController(contactsViewController, animated: true)
    }
    
    func getSelectedChat (indexPath: IndexPath) -> NSDictionary {
     
        var selectedChat: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            
            selectedChat = filteredChats[indexPath.row]
        } else {
            
            selectedChat = recentChats[indexPath.row]
        }
        
        return selectedChat
    }
    
    func setHeaderTableView() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
        let newGroupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
        
        newGroupButton.addTarget(self, action: #selector(self.newGroupButtonPressed), for: .touchUpInside)
        newGroupButton.setTitle("New Group", for: .normal)
        newGroupButton.setTitleColor(#colorLiteral(red: 0.06357951079, green: 0.7035536149, blue: 1, alpha: 1), for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        buttonView.addSubview(newGroupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
    }
    
    @objc func newGroupButtonPressed() {
        selectUserForChat(isGroup: true)
    }
    
    func showUserProfile(user: FUser) {
        
        let profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        profileViewController.user = user
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
    }
    
    //MARK: - RecentChatsTableViewCellDelegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        let recentChat = getSelectedChat(indexPath: indexPath)
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    self.showUserProfile(user: tempUser)
                }
            }
        }
        
    }
    
    
    //MARK: - SearchResultsUpdating functions
    
    func filterContentsForSearchText(searchText: String, scope: String = "All"){
        
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentsForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func updatePushMembers(recent: NSDictionary, mute: Bool) {
        
        var membersToPush = recent[kMEMBERSTOPUSH] as! [String]
        
        if mute {
            let index = membersToPush.firstIndex(of: FUser.currentId())!
            membersToPush.remove(at: index)
        } else {
            membersToPush.append(FUser.currentId())
        }
        
        updateExistingRecentWithNewValues(chatRoomId: recent[kCHATROOMID] as! String, memberIds: recent[kMEMBERS] as! [String], withValues: [kMEMBERSTOPUSH : membersToPush])
    }
    
}

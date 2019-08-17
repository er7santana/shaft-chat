//
//  ChatsViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 13/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadRecentChats()
    }
    
    //MARK: - Actions
    
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        
        let usersViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(usersViewController, animated: true)
    }
    
    //MARK: - TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentChatCell", for: indexPath) as! RecentChatsTableViewCell
        
        let recentChat = recentChats[indexPath.row]
        
        cell.generateCell(recentChat: recentChat, indexPath: indexPath)
        
        return cell;
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
    
}

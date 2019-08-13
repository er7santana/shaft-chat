//
//  ChatsViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 13/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - Actions
    
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        
        let usersViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(usersViewController, animated: true)
    }
    
    
}

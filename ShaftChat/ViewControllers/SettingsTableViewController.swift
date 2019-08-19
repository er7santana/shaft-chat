//
//  SettingsTableViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 04/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    //MARK: - Actions

    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success {
                self.showLoginView()
            }
        }
        
    }
    
    //MARK: - Helper functions
    
    func showLoginView(){
        
        let mainController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
        
        self.present(mainController, animated: true, completion: nil)
    }
    
    
}

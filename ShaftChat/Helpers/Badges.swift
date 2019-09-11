//
//  Badges.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 10/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import Foundation
import FirebaseFirestore

func recentBadgeCount(withBlock: @escaping(_ badgeNumber: Int) -> Void) {
    recentBadgeHandler = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
        
        var badge = 0
        var count = 0
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            let recents = snapshot.documents
            
            for recent in recents {
                let currentRecent = recent.data() as NSDictionary
                badge += currentRecent[kCOUNTER] as! Int
                count += 1
                
                if count == recents.count {
                    withBlock(badge)
                }
            }
        } else {
            withBlock(badge)
        }
    })
}

func setBadges(controller: UITabBarController) {
    recentBadgeCount { (badge) in
        if badge != 0 {
            controller.tabBar.items![1].badgeValue = "\(badge)"
        } else {
            controller.tabBar.items![1].badgeValue = nil
        }
    }
}

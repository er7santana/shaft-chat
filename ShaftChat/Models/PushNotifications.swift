//
//  PushNotifications.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 07/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import Foundation
import OneSignal

func sendPushNotification(membersToPush: [String], message: String) {
    
    let updatedMembers = removeCurrentUserFromMembersArray(membersToPush: membersToPush)
    getMembersToPush(members: updatedMembers) { (userPushIds) in
        let currentUser = FUser.currentUser()!
        
        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1", "include_player_ids" : userPushIds])
    }
    
}

func removeCurrentUserFromMembersArray(membersToPush: [String]) -> [String] {
    
    var updatedMembers: [String] = []
    
    for memberId in membersToPush {
        if memberId != FUser.currentId() {
            updatedMembers.append(memberId)
        }
    }
    
    return updatedMembers
}

func getMembersToPush(members: [String], completion: @escaping(_ usersArray: [String]) -> Void) {
    
    var pushIds: [String] = []
    var count = 0
    
    for memberId in members {
        reference(.User).document(memberId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(pushIds)
                return
            }
            
            if snapshot.exists {
                
                let userDictionary = snapshot.data() as! NSDictionary
                let fUser = FUser.init(_dictionary: userDictionary)
                pushIds.append(fUser.pushId!)
                count += 1
                
                if members.count == count {
                    completion(pushIds)
                }
                
            } else {
                completion(pushIds)
            }
        }
    }
}

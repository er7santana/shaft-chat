//
//  Recent.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 15/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser) -> String {
    
    let user1Id = user1.objectId;
    let user2Id = user2.objectId;
    
    var chatRoomId = ""
    
    let difference = user1Id.compare(user2Id).rawValue
    if difference < 0 {
        chatRoomId = user1Id + user2Id
    } else {
        chatRoomId = user2Id + user1Id
    }
    
    let members = [user1Id, user2Id]
    
    createRecent(members: members, chatRoomId: chatRoomId, withUserUsername: "", type: kPRIVATE, users: [user1, user2], avatarOfGroup: nil)
    
    return chatRoomId
    
}


func createRecent(members: [String], chatRoomId: String, withUserUsername: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    var tempMembers = members
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                
                if let currentUserId = currentRecent[kUSERID] {
                    
                    if tempMembers.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
            
        }
        for userId in tempMembers {
            
            createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUsername: withUserUsername, type: type, users: users, avatarOfGroup: avatarOfGroup)
            
        }
    }
}

func createRecentItems(userId: String, chatRoomId: String, members: [String], withUsername: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent: [String: Any]!
    
    if type == kPRIVATE {
        
        var withUser: FUser?
        
        if users != nil && users!.count > 0 {
            
            if userId == FUser.currentId() {
                withUser = users!.last
            } else {
                withUser = users!.first
            }
        }
        
        recent = [kRECENTID : recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUser!.fullname, kWITHUSERUSERID: withUser!.objectId, kLASTMESSAGE: "", kCOUNTER : 0, kDATE : date, kTYPE : type, kAVATAR: withUser!.avatar] as [String: Any]
        
    } else {
        
        if avatarOfGroup != nil {
            recent = [ kRECENTID: recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kMEMBERSTOPUSH: members, kWITHUSERFULLNAME: withUsername, kLASTMESSAGE : "", kCOUNTER : 0, kDATE : date, kTYPE : type, kAVATAR : avatarOfGroup!] as [String : Any]
        }
        
    }
    
    //save recent chat
    localReference.setData(recent)
    
}

func restartRecentChat(recent: NSDictionary) {
    
    if recent[kTYPE] as! String == kPRIVATE {
        
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUsername: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
        
    } else if recent[kTYPE] as! String == kGROUP {
        
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUsername: recent[kWITHUSERFULLNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as? String)
    }
}

//Update Recents


func updateRecents(chatRoomId: String, lastMessage: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
            }
        }
    }
}

func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    
    let date = dateFormatter().string(from: Date())
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as? String != FUser.currentId() {
        counter += 1
    }
    
    let values = [kLASTMESSAGE : lastMessage, kCOUNTER : counter, kDATE : date] as [String : Any]
    
    reference(.Recent).document(recent[kRECENTID] as! String).updateData(values)
}


//Delete recent Chats

func deleteRecentChat(recentChatDictionary: NSDictionary) {
    
    if let recentId = recentChatDictionary[kRECENTID] {
        reference(.Recent).document(recentId as! String).delete()
    }
}

//Clear counter

func clearRecentCounter(chatRoomId: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                if currentRecent[kUSERID] as! String == FUser.currentId() {
                    
                    clearRecentCounterItem(recent: currentRecent)
                }
            }
        }
    }
}

func clearRecentCounterItem(recent: NSDictionary) {
    
    reference(.Recent).document(recent[kRECENTID] as! String).updateData([kCOUNTER : 0])
}

// group

func startGroupChat(group: Group) {
    let chatRoomId = group.groupDictionary[kGROUPID] as! String
    let members = group.groupDictionary[kMEMBERS] as! [String]
    
    createRecent(members: members, chatRoomId: chatRoomId, withUserUsername: group.groupDictionary[kNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: group.groupDictionary[kAVATAR] as? String)
}

func createRecentForNewMembers(groupId: String, groupName: String, membersToPush: [String], avatar: String) {
    createRecent(members: membersToPush, chatRoomId: groupId, withUserUsername: groupName, type: kGROUP, users: nil, avatarOfGroup: avatar)
}

func updateExistingRecentWithNewValues(chatRoomId: String, memberIds: [String], withValues: [String : Any]) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let recent = recent.data() as NSDictionary
                updateRecent(recentId: recent[kRECENTID] as! String, withValues: withValues)
            }
        }
    }
}

func updateRecent(recentId: String, withValues: [String: Any]) {
    
    reference(.Recent).document(recentId).updateData(withValues)
}


//Block user

func blockUser(userToBlock: FUser) {
    
    let user1Id = FUser.currentId()
    let user2Id = userToBlock.objectId
    
    var chatRoomId = ""
    
    let difference = user1Id.compare(user2Id).rawValue
    if difference < 0 {
        chatRoomId = user1Id + user2Id
    } else {
        chatRoomId = user2Id + user1Id
    }
    
    deleteRecentsFor(chatRoomId: chatRoomId)
}

func deleteRecentsFor(chatRoomId: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let recent = recent.data() as NSDictionary
                deleteRecentChat(recentChatDictionary: recent)
            }
        }
    }
}

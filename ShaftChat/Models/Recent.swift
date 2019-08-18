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
            
            createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUsername: "", type: type, users: users, avatarOfGroup: avatarOfGroup)
            
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


//Delete recent Chats

func deleteRecentChat(recentChatDictionary: NSDictionary) {
    
    if let recentId = recentChatDictionary[kRECENTID] {
        reference(.Recent).document(recentId as! String).delete()
    }
}

//
//  OutgoingMessage.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 18/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    let messageDictionary: NSMutableDictionary
    
    //MARK: - Initializers
    
    //text Messages
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
    
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    
    
    
    
    
    
    
    //MARK: - Send message
    
    func sendMessage(chatRoomId: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String: Any])
        }
        
        // update recent Chat
        
        //send Push notification
    }
    
}
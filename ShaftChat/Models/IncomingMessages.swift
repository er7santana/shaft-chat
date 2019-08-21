//
//  IncomingMessages.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 18/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessages {
    
    var collectionView: JSQMessagesCollectionView
    
    init(_collectionView: JSQMessagesCollectionView) {
        collectionView = _collectionView
    }
    
    //MARK: - create message
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
            //create video message
            print("video message")
        case kAUDIO:
            //create audio message
            print("audio message")
        case kLOCATION:
            //create location message
            print("location message")
        default:
            print("unknown message type")
        }
        
        if message != nil {
            return message
        }
        
        return nil
        
    }
    
    //MARK: - create message types
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)
            }
            
        } else {
            date = Date()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: (messageDictionary[kMESSAGE] as! String))
    }
    
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)
            }
            
        } else {
            date = Date()
        }
        
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        //download image
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            
            if image != nil {
                
                mediaItem?.image = image!
                self.collectionView.reloadData()
            }
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
        
        return senderId == FUser.currentId()
    }
    
}

//
//  ChatViewController.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 18/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {

    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    // fix for iPhone X
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    // end of fix For iPhone X
    
    override func viewDidLoad() {
        super.viewDidLoad()

        senderId = FUser.currentId()
        senderDisplayName = FUser.currentUser()!.firstname
        
        // fix for iPhone X

        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(rawValue: 999)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // end of fix For iPhone X

    }
    
}

//
//  CallViewController.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 10/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class CallViewController: UIViewController, SINCallDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var speaker = false
    var mute = false
    var durationTimer: Timer! = nil
    var _call: SINCall!
    var callAnswered = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userNameLabel.text = "Unknown"
        let id = _call.remoteUserId
        getUsersFromFirestore(withIds: [id!]) { (allUsers) in
            if allUsers.count > 0 {
                let user = allUsers.first!
                self.userNameLabel.text = user.fullname
                imageFromData(pictureData: user.avatar, withBlock: { (avatarImage) in
                    if avatarImage != nil {
                        self.avatarImageView.image = avatarImage!.circleMasked
                    }
                })
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _call.delegate = self
        if _call.direction == .incoming {
            showButtons()
            
        } else {
            callAnswered = true
            setCallStatus(text: "Calling...")
            showButtons()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func muteButtonPressed(_ sender: Any) {
    }
    
    @IBAction func speakerButtonPressed(_ sender: Any) {
    }
    
    @IBAction func answerButtonPressed(_ sender: Any) {
    }
    
    @IBAction func endCallButtonPressed(_ sender: Any) {
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
    }
    
    //MARK: - Update UI
    
    func setCallStatus(text: String) {
        statusLabel.text = text
    }
    
    func showButtons() {
        if callAnswered {
            declineButton.isHidden = true
            endCallButton.isHidden = false
            answerButton.isHidden = true
            muteButton.isHidden = false
            speakerButton.isHidden = false
        } else {
            declineButton.isHidden = false
            endCallButton.isHidden = true
            answerButton.isHidden = false
            muteButton.isHidden = true
            speakerButton.isHidden = true
        }
    }
}

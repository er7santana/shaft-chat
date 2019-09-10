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
    var muted = false
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
            audioController().startPlayingSoundFile(pathForSound(soundName: "incoming"), loop: true)
        } else {
            callAnswered = true
            setCallStatus(text: "Calling...")
            showButtons()
        }
    }
    
    func audioController() -> SINAudioController {
        return appDelegate._client.audioController()
    }
    
    func setCall(call: SINCall) {
        _call = call
        _call.delegate = self
    }
    
    //MARK: - IBActions
    
    @IBAction func muteButtonPressed(_ sender: Any) {
        if muted {
            muted = false
            audioController().unmute()
            muteButton.setImage(UIImage(named: "mute"), for: .normal)
        } else {
            muted = true
            audioController().mute()
            muteButton.setImage(UIImage(named: "muteSelected"), for: .normal)
        }
    }
    
    @IBAction func speakerButtonPressed(_ sender: Any) {
        if speaker {
            speaker = false
            audioController().disableSpeaker()
            speakerButton.setImage(UIImage(named: "speaker"), for: .normal)
        } else {
            speaker = true
            audioController().enableSpeaker()
            speakerButton.setImage(UIImage(named: "speakerSelected"), for: .normal)
        }
    }
    
    @IBAction func answerButtonPressed(_ sender: Any) {
        callAnswered = true
        showButtons()
        audioController().stopPlayingSoundFile()
        _call.answer()
    }
    
    @IBAction func endCallButtonPressed(_ sender: Any) {
        _call.hangup()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        _call.hangup()
        dismiss(animated: true, completion: nil)
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
    
    //MARK: - Helpers
    
    func pathForSound(soundName: String) -> String {
        return Bundle.main.path(forResource: soundName, ofType: "wav")!
    }
}

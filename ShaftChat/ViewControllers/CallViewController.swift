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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
}

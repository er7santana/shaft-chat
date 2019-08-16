//
//  RecentChatsTableViewCell.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 16/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

protocol RecentChatsTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet weak var messageCounterBackground: UIView!
    
    var delegate: RecentChatsTableViewCellDelegate?
    var indexPath: IndexPath!
    var tapGesture = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageCounterBackground.layer.cornerRadius = messageCounterBackground.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Generate Cell
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        nameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
//        counterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                
                if avatarImage != nil {
                    avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int > 0 {
            counterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            messageCounterBackground.isHidden = false
            counterLabel.isHidden = false
        } else {
            messageCounterBackground.isHidden = true
            counterLabel.isHidden = true
        }
        
        var date = Date()
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)!
            }
        } else {
            date = Date()
        }
        
        dateLabel.text = timeElapsed(date: date)
        
    }
    
    //MARK: - Avatar tap
    @objc func avatarTap() {
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }

}

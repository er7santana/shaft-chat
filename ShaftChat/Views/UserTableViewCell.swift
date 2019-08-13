//
//  UserTableViewCell.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 12/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var indexPath: IndexPath?
    
    let avatarTapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarTapGestureRecognizer.addTarget(self, action: #selector(avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarTapGestureRecognizer)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCellWith(fUser: FUser, indexPath: IndexPath){
        
        self.indexPath = indexPath
        fullNameLabel.text = fUser.fullname
        
        if fUser.avatar != "" {
            imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    @objc func avatarTap(){
        
    }

}

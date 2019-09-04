//
//  BackgroundCollectionViewCell.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 03/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        
        self.imageView.image = image
    }
}

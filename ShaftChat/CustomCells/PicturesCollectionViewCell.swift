//
//  PicturesCollectionViewCell.swift
//  ShaftChat
//
//  Created by Eliezer Rodrigo on 02/09/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        
        self.imageView.image = image
    }
}

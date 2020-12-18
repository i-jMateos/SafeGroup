//
//  ImageCollectionViewCell.swift
//  SafeGroup
//
//  Created by omaestra on 17/12/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 5
        self.layer.cornerRadius = 5
    }
}

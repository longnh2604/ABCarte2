//
//  GalleryCell.swift
//  ABCarte2
//
//  Created by Long on 2018/10/22.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage

class GalleryCell: UICollectionViewCell {

    //IBOutlet
    @IBOutlet weak var imvPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 5.0
                layer.borderColor = UIColor(red:56/255, green:192/255, blue:201/255, alpha:1.0).cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    func configure(media: MediaData) {
        if media.thumb != "" {
            let url = URL(string: media.thumb)
            self.imvPhoto.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvPhoto.image = UIImage(named: "nophotoIcon")
        }
    }

}

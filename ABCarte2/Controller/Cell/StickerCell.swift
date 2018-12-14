//
//  StickerCell.swift
//  ABCarte2
//
//  Created by Long on 2018/10/05.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StickerCell: UICollectionViewCell {
    
    //IBOutlet
    @IBOutlet weak var imvSticker: UIImageView!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(imv: String) {
        
        imvSticker.image = UIImage(named: imv)
        
    }
}

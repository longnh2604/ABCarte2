//
//  ImageSelectCell.swift
//  JBSDemo
//
//  Created by Long on 2018/05/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class ImageSelectCell: UICollectionViewCell {
    
    //IBOutlet
    @IBOutlet weak var imvPhoto: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 5.0
                layer.borderColor = UIColor(red:244/255, green:66/255, blue:66/255, alpha:1.0).cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}

//
//  FontCell.swift
//  ABCarte2
//
//  Created by Long on 2018/11/01.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class FontCell: UICollectionViewCell {

    @IBOutlet weak var lblFontName: UILabel!
    
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
    
    func configure(font: String) {
        lblFontName.font = UIFont(name: font, size: 14)
        lblFontName.text = font
    }

}

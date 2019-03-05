//
//  ColorStyleCell.swift
//  ABCarte2
//
//  Created by Long on 2019/01/16.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class ColorStyleCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
    
    func configure(title:String,photo:String) {
        lblTitle.text = title
        imvPhoto.image = UIImage(named: photo)
    }
    
}

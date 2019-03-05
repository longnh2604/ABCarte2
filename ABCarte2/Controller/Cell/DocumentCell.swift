//
//  DocumentCell.swift
//  ABCarte2
//
//  Created by Long on 2019/01/08.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var btnCell: RoundButton!
    @IBOutlet weak var imvEdited: RoundImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title:String,edited:Bool) {
        
        btnCell.setTitle(title, for: .normal)
        
        if edited {
            imvEdited.isHidden = false
        }
    }
}

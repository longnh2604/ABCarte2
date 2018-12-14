//
//  StampCategoryCell.swift
//  ABCarte2
//
//  Created by Long on 2018/10/02.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StampCategoryCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(categories: StampCategoryData){
        lblTitle.text = categories.title
    }
    
}

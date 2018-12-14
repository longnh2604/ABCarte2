//
//  StampCell.swift
//  ABCarte2
//
//  Created by Long on 2018/08/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StampCell: UITableViewCell {

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
    
    func configure(stamp: StampKeywordData,selected:Bool){
        lblTitle.text = stamp.content
        if selected {
            lblTitle.backgroundColor = UIColor.red
        } else {
            lblTitle.backgroundColor = UIColor.clear
        }
    }
    
    func onSelectStatus(selected:Bool) {
        if selected {
            lblTitle.backgroundColor = UIColor.red
        } else {
            lblTitle.backgroundColor = UIColor.clear
        }
        
    }

}

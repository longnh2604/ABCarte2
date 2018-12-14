//
//  DailyReportCell.swift
//  ABCarte2
//
//  Created by Long on 2018/11/05.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class DailyReportCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var imvCell: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(title: String) {
        lblTitle.text = title
    }
}

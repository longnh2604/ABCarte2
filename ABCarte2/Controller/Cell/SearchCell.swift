//
//  SearchCell.swift
//  ABCarte2
//
//  Created by Long on 2018/05/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            switch set {
            case 0:
                viewBG.backgroundColor = COLOR_SET000.kEDIT_SCREEN_BACKGROUND_COLOR
            case 1:
                viewBG.backgroundColor = COLOR_SET001.kEDIT_SCREEN_BACKGROUND_COLOR
            case 2:
                viewBG.backgroundColor = COLOR_SET002.kEDIT_SCREEN_BACKGROUND_COLOR
            case 3:
                viewBG.backgroundColor = COLOR_SET003.kEDIT_SCREEN_BACKGROUND_COLOR
            case 4:
                viewBG.backgroundColor = COLOR_SET004.kEDIT_SCREEN_BACKGROUND_COLOR
            case 5:
                viewBG.backgroundColor = COLOR_SET005.kEDIT_SCREEN_BACKGROUND_COLOR
            case 6:
                viewBG.backgroundColor = COLOR_SET006.kEDIT_SCREEN_BACKGROUND_COLOR
            case 7:
                viewBG.backgroundColor = COLOR_SET007.kEDIT_SCREEN_BACKGROUND_COLOR
            default:
                break
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

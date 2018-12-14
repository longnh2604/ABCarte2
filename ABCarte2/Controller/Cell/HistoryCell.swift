//
//  HistoryCell.swift
//  ABCarte2
//
//  Created by Long on 2018/12/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(data: CarteData){
        
        if data.carte_photo.isEmpty {
            if data.medias.count > 0 {
                
                let url = URL(string: (data.medias.last?.url)!)
                
                imvCus.sd_setImage(with: url) { [weak self](image, error, cache, url) in
                    
                }
                
            } else {
                
                imvCus.image = UIImage(named: "nophotoIcon")
            }
        } else {
            
            let url = URL(string: data.carte_photo)
            
            imvCus.sd_setImage(with: url) {[weak self] (image, error, cache, url) in
                
            }
        }
    }
}

//
//  CarteImageCell.swift
//  ABCarte2
//
//  Created by Long on 2018/05/16.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage

protocol CarteImageCellDelegate: class {
    func didZoom(index:Int)
}

class CarteImageCell: UICollectionViewCell {
    
    //IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var lblNo: RoundLabel!
    @IBOutlet weak var btnZoom: RoundButton!
    
    //Variable
    weak var delegate:CarteImageCellDelegate?
    // The ID of your image that the cell is showing
    var imageId: String!
    // The counter label
    var counterLabel: UILabel!
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.lblNo.text = nil
        self.lblNo.isHidden = true
    }
    
    func configure(media: MediaData) {

        let date = convertUnixTimestampDT(time: media.date)
        lblTitle.text = date
        
        if media.thumb != "" {
            let url = URL(string: media.thumb)
            self.imvPhoto.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvPhoto.image = UIImage(named: "nophotoIcon")
        }
        
        imageId = media.media_id
        
        if media.selected_status == 1 {
            self.layer.borderWidth = 5.0
            self.layer.borderColor = UIColor(red:56/255, green:192/255, blue:201/255, alpha:1.0).cgColor
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        btnZoom.tag = media.id
        
        setButtonColorStyle(button: btnZoom, type: 1)
    }
    
    @IBAction func onZoom(_ sender: UIButton) {
            
        delegate?.didZoom(index: sender.tag)
        
    }
    
}

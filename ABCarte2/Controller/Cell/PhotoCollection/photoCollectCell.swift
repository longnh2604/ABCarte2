//
//  photoCollectCell.swift
//  ABCarte2
//
//  Created by Long on 2018/10/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage

protocol photoCollectCellDelegate: class {
    func didZoom(index:Int)
}

class photoCollectCell: UICollectionViewCell {
    
    //IBOutlet
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var lblTime: RoundLabel!
    @IBOutlet weak var btnZoom: RoundButton!
    
    //Variable
    weak var delegate:photoCollectCellDelegate?
    
    var imageId: String!
    var type: Int?
    
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
    
    func configure(media: MediaData) {

        if media.thumb != "" {
            let url = URL(string: media.url)
            self.imvPhoto.sd_setImage(with: url, placeholderImage:nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvPhoto.image = UIImage(named: "nophotoIcon")
        }
        
        let date = convertUnixTimestampT(time: media.date)
        lblTime.text = date
        
        btnZoom.tag = media.id
        
        imageId = media.media_id
        
        guard let ty = type else {
            btnZoom.isHidden = true
            return
        }
        if ty == 1 {
            btnZoom.isHidden = false
        } else {
            btnZoom.isHidden = true
        }
    }
    
    @IBAction func onZoom(_ sender: UIButton) {
        delegate?.didZoom(index: sender.tag)
    }
}

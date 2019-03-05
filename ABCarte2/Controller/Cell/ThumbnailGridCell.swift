//
//  ThumbnailGridCell.swift
//  ABCarte2
//
//  Created by Long on 2018/12/25.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class ThumbnailGridCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var pageNumberLabel: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            imageView.alpha = isHighlighted ? 0.8 : 1
        }
    }
    
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    
    var pageNumber = 0 {
        didSet {
            pageNumberLabel.text = String(pageNumber)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageNumberLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}

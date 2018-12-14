//
//  XibHeader.swift
//  ABCarte2
//
//  Created by Long on 2018/09/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

final class XibHeader: UICollectionReusableView {
    
    @IBOutlet weak var sectionLabel: UILabel!
    
    static let identifier: String = "XibHeader"
    
    static func nib() -> UINib {
        return UINib(nibName: XibHeader.identifier, bundle: nil)
    }
}

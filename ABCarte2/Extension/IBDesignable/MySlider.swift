//
//  MySlider.swift
//  JBSDemo
//
//  Created by Long on 2018/06/05.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

@IBDesignable
class MySlider: UISlider {

    @IBInspectable var thumbImage: UIImage? {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }
    
    @IBInspectable var thumbHighlightImage: UIImage? {
        didSet {
            setThumbImage(thumbHighlightImage, for: .highlighted)
        }
    }
}

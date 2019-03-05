//
//  TriangleView.swift
//  ABCarte2
//
//  Created by Long on 2018/05/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        
        if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            switch set {
            case 0:
                context.setFillColor(red: 17/255.0, green: 43/255.0, blue: 62/255.0, alpha: 1.0)
            case 1:
                context.setFillColor(red: 17/255.0, green: 42/255.0, blue: 64/255.0, alpha: 1.0)
            case 2:
                context.setFillColor(red: 60/255.0, green: 5/255.0, blue: 0/255.0, alpha: 1.0)
            default:
                break
            }
        }
        
        context.fillPath()
    }
}

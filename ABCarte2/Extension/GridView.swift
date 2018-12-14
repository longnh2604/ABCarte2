//
//  GridView.swift
//  ABCarte2
//
//  Created by Long on 2018/07/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class GridView: UIView
{
    //Variable
    var numberOfColumns: Int = 2
    var numberOfRows: Int = 2
    var lineWidth: CGFloat = 1.0
    var lineColor: UIColor = UIColor.red

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {

            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)

            let columnWidth = Int(rect.width) / (numberOfColumns + 1)
            for i in 1...numberOfColumns {
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                startPoint.x = CGFloat(columnWidth * i)
                startPoint.y = 0.0
                endPoint.x = startPoint.x
                endPoint.y = frame.size.height
                context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                context.strokePath()
            }

            let rowHeight = Int(rect.height) / (numberOfRows + 1)
            for j in 1...numberOfRows {
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                startPoint.x = 0.0
                startPoint.y = CGFloat(rowHeight * j)
                endPoint.x = frame.size.width
                endPoint.y = startPoint.y
                context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                context.strokePath()
            }
        }
    }
}

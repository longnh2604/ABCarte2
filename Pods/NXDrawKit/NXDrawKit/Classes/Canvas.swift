//
//  Canvas.swift
//  NXDrawKit
//
//  Created by Nicejinux on 7/14/16.
//  Copyright © 2016 Nicejinux. All rights reserved.
//

import UIKit
import CoreImage

enum DrawMode: Int {
    case kPen = 1
    case kAirBrush = 2
    case kEyeDrop = 3
    case kEraser = 4
    case kReset = 5
    case kLine = 6
    case kMosaic = 7
}

@objc public protocol CanvasDelegate
{
    @objc optional func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?)
    @objc optional func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?)
    
    func brush() -> Brush?
    func updateNewColor(color:UIColor)
}


open class Canvas: UIView, UITableViewDelegate
{
    @objc open weak var delegate: CanvasDelegate?
    
    fileprivate var canvasId: String?
    fileprivate var drawMode = 0
    
    fileprivate var mainImageView = UIImageView()
    fileprivate var tempImageView = UIImageView()
    fileprivate var backgroundImageView = UIImageView()
    
    fileprivate var brush = Brush()
    fileprivate let session = Session()
    fileprivate var drawing = Drawing()
    fileprivate let path = UIBezierPath()
    fileprivate let scale = UIScreen.main.scale
    fileprivate var fillLayer = CAShapeLayer()
    
    fileprivate var saved = false
    fileprivate var pointMoved = false
    fileprivate var pointIndex = 0
    fileprivate var points = [CGPoint?](repeating: CGPoint.zero, count: 5)
    fileprivate var startTouch:CGPoint?
    fileprivate var secondTouch:CGPoint?
    fileprivate var currentContext : CGContext?
    fileprivate var prevImage : UIImage?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc public init(canvasId: String? = nil, backgroundImage image: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        self.path.lineCapStyle = .round
        self.canvasId = canvasId
        self.backgroundImageView.image = image
        if image != nil {
            session.appendBackground(Drawing(stroke: nil, background: image))
        }
        self.initialize()
    }
    
    // MARK: - Private Methods
    fileprivate func initialize() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.contentMode = .scaleAspectFit
        self.backgroundImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
        
        self.addSubview(self.mainImageView)
        self.mainImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
        
        self.addSubview(self.tempImageView)
        self.tempImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
    }
    
    fileprivate func compare(_ image1: UIImage?, isEqualTo image2: UIImage?) -> Bool {
        if (image1 == nil && image2 == nil) {
            return true
        } else if (image1 == nil || image2 == nil) {
            return false
        }
        
        let data1 = UIImagePNGRepresentation(image1!)
        let data2 = UIImagePNGRepresentation(image2!)
        
        if (data1 == nil || data2 == nil) {
            return false
        }
        
        return (data1! == data2)
    }
    
    fileprivate func currentDrawing() -> Drawing {
        return Drawing(stroke: self.mainImageView.image, background: self.backgroundImageView.image)
    }
    
    fileprivate func updateByLastSession() {
        let lastSession = self.session.lastSession()
        self.mainImageView.image = lastSession?.stroke
        self.backgroundImageView.image = lastSession?.background
    }
    
    fileprivate func didUpdateCanvas() {
        let mergedImage = self.mergePathsAndImages()
        self.prevImage = self.mergePathsAndImages()
        let currentDrawing = self.currentDrawing()
        self.delegate?.canvas?(self, didUpdateDrawing: currentDrawing, mergedImage: mergedImage)
    }
    
    fileprivate func didSaveCanvas() {
        let mergedImage = self.mergePathsAndImages()
        self.delegate?.canvas?(self, didSaveDrawing: self.drawing, mergedImage: mergedImage)
    }
    
    fileprivate func isStrokeEqual() -> Bool {
        return self.compare(self.drawing.stroke, isEqualTo: self.mainImageView.image)
    }
    
    fileprivate func isBackgroundEqual() -> Bool {
        return self.compare(self.drawing.background, isEqualTo: self.backgroundImageView.image)
    }
    
    //Get color
    func getPixelColorAtPoint(point : CGPoint, sourceView : UIView) -> UIColor{
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        var color: UIColor? = nil
        
        if let context = context {
            context.translateBy(x: -point.x, y: -point.y)
            sourceView.layer.render(in: context)
            
            color = UIColor(red: CGFloat(pixel[0])/255.0,
                            green: CGFloat(pixel[1])/255.0,
                            blue: CGFloat(pixel[2])/255.0,
                            alpha: CGFloat(pixel[3])/255.0)
            
            pixel.deallocate()
        }
        return color!
    }
    
    open func setDrawingMode(mode: Int) {
        switch mode {
        case 1:
            drawMode = DrawMode.kPen.rawValue
        case 2:
            drawMode = DrawMode.kAirBrush.rawValue
        case 3:
            drawMode = DrawMode.kEyeDrop.rawValue
        case 4:
            drawMode = DrawMode.kEraser.rawValue
        case 5:
            drawMode = DrawMode.kReset.rawValue
        case 6:
            drawMode = DrawMode.kLine.rawValue
        case 7:
            drawMode = DrawMode.kMosaic.rawValue
        default:
            return
        }
    }
    
    open func setBrushWidth(width: CGFloat) {
        self.brush = (self.delegate?.brush())!
        self.brush.width = width
    }
    
    open func setMosaicEffect(img: UIImage) {
        self.tempImageView.image = img
        self.mainImageView.image = img
        self.prevImage = self.mainImageView.image
        self.strokePath()
        self.mergePaths()
        self.didUpdateCanvas()
    }
    
    // MARK: - Override Methods
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.saved = false
        self.pointMoved = false
        self.pointIndex = 0

        let touch = touches.first!
        self.points[0] = touch.location(in: self)
        
        if drawMode == DrawMode.kEraser.rawValue {
            self.brush.isEraser = true
            self.brush.blendMode = .clear
        } else if drawMode == DrawMode.kReset.rawValue {
            //do nothing
        } else if drawMode == DrawMode.kEyeDrop.rawValue {
            let pixelColor = getPixelColorAtPoint(point: self.points[0]!, sourceView: self)
            brush.color = pixelColor
            delegate?.updateNewColor(color: pixelColor)
        } else if drawMode == DrawMode.kLine.rawValue {
            self.brush = (self.delegate?.brush())!
            self.brush.blendMode = .normal
            startTouch = touch.location(in: self)
        } else if drawMode == DrawMode.kMosaic.rawValue {
            
        } else {
            self.brush = (self.delegate?.brush())!
            self.brush.blendMode = .normal
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        
        if drawMode == DrawMode.kEyeDrop.rawValue || drawMode == DrawMode.kReset.rawValue || drawMode == 0 || drawMode == DrawMode.kMosaic.rawValue {
            //do nothing
        } else if drawMode == DrawMode.kLine.rawValue {
            secondTouch = touch.location(in: self)

            if(self.currentContext == nil)
            {
                UIGraphicsBeginImageContext(self.frame.size)
                self.currentContext = UIGraphicsGetCurrentContext()
            }else{
                self.currentContext?.clear(CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            }
            
            self.prevImage?.draw(in: self.bounds)
            
            let bezier = UIBezierPath()
            bezier.move(to: startTouch!)
            bezier.addLine(to: secondTouch!)
            bezier.close()
            
            self.brush.color.withAlphaComponent(self.brush.alpha).set()
            self.currentContext?.setLineWidth(self.brush.width)
            self.currentContext?.addPath(bezier.cgPath)
            self.currentContext?.setLineJoin(.round)
            self.currentContext?.strokePath()
            
            let img2 = self.currentContext?.makeImage()
            self.mainImageView.image = UIImage.init(cgImage: img2!)
            
//        } else if drawMode == DrawMode.kAirBrush.rawValue {
//            if(touches.count==1) {
//                let airbrushInk = UIImage(named: "AirbrushSprite")
//                let airbrush = UIImageView(image: airbrushInk)
//                airbrush.image = airbrush.image?.withRenderingMode(.alwaysTemplate)
//                let kConcealerA = UIColor.init(red: 232/255, green: 206/255, blue: 191/255, alpha: 1)
//                airbrush.tintColor = kConcealerA
//                airbrush.alpha = 0.15
//                let pos = touch.location(in:self)
//                airbrush.frame = CGRect(x: pos.x - 18, y: pos.y - 18, width: 36, height : 36)
//                //                self.addSubview(airbrush)
//                self.backgroundImageView.addSubview(airbrush)
//            }
        } else if drawMode == DrawMode.kMosaic.rawValue {
            
            
            
        } else {
            let touch = touches.first!
            let currentPoint = touch.location(in: self)
            self.pointMoved = true
            self.pointIndex += 1
            self.points[self.pointIndex] = currentPoint
            
            if self.pointIndex == 4 {
                // move the endpoint to the middle of the line joining the second control point of the first Bezier segment
                // and the first control point of the second Bezier segment
                self.points[3] = CGPoint(x: (self.points[2]!.x + self.points[4]!.x)/2.0, y: (self.points[2]!.y + self.points[4]!.y) / 2.0)
                
                // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                self.path.move(to: self.points[0]!)
                self.path.addCurve(to: self.points[3]!, controlPoint1: self.points[1]!, controlPoint2: self.points[2]!)
                
                // replace points and get ready to handle the next segment
                self.points[0] = self.points[3]
                self.points[1] = self.points[4]
                self.pointIndex = 1
            }
            
            self.strokePath()
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if drawMode == DrawMode.kReset.rawValue || drawMode == DrawMode.kEyeDrop.rawValue || drawMode == 0 {
            //do nothing
        }
        else if drawMode == DrawMode.kLine.rawValue {
            self.prevImage = self.mainImageView.image
            self.mergePaths()
            self.didUpdateCanvas()
        }
        else {
            if !self.pointMoved {
                self.path.move(to: self.points[0]!)
                self.path.addLine(to: self.points[0]!)
                self.strokePath()
            }
            
            self.mergePaths()      // merge all paths
            self.didUpdateCanvas()
            
            self.path.removeAllPoints()
            self.pointIndex = 0
            }
    }
    
    fileprivate func strokePath() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.path.lineWidth = (self.brush.width / self.scale)
        self.brush.color.withAlphaComponent(self.brush.alpha).setStroke()
        
        if self.brush.isEraser {
            // should draw on screen for being erased
            self.mainImageView.image?.draw(in: self.bounds)
        }
        self.path.stroke(with: brush.blendMode, alpha: 1)
        
        let targetImageView = self.brush.isEraser ? self.mainImageView : self.tempImageView
        targetImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func mergePaths() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.mainImageView.image?.draw(in: self.bounds)
        self.tempImageView.image?.draw(in: self.bounds)

        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.session.append(self.currentDrawing())
        self.tempImageView.image = nil
   
        UIGraphicsEndImageContext()
    }
    
    fileprivate func mergePathsAndImages() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        if self.backgroundImageView.image != nil {
            let rect = self.centeredBackgroundImageRect()
            self.backgroundImageView.image?.draw(in: rect)            // draw background image
        }
        
        self.mainImageView.image?.draw(in: self.bounds)               // draw stroke
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()   // merge
        
        UIGraphicsEndImageContext()
        
        return mergedImage!
    }
    
    fileprivate func centeredBackgroundImageRect() -> CGRect {
        if self.frame.size.equalTo((self.backgroundImageView.image?.size)!) {
            return self.frame
        }
        
        let selfWidth = self.frame.width
        let selfHeight = self.frame.height
        let imageWidth = self.backgroundImageView.image?.size.width
        let imageHeight = self.backgroundImageView.image?.size.height
        
        let widthRatio = selfWidth / imageWidth!
        let heightRatio = selfHeight / imageHeight!
        let scale = min(widthRatio, heightRatio)
        let resizedWidth = scale * imageWidth!
        let resizedHeight = scale * imageHeight!
        
        var rect = CGRect.zero
        rect.size = CGSize(width: resizedWidth, height: resizedHeight)
        
        if selfWidth > resizedWidth {
            rect.origin.x = (selfWidth - resizedWidth) / 2
        }
        
        if selfHeight > resizedHeight {
            rect.origin.y = (selfHeight - resizedHeight) / 2
        }
        
        return rect
    }
    
    
    // MARK: - Public Methods
    @objc open func update(_ backgroundImage: UIImage?) {
        self.backgroundImageView.image = backgroundImage
        self.session.append(self.currentDrawing())
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    @objc open func undo() {
        if backgroundImageView.subviews.count > 1 {
            for subview in backgroundImageView.subviews {
                subview.removeFromSuperview()
            }
        }
        self.session.undo()
        self.updateByLastSession()
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    @objc open func redo() {
        self.session.redo()
        self.updateByLastSession()
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    @objc open func clear() {
        self.session.clear()
        self.updateByLastSession()
        self.saved = true
        self.didUpdateCanvas()
    }
    
    @objc open func save() {
        self.drawing.stroke = self.mainImageView.image?.copy() as? UIImage
        self.drawing.background = self.backgroundImageView.image
        self.saved = true
        self.didSaveCanvas()
    }
    
    @objc open func canUndo() -> Bool {
        return self.session.canUndo()
    }
    
    @objc open func canRedo() -> Bool {
        return self.session.canRedo()
    }
    
    @objc open func canClear() -> Bool {
        return self.session.canReset()
    }
    
    @objc open func canSave() -> Bool {
        return !(self.isStrokeEqual() && self.isBackgroundEqual())
    }
}

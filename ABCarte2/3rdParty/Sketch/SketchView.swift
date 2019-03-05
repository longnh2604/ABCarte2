//
//  SketchToolType.swift
//  Sketch
//
//  Created by daihase on 04/06/2018.
//  Copyright (c) 2018 daihase. All rights reserved.
//

import UIKit

public enum SketchToolType {
    case pen
    case eraser
    case stamp
    case line
    case arrow
    case rectangleStroke
    case rectangleFill
    case ellipseStroke
    case ellipseFill
    case star
    case fill
    case pixel
    case rectanglePixel
    case eyedrop
}

public enum ImageRenderingMode {
    case scale
    case original
}

@objc public protocol SketchViewDelegate: NSObjectProtocol  {
    @objc optional func drawView(_ view: SketchView, willBeginDrawUsingTool tool: AnyObject)
    @objc optional func drawView(_ view: SketchView,undo: NSMutableArray, didEndDrawUsingTool tool: AnyObject)
    @objc optional func updateNewColor(color:UIColor)
}

public class SketchView: UIView {
    public var lineColor = UIColor.black
    public var lineWidth = CGFloat(10)
    public var lineAlpha = CGFloat(1)
    public var stampImage: UIImage?
    public var drawTool: SketchToolType = .pen
    public var drawingPenType: PenType = .normal
    public var sketchViewDelegate: SketchViewDelegate?
    private var currentTool: SketchTool?
    private let pathArray: NSMutableArray = NSMutableArray()
    private let bufferArray: NSMutableArray = NSMutableArray()
    private var currentPoint: CGPoint?
    private var previousPoint1: CGPoint?
    private var previousPoint2: CGPoint?
    public var image: UIImage?
    private var backgroundImage: UIImage?
    private var drawMode: ImageRenderingMode = .original
    
    private var imageBG: UIImage? {
        didSet {
            if backgroundImageView == nil {
                backgroundImageView = UIImageView(image: imageBG)
                self.superview?.insertSubview(backgroundImageView, belowSubview: self)
            }
            switch drawMode {
            case .original:
                var frame = self.frame
                frame.size = image!.size
                backgroundImageView.frame = frame
                break
            case .scale:
                backgroundImageView.frame = self.frame
                break
            }
        }
    }
    private var backgroundImageView: UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareForInitial()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        prepareForInitial()
    }

    private func prepareForInitial() {
        backgroundColor = UIColor.clear
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        switch drawMode {
        case .original:
            image?.draw(at: CGPoint.zero)
            break
        case .scale:
            image?.draw(in: self.bounds)
            break
        }
        
        currentTool?.draw()
    }

    private func updateCacheImage(_ isUpdate: Bool) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)

        if isUpdate {
            image = nil
            switch drawMode {
            case .original:
                if let backgroundImage = backgroundImage  {
                    (backgroundImage.copy() as! UIImage).draw(at: CGPoint.zero)
                }
                break
            case .scale:
                (backgroundImage?.copy() as! UIImage).draw(in: self.bounds)
                break
            }

            for obj in pathArray {
                if let tool = obj as? SketchTool {
                    tool.draw()
                }
            }
        } else {
            image?.draw(at: .zero)
            currentTool?.draw()
        }

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func updateEraser() {
        guard (currentTool as? EraserTool) != nil else {
            return
        }
        updateBackground()
    }
    
    private func updateBackground() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        if let imageBackground = self.imageBG {
            switch drawMode {
            case .original:
                (imageBackground.copy() as! UIImage).draw(at: CGPoint.zero)
                break
            case .scale:
                (imageBackground.copy() as! UIImage).draw(in: self.bounds)
                break
            }
        }
        image?.draw(at: .zero)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    private func toolWithCurrentSettings() -> SketchTool? {
        switch drawTool {
        case .pen:
            return PenTool()
        case .eraser:
            return EraserTool()
        case .stamp:
            return StampTool()
        case .line:
            return LineTool()
        case .arrow:
            return ArrowTool()
        case .rectangleStroke:
            let rectTool = RectTool()
            rectTool.isFill = false
            return rectTool
        case .rectangleFill:
            let rectTool = RectTool()
            rectTool.isFill = true
            return rectTool
        case .ellipseStroke:
            let ellipseTool = EllipseTool()
            ellipseTool.isFill = false
            return ellipseTool
        case .ellipseFill:
            let ellipseTool = EllipseTool()
            ellipseTool.isFill = true
            return ellipseTool
        case .star:
            return StarTool()
        case .fill:
            return FillTool()
        case .pixel:
            return PixelTool()
        case .rectanglePixel:
            return PixelRectTool()
        case .eyedrop:
            return EyeDropTool()
        }
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

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
      
        previousPoint1 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        currentTool = toolWithCurrentSettings()
        currentTool?.lineWidth = lineWidth
        currentTool?.lineColor = lineColor
        currentTool?.lineAlpha = lineAlpha
        
        #if DEBUG
        print("touches no = \(touches.count) event = \(event?.allTouches?.count)")
        #endif
        
        if (event?.allTouches?.count)! < 2 {
            switch currentTool! {
            case is PenTool:
                guard let penTool = currentTool as? PenTool else { return }
                pathArray.add(penTool)
                penTool.drawingPenType = drawingPenType
                penTool.setInitialPoint(currentPoint!)
            case is StampTool:
                guard let stampTool = currentTool as? StampTool else { return }
                pathArray.add(stampTool)
                stampTool.setStampImage(image: stampImage)
                stampTool.setInitialPoint(currentPoint!)
            case is EyeDropTool:
                let pixelColor = getPixelColorAtPoint(point: touch.location(in: self), sourceView: self)
                lineColor = pixelColor
                sketchViewDelegate?.updateNewColor!(color: pixelColor)
            default:
                guard let currentTool = currentTool else { return }
                pathArray.add(currentTool)
                currentTool.setInitialPoint(currentPoint!)
            }
        }
        
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        previousPoint2 = previousPoint1
        previousPoint1 = touch.previousLocation(in: self)
        currentPoint = touch.location(in: self)
        
        if let penTool = currentTool as? PenTool {
            if (event?.allTouches?.count)! < 2 {
                let renderingBox = penTool.createBezierRenderingBox(previousPoint2!, widhPreviousPoint: previousPoint1!, withCurrentPoint: currentPoint!)
                setNeedsDisplay(renderingBox)
            }
        } else {
            currentTool?.moveFromPoint(previousPoint1!, toPoint: currentPoint!)
            setNeedsDisplay()
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        guard let touch = touches.first else { return }
        
        if (event?.allTouches?.count)! < 2 {
            if let pixelRectTool = currentTool as? PixelRectTool {
                guard let touch = touches.first else { return }
                previousPoint1 = touch.previousLocation(in: self)
                currentPoint = touch.location(in: self)
                pixelRectTool.endFromPoint(previousPoint1!, toPoint: currentPoint!)
                setNeedsDisplay()
            } else {
                touchesMoved(touches, with: event)
            }
            finishDrawing()
        }
    }

    fileprivate func finishDrawing() {
        updateCacheImage(false)
        bufferArray.removeAllObjects()
        updateEraser()
        sketchViewDelegate?.drawView?(self,undo:pathArray, didEndDrawUsingTool: currentTool! as AnyObject)
        currentTool = nil
    }

    private func resetTool() {
        currentTool = nil
    }

    public func clear() {
        resetTool()
        bufferArray.removeAllObjects()
        pathArray.removeAllObjects()
        updateCacheImage(true)

        setNeedsDisplay()
    }

    func pinch() {
        resetTool()
        guard let tool = pathArray.lastObject as? SketchTool else { return }
        bufferArray.add(tool)
        pathArray.removeLastObject()
        updateCacheImage(true)

        setNeedsDisplay()
    }

    public func loadImage(image: UIImage) {
        self.image = image
        self.imageBG = image.copy() as? UIImage
        
        backgroundImage =  image.copy() as? UIImage
        bufferArray.removeAllObjects()
        pathArray.removeAllObjects()
        updateCacheImage(true)

        setNeedsDisplay()
    }

    public func undo(_ block: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let _self = self else { return }
            if _self.canUndo() {
                guard let tool = _self.pathArray.lastObject as? SketchTool else { return }
                
                _self.resetTool()
                _self.bufferArray.add(tool)
                _self.pathArray.removeLastObject()
                
                DispatchQueue.main.async { [weak self] in
                    guard let _self = self else { return }
                    _self.updateCacheImage(true)
                    _self.updateBackground()
                    _self.setNeedsDisplay()
                    block()
                }
            }
        }
    }

    public func redo(_ block: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let _self = self else { return }
            if _self.canRedo() {
                guard let tool = _self.bufferArray.lastObject as? SketchTool else { return }
                _self.resetTool()
                _self.pathArray.add(tool)
                _self.bufferArray.removeLastObject()
                
                DispatchQueue.main.async { [weak self] in
                    guard let _self = self else { return }
                    _self.updateCacheImage(true)
                    _self.updateBackground()
                    _self.setNeedsDisplay()
                    block()
                }
            }
        }
    }

    public func canUndo() -> Bool {
        return pathArray.count > 0
    }

    public func canRedo() -> Bool {
        return bufferArray.count > 0
    }
}

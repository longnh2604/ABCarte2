//
//  SimulationVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/16.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
//import Vision
import AVFoundation

class SimulationVC: UIViewController, UIScrollViewDelegate {

    //Variable
    var rBrow1: CGPoint = CGPoint(x:0,y:0)
    var rBrow2: CGPoint = CGPoint(x:0,y:0)
    var lBrow1: CGPoint = CGPoint(x:0,y:0)
    var lBrow2: CGPoint = CGPoint(x:0,y:0)
    var rEye1: CGPoint = CGPoint(x:0,y:0)
    var rEye2: CGPoint = CGPoint(x:0,y:0)
    var lEye1: CGPoint = CGPoint(x:0,y:0)
    var lEye2: CGPoint = CGPoint(x:0,y:0)
    var lEar1: CGPoint = CGPoint(x:0,y:0)
    var rEar1: CGPoint = CGPoint(x:0,y:0)
    var lContour: CGPoint = CGPoint(x:0,y:0)
    var rContour: CGPoint = CGPoint(x:0,y:0)
    var image: UIImage!
    var imageURL: String? = nil
    var modeAnalyze: Int = 0
    
    //IBOutlet
    @IBOutlet weak var scrPhoto: UIScrollView!
    @IBOutlet weak var imvPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
   
    func setupUI() {
        self.navigationItem.title = "シミュレーター"

        scrPhoto.delegate = self
        scrPhoto.minimumZoomScale = 0.5
        scrPhoto.maximumZoomScale = 5.0
        scrPhoto.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imvPhoto.image = UIImage(named: "faceorigin")
//        let imageLoad = UIImage(contentsOfFile: imageURL!)
//        imvPhoto.image = imageLoad
//        image = imvPhoto.image
        
        modeAnalyze = 0
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imvPhoto.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imvPhoto
    }
    
//    func onFaceAnalyze() {
//        var orientation:Int32 = 0
//        
//        // detect image orientation, we need it to be accurate for the face detection to work
//        switch image.imageOrientation {
//        case .up:
//            orientation = 1
//        case .right:
//            orientation = 6
//        case .down:
//            orientation = 3
//        case .left:
//            orientation = 8
//        default:
//            orientation = 1
//        }
//        
//        // vision
//        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
//        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientation(rawValue: UInt32(orientation))! ,options: [:])
//        do {
//            try requestHandler.perform([faceLandmarksRequest])
//        } catch {
//            print(error)
//        }
//    }
//    
//    func handleFaceFeatures(request: VNRequest, errror: Error?) {
//        guard let observations = request.results as? [VNFaceObservation] else {
//            fatalError("unexpected result type!")
//        }
//        
//        for face in observations {
//            addFaceLandmarksToImage(face)
//        }
//    }
//    
//    func addFaceLandmarksToImage(_ face: VNFaceObservation) {
//        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
//        let context = UIGraphicsGetCurrentContext()
//        
//        // draw the image
//        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        
//        context?.translateBy(x: 0, y: image.size.height)
//        context?.scaleBy(x: 1.0, y: -1.0)
//        
//        // draw the face rect
//        let w = face.boundingBox.size.width * image.size.width
//        let h = face.boundingBox.size.height * image.size.height
//        let x = face.boundingBox.origin.x * image.size.width
//        let y = face.boundingBox.origin.y * image.size.height
//        //draw face border
////        let faceRect = CGRect(x: x, y: y, width: w, height: h)
//        
////        context?.saveGState()
////        context?.setStrokeColor(UIColor.red.cgColor)
////        context?.setLineWidth(2.0)
////        context?.addRect(faceRect)
////        context?.drawPath(using: .stroke)
////        context?.restoreGState()
//        
//        if modeAnalyze == 2 {
////            // face contour
////            context?.saveGState()
////            context?.setStrokeColor(UIColor.blue.cgColor)
////            if let landmark = face.landmarks?.faceContour {
////                for i in 0...landmark.pointCount - 1 { // last point is 0,0
////                    let point = landmark.normalizedPoints[i]
////                    if i == 0 {
////                        self.lContour = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        if i == landmark.pointCount - 1 {
////                            self.rContour = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                        }
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
////                }
////            }
////            context?.setLineWidth(8.0)
////            context?.drawPath(using: .stroke)
////            context?.saveGState()
//            
////            // outer lips
////            context?.saveGState()
////            context?.setStrokeColor(UIColor.yellow.cgColor)
////            if let landmark = face.landmarks?.outerLips {
////                for i in 0...landmark.pointCount - 1 { // last point is 0,0
////                    let point = landmark.normalizedPoints[i]
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
////                }
////            }
////            context?.closePath()
////            context?.setLineWidth(8.0)
////            context?.drawPath(using: .stroke)
////            context?.saveGState()
////
////            // inner lips
////            context?.saveGState()
////            context?.setStrokeColor(UIColor.yellow.cgColor)
////            if let landmark = face.landmarks?.innerLips {
////                for i in 0...landmark.pointCount - 1 { // last point is 0,0
////                    let point = landmark.normalizedPoints[i]
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
////                }
////            }
////            context?.closePath()
////            context?.setLineWidth(8.0)
////            context?.drawPath(using: .stroke)
////            context?.saveGState()
//            
//            // left eyebrow
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.leftEyebrow {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let cgPoint = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
//                    if i == 0 {
//                        self.lBrow1 = cgPoint
//                    }
//                    if i == landmark.pointCount - 1 {
//                        self.lBrow2 = cgPoint
//                    }
//                    //                    if i == 0 {
//                    //                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
//                    //                    } else {
//                    //                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
//                    //                    }
//                }
//            }
//            
//            context?.setLineWidth(1.0)
//            context?.drawPath(using: .fillStroke)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.saveGState()
//            
//            // right eyebrow
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.rightEyebrow {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let cgPoint = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
//                    if i == 0 {
//                        self.rBrow1 = cgPoint
//                    }
//                    if i == landmark.pointCount - 1 {
//                        self.rBrow2 = cgPoint
//                    }
//                    //                    if i == 0 {
//                    //                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
//                    //                    } else {
//                    //                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
//                    //                    }
//                }
//            }
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // left eye
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.leftEye {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let cgPoint = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
//                    if i == 0 {
//                        self.lEye1 = cgPoint
//                    }
//                    if i == 4 {
//                        self.lEye2 = cgPoint
//                    }
////                    if i == 0 {
////                        self.lEye1 = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        if i == 4 {
////                            self.lEye2 = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                        }
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
////            context?.closePath()
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // right eye
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.rightEye {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let cgPoint = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
//                    if i == 0 {
//                        self.rEye1 = cgPoint
//                    }
//                    if i == 4 {
//                        self.rEye2 = cgPoint
//                    }
////                    if i == 0 {
////                        self.rEye1 = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        if i == 4 {
////                            self.rEye2 = CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                        }
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
////            context?.closePath()
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // left pupil
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.leftPupil {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
////            context?.closePath()
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // right pupil
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.rightPupil {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
////            context?.closePath()
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // nose
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.nose {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
////            context?.closePath()
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // nose crest
////            context?.saveGState()
////            context?.setStrokeColor(UIColor.gray.cgColor)
////            if let landmark = face.landmarks?.noseCrest {
////                for i in 0...landmark.pointCount - 1 { // last point is 0,0
////                    let point = landmark.normalizedPoints[i]
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
////                }
////            }
////            context?.setLineWidth(8.0)
////            context?.drawPath(using: .stroke)
////            context?.saveGState()
//            
////            // median line
////            context?.saveGState()
////            context?.setStrokeColor(UIColor.black.cgColor)
////            if let landmark = face.landmarks?.medianLine {
////                for i in 0...landmark.pointCount - 1 { // last point is 0,0
////                    let point = landmark.normalizedPoints[i]
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
////                }
////            }
////            context?.setLineWidth(8.0)
////            context?.drawPath(using: .stroke)
////            context?.saveGState()
//            
//            //left side
//            
//            //brow->eye
////            context?.saveGState()
//            context?.setStrokeColor(UIColor.green.cgColor)
//            context?.setLineWidth(3)
//            context?.beginPath()
//            context?.move(to: lBrow2)
//            context?.addLine(to: lEye2)
//            context?.strokePath()
//            context?.saveGState()
//            
////            context?.saveGState()
//            context?.setStrokeColor(UIColor.green.cgColor)
//            context?.setLineWidth(3)
//            context?.beginPath()
//            context?.move(to: lBrow1)
//            context?.addLine(to: lEye1)
//            context?.strokePath()
//            context?.saveGState()
//            
//            //right side
//            
//            //brow->eye
//            //            context?.saveGState()
//            context?.setStrokeColor(UIColor.green.cgColor)
//            context?.setLineWidth(2)
//            context?.beginPath()
//            context?.move(to: rBrow2)
//            context?.addLine(to: rEye2)
//            context?.strokePath()
//            context?.saveGState()
//            
//            //            context?.saveGState()
//            context?.setStrokeColor(UIColor.green.cgColor)
//            context?.setLineWidth(3)
//            context?.beginPath()
//            context?.move(to: rBrow1)
//            context?.addLine(to: rEye1)
//            context?.strokePath()
//            context?.saveGState()
//            
//            // get the final image
//            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
//            
//            // end drawing context
//            UIGraphicsEndImageContext()
//            
//            imvPhoto.image = finalImage
//            
////            let rEyeDistance : CGFloat = distance(rEye1, rEye2)
////            let lEyeDistance : CGFloat = distance(lEye1, lEye2)
////            let rEye2lEyeDistance: CGFloat = distance(rEye1, lEye2)
////            let rContour2EyeDistance: CGFloat = distance(rContour, rEye2)
////            let lContour2EyeDistance: CGFloat = distance(lContour, lEye1)
////            let contourDistance: CGFloat = distance(rContour, lContour)
////            let idealDistance: CGFloat = contourDistance/5
////
////            print("print Right eye distance = \(rEyeDistance)")
////            print("print Left eye distance = \(lEyeDistance)")
////            print("print Eyes distance = \(rEye2lEyeDistance)")
////            print("print Left contour to eye distance = \(lContour2EyeDistance)")
////            print("print right contour to eye distance = \(rContour2EyeDistance)")
////            print("print total contour left to right = \(contourDistance)")
////            print("ideal distance = \(idealDistance)")
////
////            print("in ideal = \(calculateIdeal(rEyeDistance,idealDistance))")
////            let finalIdeal = calculateIdeal(rEyeDistance, idealDistance) + calculateIdeal(lEyeDistance, idealDistance) + calculateIdeal(rEye2lEyeDistance, idealDistance) + calculateIdeal(lContour2EyeDistance, idealDistance) + calculateIdeal(rContour2EyeDistance, idealDistance)
////            let percent = finalIdeal/5 * 100
////            print("total ideal = \(finalIdeal) with percent = \(percent)")
//        }
//        
//        if modeAnalyze == 1 {
//            // left eyebrow
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.leftEyebrow {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h)
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
//
//            context?.setLineWidth(1.0)
//            context?.drawPath(using: .fillStroke)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.saveGState()
//            
//            // right eyebrow
//            context?.saveGState()
//            context?.setStrokeColor(UIColor.yellow.cgColor)
//            if let landmark = face.landmarks?.rightEyebrow {
//                for i in 0...landmark.pointCount - 1 { // last point is 0,0
//                    let point = landmark.normalizedPoints[i]
//                    let rectangle = CGRect(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h, width: 1, height: 1)
//                    context?.addEllipse(in: rectangle)
////                    if i == 0 {
////                        context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    } else {
////                        context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
////                    }
//                }
//            }
//            context?.setLineWidth(1.0)
//            context?.setFillColor(UIColor.yellow.cgColor)
//            context?.drawPath(using: .fillStroke)
//            context?.saveGState()
//            
//            // get the final image
//            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
//            
//            // end drawing context
//            UIGraphicsEndImageContext()
//            
//            imvPhoto.image = finalImage
//        }
//        
//    }
//    
//    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
//        let xDist = a.x - b.x
//        let yDist = a.y - b.y
//        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
//    }
//    
//    func calculateIdeal(_ a:CGFloat,_ b: CGFloat)-> CGFloat {
//        let dist = a / b
//        return dist
//    }
    
    func getMode() {
        if modeAnalyze < 2 {
            modeAnalyze += 1
        } else {
            modeAnalyze = 0
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onModeChange(_ sender: UIButton) {
        getMode()
        switch modeAnalyze {
        case 0:
            print("default")
//            imvPhoto.image = UIImage(contentsOfFile: imageURL!)
//            image = imvPhoto.image
            imvPhoto.image = UIImage(named: "faceorigin")
        case 1:
            print("face point")
//            onFaceAnalyze()
            imvPhoto.image = UIImage(named: "faceline")
        case 2:
            print("face draw")
//            onFaceAnalyze()
            imvPhoto.image = UIImage(named: "facepoint")
        default:
            break
        }
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "SimulationEditVC") as? SimulationEditVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
}

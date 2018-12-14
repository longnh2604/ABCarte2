//
//  ShootingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/06/27.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion
import RealmSwift
import SwiftyCam

class ShootingVC: SwiftyCamViewController,SwiftyCamViewControllerDelegate {

    //variable
    var cameraState: Bool = false
    let manager = CMMotionManager()
    var degree:Int?
    var cusIndex : Int?
    var customers: Results<CustomerData>!
    var cartes: Results<CarteData>!
    var medias: Results<MediaData>!
    
    //IBOutlet
    @IBOutlet weak var lblRotationD: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var btnCapture: RecordButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = RealmServices.shared.realm
        customers = realm.objects(CustomerData.self)
        cartes = realm.objects(CarteData.self)
        medias = realm.objects(MediaData.self)
        
        setupUI()
        calculateAngle()
    }
    
    func calculateAngle() {
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = 0.1
            
            manager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {(accelData: CMAccelerometerData?, error: Error?) in
                let x = accelData?.acceleration.x
                let y = accelData?.acceleration.y
                
                let deg = fabs((atan2(y!, x!) * 180 / Double.pi) + 90)
                self.degree = Int(deg)
                if (self.degree! <= 270 && self.degree! > 180) {
                    self.degree = self.degree! - ((self.degree! - 180) * 2)
                }
                self.lblRotationD.text = " \(self.degree!)°"
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI() {
        self.navigationController?.isNavigationBarHidden = true
        
        imvCus.image = UIImage(contentsOfFile: customers[cusIndex!].cusPicURL)
        lblCusName.text = customers[cusIndex!].cusFName + " " + customers[cusIndex!].cusLName
        let dayCome = convertUnixTimestamp(time: customers[cusIndex!].cusLstCome)
        lblDayCome.text = dayCome + getDayOfWeek(dayCome)!
        
        cameraDelegate = self
        maximumVideoDuration = 12.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if let connection =  self.cameraPreviewLayer?.connection  {
//
//            let currentDevice: UIDevice = UIDevice.current
//
//            let orientation: UIDeviceOrientation = currentDevice.orientation
//
//            let previewLayerConnection : AVCaptureConnection = connection
//
//            if previewLayerConnection.isVideoOrientationSupported {
//
//                switch (orientation) {
//                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
//
//                    break
//
//                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
//
//                    break
//
//                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
//
//                    break
//
//                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
//
//                    break
//
//                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
//
//                    break
//                }
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        btnCapture.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    //*****************************************************************
    // MARK: - Camera Delegate
    //*****************************************************************
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = PhotoVC(image: photo)
        self.present(newVC, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        btnCapture.growButton()
        UIView.animate(withDuration: 0.25, animations: {
//            self.flashButton.alpha = 0.0
//            self.flipCameraButton.alpha = 0.0
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        btnCapture.shrinkButton()
        UIView.animate(withDuration: 0.25, animations: {
//            self.flashButton.alpha = 1.0
//            self.flipCameraButton.alpha = 1.0
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        let newVC = VideoVC(videoURL: url)
        self.present(newVC, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }
    
    //*****************************************************************
    // MARK: - Action
    //*****************************************************************
    
    @IBAction func onCameraChange(_ sender: UIButton) {

    }
    
    @IBAction func onShoot(_ sender: UIButton) {
        
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
}

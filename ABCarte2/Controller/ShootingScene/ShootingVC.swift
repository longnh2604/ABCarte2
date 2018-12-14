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
import Photos
import SDWebImage
import JGProgressHUD

class ShootingVC: UIViewController {
    
    //Variable
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var cameraState: Bool = false
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    let manager = CMMotionManager()
    var degree:Int?
    var customer = CustomerData()
    var carte = CarteData()
    var media = MediaData()
    var timerSet: Int?
    var gridSet: Int?
    var gridToSave: Bool?
    var tranmissionToSave: Bool?
    var alphaSave: CGFloat?
    var imageConverted: Data?
    var imageResolution: Int?
    var onTemp: Bool = false
    
    var tranmissionView = UIImageView.init()
    var silhouetteView = UIImageView.init()
    var gridOn: Bool = false
    var previousScale: CGFloat = 1
    var initialOrientation = true
    var isInPortrait = false
    var orientationDidChange = false
    var timer = Timer()
    
    //IBOutlet
    @IBOutlet weak var lblRotationD: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var btnFlash: RoundButton!
    @IBOutlet weak var sliderEVView: UIView!
    @IBOutlet weak var lblDEV: UILabel!
    @IBOutlet weak var lblBEV: UILabel!
    @IBOutlet weak var sliderEV: UISlider!
    @IBOutlet weak var sliderTranmissionView: UIView!
    @IBOutlet weak var sliderTranmission: UISlider!
    @IBOutlet weak var lblTranmission: UILabel!
    @IBOutlet weak var btnCameraRotation: RoundButton!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var btnSilhouette: RoundButton!
    @IBOutlet weak var btnSetting: RoundButton!
    @IBOutlet weak var viewCountDown: SRCountdownTimer!
    @IBOutlet weak var btnBack: RoundButton!
    
    let cameraController = CameraController()

    override func viewDidLoad() {
        super.viewDidLoad()

        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{

                } else {}
            })
        }

        loadData()

        setupUI()
    }

    func loadData() {
        //get setting camera
        tranmissionToSave = UserDefaults.standard.bool(forKey: "tranmissionIsOn")
        gridToSave = UserDefaults.standard.bool(forKey: "gridIsOn")
        gridSet = UserDefaults.standard.integer(forKey: "gridNo")
        timerSet = UserDefaults.standard.integer(forKey: "timerNo")
        imageResolution = UserDefaults.standard.integer(forKey: "imageResolution")
        
        if gridSet != 0 {
            addGridLine(noLine: gridSet!)
        }
    }

    func setupUI() {
        self.navigationController?.isNavigationBarHidden = true

        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: nil)
        } else {
            imvCus.image = UIImage(named: "nophotoIcon")
        }
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true

        lblCusName.text = customer.last_name + " " + customer.first_name
        
        let dayCome = convertUnixTimestamp(time: carte.select_date)
        lblDayCome.text = dayCome + getDayOfWeek(dayCome)!

        calculateAngle()

        styleCaptureButton()
        configureCameraController()

        setupSliderEV()
        checkTranmissionImage()

        viewCountDown.delegate = self
    }

    func showCountDown(timer:Int) {
        viewCountDown.isHidden = false
        viewCountDown.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 100.0)
        viewCountDown.labelTextColor = UIColor.white
        viewCountDown.timerFinishingText = "End"
        viewCountDown.lineWidth = 20
        viewCountDown.start(beginingValue: timer, interval: 1)
        viewCountDown.backgroundColor = UIColor.clear
    }

    func addGridLine(noLine:Int) {
        removeGridLine()

        let grid = GridView.init(frame: (CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)))
        grid.numberOfRows = noLine
        grid.numberOfColumns = noLine
        grid.draw(CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        grid.backgroundColor = UIColor.clear
        gridView.addSubview(grid)
        gridView.isHidden = false
    }

    func removeGridLine() {
        if gridView.subviews.count > 0 {
            for subview in gridView.subviews {
                subview.removeFromSuperview()
            }
        }
    }

    func checkTranmissionImage() {
        if media.media_id == "" {
            print("null")
            sliderTranmissionView.isHidden = true
            self.cameraView.addSubview(silhouetteView)
        } else {
            let url = URL(string: media.url)
            tranmissionView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: nil)
            tranmissionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)

            tranmissionView.contentMode = UIViewContentMode.scaleAspectFill
            tranmissionView.alpha = 0.3
            sliderTranmissionView.layer.cornerRadius = 10
            sliderTranmissionView.clipsToBounds = true
            sliderTranmission.maximumValue = 1
            sliderTranmission.minimumValue = 0
            sliderTranmission.value = 0.3
            self.cameraView.addSubview(tranmissionView)
            self.cameraView.addSubview(silhouetteView)

        }
    }

    func setupSliderEV() {
        sliderEVView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        lblDEV.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        lblBEV.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        sliderEVView.layer.cornerRadius = 25
        sliderEVView.clipsToBounds = true

        sliderEV.minimumValue = -8
        sliderEV.maximumValue = 8
        sliderEV.value = 0

        do {
            try cameraController.changeEV(value: sliderEV.value)
        } catch {
            print(error)
        }
    }

    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }

            try? self.cameraController.displayPreview(on: self.cameraView)
            
            delay(1.0, closure: {
                self.btnCapture.isEnabled = true
            })
        }
    }

    func styleCaptureButton() {
        btnCapture.layer.borderColor = UIColor.black.cgColor
        btnCapture.layer.borderWidth = 2
        btnCapture.layer.cornerRadius = min(btnCapture.frame.width, btnCapture.frame.height) / 2
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

    @objc func pinchedView(sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }

    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }

        if !cameraState {
            currentCamera = backCamera
        } else {
            currentCamera = frontCamera
        }

    }

    func stopCaptureSession () {
        self.captureSession.stopRunning()

        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }

    }

    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            if #available(iOS 11.0, *) {
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            } else {
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG])], completionHandler: nil)
            }
        } catch {
            print(error)
        }
    }

    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.cameraView.frame
        self.cameraView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {

        layer.videoOrientation = orientation

        cameraController.previewLayer?.frame = self.cameraView.bounds
        tranmissionView.frame = self.cameraView.bounds
        silhouetteView.frame = self.cameraView.bounds

        if gridSet != 0 {
            addGridLine(noLine: gridSet!)
        }

    }

    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if initialOrientation {
            initialOrientation = false
            if view.frame.width > view.frame.height {
                isInPortrait = false
            } else {
                isInPortrait = true
            }
            orientationWillChange()
        } else {
            if view.orientationHasChanged(&isInPortrait) {
                orientationWillChange()
            }
        }
    }
    func orientationWillChange() {
        // capture the old frame values here, storing in class variables
        orientationDidChange = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if orientationDidChange {
            print("did change")
            updateLayerView()
            // change frame for mask and reposition
            orientationDidChange = false
        } else {
            
        }
    }

    func updateLayerView() {
        if let connection = self.cameraController.previewLayer?.connection {

            let currentDevice: UIDevice = UIDevice.current

            let orientation: UIDeviceOrientation = currentDevice.orientation

            let previewLayerConnection : AVCaptureConnection = connection

            if previewLayerConnection.isVideoOrientationSupported {

                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)

                    break

                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)

                    break

                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)

                    break

                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)

                    break

                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)

                    break
                }
            }
        }
    }

    func startRunningCaptureSession() {
        captureSession.startRunning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        UIApplication.shared.isStatusBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Don't forget to reset when view is being removed
        UIApplication.shared.isStatusBarHidden = false
    }

    @objc func onCaptureTimer() {
        takePhotoAction()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }

    func mergeTwoUIImage(topImage:UIImage,bottomImage:UIImage,alpha:CGFloat)->UIImage {
        let botImg = bottomImage
        let topImg = topImage

        let size = CGSize(width: 768, height: 1024)
        UIGraphicsBeginImageContext(size)

        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        botImg.draw(in: areaSize)

        topImg.draw(in: areaSize, blendMode: .normal, alpha: alpha)

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    @objc func takePhotoAction() {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            guard let img = self.imageResolution else {
                return
            }
            
            var newImage = UIImage.init()
            switch img {
            case 0:
                newImage = imageWithImage(sourceImage: image, scaledToWidth:768)
            case 1:
                newImage = imageWithImage(sourceImage: image, scaledToWidth:1152)
            case 2:
                newImage = imageWithImage(sourceImage: image, scaledToWidth:1536)
            default:
                break
            }
            
            let hud = JGProgressHUD(style: .dark)
            hud.vibrancyEnabled = true
            hud.textLabel.text = "LOADING"
            hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
            hud.show(in: self.view)
            
            //for rotation problem
            let imgRotated = newImage.updateImageOrientionUpSide()
            var imageNew = UIImage()
            
            //check tranmission first
            if self.tranmissionToSave! {
                if self.tranmissionView.image != nil {
                    imageNew = self.mergeTwoUIImage(topImage: self.tranmissionView.image!, bottomImage: imgRotated!, alpha: self.tranmissionView.alpha)
                } else {
                    imageNew = imgRotated!
                }
            } else {
                imageNew = imgRotated!
            }
            
            //check gridline later
            let imageConvert = UIImage.init(view: self.gridView)
            if self.gridSet! > 0 {
                if self.gridToSave! {
                    if self.tranmissionToSave! {
                        imageNew = self.mergeTwoUIImage(topImage: imageConvert, bottomImage: imageNew,alpha: 1)
                    } else {
                        imageNew = self.mergeTwoUIImage(topImage: imageConvert, bottomImage: imgRotated!,alpha: 1)
                    }
                }
            }
            
            //Convert to JPEG
            self.imageConverted = UIImageJPEGRepresentation(imageNew, 100)
            
            addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageConverted!, completion: { (success) in
                if success {
                    print("Add media success")
                    self.loadData()
                    hud.dismiss()
                } else {
                    hud.dismiss()
                    print("Add media failed")
                    showAlert(message: kALERT_CANT_SAVE_PHOTO, view: self)
                }
            })
            self.onSetButtonStatus(onSet: true)
        }
    }

    func onSetButtonStatus(onSet:Bool) {
        btnFlash.isEnabled = onSet
        btnCameraRotation.isEnabled = onSet
        btnSilhouette.isEnabled = onSet
        btnSetting.isEnabled = onSet
        btnCapture.isEnabled = onSet
        btnBack.isEnabled = onSet
        sliderTranmission.isEnabled = onSet

        sliderEVView.isUserInteractionEnabled = onSet
        sliderTranmissionView.isUserInteractionEnabled = onSet
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onEVChange(_ sender: UISlider) {
        do {
            try cameraController.changeEV(value: sender.value)
        }

        catch {
            print(error)
        }

    }

    @IBAction func onFlashChange(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            btnFlash.setImage(UIImage(named: "flashIcon_off"), for: .normal)
        } else {
            cameraController.flashMode = .on
            btnFlash.setImage(UIImage(named: "flashIcon_on"), for: .normal)

        }
    }

    @IBAction func onCameraChange(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }

        catch {
            print(error)
        }
    }

    @IBAction func onShoot(_ sender: UIButton) {
        onSetButtonStatus(onSet: false)
        timer.invalidate() // just in case this button is tapped multiple times

        // start the timer
        if timerSet! > 0 {
            showCountDown(timer: timerSet!)
        } else {
            takePhotoAction()
        }
    }

    @IBAction func onTranmissionChange(_ sender: UISlider) {
        let transValue = Int(sender.value * 100)
        lblTranmission.text = "\(transValue)%"
        tranmissionView.alpha = CGFloat(sender.value)
    }

    @IBAction func onSilhouetteAdd(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"SilhouettePopupVC") as? SilhouettePopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func onSetting(_ sender: UIButton) {
        let newPopup = CameraSettingPopupVC(nibName: "CameraSettingPopupVC", bundle: nil)
        newPopup.delegate = self
        newPopup.gridNo = gridSet!
        newPopup.timerNo = timerSet!
        newPopup.onGridSave = gridToSave
        newPopup.onTranmissionSave = tranmissionToSave
        newPopup.imgResolution = imageResolution
        newPopup.modalPresentationStyle = UIModalPresentationStyle.popover
        newPopup.preferredContentSize = CGSize(width: 380, height: 380)

        let popController = newPopup.popoverPresentationController
        popController?.permittedArrowDirections = .any
        popController?.sourceRect = btnSetting.bounds
        popController?.sourceView = btnSetting
        self.present(newPopup, animated: true, completion: nil)
    }

    @IBAction func onBack(_ sender: UIButton) {
        // Go back to the previous ViewController
        self.navigationController?.isNavigationBarHidden = false

        GlobalVariables.sharedManager.selectedImageIds.removeAll()

        _ = navigationController?.popViewController(animated: true)
    }
}

//*****************************************************************
// MARK: - SilhouettePopup Delegate
//*****************************************************************

extension ShootingVC: SilhouettePopupVCDelegate {
    func didSelectType(type:Int) {
        silhouetteView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        silhouetteView.contentMode = UIViewContentMode.scaleAspectFill
        silhouetteView.alpha = 0.3
        silhouetteView.isHidden = false
        
        for recognizer in silhouetteView.gestureRecognizers ?? [] {
            silhouetteView.removeGestureRecognizer(recognizer)
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        self.silhouetteView.isUserInteractionEnabled = true
        self.silhouetteView.addGestureRecognizer(pinchGesture)
        
        switch type {
        case 0:
            silhouetteView.isHidden = true
            silhouetteView.image = UIImage(named: "silhouette_x.png")
            break
        case 1:
            silhouetteView.image = UIImage(named: "silhouette_0.png")
            break
        case 2:
            silhouetteView.image = UIImage(named: "silhouette_1.png")
            break
        case 3:
            silhouetteView.image = UIImage(named: "silhouette_6.png")
            break
        case 4:
            silhouetteView.image = UIImage(named: "silhouette_2.png")
            break
        case 5:
            silhouetteView.image = UIImage(named: "silhouette_3.png")
            break
        case 6:
            silhouetteView.image = UIImage(named: "silhouette_4.png")
            break
        case 7:
            silhouetteView.image = UIImage(named: "silhouette_5.png")
            break
        case 8:
            silhouetteView.image = UIImage(named: "silhouette_7.png")
            break
        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - CameraSettingPopup Delegate
//*****************************************************************

extension ShootingVC: CameraSettingPopupVCDelegate {
    func onSetCameraSetting(gridline: Int, timer: Int, gridSave: Bool, tranmissionSave: Bool, resolution: Int) {
   
        if gridline != 0 {
            addGridLine(noLine: gridline)
        } else {
            removeGridLine()
        }
        
        gridSet = gridline
        timerSet = timer
        gridToSave = gridSave
        tranmissionToSave = tranmissionSave
        imageResolution = resolution
    }
}

//*****************************************************************
// MARK: - SRCountdownTimer Delegate
//*****************************************************************

extension ShootingVC:SRCountdownTimerDelegate {
    //Timer Delegate
    func timerDidEnd() {
        takePhotoAction()
        viewCountDown.pause()
        viewCountDown.isHidden = true
    }
}

extension UIView {
    public func orientationHasChanged(_ isInPortrait:inout Bool) -> Bool {
        if self.frame.width > self.frame.height {
            if isInPortrait {
                isInPortrait = false
                return true
            }
        } else {
            if !isInPortrait {
                isInPortrait = true
                return true
            }
        }
        return false
    }
}

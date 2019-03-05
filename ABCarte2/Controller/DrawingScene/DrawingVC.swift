//
//  DrawingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import NXDrawKit
import EFColorPicker
import JLStickerTextView
import SDWebImage

class DrawingVC: UIViewController, UIPopoverControllerDelegate, UIGestureRecognizerDelegate {
    
    //Variable
    var cusIndex : Int?
    var carteIndex: Int?
    var canvasView: Canvas?
    var paletteView: Palette?
    var toolBar: ToolBar?
    var carteID: String?
    var photoID: String?
    var currentBrush : Brush = Brush()
    var imgSelected:UIImage? = nil
    var imageOriginal: UIImage? = nil
    
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    var customer = CustomerData()
    
    var carte = CarteData()
    var cartesData : [CarteData] = []
    
    var media = MediaData()

    var orientationDidChange = false
    var onText: Bool = false
    var onTemp: Bool = false
    var image = UIImageView()
    var imageConverted: Data?
    var imgSticker = UIImageView()
    var stickerTag: Int = 0
    
    //IBOutlet
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var viewPanel: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var viewPenEx: UIView!
    @IBOutlet weak var viewPenTool: UIView!
    @IBOutlet weak var viewPen: UIView!
    @IBOutlet weak var btnPen: RoundButton!
    @IBOutlet weak var btnEraser: RoundButton!
    @IBOutlet weak var btnStamp: RoundButton!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnPickColor: RoundButton!
    @IBOutlet weak var btnPalette: RoundButton!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet weak var viewCurColor: UIView!
    @IBOutlet weak var lblPenSize: RoundLabel!
    @IBOutlet weak var lblPenOpacity: RoundLabel!
    @IBOutlet weak var sliderPenSize: MySlider!
    @IBOutlet weak var sliderPenOpacity: MySlider!
    @IBOutlet weak var viewPenSize: UIView!
    @IBOutlet weak var viewPenOpacity: UIView!
    @IBOutlet weak var viewCurPenSize: RoundUIView!
    @IBOutlet weak var btnLine: RoundButton!
    @IBOutlet weak var imvSticker: JLStickerImageView!
    @IBOutlet weak var btnText: RoundButton!
    @IBOutlet weak var viewTextEx: UIView!
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var btnMosaic: RoundButton!
    
    //stamp
    @IBOutlet var panStampGes: UIPanGestureRecognizer!
    @IBOutlet var pinchStampGes: UIPinchGestureRecognizer!
    @IBOutlet var rotateStampGes: UIRotationGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
    }
   
    func setupUI() {
        //set navigation bar title
        let logo = UIImage(named: "DrawingNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton

        updateTopView()
        setupCanvas()
        setupPallet()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onOpenPenEx(sender:)))
        viewPen.addGestureRecognizer(tap)
        
        resetButtonStatus()
        
        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        viewCurColor.backgroundColor = UIColor.black
        viewCurPenSize.backgroundColor = UIColor.black
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPenSize.rawValue) {
            sliderPenSize.minimumValue = 1
            sliderPenSize.maximumValue = 50
            sliderPenSize.value = 15
        } else {
            sliderPenSize.minimumValue = 5
            sliderPenSize.maximumValue = 20
            sliderPenSize.value = 10
        }
        lblPenSize.text = "\(Int(sliderPenSize.value))pt"
        
        sliderPenOpacity.minimumValue = 0.01
        sliderPenOpacity.maximumValue = 1
        sliderPenOpacity.value = 1
        
        imvSticker.backgroundColor = UIColor.clear
        imvSticker.isUserInteractionEnabled = false
    }
    
    func updateTopView() {
 
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: nil)
        } else {
            imvCus.image = UIImage(named: "nophotoIcon")
        }
        
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true
        
        lblCusName.text = customer.last_name + " " + customer.first_name
        
        if onTemp == false {
            let dayCome = convertUnixTimestamp(time: carte.select_date)
            lblDayCome.text = dayCome + getDayOfWeek(dayCome)!
        } else {
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            let date = convertUnixTimestamp(time: timeInterval)
            lblDayCome.text = date + getDayOfWeek(date)!
        }
        
    }
    
    @objc func onOpenPenEx(sender: UITapGestureRecognizer? = nil) {
        let status = viewPenEx.isHidden
        viewPenEx.isHidden = !status
    }
    
    func setupCanvas() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let url = URL(string: media.url)
        image.sd_setImage(with: url) { (image, error, cachetype, url) in
            if (error != nil) {
                //Failure code here
                showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
            } else {
                //Success code here
                self.viewDrawing.translatesAutoresizingMaskIntoConstraints = false
                self.viewDrawing.addGestureRecognizer(self.panGesture)
                self.viewDrawing.addGestureRecognizer(self.pinchGesture)
                let canvasView = Canvas.init(canvasId: "photo", backgroundImage: image)
                canvasView.frame = CGRect(x:0,y:0, width: self.viewDrawing.frame.width, height:self.viewDrawing.frame.height)
                canvasView.delegate = self
                canvasView.clipsToBounds = true
                
                self.viewDrawing.addSubview(canvasView)
                self.canvasView = canvasView
                self.imageOriginal = self.saveImageEdit()
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func setupPallet() {
        let paletteView = Palette()
        paletteView.setup()
        paletteView.delegate = self
    }
    
    func saveImageEdit()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext((canvasView?.frame.size)!)
   
        canvasView?.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func saveImageEdit(viewMake:UIView)->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(viewMake.frame.size)
    
        viewMake.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func onSaveImage(image: UIImage) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)

        self.imageConverted = UIImageJPEGRepresentation(image, 1)
        
        if onTemp == false {
            addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageConverted!, completion: { (success) in
                if success {
                } else {
                    showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                }
                SVProgressHUD.dismiss()
            })
        } else {
            //Check current date
            var isAdded: Bool = false
            
            for i in 0 ..< cartesData.count {
                let today = Date()
                
                let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                let isSame = date.isInSameDay(date: today)
                
                if isSame {
                 
                    isAdded = true
                    
                    addMedias(cusID: self.customer.id, carteID: self.cartesData[i].id,mediaData: self.imageConverted!, completion: { (success) in
                        if success {
                        } else {
                            showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                        }
                        SVProgressHUD.dismiss()
                    })
                    return

                } else {
                  
                    isAdded = false
                }
            }
            
            if isAdded == false {
                
                let currDate = Date()
                let timeInterval = Int(currDate.timeIntervalSince1970)
                
                //Create Carte first
                addCarteWithIDReturn(cusID: customer.id, date: timeInterval) { (carteID) in
                    if carteID != 0 {
                       
                        addMedias(cusID: self.customer.id, carteID: carteID,mediaData: self.imageConverted!, completion: { (success) in
                            if success {
                            } else {
                                showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                            }
                            SVProgressHUD.dismiss()
                        })
                    } else {
                        showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                }
            }
        }
        
    }
    
    func addStickers(image: UIImage) {
        for subview in imvSticker.subviews {
            for recognizer in subview.gestureRecognizers ?? [] {
                subview.removeGestureRecognizer(recognizer)
            }
        }
        
        imgSticker  = UIImageView(frame: CGRect.init(x: 0.0, y: 0.0, width: 150, height: 150))
        imgSticker.center = view.center
        imgSticker.image = image
        imgSticker.contentMode = UIViewContentMode.scaleAspectFill
        imgSticker.isUserInteractionEnabled = true
        
        self.imvSticker.addSubview(imgSticker)
        
//        panStampGes = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
//        panStampGes.delegate = self
//        
//        pinchStampGes = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGesture(_:)))
//        pinchStampGes.delegate = self
//        
//        rotateStampGes = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotateGesture(_:)))
//        rotateStampGes.delegate = self
        
        imgSticker.addGestureRecognizer(panStampGes)
        imgSticker.addGestureRecognizer(pinchStampGes)
        imgSticker.addGestureRecognizer(rotateStampGes)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateToolBarButtonStatus(_ canvas: Canvas){
        btnUndo.isEnabled = canvas.canUndo()
        btnRedo.isEnabled = canvas.canRedo()
    }
    
    func resetButtonStatus() {
        btnPen.backgroundColor = COLOR_SET.kPENUNSELECT
        btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
        btnSave.backgroundColor = COLOR_SET.kPENUNSELECT
        btnPickColor.backgroundColor = COLOR_SET.kPENUNSELECT
        btnPalette.backgroundColor = COLOR_SET.kPENUNSELECT
        btnLine.backgroundColor = COLOR_SET.kPENUNSELECT
        btnText.backgroundColor = COLOR_SET.kPENUNSELECT
        btnStamp.backgroundColor = COLOR_SET.kPENUNSELECT
        btnMosaic.backgroundColor = COLOR_SET.kPENUNSELECT
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //*****************************************************************
    // MARK: - Gestures
    //*****************************************************************
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        if recognizer.state == UIGestureRecognizerState.ended {
            // 1
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           // 6
                options: UIViewAnimationOptions.curveEaseOut, animations: {
                    recognizer.view!.center = finalPoint
            }) { (success) in
                self.view.updateConstraints()
            }
        }
    }
    
    @IBAction func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        
        if recognizer.state == UIGestureRecognizerState.ended {
            // 1
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           // 6
                options: UIViewAnimationOptions.curveEaseOut, animations: {
                    recognizer.view!.center = finalPoint
            }) { (success) in
                self.view.updateConstraints()
            }
        }
    }
    
    @IBAction func handlePinchGesture(recognizer : UIPinchGestureRecognizer) {
        imgSticker.transform = imgSticker.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
    }
    
    @IBAction func handleRotateGesture(recognizer : UIRotationGestureRecognizer) {
        imgSticker.transform = imgSticker.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0.0
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func showPaletteView(sender:UIButton) {
        let colorSelectionController = EFColorSelectionViewController()
        let navCtrl = UINavigationController(rootViewController: colorSelectionController)
        navCtrl.navigationBar.backgroundColor = currentBrush.color
        navCtrl.navigationBar.isTranslucent = false
        navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
        navCtrl.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        navCtrl.popoverPresentationController?.sourceView = sender
        navCtrl.popoverPresentationController?.sourceRect = sender.bounds
        navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
            UILayoutFittingCompressedSize
        )
        
        colorSelectionController.delegate = self
        colorSelectionController.color = currentBrush.color
        
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItemStyle.done,
                target: self,
                action: #selector(ef_dismissViewController(sender:))
            )
            colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
        }
        self.present(navCtrl, animated: true, completion: nil)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func pixellated() {
        // 1.
        let filter = CIFilter(name: "CIPixellate")!
        print(filter.attributes)
        
        let newImage = imageWithImage(sourceImage: (self.canvasView?.asImage())!, scaledToWidth:768)
        
        let inputImage = CIImage(image: newImage)!
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        let fullPixellatedImage = filter.outputImage
        
        // 2.
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: context,
                                  options: nil)
        let faceFeatures = detector?.features(in: inputImage)
        
        // 3.
        var maskImage: CIImage!
        let scale = min(self.canvasView!.bounds.size.width / inputImage.extent.size.width,
                        self.canvasView!.bounds.size.height / inputImage.extent.size.height)
        for faceFeature in faceFeatures! {
            print(faceFeature.bounds)
            
            // 4.
            let centerX = faceFeature.bounds.origin.x + faceFeature.bounds.size.width / 2
            let centerY = faceFeature.bounds.origin.y + faceFeature.bounds.size.height / 2
            let radius = min(faceFeature.bounds.size.width, faceFeature.bounds.size.height) * scale
            let radialGradient = CIFilter(name: "CIRadialGradient",
                                          withInputParameters: [
                                            "inputRadius0" : radius,
                                            "inputRadius1" : radius + 1,
                                            "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                            "inputColor1" : CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                            kCIInputCenterKey : CIVector(x: centerX, y: centerY)
                ])!
            
            print(radialGradient.attributes)
            
            // 5.
            let radialGradientOutputImage = radialGradient.outputImage!.cropped(to: inputImage.extent)
            if maskImage == nil {
                maskImage = radialGradientOutputImage
            } else {
                print(radialGradientOutputImage)
                maskImage = CIFilter(name: "CISourceOverCompositing",
                                     withInputParameters: [
                                        kCIInputImageKey : radialGradientOutputImage,
                                        kCIInputBackgroundImageKey : maskImage
                    ])!.outputImage
            }
            print(maskImage.extent)
        }
        
        // 6.
        let blendFilter = CIFilter(name: "CIBlendWithMask")!
        blendFilter.setValue(fullPixellatedImage, forKey: kCIInputImageKey)
        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        // 7.
        let blendOutputImage = blendFilter.outputImage!
        if let blendCGImage = context.createCGImage(blendOutputImage, from: blendOutputImage.extent) {
            let uiimage = UIImageView.init(image: UIImage(cgImage: blendCGImage))
            self.canvasView!.addSubview(uiimage)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onUndo(_ sender: UIButton) {
        self.canvasView?.undo()
    }
    
    @IBAction func onRedo(_ sender: UIButton) {
        self.canvasView?.redo()
    }
    
    @IBAction func onToolSelect(_ sender: UIButton) {
        switch sender.tag {
        case 0:
           
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 1)
            btnPen.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = false
            break
        case 1:
        
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 4)
            btnEraser.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = false
            break
        case 2:
            
            guard let imv = imvSticker else {
                onSaveImage(image: saveImageEdit())
                return
            }
            let imgS = imv.asImage()
            let imgD = viewDrawing.asImage()
            
            onSaveImage(image: mergeTwoUIImage(topImage: imgS, bottomImage: imgD, width: self.view.frame.width,height: self.view.frame.height))
            break
        case 3:
      
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 3)
            btnPickColor.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = false
            break
        case 4:
        
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 5)
            showPaletteView(sender: sender)
            btnPalette.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = false
            break
        case 5:
        
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 6)
            btnLine.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = false
            break
        case 6:
           
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
                resetButtonStatus()
//                self.canvasView?.setDrawingMode(mode: 5)
                btnText.backgroundColor = COLOR_SET.kPENSELECT
                
                if onText == false {
                    setView(view: viewTextEx, hidden: false)
                    onText = true
                } else {
                    setView(view: viewTextEx, hidden: true)
                    onText = false
                }
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
         
            break
        case 7:
       
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 5)
            btnText.setImage(UIImage(named: "selectIcon"), for: .normal)
            btnText.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = true
            setView(view: viewTextEx, hidden: true)
            onText = false
            break
        case 8:
       
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 5)
            btnText.setImage(UIImage(named: "textIcon"), for: .normal)
            btnText.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = true
            imvSticker.addLabel()
            imvSticker.textColor = currentBrush.color
            imvSticker.currentlyEditingLabel.closeView!.image = UIImage(named: "cancel")
            imvSticker.currentlyEditingLabel.rotateView?.image = UIImage(named: "rotate")
            setView(view: viewTextEx, hidden: true)
            onText = false
            break
        case 9:
        
            resetButtonStatus()
//            self.canvasView?.setDrawingMode(mode: 5)
            btnStamp.backgroundColor = COLOR_SET.kPENSELECT
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"StickerPopupVC") as? StickerPopupVC {
                vc.modalTransitionStyle   = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
            imvSticker.isUserInteractionEnabled = true
        case 10:
            pixellated()
            btnMosaic.backgroundColor = COLOR_SET.kPENSELECT
            imvSticker.isUserInteractionEnabled = false
        case 11:
          
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
                let urlPath = saveImageToLocal(imageDownloaded: self.canvasView!.asImage(), name: customer.customer_no)
                
                printUrl(urlPath)
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
            
        default:
            break
        }
    }
    
    @IBAction func onPenSizeChange(_ sender: UISlider) {
       
        let value = Int(sender.value)
        lblPenSize.text = "\(value) pt"
        currentBrush.width = CGFloat(sender.value)
        
//        self.canvasView?.setBrushWidth(width: CGFloat(sender.value))
    }
    
    @IBAction func onOpacityChange(_ sender: UISlider) {
      
        let value = Int(sender.value * 100)
        lblPenOpacity.text = "\(value)%"
        currentBrush.alpha = CGFloat(sender.value)
        viewCurPenSize.alpha = CGFloat(sender.value)
    }
}

//*****************************************************************
// MARK: - EFColorSelectionViewControllerDelegate
//*****************************************************************

extension DrawingVC: EFColorSelectionViewControllerDelegate {
    func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        viewCurColor.backgroundColor = color
        viewCurPenSize.backgroundColor = color
        currentBrush.color = color
    }
    
    // MARK:- Private
    @objc func ef_dismissViewController(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            [weak self] in
            if let _ = self {
                // TODO: You can do something here when EFColorPicker close.
                print("EFColorPicker closed.")
            }
        }
    }
}

//*****************************************************************
// MARK: - Canvas Delegate
//*****************************************************************

extension DrawingVC: CanvasDelegate{
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        updateToolBarButtonStatus(canvas)
    }
    
    func updatingNewColor(color: UIColor) {
        viewCurColor.backgroundColor = color
        viewCurPenSize.backgroundColor = color
//        self.paletteView?.setNewColorPick(newColor: color)
        currentBrush.color = color
    }
}

//*****************************************************************
// MARK: - Palette Delegate
//*****************************************************************

extension DrawingVC: PaletteDelegate
{
    func didChangeBrushColor(_ color: UIColor) {
        currentBrush.color = color
        viewCurColor.backgroundColor = color
    }
    
    func didChangeBrushAlpha(_ alpha: CGFloat) {
        currentBrush.alpha = alpha
    }
    
    func didChangeBrushWidth(_ width: CGFloat) {
        currentBrush.width = width
    }
    
    // tag can be 1 ... 12
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.blue
        }
        return nil
    }
}

//*****************************************************************
// MARK: - StickerPopup Delegate
//*****************************************************************

extension DrawingVC: StickerPopupVCDelegate
{
    func didStickerSelect(imv: String) {
        
        addStickers(image: UIImage(named: imv)!)
    }
}

extension UIImageView {
    
    func setImageBySDWebImage(with url: URL) {
        
        self.sd_setImage(with: url) { [weak self] image, error, _, _ in
            // Success
            if error == nil, let image = image {
                self?.image = image
                
                // Failure
            } else {
                // error handling
                
            }
        }
        
    }
}

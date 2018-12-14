//
//  ComparisonVC.swift
//  ABCarte2
//
//  Created by Long on 2018/06/26.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import JGProgressHUD

class ComparisonVC: UIViewController {

    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var media1 = MediaData()
    var media2 = MediaData()
    
    var cusIndex : Int?
    var carteIndex: Int?
    var compareTool: Int = 0
    var picSelected: Int = 0
    var needLoad: Bool = true
    var carteID: String?
    var imageConverted: Data?
    var onTemp: Bool = false
    var indexSelect = [Int]()
    var thumbsData : [ThumbData] = []
    var cartesData : [CarteData] = []
    let hud = JGProgressHUD(style: .dark)
    
    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var btnLR: UIButton!
    @IBOutlet weak var btnUD: UIButton!
    @IBOutlet weak var btnTRA: UIButton!
    @IBOutlet weak var imv_lock_printer: UIImageView!
    //compare
    @IBOutlet weak var viewCompare: UIView!
    @IBOutlet weak var scrollLRL: UIScrollView!
    @IBOutlet weak var imvLRL: UIImageView!
    @IBOutlet weak var scrollLRR: UIScrollView!
    @IBOutlet weak var imvLRR: UIImageView!
    //updown
    @IBOutlet weak var viewUpDown: UIView!
    @IBOutlet weak var scrollUDU: UIScrollView!
    @IBOutlet weak var imvUDU: UIImageView!
    @IBOutlet weak var scrollUDD: UIScrollView!
    @IBOutlet weak var imvUDD: UIImageView!
    @IBOutlet weak var widthUD: NSLayoutConstraint!
    @IBOutlet weak var heightUD: NSLayoutConstraint!
    @IBOutlet weak var heightUDSc1: NSLayoutConstraint!
    //tranmission
    @IBOutlet weak var viewTranmission: UIView!
    @IBOutlet weak var scrollTRA1: UIScrollView!
    @IBOutlet weak var imvTRA1: UIImageView!
    @IBOutlet weak var scrollTRA2: UIScrollView!
    @IBOutlet weak var imvTRA2: UIImageView!
    @IBOutlet weak var sliderTranmission: MySlider!
    @IBOutlet weak var widthTRA: NSLayoutConstraint!
    @IBOutlet weak var heightTRA: NSLayoutConstraint!
    @IBOutlet weak var onPhoto1: RoundButton!
    @IBOutlet weak var onPhoto2: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }
    
    func setupUI() {
        //set navigation bar title
        let logo = UIImage(named: "CarteImageNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        updateTopView()
        
        setViewandButton(type: compareTool)
        
        showLoading()
        
        if onTemp == false {
            imvLRL.sd_setImage(with: URL(string: media1.url)) { (image, error, type, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                } else {
                    self.imvUDU.image = self.imvLRL.image
                    self.imvTRA1.image = self.imvLRL.image
                    
                    self.imvLRR.sd_setImage(with: URL(string: self.media2.url)) { (image, error, type, url) in
                        if (error != nil) {
                            showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            self.hud.dismiss()
                        } else {
                            self.imvUDD.image = self.imvLRR.image
                            self.imvTRA2.image = self.imvLRR.image
                            self.hud.dismiss()
                        }
                    }
                }
            }
        } else {
         
            imvLRL.sd_setImage(with: URL(string: media1.url)) { (image, error, type, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                } else {
                    self.imvUDU.image = self.imvLRL.image
                    self.imvTRA1.image = self.imvLRL.image
                    
                    self.imvLRR.sd_setImage(with: URL(string: self.media2.url)) { (image, error, type, url) in
                        if (error != nil) {
                            showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            self.hud.dismiss()
                        } else {
                            self.imvUDD.image = self.imvLRR.image
                            self.imvTRA2.image = self.imvLRR.image
                            self.hud.dismiss()
                        }
                    }
                }
            }
        }
        
        scrollLRL.delegate = self
        scrollLRL.minimumZoomScale = 0.5
        scrollLRL.maximumZoomScale = 10.0
        scrollLRL.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollLRR.delegate = self
        scrollLRR.minimumZoomScale = 0.5
        scrollLRR.maximumZoomScale = 10.0
        scrollLRR.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollLRL.zoomScale = 2.0
        scrollLRR.zoomScale = 2.0
        scrollLRL.contentInset.top = 100
        scrollLRR.contentInset.top = 100
        
        scrollUDU.delegate = self
        scrollUDU.minimumZoomScale = 0.5
        scrollUDU.maximumZoomScale = 10.0
        scrollUDU.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollUDD.delegate = self
        scrollUDD.minimumZoomScale = 0.5
        scrollUDD.maximumZoomScale = 10.0
        scrollUDD.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollTRA1.delegate = self
        scrollTRA1.minimumZoomScale = 0.5
        scrollTRA1.maximumZoomScale = 10.0
        scrollTRA1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollTRA2.delegate = self
        scrollTRA2.minimumZoomScale = 0.5
        scrollTRA2.maximumZoomScale = 10.0
        scrollTRA2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        sliderTranmission.minimumValue = 0
        sliderTranmission.maximumValue = 1
        sliderTranmission.value = 0.5
        
        imvTRA1.alpha = CGFloat(sliderTranmission.value)
        imvTRA2.alpha = CGFloat(sliderTranmission.value)
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kComparePrinter.rawValue) {
            imv_lock_printer.isHidden = true
        } else {
            imv_lock_printer.isHidden = false
        }
    }
    
    func updateTopView() {
        print(customer.thumb)
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
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
    
    func updateOrientView() {
        if UIDevice.current.orientation.isLandscape {
            // Landscape mode

            widthUD.constant = 407
            heightUD.constant = 520
            heightUDSc1.constant = 260
            
            widthTRA.constant = 376
            heightTRA.constant = 480
        } else {
            // Portrait mode
    
            widthUD.constant = 547
            heightUD.constant = 700
            heightUDSc1.constant = 350
            
            widthTRA.constant = 548
            heightTRA.constant = 700
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            
            switch orient {
                
            case .portrait:
                self.changeCompareViewLayout(false)
                print("Portrait")
                
            case .landscapeLeft,.landscapeRight :
                self.changeCompareViewLayout()
                print("Landscape")
                
            default:
                self.changeCompareViewLayout(false)
                print("Anything But Portrait")
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            //refresh view once rotation is completed not in will transition as it returns incorrect frame size.Refresh here
            self.viewWillLayoutSubviews()
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func changeCompareViewLayout(_ isLandscape: Bool = true) {
        if isLandscape {
            switch compareTool {
            case 1:
                widthUD.constant = 407
                heightUD.constant = 520
                heightUDSc1.constant = 260
                break
            case 2:
                widthTRA.constant = 376
                heightTRA.constant = 480
                break
            default:
                break
            }
            
        } else {
            switch compareTool {
            case 1:
                widthUD.constant = 547
                heightUD.constant = 700
                heightUDSc1.constant = 350
                break
            case 2:
                widthTRA.constant = 548
                heightTRA.constant = 700
                break
            default:
                break
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setViewandButton(type:Int) {
        updateOrientView()
        switch type {
        case 0:
            btnLR.setImage(UIImage(named: "compareIcon_on"), for: .normal)
            btnUD.setImage(UIImage(named: "updownIcon_off"), for: .normal)
            btnTRA.setImage(UIImage(named: "tranmissionIcon_off"), for: .normal)
            viewCompare.isHidden = false
            viewTranmission.isHidden = true
            viewUpDown.isHidden = true
            sliderTranmission.isHidden = true
            onPhoto1.isHidden = true
            onPhoto2.isHidden = true
            break
        case 1:
            btnLR.setImage(UIImage(named: "compareIcon_off"), for: .normal)
            btnUD.setImage(UIImage(named: "updownIcon_on"), for: .normal)
            btnTRA.setImage(UIImage(named: "tranmissionIcon_off"), for: .normal)
            viewCompare.isHidden = true
            viewUpDown.isHidden = false
            viewTranmission.isHidden = true
            sliderTranmission.isHidden = true
            onPhoto1.isHidden = true
            onPhoto2.isHidden = true
            break
        case 2:
            btnLR.setImage(UIImage(named: "compareIcon_off"), for: .normal)
            btnUD.setImage(UIImage(named: "updownIcon_off"), for: .normal)
            btnTRA.setImage(UIImage(named: "tranmissionIcon_on"), for: .normal)
            viewCompare.isHidden = true
            viewUpDown.isHidden = true
            viewTranmission.isHidden = false
            sliderTranmission.isHidden = false
            onPhoto1.isHidden = false
            onPhoto2.isHidden = false
            break
        default:
            break
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
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
        showLoading()
        
        self.imageConverted = UIImageJPEGRepresentation(image, 100)
        
        if onTemp == false {
            addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageConverted!, completion: { (success) in
                if success {
        
                    self.hud.dismiss()
                } else {
                    self.hud.dismiss()
            
                    showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
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
                    
                            self.hud.dismiss()
                        } else {
                            self.hud.dismiss()
                    
                            showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
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
                         
                                self.hud.dismiss()
                            } else {
                                self.hud.dismiss()
                         
                                showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                        })
                        
                    } else {
                        self.hud.dismiss()
                      
                        showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            }
        }
    }
    
    func printUrl(_ url: URL) {
        guard (UIPrintInteractionController.canPrint(url)) else {
            Swift.print("Unable to print: \(url)")
            return
        }
        
        showPrintInteraction(url)
    }
    
    func showPrintInteraction(_ url: URL) {
        let controller = UIPrintInteractionController.shared
        controller.printingItem = url
        controller.printInfo = printerInfo(url.lastPathComponent)
        controller.present(animated: true, completionHandler: nil)
    }
    
    func printerInfo(_ jobName: String) -> UIPrintInfo {
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = jobName
        Swift.print("Printing: \(jobName)")
        return printInfo
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onToolSelect(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            compareTool = 0
            setViewandButton(type: 0)
            break
        case 2:
            compareTool = 1
            setViewandButton(type: 1)
            break
        case 3:
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCompareTranmission.rawValue) {
          
                compareTool = 2
                setViewandButton(type: 2)
            } else {
                showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
          
            break
        case 4:
      
            if compareTool == 0 {
                let image = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
                image.contentMode = .scaleAspectFit
                image.image = UIImage.init(view: viewCompare)
                
                onSaveImage(image: saveImageEdit(viewMake: image))
            } else  if compareTool == 1 {
                onSaveImage(image: saveImageEdit(viewMake: viewUpDown))
            } else  if compareTool == 2 {
                onSaveImage(image: saveImageEdit(viewMake: viewTranmission))
            }
            
            break
        default:
            break
        }
    }
    
    @IBAction func onTranmissionChange(_ sender: UISlider) {
        if picSelected == 0 {
            imvTRA1.alpha = CGFloat(sender.value)
            imvTRA2.alpha = CGFloat(1.0 - sender.value)
        } else {
            imvTRA2.alpha = CGFloat(sender.value)
            imvTRA1.alpha = CGFloat(1.0 - sender.value)
        }
    }
    
    @IBAction func onPhotoSelect(_ sender: UIButton) {
        if sender.tag == 1 {
            picSelected = 1
            scrollTRA1.isUserInteractionEnabled = true
            scrollTRA2.isUserInteractionEnabled = false
        } else {
            picSelected = 2
            scrollTRA1.isUserInteractionEnabled = false
            scrollTRA2.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func onPrint(_ sender: UIButton) {
        
        var urlPath = URL(string: "")
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
            if compareTool == 0 {
                urlPath = saveImageToLocal(imageDownloaded: viewCompare.asImage(), name: customer.customer_no)
            } else  if compareTool == 1 {
                urlPath = saveImageToLocal(imageDownloaded: viewUpDown.asImage(), name: customer.customer_no)
            } else  if compareTool == 2 {
                urlPath = saveImageToLocal(imageDownloaded: viewTranmission.asImage(), name: customer.customer_no)
            }
            
            #if DEBUG
            printUrl(urlPath!)
            #endif
        } else {
            showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension ComparisonVC: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var imageViewSize = CGSize()
        switch scrollView.tag {
        case 1:
            imageViewSize = imvLRL.frame.size
            break
        case 2:
            imageViewSize = imvLRR.frame.size
            break
        case 3:
            imageViewSize = imvUDU.frame.size
            break
        case 4:
            imageViewSize = imvUDD.frame.size
            break
        case 5:
            imageViewSize = imvTRA1.frame.size
            break
        case 6:
            imageViewSize = imvTRA2.frame.size
            break
        default:
            break
        }
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        var imv = UIImageView()
        switch scrollView.tag {
        case 1:
            imv = imvLRL
            break
        case 2:
            imv = imvLRR
            break
        case 3:
            imv = imvUDU
            break
        case 4:
            imv = imvUDD
            break
        case 5:
            imv = imvTRA1
            break
        case 6:
            imv = imvTRA2
            break
        default:
            break
        }
        return imv
    }
}

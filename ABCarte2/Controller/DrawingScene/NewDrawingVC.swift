//
//  NewDrawingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/10/16.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import EFColorPicker
import JLStickerTextView

class NewDrawingVC: UIViewController {
    
    //Variable
    var accounts: Results<AccountData>!
    
    var customer = CustomerData()
    
    var carte = CarteData()
    var cartesData : [CarteData] = []
    
    var media = MediaData()
    
    var imvStamp = UIImageView()
    let imvDraw = UIImageView()
    var onTemp: Bool = false
    var imageData: Data?
    var toolSelected: Int?
    var imgSticker = UIImageView()
    var stickNo: Int = 0
    var isEdited: Bool = false
    
    let maxScale: CGFloat = 3.0
    let minScale: CGFloat = 0.6
    var cumulativeScale:CGFloat = 1.0
    
    var needLoad: Bool = true
    
    //IBOutlet
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var sketchView: SketchView?
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    //Pen Tool
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnResize: RoundButton!
    @IBOutlet weak var btnShape: RoundButton!
    @IBOutlet weak var btnEraser: RoundButton!
    @IBOutlet weak var btnText: RoundButton!
    @IBOutlet weak var btnPrinter: RoundButton!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnEyedrop: RoundButton!
    @IBOutlet weak var btnPalette: RoundButton!
    @IBOutlet weak var btnPen: RoundButton!
    @IBOutlet weak var btnStamp: RoundButton!
    @IBOutlet weak var btnMosaic: RoundButton!
    
    //Bottom View
    @IBOutlet weak var viewTool: UIView!
    @IBOutlet weak var viewPen: UIView!
    @IBOutlet weak var viewPenEx: UIView!
    @IBOutlet weak var viewCurrColor: UIView!
    @IBOutlet weak var imvSticker: JLStickerImageView!
    @IBOutlet weak var sliderPenSize: MySlider!
    @IBOutlet weak var lblPenSize: RoundLabel!
    @IBOutlet weak var sliderPenOpacity: MySlider!
    @IBOutlet weak var lblOpacity: RoundLabel!
    @IBOutlet weak var btnShowHide: RoundButton!
    @IBOutlet weak var btnPenShowHide: UIView!
    @IBOutlet weak var btnFavoriteColor: RoundButton!
    @IBOutlet weak var viewFav1: RoundButton!
    @IBOutlet weak var viewFav2: RoundButton!
    @IBOutlet weak var viewFav3: RoundButton!
    @IBOutlet weak var viewFav4: RoundButton!
    @IBOutlet weak var viewFav5: RoundButton!
    @IBOutlet weak var lblTitleOpacity: UILabel!
    
    //Font View
    @IBOutlet weak var viewFont: UIView!
    @IBOutlet weak var lblTextExample: UILabel!
    @IBOutlet weak var btnFontColor: RoundButton!
    @IBOutlet weak var btnFont: RoundButton!
    @IBOutlet weak var btnColorFont: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        
        setupCanvas()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
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
        
        //resize select from first
        btnResize.backgroundColor = COLOR_SET.kPENSELECT
        toolSelected = 11
        btnFavoriteColor.isEnabled = false
        //focus on resize
        viewPenEx.isHidden = true
        viewPen.isHidden = true
        btnPenShowHide.isHidden = true
        
        btnPenShowHide.layer.cornerRadius = 10
        btnPenShowHide.clipsToBounds = true
        
        viewFont.isHidden = true
        
        updateTopView()
        updateBottomView()
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kDrawingPrinter.rawValue) {
            btnPrinter.isHidden = false
        } else {
            btnPrinter.isHidden = true
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
            btnText.isHidden = false
        } else {
            btnText.isHidden = true
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMosaic.rawValue) {
            btnMosaic.isHidden = false
        } else {
            btnMosaic.isHidden = true
        }
    
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kEyeDrop.rawValue) {
            btnEyedrop.isHidden = false
        } else {
            btnEyedrop.isHidden = true
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kOpacity.rawValue) {
            lblTitleOpacity.isHidden = false
            lblOpacity.isHidden = false
            sliderPenOpacity.isHidden = false
        } else {
            lblTitleOpacity.isHidden = true
            lblOpacity.isHidden = true
            sliderPenOpacity.isHidden = true
        }
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
    
    func updateBottomView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onOpenPenEx(sender:)))
        btnPenShowHide.addGestureRecognizer(tap)
        
        viewCurrColor.backgroundColor = UIColor.black
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPenSize.rawValue) {
            sliderPenSize.minimumValue = 0.5
            sliderPenSize.maximumValue = 30
            sliderPenSize.value = 5
        } else {
            sliderPenSize.minimumValue = 5
            sliderPenSize.maximumValue = 20
            sliderPenSize.value = 5
        }
        lblPenSize.text = "\(Int(sliderPenSize.value))pt"
        
        sliderPenOpacity.minimumValue = 0.01
        sliderPenOpacity.maximumValue = 1
        sliderPenOpacity.value = 1
        
        viewFav1.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[0])
        viewFav2.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[1])
        viewFav3.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[2])
        viewFav4.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[3])
        viewFav5.backgroundColor = hexStringToUIColor(hex: GlobalVariables.sharedManager.accFavoriteColors[4])
        
        let realm = try! Realm()
        accounts = realm.objects(AccountData.self)
    }
    
    @objc func onOpenPenEx(sender: UITapGestureRecognizer? = nil) {
        let status = viewPenEx.isHidden
        viewPenEx.isHidden = !status
    }
    
    func setupCanvas() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        guard let url = URL(string: media.url) as URL? else { fatalError("URL not found") }
        
        imvDraw.sd_setImage(with: url, completed: {(image, err, cacheType, url) in
            
            let imageV = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            imageV.contentMode = .scaleAspectFit
            imageV.image = image
            
            let imageS = self.saveImageEditN(viewMake: imageV)
            
            self.sketchView?.frame = CGRect(x: (self.sketchView?.frame.origin.x)!, y: (self.sketchView?.frame.origin.y)!, width: self.view.frame.width, height: self.view.frame.height)
            self.sketchView?.sketchViewDelegate = self
            self.sketchView?.loadImage(image: imageS)
            self.sketchView?.lineWidth = 5.0
            
            self.viewDrawing.addGestureRecognizer(self.panGesture)
            self.viewDrawing.addGestureRecognizer(self.pinchGesture)
            
            self.checkUndoRedoStatus()
            
            SVProgressHUD.dismiss()
        })
        
        imvSticker.isUserInteractionEnabled = false
        sketchView?.isUserInteractionEnabled = false
        changeGestureStatus(status: true)
    }
    
    func changeGestureStatus(status:Bool) {
        self.panGesture.isEnabled = status
        self.pinchGesture.isEnabled = status
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        checkPhotoEditOrNot { (success) in
            if success {
                
            } else {
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func resetAllButton() {
        btnPen.backgroundColor = COLOR_SET.kPENUNSELECT
        btnShape.backgroundColor = COLOR_SET.kPENUNSELECT
        btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
        btnText.backgroundColor = COLOR_SET.kPENUNSELECT
        btnStamp.backgroundColor = COLOR_SET.kPENUNSELECT
        btnMosaic.backgroundColor = COLOR_SET.kPENUNSELECT
        btnEyedrop.backgroundColor = COLOR_SET.kPENUNSELECT
        btnPalette.backgroundColor = COLOR_SET.kPENUNSELECT
        btnResize.backgroundColor = COLOR_SET.kPENUNSELECT
        btnPrinter.backgroundColor = COLOR_SET.kPENUNSELECT
        btnSave.backgroundColor = COLOR_SET.kPENUNSELECT
    }
    
    func checkUndoRedoStatus() {
        guard let undo = sketchView?.canUndo() as Bool?,let redo = sketchView?.canRedo() as Bool? else {
            btnUndo.isEnabled = false
            btnRedo.isEnabled = false
            return
        }
        
        if undo == true {
            btnUndo.isEnabled = true
        } else {
            btnUndo.isEnabled = false
        }
        
        if redo == true {
            btnRedo.isEnabled = true
        } else {
            btnRedo.isEnabled = false
        }
    }
    
    //Select Favorite Color
    func tapFavoriteColor() {
        
        let option1 = UIAlertAction(title: "1", style: .default) { _ in
            self.viewFav1.backgroundColor = self.sketchView?.lineColor
            self.setColorToAccFavorite(index: 0)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option2 = UIAlertAction(title: "2", style: .default) { _ in
            self.viewFav2.backgroundColor = self.sketchView?.lineColor
            self.setColorToAccFavorite(index: 1)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option3 = UIAlertAction(title: "3", style: .default) { _ in
            self.viewFav3.backgroundColor = self.sketchView?.lineColor
            self.setColorToAccFavorite(index: 2)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option4 = UIAlertAction(title: "4", style: .default) { _ in
            self.viewFav4.backgroundColor = self.sketchView?.lineColor
            self.setColorToAccFavorite(index: 3)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let option5 = UIAlertAction(title: "5", style: .default) { _ in
            self.viewFav5.backgroundColor = self.sketchView?.lineColor
            self.setColorToAccFavorite(index: 4)
            let stringColors = GlobalVariables.sharedManager.accFavoriteColors.joined(separator: ",")
            
            updateAccountFavoriteColors(accountID: self.accounts[0].id, favColors: stringColors, completion: { (success) in
                if success {
                    showAlert(message: "好きな色を更新しました", view: self)
                } else {
                    showAlert(message: "好きな色を更新に失敗しました", view: self)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { _ in }
        
        let alertController = UIAlertController(title: MSG_ALERT.kALERT_SELECT_FAVORITE_COLOR, message: nil, preferredStyle: .alert)
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(option3)
        alertController.addAction(option4)
        alertController.addAction(option5)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //add Shape Function
    func tapFigureButton() {
        // Line
        let lineAction = UIAlertAction(title: "Line", style: .default) { _ in
            self.sketchView?.drawTool = .line
        }
        // Arrow
        let arrowAction = UIAlertAction(title: "Arrow", style: .default) { _ in
            self.sketchView?.drawTool = .arrow
        }
        // Rect
        let rectAction = UIAlertAction(title: "Rect", style: .default) { _ in
            self.sketchView?.drawTool = .rectangleStroke
        }
        // Rectfill
        let rectFillAction = UIAlertAction(title: "Rect(Fill)", style: .default) { _ in
            self.sketchView?.drawTool = .rectangleFill
        }
        // Ellipse
        let ellipseAction = UIAlertAction(title: "Ellipse", style: .default) { _ in
            self.sketchView?.drawTool = .ellipseStroke
        }
        // EllipseFill
        let ellipseFillAction = UIAlertAction(title: "Ellipse(Fill)", style: .default) { _ in
            self.sketchView?.drawTool = .ellipseFill
        }
        // Star
        let starAction = UIAlertAction(title: "Star platinum", style: .default) { _ in
            self.sketchView?.drawTool = .star
        }
        // Cancel
        let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in }
        
        let alertController = UIAlertController(title: MSG_ALERT.kALERT_CHOOSE_FIGURE_TO_DRAW, message: nil, preferredStyle: .alert)
        alertController.addAction(lineAction)
        alertController.addAction(arrowAction)
        alertController.addAction(rectAction)
        alertController.addAction(rectFillAction)
        alertController.addAction(ellipseAction)
        alertController.addAction(ellipseFillAction)
        alertController.addAction(starAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func changeStampMode(stampName: String) {
        sketchView?.stampImage = UIImage(named: stampName)
        sketchView?.drawTool = .stamp
    }
    
    //Save Image
    func onSaveImage(image: UIImage) {
        SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.imageData = UIImageJPEGRepresentation(image, 1)
        
        if onTemp == false {
            addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageData!, completion: { (success) in
                if success {
                    
                    showAlert(message: "画像の保存しました。", view: self)
                    
                    if self.isEdited == true {
                        self.isEdited = false
                    }
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
                    
                    addMedias(cusID: self.customer.id, carteID: self.cartesData[i].id,mediaData: self.imageData!, completion: { (success) in
                        if success {
                            
                            showAlert(message: "画像の保存しました。", view: self)
                            
                            if self.isEdited == true {
                                self.isEdited = false
                            }
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
                        
                        addMedias(cusID: self.customer.id, carteID: carteID,mediaData: self.imageData!, completion: { (success) in
                            if success {
                                
                                if self.isEdited == true {
                                    self.isEdited = false
                                }
                            } else {
                                showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                            }
                            SVProgressHUD.dismiss()
                        })
                    } else {
                        showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func saveImageEditN(viewMake:UIView)->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(viewMake.frame.size)
        viewMake.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //show palette view
    func showPaletteView(sender:UIButton) {
        let colorSelectionController = EFColorSelectionViewController()
        let navCtrl = UINavigationController(rootViewController: colorSelectionController)
        navCtrl.navigationBar.backgroundColor = sketchView?.lineColor
        navCtrl.navigationBar.isTranslucent = false
        navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
        navCtrl.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        navCtrl.popoverPresentationController?.sourceView = sender
        navCtrl.popoverPresentationController?.sourceRect = sender.bounds
        navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
            UILayoutFittingCompressedSize
        )
        
        colorSelectionController.delegate = self
        colorSelectionController.color = (sketchView?.lineColor)!
        
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
    
    func setColorToAccFavorite(index:Int) {
        GlobalVariables.sharedManager.accFavoriteColors[index] = (sketchView?.lineColor.hexString)!
    }
    
    //add Color Font
    func tapFontColor() {
        
        let black = UIAlertAction(title: "黒", style: .default) { _ in
            self.changeTextFont(color: UIColor.black)
        }
        
        let red = UIAlertAction(title: "赤", style: .default) { _ in
            self.changeTextFont(color: UIColor.red)
        }
        
        let blue = UIAlertAction(title: "青", style: .default) { _ in
            self.changeTextFont(color: UIColor.blue)
        }
        
        let yellow = UIAlertAction(title: "黄", style: .default) { _ in
            self.changeTextFont(color: UIColor.yellow)
        }
        
        let white = UIAlertAction(title: "白", style: .default) { _ in
            self.changeTextFont(color: UIColor.white)
        }
        
        let gray = UIAlertAction(title: "グレー", style: .default) { _ in
            self.changeTextFont(color: UIColor.gray)
        }
        
        let orange = UIAlertAction(title: "オレンジ", style: .default) { _ in
            self.changeTextFont(color: UIColor.orange)
        }
        
        let green = UIAlertAction(title: "緑", style: .default) { _ in
            self.changeTextFont(color: UIColor.green)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { _ in }
        
        let alertController = UIAlertController(title: "色を選択して下さい", message: nil, preferredStyle: .alert)
        alertController.addAction(black)
        alertController.addAction(red)
        alertController.addAction(blue)
        alertController.addAction(yellow)
        alertController.addAction(white)
        alertController.addAction(gray)
        alertController.addAction(orange)
        alertController.addAction(green)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func changeTextFont(color:UIColor) {
        imvSticker.textColor = color
        
        btnColorFont.backgroundColor = color
    }
    
    @objc func onAddStampConfirm(sender: UIButton!) {
        for subview in imvSticker.subviews {
            if subview.tag == sender.tag {
                //hidden dash line
                if let layer = subview.layer.sublayers?.first {
                    //            layer.removeFromSuperlayer()
                    layer.isHidden = true
                }
                
                //hidden button
                for btn in subview.subviews {
                    btn.isHidden = true
                    //            btn.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func onCancelStampAdd(sender: UIButton!) {
        for subview in imvSticker.subviews {
            if subview.tag == sender.tag {
                subview.removeFromSuperview()
            }
        }
    }
    
    func checkPhotoEditOrNot(completion:@escaping(Bool) -> ()) {
        
        if isEdited == true {
            let alert = UIAlertController(title: "画像描画", message: MSG_ALERT.kALERT_SAVE_PHOTO_NOTIFICATION, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler:{ (UIAlertAction) in
                completion(false)
            }))
            alert.addAction(UIAlertAction(title: "いいえ", style: .default, handler:{ (UIAlertAction) in
                completion(true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            completion(false)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onFontChange(_ sender: UIButton) {
        let newPopup = TextFontPopupVC(nibName: "TextFontPopupVC", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 400, height: 400)
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onSelectFavoriteColor(_ sender: UIButton) {
        tapFavoriteColor()
    }
    
    @IBAction func onSelectFavoriteBox(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            sketchView?.lineColor = viewFav1.backgroundColor!
            viewCurrColor.backgroundColor = viewFav1.backgroundColor
        case 2:
            sketchView?.lineColor = viewFav2.backgroundColor!
            viewCurrColor.backgroundColor = viewFav2.backgroundColor
        case 3:
            sketchView?.lineColor = viewFav3.backgroundColor!
            viewCurrColor.backgroundColor = viewFav3.backgroundColor
        case 4:
            sketchView?.lineColor = viewFav4.backgroundColor!
            viewCurrColor.backgroundColor = viewFav4.backgroundColor
        case 5:
            sketchView?.lineColor = viewFav5.backgroundColor!
            viewCurrColor.backgroundColor = viewFav5.backgroundColor
        default:
            break
        }
        print(GlobalVariables.sharedManager.accFavoriteColors)
    }
    
    @IBAction func onHiddenPenTool(_ sender: Any) {
        if viewTool.isHidden == true {
            viewTool.isHidden = false
        } else {
            viewTool.isHidden = true
        }
    }
    
    @IBAction func onUndoRedo(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        switch sender.tag {
        case 0:
            print("Undo")
            sketchView?.undo {
                self.checkUndoRedoStatus()
            }
        case 1:
            print("Redo")
            sketchView?.redo {
                self.checkUndoRedoStatus()
            }
        default:
            break
        }
        SVProgressHUD.dismiss()
    }
    
    @IBAction func onToolSelect(_ sender: UIButton) {
        
        resetAllButton()
        sketchView?.isUserInteractionEnabled = true
        imvSticker.isUserInteractionEnabled = false
        changeGestureStatus(status: false)
        viewFont.isHidden = true
        viewPenEx.isHidden = false
        viewPen.isHidden = false
        btnPenShowHide.isHidden = false
        onToolSelected(index: sender.tag)
    }
    
    func onToolSelected(index: Int) {
        btnFavoriteColor.isEnabled = true
        //remove border of stamp
        for subview in imvSticker.subviews {
            //check if it's sticker textview
            if subview.isKind(of: JLStickerLabelView.self) {
                //do nothing
            } else {
                //hidden dash line
                if let layer = subview.layer.sublayers?.first {
                    layer.isHidden = true
                }
                
                //hidden button
                for btn in subview.subviews {
                    btn.isHidden = true
                }
            }
        }
        
        switch index {
        case 1:
            btnPen.backgroundColor = COLOR_SET.kPENSELECT
            
            sketchView?.drawTool = .pen
        case 2:
            btnShape.backgroundColor = COLOR_SET.kPENSELECT
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"ShapePopupVC") as? ShapePopupVC {
                vc.modalTransitionStyle   = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
            
        case 3:
            btnEraser.backgroundColor = COLOR_SET.kPENSELECT
            sketchView?.drawTool = .eraser
        case 4:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kTextSticker.rawValue) {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
                return
            }
            
            btnText.backgroundColor = COLOR_SET.kPENSELECT
            sketchView?.isUserInteractionEnabled = false
            imvSticker.isUserInteractionEnabled = true
            btnColorFont.backgroundColor = UIColor.black
            imvSticker.addLabel()
            
            if isEdited == false {
                isEdited = true
            }
            
            imvSticker.currentlyEditingLabel.closeView!.image = UIImage(named: "cancel")
            imvSticker.currentlyEditingLabel.rotateView?.image = UIImage(named: "rotate")
            viewFont.isHidden = true
        case 5:
            btnStamp.backgroundColor = COLOR_SET.kPENSELECT
            sketchView?.isUserInteractionEnabled = false
            imvSticker.isUserInteractionEnabled = true
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"StickerPopupVC") as? StickerPopupVC {
                vc.modalTransitionStyle   = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        case 6:
            if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMosaic.rawValue) {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
                return
            }
            btnMosaic.backgroundColor = COLOR_SET.kPENSELECT
            sketchView?.drawTool = .rectanglePixel
        case 7:
            btnEyedrop.backgroundColor = COLOR_SET.kPENSELECT
            sketchView?.drawTool = .eyedrop
        case 8:
            btnPalette.backgroundColor = COLOR_SET.kPENSELECT
            showPaletteView(sender: btnPalette)
            sketchView?.isUserInteractionEnabled = false
        case 9:
            btnPrinter.backgroundColor = COLOR_SET.kPENSELECT
            
            let urlPath: URL
            if imvSticker.subviews.count > 0 {
                let imgS = imvSticker.asImage()
                let imgD = sketchView?.image!
                
                urlPath = saveImageToLocal(imageDownloaded: mergeTwoUIImage(topImage: imgS, bottomImage: imgD!,width: self.view.frame.width, height: self.view.frame.height ), name: customer.customer_no)
                
                printUrl(urlPath)
            } else {
                urlPath = saveImageToLocal(imageDownloaded: (sketchView?.image)!, name: customer.customer_no)
                printUrl(urlPath)
            }
            sketchView?.isUserInteractionEnabled = false
        case 10:
            btnSave.backgroundColor = COLOR_SET.kPENSELECT
            
            if imvSticker.subviews.count > 0 {
                let imgS = imvSticker.asImage()
                let imgD = sketchView?.image
                
                onSaveImage(image: mergeTwoUIImage(topImage: imgS, bottomImage: imgD!,width: self.view.frame.width,height: self.view.frame.height))
                sketchView?.isUserInteractionEnabled = false
            } else {
                onSaveImage(image: (sketchView?.image)!)
            }
        case 11:
            btnResize.backgroundColor = COLOR_SET.kPENSELECT
            sketchView?.isUserInteractionEnabled = false
            changeGestureStatus(status: true)
            //focus on resize
            viewPenEx.isHidden = true
            viewPen.isHidden = true
            btnPenShowHide.isHidden = true
            btnFavoriteColor.isEnabled = false
        default:
            break
        }
        
        toolSelected = index
    }
    
    @IBAction func onPenSizeChange(_ sender: UISlider) {
        let size = String(format:"%.1f", sender.value)
        
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            _self.lblPenSize.text = "\(size) pt"
        }
        
        sketchView?.lineWidth = CGFloat(sender.value)
    }
    
    @IBAction func onOpacityChange(_ sender: UISlider) {
        let value = Int(sender.value * 100)
        lblOpacity.text = "\(value)%"
        sketchView?.lineAlpha = CGFloat(sender.value)
    }
    
    @IBAction func onFontColorChange(_ sender: UIButton) {
        tapFontColor()
    }
    
    //*****************************************************************
    // MARK: - Gestures
    //*****************************************************************
    
    @IBAction func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func handlePinchGesture(recognizer : UIPinchGestureRecognizer) {
        
        guard pinchGesture.view != nil else {return}
        
        if pinchGesture.state == .began || pinchGesture.state == .changed{
            if (cumulativeScale < maxScale && pinchGesture.scale > 1.0) {
                pinchGesture.view?.transform = (pinchGesture.view?.transform)!.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
                cumulativeScale *= pinchGesture.scale
                pinchGesture.scale = 1.0
            }
            if (cumulativeScale > minScale && pinchGesture.scale < 1.0) {
                pinchGesture.view?.transform = (pinchGesture.view?.transform)!.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
                cumulativeScale *= pinchGesture.scale
                pinchGesture.scale = 1.0
            }
        }
    }
}

//*****************************************************************
// MARK: - EFColorSelectionViewControllerDelegate
//*****************************************************************

extension NewDrawingVC: EFColorSelectionViewControllerDelegate {
    func colorViewController(colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        viewCurrColor.backgroundColor = color
        sketchView?.lineColor = color
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
// MARK: - SketchView Delegate
//*****************************************************************

extension NewDrawingVC: SketchViewDelegate {
    
    func drawView(_ view: SketchView, undo: NSMutableArray, didEndDrawUsingTool tool: AnyObject) {
        
        if isEdited == false {
            isEdited = true
        }
        
        checkUndoRedoStatus()
    }
    
    func updateNewColor(color: UIColor) {
        viewCurrColor.backgroundColor = color
    }
}

//*****************************************************************
// MARK: - StickerPopupVC Delegate
//*****************************************************************

extension NewDrawingVC: StickerPopupVCDelegate {
    
    func didStickerSelect(imv: String) {
        
        if isEdited == false {
            isEdited = true
        }
        
        stickNo += 1
        
        imgSticker  = UIImageView(frame: CGRect.init(x: 0.0, y: 0.0, width: 300, height: 300))
        imgSticker.center = view.center
        imgSticker.image = UIImage(named: imv)
        imgSticker.contentMode = UIViewContentMode.scaleAspectFit
        imgSticker.isUserInteractionEnabled = true
        imgSticker.tag = stickNo
        
        let rect = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: 300, height: 300))
        let layer = CAShapeLayer.init()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        layer.path = path.cgPath
        layer.strokeColor = UIColor.red.cgColor
        layer.lineDashPattern = [5,5]
        layer.lineWidth = 3
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        imgSticker.layer.addSublayer(layer)
        
        var delete = UIButton()
        delete = UIButton(frame: CGRect(x: 0, y: 0, width:30, height:30))
        delete.setImage(UIImage(named: "icon_trash_color"), for: .normal)
        delete.layer.cornerRadius = 15
        delete.clipsToBounds = true
        delete.tag = stickNo
        delete.addTarget(self, action: #selector(onCancelStampAdd(sender:)), for: .touchUpInside)
        self.imgSticker.addSubview(delete)
        
        var confirm = UIButton()
        confirm = UIButton(frame: CGRect(x: imgSticker.frame.size.width - 30, y: imgSticker.frame.size.height - 30, width:30, height:30))
        confirm.setImage(UIImage(named:"icon_check_color"), for: .normal)
        confirm.tag = stickNo
        confirm.addTarget(self, action: #selector(onAddStampConfirm(sender:)), for: .touchUpInside)
        self.imgSticker.addSubview(confirm)
        
        self.imvSticker.addSubview(imgSticker)
        
        let panStampGes = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGestureSticker(recognizer:)))
        panStampGes.delegate = self
        
        let pinchStampGes = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGestureSticker(recognizer:)))
        pinchStampGes.delegate = self
        
        let rotateStampGes = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotateGestureSticker(recognizer:)))
        rotateStampGes.delegate = self
        
        imgSticker.addGestureRecognizer(panStampGes)
        imgSticker.addGestureRecognizer(pinchStampGes)
        imgSticker.addGestureRecognizer(rotateStampGes)
    }
    
    @objc func handlePanGestureSticker(recognizer:UIPanGestureRecognizer) {
        
//        if recognizer.state == .began || recognizer.state == .changed {
//
//            let translation = recognizer.translation(in: self.view)
//            // note: 'view' is optional and need to be unwrapped
//            recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
//            recognizer.setTranslation(CGPoint.zero, in: self.view)
//        }
        
        if recognizer.state == .began || recognizer.state == .changed
        {
            let point = recognizer.location(in: self.imvSticker)
            if let superview = self.imvSticker
            {
                let restrictByPoint : CGFloat = 50.0
                let superBounds = CGRect(x: superview.bounds.origin.x + restrictByPoint, y: superview.bounds.origin.y + restrictByPoint, width: superview.bounds.size.width - restrictByPoint, height: superview.bounds.size.height - restrictByPoint)
                if (superBounds.contains(point))
                {
                    let translation = recognizer.translation(in: self.imvSticker)
                    recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
                    recognizer.setTranslation(CGPoint.zero, in: self.imvSticker)
                }
            }
        }
    }
    
    @objc func handlePinchGestureSticker(recognizer : UIPinchGestureRecognizer) {
        
        guard let view = recognizer.view else { return }
        
        view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1.0
    }
    
    @objc func handleRotateGestureSticker(recognizer : UIRotationGestureRecognizer) {
        
        guard let view = recognizer.view else { return }
        
        view.transform = view.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0.0
    }
}

//*****************************************************************
// MARK: - ShapePopupVC Delegate
//*****************************************************************

extension NewDrawingVC: ShapePopupVCDelegate {
    func didShapeClose() {
        sketchView?.isUserInteractionEnabled = false
        imvSticker.isUserInteractionEnabled = false
    }
    
    func didShapeSelect(index: Int) {
        switch index {
        case 0:
            self.sketchView?.drawTool = .line
        case 1:
            self.sketchView?.drawTool = .arrow
        case 2:
            self.sketchView?.drawTool = .rectangleStroke
        case 3:
            self.sketchView?.drawTool = .rectangleFill
        case 4:
            self.sketchView?.drawTool = .ellipseStroke
        case 5:
            self.sketchView?.drawTool = .ellipseFill
        case 6:
            self.sketchView?.drawTool = .star
        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - TextFontPopupVC Delegate
//*****************************************************************

extension NewDrawingVC: TextFontPopupVCDelegate {
    
    func onFontSelect(font: String) {
        imvSticker.fontName = font
        lblTextExample.text = font
    }
}

//*****************************************************************
// MARK: - UIGesture Delegate
//*****************************************************************

extension NewDrawingVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = gestureRecognizer.view else { return false }
        
        if let layer = view.layer.sublayers?.first {
            layer.isHidden = false
        }
        
        //hidden button
        for btn in view.subviews {
            btn.isHidden = false
        }
        
        return true
    }
}

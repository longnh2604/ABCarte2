//
//  NewDocumentVC.swift
//  ABCarte2
//
//  Created by Long on 2019/02/05.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import NXDrawKit

class NewDocumentVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnEdit: RoundButton!
    @IBOutlet weak var btnNext: RoundButton!
    @IBOutlet weak var btnPrev: RoundButton!
    @IBOutlet weak var btnPrinter: RoundButton!
    @IBOutlet weak var btnEraser: RoundButton!
    @IBOutlet weak var btnAction: RoundButton!
    @IBOutlet weak var lblPageNo: RoundLabel!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    //Variable
    var customer = CustomerData()
    var document = DocumentData()
    
    let imvDraw = UIImageView()
    var carteID: Int?
    var allowSave: Bool = false
    var docImage: [UIImage] = []
    var currPage: Int = 1
    var penMode = 0
    var isOriginal: Bool = false
    var isModified: Bool = false
    var isEditMode: Bool = false
    let maxScale: CGFloat = 3.0
    let minScale: CGFloat = 0.8
    var cumulativeScale:CGFloat = 1.0
    weak var canvasView: Canvas?
    var currentBrush : Brush = Brush()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        
        //setup navigation button
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.8
        scrollView.maximumZoomScale = 3.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
   
        setupCanvas()
        
        btnEdit.backgroundColor = COLOR_SET.kPENSELECT
        scrollView.isScrollEnabled = false
        
        if document.is_template == 1 {
            btnAction.setTitle("登録", for: .normal)
            self.canvasView?.setDrawingMode(mode: 1)
            canvasView?.isUserInteractionEnabled = true
            isEditMode = true
        } else {
            btnAction.setTitle("編集", for: .normal)
            canvasView?.isUserInteractionEnabled = false
            onEditMode(hidden: true)
        }
    }
    
    func setupCanvas() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        var stringPath = ""
        let urlEdit = URL(string: document.document_pages[0].url_edit)
        if urlEdit != nil {
            stringPath = document.document_pages[0].url_edit
            isOriginal = false
        } else {
            stringPath = document.document_pages[0].url_original
            isOriginal = true
        }
        
        btnEdit.backgroundColor = COLOR_SET.kPENSELECT
        currentBrush.width = 1.0
        
        setupButtonStatus()
        checkNextPrevButtonStatus()
        
        guard let url = URL(string: stringPath) as URL? else { fatalError("URL not found") }
        
        imvDraw.sd_setImage(with: url, completed: {(image, err, cacheType, url) in
            let canvasView = Canvas.init(canvasId: "photo\(self.currPage)", backgroundImage: image!)
            canvasView.frame = CGRect(x:0,y:0, width: self.view.frame.width, height: self.view.frame.height - 50)
            canvasView.clipsToBounds = true
            canvasView.delegate = self
            self.scrollView.addSubview(canvasView)
            self.canvasView = canvasView
            SVProgressHUD.dismiss()
        })
        
        panGesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        pinchGesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        scrollView.addGestureRecognizer(self.panGesture)
        scrollView.addGestureRecognizer(self.pinchGesture)
        
        for _ in 1...document.document_pages.count {
            let data = UIImage()
            docImage.append(data)
        }
        
        checkDocumentPageEdit(index: 0)
    }
    
    func checkDocumentPageEdit(index:Int) {
        if document.document_pages[index].is_edited == 1 {
            currentBrush.color = UIColor.red
        } else {
            currentBrush.color = UIColor.black
        }
    }
    
    func checkDocumentEditOrNot(completion:@escaping(Bool) -> ()) {
        
        if isModified == true {
            let alert = UIAlertController(title: "ドキュメント", message: MSG_ALERT.kALERT_SAVE_DOCUMENT_NOTIFICATION, preferredStyle: UIAlertControllerStyle.alert)
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
    
    func onEditMode(hidden:Bool) {
        btnUndo.isHidden = hidden
        btnRedo.isHidden = hidden
        btnEdit.isHidden = hidden
        btnEraser.isHidden = hidden
    }
    
    func setupButtonStatus() {
        if isOriginal {
            btnAction.setTitle("登録", for: .normal)
        } else {
            btnAction.setTitle("編集", for: .normal)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        checkDocumentEditOrNot { (success) in
            if success {
                //do nothing
            } else {
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func saveImageOnPresentScreen() {
        //save image last
        self.docImage[currPage - 1] = (canvasView?.asImage())!
    }
    
    func checkNextPrevButtonStatus() {
        
        if currPage == 1 && document.document_pages.count == 1 {
            btnNext.isHidden = true
            btnPrev.isHidden = true
            allowSave = true
        } else if currPage == 1 {
            btnNext.isHidden = false
            btnPrev.isHidden = true
        } else if currPage == document.document_pages.count {
            btnNext.isHidden = true
            btnPrev.isHidden = false
            allowSave = true
        } else {
            btnNext.isHidden = false
            btnPrev.isHidden = false
        }
        
        if isEditMode {
            if allowSave {
                btnAction.isHidden = false
            } else {
                btnAction.isHidden = true
            }
        }
        lblPageNo.text = "ページ : \(currPage)/\(document.document_pages.count)"
    }
    
    func resetAllButtonStatus() {
        btnEdit.backgroundColor = COLOR_SET.kPENUNSELECT
        btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
        btnPrinter.backgroundColor = COLOR_SET.kPENUNSELECT
    }
    
    func onChangePage() {
        //reset frame
        pinchGesture.scale = 1.0
        cumulativeScale = 1.0
        scrollView.transform = CGAffineTransform.identity
        
        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        self.canvasView = nil
        canvasView?.delegate = nil
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //check document is template or not
        if document.is_template == 1 {
 
            let url = URL(string: self.document.document_pages[currPage - 1].url_original)
            
            imvDraw.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                } else {
                    var imageData = UIImage()
                    
                    if self.docImage[self.currPage - 1].size.width != 0 {
                        imageData = self.docImage[self.currPage - 1]
                    } else {
                        imageData = image!
                    }
                    
                    let canvasView = Canvas.init(canvasId: nil, backgroundImage: imageData)
                    canvasView.frame = CGRect(x:0,y:0, width: self.view.frame.width, height: self.view.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.scrollView.addSubview(canvasView)
                    self.canvasView = canvasView
                    
                    self.checkDocumentPageEdit(index: self.currPage - 1)
                    
                    self.btnEdit.backgroundColor = COLOR_SET.kPENSELECT
                    self.btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
                    
                    self.canvasView?.setDrawingMode(mode: 1)
                    self.canvasView?.penMode = self.penMode
                }
                SVProgressHUD.dismiss()
            }
        } else {
            var stringPath = ""
            
            let urlEdit = URL(string: document.document_pages[currPage - 1].url_edit)
            if urlEdit != nil {
                stringPath = document.document_pages[currPage - 1].url_edit
            } else {
                stringPath = document.document_pages[currPage - 1].url_original
            }
            
            let url = URL(string: stringPath)
            
            imvDraw.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                } else {
                    var imageData = UIImage()
                    if self.docImage[self.currPage - 1].size.width != 0 {
                        imageData = self.docImage[self.currPage - 1]
                    } else {
                        imageData = image!
                    }
                    
                    let canvasView = Canvas.init(canvasId: nil, backgroundImage: imageData)
                    
                    canvasView.frame = CGRect(x:0,y:0, width: self.view.frame.width, height: self.view.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.scrollView.addSubview(canvasView)
                    self.canvasView = canvasView
                    
                    self.checkDocumentPageEdit(index: self.currPage - 1)
                    
                    self.btnEdit.backgroundColor = COLOR_SET.kPENSELECT
                    self.btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
                    
                    self.canvasView?.setDrawingMode(mode: 1)
                    self.canvasView?.penMode = self.penMode
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Action
    //*****************************************************************
    
    @IBAction func onAction(_ sender: UIButton) {
        
        if isEditMode == false {
            isEditMode = true
            btnAction.setTitle("登録", for: .normal)
            onEditMode(hidden: false)
            
            canvasView?.isUserInteractionEnabled = true
            self.canvasView?.setDrawingMode(mode: 1)
        } else {
            //check if user has edited all page or not
            if allowSave {
                
                SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                saveImageOnPresentScreen()
                
                guard let carteID = carteID else { return }
                //check document is template or not
                if document.is_template == 1 {
                    
                    //add document first
                    addDocumentIntoCarte(documentID: document.id, carteID: carteID) { (success, jsonData) in
                        if success {
                            
                            var documentIDs : [Int] = []
                            
                            if jsonData.count > 0 {
                                for i in 0 ..< jsonData.count {
                                    documentIDs.append(jsonData[i]["id"].intValue)
                                }
                            }
                            var data : [Data] = []
                            for i in 0 ..< self.docImage.count {
                                data.append(UIImageJPEGRepresentation(self.docImage[i], 1.0)!)
                            }
                            
                            SVProgressHUD.showProgress(0.6, status: "サーバーにアップロード中:60%")
                            
                            editDocumentInCarteFromNew(documentIDs: documentIDs, imageData: data, page: 1, isEdited: 1, completion: { (success) in
                                
                                SVProgressHUD.showProgress(0.9, status: "サーバーにアップロード中:90%")
                                
                                if success {
                                    if self.isModified == true {
                                        self.isModified = false
                                    }
                                    GlobalVariables.sharedManager.selectedImageIds.removeAll()
                                    _ = self.navigationController?.popViewController(animated: true)
                                } else {
                                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                                }
                                SVProgressHUD.dismiss()
                            })
                        }
                    }
                    
                } else {
                    
                    var data : [Data] = []
                    for i in 0 ..< self.docImage.count {
                        data.append(UIImageJPEGRepresentation(self.docImage[i], 1.0)!)
                    }
                    
                    editDocumentInCarteNew(document: document, imageData: data,page: 1, isEdited: 1) { (success) in
                        
                        SVProgressHUD.showProgress(0.9, status: "サーバーにアップロード中:90%")
                        
                        if success {
                            if self.isModified == true {
                                self.isModified = false
                            }
                            
                            GlobalVariables.sharedManager.selectedImageIds.removeAll()
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                }
                
            } else {
                showAlert(message: MSG_ALERT.kALERT_CHECK_ALL_DOCUMENT_PAGE, view: self)
                return
            }
        }
    }
    
    @IBAction func onToolSelect(_ sender: UIButton) {
        
        resetAllButtonStatus()
        canvasView?.isUserInteractionEnabled = false
        
        switch sender.tag {
        case 1:
            let alert = UIAlertController(title: "描画モードを選択してください", message: nil, preferredStyle: .actionSheet)
            let pencil = UIAlertAction(title: "ペンシル", style: .default) { UIAlertAction in
                self.canvasView?.penMode = 1
                self.penMode = 1
                self.btnEdit.setImage(UIImage(named: "icon_pen_black.png"), for: .normal)
            }
            let finger = UIAlertAction(title: "指", style: .default) { UIAlertAction in
                self.canvasView?.penMode = 0
                self.penMode = 0
                self.btnEdit.setImage(UIImage(named: "selectIcon.png"), for: .normal)
            }
            
            alert.addAction(pencil)
            alert.addAction(finger)
            
            alert.popoverPresentationController?.sourceView = self.btnEdit
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            alert.popoverPresentationController?.sourceRect = self.btnEdit.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            self.canvasView?.setDrawingMode(mode: 1)
            canvasView?.isUserInteractionEnabled = true
            btnEdit.backgroundColor = COLOR_SET.kPENSELECT
            currentBrush.width = 1.0
        case 2:
            canvasView?.isUserInteractionEnabled = true
            self.canvasView?.setDrawingMode(mode: 4)
            btnEraser.backgroundColor = COLOR_SET.kPENSELECT
            currentBrush.width = 10.0
        case 3:
            btnPrinter.backgroundColor = COLOR_SET.kPENSELECT
            let urlPath = saveImageToLocal(imageDownloaded: self.canvasView!.asImage(), name: customer.customer_no)
            printUrl(urlPath)
        default:
            break
        }
    }
    
    @IBAction func onUndoRedo(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.canvasView?.undo()
        case 1:
            self.canvasView?.redo()
        default:
            break
        }
    }
    
    @IBAction func onPrevious(_ sender: UIButton) {
        
        //save image last
        saveImageOnPresentScreen()
        
        if currPage > 1 {
            currPage -= 1
            checkNextPrevButtonStatus()
            onChangePage()
        }
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
        //save image last
        saveImageOnPresentScreen()
        
        if currPage < document.document_pages.count {
            currPage += 1
            checkNextPrevButtonStatus()
            onChangePage()
        }
    }
    
    //*****************************************************************
    // MARK: - Gestures
    //*****************************************************************
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            
            switch recognizer.state {
            case .changed:
                if (cumulativeScale < maxScale && recognizer.scale > 1.0) || (cumulativeScale > minScale && recognizer.scale < 1.0) {
                    let pinchCenter = CGPoint(x: recognizer.location(in: view).x - view.bounds.midX,
                                              y: recognizer.location(in: view).y - view.bounds.midY)
                    let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                        .scaledBy(x: recognizer.scale, y: recognizer.scale)
                        .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                    view.transform = transform
                    cumulativeScale *= recognizer.scale
                    recognizer.scale = 1
                }
                
//            case .ended:
                // scale down when releasing the pinch.
//                UIView.animate(withDuration: 0.2, animations: {
//                    view.transform = CGAffineTransform.identity
//            })
            default:
                return
            }
        }
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        if recognizer.state == .began || recognizer.state == .changed
        {
            let point = recognizer.location(in: self.view)
            if let superview = self.view
            {
                let restrictByPoint : CGFloat = 50.0
                let superBounds = CGRect(x: superview.bounds.origin.x + restrictByPoint, y: superview.bounds.origin.y + restrictByPoint, width: superview.bounds.size.width - 2*restrictByPoint, height: superview.bounds.size.height - 2*restrictByPoint)
                if (superBounds.contains(point))
                {
                    let translation = recognizer.translation(in: self.view)
                    recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
                    recognizer.setTranslation(CGPoint.zero, in: self.view)
                }
            }
        }
    }
}

//*****************************************************************
// MARK: - SketchView Delegate
//*****************************************************************

extension NewDocumentVC: CanvasDelegate {
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        if self.isModified == false {
            self.isModified = true
        }
        updateToolBarButtonStatus(canvas)
    }
    
    func updateToolBarButtonStatus(_ canvas: Canvas){
        btnUndo.isEnabled = canvas.canUndo()
        btnRedo.isEnabled = canvas.canRedo()
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension NewDocumentVC: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        guard let imageViewSize = canvasView?.frame.size else { return }
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        if verticalPadding >= 0 {
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding + 200, left: horizontalPadding + 200, bottom: verticalPadding + 200, right: horizontalPadding + 200)
        } else {
            scrollView.contentSize = imageViewSize
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
}

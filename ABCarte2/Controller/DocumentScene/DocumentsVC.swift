//
//  DocumentsVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import NXDrawKit
import SDWebImage

class DocumentsVC: UIViewController {
    
    //IBOutlet
    @IBOutlet weak var viewDoc: UIView!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnEdit: RoundButton!
    @IBOutlet weak var btnNext: RoundButton!
    @IBOutlet weak var btnPrev: RoundButton!
    @IBOutlet weak var btnEraser: RoundButton!
    @IBOutlet weak var btnComplete: RoundButton!
    
    //Variable
    var customer = CustomerData()
    var document = DocumentData()
    
    var carteID: Int?
    var arrDocumentPageID: [Int] = []
    weak var canvasView: Canvas?
    var currentBrush : Brush = Brush()
    var isTouch: Bool?
    var pageNo: Int?
    var imageConverted: Data?
    let maxScale: CGFloat = 5.0
    let minScale: CGFloat = 1.0
    var cumulativeScale:CGFloat = 1.0
    var isEdited: Int?
    var isModified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        setupCanvas()
        
        isTouch = false
        btnEdit.backgroundColor = COLOR_SET.kPENSELECT
//        self.canvasView?.setDrawingMode(mode: 1)
        
        self.btnUndo.isEnabled = false
        self.btnRedo.isEnabled = false
        
        currentBrush.width = 1
        
        //set document page
        pageNo = 1
        //check total document page
        if document.document_pages.count > 1 {
            btnNext.isHidden = false
            btnComplete.isHidden = true
        } else {
            btnNext.isHidden = true
            btnComplete.isHidden = false
        }
        
        checkDocumentPageEdit(index: pageNo! - 1)
    }
    
    func checkDocumentPageEdit(index:Int) {
        if document.document_pages[index].is_edited == 1 {
            currentBrush.color = UIColor.red
        } else {
            currentBrush.color = UIColor.black
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        
        checkDocumentEditOrNot { (success) in
            if success {
                
            } else {
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onPrintFile() {
        
        let urlPath = saveImageToLocal(imageDownloaded: self.canvasView!.asImage(), name: customer.customer_no)
        
        printUrl(urlPath)
    }
    
    func resetButtonState() {
        btnEdit.backgroundColor = COLOR_SET.kPENUNSELECT
        btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
    }
    
    func setupCanvas() {
        pinchGesture.scale = 1
        //allow gesture with finger touch only
        panGesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        pinchGesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        
        viewDoc.translatesAutoresizingMaskIntoConstraints = false
        viewDoc.addGestureRecognizer(self.panGesture)
        viewDoc.addGestureRecognizer(self.pinchGesture)
        
        let img = UIImageView()
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        var stringPath = ""
        
        let urlEdit = URL(string: document.document_pages[0].url_edit)
        if urlEdit != nil {
            stringPath = document.document_pages[0].url_edit
        } else {
            stringPath = document.document_pages[0].url_original
        }
        
        let url = URL(string: stringPath)
     
        img.sd_setImage(with: url) { (image, error, cachetype, url) in
            if (error != nil) {
                //Failure code here
                showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
            } else {
                //Success code here
                let canvasView = Canvas.init(canvasId: "photo", backgroundImage: img.image)
                canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                canvasView.clipsToBounds = true
                canvasView.delegate = self
                self.viewDoc.addSubview(canvasView)
                self.canvasView = canvasView
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func updateToolBarButtonStatus(_ canvas: Canvas){
        btnUndo.isEnabled = canvas.canUndo()
        btnRedo.isEnabled = canvas.canRedo()
    }
    
    //*****************************************************************
    // MARK: - Gestures
    //*****************************************************************
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
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
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        if recognizer.state == .began || recognizer.state == .changed {
            
            let translation = recognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    func onChangePage() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.canvasView?.clear()
        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        for subview in viewDoc.subviews {
            subview.removeFromSuperview()
        }
        
        let img = UIImageView()
        
        guard let pageNo = pageNo else { return }
        
        //check document is template or not
        if document.is_template == 1 {
            
            let url = URL(string: self.document.document_pages[pageNo - 1].url_original)
            img.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                } else {
                    //Success code here
                    let canvasView = Canvas.init(canvasId: "photo", backgroundImage: img.image)
                    canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.viewDoc.addSubview(canvasView)
                    self.canvasView = canvasView
                }
                SVProgressHUD.dismiss()
            }
            
        } else {
            
            var stringPath = ""
            
            let urlEdit = URL(string: document.document_pages[pageNo - 1].url_edit)
            if urlEdit != nil {
                stringPath = document.document_pages[pageNo - 1].url_edit
            } else {
                stringPath = document.document_pages[pageNo - 1].url_original
            }
            
            let url = URL(string: stringPath)
            
            img.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                } else {
                    //Success code here
                    let canvasView = Canvas.init(canvasId: "photo", backgroundImage: img.image)
                    canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.viewDoc.addSubview(canvasView)
                    self.canvasView = canvasView
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func onSaveImage(image: UIImage,completion:@escaping(Bool) -> ()) {

        guard let carteID = carteID,let pageNumber = pageNo else {
            completion(false)
            return
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        self.imageConverted = UIImageJPEGRepresentation(image, 1)
        
        //check document is template or not
        if document.is_template == 1 {
            //check if it's page 1
            if pageNumber == 1 {
                
                //add document first
                addDocumentIntoCarte(documentID: document.id, carteID: carteID) { (success, jsonData) in
                    if success {
                        
                        if jsonData.count > 0 {
                            
                            for i in 0 ..< jsonData.count {
                                self.arrDocumentPageID.append(jsonData[i]["id"].intValue)
                            }
                        }
                        
                        if self.document.document_pages[pageNumber - 1].is_edited == 0 {
                            self.isEdited = 1
                        } else {
                            self.isEdited = self.document.document_pages[pageNumber - 1].is_edited
                        }
                        
                        editDocumentInCarte(documentPageID: self.arrDocumentPageID[pageNumber - 1], page: pageNumber, imageData: self.imageConverted!,isEdited: self.isEdited!) { (success) in
                            if success {
                                if self.isModified == true {
                                    self.isModified = false
                                }
                                completion(true)
                            } else {
                                completion(false)
                                showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        completion(false)
                        showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                guard let id = self.arrDocumentPageID[pageNumber - 1] as Int? else { return }
                
                editDocumentInCarte(documentPageID: id, page: pageNumber, imageData: self.imageConverted!,isEdited: self.isEdited!) { (success) in
                    if success {
                        if self.isModified == true {
                            self.isModified = false
                        }
                        completion(true)
                    } else {
                        completion(false)
                        showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            }
            
        } else {
            
            if self.document.document_pages[pageNumber - 1].is_edited == 0 {
                self.isEdited = 1
            } else {
                self.isEdited = self.document.document_pages[pageNumber - 1].is_edited
            }
            
            editDocumentInCarte(documentPageID: document.document_pages[pageNumber - 1].id, page: pageNumber, imageData: self.imageConverted!,isEdited: self.isEdited!) { (success) in
                if success {
                    if self.isModified == true {
                        self.isModified = false
                    }
                    completion(true)
                } else {
                    completion(false)
                    showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func saveImageEdit()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext((canvasView?.frame.size)!)
        canvasView?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onComplete(_ sender: UIButton) {
        onSaveImage(image: saveImageEdit()) { (success) in
            if success {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        currentBrush.width = 1
        
        isTouch = false
        resetButtonState()
        btnEdit.backgroundColor = COLOR_SET.kPENSELECT
    }
    
    @IBAction func onUndo(_ sender: UIButton) {
        self.canvasView?.undo()
    }
    
    @IBAction func onRedo(_ sender: UIButton) {
        self.canvasView?.redo()
    }
    
    @IBAction func onTouch(_ sender: UIButton) {
        isTouch = true
        resetButtonState()
    }
    
    @IBAction func onEraser(_ sender: UIButton) {
        currentBrush.width = 20
        
        isTouch = false
        resetButtonState()
        btnEraser.backgroundColor = COLOR_SET.kPENSELECT
    }
    
    @IBAction func onPrint(_ sender: UIButton) {
        onPrintFile()
    }
    
    @IBAction func onNextPage(_ sender: UIButton) {
        
        onSaveImage(image: saveImageEdit()) { (success) in
            if success {
                self.pageNo = self.pageNo! + 1
                
                self.checkDocumentPageEdit(index: self.pageNo! - 1)
                
                self.onChangePage()
                
                if self.pageNo! < self.document.document_pages.count {
                    self.btnNext.isHidden = false
                    self.btnComplete.isHidden = true
                } else {
                    self.btnNext.isHidden = true
                    self.btnComplete.isHidden = false
                }
                
                self.isTouch = true
                self.resetButtonState()
            }
        }
    }
    
}

//*****************************************************************
// MARK: - Canvas Delegate
//*****************************************************************

extension DocumentsVC: CanvasDelegate {
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        if self.isModified == false {
            self.isModified = true
        }
        
        updateToolBarButtonStatus(canvas)
    }
}

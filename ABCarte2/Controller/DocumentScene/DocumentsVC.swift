//
//  DocumentsVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import NXDrawKit
import JGProgressHUD
import SDWebImage

class DocumentsVC: UIViewController {
    
    //IBOutlet
    @IBOutlet weak var viewDoc: UIView!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnEdit: RoundButton!
    @IBOutlet weak var btnTouch: RoundButton!
    @IBOutlet weak var btnNext: RoundButton!
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
    let hud = JGProgressHUD(style: .dark)
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
        
        isTouch = true
        btnTouch.backgroundColor = kPENSELECT
        
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
    
    func resetButtonState() {
        btnEdit.backgroundColor = kPENUNSELECT
        btnTouch.backgroundColor = kPENUNSELECT
        btnEraser.backgroundColor = kPENUNSELECT
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }
    
    func setupCanvas() {
        pinchGesture.scale = 1
        
        viewDoc.translatesAutoresizingMaskIntoConstraints = false
        viewDoc.addGestureRecognizer(self.panGesture)
        viewDoc.addGestureRecognizer(self.pinchGesture)
        
        let img = UIImageView()
        
        showLoading()
        
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
                self.hud.dismiss()
            } else {
                //Success code here
                let canvasView = Canvas.init(canvasId: "photo", backgroundImage: img.image)
                canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                canvasView.delegate = self
                canvasView.clipsToBounds = true
                self.viewDoc.addSubview(canvasView)
                self.canvasView = canvasView
                self.hud.dismiss()
            }
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
        
        self.canvasView?.clear()
        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        for subview in viewDoc.subviews {
            subview.removeFromSuperview()
        }
        
        showLoading()
        let img = UIImageView()
        
        guard let pageN = pageNo else {
            return
        }
        
        //check document is template or not
        if document.is_template == 1 {
            
            let url = URL(string: self.document.document_pages[pageN - 1].url_original)
            img.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                    self.hud.dismiss()
                } else {
                    //Success code here
                    let canvasView = Canvas.init(canvasId: "photo", backgroundImage: img.image)
                    canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.viewDoc.addSubview(canvasView)
                    self.canvasView = canvasView
                    self.hud.dismiss()
                }
            }
            
        } else {
            
            var stringPath = ""
            
            let urlEdit = URL(string: document.document_pages[pageN - 1].url_edit)
            if urlEdit != nil {
                stringPath = document.document_pages[pageN - 1].url_edit
            } else {
                stringPath = document.document_pages[pageN - 1].url_original
            }
            
            let url = URL(string: stringPath)
            
            img.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                    self.hud.dismiss()
                } else {
                    //Success code here
                    let canvasView = Canvas.init(canvasId: "photo", backgroundImage: img.image)
                    canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.viewDoc.addSubview(canvasView)
                    self.canvasView = canvasView
                    self.hud.dismiss()
                }
            }
        }
        
        if isTouch! {
            self.canvasView?.setDrawingMode(mode: 5)
            panGesture.isEnabled = true
            pinchGesture.isEnabled = true
        } else {
            self.canvasView?.setDrawingMode(mode: 1)
            panGesture.isEnabled = false
            pinchGesture.isEnabled = false
        }
    }
    
    func onSaveImage(image: UIImage,completion:@escaping(Bool) -> ()) {

        guard let carteID = carteID else {
            completion(false)
            return
        }
        
        guard let pageNumber = pageNo else {
            completion(false)
            return
        }
  
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
        
        self.imageConverted = UIImageJPEGRepresentation(image, 1.0)
        
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
                               
                                hud.dismiss()
                            } else {
                                
                                completion(false)
                                
                                hud.dismiss()
                 
                                showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                            }
                        }
                    } else {
                        
                        completion(false)
                        
                        hud.dismiss()
        
                        showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                }
            } else {
                guard let id = self.arrDocumentPageID[pageNumber - 1] as Int? else {
                    return
                }
                
                editDocumentInCarte(documentPageID: id, page: pageNumber, imageData: self.imageConverted!,isEdited: self.isEdited!) { (success) in
                    if success {
                        
                        if self.isModified == true {
                            self.isModified = false
                        }
                        
                        completion(true)
                    
                        hud.dismiss()
                    } else {
                        
                        completion(false)
                        
                        hud.dismiss()
                   
                        showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
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
                 
                    hud.dismiss()
                } else {
                    
                    completion(false)
                    
                    hud.dismiss()
          
                    showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
                }
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
            let alert = UIAlertController(title: "ドキュメント", message: kALERT_SAVE_DOCUMENT_NOTIFICATION, preferredStyle: UIAlertControllerStyle.alert)
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
        self.canvasView?.setDrawingMode(mode: 1)
        panGesture.isEnabled = false
        pinchGesture.isEnabled = false
        
        resetButtonState()
        btnEdit.backgroundColor = kPENSELECT
    }
    
    @IBAction func onUndo(_ sender: UIButton) {
        self.canvasView?.undo()
    }
    
    @IBAction func onRedo(_ sender: UIButton) {
        self.canvasView?.redo()
    }
    
    @IBAction func onTouch(_ sender: UIButton) {
        isTouch = true
        self.canvasView?.setDrawingMode(mode: 5)
        panGesture.isEnabled = true
        pinchGesture.isEnabled = true
        
        resetButtonState()
        btnTouch.backgroundColor = kPENSELECT
    }
    
    @IBAction func onEraser(_ sender: UIButton) {
        currentBrush.width = 20
        
        isTouch = false
        self.canvasView?.setDrawingMode(mode: 4)
        panGesture.isEnabled = false
        pinchGesture.isEnabled = false
        
        resetButtonState()
        btnEraser.backgroundColor = kPENSELECT
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
                self.canvasView?.setDrawingMode(mode: 5)
                self.panGesture.isEnabled = true
                self.pinchGesture.isEnabled = true
                
                self.resetButtonState()
                self.btnTouch.backgroundColor = kPENSELECT
            }
        }
    }
    
}

//*****************************************************************
// MARK: - Canvas Delegate
//*****************************************************************

extension DocumentsVC: CanvasDelegate{
    
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        
        if self.isModified == false {
            self.isModified = true
        }
        
        updateToolBarButtonStatus(canvas)
    }
    
    func updateNewColor(color: UIColor) {
    }
}

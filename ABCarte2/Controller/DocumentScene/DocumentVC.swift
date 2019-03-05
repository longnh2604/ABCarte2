//
//  DocumentVC.swift
//  ABCarte2
//
//  Created by Long on 2019/01/09.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage
import NXDrawKit

class DocumentVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var viewDoc: UIView!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnEdit: RoundButton!
    @IBOutlet weak var btnNext: RoundButton!
    @IBOutlet weak var btnPrev: RoundButton!
    @IBOutlet weak var btnPrinter: RoundButton!
    @IBOutlet weak var btnEraser: RoundButton!
    @IBOutlet weak var btnAction: RoundButton!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var lblPageNo: RoundLabel!
    
    //Variable
    var customer = CustomerData()
    var document = DocumentData()
    
    let imvDraw = UIImageView()
    var carteID: Int?
    var allowSave: Bool = false
    var docsImage: [Data] = []
    var currPage: Int = 1
    var isOriginal: Bool = false
    var isModified: Bool = false
    var isEditMode: Bool = false
    let maxScale: CGFloat = 3.0
    let minScale: CGFloat = 1.0
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
        
        setupCanvas()
        
        btnEdit.backgroundColor = COLOR_SET.kPENSELECT
        currentBrush.width = 1.0
        
        setupButtonStatus()
        
        checkNextPrevButtonStatus()
        
        if document.is_template == 1 {
            btnAction.setTitle("登録", for: .normal)
            canvasView?.isUserInteractionEnabled = true
            isEditMode = true
        } else {
            btnAction.setTitle("編集", for: .normal)
            onEditMode(hidden: true)
        }
    }
    
    func setupCanvas() {
        
        //setup gesture
        pinchGesture.scale = 1
        //allow gesture with finger touch only
        panGesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        pinchGesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        
        viewDoc.translatesAutoresizingMaskIntoConstraints = false
        viewDoc.addGestureRecognizer(self.panGesture)
        viewDoc.addGestureRecognizer(self.pinchGesture)
        
        var stringPath = ""
        let urlEdit = URL(string: document.document_pages[0].url_edit)
        if urlEdit != nil {
            stringPath = document.document_pages[0].url_edit
            isOriginal = false
        } else {
            stringPath = document.document_pages[0].url_original
            isOriginal = true
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let url = URL(string: stringPath)
        imvDraw.sd_setImage(with: url) { (image, error, cachetype, url) in
            if (error != nil) {
                //Failure code here
                showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
            } else {
                //Success code here
                let canvasView = Canvas.init(canvasId: "photo", backgroundImage: self.imvDraw.image)
                canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                canvasView.clipsToBounds = true
                canvasView.delegate = self
                self.viewDoc.addSubview(canvasView)
                self.canvasView = canvasView
            }
            SVProgressHUD.dismiss()
        }
        
        for _ in 1...document.document_pages.count {
            let data = Data()
            docsImage.append(data)
        }
        
        checkDocumentPageEdit(index: 0)
    }
    
    func setupButtonStatus() {
        if isOriginal {
            btnAction.setTitle("登録", for: .normal)
        } else {
            btnAction.setTitle("編集", for: .normal)
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
    
//    func checkUndoRedoStatus() {
//        guard let undo = sketchView?.canUndo() as Bool?,let redo = sketchView?.canRedo() as Bool? else {
//            btnUndo.isEnabled = false
//            btnRedo.isEnabled = false
//            return
//        }
//
//        if undo == true {
//            btnUndo.isEnabled = true
//        } else {
//            btnUndo.isEnabled = false
//        }
//
//        if redo == true {
//            btnRedo.isEnabled = true
//        } else {
//            btnRedo.isEnabled = false
//        }
//    }
    
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
    
    func onChangePage() {

        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        for subview in viewDoc.subviews {
            subview.removeFromSuperview()
        }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
   
        //check document is template or not
        if document.is_template == 1 {
            
            print(docsImage)
            let url = URL(string: self.document.document_pages[currPage - 1].url_original)
            
            imvDraw.sd_setImage(with: url) { (image, error, cachetype, url) in
                if (error != nil) {
                    //Failure code here
                    showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                } else {
                    
                    var imageData = UIImage()
                    
                    if self.docsImage[self.currPage - 1].hashValue != 0 {
                        guard let data = self.docsImage[self.currPage - 1] as Data? else { return }
                        imageData = UIImage(data: data)!
                    } else {
                        imageData = self.imvDraw.image!
                    }
                    
                    let canvasView = Canvas.init(canvasId: "photo", backgroundImage: imageData)
                    canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.viewDoc.addSubview(canvasView)
                    self.canvasView = canvasView
                    
                    self.checkDocumentPageEdit(index: self.currPage - 1)
                    
                    self.btnEdit.backgroundColor = COLOR_SET.kPENSELECT
                    self.btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
                    
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
                    //Success code here
                    var imageData = UIImage()
                    
                    if self.docsImage[self.currPage - 1].hashValue != 0 {
                        guard let data = self.docsImage[self.currPage - 1] as Data? else { return }
                        imageData = UIImage(data: data)!
                    } else {
                        imageData = self.imvDraw.image!
                    }
                    
                    let canvasView = Canvas.init(canvasId: "photo", backgroundImage: imageData)
                   
                    canvasView.frame = CGRect(x:0,y:0, width: self.viewDoc.frame.width, height: self.viewDoc.frame.height)
                    canvasView.delegate = self
                    canvasView.clipsToBounds = true
                    self.viewDoc.addSubview(canvasView)
                    self.canvasView = canvasView
                    
                    self.checkDocumentPageEdit(index: self.currPage - 1)
                    
                    self.btnEdit.backgroundColor = COLOR_SET.kPENSELECT
                    self.btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func onEditMode(hidden:Bool) {
        btnUndo.isHidden = hidden
        btnRedo.isHidden = hidden
        btnEdit.isHidden = hidden
        btnEraser.isHidden = hidden
    }
    
    func saveImageOnPresentScreen() {
        //save image last
//        guard let data = UIImageJPEGRepresentation((self.sketchView?.image)!, 1.0) else { return }
        guard let data = UIImageJPEGRepresentation(saveImageEdit(), 1.0) else { return }
        self.docsImage[currPage - 1] = data
    }
    
    func saveImageEdit()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext((canvasView?.frame.size)!)
        canvasView?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func checkDocumentPageEdit(index:Int) {
        if document.document_pages[index].is_edited == 1 {
            currentBrush.color = UIColor.red
        } else {
            currentBrush.color = UIColor.black
        }
    }
        
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onUndoRedo(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            print("Undo")
            self.canvasView?.undo()
        case 1:
            print("Redo")
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
    
    @IBAction func onPrint(_ sender: UIButton) {
        let urlPath = saveImageToLocal(imageDownloaded: self.canvasView!.asImage(), name: customer.customer_no)
        printUrl(urlPath)
    }
    
    @IBAction func onPen(_ sender: UIButton) {
        btnEdit.backgroundColor = COLOR_SET.kPENSELECT
        btnEraser.backgroundColor = COLOR_SET.kPENUNSELECT
        
//        self.canvasView?.setDrawingMode(mode: 1)
        currentBrush.width = 1.0
    }
    
    @IBAction func onEraser(_ sender: UIButton) {
        btnEdit.backgroundColor = COLOR_SET.kPENUNSELECT
        btnEraser.backgroundColor = COLOR_SET.kPENSELECT
        
//        self.canvasView?.setDrawingMode(mode: 4)
        currentBrush.width = 10.0
    }
    
    @IBAction func onAction(_ sender: UIButton) {
        
        if isEditMode == false {
            isEditMode = true
            btnAction.setTitle("登録", for: .normal)
            onEditMode(hidden: false)

            canvasView?.isUserInteractionEnabled = true
//            self.canvasView?.setDrawingMode(mode: 1)
        } else {
            
            //check if user has edited all page or not
            if allowSave {
                
                SVProgressHUD.show(withStatus: "読み込み中")
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
                            
                            editDocumentInCarteFromNew(documentIDs: documentIDs, imageData: self.docsImage, page: 1, isEdited: 1, completion: { (success) in
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
                    
                    editDocumentInCarteNew(document: document, imageData: docsImage,page: 1, isEdited: 1) { (success) in
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
                // Nice animation to scale down when releasing the pinch.
                // OPTIONAL
//                UIView.animate(withDuration: 0.2, animations: {
//                    view.transform = CGAffineTransform.identity
//                })
            default:
                return
            }
        }
        
//        guard pinchGesture.view != nil else { return }
//
//        if pinchGesture.state == .began || pinchGesture.state == .changed{
//            if (cumulativeScale < maxScale && pinchGesture.scale > 1.0) {
//                pinchGesture.view?.transform = (pinchGesture.view?.transform)!.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
//                cumulativeScale *= pinchGesture.scale
//                pinchGesture.scale = 1.0
//            }
//            if (cumulativeScale > minScale && pinchGesture.scale < 1.0) {
//                pinchGesture.view?.transform = (pinchGesture.view?.transform)!.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
//                cumulativeScale *= pinchGesture.scale
//                pinchGesture.scale = 1.0
//            }
//        }
    }
}

//*****************************************************************
// MARK: - Canvas Delegate
//*****************************************************************

extension DocumentVC: CanvasDelegate {
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

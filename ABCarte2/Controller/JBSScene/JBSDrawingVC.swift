//
//  JBSDrawingVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import NXDrawKit

class JBSDrawingVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var viewPallet: UIView!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var viewPalletConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnPen: UIButton!
    @IBOutlet weak var btnAirBrush: UIButton!
    @IBOutlet weak var btnEraser: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewBrushSize: UIView!
    @IBOutlet weak var slideBWidth: MySlider!
    @IBOutlet weak var lblBrushSize: UILabel!
    
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var btnUnlock: UIButton!
    @IBOutlet weak var btnPickColor: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    //Variable
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    var currentBrush : Brush = Brush()
    var imgSelected:String? = ""
    var cellSelected:Int? = nil
    var lockStatus: Bool = false
    var airbrushSize: Float? = 0
    var penSize: Float? = 0
    var eraserSize: Float? = 0
    var drawMode: Int? = 0
    var imageOriginal: UIImage? = nil
    var arrBFace = ["JBS_selectA1.png","JBS_selectB2.png","JBS_selectC2.png","JBS_selectD2.png","JBS_selectA2.png","JBS_selectE2.png"]

    var imageCenterXConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var imageCenterYConstraint:NSLayoutConstraint = NSLayoutConstraint()
    let kSelectColor = UIColor.init(red: 12/255, green: 249/255, blue: 158/255, alpha: 1)
    let kUnSelectColor = UIColor.clear
    //color set
    //A
    let kConcealerA = UIColor.init(red: 232/255, green: 206/255, blue: 191/255, alpha: 1)
    let kEyeBrowA = UIColor.init(red: 124/255, green: 106/255, blue: 88/255, alpha: 1)
    //B
    let kConcealerB = UIColor.init(red: 218/255, green: 185/255, blue: 165/255, alpha: 1)
    let kEyeBrowB = UIColor.init(red: 133/255, green: 98/255, blue: 84/255, alpha: 1)
    //C
    let kConcealerC = UIColor.init(red: 230/255, green: 204/255, blue: 193/255, alpha: 1)
    let kEyeBrowC = UIColor.init(red: 144/255, green: 105/255, blue: 95/255, alpha: 1)
    //D
    let kConcealerD = UIColor.init(red: 234/255, green: 204/255, blue: 186/255, alpha: 1)
    let kEyeBrowD = UIColor.init(red: 78/255, green: 65/255, blue: 69/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {  
        setupCanvas()
        setupPallet()
        
        btnUndo.isEnabled = false
        btnRedo.isEnabled = false
        
        btnComplete.layer.cornerRadius = 10
        btnSave.layer.cornerRadius = 10
        btnComplete.clipsToBounds = true
        btnSave.clipsToBounds = true
        
        lockStatus = false
        
        viewBrushSize.isHidden = true
    }
    
    func setupCanvas() {
        viewDrawing.translatesAutoresizingMaskIntoConstraints = false
        
        let canvasView = Canvas.init(canvasId: "photo", backgroundImage: UIImage(named:imgSelected!))
        canvasView.frame = CGRect(x:0,y:0, width: self.viewDrawing.frame.width, height: self.viewDrawing.frame.height)
        canvasView.delegate = self
        canvasView.clipsToBounds = true
        viewDrawing.addSubview(canvasView)
        self.canvasView = canvasView
        imageOriginal = saveImageEdit()
    }
    
    func setupPallet() {
        let paletteView = Palette()
        paletteView.setup()
        paletteView.delegate = self
        self.viewPallet.addSubview(paletteView)
        self.paletteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0, y: 0, width: self.viewPallet.frame.width, height: paletteHeight)
        paletteView.layer.cornerRadius = 20
    }
    
    func updateToolBarButtonStatus(_ canvas: Canvas){
        btnUndo.isEnabled = canvas.canUndo()
        btnRedo.isEnabled = canvas.canRedo()
    }
    
    func updateDrawButtonStatus() {
        switch drawMode {
        case 1:
            changeBrushColor()
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_ON.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
        case 2:
            changeAirBrushColor()
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_ON.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
        case 4:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_ON.png"), for: .normal)
        default:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
        }
        changeBrushSizeView()
    }
    
    func changeBrushColor() {
        switch cellSelected {
        case 0:
            currentBrush.color = kEyeBrowA
        case 1:
            currentBrush.color = kEyeBrowB
        case 2:
            currentBrush.color = kEyeBrowC
        case 3:
            currentBrush.color = kEyeBrowD
        case 4:
            currentBrush.color = kEyeBrowA
        case 5:
            currentBrush.color = kEyeBrowD
        default:
            return
        }
    }
    
    func changeAirBrushColor() {
        switch cellSelected {
        case 0:
            currentBrush.color = kConcealerA
        case 1:
            currentBrush.color = kConcealerB
        case 2:
            currentBrush.color = kConcealerC
        case 3:
            currentBrush.color = kConcealerD
        case 4:
            currentBrush.color = kConcealerA
        case 5:
            currentBrush.color = kConcealerD
        default:
            return
        }
    }
    
    func changeBrushSizeView() {
        switch drawMode {
        case 1:
            slideBWidth.minimumValue = 0.1
            slideBWidth.maximumValue = 2
            slideBWidth.value = 1.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "1.0"
        case 2:
            slideBWidth.minimumValue = 0
            slideBWidth.maximumValue = 5
            slideBWidth.value = 2.5
            slideBWidth.isContinuous = true
            lblBrushSize.text = "2.5"
        case 4:
            slideBWidth.minimumValue = 10
            slideBWidth.maximumValue = 30
            slideBWidth.value = 20.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "20.0"
        default:
            slideBWidth.minimumValue = 0
            slideBWidth.maximumValue = 2
            slideBWidth.value = 1.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "1.0"
        }
        self.canvasView?.setBrushWidth(width: CGFloat(slideBWidth.value))
        viewBrushSize.isHidden = false
    }
    
    func saveImageEdit()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext((canvasView?.frame.size)!)
        canvasView?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            let ac = UIAlertController(title: "保存しました", message: "画像はカメラロールに保存しています", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onReset(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onComplete(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultVC {
            
            let newImage = imageWithImage(sourceImage: saveImageEdit(), scaledToWidth:768)
            
            viewController.imgEdited = newImage
            viewController.imgOriginal = UIImage(named:arrBFace[cellSelected!])
            viewController.picSelected = cellSelected
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onBrushWidthChange(_ sender: MySlider) {
        let string = String(format:"%.1f", sender.value)
        lblBrushSize.text = "\(string)"
        
        let floatNo = (string as NSString).floatValue
       
        self.canvasView?.setBrushWidth(width: CGFloat(floatNo))
    }
    
    @IBAction func onToolSelect(_ sender: UIButton) {
        if lockStatus {
            showAlert(message: "Please unlock to draw", view: self)
        } else {
            switch sender.tag {
            case 1:
              
                self.canvasView?.setDrawingMode(mode: 1)
                drawMode = 1
            case 2:
           
                self.canvasView?.setDrawingMode(mode: 4)
                drawMode = 4
            case 3:
      
                self.canvasView?.setDrawingMode(mode: 2)
                drawMode = 2
            case 4:
           
                self.canvasView?.undo()
            case 5:
            
                self.canvasView?.redo()
            default:
                return
            }
        }
        updateDrawButtonStatus()
    }
    
    @IBAction func onLock(_ sender: UIButton) {
        if lockStatus {
            btnLock.isHidden = true
            btnUnlock.isHidden = false
            lockStatus = false
            self.canvasView?.setDrawingMode(mode: 0)
        } else {
            btnLock.isHidden = false
            btnUnlock.isHidden = true
            lockStatus = true
            self.canvasView?.setDrawingMode(mode: 0)
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        UIGraphicsBeginImageContext((canvasView?.frame.size)!)
        canvasView?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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

}

//*****************************************************************
// MARK: - Canvas Delegate
//*****************************************************************

extension JBSDrawingVC: CanvasDelegate{
    
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        updateToolBarButtonStatus(canvas)
    }
    
    func updateNewColor(color: UIColor) {
        self.paletteView?.setNewColorPick(newColor: color)
    }
}

//*****************************************************************
// MARK: - Palette Delegate
//*****************************************************************

extension JBSDrawingVC: PaletteDelegate
{
    func didChangeBrushColor(_ color: UIColor) {
        currentBrush.color = color
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

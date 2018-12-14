//
//  JBSSimulationVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import NXDrawKit
import RealmSwift
import SDWebImage
import JGProgressHUD

class JBSSimulationVC: UIViewController {

    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var media = MediaData()
    var imageConverted: Data?
    
    //IBOutlet
    @IBOutlet weak var viewDrawing: UIView!
    @IBOutlet weak var viewPallet: UIView!
    @IBOutlet weak var viewColor: RoundUIView!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var viewPalletConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnPen: UIButton!
    @IBOutlet weak var btnAirBrush: UIButton!
    @IBOutlet weak var btnEraser: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewBrushSize: UIView!
    @IBOutlet weak var slideBWidth: MySlider!
    @IBOutlet weak var lblBrushSize: UILabel!
    @IBOutlet weak var btnEyeDrop: RoundButton!
    
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    var currentBrush : Brush = Brush()
    var imgSelected:UIImage? = nil
    var cellSelected:Int? = nil
    var lockStatus: Bool = false
    var airbrushSize: Float? = 0
    var penSize: Float? = 0
    var eraserSize: Float? = 0
    var drawMode: Int? = 0
    var imageOriginal: UIImage? = nil
    var image = UIImageView()
    var arrBFace = ["JBS_selectA.png","JBS_selectB.png","JBS_selectC.png","JBS_selectD.png","JBS_selectA.png"]

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
        let logo = UIImage(named: "JBS_UIkit-icon.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
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
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setupCanvas() {
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
        
        let url = URL(string: media.url)
        image.sd_setImage(with: url) { (image, error, cachetype, url) in
            if (error != nil) {
                //Failure code here
                showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                hud.dismiss()
            } else {
                //Success code here
                self.viewDrawing.translatesAutoresizingMaskIntoConstraints = false
                let canvasView = Canvas.init(canvasId: "photo", backgroundImage: image)
                canvasView.frame = CGRect(x:0,y:0, width: self.viewDrawing.frame.width, height: self.viewDrawing.frame.height)
                canvasView.delegate = self
                canvasView.clipsToBounds = true
                
                self.viewDrawing.addSubview(canvasView)
                self.canvasView = canvasView
                self.imageOriginal = self.saveImageEdit()
                
                self.currentBrush.color = self.kEyeBrowA
                
                hud.dismiss()
            }
        }
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
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 2:
            changeAirBrushColor()
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_ON.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 3:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_ON.png"), for: .normal)
        case 4:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_ON.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        case 6:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        default:
            btnPen.setImage(UIImage(named: "JBS_UIkit-design-Drow-button_OFF.png"), for: .normal)
            btnAirBrush.setImage(UIImage(named: "JBS_UIkit-design-Extinguish-button_OFF.png"), for: .normal)
            btnEraser.setImage(UIImage(named: "JBS_UIkit-design-eraser-button_OFF.png"), for: .normal)
            btnEyeDrop.setImage(UIImage(named: "JBS_UIkit-design-spoit-button_OFF.png"), for: .normal)
        }
        changeBrushSizeView()
    }
    
    func changeBrushColor() {
        viewColor.backgroundColor = currentBrush.color
    }
    
    func changeAirBrushColor() {
        currentBrush.color = kConcealerA
        viewColor.backgroundColor = currentBrush.color
    }
    
    func changeBrushSizeView() {
        
        viewBrushSize.isHidden = false
        
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
        case 3:
            viewBrushSize.isHidden = true
        default:
            slideBWidth.minimumValue = 0
            slideBWidth.maximumValue = 2
            slideBWidth.value = 1.0
            slideBWidth.isContinuous = true
            lblBrushSize.text = "1.0"
        }
        self.canvasView?.setBrushWidth(width: CGFloat(slideBWidth.value))
        
    }
    
    func saveImageEdit()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext((canvasView?.frame.size)!)
        canvasView?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func onSaveImage(image: UIImage) {
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
        
        self.imageConverted = UIImageJPEGRepresentation(image, 100)
        
        addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageConverted!, completion: { (success) in
            if success {
                hud.dismiss()
            } else {
                hud.dismiss()
                showAlert(message: "画像の保存に失敗しました。ネットワークの状態を確認してください。", view: self)
            }
        })
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
            case 6:
      
                self.canvasView?.setDrawingMode(mode: 3)
                drawMode = 3
            default:
                return
            }
        }
        updateDrawButtonStatus()
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        onSaveImage(image: saveImageEdit())
        showAlert(message: "写真を保存しました", view: self)
    }
}

//*****************************************************************
// MARK: - Canvas Delegate
//*****************************************************************

extension JBSSimulationVC: CanvasDelegate{
    
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        updateToolBarButtonStatus(canvas)
    }
    
    func updateNewColor(color: UIColor) {
        self.paletteView?.setNewColorPick(newColor: color)
        currentBrush.color = color
        viewColor.backgroundColor = color
    }
}

//*****************************************************************
// MARK: - Palette Delegate
//*****************************************************************

extension JBSSimulationVC: PaletteDelegate
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

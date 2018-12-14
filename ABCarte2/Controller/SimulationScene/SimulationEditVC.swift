//
//  SimulationEditVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/16.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import NXDrawKit
import QuartzCore

class SimulationEditVC: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewCanvasSuperview: UIView!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    var currentBrush : Brush = Brush()
    
    var currentTool : Int!
    @IBOutlet weak var colorIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
  
    //*****************************************************************
    // MARK: - Setup
    //*****************************************************************
    
    func setupUI() {
        self.navigationItem.title = "シミュレーター編集"
        currentTool = 0
        pinchGesture?.isEnabled = true
        colorIndicator.layer.borderWidth = 2.0
        colorIndicator.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
        colorIndicator.layer.cornerRadius = 5.0
        self.setupCanvas()
    }
    
    fileprivate func setupCanvas(){
        let canvasView = Canvas.init(canvasId: "photo", backgroundImage: UIImage(named:"faceorigin"))
        canvasView.frame = CGRect(x: 0, y:0, width: viewCanvasSuperview.frame.size.width, height: viewCanvasSuperview.frame.size.width)
        canvasView.delegate = self
        canvasView.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
        canvasView.layer.borderWidth = 2.0
        canvasView.layer.cornerRadius = 5.0
        canvasView.clipsToBounds = true
        
        self.viewCanvasSuperview.addSubview(canvasView)
        self.canvasView = canvasView
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("simulationEditVCOnTouch")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    fileprivate func updateToolBarButtonStatus(_ canvas: Canvas){
        btnUndo.isEnabled = canvas.canUndo()
        btnRedo.isEnabled = canvas.canRedo()
        btnSave.isEnabled = canvas.canSave()
    }
    
    @IBAction func onClickUndoButton(_ sender: UIButton) {
        self.canvasView?.undo()
    }
    
    @IBAction func onClickRedoButton(_ sender: UIButton) {
        self.canvasView?.redo()
    }
    
    @IBAction func onClickSaveButton(_ sender: UIButton) {
        self.canvasView?.save()
    }
    
    @IBAction func onClickPenButton(_ sender: UIButton) {
//        self.canvasView?.setPen()
        
        pinchGesture?.isEnabled = false
    }
    
    @IBAction func onClickBlend(_ sender: UIButton) {
//        self.canvasView?.setBlend()
        
        pinchGesture.isEnabled = true
    }
    
    @IBAction func onClickColorPicker(_ sender: UIButton) {
//        self.canvasView?.setColorPicker()
        pinchGesture.isEnabled = true
    }
    
    @IBAction func onSave(_ sender: UIButton) {
//        let vcIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
//            if let _ = viewController as? CarteSelectionVC {
//                return true
//            }
//            return false
//        })
//        
//        let composeVC = self.navigationController?.viewControllers[vcIndex!] as! CarteSelectionVC
//        
//        self.navigationController?.popToViewController(composeVC, animated: true)
    }
    
    func viewForZooming(in scrView: UIScrollView) -> UIView? {
        //canvasView?.frame = CGRect(x: 20, y:50, width: scrView.frame.width-40, height: scrView.frame.width - 40)
        return canvasView
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    open func setColorIndicator(color : UIColor){
        colorIndicator.tintColor = color
    }
    
}

extension SimulationEditVC: CanvasDelegate{
    func updateNewColor(color: UIColor) {
        
    }
    
    func returnPoints(allPoints: [CGPoint]) {
        
    }
    
    func brush() -> Brush? {
        return currentBrush
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?){
        self.updateToolBarButtonStatus(canvas)
    }
}

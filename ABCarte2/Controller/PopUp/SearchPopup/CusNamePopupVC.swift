//
//  CusNamePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol CusNamePopupVCDelegate: class {
    func onCusNameSearch(LName1:String,FName1:String,LNameKana1:String,FNameKana1:String,LName2:String,FName2:String,LNameKana2:String,FNameKana2:String,LName3:String,FName3:String,LNameKana3:String,FNameKana3:String)
}

class CusNamePopupVC: UIViewController {

    //Variable
    weak var delegate:CusNamePopupVCDelegate?
    
    //IBOutlet
    @IBOutlet weak var tfJPLName1: UITextField!
    @IBOutlet weak var tfJPFName1: UITextField!
    @IBOutlet weak var tfWLName1: UITextField!
    @IBOutlet weak var tfWFName1: UITextField!
    @IBOutlet weak var tfJPLName2: UITextField!
    @IBOutlet weak var tfJPFName2: UITextField!
    @IBOutlet weak var tfWLName2: UITextField!
    @IBOutlet weak var tfWFName2: UITextField!
    @IBOutlet weak var tfJPLName3: UITextField!
    @IBOutlet weak var tfJPFName3: UITextField!
    @IBOutlet weak var tfWLName3: UITextField!
    @IBOutlet weak var tfWFName3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        
        if (tfJPLName1.text?.isEmpty)! && (tfJPFName1.text?.isEmpty)! && (tfWLName1.text?.isEmpty)! && (tfWFName1.text?.isEmpty)! && (tfJPLName2.text?.isEmpty)! && (tfJPFName2.text?.isEmpty)! && (tfWLName2.text?.isEmpty)! && (tfWFName2.text?.isEmpty)! && (tfJPLName3.text?.isEmpty)! && (tfJPFName3.text?.isEmpty)! && (tfWLName3.text?.isEmpty)! && (tfWFName3.text?.isEmpty)! {
            showAlert(message: kALERT_INPUT_DATA, view: self)
            return
        }
    self.delegate?.onCusNameSearch(LName1:tfJPLName1.text!,FName1:tfJPFName1.text!,LNameKana1:tfWLName1.text!,FNameKana1:tfWFName1.text!,LName2:tfJPLName2.text!,FName2:tfJPFName2.text!,LNameKana2:tfWLName2.text!,FNameKana2:tfWFName2.text!,LName3:tfJPLName3.text!,FName3:tfJPFName3.text!,LNameKana3:tfWLName3.text!,FNameKana3:tfWFName3.text!)
        dismiss(animated: true, completion: nil)
    }
}

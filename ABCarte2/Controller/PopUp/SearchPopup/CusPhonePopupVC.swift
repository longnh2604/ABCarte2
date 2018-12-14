//
//  CusPhonePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/22.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol CusPhonePopupVCDelegate: class {
    func onCusPhoneSearch(phoneNo:[String])
}

class CusPhonePopupVC: UIViewController {

    //Variable
    var delegate:CusPhonePopupVCDelegate?
    
    var phoneNoSelect = [String]()
    
    //IBOutlet
    @IBOutlet weak var tfPhone1: UITextField!
    @IBOutlet weak var tfPhone2: UITextField!
    @IBOutlet weak var tfPhone3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSearch(_ sender: UIButton) {
        if tfPhone1.text != "" {
            phoneNoSelect.append(tfPhone1.text!)
        }
        if tfPhone2.text != "" {
            phoneNoSelect.append(tfPhone2.text!)
        }
        if tfPhone3.text != "" {
            phoneNoSelect.append(tfPhone3.text!)
        }
        
        self.delegate?.onCusPhoneSearch(phoneNo: phoneNoSelect)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

//
//  CustomerNoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol CustomerNoPopupVCDelegate: class {
    func onCustomerNoSearch(number:String)
}

class CustomerNoPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfCustomerNo: UITextField!
    
    //Variable
    weak var delegate:CustomerNoPopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        
        guard let text = tfCustomerNo.text else {
            return
        }
        
        if text.isEmpty {
            showAlert(message: MSG_ALERT.kALERT_INPUT_DATA, view: self)
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.onCustomerNoSearch(number: text)
        }
        
    }
}

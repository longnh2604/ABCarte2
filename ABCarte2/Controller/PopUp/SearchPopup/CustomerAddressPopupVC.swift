//
//  CustomerAddressPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol CustomerAddressPopupVCDelegate: class {
    func onCustomerAddressSearch(address:String)
}

class CustomerAddressPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfPostalCode: UITextField!
    @IBOutlet weak var tvAddress: UITextView!
    
    //Variable
    weak var delegate:CustomerAddressPopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        tvAddress.layer.cornerRadius = 10
        tvAddress.clipsToBounds = true
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPostalConvert(_ sender: UIButton) {
        guard let post = tfPostalCode.text else {
            return
        }
        
        getLocationFromPostalCode(postalCode: post) { (result, msg) in
            if result {
                self.tvAddress.text = msg
            } else {
                showAlert(message: msg, view: self)
            }
        }
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        guard let text = tvAddress.text else {
            return
        }
        
        if text.isEmpty {
            showAlert(message: kALERT_INPUT_DATA, view: self)
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.onCustomerAddressSearch(address: text)
        }
    }
}

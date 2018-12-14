//
//  PasswordInputVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol PasswordInputVCDelegate: class {
    func onPasswordInput(password:String, cusData: CustomerData)
}

class PasswordInputVC: UIViewController {

    //Variable
    weak var delegate:PasswordInputVCDelegate?
    
    var customer = CustomerData()
    
    //IBOutlet
    @IBOutlet weak var tfInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onConfirm(_ sender: UIButton) {
        
        if tfInput.text!.count > 0 {
            self.delegate?.onPasswordInput(password: tfInput.text!, cusData:customer)
            dismiss(animated: true, completion: nil)
        } else {
            showAlert(message: "パスワードを入力してください", view: self)
            return
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

//
//  AccountSettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class AccountSettingPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfCurrPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
 
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
        
        if tfCurrPassword.text == "" {
            showAlert(message: "現在のパスワードが入力されていません。", view: self)
        } else if tfNewPassword.text == "" {
            showAlert(message: "新しいパスワードが入力されていません。", view: self)
        } else if tfCurrPassword.text == tfNewPassword.text {
            showAlert(message: "同じパスワードで更新はできません。", view: self)
        } else {
            //add loading view
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            updateAccountPass(currentP: tfCurrPassword.text!, newP: tfNewPassword.text!) { (success) in
                if success {
                    showAlert(message: "シークレットメモのパスワードを更新しました。", view: self)
                } else {
                    showAlert(message: "パスワードが間違っています。正しいパスワードを入力してください。", view: self)
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  SecretMemoSettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class SecretMemoSettingPopupVC: UIViewController {

    //Variable
    var isNew: Bool?
    
    //IBOutlet
    @IBOutlet weak var tfCurrPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    
    @IBOutlet weak var heightLblCurr: NSLayoutConstraint!
    @IBOutlet weak var heightCurrentP: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if isNew == true {
//            heightLblCurr.constant = 0
//            heightCurrentP.constant = 0
//        }
    }
 
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
        
//        if isNew == true {
//            hud.show(in: self.view)
//
//            updateAccountSecretMemoPass(password: self.tfNewPassword.text!) { (success) in
//                if success {
//                    showAlert(message: "シークレットメモのパスワードを更新しました。", view: self)
//                    UserDefaults.standard.set(self.tfNewPassword.text, forKey: "secret_pass")
//                    hud.dismiss()
//                } else {
//                    showAlert(message: "シークレットメモのパスワード更新に失敗しました。", view: self)
//                    hud.dismiss()
//                }
//            }
//
//        } else {
            if tfCurrPassword.text == "" {
                showAlert(message: "現在のパスワードが入力されていません。", view: self)
            } else if tfNewPassword.text == "" {
                showAlert(message: "新しいパスワードが入力されていません。", view: self)
            } else if tfCurrPassword.text == tfNewPassword.text {
                showAlert(message: "同じパスワードで更新はできません。", view: self)
            } else {
                
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
            
                getAccessSecretMemo(password: tfCurrPassword.text!) { (success, msg) in
                    if success {
                        updateAccountSecretMemoPass(password: self.tfNewPassword.text!) { (success) in
                            if success {
                                showAlert(message: msg, view: self)
                                UserDefaults.standard.set(self.tfNewPassword.text, forKey: "secret_pass")
                            } else {
                                showAlert(message: msg, view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        showAlert(message: msg, view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            }
//        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

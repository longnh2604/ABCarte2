//
//  SecretMemoSettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import JGProgressHUD

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
        
        //add loading view
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        
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
                
                hud.show(in: self.view)
                
                getAccessSecretMemo(password: tfCurrPassword.text!) { (success) in
                    if success {
                        updateAccountSecretMemoPass(password: self.tfNewPassword.text!) { (success) in
                            if success {
                                showAlert(message: "シークレットメモのパスワードを更新しました。", view: self)
                                UserDefaults.standard.set(self.tfNewPassword.text, forKey: "secret_pass")
                                hud.dismiss()
                            } else {
                                showAlert(message: "シークレットメモのパスワード更新に失敗しました。", view: self)
                                hud.dismiss()
                            }
                        }
                    } else {
                        showAlert(message: "パスワードが間違っています。正しいパスワードを入力してください。", view: self)
                        hud.dismiss()
                    }
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

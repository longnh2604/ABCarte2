//
//  SettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/31.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import JGProgressHUD

class SettingPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tfSecretPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
    @IBAction func onSaveSetting(_ sender: UIButton) {
        if tfSecretPass.text == "" {
            showAlert(message: "シークレットメモのパスワードを設定してください。", view: self)
        } else {
            //add loading view
            let hud = JGProgressHUD(style: .dark)
            hud.vibrancyEnabled = true
            hud.textLabel.text = "LOADING"
            hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
            hud.show(in: self.view)
            
            updateAccountSecretMemoPass(password: tfSecretPass.text!) { (success) in
                if success {
                    showAlert(message: "シークレットメモのパスワードを更新しました。", view: self)
                    hud.dismiss()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    showAlert(message: "シークレットメモのパスワード更新に失敗しました。", view: self)
                    hud.dismiss()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

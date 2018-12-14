//
//  LoginVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import BarcodeScanner
import Alamofire
import SwiftyJSON
import RealmSwift
import TransitionButton

class LoginVC: UIViewController {

    //Variable
    var isLogin: Bool?
    var token: String?
    var appVersion: String?
    var iosVersion: String?
    
    // IBOutlet
    @IBOutlet weak var btnLogin: TransitionButton!
    @IBOutlet weak var btnQRLogin: TransitionButton!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lblVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        //Set login status
        isLogin = false
        
        //get App version
        appVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        lblVersion.text = "VER \(appVersion ?? "")"
        //get iOS version
        iosVersion = UIDevice.current.systemVersion
        
        //Automatic set tf value for test
        guard let status = UserDefaults.standard.string(forKey: "collectu-status") else {
            tfUsername.text = ""
            tfPassword.text = ""
            return
        }
        
        if status == "logined" {
            if let userN = UserDefaults.standard.string(forKey: "collectu-usr") {
                tfUsername.text = userN
            } else {
                tfUsername.text = ""
            }
            
            if let userP = UserDefaults.standard.string(forKey: "collectu-pwd") {
                tfPassword.text = userP
            } else {
                tfPassword.text = ""
            }
            
        } else if status == "logout" {
            if let userN = UserDefaults.standard.string(forKey: "collectu-usr") {
                tfUsername.text = userN
            } else {
                tfUsername.text = ""
            }
            
        } else {
            tfUsername.text = ""
            tfPassword.text = ""
        }
    }
    
    func goToAppSelect() {
        guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func callNumber(phoneNumber:String) {
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func confirmAgain2Login(comName:String) {
        let alert = UIAlertController(title: "ユーザー名:\(comName)でログインしてよろしいですか？", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            self.goToAppSelect()
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func stopLoginProcess(message: String,type:Int) {
        switch type {
        case 1:
            self.btnLogin.stopAnimation()
            
        case 2:
            self.btnQRLogin.stopAnimation()
        default:
            break
        }
        
        self.isLogin = false
        showAlert(message: message, view: self)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    //handle login process
    @IBAction func onLoginSelect(_ sender: TransitionButton) {
        if isLogin == false {
            isLogin = true
            sender.startAnimation()
            
            guard let appV = appVersion, let iosV = iosVersion else {
                return
            }
            
            authenticateServer(accID: tfUsername.text!, accPassword: tfPassword.text!,appVer: appV,iOSVer: iosV) { (success, msg) in
                if success {
                  
                    searchCustomers(completion: { (success) in
                        if success {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(CustomerData.self))
                            }
                            
                            getCustomers(page: 1, completion: { (success) in
                                if success {
                                    sender.stopAnimation()
                                    self.goToAppSelect()
                                } else {
                                    self.stopLoginProcess(message: kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER,type: 1)
                                }
                            })
                        } else {
                            self.stopLoginProcess(message: msg,type: 1)
                        }
                    })
                } else {
                    self.stopLoginProcess(message: msg,type: 1)
                }
            }
        }
    }
    
    //open QR View Controller
    @IBAction func onQRLoginSelect(_ sender: UIButton) {
        let controller = BarcodeScannerViewController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    //redirect to website
    @IBAction func onWebsiteSelect(_ sender: UIButton) {
        UIApplication.tryURL(urls: ["http://eyebrow.co.jp/index.html"])
    }
    
    //call by phone
    @IBAction func onFacebookSelect(_ sender: UIButton) {
        UIApplication.tryURL(urls: [
            "fb://profile/eyebrow.willbrow.ista", // App
            "https://www.facebook.com/eyebrow.willbrow.ista/" // Website if app fails
            ])
    }
    
    @IBAction func onCallSelect(_ sender: UIButton) {
        callNumber(phoneNumber: "0120357339")
    }
}

//*****************************************************************
// MARK: - Barcode Delegate
//*****************************************************************

extension LoginVC:BarcodeScannerDismissalDelegate,BarcodeScannerCodeDelegate,BarcodeScannerErrorDelegate {
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        
        if code.contains("-") {
            let delimiter = "-"
            var token = code.components(separatedBy: delimiter)
            let user = token[0]
            let pass = token[1]
            
            controller.dismiss(animated: true) {
                self.confirm2LoginbyQR(user: user, pass: pass, completion: { (success) in
                    if success {
                        guard let kaishaN = GlobalVariables.sharedManager.comName else {
                            self.confirmAgain2Login(comName: user)
                            return
                        }
                        
                        self.confirmAgain2Login(comName: kaishaN)
                    }
                })
            }
            
        } else {
            controller.dismiss(animated: true) {
                showAlert(message: "QRコードが違います", view: self)
            }
        }

    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    func confirm2LoginbyQR(user:String,pass:String,completion:@escaping(Bool) -> ()) {
            
        self.isLogin = true
        self.btnQRLogin.startAnimation()
        
        QRauthenticateServer(accID: user) { (success, msg) in
            
            if success {
             
                guard let appV = self.appVersion, let iosV = self.iosVersion else {
                    return
                }
                
                authenticateServer(accID: user, accPassword: pass,appVer: appV,iOSVer: iosV) { (success, msg) in
                    if success {
                       
                        searchCustomers(completion: { (success) in
                            if success {
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(CustomerData.self))
                                }
                                
                                getCustomers(page: 1, completion: { (success) in
                                    if success {
                                        self.btnQRLogin.stopAnimation()
                                        completion(true)
                                    } else {
                                        self.stopLoginProcess(message: kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER,type: 2)
                                        completion(false)
                                    }
                                })
                            } else {
                                self.stopLoginProcess(message: msg,type: 2)
                                completion(false)
                            }
                        })
                    } else {
                        self.stopLoginProcess(message: msg,type: 2)
                        completion(false)
                    }
                }
                
            } else {
                self.stopLoginProcess(message: msg,type: 2)
                completion(false)
            }
            
        }
    }
}

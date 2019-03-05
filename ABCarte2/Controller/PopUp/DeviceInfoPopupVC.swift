//
//  DeviceInfoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/19.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol DeviceInfoPopupVCDelegate: class {
    func onEraseDevice()
}

class DeviceInfoPopupVC: UIViewController {
    
    //Variable
    weak var delegate:DeviceInfoPopupVCDelegate?
    let network: NetworkManager = NetworkManager.sharedInstance
    
    //IBOutlet
    @IBOutlet weak var tfiPadModel: UITextField!
    @IBOutlet weak var tfiOSVer: UITextField!
    @IBOutlet weak var tfDeviceID: UITextField!
    @IBOutlet weak var imvInternetStatus: UIImageView!
    @IBOutlet weak var switchDeviceTransfer: UISwitch!
    @IBOutlet weak var lblWifiName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        let systemVersion = UIDevice.current.systemVersion
        let deviceType = UIDevice().type
        
        tfiPadModel.text = deviceType.rawValue
        
        tfiOSVer.text = systemVersion
        
        if let receivedData = KeyChain.load(key: "MyNumber") {
            let result = receivedData.to(type: Int.self)
            tfDeviceID.text = String(result)
        }
        
        do {
            try network.reachability.startNotifier()
        } catch {
            print("error connection")
        }
        network.delegate = self
        checkNetworking()
        
        lblWifiName.text = getWiFiSsid()
        
        switchDeviceTransfer.isOn = false
    }
    
    func checkNetworking() {
        NetworkManager.isUnreachable { _ in
            self.imvInternetStatus.image = UIImage(named: "icon_wifi_off_color")
        }
        NetworkManager.isReachable { _ in
            self.imvInternetStatus.image = UIImage(named: "icon_wifi_on_color")
        }
    }

    @IBAction func onClose(_ sender: Any) {
        network.reachability.stopNotifier()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDeviceTransferSelect(_ sender: UISwitch) {
        
        if sender.isOn {
            
            let alert = UIAlertController(title: "データ引継ぎを行いますか?", message: "データを引継ぐ場合は [OK] をタップして、パスワードを入力してください。自動ログアウト後に新しい iPad で attender にログインしてください。", preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: "取消", style: .default) { UIAlertAction in
                sender.isOn = false
            }
            let ok = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                //request api
                self.dismiss(animated: false, completion: {
                    self.delegate?.onEraseDevice()
                })
            }

            alert.addAction(ok)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension DeviceInfoPopupVC: NetworkManagerDelegate {
    func onNetworkStatusChange() {
        checkNetworking()
    }
}

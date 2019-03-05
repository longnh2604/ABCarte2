//
//  AppSelectVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/21.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class AppSelectVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnKarte: UIButton!
    @IBOutlet weak var btnSimulator: UIButton!
    @IBOutlet weak var btnOperation: UIButton!
    @IBOutlet weak var btnPractice: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        btnKarte.layer.cornerRadius = 10
        btnKarte.clipsToBounds = true
        btnOperation.layer.cornerRadius = 10
        btnOperation.clipsToBounds = true
        btnPractice.layer.cornerRadius = 10
        btnPractice.clipsToBounds = true
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onButtonSelect(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            guard let mainPageView =  self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? MainVC else { return }
            let navController = UINavigationController(rootViewController: mainPageView)
            navController.navigationBar.tintColor = UIColor.white
            self.present(navController, animated: true, completion: nil)
        case 1:
            showAlert(message: MSG_ALERT.kALERT_FUNCTION_UNDER_CONSTRUCTION, view: self)
        case 2:
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kJBrowOperation.rawValue) {
                guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "BookVC") as? BookVC else { return }
                let navController = UINavigationController(rootViewController: vc)
                self.present(navController, animated: true, completion: nil)
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
        case 3:
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kJBrowPractice.rawValue) {
                guard let story: UIStoryboard = UIStoryboard(name: "JBS", bundle: nil) as UIStoryboard?,
                      let vc =  story.instantiateViewController(withIdentifier: "StartingVC") as? StartingVC else { return }
                let navController = UINavigationController(rootViewController: vc)
                self.present(navController, animated: true, completion: nil)
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
        default:
            break
        }
    }
}

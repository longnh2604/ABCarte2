//
//  StartingVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StartingVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnStart: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        //set gradient navigation bar
        var colors = [UIColor]()
        colors.append(UIColor(red: 69/255, green: 13/255, blue: 1/255, alpha: 1))
        colors.append(UIColor(red: 166/255, green: 123/255, blue: 89/255, alpha: 1))
        navigationController?.navigationBar.apply(gradient: colors)
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }

    func goToMainView() {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ImageSelectVC") as? ImageSelectVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        let story: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  story.instantiateViewController(withIdentifier: "AppSelectVC") as! AppSelectVC
        self.present(vc, animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onStart(_ sender: UIButton) {
        goToMainView()
    }

}

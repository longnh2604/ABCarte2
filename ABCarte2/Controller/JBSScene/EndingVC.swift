//
//  EndingVC.swift
//  JBSDemo
//
//  Created by Long on 2018/06/01.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class EndingVC: UIViewController,UIScrollViewDelegate {

    //IBOutlet
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrView.delegate = self
        bottom.constant = 0
    }
    
    @IBAction func onFinish(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

}

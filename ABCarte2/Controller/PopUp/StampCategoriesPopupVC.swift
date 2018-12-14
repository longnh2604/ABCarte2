//
//  StampCategoriesPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/10/01.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class StampCategoriesPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var popTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        
    }

    @IBAction func onSave(_ sender: UIButton) {
    
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  ResponsiblePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol ResponsiblePopupVCDelegate: class {
    func onResponsibleSearch(responsible:String)
}

class ResponsiblePopupVC: UIViewController {
    
    //IBOutlet
    @IBOutlet weak var tfResponsible: UITextField!
    
    //Variable
    weak var delegate:ResponsiblePopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearch(_ sender: UIButton) {
        guard let text = tfResponsible.text else {
            return
        }
        
        if text.isEmpty {
            showAlert(message: kALERT_INPUT_DATA, view: self)
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.onResponsibleSearch(responsible: text)
        }
    }
}

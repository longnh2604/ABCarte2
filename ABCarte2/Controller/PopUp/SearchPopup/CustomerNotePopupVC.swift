//
//  CustomerNotePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol CustomerNotePopupVCDelegate: class {
    func onCustomerNoteSearch(note1:String,note2:String)
}

class CustomerNotePopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var tvNote1: UITextView!
    @IBOutlet weak var tvNote2: UITextView!
    
    //Variable
    weak var delegate:CustomerNotePopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        tvNote1.layer.cornerRadius = 10
        tvNote1.clipsToBounds = true
        tvNote2.layer.cornerRadius = 10
        tvNote2.clipsToBounds = true
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        if tvNote1.text.isEmpty && tvNote2.text.isEmpty {
            showAlert(message: kALERT_INPUT_DATA, view: self)
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.onCustomerNoteSearch(note1: self.tvNote1.text, note2: self.tvNote2.text)
        }
    }
}

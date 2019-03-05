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
    @IBOutlet weak var tvNote: UITextView!
    
    //Variable
    weak var delegate:CustomerNotePopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        tvNote.layer.cornerRadius = 10
        tvNote.clipsToBounds = true
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        if tvNote.text.isEmpty {
            showAlert(message: MSG_ALERT.kALERT_INPUT_DATA, view: self)
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.onCustomerNoteSearch(note1: self.tvNote.text, note2: self.tvNote.text)
        }
    }
}

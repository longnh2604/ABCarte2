//
//  GenderPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol GenderPopupVCDelegate: class {
    func onGenderSearch(gen:Int)
}

class GenderPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnGender: RoundButton!
    
    //Variable
    weak var delegate:GenderPopupVCDelegate?
    
    var genderSelect: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        self.btnGender.setTitle("末登録", for: .normal)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        guard let gen = genderSelect else {
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.onGenderSearch(gen: gen)
        }
        
    }
    
    @IBAction func onGenderSelect(_ sender: UIButton) {
        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let male = UIAlertAction(title: "男性", style: .default) { UIAlertAction in
            self.btnGender.setTitle("男性", for: .normal)
            self.genderSelect = 1
        }
        let female = UIAlertAction(title: "女性", style: .default) { UIAlertAction in
            self.btnGender.setTitle("女性", for: .normal)
            self.genderSelect = 2
        }
        let undefined = UIAlertAction(title: "不明", style: .default) { UIAlertAction in
            self.btnGender.setTitle("不明", for: .normal)
            self.genderSelect = 0
        }
        
        alert.addAction(cancel)
        alert.addAction(female)
        alert.addAction(male)
        alert.addAction(undefined)
        alert.popoverPresentationController?.sourceView = self.btnGender
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnGender.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

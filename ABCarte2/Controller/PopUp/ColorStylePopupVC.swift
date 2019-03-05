//
//  ColorStylePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/01/16.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

protocol ColorStylePopupVCDelegate: class {
    func onColorStyleChange()
}

class ColorStylePopupVC: UIViewController {

    //Variable
    var arrColorStyle = ["Collect You","J.Brow","Roman Pink","HiSul","Lavender","Pink Gold","Mysterious Night","Garden Party"]
    var arrPhotoStyle = ["color_style_0","color_style_1","color_style_2","color_style_3","color_style_4","color_style_5","color_style_6","color_style_7"]
    var indexSelect :Int = 0

    weak var delegate:ColorStylePopupVCDelegate?
    
    //IBOutlet
    @IBOutlet weak var tblColorStyle: UITableView!
    @IBOutlet weak var btnRegister: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        let nib = UINib(nibName: "ColorStyleCell", bundle: nil)
        tblColorStyle.register(nib, forCellReuseIdentifier: "ColorStyleCell")
        
        tblColorStyle.delegate = self
        tblColorStyle.dataSource = self
        tblColorStyle.layer.borderWidth = 2
        tblColorStyle.layer.borderColor = UIColor.black.cgColor
        tblColorStyle.layer.cornerRadius = 5
        
        if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            indexSelect = set
            tblColorStyle.selectRow(at: IndexPath(row: indexSelect, section: 0), animated: false, scrollPosition: .none)
        } else {
            tblColorStyle.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
        
        setButtonColorStyle(button: btnRegister, type: 1)
    }

    @IBAction func onRegister(_ sender: UIButton) {
        UserDefaults.standard.set(indexSelect, forKey: "colorset")
        dismiss(animated: true) {
            self.delegate?.onColorStyleChange()
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ColorStylePopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrColorStyle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ColorStyleCell") as? ColorStyleCell else { return UITableViewCell() }
        cell.configure(title: arrColorStyle[indexPath.row], photo: arrPhotoStyle[indexPath.row])
        if indexPath.row == indexSelect {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelect = indexPath.row
    }
    
}

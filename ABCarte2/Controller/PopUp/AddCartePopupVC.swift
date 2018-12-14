//
//  AddCartePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/04.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol AddCartePopupVCDelegate: class {
    func didAddCarte(time:Int)
}

class AddCartePopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var lblCurrDate: UILabel!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var viewPopup: UIView!
    
    //Variable
    weak var delegate:AddCartePopupVCDelegate?
    var daySelected: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        viewPopup.layer.cornerRadius = 10
        viewPopup.clipsToBounds = true
        
        let currDate = Date()
        let timeInterval = Int(currDate.timeIntervalSince1970)
        let date = convertUnixTimestamp(time: timeInterval)
        lblCurrDate.text = date + getDayOfWeek(date)!
        
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        dateTimePicker.locale = loc
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onConfirm(_ sender: UIButton) {
        if daySelected != nil {
            let time = Int((daySelected?.timeIntervalSince1970)!)
            delegate?.didAddCarte(time: time)
        } else {
            let time = Date()
            delegate?.didAddCarte(time: Int(time.timeIntervalSince1970))
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDateTimeSelect(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let strDate = dateFormatter.string(from: dateTimePicker.date)
        
        lblCurrDate.text = strDate + getDayOfWeek(strDate)!
        
        daySelected = dateTimePicker.date
    }
}

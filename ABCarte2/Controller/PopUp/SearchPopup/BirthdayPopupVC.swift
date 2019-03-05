//
//  BirthdayPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/06.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol BirthdayPopupVCDelegate: class {
    func onCustomerBirthdaySearch(date:String)
    func onCustomerBirthdayM2MSearch(month1:String,month2:String)
    func onCustomerBirthdayY2YSearch(year1:String,year2:String)
}

class BirthdayPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnYear: UIButton!
    
    @IBOutlet weak var datetimePicker: UIDatePicker!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var viewSDate: UIStackView!
    @IBOutlet weak var pickerLeft: UIPickerView!
    @IBOutlet weak var pickerRight: UIPickerView!
    
    let arrMonth = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var arrYear = [String]()
    
    var dayNo: Int = 0
    var monthNo: Int = 0
    var yearNo: Int = 0
    var dateString : String?
    var btnIndex: Int?
    var leftIndex: Int?
    var rightIndex: Int?
    
    //Variable
    weak var delegate:BirthdayPopupVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        for i in 1930 ..< 2018 {
            arrYear.append("\(i)")
        }
        
        //full birthdate
        datetimePicker.backgroundColor = UIColor.white
        datetimePicker.layer.cornerRadius = 10
        datetimePicker.clipsToBounds = true
        datetimePicker.datePickerMode = .date
        
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        datetimePicker.locale = loc
        
        dateString = "1990年 01月 01日"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年 MM月 dd日"
        let date = dateFormatter.date(from: dateString!)
        datetimePicker.setDate(date!, animated: false)
        
        btnDay.backgroundColor = COLOR_SET.kMEMO_HAS_CONTENT_COLOR
        btnIndex = 0
        
        viewDate.isHidden = true
        viewDate.backgroundColor = UIColor.white
        viewDate.layer.cornerRadius = 10
        viewDate.clipsToBounds = true
        
        pickerLeft.dataSource = self
        pickerLeft.delegate = self
        pickerLeft.tag = 1
        pickerRight.dataSource = self
        pickerRight.delegate = self
        pickerRight.tag = 2
    }
    
    func resetButtonSelect() {
        btnDay.backgroundColor = UIColor.clear
        btnMonth.backgroundColor = UIColor.clear
        btnYear.backgroundColor = UIColor.clear
        
        viewDate.isHidden = true
        datetimePicker.isHidden = true
    }
   
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearch(_ sender: UIButton) {
     
        switch btnIndex {
        case 0:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-YYYY"
            let strDate = dateFormatter.string(from: datetimePicker.date)
            
            dismiss(animated: true) {
                self.delegate?.onCustomerBirthdaySearch(date: strDate)
            }
            return
        case 1:
            guard let left = leftIndex,let right = rightIndex else { return }
            
            dismiss(animated: true) {
                self.delegate?.onCustomerBirthdayM2MSearch(month1: self.arrMonth[left], month2: self.arrMonth[right])
            }
            
            return
        case 2:
            guard let left = leftIndex,let right = rightIndex else { return }
            
            dismiss(animated: true) {
                self.delegate?.onCustomerBirthdayY2YSearch(year1: self.arrYear[left], year2: self.arrYear[right])
            }
            
            return
        default:
            break
        }
    }
    
    @IBAction func onButtonSelect(_ sender: UIButton) {
        
        resetButtonSelect()
        
        switch sender.tag {
        case 0:
            btnDay.backgroundColor = COLOR_SET.kMEMO_HAS_CONTENT_COLOR
            btnIndex = 0
            datetimePicker.isHidden = false
            return
        case 1:
            btnMonth.backgroundColor = COLOR_SET.kMEMO_HAS_CONTENT_COLOR
            btnIndex = 1
            viewDate.isHidden = false
            pickerLeft.reloadAllComponents()
            pickerRight.reloadAllComponents()
            
            pickerLeft.selectRow(5, inComponent: 0, animated: true)
            pickerRight.selectRow(5, inComponent: 0, animated: true)
            
            leftIndex = 5
            rightIndex = 5
            return
        case 2:
            btnYear.backgroundColor = COLOR_SET.kMEMO_HAS_CONTENT_COLOR
            btnIndex = 2
            viewDate.isHidden = false
            pickerLeft.reloadAllComponents()
            pickerRight.reloadAllComponents()
            
            pickerLeft.selectRow(50, inComponent: 0, animated: true)
            pickerRight.selectRow(50, inComponent: 0, animated: true)
            
            leftIndex = 50
            rightIndex = 50
            return
        default:
            break
        }
    }
    
    @IBAction func onDateTimeChange(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy年 MM月 dd日"
        let strDate = dateFormatter.string(from: datetimePicker.date)
        dateString = strDate
    }
}

extension BirthdayPopupVC: UIPickerViewDataSource,UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch btnIndex {
        case 1:
            return arrMonth.count
        case 2:
            return arrYear.count
        default:
            break
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch btnIndex {
        case 1:
            return arrMonth[row] + "月"
        case 2:
            return arrYear[row] + "年"
        default:
            break
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch btnIndex {
        case 1:
            if pickerView.tag == 1 {
                leftIndex = row
            } else {
                rightIndex = row
            }
        case 2:
            if pickerView.tag == 1 {
                leftIndex = row
            } else {
                rightIndex = row
            }
        default:
            break
        }
    }
}

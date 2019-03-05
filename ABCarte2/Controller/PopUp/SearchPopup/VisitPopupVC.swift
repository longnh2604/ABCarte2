//
//  VisitPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/22.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol VisitPopupVCDelegate: class {
    func onVisitSearch(params:String,type:Int)
}

class VisitPopupVC: UIViewController {

    //Variable
    weak var delegate:VisitPopupVCDelegate?
    
    var dateSelect: Int = 0
    var isRanged: Bool = false
    var indexSelect: Int = 0
    var searchType: Int = 1
    var specType: Int = 2
    //date
    var dateFrom1: String?
    var dateFrom2: String?
    var dateFrom3: String?
    var dateTo1: String?
    var dateTo2: String?
    var dateTo3: String?
    
    //IBOutlet
    @IBOutlet weak var btnDayVisit: RoundButton!
    @IBOutlet weak var btnLstDayVisit: RoundButton!
    @IBOutlet weak var btnFirstDayVisit: RoundButton!
    @IBOutlet weak var btnVisitInterval: RoundButton!
    @IBOutlet weak var btnDateSpec: RoundButton!
    @IBOutlet weak var btnRangeSpec: RoundButton!
    @IBOutlet weak var btnFromDate1: RoundButton!
    @IBOutlet weak var btnToDate1: RoundButton!
    @IBOutlet weak var btnFromDate2: RoundButton!
    @IBOutlet weak var btnToDate2: RoundButton!
    @IBOutlet weak var btnFromDate3: RoundButton!
    @IBOutlet weak var btnToDate3: RoundButton!
    @IBOutlet weak var charac1: UILabel!
    @IBOutlet weak var charac2: UILabel!
    @IBOutlet weak var charac3: UILabel!
    
    //interval
    @IBOutlet weak var viewYear1: UIView!
    @IBOutlet weak var viewDay1: UIView!
    @IBOutlet weak var tfYear1: UITextField!
    @IBOutlet weak var tfDay1: UITextField!
    @IBOutlet weak var viewYear2: UIView!
    @IBOutlet weak var viewDay2: UIView!
    @IBOutlet weak var tfYear2: UITextField!
    @IBOutlet weak var tfDay2: UITextField!
    @IBOutlet weak var tfYear3: UITextField!
    @IBOutlet weak var tfDay3: UITextField!
    @IBOutlet weak var viewYear3: UIView!
    @IBOutlet weak var viewDay3: UIView!
    @IBOutlet weak var view2: RoundUIView!
    @IBOutlet weak var view3: RoundUIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
   
    func setupUI() {
        btnToDate1.isHidden = false
        btnToDate2.isHidden = false
        btnToDate3.isHidden = false
        charac1.isHidden = false
        charac2.isHidden = false
        charac3.isHidden = false
        
        btnDayVisit.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
        btnRangeSpec.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
    }
    
    func removeAllTypeDate() {
        btnDayVisit.backgroundColor = UIColor.clear
        btnLstDayVisit.backgroundColor = UIColor.clear
        btnFirstDayVisit.backgroundColor = UIColor.clear
        btnVisitInterval.backgroundColor = UIColor.clear
    }
    
    func removeAllTypeSpec() {
        btnDateSpec.backgroundColor = UIColor.clear
        btnRangeSpec.backgroundColor = UIColor.clear
    }
    
    func showViewInterval(isHidden:Bool) {
        viewDay1.isHidden = isHidden
        viewDay2.isHidden = isHidden
        viewDay3.isHidden = isHidden
        viewYear1.isHidden = isHidden
        viewYear2.isHidden = isHidden
        viewYear3.isHidden = isHidden
        
        view2.isHidden = !isHidden
        view3.isHidden = !isHidden
        
        btnToDate1.isHidden = !isHidden
        btnToDate2.isHidden = !isHidden
        btnToDate3.isHidden = !isHidden
        btnFromDate1.isHidden = !isHidden
        btnFromDate2.isHidden = !isHidden
        btnFromDate3.isHidden = !isHidden
        charac1.isHidden = !isHidden
        charac2.isHidden = !isHidden
        charac3.isHidden = !isHidden
        btnDateSpec.isHidden = !isHidden
        btnRangeSpec.isHidden = !isHidden
    }
   
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSearch(_ sender: UIButton) {
        var searchParams = ""
        switch searchType {
        case 1:
            searchParams.append("?search_by_carte=true")
            switch specType {
            case 1:
                if dateFrom1 != nil {
                    searchParams.append("&carte_select_date_from_1=\(dateFrom1!)&carte_select_date_to_1=\(dateFrom1!)")
                } else {
                    searchParams.append("&carte_select_date_from_1=&carte_select_date_to_1=")
                }
                if dateFrom2 != nil {
                    searchParams.append("&carte_select_date_from_2=\(dateFrom2!)&carte_select_date_to_2=\(dateFrom2!)")
                }
                if dateFrom3 != nil {
                    searchParams.append("&carte_select_date_from_3=\(dateFrom3!)&carte_select_date_to_3=\(dateFrom3!)")
                }
                if dateFrom1 == nil && dateFrom2 == nil && dateFrom3 == nil {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_DATE, view: self)
                    return
                }
                self.delegate?.onVisitSearch(params:searchParams,type:1)
            case 2:
                //check row 1
                if dateFrom1 != nil || dateTo1 != nil {
                    if dateFrom1 != nil {
                        searchParams.append("&carte_select_date_from_1=\(dateFrom1!)")
                    } else {
                        searchParams.append("&carte_select_date_from_1=NULL")
                    }
                    if dateTo1 != nil {
                        searchParams.append("&carte_select_date_to_1=\(dateTo1!)")
                    } else {
                        searchParams.append("&carte_select_date_to_1=NULL")
                    }
                }
                
                //check row 2
                if dateFrom2 != nil || dateTo2 != nil {
                    if dateFrom2 != nil {
                        searchParams.append("&carte_select_date_from_2=\(dateFrom2!)")
                    } else {
                        searchParams.append("&carte_select_date_from_2=NULL")
                    }
                    
                    if dateTo2 != nil {
                        searchParams.append("&carte_select_date_to_2=\(dateTo2!)")
                    } else {
                        searchParams.append("&carte_select_date_to_2=NULL")
                    }
                }
                
                //check row 3
                if dateFrom3 != nil || dateTo3 != nil {
                    if dateFrom3 != nil {
                        searchParams.append("&carte_select_date_from_3=\(dateFrom3!)")
                    } else {
                        searchParams.append("&carte_select_date_from_3=NULL")
                    }
                    if dateTo3 != nil {
                        searchParams.append("&carte_select_date_to_3=\(dateTo3!)")
                    } else {
                        searchParams.append("&carte_select_date_to_3=NULL")
                    }
                }
                
                if dateFrom1 == nil && dateTo1 == nil && dateFrom2 == nil && dateTo2 == nil && dateFrom3 == nil && dateTo3 == nil {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_DATE, view: self)
                    return
                }
                
                self.delegate?.onVisitSearch(params:searchParams,type:1)
            default:
                break
            }
        case 2:
            searchParams.append("?search_by_carte=true")
            switch specType {
            case 1:
                if dateFrom1 != nil {
                    searchParams.append("&last_day_come_from_1=\(dateFrom1!)&last_day_come_to_1=\(dateFrom1!)")
                }
                if dateFrom2 != nil {
                    searchParams.append("&last_day_come_from_2=\(dateFrom2!)&last_day_come_to_2=\(dateFrom2!)")
                }
                if dateFrom3 != nil {
                    searchParams.append("&last_day_come_from_3=\(dateFrom3!)&last_day_come_to_3=\(dateFrom3!)")
                }
                if dateFrom1 == nil && dateFrom2 == nil && dateFrom3 == nil {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_DATE, view: self)
                    return
                }
                self.delegate?.onVisitSearch(params:searchParams,type: 2)
            case 2:
                //check row 1
                if dateFrom1 != nil || dateTo1 != nil {
                    if dateFrom1 != nil {
                        searchParams.append("&last_day_come_from_1=\(dateFrom1!)")
                    } else {
                        searchParams.append("&last_day_come_from_1=NULL")
                    }
                    if dateTo1 != nil {
                        searchParams.append("&last_day_come_to_1=\(dateTo1!)")
                    } else {
                        searchParams.append("&last_day_come_to_1=NULL")
                    }
                }
                
                //check row 2
                if dateFrom2 != nil || dateTo2 != nil {
                    if dateFrom2 != nil {
                        searchParams.append("&last_day_come_from_2=\(dateFrom2!)")
                    } else {
                        searchParams.append("&last_day_come_from_2=NULL")
                    }
                    if dateTo2 != nil {
                        searchParams.append("&last_day_come_to_2=\(dateTo2!)")
                    } else {
                        searchParams.append("&last_day_come_to_2=NULL")
                    }
                }
                
                //check row 3
                if dateFrom3 != nil || dateTo3 != nil {
                    if dateFrom3 != nil {
                        searchParams.append("&last_day_come_from_3=\(dateFrom3!)")
                    } else {
                        searchParams.append("&last_day_come_from_3=NULL")
                    }
                    if dateTo3 != nil {
                        searchParams.append("&last_day_come_to_3=\(dateTo3!)")
                    } else {
                        searchParams.append("&last_day_come_to_3=NULL")
                    }
                }
                
                if dateFrom1 == nil && dateTo1 == nil && dateFrom2 == nil && dateTo2 == nil && dateFrom3 == nil && dateTo3 == nil {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_DATE, view: self)
                    return
                }
                
                self.delegate?.onVisitSearch(params:searchParams,type: 2)
            default:
                break
            }
        case 3:
            searchParams.append("?search_by_carte=true")
            switch specType {
            case 1:
                if dateFrom1 != nil {
                    searchParams.append("&first_day_come_from_1=\(dateFrom1!)&first_day_come_to_1=\(dateFrom1!)")
                }
                if dateFrom2 != nil {
                    searchParams.append("&first_day_come_from_2=\(dateFrom2!)&first_day_come_to_2=\(dateFrom2!)")
                }
                if dateFrom3 != nil {
                    searchParams.append("&first_day_come_from_3=\(dateFrom3!)&first_day_come_to_3=\(dateFrom3!)")
                }
                if dateFrom1 == nil && dateFrom2 == nil && dateFrom3 == nil {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_DATE, view: self)
                    return
                }
                self.delegate?.onVisitSearch(params:searchParams,type: 2)
            case 2:
                //check row 1
                if dateFrom1 != nil || dateTo1 != nil {
                    if dateFrom1 != nil {
                        searchParams.append("&first_day_come_from_1=\(dateFrom1!)")
                    } else {
                        searchParams.append("&first_day_come_from_1=NULL")
                    }
                    if dateTo1 != nil {
                        searchParams.append("&first_day_come_to_1=\(dateTo1!)")
                    } else {
                        searchParams.append("&first_day_come_to_1=NULL")
                    }
                }
                
                //check row 2
                if dateFrom2 != nil || dateTo2 != nil {
                    if dateFrom2 != nil {
                        searchParams.append("&first_day_come_from_2=\(dateFrom2!)")
                    } else {
                        searchParams.append("&first_day_come_from_2=NULL")
                    }
                    if dateTo2 != nil {
                        searchParams.append("&first_day_come_to_2=\(dateTo2!)")
                    } else {
                        searchParams.append("&first_day_come_to_2=NULL")
                    }
                }
                
                //check row 3
                if dateFrom3 != nil || dateTo3 != nil {
                    if dateFrom3 != nil {
                        searchParams.append("&first_day_come_from_3=\(dateFrom3!)")
                    } else {
                        searchParams.append("&first_day_come_from_3=NULL")
                    }
                    if dateTo3 != nil {
                        searchParams.append("&first_day_come_to_3=\(dateTo3!)")
                    } else {
                        searchParams.append("&first_day_come_to_3=NULL")
                    }
                }
                
                if dateFrom1 == nil && dateTo1 == nil && dateFrom2 == nil && dateTo2 == nil && dateFrom3 == nil && dateTo3 == nil {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_DATE, view: self)
                    return
                }
                
                self.delegate?.onVisitSearch(params:searchParams,type: 2)
            default:
                break
            }
        case 4:
            
            if tfDay1.text == "" && tfYear1.text == "" || tfDay1.text != "" && tfYear1.text == "" || tfDay1.text == "" && tfYear1.text != "" {
                showAlert(message: MSG_ALERT.kALERT_INPUT_DATA, view: self)
                return
            } else {
                
                searchParams.append("year=\(tfYear1.text!)&day=\(tfDay1.text!)")
                self.delegate?.onVisitSearch(params: searchParams, type: 3)
            }

            //Search Frequency
//            if tfDay1.text == "" && tfDay2.text == "" && tfDay3.text == "" && tfYear1.text == "" && tfYear2.text == "" && tfYear3.text == "" {
//                showAlert(message: "Please at least enter number of day and year visit in one row", view: self)
//                return
//            }
//            if tfDay1.text == "" && tfYear1.text != "" || tfDay1.text != "" && tfYear1.text == "" {
//                showAlert(message: "Please complete input data in row 1", view: self)
//                return
//            } else {
//                if tfDay1.text == "" && tfYear1.text == "" {
//                    searchParams.append("number_carte_1=&year_1=")
//                } else {
//                    searchParams.append("number_carte_1=\(tfDay1.text!)&year_1=\(tfYear1.text!)")
//                }
//            }
//            if tfDay2.text == "" && tfYear2.text != "" || tfDay2.text != "" && tfYear2.text == "" {
//                showAlert(message: "Please complete input data in row 2", view: self)
//                return
//            } else {
//                if tfDay2.text != "" && tfYear2.text != "" {
//                    searchParams.append("&number_carte_2=\(tfDay2.text!)&year_2=\(tfYear2.text!)")
//                }
//            }
//            if tfDay3.text == "" && tfYear3.text != "" || tfDay3.text != "" && tfYear3.text == "" {
//                showAlert(message: "Please complete input data in row 3", view: self)
//                return
//            } else {
//                if tfDay3.text != "" && tfYear3.text != "" {
//                    searchParams.append("&number_carte_3=\(tfDay3.text!)&year_3=\(tfYear3.text!)")
//                }
//            }
//            self.delegate.onVisitSearch(params: searchParams, type: 3)
            break
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTypeDate(_ sender: UIButton) {
        removeAllTypeDate()
        searchType = sender.tag
        
        if sender.tag == 4 {
            lblTitle.text = "検索したい来店日を選択してください。(複数入力可)"
            showViewInterval(isHidden: false)
        } else {
            lblTitle.text = "検索したい来店日を選択してください。(複数入力可)\r\n※同時に3つまで検索できます。"
            showViewInterval(isHidden: true)
        }
        
        if sender.tag < 4 {
            if specType == 1 {
                btnToDate1.isHidden = true
                btnToDate2.isHidden = true
                btnToDate3.isHidden = true
                charac1.isHidden = true
                charac2.isHidden = true
                charac3.isHidden = true
            } else {
                btnToDate1.isHidden = false
                btnToDate2.isHidden = false
                btnToDate3.isHidden = false
                charac1.isHidden = false
                charac2.isHidden = false
                charac3.isHidden = false
            }
        }
        
  
        switch sender.tag {
        case 1:
            btnDayVisit.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
        case 2:
            btnLstDayVisit.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
        case 3:
            btnFirstDayVisit.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
        case 4:
            btnVisitInterval.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
        default:
            break
        }
    }
    
    @IBAction func onTypeSpec(_ sender: UIButton) {
        removeAllTypeSpec()
        specType = sender.tag
        switch sender.tag {
        case 1:
            btnDateSpec.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            btnToDate1.isHidden = true
            btnToDate2.isHidden = true
            btnToDate3.isHidden = true
            charac1.isHidden = true
            charac2.isHidden = true
            charac3.isHidden = true
        case 2:
            btnRangeSpec.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            btnToDate1.isHidden = false
            btnToDate2.isHidden = false
            btnToDate3.isHidden = false
            charac1.isHidden = false
            charac2.isHidden = false
            charac3.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func onDateFrom(_ sender: UIButton) {
        indexSelect = sender.tag
        
        let datePicker = UIDatePicker()//Date picker
        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 5
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        datePicker.locale = loc
        
        datePicker.addTarget(self, action: #selector(dateFromChanged(_:)), for: .valueChanged)
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let formatterServer = DateFormatter()
        formatterServer.dateFormat = "dd-MM-yyyy"
        
        switch indexSelect {
        case 1:
            btnFromDate1.setTitle(formatter.string(from: date), for: .normal)
            dateFrom1 = formatterServer.string(from: date)
        case 2:
            btnFromDate2.setTitle(formatter.string(from: date), for: .normal)
            dateFrom2 = formatterServer.string(from: date)
        case 3:
            btnFromDate3.setTitle(formatter.string(from: date), for: .normal)
            dateFrom3 = formatterServer.string(from: date)
        default:
            break
        }
    }
    
    @objc func dateFromChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let dateFormatterServer = DateFormatter()
        dateFormatterServer.dateFormat = "dd-MM-yyyy"
        
        dateSelect = Int(datePicker.date.timeIntervalSince1970)
        
        switch indexSelect {
        case 1:
            btnFromDate1.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
            dateFrom1 = dateFormatterServer.string(from: datePicker.date)
        case 2:
            btnFromDate2.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
            dateFrom2 = dateFormatterServer.string(from: datePicker.date)
        case 3:
            btnFromDate3.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
            dateFrom3 = dateFormatterServer.string(from: datePicker.date)
        default:
            break
        }
        
    }
    
    @IBAction func onDateTo(_ sender: UIButton) {
        indexSelect = sender.tag
        
        let datePicker = UIDatePicker()//Date picker
        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 5
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        datePicker.locale = loc
        datePicker.addTarget(self, action: #selector(dateToChanged(_:)), for: .valueChanged)
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let formatterServer = DateFormatter()
        formatterServer.dateFormat = "dd-MM-yyyy"
        
        switch indexSelect {
        case 1:
            btnToDate1.setTitle(formatter.string(from: date), for: .normal)
            dateTo1 = formatterServer.string(from: date)
        case 2:
            btnToDate2.setTitle(formatter.string(from: date), for: .normal)
            dateTo2 = formatterServer.string(from: date)
        case 3:
            btnToDate3.setTitle(formatter.string(from: date), for: .normal)
            dateTo3 = formatterServer.string(from: date)
        default:
            break
        }
    }
    
    @objc func dateToChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let dateFormatterServer = DateFormatter()
        dateFormatterServer.dateFormat = "dd-MM-yyyy"
        
        dateSelect = Int(datePicker.date.timeIntervalSince1970)
        
        switch indexSelect {
        case 1:
            btnToDate1.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
            dateTo1 = dateFormatterServer.string(from: datePicker.date)
        case 2:
            btnToDate2.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
            dateTo2 = dateFormatterServer.string(from: datePicker.date)
        case 3:
            btnToDate3.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
            dateTo3 = dateFormatterServer.string(from: datePicker.date)
        default:
            break
        }
    }
}

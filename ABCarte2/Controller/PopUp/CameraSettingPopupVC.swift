//
//  CameraSettingPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/19.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol CameraSettingPopupVCDelegate: class {
    func onSetCameraSetting(gridline:Int,timer:Int,gridSave:Bool,tranmissionSave:Bool,resolution:Int)
}

class CameraSettingPopupVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    //IBOutlet
    @IBOutlet weak var btnGrid: RoundButton!
    @IBOutlet weak var btnTimer: RoundButton!
    @IBOutlet weak var switchGrid: UISwitch!
    @IBOutlet weak var lblSwitchTranmission: UILabel!
    @IBOutlet weak var switchTranmission: UISwitch!
    @IBOutlet weak var segResolution: UISegmentedControl!
    
    //Variable
    weak var delegate:CameraSettingPopupVCDelegate?
    
    var gridPicker = UIPickerView()
    var timerPicker = UIPickerView()
    var gridNo: Int = 0
    var timerNo: Int = 0
    var onGridSave: Bool?
    var onTranmissionSave: Bool?
    var imgResolution: Int?
    
    let gridData = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    let timerData = ["0", "3", "5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        gridPicker.tag = 0
        timerPicker.tag = 1
        
        if onGridSave == nil {
            switchGrid.isOn = false
        } else {
            switchGrid.isOn = onGridSave!
        }
        
        if onTranmissionSave == nil {
            switchTranmission.isOn = false
        } else {
            switchTranmission.isOn = onTranmissionSave!
        }
        
        btnGrid.setTitle("\(gridNo) 本", for: .normal)
        btnTimer.setTitle("\(timerNo) 秒", for: .normal)
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPhotoResolution.rawValue) {
            setResolution(reso: imgResolution ?? 0)
            segResolution.isUserInteractionEnabled = true
        } else {
            imgResolution = 1
            setResolution(reso: imgResolution!)
            segResolution.isEnabled = false
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
            //do nothing
        } else {
            switchTranmission.isHidden = true
            lblSwitchTranmission.isHidden = true
        }
    }
    
    func setResolution(reso: Int) {
        segResolution.selectedSegmentIndex = reso
    }

    @IBAction func onGridLineSet(_ sender: UIButton) {
        gridPicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        gridPicker.delegate = self
        gridPicker.dataSource = self
        gridPicker.selectRow(gridNo, inComponent: 0, animated: true)
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(gridPicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    @IBAction func onTimerSet(_ sender: UIButton) {
        timerPicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        timerPicker.delegate = self
        timerPicker.dataSource = self
        
        if timerNo == 3 {
            timerPicker.selectRow(1, inComponent: 0, animated: true)
        } else if timerNo == 5 {
            timerPicker.selectRow(2, inComponent: 0, animated: true)
        } else {
            timerPicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(timerPicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    @IBAction func onSaveGridLine(_ sender: UISwitch) {
        if switchGrid.isOn {
            onGridSave = true
        } else {
            onGridSave = false
        }
    }
    
    @IBAction func onSaveTranmission(_ sender: UISwitch) {
        if switchTranmission.isOn {
            onTranmissionSave = true
        } else {
            onTranmissionSave = false
        }
    }
    
    @IBAction func onSaveSetting(_ sender: UIButton) {
        if onGridSave == nil {
            onGridSave = false
        }
        
        if onTranmissionSave == nil {
            onTranmissionSave = false
        }
        
        UserDefaults.standard.set(onTranmissionSave, forKey: "tranmissionIsOn")
        UserDefaults.standard.set(onGridSave, forKey: "gridIsOn")
        UserDefaults.standard.set(gridNo, forKey: "gridNo")
        UserDefaults.standard.set(timerNo, forKey: "timerNo")
        UserDefaults.standard.set(imgResolution, forKey: "imageResolution")
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kPhotoResolution.rawValue) {
            delegate?.onSetCameraSetting(gridline: gridNo, timer: timerNo,gridSave: onGridSave!,tranmissionSave: onTranmissionSave!,resolution: imgResolution ?? 0)
        } else {
            delegate?.onSetCameraSetting(gridline: gridNo, timer: timerNo,gridSave: onGridSave!,tranmissionSave: onTranmissionSave!,resolution: imgResolution ?? 1)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var number: Int = 0
        switch pickerView.tag {
            case 0:
                number = gridData.count
            case 1:
                number = timerData.count
                break
        default:
                break
        }
        return number
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var stringData: String = ""
            switch pickerView.tag {
                case 0:
                    stringData = gridData[row]
                
                case 1:
                    stringData = timerData[row]
                    
                    break
                default:
                    break
            }
        return stringData
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            let title = "\(gridData[row]) 本"
            gridNo = Int(gridData[row])!
            btnGrid.setTitle(title, for: .normal)
        case 1:
            let title = "\(timerData[row]) 秒"
            timerNo = Int(timerData[row])!
            btnTimer.setTitle(title, for: .normal)
            break
        default:
            break
        }
    }
    
    @IBAction func onResolutionChange(_ sender: UISegmentedControl) {
        imgResolution = sender.selectedSegmentIndex
    }
    
}

//
//  UserInfoPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/19.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class UserInfoPopupVC: UIViewController {

    //Variable
    var accountsData = AccountData()
    var usedGB = PieChartDataEntry(value: 0)
    var remainedGB = PieChartDataEntry(value: 0)
    var numberOfDataEntries = [PieChartDataEntry]()
    var usedGBStep = UIStepper.init()
    var remainedGBStep = UIStepper.init()
    
    //IBOutlet
    @IBOutlet weak var tfAccName: UITextField!
    @IBOutlet weak var tfAccID: UITextField!
    @IBOutlet weak var tfDayCreate: UITextField!
    @IBOutlet weak var tfFreeMemo: UITextField!
    @IBOutlet weak var tfStampMemo: UITextField!
    @IBOutlet weak var chartStorageLimit: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        updateChartData()
    }

    func setupUI() {
        tfAccName.text = accountsData.acc_name
        
        tfAccID.text = accountsData.account_id
        
        let dayCreate = convertUnixTimestamp(time: accountsData.created_at)
        tfDayCreate.text = "\(dayCreate + getDayOfWeek(dayCreate)!)"
        
        tfFreeMemo.text = String(accountsData.acc_free_memo_max)
        
        tfStampMemo.text = String(accountsData.acc_stamp_memo_max)

        chartStorageLimit.layer.cornerRadius = 10
        chartStorageLimit.clipsToBounds = true
        
        countStorage { (success) in
            if success {
                self.updateChartData()
            }
        }
    }
    
    func updateChartData()  {
        
        // 2. generate chart data entries
        let track = ["使用容量","空き容量"]
        
        guard let limit = GlobalVariables.sharedManager.limitSize,let curr = GlobalVariables.sharedManager.currentSize else { return }
        let limitGB = Double(limit) / 1_024 / 1_024 / 1_024
        let currGB = Double(curr) / 1_024 / 1_024 / 1_024
        let remainGB = limitGB - currGB
        
        let money = [currGB,remainGB]
        
        var entries = [PieChartDataEntry]()
        for (index, value) in money.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = Double(value)
            entry.label = track[index]
            entries.append( entry)
        }
        
        // 3. chart setup
        let set = PieChartDataSet( values: entries, label: "")
        // this is custom extension method. Download the code for more details.
        var colors: [UIColor] = []

        let usedColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
        let remainedColor = UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)
     
        colors.append(usedColor)
        colors.append(remainedColor)
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        chartStorageLimit.data = data
        chartStorageLimit.noDataText = "データーがない"
        // user interaction
        chartStorageLimit.isUserInteractionEnabled = false
        
        let d = Description()
//        d.text = "データー量"
        chartStorageLimit.rotationEnabled = false
        chartStorageLimit.chartDescription = d
        chartStorageLimit.centerText = "\(limitGB)GB"
        chartStorageLimit.holeRadiusPercent = 0.5
        chartStorageLimit.transparentCircleColor = UIColor.clear
        chartStorageLimit.backgroundColor = COLOR_SET.kBACKGROUND_LIGHT_GRAY
        
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  CalendarVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class CalendarVC: UIViewController {

    //Variable
    var accounts: Results<AccountData>!
    
    var customersData : [CustomerData] = []
    
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    var cartesDay: [CarteData] = []
    
    var categories: Results<StampCategoryData>!
    var categoriesData : [String] = []
  
    var dateEvents: [String] = []
    
    weak var bottomPanelView: BottomPanelView!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    //IBOutlet
    @IBOutlet weak var viewCalendar: FSCalendar!
    @IBOutlet weak var tblVisitHistory: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        setupUI()
        
        loadData()
    }
    
    func setupUI() {
        viewCalendar.delegate = self
        viewCalendar.dataSource = self
        viewCalendar.allowsMultipleSelection = false
        viewCalendar.locale = Locale(identifier: "ja")
        viewCalendar.reloadData()
        viewCalendar.reloadInputViews()
        
        //register nib
        let nib = UINib(nibName: "HistoryCell", bundle: nil)
        tblVisitHistory.register(nib, forCellReuseIdentifier: "HistoryCell")
        
        tblVisitHistory.delegate = self
        tblVisitHistory.dataSource = self
        tblVisitHistory.tableFooterView = UIView()
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        bottomPanelView = BottomPanelView.instanceFromNib(self)
        view.addSubview(bottomPanelView)
        bottomPanelView.snp.makeConstraints { (make) -> Void in
            make.height.height.equalTo(60)
            make.leading.equalTo(self.view).inset(0)
            make.trailing.equalTo(self.view).inset(0)
            make.bottom.equalTo(self.view)
        }
        bottomPanelView.btnLogout.isHidden = true
        bottomPanelView.btnSetting.isHidden = true
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadData() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //remove before get new
        cartesData.removeAll()
        
        let realm = RealmServices.shared.realm
        self.accounts = realm.objects(AccountData.self)
        
        try! realm.write {
            realm.delete(realm.objects(CarteData.self))
        }
   
        getAllCartesWithCustomerInfo(page: nil) { [unowned self] (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.cartes = realm.objects(CarteData.self)
                
                for i in 0 ..< self.cartes.count {
                    self.cartesData.append(self.cartes[i])
                    self.dateEvents.append(self.cartes[i].date_converted)
                }
                self.checkNextDay()
                self.loadCarte()
                
                //Get category title first
                onGetStampCategory { [unowned self] (success) in
                    if success {
                        //get category data
                        self.categories = realm.objects(StampCategoryData.self)
                    } else {
                        showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func checkNextDay() {
        let dateString = self.dateFormatter.string(from: Date.tomorrow)
        
        for i in 0 ..< dateEvents.count {
            if dateEvents[i] == dateString {
                var cusName = ""
                
                for j in 0 ..< cartesData.count {
                    if cartesData[j].date_converted == dateString {
                        if cusName != "" {
                            cusName.append(", ")
                        }
                        cusName.append(cartesData[j].cus[0].last_name + cartesData[j].cus[0].first_name)
                    }
                }
                sendTomorrowEvent(cus: cusName)
                return
            }
        }
    }
    
    func sendTomorrowEvent(cus: String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "来店予約"
//        content.subtitle = ""
        content.body = "明日の来店御客名は\(cus)"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "TestNotify", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func loadCarte() {
        
        let dateString = self.dateFormatter.string(from: Date())
        
        cartesDay.removeAll()
        
        for i in 0 ..< self.cartesData.count {
            if cartesData[i].date_converted == "\(dateString)" {
                cartesDay.append(cartesData[i])
            }
        }
        tblVisitHistory.reloadData()
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAddNewCarte(_ sender: UIButton) {
        
    }
}

//*****************************************************************
// MARK: - FSCalendar Delegate
//*****************************************************************

extension CalendarVC: FSCalendarDelegate, FSCalendarDataSource,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        
        if self.dateEvents.contains(dateString) {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let key = self.dateFormatter.string(from: date)
        if self.dateEvents.contains(key) {
            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let key = self.dateFormatter.string(from: date)
        return dateEvents.contains(key) ? UIImage(named: "icon_carte_color") : nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        
        #if DEBUG
        print("selected dates is \(selectedDates)")
        #endif
        
        cartesDay.removeAll()
        
        for i in 0 ..< self.cartesData.count {
            if cartesData[i].date_converted == "\(selectedDates[0])" {
                cartesDay.append(cartesData[i])
            }
        }
        tblVisitHistory.reloadData()
    }
}

//*****************************************************************
// MARK: - Tableview Delegate
//*****************************************************************

extension CalendarVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartesDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell else
        { return UITableViewCell() }
        
        let his = cartesDay[indexPath.row]
        cell.configure(data: his)
        cell.btnDetail.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//*****************************************************************
// MARK: - HistoryCell Delegate
//*****************************************************************

extension CalendarVC: HistoryCellDelegate {
    
    func onSelectDetail(index: Int) {
        print("index = \(index)")
        
        guard let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil) as UIStoryboard? else { return }
        
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "CarteMemoVC") as? CarteMemoVC {
            if let navigator = navigationController {
                viewController.customer = cartesDay[index].cus[0]
                viewController.carte = cartesDay[index]
                viewController.categories = categories
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}

//*****************************************************************
// MARK: - UserNotificationCenter Delegate
//*****************************************************************

extension CalendarVC: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
}

//*****************************************************************
// MARK: - UserNotificationCenter Delegate
//*****************************************************************

extension CalendarVC: BottomPanelViewDelegate {
    func tapSetting() {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view: self)
    }
}

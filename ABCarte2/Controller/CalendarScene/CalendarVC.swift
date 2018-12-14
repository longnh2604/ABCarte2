//
//  CalendarVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD

class CalendarVC: UIViewController {

    //Variable
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    var cartesDay: [CarteData] = []
    
    var dateEvents: [String] = []
    let hud = JGProgressHUD(style: .dark)
    
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
        
        loadData()
    }
    
    func setupUI() {
        viewCalendar.delegate = self
        viewCalendar.dataSource = self
        viewCalendar.allowsMultipleSelection = false
        viewCalendar.locale = Locale(identifier: "ja")
        viewCalendar.reloadData()
        viewCalendar.reloadInputViews()
        
        let nib = UINib(nibName: "HistoryCell", bundle: nil)
        //exam
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
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadData() {
        showLoading()
        
        //remove before get new
        cartesData.removeAll()
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CarteData.self))
        }
        
        getAllCartes(page: nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.cartes = realm.objects(CarteData.self)
                
                for i in 0 ..< self.cartes.count {
                    self.cartesData.append(self.cartes[i])
                    self.dateEvents.append(self.cartes[i].date_converted)
                }
                
                self.setupUI()
                
                self.hud.dismiss()
            } else {
                self.hud.dismiss()
                showAlert(message: "Can not get Data", view: self)
            }
        }
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

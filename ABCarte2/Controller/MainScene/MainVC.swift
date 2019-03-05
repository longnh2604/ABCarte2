//
//  MainVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import ExpyTableView
import UserNotifications

class MainVC: UIViewController {

    //Variable
    var accounts: Results<AccountData>!
    
    var customers: Results<CustomerData>!
    var customersData : [CustomerData] = []
    var customersDataSearch : [CustomerData] = []
    
    var latestExpandedSection: Int?
    var textField: UITextField?
    var indexDelete : [Int] = []
    var sortIndex: Bool = false
    var needLoad: Bool = true
    var searchActive = false
    
    weak var bottomPanelView: BottomPanelView!
    
    //IBOutlet
    @IBOutlet weak var tblMain: ExpyTableView!
    @IBOutlet weak var arrowSort: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnAddCustomer: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnShowAll: UIButton!
    @IBOutlet weak var btnCalendar: UIButton!
    @IBOutlet weak var viewPanelTop: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Alphabet Sort
    @IBOutlet weak var btnAG: UIButton!
    @IBOutlet weak var btnHN: UIButton!
    @IBOutlet weak var btnOU: UIButton!
    @IBOutlet weak var btnVZ: UIButton!
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var btnKa: UIButton!
    @IBOutlet weak var btnSa: UIButton!
    @IBOutlet weak var btnTa: UIButton!
    @IBOutlet weak var btnNa: UIButton!
    @IBOutlet weak var btnHa: UIButton!
    @IBOutlet weak var btnMa: UIButton!
    @IBOutlet weak var btnYa: UIButton!
    @IBOutlet weak var btnRa: UIButton!
    @IBOutlet weak var btnWa: UIButton!
    @IBOutlet weak var btnAll: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    func loadData() {
        if needLoad == true {
            //remove before get new
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CustomerData.self))
            }
            
            accounts = realm.objects(AccountData.self)
            
//            //new alphabet loading
//            self.navigationItem.hidesBackButton = true
//            let newBackButton = UIBarButtonItem(title: "登録件数 0件", style: UIBarButtonItemStyle.plain, target: self, action: nil)
//            self.navigationItem.rightBarButtonItem = newBackButton
//
//            GlobalVariables.sharedManager.onMultiSelect = false
//            //check alphabet index exist or not
//            if let alphabetIndex = GlobalVariables.sharedManager.alphabetIndex {
//                loadCustomersByAlphabet(index: alphabetIndex)
//            } else {
//                btnA.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
//                var alphaC : [String] = []
//                alphaC.append(contentsOf: ["あ","い","う","え","お"])
//                onSyllabarySearch(characters: alphaC)
//            }

            //previous loading
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            self.customersData.removeAll()
            
            getCustomers(page: nil) { [unowned self] (success) in
                if success {

                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)

                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }

                    if self.sortIndex {
                        self.customersData = self.customersData.sorted { (cus0: CustomerData, cus1:CustomerData) -> Bool in
                            return cus0.last_name_kana > cus1.last_name_kana
                        }
                    }
                    
                    self.tblMain.reloadData()
                    GlobalVariables.sharedManager.onMultiSelect = false

                    self.setupUI()

                    let number = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    self.navigationItem.hidesBackButton = true
                    let newBackButton = UIBarButtonItem(title: number, style: UIBarButtonItemStyle.plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem = newBackButton
                    
                    if let pageSectionTemp = GlobalVariables.sharedManager.pageSectionTemp {
                        let indexPath = IndexPath(row: 0, section: pageSectionTemp)
                        self.tblMain.collapse(pageSectionTemp)
                        self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    }
                } else {
                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    GlobalVariables.sharedManager.totalCus = 0
                    GlobalVariables.sharedManager.pageTotal = 0
                    self.updateTotalCus()
                    self.tblMain.reloadData()
                }
                self.needLoad = false
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    @objc func back(sender: UIBarButtonItem) {
        guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else { return }
        self.present(vc, animated: true, completion: nil)
    }

    func setupUI() {
        tblMain.rowHeight = UITableViewAutomaticDimension
        tblMain.estimatedRowHeight = 80

        //Alter the animations as you want
        tblMain.expandingAnimation = .fade
        tblMain.collapsingAnimation = .fade

        tblMain.tableFooterView = UIView()

        guard let navi = navigationController else { return }
        
         if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            addNavigationBarColor(navigation: navi,type: set)
        } else {
            addNavigationBarColor(navigation: navi,type: 0)
        }
        
        //set navigation bar title
        let logo = UIImage(named: "HomeNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
 
        bottomPanelView = BottomPanelView.instanceFromNib(self)
        view.addSubview(bottomPanelView)
        bottomPanelView.snp.makeConstraints { (make) -> Void in
            make.height.height.equalTo(60)
            make.leading.equalTo(self.view).inset(0)
            make.trailing.equalTo(self.view).inset(0)
            make.bottom.equalTo(self.view)
        }
        
        #if SERMENT
        bottomPanelView.btnDocument.isHidden = false
        #elseif SHISEI || AIMB
        //do nothing
        #else
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        #endif
 
        setViewColorStyle(view: viewPanelTop, type: 1)
        
        searchBar.delegate = self
        
        //design alphabet sort button
        btnAG.roundTopCorner()
        btnHN.roundTopCorner()
        btnOU.roundTopCorner()
        btnVZ.roundTopCorner()
        btnA.roundTopCorner()
        btnKa.roundTopCorner()
        btnSa.roundTopCorner()
        btnTa.roundTopCorner()
        btnNa.roundTopCorner()
        btnHa.roundTopCorner()
        btnMa.roundTopCorner()
        btnYa.roundTopCorner()
        btnRa.roundTopCorner()
        btnWa.roundTopCorner()
        btnAll.roundTopCorner()
        
        btnShowAll.isHidden = true
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCalendar.rawValue) {
            btnCalendar.isHidden = false
        } else {
            btnCalendar.isHidden = true
        }
    }
    
    func onGetAllCustomers() {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        getCustomers(page: nil) { [unowned self] (success) in
            if success {

                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)

                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }

                self.tblMain.reloadData()

                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }

    func goToCarteDetail() {
        guard let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil) as UIStoryboard?,
        let vc = storyBoard.instantiateViewController(withIdentifier: "CarteListVC") as? CarteListVC,
        let cus = customersData.count as Int?,
        let lastEx = latestExpandedSection else { return }
        
        if cus == 0 {
            showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        vc.customer = customersData[lastEx]
        
        self.navigationController?.pushViewController(vc, animated: true)
        //remove lastest
        latestExpandedSection = nil
    }

    func updateTotalCus() {
        self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
    }
    
    func loadCustomersByAlphabet(index: Int) {
        
        var alphaCharacters : [String] = []
        GlobalVariables.sharedManager.alphabetIndex = index
        
        switch index {
        case 1:
            btnA.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["あ","い","う","え","お"])
        case 2:
            btnKa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["か","き","く","け","こ"])
        case 3:
            btnSa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["さ","し","す","せ","そ"])
        case 4:
            btnTa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["た","ち","つ","て","と"])
        case 5:
            btnNa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["な","に","ぬ","ね","の"])
        case 6:
            btnHa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["は","ひ","ふ","へ","ほ"])
        case 7:
            btnMa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["ま","み","む","め","も"])
        case 8:
            btnYa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["や","ゆ","よ"])
        case 9:
            btnRa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["ら","り","る","れ","ろ"])
        case 10:
            btnWa.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["わ","を","ん"])
        case 11:
            btnAG.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["A","B","C","D","E","F","G"])
        case 12:
            btnHN.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["H","I","J","K","L","M","N"])
        case 13:
            btnOU.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["O","P","Q","R","S","T","U"])
        case 14:
            btnVZ.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            alphaCharacters.append(contentsOf: ["V","W","X","Y","Z"])
        case 15:
            btnAll.backgroundColor = COLOR_SET.kMEMO_SELECT_COLOR
            onGetAllCustomers()
            return
        default:
            break
        }
        onSyllabarySearch(characters: alphaCharacters)
    }
    
    func resetAllSetting() {
        sortIndex = false
        arrowSort.image = UIImage(named: "arrowBlackIcon")
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onAlphabetSelect(_ sender: UIButton) {
        
        //remove color button selected first
        btnA.backgroundColor = UIColor.lightGray
        btnKa.backgroundColor = UIColor.lightGray
        btnSa.backgroundColor = UIColor.lightGray
        btnTa.backgroundColor = UIColor.lightGray
        btnNa.backgroundColor = UIColor.lightGray
        btnHa.backgroundColor = UIColor.lightGray
        btnMa.backgroundColor = UIColor.lightGray
        btnYa.backgroundColor = UIColor.lightGray
        btnRa.backgroundColor = UIColor.lightGray
        btnWa.backgroundColor = UIColor.lightGray
        btnAG.backgroundColor = UIColor.lightGray
        btnHN.backgroundColor = UIColor.lightGray
        btnOU.backgroundColor = UIColor.lightGray
        btnVZ.backgroundColor = UIColor.lightGray
        btnAll.backgroundColor = UIColor.lightGray
        
        loadCustomersByAlphabet(index: sender.tag)
    }
    
    @IBAction func onAddCustomer(_ sender: UIButton) {
        NetworkManager.isUnreachable { _ in
            showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            return
        }
        NetworkManager.isReachable { _ in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
                vc.modalTransitionStyle   = .crossDissolve;
                vc.modalPresentationStyle = .overCurrentContext
                vc.popupType = PopUpType.AddNew.rawValue
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    @IBAction func onSearchSelect(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"SearchPopupVC") as? SearchPopupVC {
            vc.modalTransitionStyle   = .crossDissolve;
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func onSelectOption(_ sender: UIButton) {
        
        //check customer has exist or not
        guard let cus = customers else {
            showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        showDeleteOption(status: true)
        
        GlobalVariables.sharedManager.onMultiSelect = !GlobalVariables.sharedManager.onMultiSelect!

        tblMain.reloadData()
        for i in 0 ..< cus.count {
            let dict : [String : Any?] = ["selected_status" : 0]
            RealmServices.shared.update(customers[i], with: dict)
            self.tblMain.collapse(i)
        }
    }
    
    @IBAction func onComplete(_ sender: UIButton) {
        showDeleteOption(status: false)
        
        GlobalVariables.sharedManager.onMultiSelect = false
        latestExpandedSection = nil
        tblMain.reloadData()
        
        for i in 0 ..< customers.count {
            let dict : [String : Any?] = ["selected_status" : 0]
            RealmServices.shared.update(customers[i], with: dict)
            self.tblMain.collapse(i)
        }
    }
    
    func showDeleteOption(status:Bool) {
        btnAddCustomer.isHidden = status
        btnSelect.isHidden = status
        btnSearch.isHidden = status
        
        btnComplete.isHidden = !status
        btnDelete.isHidden = !status
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        
        for cus in self.customers.filter("selected_status = 1") {
            self.indexDelete.append(cus.id)
        }
        
        if indexDelete.count > 0 {
            let alert = UIAlertController(title: "選択しているお客様を削除しますか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                //add loading view
                SVProgressHUD.showProgress(0.3, status: "サーバーにアップロード中:30%")
                SVProgressHUD.setDefaultMaskType(.clear)
                
                self.indexDelete.removeAll()
                for cus in self.customers.filter("selected_status = 1") {
                    self.indexDelete.append(cus.id)
                }
                
                self.customersData.removeAll()
                
                deleteCustomer(ids: self.indexDelete) { (success) in
                    if success {
                      
                        GlobalVariables.sharedManager.pageCurr = 1
                        GlobalVariables.sharedManager.pageSectionTemp = nil
                        
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(CustomerData.self))
                        }
                        
                        SVProgressHUD.showProgress(0.6, status: "サーバーにアップロード中:60%")
                     
                        getCustomers(page: nil) { (success) in
                            if success {
            
                                let realm = RealmServices.shared.realm
                                self.customers = realm.objects(CustomerData.self)
                                
                                for i in 0 ..< self.customers.count {
                                    self.customersData.append(self.customers[i])
                                }
                                
                                self.tblMain.reloadData()
                                
                                self.updateTotalCus()
                            } else {
                                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                self.tblMain.reloadData()
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                        self.tblMain.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            showAlert(message: MSG_ALERT.kALERT_SELECT_CUSTOMER_2_DELETE, view: self)
        }
    }
    
    @IBAction func onShowAllRecord(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        GlobalVariables.sharedManager.pageCurr = 1
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        getCustomers(page: nil) { (success) in
            if success {

                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
                self.tblMain.reloadData()
                
                if let pageSectionTemp = GlobalVariables.sharedManager.pageSectionTemp {
                    let indexPath = IndexPath(row: 0, section: pageSectionTemp)
                    self.tblMain.collapse(pageSectionTemp)
                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                }
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            self.btnShowAll.isHidden = true
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onShowCalendar(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as? CalendarVC {
            viewController.customersData = customersData
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onNameSort(_ sender: UIButton) {
//        if sortIndex {
//            customersData = customersData.sorted { (cus0: CustomerData, cus1:CustomerData) -> Bool in
//                return cus0.last_name_kana < cus1.last_name_kana
//            }
//
//            tblMain.reloadData()
//            sortIndex = false
//            arrowSort.image = UIImage(named: "arrowBlackIcon")
//        } else {
//            customersData = customersData.sorted { (cus0: CustomerData, cus1:CustomerData) -> Bool in
//                return cus0.last_name_kana > cus1.last_name_kana
//            }
//
//            tblMain.reloadData()
//            sortIndex = true
//            arrowSort.image = UIImage(named: "arrowBlackReverseIcon")
//        }
    }
}

//*****************************************************************
// MARK: - RegCustomerPopup Delegate
//*****************************************************************

extension MainVC: RegCustomerPopupDelegate {
    
    func didConfirm(type:Int) {
        
        //add loading view
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
      
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        self.customersData.removeAll()
        
        getCustomers(page: nil) { (success) in
            if success {
                
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
                self.tblMain.reloadData()
                
                if let pageSectionTemp = GlobalVariables.sharedManager.pageSectionTemp {
                    let indexPath = IndexPath(row: 0, section: pageSectionTemp)
                    self.tblMain.collapse(pageSectionTemp)
                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                }
                self.updateTotalCus()
                self.btnShowAll.isHidden = true
            } else {
                self.tblMain.reloadData()
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - DetailCustomerCell Delegate
//*****************************************************************

extension MainVC: DetailCustomerCellDelegate {
    
    func didPressButton(type: Int) {
        switch type {
        case 1:
     
            if let vc = self.storyboard?.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
                vc.modalTransitionStyle   = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                
                guard let cus = customersData.count as Int?,
                    let lastEx = latestExpandedSection else { return }
                
                if cus == 0 {
                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
                
                vc.customer = customersData[lastEx]
                vc.popupType = PopUpType.Edit.rawValue
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        case 2:
          
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
                
                guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard?,
                    let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC,
                    let cus = customersData.count as Int? else { return }
                
                if cus == 0 {
                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
                
                vc.customer = customersData[latestExpandedSection!]
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
            
        case 3:
          
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kConsent.rawValue) {
                
                guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard?,
                    let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC,
                    let cus = customersData.count as Int? else { return }
                
                if cus == 0 {
                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
                
                vc.customer = customersData[latestExpandedSection!]
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
        case 4:
            goToCarteDetail()
        case 5:
       
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
                guard let sec = latestExpandedSection,
                    let newPopup = PasswordInputVC(nibName: "PasswordInputVC", bundle: nil) as PasswordInputVC? else { return }
   
                newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                newPopup.preferredContentSize = CGSize(width: 300, height: 150)
                newPopup.customer = customersData[sec]
                newPopup.delegate = self
                self.present(newPopup, animated: true, completion: nil)
        
            } else {
                showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
            
        default:
            break
        }
    }
    
}

//*****************************************************************
// MARK: - ExpyTableView
//*****************************************************************

//MARK: ExpyTableViewDataSourceMethods
extension MainVC: ExpyTableViewDataSource {

    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        return true
    }

    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomerCell.self)) as? CustomerCell else {
            return UITableViewCell()
        }
        
        if section < customersData.count {
            cell.layoutMargins = UIEdgeInsets.zero
            
            if searchActive {
                cell.configure(with: customersDataSearch[section])
            } else {
                cell.configure(with: customersData[section])
            }
            
            
            cell.showSeparator()
        } else {
            // Handle non-existing object here
        }

        return cell
    }
}

//MARK: ExpyTableView delegate methods
extension MainVC: ExpyTableViewDelegate {
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {

        switch state {
        case .willExpand:
            print("WILL EXPAND")

        case .willCollapse:
            print("WILL COLLAPSE")

        case .didExpand:
            print("DID EXPAND")

        case .didCollapse:
            print("DID COLLAPSE")
        }
    }
}

extension MainVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")

        GlobalVariables.sharedManager.pageSectionTemp = indexPath.section
//        GlobalVariables.sharedManager.alphabetSection = indexPath.section
        GlobalVariables.sharedManager.pageCurrTemp = GlobalVariables.sharedManager.pageCurr
        
        if ((latestExpandedSection) != nil) {
            if (latestExpandedSection != indexPath.section) {
        
                print(latestExpandedSection!)
                tblMain.collapse(latestExpandedSection!)
                latestExpandedSection = indexPath.section
                if GlobalVariables.sharedManager.onMultiSelect == true {
                    let dict : [String : Any?] = ["selected_status" : 1]
                    RealmServices.shared.update(customers[indexPath.section], with: dict)
                    tblMain.reloadData()
                }
            } else {
        
                let selected = customers[indexPath.section].selected_status
                if GlobalVariables.sharedManager.onMultiSelect == true {
                    if selected == 0 {
                        let dict : [String : Any?] = ["selected_status" : 1]
                        RealmServices.shared.update(customers[indexPath.section], with: dict)
                        tblMain.reloadData()
                    } else {
                        let dict : [String : Any?] = ["selected_status" : 0]
                        RealmServices.shared.update(customers[indexPath.section], with: dict)
                        tblMain.reloadData()
                    }
                }
            }
        } else {
    
            latestExpandedSection = indexPath.section
            
            if customers.count > 0 {
                let selected = customers[indexPath.section].selected_status
                if GlobalVariables.sharedManager.onMultiSelect == true {
                    if selected == 0 {
                        let dict : [String : Any?] = ["selected_status" : 1]
                        RealmServices.shared.update(customers[indexPath.section], with: dict)
                        tblMain.reloadData()
                    } else {
                        let dict : [String : Any?] = ["selected_status" : 0]
                        RealmServices.shared.update(customers[indexPath.section], with: dict)
                        tblMain.reloadData()
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 100
        }
        return 220
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        var number = 0
        if searchActive {
            number = customersDataSearch.count
        } else {
            number = customersData.count
        }
        return number
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows :Int = 2
        if GlobalVariables.sharedManager.onMultiSelect == true {
            rows = 1
        }

        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailCustomerCell.self)) as? DetailCustomerCell else
        { return UITableViewCell() }

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layoutMargins = UIEdgeInsets.zero
            cell.showSeparator()
            
            if searchActive {
                cell.configure(with: customersDataSearch[indexPath.section])
            } else {
                cell.configure(with: customersData[indexPath.section])
            }
            
            cell.delegate = self
            return cell
        } else {
            return cell
        }
    }
    
    //loading pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if (indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex) {
            
            if GlobalVariables.sharedManager.pageCurr! < GlobalVariables.sharedManager.pageTotal! {

                GlobalVariables.sharedManager.pageCurr! += 1

                getCustomers(page: GlobalVariables.sharedManager.pageCurr!) { (success) in
                    if success {

                        let realm = RealmServices.shared.realm
                        self.customers = realm.objects(CustomerData.self)

                        self.customersData.removeAll()
                        for i in 0 ..< self.customers.count {
                            self.customersData.append(self.customers[i])
                        }

                        self.tblMain.reloadData()

                        self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"

                    } else {
                        showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            }
        }
    }
}

//*****************************************************************
// MARK: - Search Delegate
//*****************************************************************

extension MainVC:SearchPopupVCDelegate,SyllabaryPopupVCDelegate,CusNamePopupVCDelegate,CusPhonePopupVCDelegate,VisitPopupVCDelegate,GenderPopupVCDelegate,CustomerNoPopupVCDelegate,ResponsiblePopupVCDelegate,CustomerAddressPopupVCDelegate,BirthdayPopupVCDelegate,CustomerNotePopupVCDelegate {
    
    //*****************************************************************
    // MARK: - SearchPopup Delegate
    //*****************************************************************
    
    func selectSearchType(type: Int) {
        switch type {
        #if SHISEI
        case 0:
            guard let newPopup = SyllabaryPopupVC(nibName: "SyllabaryPopupVC", bundle: nil) as SyllabaryPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 650)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 1:
            guard let newPopup = CusNamePopupVC(nibName: "CusNamePopupVC", bundle: nil) as CusNamePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 460)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 2:
            guard let newPopup = CusPhonePopupVC(nibName: "CusPhonePopupVC", bundle: nil) as CusPhonePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 440)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 3:
            guard let newPopup = GenderPopupVC(nibName: "GenderPopupVC", bundle: nil) as GenderPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 4:
            guard let newPopup = CustomerNoPopupVC(nibName: "CustomerNoPopupVC", bundle: nil) as CustomerNoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 5:
            guard let newPopup = ResponsiblePopupVC(nibName: "ResponsiblePopupVC", bundle: nil) as ResponsiblePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 6:
            guard let newPopup = CustomerAddressPopupVC(nibName: "CustomerAddressPopupVC", bundle: nil) as CustomerAddressPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 320)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 7:
            guard let newPopup = BirthdayPopupVC(nibName: "BirthdayPopupVC", bundle: nil) as BirthdayPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 380)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        default:
            break
        #else
        case 0:
            guard let newPopup = SyllabaryPopupVC(nibName: "SyllabaryPopupVC", bundle: nil) as SyllabaryPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 650)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 1:
            guard let newPopup = CusNamePopupVC(nibName: "CusNamePopupVC", bundle: nil) as CusNamePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 460)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 2:
            guard let newPopup = CusPhonePopupVC(nibName: "CusPhonePopupVC", bundle: nil) as CusPhonePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 440)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 3:
            guard let newPopup = VisitPopupVC(nibName: "VisitPopupVC", bundle: nil) as VisitPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 490)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 4:
            guard let newPopup = GenderPopupVC(nibName: "GenderPopupVC", bundle: nil) as GenderPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 5:
            guard let newPopup = CustomerNoPopupVC(nibName: "CustomerNoPopupVC", bundle: nil) as CustomerNoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 6:
            guard let newPopup = ResponsiblePopupVC(nibName: "ResponsiblePopupVC", bundle: nil) as ResponsiblePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 7:
            guard let newPopup = CustomerAddressPopupVC(nibName: "CustomerAddressPopupVC", bundle: nil) as CustomerAddressPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 320)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 8:
            guard let newPopup = BirthdayPopupVC(nibName: "BirthdayPopupVC", bundle: nil) as BirthdayPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 380)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 9:
            guard let newPopup = CustomerNotePopupVC(nibName: "CustomerNotePopupVC", bundle: nil) as CustomerNotePopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 300)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        default:
            break
        #endif
        }
    }
    
    //*****************************************************************
    // MARK: - Syllabary Popup Delegate
    //*****************************************************************
    
    func onSyllabarySearch(characters: [String]) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchSyllabary(characters: characters,page: nil) { (success) in
            if success {
       
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                self.btnShowAll.isHidden = false
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.updateTotalCus()
                self.latestExpandedSection = nil
            } else {
                showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Cus Name Popup Delegate
    //*****************************************************************
    
    func onCusNameSearch(LName1:String,FName1:String,LNameKana1:String,FNameKana1:String,LName2:String,FName2:String,LNameKana2:String,FNameKana2:String,LName3:String,FName3:String,LNameKana3:String,FNameKana3:String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchName(LName1: LName1, FName1: FName1, LNameKana1: LNameKana1, FNameKana1: FNameKana1, LName2: LName2, FName2: FName2, LNameKana2: LNameKana2, FNameKana2: FNameKana2, LName3: LName3, FName3: FName3, LNameKana3: LNameKana3, FNameKana3: FNameKana3, page: nil) { (success) in
            if success {
               
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }

//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Cus Phone Popup Delegate
    //*****************************************************************
    
    func onCusPhoneSearch(phoneNo: [String]) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchMobile(mobileNo: phoneNo, page:nil) { (success) in
            if success {
     
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - VisitPopup Delegate
    //*****************************************************************
    
    func onVisitSearch(params: String,type:Int) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        switch type {
        case 1:
            onSearchSelectedDate(params: params) { (success) in
                if success {
               
                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
        
//                    if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                        let indexPath = IndexPath(row: 0, section: alphabetSection)
//                        self.tblMain.collapse(alphabetSection)
//                        self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                    }
                    
                    self.btnShowAll.isHidden = false
                    
                    self.tblMain.reloadData()
                    self.resetAllSetting()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    self.latestExpandedSection = nil
                    
                    self.updateTotalCus()
                } else {
                    showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        case 2:
            onSearchDate(params: params,page:nil) { (success) in
                if success {
       
                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                    
//                    if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                        let indexPath = IndexPath(row: 0, section: alphabetSection)
//                        self.tblMain.collapse(alphabetSection)
//                        self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                    }
                    
                    self.btnShowAll.isHidden = false
                    
                    self.tblMain.reloadData()
                    self.resetAllSetting()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    self.latestExpandedSection = nil
                    
                    self.updateTotalCus()
                } else {
                    showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        case 3:
            onSearchInterval(params: params,page:nil) { (success) in
                if success {
    
                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                    
//                    if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                        let indexPath = IndexPath(row: 0, section: alphabetSection)
//                        self.tblMain.collapse(alphabetSection)
//                        self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                    }
                    
                    self.btnShowAll.isHidden = false
                    
                    self.tblMain.reloadData()
                    self.resetAllSetting()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    self.latestExpandedSection = nil
                    
                    self.updateTotalCus()
                } else {
                    showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                }
                SVProgressHUD.dismiss()
            }
        default:
            break
        }
    }
    
    //*****************************************************************
    // MARK: - GenderPopupVC Delegate
    //*****************************************************************
    
    func onGenderSearch(gen: Int) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchGender(gender: gen,page:nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
            
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - CustomerNo Popup Delegate
    //*****************************************************************
    
    func onCustomerNoSearch(number: String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchCustomerNumber(customerNo: number,page:nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Responsible Popup Delegate
    //*****************************************************************
    
    func onResponsibleSearch(responsible: String) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchResponsiblePerson(name: responsible,page:nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
 
    
    //*****************************************************************
    // MARK: - Responsible Popup Delegate
    //*****************************************************************
    
    func onCustomerAddressSearch(address: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchCustomerAddress(address: address, page: nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - Birthday Popup Delegate
    //*****************************************************************
    
    func onCustomerBirthdaySearch(date:String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchCustomerBirthday(day: date, page: nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func onCustomerBirthdayM2MSearch(month1: String, month2: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchCustomerBirthdayM2M(month1: month1, month2: month2, page: nil) { (success) in
            
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
            
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func onCustomerBirthdayY2YSearch(year1: String, year2: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchCustomerBirthdayY2Y(year1: year1, year2: year2, page: nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
            
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //*****************************************************************
    // MARK: - CustomerNote Popup Delegate
    //*****************************************************************
    
    func onCustomerNoteSearch(note1: String, note2: String) {
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        onSearchCustomerNote(memo1: note1, memo2: note2, page: nil) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
//                if let alphabetSection = GlobalVariables.sharedManager.alphabetSection {
//                    let indexPath = IndexPath(row: 0, section: alphabetSection)
//                    self.tblMain.collapse(alphabetSection)
//                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                }
                
                self.btnShowAll.isHidden = false
                
                self.tblMain.reloadData()
                self.resetAllSetting()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                self.latestExpandedSection = nil
                
                self.updateTotalCus()
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - SecretPopup Delegate
//*****************************************************************

extension MainVC: SecretPopupVCDelegate {
    func didCloseSecret() {
        //add loading view
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        self.customersData.removeAll()
        
        getCustomers(page: nil) { (success) in
            if success {
         
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
                if self.sortIndex {
                    self.customersData = self.customersData.sorted { (cus0: CustomerData, cus1:CustomerData) -> Bool in
                        return cus0.last_name_kana > cus1.last_name_kana
                    }
                }
                
                self.tblMain.reloadData()
                
                if let pageSectionTemp = GlobalVariables.sharedManager.pageSectionTemp {
                    let indexPath = IndexPath(row: 0, section: pageSectionTemp)
                    self.tblMain.collapse(pageSectionTemp)
                    self.tblMain.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                }
                self.updateTotalCus()
            } else {
                self.tblMain.reloadData()
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - PasswordInput Delegate
//*****************************************************************

extension MainVC: PasswordInputVCDelegate {
    func onPasswordInput(password: String, cusData:CustomerData) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        getAccessSecretMemo(password: password) { (success, msg) in
            if success {
                guard let newPopup = SecretPopupVC(nibName: "SecretPopupVC", bundle: nil) as SecretPopupVC? else { return }
                newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                newPopup.preferredContentSize = CGSize(width: 560, height: 450)
                newPopup.customer = cusData
                newPopup.authenPass = password
                newPopup.delegate = self
                self.present(newPopup, animated: true, completion: nil)
            } else {
                showAlert(message: msg, view: self)
            }
            SVProgressHUD.dismiss()
        }
    }
}

//*****************************************************************
// MARK: - DeviceInfoPopup Delegate
//*****************************************************************

extension MainVC: DeviceInfoPopupVCDelegate {
    
    func onEraseDevice() {
        
        let alert = UIAlertController(title: "", message: MSG_ALERT.kALERT_INPUT_ACCOUNT_PASSWORD, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            guard
                let text = self.textField?.text,
                let device = UserDefaults.standard.string(forKey: "mac_address"),
                let token = UserDefaults.standard.string(forKey: "token") else { return }
            
            onEraseDeviceToken(userName: self.accounts[0].account_id,userPass: text, deviceID: device,token:token, completion: { (success, msg) in
                
                if success {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                        UserDefaults.standard.set("logout", forKey: "collectu-status")
                        GlobalVariables.sharedManager.pageSectionTemp = nil
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    showAlert(message: msg, view: self)
                }
                SVProgressHUD.dismiss()
            })
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler:nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "入力して下さい";
        }
    }
}

//*****************************************************************
// MARK: - BottomPanelView Delegate
//*****************************************************************

extension MainVC: BottomPanelViewDelegate {
    
    func tapInfo() {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view:self)
    }
    
    func tapLogout() {
        UserDefaults.standard.set("logout", forKey: "collectu-status")
        GlobalVariables.sharedManager.pageSectionTemp = nil
        GlobalVariables.sharedManager.alphabetIndex = nil
        GlobalVariables.sharedManager.pageCurrTemp = nil
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
       
        self.present(vc, animated: true, completion: nil)
    }
    
    func tapSetting() {
        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        //user
        let user = UIAlertAction(title: "ユーザー情報", style: .default) { UIAlertAction in
            guard let newPopup = UserInfoPopupVC(nibName: "UserInfoPopupVC", bundle: nil) as UserInfoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 600)
            newPopup.accountsData = self.accounts[0]
            self.present(newPopup, animated: true, completion: nil)
        }
        
        //device
        let device = UIAlertAction(title: "デバイス情報", style: .default) { UIAlertAction in
            guard let newPopup = DeviceInfoPopupVC(nibName: "DeviceInfoPopupVC", bundle: nil) as DeviceInfoPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 400)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        }
        
        //secret
        let secret = UIAlertAction(title: "シークレット設定", style: .default) { UIAlertAction in
            guard let newPopup = SecretMemoSettingPopupVC(nibName: "SecretMemoSettingPopupVC", bundle: nil) as SecretMemoSettingPopupVC? else { return }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 380, height: 280)
            
            let secretP = UserDefaults.standard.string(forKey: "secret_pass")
            
            if secretP == "" {
                newPopup.isNew = true
            } else {
                newPopup.isNew = false
            }
            
            self.present(newPopup, animated: true, completion: nil)
        }

        //color style
//        let colorStyle = UIAlertAction(title: "色スタイル設定", style: .default) { UIAlertAction in
//            guard let newPopup = ColorStylePopupVC(nibName: "ColorStylePopupVC", bundle: nil) as ColorStylePopupVC? else { return }
//            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
//            newPopup.preferredContentSize = CGSize(width: 380, height: 500)
//            newPopup.delegate = self
//            self.present(newPopup, animated: true, completion: nil)
//        }
        
        alert.addAction(user)
        alert.addAction(device)
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            alert.addAction(secret)
        }
        
//        alert.addAction(colorStyle)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tapDocument() {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "BookVC") as? BookVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
//        if let viewController = storyboard?.instantiateViewController(withIdentifier: "BookCollectionVC") as? BookCollectionVC {
//            if let navigator = navigationController {
//                navigator.pushViewController(viewController, animated: true)
//            }
//        }
    }
}

//*****************************************************************
// MARK: - ColorStylePopup Delegate
//*****************************************************************

extension MainVC: ColorStylePopupVCDelegate {
    func onColorStyleChange() {
        
        self.tblMain.reloadData()
        GlobalVariables.sharedManager.onMultiSelect = false
        
        for i in 0 ..< self.customersData.count {
            self.tblMain.collapse(i)
        }
        
        setupUI()
    }
}

//*****************************************************************
// MARK: - SearchBar Delegate
//*****************************************************************

extension MainVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty  else { searchActive = false; tblMain.reloadData(); return }
        
        customersDataSearch = customersData.filter({ customer -> Bool in
            return customer.first_name_kana.lowercased().contains(searchText.lowercased())
        })
        
        if(customersDataSearch.count == 0){
            searchActive = false
        } else {
            searchActive = true
        }
        tblMain.reloadData()
    }
}

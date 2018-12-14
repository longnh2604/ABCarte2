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
import JGProgressHUD
import ExpyTableView

class MainVC: UIViewController {

    //Variable
    var accounts: Results<AccountData>!
    
    var customers: Results<CustomerData>!
    var customersData : [CustomerData] = []
    
    var latestExpandedSection: Int?
    var textField: UITextField?
    var indexDelete : [Int] = []
    var sortIndex: Bool = false
    var needLoad: Bool = true
    let hud = JGProgressHUD(style: .dark)
    
    //IBOutlet
    @IBOutlet weak var btnHelp: RoundButton!
    @IBOutlet weak var tblMain: ExpyTableView!
    @IBOutlet weak var arrowSort: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnAddCustomer: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnShowAll: UIButton!
    @IBOutlet weak var btnCalendar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func loadData() {
        if needLoad == true {
            //remove before get new
            customersData.removeAll()
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CustomerData.self))
            }
            
            accounts = realm.objects(AccountData.self)
            
            showLoading()
            
            getCustomers(page: 1) { [unowned self] (success) in
                if success {
          
                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                    
                    self.tblMain.reloadData()
                    GlobalVariables.sharedManager.onMultiSelect = false
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    self.setupUI()
                    
                    let number = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    self.navigationItem.hidesBackButton = true
                    let newBackButton = UIBarButtonItem(title: number, style: UIBarButtonItemStyle.plain, target: self, action: nil)
                    self.navigationItem.rightBarButtonItem = newBackButton
                    
                    self.hud.dismiss()
                    
                } else {
    
                    showAlert(message: kALERT_CANT_GET_ACCOUNT_INFO_PLEASE_CONTACT_SUPPORTER, view: self)
                    self.hud.dismiss()
                }
            }
            
            needLoad = false
        }
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        setupUI()
    }
    
    @objc func back(sender: UIBarButtonItem) {
        guard let vc =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }

    func setupUI() {
        tblMain.rowHeight = UITableViewAutomaticDimension
        tblMain.estimatedRowHeight = 80

        //Alter the animations as you want
        tblMain.expandingAnimation = .fade
        tblMain.collapsingAnimation = .fade

        tblMain.tableFooterView = UIView()

        //set gradient navigation bar
        var colors = [UIColor]()
        colors.append(UIColor(red: 69/255, green: 13/255, blue: 1/255, alpha: 1))
        colors.append(UIColor(red: 166/255, green: 123/255, blue: 89/255, alpha: 1))
        navigationController?.navigationBar.apply(gradient: colors)

        //set navigation bar title
        let logo = UIImage(named: "HomeNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }

    func goToCarteDetail() {
        guard let storyBoard: UIStoryboard = UIStoryboard(name: "Carte", bundle: nil) as UIStoryboard? else {
            return
        }
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "CarteListVC") as? CarteListVC else {
            return
        }
        
        guard let cus = customers.count as Int? else {
            return
        }
        
        if cus == 0 {
            showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        vc.customer = customers[latestExpandedSection!]
        
        self.navigationController?.pushViewController(vc, animated: true)
        //remove lastest
        latestExpandedSection = nil
    }

    func updateTotalCus() {
        self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onLogoutSelect(_ sender: UIButton) {
        UserDefaults.standard.set("logout", forKey: "collectu-status")
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func onSettingSelect(_ sender: UIButton) {
        
        
        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let secret = UIAlertAction(title: "シークレット設定", style: .default) { UIAlertAction in
            guard let newPopup = SecretMemoSettingPopupVC(nibName: "SecretMemoSettingPopupVC", bundle: nil) as SecretMemoSettingPopupVC? else {
                return
            }
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
        let user = UIAlertAction(title: "ユーザー情報", style: .default) { UIAlertAction in
            guard let newPopup = UserInfoPopupVC(nibName: "UserInfoPopupVC", bundle: nil) as UserInfoPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 350)
            newPopup.accountsData = self.accounts[0]
            self.present(newPopup, animated: true, completion: nil)
        }
        
        let device = UIAlertAction(title: "デバイス情報", style: .default) { UIAlertAction in
            guard let newPopup = DeviceInfoPopupVC(nibName: "DeviceInfoPopupVC", bundle: nil) as DeviceInfoPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 400)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        }
        alert.addAction(user)
        alert.addAction(device)
        alert.addAction(secret)
        alert.addAction(cancel)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func onHelpSelect(_ sender: UIButton) {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view:self)
    }

    @IBAction func onAddCustomer(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
            vc.modalTransitionStyle   = .crossDissolve;
            vc.modalPresentationStyle = .overCurrentContext
            vc.popupType = PopUpType.AddNew.rawValue
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
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
            showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
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
                self.showLoading()
                
                self.indexDelete.removeAll()
                for cus in self.customers.filter("selected_status = 1") {
                    self.indexDelete.append(cus.id)
                }
                
                deleteCustomer(ids: self.indexDelete) { (success) in
                    if success {
                      
                        GlobalVariables.sharedManager.pageCurr = 1
                        
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(CustomerData.self))
                        }
                        
                        getCustomers(page: 1) { (success) in
                            if success {
            
                                let realm = RealmServices.shared.realm
                                self.customers = realm.objects(CustomerData.self)
                                
                                self.customersData.removeAll()
                                for i in 0 ..< self.customers.count {
                                    self.customersData.append(self.customers[i])
                                }
                                
                                self.tblMain.reloadData()
                                
                                for i in 0 ..< self.customers.count {
                                    self.tblMain.collapse(i)
                                }
                                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                                
                                self.hud.dismiss()
                            } else {
                                self.hud.dismiss()
    
                                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                        }
                    } else {
        
                        self.hud.dismiss()
                        showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            showAlert(message: kALERT_SELECT_CUSTOMER_2_DELETE, view: self)
        }
    }
    
    @IBAction func onShowAllRecord(_ sender: UIButton) {
        showLoading()
        
        GlobalVariables.sharedManager.pageCurr = 1
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        getCustomers(page: 1) { (success) in
            if success {

                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customers.count {
                    self.tblMain.collapse(i)
                }
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.hud.dismiss()
            } else {
          
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                self.hud.dismiss()
            }
        }
        
        btnShowAll.isHidden = true
    }
    
    @IBAction func onShowCalendar(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as? CalendarVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}

//*****************************************************************
// MARK: - RegCustomerPopup Delegate
//*****************************************************************

extension MainVC: RegCustomerPopupDelegate {
    
    func didConfirm(type:Int) {
        
        //add loading view
        showLoading()
        
        switch type {
        case 1:
  
            GlobalVariables.sharedManager.pageCurr = 1
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CustomerData.self))
            }
            
            getCustomers(page: 1) { (success) in
                if success {
            
                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    
                    self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    
                    self.hud.dismiss()
                } else {
            
                    showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                }
            }
            break
        case 2:
    
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CustomerData.self))
            }
            
            getCustomers(page: 1) { (success) in
                if success {
              
                    let realm = RealmServices.shared.realm
                    self.customers = realm.objects(CustomerData.self)
                    
                    self.customersData.removeAll()
                    for i in 0 ..< self.customers.count {
                        self.customersData.append(self.customers[i])
                    }
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    
                    self.hud.dismiss()
                } else {
            
                    showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                }
            }
            
            break
        default:
            break
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
                
                guard let cus = customers.count as Int? else {
                    return
                }
                
                if cus == 0 {
                    showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
                
                vc.customer = customers[latestExpandedSection!]
                
                vc.popupType = PopUpType.Edit.rawValue
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        case 2:
          
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
                
                guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else {
                    return
                }
                
                guard let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC else {
                    return
                }
                
                guard let cus = customers.count as Int? else {
                    return
                }
                
                if cus == 0 {
                    showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
                
                vc.customer = customers[latestExpandedSection!]
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
            
        case 3:
          
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kConsent.rawValue) {
                
                guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else {
                    return
                }
                
                guard let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC else {
                    return
                }
             
                guard let cus = customers.count as Int? else {
                    return
                }
                
                if cus == 0 {
                    showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                    return
                }
                
                vc.customer = customers[latestExpandedSection!]
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
        case 4:
 
            goToCarteDetail()
        case 5:
       
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
                guard let sec = latestExpandedSection else {
                    return
                }
   
                guard let newPopup = PasswordInputVC(nibName: "PasswordInputVC", bundle: nil) as PasswordInputVC? else {
                    return
                }
                newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                newPopup.preferredContentSize = CGSize(width: 300, height: 150)
                newPopup.customer = customers[sec]
                newPopup.delegate = self
                self.present(newPopup, animated: true, completion: nil)
        
            } else {
                showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
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
            cell.configure(with: customersData[section])
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 100
        }
        return 220
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return customersData.count
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
            cell.configure(with: customersData[indexPath.section])
            cell.delegate = self
            return cell
        } else {
            return cell
        }
    }
    
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
                        
                        for i in 0 ..< self.customersData.count {
                            self.tblMain.collapse(i)
                        }
                        self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                        
                    } else {
                
                        showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
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
        case 0:
            guard let newPopup = SyllabaryPopupVC(nibName: "SyllabaryPopupVC", bundle: nil) as SyllabaryPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 650)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 1:
            guard let newPopup = CusNamePopupVC(nibName: "CusNamePopupVC", bundle: nil) as CusNamePopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 460)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 2:
            guard let newPopup = CusPhonePopupVC(nibName: "CusPhonePopupVC", bundle: nil) as CusPhonePopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 440)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 3:
            guard let newPopup = VisitPopupVC(nibName: "VisitPopupVC", bundle: nil) as VisitPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 620, height: 490)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 4:
            guard let newPopup = GenderPopupVC(nibName: "GenderPopupVC", bundle: nil) as GenderPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 5:
            guard let newPopup = CustomerNoPopupVC(nibName: "CustomerNoPopupVC", bundle: nil) as CustomerNoPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 6:
            guard let newPopup = ResponsiblePopupVC(nibName: "ResponsiblePopupVC", bundle: nil) as ResponsiblePopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 200)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 7:
            guard let newPopup = CustomerAddressPopupVC(nibName: "CustomerAddressPopupVC", bundle: nil) as CustomerAddressPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 320)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 8:
            guard let newPopup = BirthdayPopupVC(nibName: "BirthdayPopupVC", bundle: nil) as BirthdayPopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 400, height: 380)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        case 9:
            guard let newPopup = CustomerNotePopupVC(nibName: "CustomerNotePopupVC", bundle: nil) as CustomerNotePopupVC? else {
                return
            }
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 500, height: 400)
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    //*****************************************************************
    // MARK: - Syllabary Popup Delegate
    //*****************************************************************
    
    func onSyllabarySearch(characters: [String]) {
        
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
                
            } else {
         
                showAlert(message: kALERT_SEARCH_RESULTS_NOTHING, view: self)
                self.hud.dismiss()
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
            }
        }
        latestExpandedSection = nil
    }
    
    //*****************************************************************
    // MARK: - Cus Name Popup Delegate
    //*****************************************************************
    
    func onCusNameSearch(LName1:String,FName1:String,LNameKana1:String,FNameKana1:String,LName2:String,FName2:String,LNameKana2:String,FNameKana2:String,LName3:String,FName3:String,LNameKana3:String,FNameKana3:String) {
        
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
     
            } else {
     
                showAlert(message: kALERT_SEARCH_RESULTS_NOTHING, view: self)
                self.hud.dismiss()
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
            }
        }
        latestExpandedSection = nil
    }
    
    //*****************************************************************
    // MARK: - Cus Phone Popup Delegate
    //*****************************************************************
    
    func onCusPhoneSearch(phoneNo: [String]) {
        
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
            } else {
      
                showAlert(message: kALERT_SEARCH_RESULTS_NOTHING, view: self)
                self.hud.dismiss()
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
            }
        }
        latestExpandedSection = nil
    }
    
    //*****************************************************************
    // MARK: - VisitPopup Delegate
    //*****************************************************************
    
    func onVisitSearch(params: String,type:Int) {
        
        showLoading()
        
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
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    
                    self.navigationItem.rightBarButtonItem?.title = "登録件数 \(self.customersData.count)件"
                    //self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    
                    self.btnShowAll.isHidden = false
                    self.hud.dismiss()
                    
                } else {
               
                    showAlert(message: kALERT_SEARCH_RESULTS_NOTHING, view: self)
                    self.hud.dismiss()
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                }
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
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    
                    self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    
                    self.btnShowAll.isHidden = false
                    self.hud.dismiss()
                    
                } else {
        
                    showAlert(message: kALERT_SEARCH_RESULTS_NOTHING, view: self)
                    self.hud.dismiss()
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                }
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
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                    
                    self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                    
                    self.btnShowAll.isHidden = false
                    self.hud.dismiss()
              
                } else {
  
                    showAlert(message: kALERT_SEARCH_RESULTS_NOTHING, view: self)
                    self.hud.dismiss()
                    
                    self.tblMain.reloadData()
                    
                    for i in 0 ..< self.customersData.count {
                        self.tblMain.collapse(i)
                    }
                }
            }
        default:
            break
        }
        
        latestExpandedSection = nil
    }
    
    //*****************************************************************
    // MARK: - GenderPopupVC Delegate
    //*****************************************************************
    
    func onGenderSearch(gen: Int) {
        
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
                
            } else {
                self.hud.dismiss()
  
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - CustomerNo Popup Delegate
    //*****************************************************************
    
    func onCustomerNoSearch(number: String) {
        
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
                
            } else {
                self.hud.dismiss()
     
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - Responsible Popup Delegate
    //*****************************************************************
    
    func onResponsibleSearch(responsible: String) {
        
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
                
            } else {
                self.hud.dismiss()
    
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
 
    
    //*****************************************************************
    // MARK: - Responsible Popup Delegate
    //*****************************************************************
    
    func onCustomerAddressSearch(address: String) {
   
    }
    
    //*****************************************************************
    // MARK: - Birthday Popup Delegate
    //*****************************************************************
    
    func onCustomerBirthdaySearch(date:String) {
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
                
            } else {
                self.hud.dismiss()
                
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
    
    //*****************************************************************
    // MARK: - CustomerNote Popup Delegate
    //*****************************************************************
    
    func onCustomerNoteSearch(note1: String, note2: String) {
        showLoading()
        
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
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customersData.count {
                    self.tblMain.collapse(i)
                }
                
                self.navigationItem.rightBarButtonItem?.title = "登録件数 \(String(GlobalVariables.sharedManager.totalCus!))件"
                
                self.btnShowAll.isHidden = false
                self.hud.dismiss()
                
            } else {
                self.hud.dismiss()
                
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
}

//*****************************************************************
// MARK: - SecretPopup Delegate
//*****************************************************************

extension MainVC: SecretPopupVCDelegate {
    func didCloseSecret() {
        //add loading view
        showLoading()
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomerData.self))
        }
        
        getCustomers(page: 1) { (success) in
            if success {
         
                let realm = RealmServices.shared.realm
                self.customers = realm.objects(CustomerData.self)
                
                self.customersData.removeAll()
                for i in 0 ..< self.customers.count {
                    self.customersData.append(self.customers[i])
                }
                
                self.tblMain.reloadData()
                
                for i in 0 ..< self.customers.count {
                    self.tblMain.collapse(i)
                }
                self.hud.dismiss()
            } else {
                self.hud.dismiss()
     
                showAlert(message: kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
        }
    }
}

//*****************************************************************
// MARK: - PasswordInput Delegate
//*****************************************************************

extension MainVC: PasswordInputVCDelegate {
    func onPasswordInput(password: String, cusData:CustomerData) {
        
        showLoading()
        
        getAccessSecretMemo(password: password) { (success) in
            if success {
                guard let newPopup = SecretPopupVC(nibName: "SecretPopupVC", bundle: nil) as SecretPopupVC? else {
                    return
                }
                newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                newPopup.preferredContentSize = CGSize(width: 560, height: 450)
                newPopup.customer = cusData
                newPopup.authenPass = password
                newPopup.delegate = self
                self.present(newPopup, animated: true, completion: nil)
                self.hud.dismiss()
            } else {
                showAlert(message: kALERT_WRONG_PASSWORD, view: self)
                self.hud.dismiss()
            }
        }
    }
}

//*****************************************************************
// MARK: - DeviceInfoPopup Delegate
//*****************************************************************

extension MainVC: DeviceInfoPopupVCDelegate {
    
    func onEraseDevice() {
        
        let alert = UIAlertController(title: "", message: kALERT_INPUT_ACCOUNT_PASSWORD, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            
            self.showLoading()
            
            guard
                let text = self.textField?.text,
                let device = UserDefaults.standard.string(forKey: "mac_address"),
                let token = UserDefaults.standard.string(forKey: "token")
            else {
                return
            }
            
            onEraseDeviceToken(userName: self.accounts[0].account_id,userPass: text, deviceID: device,token:token, completion: { (success, msg) in
                
                self.hud.dismiss()
                if success {
                    guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else {
                        return
                    }
                    
                    UserDefaults.standard.set("logout", forKey: "collectu-status")
                    
                    self.present(vc, animated: true, completion: nil)
                } else {
                    showAlert(message: msg, view: self)
                    return
                }
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

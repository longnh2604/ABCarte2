//
//  CarteListVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/10.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SDWebImage
import JGProgressHUD

class CarteListVC: UIViewController {
    
    //Variable
    var needLoad: Bool = true
    
    var customer = CustomerData()
    
    var accounts: Results<AccountData>!
    
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    
    var categories: Results<StampCategoryData>!
    var categoriesData : [String] = []
    
    var indexDelete : [Int] = []
    var selectedIndexPath: NSIndexPath?
    let hud = JGProgressHUD(style: .dark)
    
    //IBOutlet
    @IBOutlet weak var tblCarte: UITableView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var imvCusTop: UIImageView!
    @IBOutlet weak var imvCustomer: UIImageView!
    @IBOutlet weak var lblCusGender: UILabel!
    @IBOutlet weak var lblCusNo: UILabel!
    @IBOutlet weak var lblLastCome: UILabel!
    @IBOutlet weak var lblFirstCome: UILabel!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblBirthdate: UILabel!
    @IBOutlet weak var lblBloodtype: UILabel!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnAddCarte: UIButton!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnMemo1: RoundButton!
    @IBOutlet weak var btnMemo2: RoundButton!
    @IBOutlet weak var btnSecret: RoundButton!
    @IBOutlet weak var lblLastComeTop: UILabel!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var imv_lock_memo_secret: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }

    func loadData() {
        if needLoad == true {
            //add loading view
            showLoading()
            
            //remove before get new
            cartesData.removeAll()
            
            let realm = RealmServices.shared.realm
            self.accounts = realm.objects(AccountData.self)
            
            //Get category title first
            onGetStampCategory { [unowned self] (success) in
                if success {
                    
                    //get category data
                    let realm = RealmServices.shared.realm
                    self.categories = realm.objects(StampCategoryData.self)
                    
                    self.categoriesData.removeAll()
                    
                    for i in 0 ..< self.categories.count {
                        self.categoriesData.append(self.categories[i].title)
                    }
                    
                    try! realm.write {
                        realm.delete(realm.objects(CarteData.self))
                    }
                    
                    getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                        if success {
                    
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            for i in 0 ..< self.cartes.count {
                                self.cartesData.append(self.cartes[i])
                            }
                            
                            self.tblCarte.reloadData()
                            
                            self.hud.dismiss()
                        } else {
                    
                            showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                            self.hud.dismiss()
                        }
                    }
                    
                } else {
                    showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                }
            }
            needLoad = false
        }
    }

    func updateDateTime() {
        var maxDay = cartesData.map { $0.select_date }.max()
        var minDay = cartesData.map { $0.select_date }.min()

        if maxDay == nil {
            maxDay = 0
        }
        if minDay == nil {
            minDay = 0
        }
        let dict : [String : Any?] = ["cusLstCome" : maxDay,
                                      "cusFirstCome" : minDay]
        RealmServices.shared.update(customer, with: dict)
    }

    func setupUI() {
        //set navigation bar title
        let logo = UIImage(named: "CarteNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton

        btnHelp.layer.cornerRadius = 15
        btnHelp.clipsToBounds = true
        viewGender.layer.cornerRadius = 5
        viewGender.clipsToBounds = true
        viewTop.layer.cornerRadius = 5
        viewTop.clipsToBounds = true

        tblCarte.delegate = self
        tblCarte.dataSource = self
        tblCarte.allowsMultipleSelection = false
        tblCarte.allowsSelection = true

        updateTopView()
    }

    func updateTopView() {
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCusTop.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
            
            imvCustomer.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvCustomer.image = UIImage(named: "nophotoIcon")
            imvCusTop.image = UIImage(named: "nophotoIcon")
        }
        
        imvCusTop.layer.cornerRadius = 25
        imvCusTop.clipsToBounds = true
        lblCusName.text = customer.last_name + " " + customer.first_name
        
        if customer.gender == 0 {
            lblCusGender.text = "不明"
            viewGender.backgroundColor = UIColor.lightGray
        } else if customer.gender == 1 {
            lblCusGender.text = "男性"
            viewGender.backgroundColor = kMALE_COLOR
        } else {
            lblCusGender.text = "女性"
            viewGender.backgroundColor = kFEMALE_COLOR
        }

        lblCusNo.text = customer.customer_no
        lblHobby.text = customer.hobby
        lblMobile.text = customer.urgent_no
        
        if customer.birthday != 0 {
            let birthday = convertUnixTimestamp(time: customer.birthday)
            lblBirthdate.text = birthday
        } else {
            lblBirthdate.text = ""
        }
        
        lblBloodtype.text = checkBloodType(type: customer.bloodtype)
        
        if customer.last_daycome != 0 {
            let ldayCome = convertUnixTimestamp(time: customer.last_daycome)
            lblLastCome.text = ldayCome + getDayOfWeek(ldayCome)!
            lblLastComeTop.text = ldayCome + getDayOfWeek(ldayCome)!
        } else {
            lblLastCome.text = ""
            lblLastComeTop.text = ""
        }
        
        if customer.first_daycome != 0 {
            let fdayCome = convertUnixTimestamp(time: customer.first_daycome)
            lblFirstCome.text = fdayCome + getDayOfWeek(fdayCome)!
        } else {
            lblFirstCome.text = ""
        }
        
        if customer.memo1.count > 0 {
            btnMemo1.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        } else {
            btnMemo1.backgroundColor = UIColor.lightGray
        }
        
        if customer.memo2.count > 0 {
            btnMemo2.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        } else {
            btnMemo2.backgroundColor = UIColor.lightGray
        }
        
        if customer.onSecret == 1 {
            btnSecret.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        } else {
            btnSecret.backgroundColor = UIColor.lightGray
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            imv_lock_memo_secret.isHidden = true
        } else {
            imv_lock_memo_secret.isHidden = false
        }
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        showDeleteOption(status: false)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    

    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        print("DATE :: \(datePicker.date)")
    }

    //*****************************************************************
    // MARK: - Action
    //*****************************************************************

    @IBAction func onHelp(_ sender: UIButton) {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view: self)
    }

    @IBAction func onAddNewCarte(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier:"AddCartePopupVC") as? AddCartePopupVC {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func onEdit(_ sender: UIButton) {
        
        guard let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? else {
            return
        }
        if let vc = storyBoard.instantiateViewController(withIdentifier:"RegCustomerPopup") as? RegCustomerPopup {
            vc.modalTransitionStyle   = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.customer = customer
            vc.popupType = PopUpType.Edit.rawValue
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onCounseling(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
            guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else {
                return
            }
     
            if let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC {
                vc.customer = customer
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
    @IBAction func onConsent(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kConsent.rawValue) {
            guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else {
                return
            }
            
            if let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC {
                vc.customer = customer
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
    @IBAction func onSecret(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            guard let newPopup = PasswordInputVC(nibName: "PasswordInputVC", bundle: nil) as PasswordInputVC? else {
                return
            }
            
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 300, height: 150)
            newPopup.customer = customer
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        } else {
            showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
        
    }
    
    @IBAction func onGallery(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PhotoCollectionVC") as? PhotoCollectionVC {
            if let navigator = navigationController {
                viewController.customer = customer
                viewController.cartesData = cartesData
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onSelect(_ sender: UIButton) {
        
        //check customer has exist or not
        guard let carte = cartes else {
            showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        showDeleteOption(status: true)
        
        tblCarte.reloadData()
        tblCarte.allowsMultipleSelection = true
        
        for i in 0 ..< carte.count {
            let dict : [String : Any?] = ["selected_status" : 0]
            RealmServices.shared.update(cartes[i], with: dict)
        }
    }
    
    func showDeleteOption(status:Bool) {
        btnAddCarte.isHidden = status
        btnSelect.isHidden = status
        
        btnComplete.isHidden = !status
        btnDelete.isHidden = !status
        
        GlobalVariables.sharedManager.onMultiSelect = status
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        
        for carte in self.cartes.filter("selected_status = 1") {
            self.indexDelete.append(carte.id)
        }
        
        if indexDelete.count > 0 {
            let alert = UIAlertController(title: "選択しているカルテを削除しますか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                //add loading view
                self.showLoading()
                
                self.indexDelete.removeAll()
                for carte in self.cartes.filter("selected_status = 1") {
                    self.indexDelete.append(carte.id)
                }
                
                deleteCarte(ids: self.indexDelete) { (success) in
                    if success {
                      
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(CarteData.self))
                        }
                        
                        getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                            if success {
                  
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                self.cartesData.removeAll()
                                
                                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                    self.cartesData.append(carte)
                                }
                                
                                self.tblCarte.reloadData()
                                self.hud.dismiss()
                            } else {
                                self.hud.dismiss()
                         
                            }
                        }
                    } else {
            
                        self.hud.dismiss()
                    }
                }
            }
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            showAlert(message: kALERT_SELECT_CARTE_2_DELETE, view: self)
        }
    }
    
    @IBAction func onComplete(_ sender: UIButton) {
        showDeleteOption(status: false)
        
        tblCarte.reloadData()
        tblCarte.allowsMultipleSelection = false
        
        for i in 0 ..< cartes.count {
            let dict : [String : Any?] = ["selected_status" : 0]
            RealmServices.shared.update(cartes[i], with: dict)
        }
    }
}

//*****************************************************************
// MARK: - DailyExaminationPopupVC Delegate
//*****************************************************************

extension CarteListVC: DailyExaminationPopupVCDelegate {
    
    func onEditDocument(document: DocumentData, carteID: Int) {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
            
            guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else {
                return
            }
            
            guard let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC else {
                return
            }
            
            vc.customer = customer
            vc.document = document
            vc.carteID = carteID
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension CarteListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tblTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartesData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarteCell") as? CarteCell else
        { return UITableViewCell() }
        
        let carteCell = cartesData[indexPath.row]
        cell.categories = categoriesData
        cell.maxFree = accounts[0].acc_free_memo_max
        cell.maxStamp = accounts[0].acc_stamp_memo_max
        cell.configure(carte: carteCell)
        cell.btnEdit.tag = indexPath.row
        cell.btnDailyReport.tag = indexPath.row
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tblCarte.allowsMultipleSelection == true {
            if cartes[indexPath.row].selected_status == 0 {
                let dict : [String : Any?] = ["selected_status" : 1]
                RealmServices.shared.update(cartes[indexPath.row], with: dict)
                tblCarte.reloadData()
            } else {
                let dict : [String : Any?] = ["selected_status" : 0]
                RealmServices.shared.update(cartes[indexPath.row], with: dict)
                tblCarte.reloadData()
            }
        }
    }
}

//*****************************************************************
// MARK: - CarteCell Delegate
//*****************************************************************

extension CarteListVC: CarteCellDelegate {
    func didDailyReportPress(tag: Int) {
        guard let newPopup = DailyExaminationPopupVC(nibName: "DailyExaminationPopupVC", bundle: nil) as DailyExaminationPopupVC? else {
            return
        }
        
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 800)
        newPopup.carteID = cartesData[tag].id
        newPopup.delegate = self
        self.present(newPopup, animated: true, completion: nil)
    }
    
    func didAvatarPress(tag: Int) {
        if cartesData.count == 0 {
            showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        showDeleteOption(status: false)
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CarteImageListVC") as? CarteImageListVC {
            if let navigator = navigationController {
                viewController.customer = customer
                
                for i in 0 ..< cartesData.count {
                    if cartesData[i].id == tag {
                        viewController.carte = cartesData[i]
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    func didPressButton(type: Int,tag: Int) {
        switch type {
        case 0:
      
            let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let confirm = UIAlertAction(title: "削除", style: .default) { UIAlertAction in
                let carte = self.cartesData[tag]
                
                self.cartesData.remove(at: tag)
                RealmServices.shared.delete(carte)
                
                self.tblCarte.reloadData()
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            break
        case 1:
            showDeleteOption(status: false)
   
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "CarteMemoVC") as? CarteMemoVC {
                if let navigator = navigationController {
                    viewController.customer = customer
                    
                    guard let cart = cartesData.count as Int? else {
                        showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    if cart == 0 {
                        showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    
                    viewController.carte = cartesData[tag]
                    viewController.categories = categories
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            break
        default:
            break
        }
    }
}

//*****************************************************************
// MARK: - AddCartePopupVC Delegate
//*****************************************************************

extension CarteListVC: AddCartePopupVCDelegate {
    func didAddCarte(time:Int) {
        var isAllow: Bool = true
        
        let dateAdd = Date(timeIntervalSince1970: TimeInterval(time))
        
        for i in 0 ..< cartesData.count {
            let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
            let isSame = date.isInSameDay(date: dateAdd)
            if isSame {
                isAllow = false
            }
        }
        
        if isAllow {
            
            showLoading()
            
            addCarte(cusID: customer.id, date: time) { (success) in
                if success {
                  
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(realm.objects(CarteData.self))
                    }
                    
                    getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                        if success {
                   
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            self.cartesData.removeAll()
                            
                            for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                self.cartesData.append(carte)
                            }
                            
                            self.tblCarte.reloadData()
                            self.hud.dismiss()
                        } else {
                   
                            self.hud.dismiss()
                            showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                    }
                } else {
    
                    self.hud.dismiss()
                    showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
            }
        } else {
            showAlert(message: kALERT_CARTE_EXISTS_ALREADY, view: self)
        }
    }
}

//*****************************************************************
// MARK: - Secret Popup Delegate
//*****************************************************************

extension CarteListVC: SecretPopupVCDelegate {
    func didCloseSecret() {
        onViewCustomer(cusID: customer.id) { (cusData) in
            self.customer = cusData
            self.setupUI()
        }
    }
}

//*****************************************************************
// MARK: - Password Input Delegate
//*****************************************************************

extension CarteListVC: PasswordInputVCDelegate {
    func onPasswordInput(password: String, cusData: CustomerData) {
        
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
// MARK: - RegCustomerPopup Delegate
//*****************************************************************

extension CarteListVC: RegCustomerPopupDelegate {
    func didConfirm(type:Int) {
        switch type {
        case 1:
            onViewCustomer(cusID: customer.id) { (cusData) in
                self.customer = cusData
                self.setupUI()
            }
            break
        case 2:
            onViewCustomer(cusID: customer.id) { (cusData) in
                self.customer = cusData
                self.setupUI()
            }
            break
        default:
            break
        }
    }
}

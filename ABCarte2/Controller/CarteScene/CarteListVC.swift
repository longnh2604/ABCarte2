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
    weak var bottomPanelView: BottomPanelView!
    
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
    @IBOutlet weak var viewPanelTop: UIView!
    @IBOutlet weak var cusView: GradientView!
    @IBOutlet weak var btnEdit: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()  
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
    }

    func loadData() {
        if needLoad == true {
            //add loading view
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
            //remove before get new
            cartesData.removeAll()
            
            let realm = RealmServices.shared.realm
            self.accounts = realm.objects(AccountData.self)
            
            //Get category title first
            onGetStampCategory { [unowned self] (success) in
                if success {
                    
                    //get category data
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
               
                            self.cartes = realm.objects(CarteData.self)
                            
                            for i in 0 ..< self.cartes.count {
                                self.cartesData.append(self.cartes[i])
                            }
                            
                            self.tblCarte.reloadData()
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

        viewGender.layer.cornerRadius = 5
        viewGender.clipsToBounds = true
        viewTop.layer.cornerRadius = 5
        viewTop.clipsToBounds = true

        tblCarte.delegate = self
        tblCarte.dataSource = self
        tblCarte.allowsMultipleSelection = false
        tblCarte.allowsSelection = true

        updateTopView()
        
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
        
        if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            switch set {
            case 0:
                cusView.topColor = COLOR_SET000.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET000.kHEADER_BACKGROUND_COLOR_DOWN
            case 1:
                cusView.topColor = COLOR_SET001.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET001.kHEADER_BACKGROUND_COLOR_DOWN
            case 2:
                cusView.topColor = COLOR_SET002.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET002.kHEADER_BACKGROUND_COLOR_DOWN
            case 3:
                cusView.topColor = COLOR_SET003.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET003.kHEADER_BACKGROUND_COLOR_DOWN
            case 4:
                cusView.topColor = COLOR_SET004.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET004.kHEADER_BACKGROUND_COLOR_DOWN
            case 5:
                cusView.topColor = COLOR_SET005.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET005.kHEADER_BACKGROUND_COLOR_DOWN
            case 6:
                cusView.topColor = COLOR_SET006.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET006.kHEADER_BACKGROUND_COLOR_DOWN
            case 7:
                cusView.topColor = COLOR_SET007.kHEADER_BACKGROUND_COLOR_UP
                cusView.bottomColor = COLOR_SET007.kHEADER_BACKGROUND_COLOR_DOWN
            default:
                break
            }
        }
        setViewColorStyle(view: viewPanelTop, type: 1)
        setButtonColorStyle(button: btnEdit, type: 1)
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
            viewGender.backgroundColor = COLOR_SET.kMALE_COLOR
        } else {
            lblCusGender.text = "女性"
            viewGender.backgroundColor = COLOR_SET.kFEMALE_COLOR
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
            setButtonColorStyle(button: btnMemo1,type: 0)
        } else {
            btnMemo1.backgroundColor = UIColor.lightGray
        }
        
        if customer.memo2.count > 0 {
            setButtonColorStyle(button: btnMemo2,type: 0)
        } else {
            btnMemo2.backgroundColor = UIColor.lightGray
        }
        
        if customer.onSecret == 1 {
            setButtonColorStyle(button: btnSecret,type: 0)
        } else {
            btnSecret.backgroundColor = UIColor.lightGray
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            btnSecret.isHidden = false
        } else {
            btnSecret.isHidden = true
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
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
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
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
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
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
        
    }
    
    @IBAction func onGallery(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PhotoCollectionVC") as? PhotoCollectionVC {
            if let navigator = navigationController {
                viewController.customer = customer
                
                showDeleteOption(status: false)
                
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onSelect(_ sender: UIButton) {
        
        //check customer has exist or not
        guard let carte = cartes else {
            showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
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
                SVProgressHUD.show(withStatus: "読み込み中")
                SVProgressHUD.setDefaultMaskType(.clear)
                
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
                            } else {
                                showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        showAlert(message: MSG_ALERT.kALERT_CANT_DELETE_CARTE , view: self)
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
            showAlert(message: MSG_ALERT.kALERT_SELECT_CARTE_2_DELETE, view: self)
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

////*****************************************************************
//// MARK: - DailyExaminationPopupVC Delegate
////*****************************************************************
//
//extension CarteListVC: DailyExaminationPopupVCDelegate {
//
//    func onEditDocument(document: DocumentData, carteID: Int) {
//        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
//
//            guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else { return }
//
//            guard let vc = storyBoard.instantiateViewController(withIdentifier: "DocumentsVC") as? DocumentsVC else { return }
//
//            vc.customer = customer
//            vc.document = document
//            vc.carteID = carteID
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
//        }
//    }
//}

//*****************************************************************
// MARK: - CarteDocumentPopupVC Delegate
//*****************************************************************

extension CarteListVC: CarteDocumentPopupVCDelegate {
    
    func onDocSelected(document: DocumentData, carteID: Int) {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
            
            guard let storyBoard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil) as UIStoryboard? else { return }
            guard let vc = storyBoard.instantiateViewController(withIdentifier: "NewDocumentVC") as? NewDocumentVC else { return }
            vc.customer = customer
            vc.document = document
            vc.carteID = carteID
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
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
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCarteDocs.rawValue) {
            guard let newPopup = CarteDocumentPopupVC(nibName: "CarteDocumentPopupVC", bundle: nil) as CarteDocumentPopupVC? else { return }
            
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kAdditionalDoc.rawValue) {
                newPopup.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            } else {
                newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            }

            newPopup.preferredContentSize = CGSize(width: 800, height: 700)
            newPopup.carteID = cartesData[tag].id
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        } else {
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
        
    }
    
    func didAvatarPress(tag: Int) {
        if cartesData.count == 0 {
            showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
            return
        }
        
        showDeleteOption(status: false)
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CarteImageListVC") as? CarteImageListVC {
            if let navigator = navigationController {
                viewController.customer = customer
                
                for i in 0 ..< cartesData.count {
                    if cartesData[i].id == tag {
                        viewController.carte = cartesData[i]
                        viewController.accountPicLimit = accounts[0].pic_limit
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
                        showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        return
                    }
                    if cart == 0 {
                        showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
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
            
            SVProgressHUD.show(withStatus: "読み込み中")
            SVProgressHUD.setDefaultMaskType(.clear)
            
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
                        } else {
                            showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
                SVProgressHUD.dismiss()
            }
        } else {
            showAlert(message: MSG_ALERT.kALERT_CARTE_EXISTS_ALREADY, view: self)
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
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        getAccessSecretMemo(password: password) { (success, msg) in
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
            } else {
                showAlert(message: msg, view: self)
            }
            SVProgressHUD.dismiss()
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

//*****************************************************************
// MARK: - BottomPanelView Delegate
//*****************************************************************

extension CarteListVC: BottomPanelViewDelegate {

    func tapInfo() {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view: self)
    }
}

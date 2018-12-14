//
//  CarteMemoVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/10.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import JGProgressHUD
import SDWebImage

class CarteMemoVC : UIViewController {

    //Variable
    var accounts: Results<AccountData>!
    
    var customer = CustomerData()
    
    var carte = CarteData()
    var cartes: Results<CarteData>!
    
    var memos: Results<MemoData>!
    
    var keywords: Results<StampKeywordData>!
    var keywordsData : [StampKeywordData] = []
    
    var contents: Results<StampContentData>!
    var contentsData : [StampContentData] = []
    
    var categories: Results<StampCategoryData>!
    
    var needLoad: Bool = true
    var memoSelected: Int = 0
    var carteID: Int = 0
    
    var indexHasMemo : [Int] = []
    var idContent: [Int] = []
    var maxFree: Int?
    var maxStamp: Int?
    var isEdited: Bool = false
    let hud = JGProgressHUD(style: .dark)
    
    //topview
    @IBOutlet weak var imvCusPic: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnCancel: RoundButton!
    
    //memoTopView
    @IBOutlet weak var imvAvatar: UIButton!
    @IBOutlet weak var lblNoPhoto: UILabel!
    @IBOutlet weak var lblDayDate: UILabel!
    @IBOutlet weak var btnMemo1: RoundButton!
    @IBOutlet weak var btnMemo2: RoundButton!
    @IBOutlet weak var btnMemo3: RoundButton!
    @IBOutlet weak var btnMemo4: RoundButton!
    @IBOutlet weak var btnMemo5: RoundButton!
    @IBOutlet weak var btnMemo6: RoundButton!
    @IBOutlet weak var btnMemo7: RoundButton!
    @IBOutlet weak var btnMemo8: RoundButton!
    @IBOutlet weak var btnMemo9: RoundButton!
    @IBOutlet weak var btnMemo10: RoundButton!
    @IBOutlet weak var btnMemo11: RoundButton!
    @IBOutlet weak var btnMemo12: RoundButton!
    @IBOutlet weak var btnPhotoMgnt: RoundButton!
    
    //memoView
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var tblStamp: UITableView!
    @IBOutlet weak var btnStamp: RoundButton!
    
    @IBOutlet weak var constWStamp: NSLayoutConstraint!
    @IBOutlet weak var constWBtnStamp: NSLayoutConstraint!
    @IBOutlet weak var viewStampNotify: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "StampCell", bundle: nil)
        tblStamp.register(nib, forCellReuseIdentifier: "StampCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()

        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        needLoad = true
        memoSelected = 1
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }
    
    func loadData() {
 
        if needLoad == true {
            
            showLoading()
            
            let realm = RealmServices.shared.realm
            self.accounts = realm.objects(AccountData.self)
            
            maxFree = accounts[0].acc_free_memo_max
            maxStamp = accounts[0].acc_stamp_memo_max
            
            getCustomerCartesWithMemos(cusID: self.customer.id, completion: { (success) in
                if success {
         
                    //remove data first
                    self.indexHasMemo.removeAll()
                    
                    let realm = RealmServices.shared.realm
                    self.cartes = realm.objects(CarteData.self)
                    
                    for i in 0 ..< self.cartes.count {
                        
                        if self.cartes[i].id == self.carteID {
                            self.carte = self.cartes[i]
                        }
                    }
                    
                    self.removeAllMemoSelect()
                    
                    self.updateTopView()
                    
                    self.setupUI()
                    
                    self.hud.dismiss()
                } else {
                    self.removeAllMemoSelect()
                    
                    self.updateTopView()
                    
                    self.setupUI()
                    
                    showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                }
            })
            needLoad = false
            
        }
        
    }
    
    func loadStamp(stampID:Int) {
        showLoading()
        
        onGetContentFromStamp(stampID: stampID) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.contents = realm.objects(StampContentData.self)
                
                self.contentsData.removeAll()
                
                for i in 0 ..< self.contents.count {
                    self.contentsData.append(self.contents[i])
                }
                
                onGetKeyFromCategory(categoryID: self.categories[self.memoSelected - 5].id, completion: { (success) in
                    if success {
                        
                        let realm = RealmServices.shared.realm
                        self.keywords = realm.objects(StampKeywordData.self)
                        
                        self.keywordsData.removeAll()
                        
                        if self.keywords.count > 0 {
                            self.viewStampNotify.isHidden = true
                        } else {
                            self.viewStampNotify.isHidden = false
                        }
                        
                        for i in 0 ..< self.keywords.count {
                            self.keywordsData.append(self.keywords[i])
                        }
                        
                        self.tblStamp.reloadData()
                        self.hud.dismiss()
                    } else {
                        showAlert(message: kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK, view: self)
                        self.hud.dismiss()
                    }
                })
                
                self.updateMemoView(index: self.memoSelected)
            } else {
                showAlert(message: kALERT_CANT_GET_STAMP_INFO_PLEASE_CHECK_NETWORK, view: self)
                self.hud.dismiss()
            }
        }
    }
    
    func setupUI() {
        //set navigation bar title
        let logo = UIImage(named: "CarteDetailNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        btnPhotoMgnt.layer.cornerRadius = 10
        btnPhotoMgnt.clipsToBounds = true
        
        memoSelected = 1
        btnMemo1.backgroundColor = kMEMO_SELECT_COLOR
    
        tfTitle.text = ""
        tvContent.text = ""
        
        for i in 0 ..< carte.free_memo.count {
            if carte.free_memo[i].position == memoSelected {
                tfTitle.text = carte.free_memo[i].title
                tvContent.text = carte.free_memo[i].content
            }
        }
        
        updateTopView()
        updateTopMemoView()
        
        tblStamp.delegate = self
        tblStamp.dataSource = self
        tblStamp.isHidden = true
        
        showStamp(enable: false)
        
        //textview delegate
        tvContent.delegate = self
    }
    
    func updateTopView() {
        if customer.pic_url != "" {
            let url = URL(string: customer.pic_url)
            imvCusPic.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: nil)
        } else {
            imvCusPic.image = UIImage(named: "nophotoIcon")
        }
        
        imvCusPic.layer.cornerRadius = 25
        imvCusPic.clipsToBounds = true

        lblCusName.text = customer.last_name + " " + customer.first_name

        let dayCome = convertUnixTimestamp(time: carte.select_date)
        lblDate.text = dayCome + getDayOfWeek(dayCome)!
        
        //add id carte
        carteID = carte.id
        
        //check memo has included or not
        if carte.free_memo.count > 0 {
            
            for i in 0 ..< carte.free_memo.count {
                setMemo(position: carte.free_memo[i].position, title: carte.free_memo[i].title, content: carte.free_memo[i].content)
                
                self.indexHasMemo.append(self.carte.free_memo[i].position)
                
                if carte.free_memo[i].position == memoSelected {
                    switch memoSelected {
                    case 1:
                        btnMemo1.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = carte.free_memo[i].title
                        tvContent.text = carte.free_memo[i].content
                    case 2:
                        btnMemo2.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = carte.free_memo[i].title
                        tvContent.text = carte.free_memo[i].content
                    case 3:
                        btnMemo3.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = carte.free_memo[i].title
                        tvContent.text = carte.free_memo[i].content
                    case 4:
                        btnMemo4.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = carte.free_memo[i].title
                        tvContent.text = carte.free_memo[i].content
                    default:
                        break
                    }
                }
            }
        }
        
        if carte.stamp_memo.count > 0 {
            
            for i in 0 ..< carte.stamp_memo.count {
                setMemo(position: carte.stamp_memo[i].position, title: categories[i].title, content: carte.stamp_memo[i].content)
                
                self.indexHasMemo.append(self.carte.stamp_memo[i].position)
                
                var text: String = ""
                
                if carte.stamp_memo[i].position == memoSelected {
                    switch memoSelected {
                    case 5:
                        btnMemo5.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = categories[0].title
                        
                        for i in 0 ..< contentsData.count {
                            text.append(contentsData[i].content)
                            addContent(id: contentsData[i].id)
                        }
                        tvContent.text = text
                    case 6:
                        btnMemo6.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = categories[1].title
                        
                        for i in 0 ..< contentsData.count {
                            text.append(contentsData[i].content)
                            addContent(id: contentsData[i].id)
                        }
                        tvContent.text = text
                    case 7:
                        btnMemo7.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = categories[2].title
                        
                        for i in 0 ..< contentsData.count {
                            text.append(contentsData[i].content)
                            addContent(id: contentsData[i].id)
                        }
                        tvContent.text = text
                    case 8:
                        btnMemo8.backgroundColor = kMEMO_SELECT_COLOR
                        tfTitle.text = categories[3].title
                        
                        for i in 0 ..< contentsData.count {
                            text.append(contentsData[i].content)
                            addContent(id: contentsData[i].id)
                        }
                        tvContent.text = text
                    default:
                        break
                    }
                }
            }
        }
        
        if carte.free_memo.count == 0 && carte.stamp_memo.count == 0 {
            btnMemo1.backgroundColor = kMEMO_SELECT_COLOR
            memoSelected = 1
            tfTitle.text = ""
            tvContent.text = ""
        }
        
        hideFreeMemo()
        hideStampMemo()
        
        //Check account's memo limitation
        switch maxFree {
        case 2:
            btnMemo2.isHidden = false
        case 3:
            btnMemo2.isHidden = false
            btnMemo3.isHidden = false
        case 4:
            btnMemo2.isHidden = false
            btnMemo3.isHidden = false
            btnMemo4.isHidden = false
        default:
            break
        }
        
        switch maxStamp {
        case 2:
            btnMemo6.isHidden = false
        case 3:
            btnMemo6.isHidden = false
            btnMemo7.isHidden = false
        case 4:
            btnMemo6.isHidden = false
            btnMemo7.isHidden = false
            btnMemo8.isHidden = false
        default:
            break
        }
    }
    
    func hideFreeMemo() {
        btnMemo2.isHidden = true
        btnMemo3.isHidden = true
        btnMemo4.isHidden = true
    }
    
    func hideStampMemo() {
        btnMemo6.isHidden = true
        btnMemo7.isHidden = true
        btnMemo8.isHidden = true
    }
    
    func setMemo(position:Int,title:String,content:String) {
        switch position {
        case 1:
            btnMemo1.setTitle("\(title)", for: .normal)
            btnMemo1.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 2:
            btnMemo2.setTitle("\(title)", for: .normal)
            btnMemo2.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 3:
            btnMemo3.setTitle("\(title)", for: .normal)
            btnMemo3.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 4:
            btnMemo4.setTitle("\(title)", for: .normal)
            btnMemo4.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 5:
            btnMemo5.setTitle("\(title)", for: .normal)
            if content.isEmpty {
                btnMemo5.backgroundColor = UIColor.lightGray
            } else {
                btnMemo5.backgroundColor = kMEMO_HAS_CONTENT_COLOR
            }
            
        case 6:
            btnMemo6.setTitle("\(title)", for: .normal)
            if content.isEmpty {
                btnMemo6.backgroundColor = UIColor.lightGray
            } else {
                btnMemo6.backgroundColor = kMEMO_HAS_CONTENT_COLOR
            }
            
        case 7:
            btnMemo7.setTitle("\(title)", for: .normal)
            if content.isEmpty {
                btnMemo7.backgroundColor = UIColor.lightGray
            } else {
                btnMemo7.backgroundColor = kMEMO_HAS_CONTENT_COLOR
            }
            
        case 8:
            btnMemo8.setTitle("\(title)", for: .normal)
            if content.isEmpty {
                btnMemo8.backgroundColor = UIColor.lightGray
            } else {
                btnMemo8.backgroundColor = kMEMO_HAS_CONTENT_COLOR
            }
           
        case 9:
            btnMemo9.setTitle("\(title)", for: .normal)
            btnMemo9.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 10:
            btnMemo10.setTitle("\(title)", for: .normal)
            btnMemo10.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 11:
            btnMemo11.setTitle("\(title)", for: .normal)
            btnMemo11.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        case 12:
            btnMemo12.setTitle("\(title)", for: .normal)
            btnMemo12.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        default:
            break
        }
    }
    
    func addContent(id:Int) {
        idContent.append(id)
    }
    
    func updateTopMemoView() {
        let dayCome = convertUnixTimestamp(time: carte.select_date)
        lblDayDate.text = dayCome + getDayOfWeek(dayCome)!
 
        if carte.carte_photo.isEmpty {
            if carte.medias.count > 0 {
                lblNoPhoto.text = "\(carte.medias.count)"
                let url = URL(string: (carte.medias.last?.url)!)
                
                imvAvatar.sd_setImage(with: url, for: .normal) { (image, error, cache, url) in
                    let img = image?.crop(to: CGSize(width: 768, height: 1024))
                    self.imvAvatar.setImage(img, for: .normal)
                }

            } else {
                self.imvAvatar.setImage(UIImage(named: "nophotoIcon"), for: .normal)
            }
        } else {
            lblNoPhoto.text = "\(carte.medias.count)"
            let url = URL(string: carte.carte_photo)
            
            imvAvatar.sd_setImage(with: url, for: .normal) { (image, error, cache, url) in
                let img = image?.crop(to: CGSize(width: 768, height: 1024))
                self.imvAvatar.setImage(img, for: .normal)
            }
        }
    }
    
    func updateMemoView(index:Int) {

        tfTitle.text = ""
        tvContent.text = ""
        
        var text: String = ""
        switch index {
            
        case 1,2,3,4:
            
            tfTitle.text = ""
            tvContent.text = ""
            
            for i in 0 ..< carte.free_memo.count {
                if carte.free_memo[i].position == index {
                    tfTitle.text = carte.free_memo[i].title
                    tvContent.text = carte.free_memo[i].content
                }
            }
        case 5:
            tfTitle.text = categories[0].title
            
            for i in 0 ..< contentsData.count {
                if text == "" {
                    text.append(contentsData[i].content)
                } else {
                    text.append("\n\(contentsData[i].content)")
                }
                addContent(id: contentsData[i].id)
            }
            tvContent.text = text
        case 6:
            tfTitle.text = categories[1].title
            
            for i in 0 ..< contentsData.count {
                if text == "" {
                    text.append(contentsData[i].content)
                } else {
                    text.append("\n\(contentsData[i].content)")
                }
                addContent(id: contentsData[i].id)
            }
            tvContent.text = text
        case 7:
            tfTitle.text = categories[2].title
            
            for i in 0 ..< contentsData.count {
                if text == "" {
                    text.append(contentsData[i].content)
                } else {
                    text.append("\n\(contentsData[i].content)")
                }
                
                addContent(id: contentsData[i].id)
            }
            tvContent.text = text
        case 8:
            tfTitle.text = categories[3].title
            
            for i in 0 ..< contentsData.count {
                if text == "" {
                    text.append(contentsData[i].content)
                } else {
                    text.append("\n\(contentsData[i].content)")
                }
                addContent(id: contentsData[i].id)
            }
            tvContent.text = text
        default:
            break
        }
    }
    
    func updateMemoViewEmpty() {
        tfTitle.text = ""
        tvContent.text = ""
    }
    
    func removeAllMemoSelect() {
        
        btnMemo1.backgroundColor = UIColor.lightGray
        btnMemo2.backgroundColor = UIColor.lightGray
        btnMemo3.backgroundColor = UIColor.lightGray
        btnMemo4.backgroundColor = UIColor.lightGray
        btnMemo5.backgroundColor = UIColor.lightGray
        btnMemo6.backgroundColor = UIColor.lightGray
        btnMemo7.backgroundColor = UIColor.lightGray
        btnMemo8.backgroundColor = UIColor.lightGray
        
        if carte.free_memo.count > 0 {
            for i in 0 ..< carte.free_memo.count {
                switch carte.free_memo[i].position {
                case 1:
                   btnMemo1.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                case 2:
                    btnMemo2.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                case 3:
                    btnMemo3.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                case 4:
                    btnMemo4.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                default:
                    break
                }
            }
        }
        
        if carte.stamp_memo.count > 0 {
            for i in 0 ..< carte.stamp_memo.count {
                switch carte.stamp_memo[i].position {
                case 5:
                    if carte.stamp_memo[i].content.isEmpty {
                        btnMemo5.backgroundColor = UIColor.lightGray
                    } else {
                        btnMemo5.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                    }
                    
                case 6:
                    if carte.stamp_memo[i].content.isEmpty {
                        btnMemo6.backgroundColor = UIColor.lightGray
                    } else {
                        btnMemo6.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                    }
                   
                case 7:
                    if carte.stamp_memo[i].content.isEmpty {
                        btnMemo7.backgroundColor = UIColor.lightGray
                    } else {
                        btnMemo7.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                    }
                  
                case 8:
                    if carte.stamp_memo[i].content.isEmpty {
                        btnMemo8.backgroundColor = UIColor.lightGray
                    } else {
                        btnMemo8.backgroundColor = kMEMO_HAS_CONTENT_COLOR
                    }
                 
                default:
                    break
                }
            }
        }
        
    }
    
    func removeAllData() {
        let realm = RealmServices.shared.realm
       
        try! realm.write {
            realm.delete(realm.objects(CarteData.self))
            realm.delete(carte)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        
        checkMemoEditOrNot { (success) in
            if success {
                return
            } else {
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func checkMemoEditOrNot(completion:@escaping(Bool) -> ()) {
        
        if isEdited == true {
            let alert = UIAlertController(title: "カルテメモ", message: kALERT_SAVE_MEMO_NOTIFICATION, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler:{ (UIAlertAction) in
                completion(false)
            }))
            alert.addAction(UIAlertAction(title: "いいえ", style: .default, handler:{ (UIAlertAction) in
                completion(true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            completion(false)
        }
    }
    
    func showStamp(enable: Bool) {
        if enable {
            constWStamp.constant = 200
            constWBtnStamp.constant = 120
        } else {
            constWStamp.constant = 0
            constWBtnStamp.constant = 0
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onHelp(_ sender: UIButton) {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view: self)
    }

    @IBAction func onEdit(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CarteImageListVC") as? CarteImageListVC {
            if let navigator = navigationController {
                viewController.customer = customer
                viewController.carte = carte
                viewController.account_id = accounts[0].account_id
                viewController.account_name = accounts[0].acc_name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func callAction(index:Int) {
        idContent.removeAll()
        
        removeAllMemoSelect()
        
        memoSelected = index
        
        if index > 4 {
            tvContent.isSelectable = false
            tfTitle.isEnabled = false
            tblStamp.isHidden = false
            showStamp(enable: true)
            loadStamp(stampID: carte.stamp_memo[index-5].id)
        } else {
            tfTitle.isEnabled = true
            tvContent.isSelectable = true
            tvContent.isEditable = true
            tblStamp.isHidden = true
            showStamp(enable: false)
            updateMemoView(index: memoSelected)
        }
        
        switch index {
        case 1:
            btnMemo1.backgroundColor = kMEMO_SELECT_COLOR
        case 2:
            btnMemo2.backgroundColor = kMEMO_SELECT_COLOR
        case 3:
            btnMemo3.backgroundColor = kMEMO_SELECT_COLOR
        case 4:
            btnMemo4.backgroundColor = kMEMO_SELECT_COLOR
        case 5:
            btnMemo5.backgroundColor = kMEMO_SELECT_COLOR
        case 6:
            btnMemo6.backgroundColor = kMEMO_SELECT_COLOR
        case 7:
            btnMemo7.backgroundColor = kMEMO_SELECT_COLOR
        case 8:
            btnMemo8.backgroundColor = kMEMO_SELECT_COLOR
        default:
            break
        }
    }
    
    @IBAction func onMemoSelect(_ sender: UIButton) {
        
        //Check memo has edited or not
        checkMemoEditOrNot { (success) in
            if success {
                return
            } else {
                if self.isEdited == true {
                    self.isEdited = false
                }
                
                if sender.tag > 4 {
                    self.btnCancel.isHidden = true
                } else {
                    self.btnCancel.isHidden = false
                }
                
                self.callAction(index: sender.tag)
            }
        }
    }
    
    @IBAction func onStampRegister(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "OtherSettingVC") as? OtherSettingVC {
            if let navigator = navigationController {
                viewController.customer = customer
                viewController.carte = carte
                viewController.maxStamp = maxStamp
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        if tfTitle.text == "" {
            showAlert(message: kALERT_INPUT_TITLE, view: self)
            return
        }
        
        //Check free memo or not
        if memoSelected < 5 {
            if tvContent.text == "" {
                showAlert(message: kALERT_INPUT_CONTENT, view: self)
                return
            }
        }
        
        showLoading()
        
        if indexHasMemo.contains(memoSelected) {
            //In case of memo has exist
            var idMemo = 0
            for i in 0 ..< self.carte.free_memo.count {
                if memoSelected == self.carte.free_memo[i].position {
                    idMemo = self.carte.free_memo[i].id
                }
            }
            
            if memoSelected > 4 {
                
                var str = ""
                for i in 0 ..< idContent.count {
                    if str == "" {
                        str.append("\(idContent[i])")
                    } else {
                        str.append(",\(idContent[i])")
                    }
                }
                
                editCarteStampMemo(stampID: carte.stamp_memo[memoSelected-5].id, content: str) { (success) in
                    if success {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(CarteData.self))
                        }
                        
                        getCustomerCartesWithMemos(cusID: self.customer.id, completion: { (success) in
                            if success {
                      
                                //remove data first
                                self.indexHasMemo.removeAll()
                                
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                for i in 0 ..< self.cartes.count {
                                    
                                    if self.cartes[i].id == self.carteID {
                                        self.carte = self.cartes[i]
                                    }
                                }
       
                                self.updateTopView()
                                self.callAction(index: self.memoSelected)
                                
                                if self.isEdited == true {
                                    self.isEdited = false
                                }
                                
                                self.hud.dismiss()
                            } else {
                                
                                self.updateTopView()
                                self.callAction(index: self.memoSelected)
                                
                                showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                                self.hud.dismiss()
                            }
                        })
                    } else {
                        
                        self.updateTopView()
                        self.callAction(index: self.memoSelected)
                        
                        showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        self.hud.dismiss()
                    }
                }
            } else {
                editCarteMemos(memoID: idMemo, title: tfTitle.text!, content: tvContent.text) { (success) in
                    if success {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(CarteData.self))
                        }
                        
                        getCustomerCartesWithMemos(cusID: self.customer.id, completion: { (success) in
                            if success {
                     
                                //remove data first
                                self.indexHasMemo.removeAll()
                                
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                for i in 0 ..< self.cartes.count {
                                    
                                    if self.cartes[i].id == self.carteID {
                                        self.carte = self.cartes[i]
                                    }
                                }
                                
                                self.updateTopView()
                                self.callAction(index: self.memoSelected)
                                
                                if self.isEdited == true {
                                    self.isEdited = false
                                }
                                
                                self.hud.dismiss()
                            } else {
                                self.updateTopView()
                                self.callAction(index: self.memoSelected)
                                showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                                self.hud.dismiss()
                            }
                        })
                    } else {
                        self.updateTopView()
                        self.callAction(index: self.memoSelected)
                        showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        self.hud.dismiss()
                    }
                }
            }
            
            
        } else {
            //Add New
            onAddNewFreeMemo(carteID: carte.id,cusID: customer.id,title:tfTitle.text!,content:tvContent.text,position:memoSelected) { (success) in
                if success {
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(realm.objects(CarteData.self))
                    }
                    
                    getCustomerCartesWithMemos(cusID: self.customer.id, completion: { (success) in
                        if success {
               
                            //remove data first
                            self.indexHasMemo.removeAll()
                            
                            let realm = RealmServices.shared.realm
                            self.cartes = realm.objects(CarteData.self)
                            
                            for i in 0 ..< self.cartes.count {
                
                                if self.cartes[i].id == self.carteID {
                                    self.carte = self.cartes[i]
                                }
                            }
                           
                            self.updateTopView()
                            self.updateMemoView(index: self.memoSelected)
                            
                            if self.isEdited == true {
                                self.isEdited = false
                            }
                            
                            self.hud.dismiss()
                        } else {
                            self.updateTopView()
                            self.updateMemoView(index: self.memoSelected)
                            
                            showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            self.hud.dismiss()
                        }
                    })
                } else {
                    self.updateTopView()
                    self.updateMemoView(index: self.memoSelected)
                    
                    showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.hud.dismiss()
                }
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        tvContent.text = ""
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension CarteMemoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tblTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywordsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StampCell") as? StampCell else
        { return UITableViewCell() }
        
        cell.selectionStyle = .none
        
        if idContent.contains(keywordsData[indexPath.row].id) {
            cell.configure(stamp: keywordsData[indexPath.row],selected: true)
        } else {
            cell.configure(stamp: keywordsData[indexPath.row],selected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! StampCell
        
        if idContent.contains(keywordsData[indexPath.row].id) {
            if let index = idContent.index(of: keywordsData[indexPath.row].id) {
                idContent.remove(at: index)
                cell.onSelectStatus(selected: false)
            }
            
        } else {
            idContent.append(keywordsData[indexPath.row].id)
            cell.onSelectStatus(selected: true)
        }
        showContentByIndex()
        
        if isEdited == false {
            isEdited = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
     
    }
    
    func showContentByIndex() {
        
        tvContent.text.removeAll()
        
        for i in 0 ..< idContent.count {
            
            for j in 0 ..< keywordsData.count {
                if keywordsData[j].id == idContent[i] {
                    if tvContent.text.isEmpty {
                        tvContent.text.append(keywordsData[j].content)
                    } else {
                        tvContent.text.append("\n\(keywordsData[j].content)")
                    }
                }
            }
        }
    }
}

//*****************************************************************
// MARK: - TextView Delegate
//*****************************************************************

extension CarteMemoVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
  
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
  
        if isEdited == false {
            isEdited = true
        }
    }
}




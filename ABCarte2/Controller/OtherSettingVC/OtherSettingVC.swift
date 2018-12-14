//
//  OtherSettingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD

class OtherSettingVC: UIViewController {
    //Variable
    var categories: Results<StampCategoryData>!
    var categoriesData: [StampCategoryData] = []
    
    var keywords: Results<StampKeywordData>!
    var keywordsData : [StampKeywordData] = []
    
    var customer = CustomerData()
    var carte = CarteData()
    
    var maxStamp: Int?
    var isCreating: Bool = false
    var isModifying: Bool = false
    var stampIndex: Int?
    var keyIndex: Int?
    var textField: UITextField?
    var categoryID: Int?
    let hud = JGProgressHUD(style: .dark)
    
    //IBOutlet
    @IBOutlet weak var btnStampReg: RoundButton!
    @IBOutlet weak var tblMemo: UITableView!
    @IBOutlet weak var btnCreate: RoundButton!
    @IBOutlet weak var btnDelete: RoundButton!
    @IBOutlet weak var collectStampMemo: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "StampCategoryCell", bundle: nil)
        tblMemo.register(nib, forCellReuseIdentifier: "StampCategoryCell")
        
        tblMemo.delegate = self
        tblMemo.dataSource = self
        tblMemo.tableFooterView = UIView()
        
        collectStampMemo.delegate = self
        collectStampMemo.dataSource = self
        
        loadData()
        
        setupUI()
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }

    func loadData() {
        showLoading()
        
        //Get category title first
        onGetStampCategory { (success) in
            if success {
                
                //get category data
                let realm = RealmServices.shared.realm
                self.categories = realm.objects(StampCategoryData.self)
                
                self.categoriesData.removeAll()
                
                for i in 0 ..< self.categories.count {
                    self.categoriesData.append(self.categories[i])
                }
                
                self.categoryID = nil
                
                self.tblMemo.reloadData()
                self.hud.dismiss()
                
                guard let index = self.stampIndex else {
                    return
                }
                self.tblMemo.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
                
                self.stampIndex = index
                self.categoryID = self.categoriesData[index].id
                
                guard let id = self.categoryID else {
                    return
                }
                
                self.loadStamp(categoryID: id)
                
            } else {
                showAlert(message: kALERT_CANT_GET_MEMO_INFO_PLEASE_CHECK_NETWORK, view: self)
                self.hud.dismiss()
            }
        }
    }
    
    func loadStamp(categoryID:Int) {
        showLoading()
        
        onGetKeyFromCategory(categoryID: categoryID) { (success) in
            if success {
                let realm = RealmServices.shared.realm
                self.keywords = realm.objects(StampKeywordData.self)
                
                self.keywordsData.removeAll()
                
                for i in 0 ..< self.keywords.count {
                    self.keywordsData.append(self.keywords[i])
                }
                
                self.collectStampMemo.reloadData()
                self.hud.dismiss()
            } else {
                
                self.hud.dismiss()
            }
        }
    }
    
    func setupUI() {
        //set navigation bar title
        self.navigationItem.title = "各種設定"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "入力して下さい";
        }
    }
    
    func openAddKeywordAlert() {
        let alert = UIAlertController(title: "スタンプキーワード", message: "キーワードを追加してください。", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
          
            guard let id = self.categoryID else {
                return
            }
            
            onAddKeywords(categoryID: id, content: (self.textField?.text)!, completion: { (success) in
                if success {
                    showAlert(message: kALERT_ADD_KEYWORD_SUCCESS, view: self)
                    self.loadStamp(categoryID:id)
                } else {
                    showAlert(message: kALERT_CANT_SAVE_KEYWORD, view: self)
                }

            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openEditStampCategoryTitleAlert() {
        let alert = UIAlertController(title: "スタンプタイトル", message: "タイトルを追加してください。", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (UIAlertAction) in
            
            guard let id = self.categoryID else {
                return
            }
            
            if (self.textField?.text?.isEmpty)! {
                showAlert(message: kALERT_INPUT_TITLE, view: self)
            } else {
                editStampCategoryTitle(categoryID: id, title: (self.textField?.text)!, completion: { (success) in
                    if success {
                        
                        self.loadData()
                        showAlert(message: kALERT_UPDATE_TITLE_SUCCESS, view: self)
                       
                    } else {
                        showAlert(message: kALERT_CANT_SAVE_TITLE, view: self)
                    }
                })
            }
            
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - Action
    //*****************************************************************
    
    @IBAction func onEditStampCategoryTitle(_ sender: UIButton) {
        
        guard categoryID != nil else {
            showAlert(message: kALERT_SELECT_TITLE_EDIT, view: self)
            return
        }
        openEditStampCategoryTitleAlert()
        
    }
    
    @IBAction func onCreateNew(_ sender: UIButton) {
        
        openAddKeywordAlert()

    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        if keyIndex != nil {
            let alert = UIAlertController(title: "このキーワードを削除しますか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                self.showLoading()
                
                onDeleteKeywords(keywordID: self.keywordsData[self.keyIndex!].id, completion: { (success) in
                    if success {
                        
                        guard let id = self.categoryID else {
                            return
                        }
                        
                        self.loadStamp(categoryID: id)
                        self.hud.dismiss()
                    } else {
                        showAlert(message: kALERT_CANT_DELETE_KEYWORD, view: self)
                        self.hud.dismiss()
                    }
                })
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            alert.popoverPresentationController?.sourceRect = sender.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            showAlert(message: kALERT_SELECT_KEYWORD_DELETE, view: self)
        }
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension OtherSettingVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let max = maxStamp else {
            return categoriesData.count
        }
        return max
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StampCategoryCell") as? StampCategoryCell else
        { return UITableViewCell() }
        
        if categoriesData.count > 0 {
            let stampCell = categoriesData[indexPath.row]
            cell.configure(categories: stampCell)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        stampIndex = indexPath.row
        
        categoryID = categoriesData[indexPath.row].id
        
        guard let id = categoryID else {
            return
        }
        
        self.loadStamp(categoryID: id)
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension OtherSettingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StampCollectCell", for: indexPath) as! StampCollectCell
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.configure(stamp: keywordsData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywordsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        keyIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        keyIndex = nil
    }
}

extension OtherSettingVC : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

//*****************************************************************
// MARK: - TextView Delegate
//*****************************************************************

extension OtherSettingVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        isModifying = true
        tblMemo.allowsSelection = false
    }
    
}

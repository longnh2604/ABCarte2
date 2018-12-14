//
//  SecretPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD

protocol SecretPopupVCDelegate: class {
    func didCloseSecret()
}

class SecretPopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    //Variable
    weak var delegate:SecretPopupVCDelegate?
    
    var customer = CustomerData()
    var secrets: Results<SecretMemoData>!
    var secretData = [SecretMemoData]()
    var authenPass: String?
    var indexSelected: Int?
    var isCreating: Bool = false
    var isModifying: Bool = false
    
    //IBOutlet
    @IBOutlet weak var tblMemo: UITableView!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btnAdd: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnDelete: RoundButton!
    @IBOutlet weak var lblDayCreate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        
        setupUI()
    }

    func loadData() {
        let nib = UINib(nibName: "SecretCell", bundle: nil)
        tblMemo.register(nib, forCellReuseIdentifier: "SecretCell")
        
        //add loading view
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
        
        print(customer.id)
        getCusSecretMemo(cusID: customer.id) { (success) in
            if success {
            
                let realm = RealmServices.shared.realm
                self.secrets = realm.objects(SecretMemoData.self)
                
                self.secretData.removeAll()
                
                for i in 0 ..< self.secrets.count {
                    self.secretData.append(self.secrets[i])
                }
                
                self.tblMemo.reloadData()
                hud.dismiss()
            } else {
                showAlert(message: "シークレットメモの読込に失敗しました。ネットワークの状態を確認してください。", view: self)
                hud.dismiss()
            }
        }
    }

    func setupUI() {
        tblMemo.delegate = self
        tblMemo.dataSource = self
        
        tvContent.text = ""
        tvContent.delegate = self
        tvContent.isSelectable = false
        
        showButtonOption(hidden: true)
    }
    
    func showButtonOption(hidden:Bool) {
        btnCancel.isHidden = hidden
        btnSave.isHidden = hidden
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAdd(_ sender: UIButton) {
        //remove if it before has
        indexSelected = nil
        
        if isCreating == false {
            isCreating = true
            
            showButtonOption(hidden: false)
            
            let secret = SecretMemoData()
            secretData.append(secret)
            tvContent.text = ""
            tvContent.isSelectable = true
            tvContent.isEditable = true
            
            tblMemo.beginUpdates()
            tblMemo.insertRows(at: [IndexPath.init(row: self.secretData.count-1, section: 0)], with: .automatic)
            tblMemo.endUpdates()
            
            let index = IndexPath(row: self.secretData.count - 1, section: 0)
            tblMemo.selectRow(at: index, animated: true, scrollPosition: UITableViewScrollPosition.bottom)
            tblMemo.allowsSelection = false
        } else {
            showAlert(message: "新しいメモを作成中です。新たにメモを追加する場合は、先に保存をしてください。", view: self)
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        
        //check textfield first
        if tvContent.text == "" {
            showAlert(message: "シークレットメモが入力されていません。", view: self)
            return
        }
        
        if isModifying == true && isCreating == false {
            
            let alert = UIAlertController(title: "メモを上書き保存します。よろしいですか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                hud.show(in: self.view)
                
                editSecretMemo(secretID: self.secretData[self.indexSelected!].id, content: self.tvContent.text, auth: self.authenPass!,completion: { (success) in
                    if success {
                        getCusSecretMemo(cusID: self.customer.id) { (success) in
                            if success {
                                let realm = RealmServices.shared.realm
                                self.secrets = realm.objects(SecretMemoData.self)
                                
                                self.secretData.removeAll()
                                
                                for i in 0 ..< self.secrets.count {
                                    self.secretData.append(self.secrets[i])
                                }
                                
                                self.tblMemo.reloadData()
                                hud.dismiss()
                                
                                self.showButtonOption(hidden: true)
                                self.tvContent.text = ""
                                self.tvContent.isSelectable = false
                           
                                self.isCreating = false
                                self.tblMemo.allowsSelection = true
                                
                                self.lblDayCreate.text = "作成日:"
                            } else {
                                showAlert(message: "メモの読込に失敗しました。ネットワークの状態を確認してください。", view: self)
                                hud.dismiss()
                            }
                        }
                    } else {
                        showAlert(message: "メモの更新に失敗しました。ネットワークの状態を確認してください。", view: self)
                        hud.dismiss()
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
        }
        
        if isModifying == true && isCreating == true {
            let alert = UIAlertController(title: "メモを保存します。よろしいですか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                
                hud.show(in: self.view)
                
                addSecretMemo(cusID: self.customer.id, content: self.tvContent.text, auth: self.authenPass!) { (success) in
                    if success {
                        getCusSecretMemo(cusID: self.customer.id) { (success) in
                            if success {
                                let realm = RealmServices.shared.realm
                                self.secrets = realm.objects(SecretMemoData.self)
                                
                                self.secretData.removeAll()
                                
                                for i in 0 ..< self.secrets.count {
                                    self.secretData.append(self.secrets[i])
                                }
                                
                                self.tblMemo.reloadData()
                                hud.dismiss()
                                
                                self.showButtonOption(hidden: true)
                                self.tvContent.text = ""
                                self.tvContent.isSelectable = false
                        
                                self.isCreating = false
                                self.tblMemo.allowsSelection = true
                                
                                self.lblDayCreate.text = "作成日:"
                            } else {
                                showAlert(message: "メモの読込に失敗しました。ネットワークの状態を確認してください。", view: self)
                                hud.dismiss()
                            }
                        }
                    } else {
                        showAlert(message: "Failed to Add New Memo", view: self)
                        hud.dismiss()
                    }
                }
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            alert.popoverPresentationController?.sourceRect = sender.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
  
        if indexSelected != nil {
            let alert = UIAlertController(title: "選択しているメモを削除します。よろしいですか？", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                let hud = JGProgressHUD(style: .dark)
                hud.vibrancyEnabled = true
                hud.textLabel.text = "LOADING"
                hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
                hud.show(in: self.view)
                
                deleteSecretMemo(memoID: self.secretData[self.indexSelected!].id,auth: self.authenPass!, completion: { (success) in
                    if success {
                        getCusSecretMemo(cusID: self.customer.id) { (success) in
                            if success {
                            
                                let realm = RealmServices.shared.realm
                                self.secrets = realm.objects(SecretMemoData.self)
                                
                                self.secretData.removeAll()
                                
                                for i in 0 ..< self.secrets.count {
                                    self.secretData.append(self.secrets[i])
                                }
                                
                                self.tblMemo.reloadData()
                                self.tvContent.text = ""
                                hud.dismiss()
                                
                                self.indexSelected = nil
                                
                                self.lblDayCreate.text = "作成日:"
                            } else {
                         
                                showAlert(message: "シークレットメモの読込に失敗しました。ネットワークの状態を確認してください。", view: self)
                                hud.dismiss()
                            }
                        }
                    } else {
                        showAlert(message: "Failed to Delete Memo", view: self)
                        hud.dismiss()
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
            showAlert(message: "保存していないメモは削除できません。", view: self)
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        isCreating = false
        showButtonOption(hidden: true)
        tvContent.text = ""
        tvContent.isSelectable = false
        tblMemo.allowsSelection = true
        
        secretData.remove(at: self.secretData.count - 1)
        
        if secretData.count <= 0 {
            
        } else {
            tblMemo.beginUpdates()
            tblMemo.deleteRows(at: [IndexPath.init(row: self.secretData.count-1, section: 0)], with: .automatic)
            tblMemo.endUpdates()
        }

        tblMemo.reloadData()
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        self.delegate?.didCloseSecret()
        dismiss(animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - TableView Delegate
    //*****************************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secretData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SecretCell") as? SecretCell else
        { return UITableViewCell() }
        
        let secretCell = secretData[indexPath.row]
        cell.configure(secret: secretCell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tvContent.text = secretData[indexPath.row].content
        
        let dayCreate = convertUnixTimestamp(time: secretData[indexPath.row].created_at)
        lblDayCreate.text = "作成日: \(dayCreate + getDayOfWeek(dayCreate)!)"

        indexSelected = indexPath.row
        btnDelete.isHidden = false
        tvContent.isSelectable = true
        tvContent.isEditable = true
    }
    
    //*****************************************************************
    // MARK: - TextView Delegate
    //*****************************************************************
    
    func textViewDidChange(_ textView: UITextView) {
        isModifying = true
        tblMemo.allowsSelection = false
        btnSave.isHidden = false
    }
}

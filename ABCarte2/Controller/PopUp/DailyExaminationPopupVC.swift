//
//  DailyExaminationPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/05.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

protocol DailyExaminationPopupVCDelegate: class {
    func onEditDocument(document:DocumentData,carteID:Int)
}

class DailyExaminationPopupVC: UIViewController {

    //Variable
    weak var delegate:DailyExaminationPopupVCDelegate?
    
    var documents: Results<DocumentData>!
    var consentData : [DocumentData] = []
    var consentTempData: [DocumentData] = []
    var counsellingData : [DocumentData] = []
    var counsellingTempData : [DocumentData] = []
    
    var carteID: Int?
    var type: Int?
    var cellIndex: Int?
    var tableIndex: Int?
    
    //IBOutlet
    @IBOutlet weak var imvDoc: UIImageView!
    @IBOutlet weak var lblCreated: UILabel!
    @IBOutlet weak var lblTotalPage: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEdit: RoundButton!
    @IBOutlet weak var btnClose: UIButton!

    @IBOutlet weak var btnPreview: RoundButton!
    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var btnCounselling: RoundButton!
    @IBOutlet weak var btnConsent: RoundButton!
    @IBOutlet weak var imvLockCounselling: UIImageView!
    @IBOutlet weak var imvLockConsent: UIImageView!
    
    //exam
    @IBOutlet weak var tblExamDoc: UITableView!
    //customer file
    @IBOutlet weak var tblCusDoc: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        setupUI()
    }
    
    func loadData() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //remove before get new
        consentData.removeAll()
        counsellingData.removeAll()
        
        let realm = RealmServices.shared.realm
        try! realm.write {
            realm.delete(realm.objects(DocumentData.self))
        }
        
        onHiddenButton()
        
        //get document template
        onGetDocumentsTemplate { (success) in
            if success {
                
                guard let cartID = self.carteID else { return }
                //get document carte if exist
                getCustomerCartesWithDocument(carteID: cartID) { (success) in
                    if success {
                        
                        //get category data
                        let realm = RealmServices.shared.realm
                        self.documents = realm.objects(DocumentData.self)
                        
                        for i in 0 ..< self.documents.count {
                            
                            if self.documents[i].type == 1 {
                                if self.documents[i].is_template == 1 {
                                    self.consentTempData.append(self.documents[i])
                                } else {
                                    self.consentData.append(self.documents[i])
                                }
                            }
                            
                            if self.documents[i].type == 2 {
                                if self.documents[i].is_template == 1 {
                                    self.counsellingTempData.append(self.documents[i])
                                } else {
                                    self.counsellingData.append(self.documents[i])
                                }
                            }
                        }
                        
                        //set Type
                        self.type = 1
                        
                        self.resetLoadDocument()
                        
                    } else {
                        showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                    SVProgressHUD.dismiss()
                }
            } else {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func resetLoadDocument() {
        self.tblExamDoc.reloadData()
        self.tblCusDoc.reloadData()
    }
    
    func setupUI() {
        let nib = UINib(nibName: "DailyReportCell", bundle: nil)
        //exam
        tblExamDoc.register(nib, forCellReuseIdentifier: "DailyReportCell")
        
        tblExamDoc.delegate = self
        tblExamDoc.dataSource = self
        tblExamDoc.tableFooterView = UIView()
        
        tblExamDoc.layer.borderColor = UIColor.white.cgColor
        tblExamDoc.layer.cornerRadius = 5
        tblExamDoc.layer.borderWidth = 1
        
        //customer
        tblCusDoc.register(nib, forCellReuseIdentifier: "DailyReportCell")
        
        tblCusDoc.delegate = self
        tblCusDoc.dataSource = self
        tblCusDoc.tableFooterView = UIView()
        
        tblCusDoc.layer.borderColor = UIColor.white.cgColor
        tblCusDoc.layer.cornerRadius = 5
        tblCusDoc.layer.borderWidth = 1
        
        imvDoc.layer.borderWidth = 1
        imvDoc.layer.borderColor = UIColor.white.cgColor
        imvDoc.layer.cornerRadius = 5
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
            imvLockCounselling.isHidden = true
        }
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kConsent.rawValue) {
            imvLockConsent.isHidden = true
        }
    }
    
    func onResetButton() {
        btnCounselling.backgroundColor = UIColor.clear
        btnConsent.backgroundColor = UIColor.clear
    }
    
    func onResetData() {
        tblExamDoc.reloadData()
        tblCusDoc.reloadData()
    }
    
    func onHiddenButton() {
        btnAdd.isHidden = true
        btnEdit.isHidden = true
    }
    
    func showPageNumberAndDate(pageNo:Int,showCreate:Bool,createdTime:Int) {
        lblTotalPage.text = "合計ページ： \(pageNo)"
     
        if showCreate {
            lblCreated.isHidden = false
            let dayCreate = convertUnixTimestamp(time: createdTime)
            lblCreated.text = "作成日: \(dayCreate + getDayOfWeek(dayCreate)!)"
        } else {
            lblCreated.isHidden = true
        }
        
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onAddDocumentFromTemplate(_ sender: UIButton) {
        
        if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kConsent.rawValue) || !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            return
        }
        
        guard let index = cellIndex, let cartID = carteID else { return }
        
        //check customer data has exist document or not
        switch type {
        case 1:
            for i in 0 ..< self.consentData.count {
                if self.consentTempData[index].sub_type == self.consentData[i].sub_type {
                    //data has exist
                    showAlert(message: MSG_ALERT.kALERT_SAME_TYPE_DOCUMENT, view: self)
                    return
                }
            }
        case 2:
            for i in 0 ..< self.counsellingData.count {
                if self.counsellingTempData[index].sub_type == self.counsellingData[i].sub_type {
                    //data has exist
                    showAlert(message: MSG_ALERT.kALERT_SAME_TYPE_DOCUMENT, view: self)
                    return
                }
            }
        default:
            break
        }
        
        if type == 1 {
            dismiss(animated: true) {
                self.delegate?.onEditDocument(document: self.consentTempData[index],carteID: cartID)
            }
        } else {
            dismiss(animated: true) {
                self.delegate?.onEditDocument(document: self.counsellingTempData[index],carteID: cartID)
            }
        }
    }
    
    @IBAction func onEditDocument(_ sender: UIButton) {
        
        if !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kConsent.rawValue) || !GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kCounselling.rawValue) {
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
            return
        }
        
        guard let index = cellIndex,let cartID = carteID else { return }
        
        if type == 1 {
            dismiss(animated: true) {
                self.delegate?.onEditDocument(document: self.consentData[index],carteID: cartID)
            }
        } else {
            dismiss(animated: true) {
                self.delegate?.onEditDocument(document: self.counsellingData[index],carteID: cartID)
            }
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPreview(_ sender: UIButton) {
        let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        
        guard let index = cellIndex else { return }
        
        if tableIndex == 1 {
            if type == 1 {
                newPopup.documentsData = self.consentTempData[index]
            } else {
                newPopup.documentsData = self.counsellingTempData[index]
            }
            newPopup.isTemp = true
        } else {
            if type == 1 {
                newPopup.documentsData = self.consentData[index]
            } else {
                newPopup.documentsData = self.counsellingData[index]
            }
            newPopup.isTemp = false
        }
        
        self.present(newPopup, animated: true, completion: nil)
    }
    
    @IBAction func onDocumentSelect(_ sender: UIButton) {
        
        onResetButton()
        
        switch sender.tag {
        case 1:
            type = 1
            btnCounselling.backgroundColor = COLOR_SET.kBLUE
        case 2:
            type = 2
            btnConsent.backgroundColor = COLOR_SET.kBLUE
        default:
            break
        }
        
        imvDoc.image = UIImage(named: "nophotoIcon")
        cellIndex = nil
        resetLoadDocument()
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension DailyExaminationPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let no: Int?
        
        if tableView.tag == 1 {
            if type == 1 {
                no = consentTempData.count
            } else {
                no = counsellingTempData.count
            }
        } else {
            if type == 1 {
                no = consentData.count
            } else {
                no = counsellingData.count
            }
        }
        
        return no!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DailyReportCell.self)) as! DailyReportCell
        
        if tableView.tag == 1 {
            if type == 1 {
                cell.configure(title:consentTempData[indexPath.row].title)
            } else {
                cell.configure(title:counsellingTempData[indexPath.row].title)
            }
        } else {
            if type == 1 {
                cell.configure(title:consentData[indexPath.row].title)
            } else {
                cell.configure(title:counsellingData[indexPath.row].title)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        //reset all selection
        if cellIndex != nil {
            let indexP = IndexPath.init(row: cellIndex!, section: 0)
            
            if tableIndex == 1 {
                tblExamDoc.deselectRow(at: indexP, animated: false)
            } else {
                tblCusDoc.deselectRow(at: indexP, animated: false)
            }
        }
        
        cellIndex = indexPath.row
        tableIndex = tableView.tag
        
        onHiddenButton()
        if tableView.tag == 1 {
            btnAdd.isHidden = false
        } else {
            btnEdit.isHidden = false
        }
        
        var stringPath = ""
        
        switch tableView.tag {
        case 1:
            if type == 1 {
                //check edit link first
                
                let urlEdit = URL(string: consentTempData[indexPath.row].document_pages[0].url_edit)
                if urlEdit != nil {
                    stringPath = consentTempData[indexPath.row].document_pages[0].url_edit
                } else {
                    stringPath = consentTempData[indexPath.row].document_pages[0].url_original
                }
                
                let url = URL(string: stringPath)
                
                imvDoc.sd_setImage(with: url) { (image, error, cachetype, url) in
                    if (error != nil) {
                        //Failure code here
                        showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    SVProgressHUD.dismiss()
                }
                
                showPageNumberAndDate(pageNo: consentTempData[indexPath.row].document_pages.count,showCreate: false,createdTime: consentTempData[indexPath.row].created_at)
            } else {
                
                let urlEdit = URL(string: counsellingTempData[indexPath.row].document_pages[0].url_edit)
                if urlEdit != nil {
                    stringPath = counsellingTempData[indexPath.row].document_pages[0].url_edit
                } else {
                    stringPath = counsellingTempData[indexPath.row].document_pages[0].url_original
                }
                
                let url = URL(string: stringPath)
                
                imvDoc.sd_setImage(with: url) { (image, error, cachetype, url) in
                    if (error != nil) {
                        //Failure code here
                        showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    SVProgressHUD.dismiss()
                }
                
                showPageNumberAndDate(pageNo: counsellingTempData[indexPath.row].document_pages.count,showCreate: false,createdTime: counsellingTempData[indexPath.row].created_at)
            }
        case 2:
            if type == 1 {
                //check edit link first
                
                let urlEdit = URL(string: consentData[indexPath.row].document_pages[0].url_edit)
                if urlEdit != nil {
                    stringPath = consentData[indexPath.row].document_pages[0].url_edit
                } else {
                    stringPath = consentData[indexPath.row].document_pages[0].url_original
                }
                
                let url = URL(string: stringPath)
                
                imvDoc.sd_setImage(with: url) { (image, error, cachetype, url) in
                    if (error != nil) {
                        //Failure code here
                        showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    SVProgressHUD.dismiss()
                }
                
                showPageNumberAndDate(pageNo: consentData[indexPath.row].document_pages.count,showCreate: true,createdTime: consentData[indexPath.row].created_at)
            } else {
                
                let urlEdit = URL(string: counsellingData[indexPath.row].document_pages[0].url_edit)
                if urlEdit != nil {
                    stringPath = counsellingData[indexPath.row].document_pages[0].url_edit
                } else {
                    stringPath = counsellingData[indexPath.row].document_pages[0].url_original
                }
                
                let url = URL(string: stringPath)
                
                imvDoc.sd_setImage(with: url) { (image, error, cachetype, url) in
                    if (error != nil) {
                        //Failure code here
                        showAlert(message: "写真の読み込みに失敗しました。ネットワークの状態を確認してください。", view: self)
                    }
                    SVProgressHUD.dismiss()
                }
                
                showPageNumberAndDate(pageNo: counsellingData[indexPath.row].document_pages.count,showCreate: true,createdTime: counsellingData[indexPath.row].created_at)
            }
        default:
            break
        }
    }
}

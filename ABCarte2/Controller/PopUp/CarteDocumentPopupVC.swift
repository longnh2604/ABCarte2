//
//  CarteDocumentPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2019/01/08.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol CarteDocumentPopupVCDelegate: class {
    func onDocSelected(document:DocumentData,carteID:Int)
}

class CarteDocumentPopupVC: UIViewController {

    //Variable
    weak var delegate:CarteDocumentPopupVCDelegate?
    
    var documents: Results<DocumentData>!
    var consentData : [DocumentData] = []
    var consentTempData: [DocumentData] = []
    var counsellingData : [DocumentData] = []
    var counsellingTempData : [DocumentData] = []
    var handwrittingData : [DocumentData] = []
    var handwrittingTempData : [DocumentData] = []
    var outlineData : [DocumentData] = []
    var outlineTempData : [DocumentData] = []
    
    var carteID: Int?
    
    //IBOutlet
    @IBOutlet weak var viewConsent: RoundUIView!
    @IBOutlet weak var tblConsent: UITableView!
    @IBOutlet weak var viewCounselling: RoundUIView!
    @IBOutlet weak var tblCounselling: UITableView!
    @IBOutlet weak var viewHandwrittingCarte: RoundUIView!
    @IBOutlet weak var tblHandwrittingCarte: UITableView!
    @IBOutlet weak var viewOutlineDoc: RoundUIView!
    @IBOutlet weak var tblOutlineDoc: UITableView!
    
    @IBOutlet weak var viewNormallyDoc: UIStackView!
    @IBOutlet weak var viewAdditionDoc: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    func setupUI() {
        let nib = UINib(nibName: "DocumentCell", bundle: nil)
        tblConsent.register(nib, forCellReuseIdentifier: "DocumentCell")
        tblCounselling.register(nib, forCellReuseIdentifier: "DocumentCell")
        tblHandwrittingCarte.register(nib, forCellReuseIdentifier: "DocumentCell")
        tblOutlineDoc.register(nib, forCellReuseIdentifier: "DocumentCell")
        
        tblConsent.delegate = self
        tblConsent.dataSource = self
        tblConsent.tableFooterView = UIView()
        tblConsent.tag = DocType.Consent.rawValue
        
        tblCounselling.delegate = self
        tblCounselling.dataSource = self
        tblCounselling.tableFooterView = UIView()
        tblCounselling.tag = DocType.Counselling.rawValue
        
        tblHandwrittingCarte.delegate = self
        tblHandwrittingCarte.dataSource = self
        tblHandwrittingCarte.tableFooterView = UIView()
        tblHandwrittingCarte.tag = DocType.Handwritting.rawValue
        
        tblOutlineDoc.delegate = self
        tblOutlineDoc.dataSource = self
        tblOutlineDoc.tableFooterView = UIView()
        tblOutlineDoc.tag = DocType.Outline.rawValue
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kAdditionalDoc.rawValue) {
            //do nothing
        } else {
            viewAdditionDoc.isHidden = true
            viewHandwrittingCarte.isHidden = true
            viewOutlineDoc.isHidden = true
        }
        
        loadData()
    }
    
    func loadData() {
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        //remove before get new
        consentData.removeAll()
        counsellingData.removeAll()
        handwrittingData.removeAll()
        outlineData.removeAll()
        
        let realm = RealmServices.shared.realm
        try! realm.write {
            realm.delete(realm.objects(DocumentData.self))
        }
        
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
                                    self.counsellingTempData.append(self.documents[i])
                                } else {
                                    self.counsellingData.append(self.documents[i])
                                }
                            }
                            
                            if self.documents[i].type == 2 {
                                if self.documents[i].is_template == 1 {
                                    self.consentTempData.append(self.documents[i])
                                } else {
                                    self.consentData.append(self.documents[i])
                                }
                            }
                            
                            if self.documents[i].type == 3 {
                                if self.documents[i].is_template == 1 {
                                    self.handwrittingTempData.append(self.documents[i])
                                } else {
                                    self.handwrittingData.append(self.documents[i])
                                }
                            }
                            
                            if self.documents[i].type == 4 {
                                if self.documents[i].is_template == 1 {
                                    self.outlineTempData.append(self.documents[i])
                                } else {
                                    self.outlineData.append(self.documents[i])
                                }
                            }
                        }
                        
                        self.tblConsent.reloadData()
                        self.tblCounselling.reloadData()
                        self.tblHandwrittingCarte.reloadData()
                        self.tblOutlineDoc.reloadData()
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
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - TableView Delegate, Datasource
//*****************************************************************

extension CarteDocumentPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView.tag {
        case DocType.Consent.rawValue:
            return consentTempData.count
        case DocType.Counselling.rawValue:
            return counsellingTempData.count
        case DocType.Handwritting.rawValue:
            return handwrittingTempData.count
        case DocType.Outline.rawValue:
            return outlineTempData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DocumentCell.self)) as! DocumentCell
        
        switch tableView.tag {
        case DocType.Consent.rawValue:
            for i in 0 ..< consentData.count {
                if consentData[i].sub_type == consentTempData[indexPath.row].sub_type {
                    cell.configure(title: consentData[i].title,edited:true)
                    break
                }
            }
            cell.configure(title: consentTempData[indexPath.row].title, edited: false)
        case DocType.Counselling.rawValue:
            for i in 0 ..< counsellingData.count {
                if counsellingData[i].sub_type == counsellingTempData[indexPath.row].sub_type {
                    cell.configure(title: counsellingData[i].title,edited:true)
                    break
                }
            }
            cell.configure(title: counsellingTempData[indexPath.row].title, edited: false)
        case DocType.Handwritting.rawValue:
            for i in 0 ..< handwrittingData.count {
                if handwrittingData[i].sub_type == handwrittingTempData[indexPath.row].sub_type {
                    cell.configure(title: handwrittingData[i].title,edited:true)
                    break
                }
            }
            cell.configure(title: handwrittingTempData[indexPath.row].title, edited: false)
        case DocType.Outline.rawValue:
            for i in 0 ..< outlineData.count {
                if outlineData[i].sub_type == outlineTempData[indexPath.row].sub_type {
                    cell.configure(title: outlineData[i].title,edited:true)
                    break
                }
            }
            cell.configure(title: outlineTempData[indexPath.row].title, edited: false)
        default:
            break
        }
        
        cell.btnCell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellNo = indexPath.row as Int?,let tableNo = tableView.tag as Int? else { return }
        
        //deselect before present popup
        switch tableNo {
        case DocType.Consent.rawValue:
            tblConsent.deselectRow(at: indexPath, animated: false)
        case DocType.Counselling.rawValue:
            tblCounselling.deselectRow(at: indexPath, animated: false)
        case DocType.Handwritting.rawValue:
            tblHandwrittingCarte.deselectRow(at: indexPath, animated: false)
        case DocType.Outline.rawValue:
            tblOutlineDoc.deselectRow(at: indexPath, animated: false)
        default:
            break
        }
        
        onDocSelected(cellIndex: cellNo, tableIndex: tableNo)
    }
    
    func onDocSelected(cellIndex: Int,tableIndex: Int) {
        let newPopup = DocumentPreviewPopup(nibName: "DocumentPreviewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        newPopup.carteID = carteID
        newPopup.delegate = self
        
        switch tableIndex {
        case DocType.Consent.rawValue:
            for i in 0 ..< consentData.count {
                if consentData[i].sub_type == consentTempData[cellIndex].sub_type {
                    newPopup.documentsData = self.consentData[i]
                    newPopup.isTemp = false
                    self.present(newPopup, animated: true, completion: nil)
                    return
                }
            }
            newPopup.documentsData = self.consentTempData[cellIndex]
            newPopup.isTemp = true
        case DocType.Counselling.rawValue:
            for i in 0 ..< counsellingData.count {
                if counsellingData[i].sub_type == counsellingTempData[cellIndex].sub_type {
                    newPopup.documentsData = self.counsellingData[i]
                    newPopup.isTemp = false
                    self.present(newPopup, animated: true, completion: nil)
                    return
                }
            }
            newPopup.documentsData = self.counsellingTempData[cellIndex]
            newPopup.isTemp = true
        case DocType.Handwritting.rawValue:
            for i in 0 ..< handwrittingData.count {
                if handwrittingData[i].sub_type == handwrittingTempData[cellIndex].sub_type {
                    newPopup.documentsData = self.handwrittingData[i]
                    newPopup.isTemp = false
                    self.present(newPopup, animated: true, completion: nil)
                    return
                }
            }
            newPopup.documentsData = self.handwrittingTempData[cellIndex]
            newPopup.isTemp = true
        case DocType.Outline.rawValue:
            for i in 0 ..< outlineData.count {
                if outlineData[i].sub_type == outlineTempData[cellIndex].sub_type {
                    newPopup.documentsData = self.outlineData[i]
                    newPopup.isTemp = false
                    self.present(newPopup, animated: true, completion: nil)
                    return
                }
            }
            newPopup.documentsData = self.outlineTempData[cellIndex]
            newPopup.isTemp = true
        default:
            break
        }
        self.present(newPopup, animated: true, completion: nil)
    }
}

extension CarteDocumentPopupVC: DocumentPreviewPopupDelegate {
    func onEditDocument(document: DocumentData, carteID: Int) {
        dismiss(animated: true) {
            self.delegate?.onDocSelected(document: document, carteID: carteID)
        }
    }
}

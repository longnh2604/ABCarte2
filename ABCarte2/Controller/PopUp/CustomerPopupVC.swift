//
//  CustomerPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/11.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

protocol CustomerPopupVCDelegate: class {
    func didConfirm(type:Int)
}

class CustomerPopupVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //Variable
    weak var delegate:CustomerPopupVCDelegate?
    
    var popupType: Int?
    var customer = CustomerData()
    var language: Int? = 0
    var imagePicker = UIImagePickerController()
    var genderSelect: Int? = 0
    var bloodSelect: Int? = 0
    var birthDate: Date? = nil
    var imageTemp: UIImage? = nil
    
    //IBOutlet
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSetPhoto: UIButton!
    @IBOutlet weak var btnBirthday: UIButton!
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var btnBloodType: UIButton!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var tfFName: UITextField!
    @IBOutlet weak var tfLName: UITextField!
    @IBOutlet weak var tfFNameKana: UITextField!
    @IBOutlet weak var tfLNameKana: UITextField!
    @IBOutlet weak var tfCusNumber: UITextField!
    @IBOutlet weak var tfPostalCode: UITextField!
    @IBOutlet weak var tfPrefecture: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfSubAdd1: UITextField!
    @IBOutlet weak var tfSubAdd2: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfMail: UITextField!
    @IBOutlet weak var tfHobby: UITextField!
    @IBOutlet weak var tvMemo: UITextView!
    @IBOutlet weak var tfResponsible: UITextField!
    @IBOutlet weak var tfEntry: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblKana: UILabel!
    @IBOutlet weak var lblCusNumber: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var lblMailNote: UILabel!
    @IBOutlet weak var lblBloodType: UILabel!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var lblMemo: UILabel!
    @IBOutlet weak var lblResponsible: UILabel!
    @IBOutlet weak var lblEntry: UILabel!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupUI()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    func setupUI() {
////        let realm = RealmServices.shared.realm
////        customers = realm.objects(CustomerData.self)
////        customers = customers!.sorted(byKeyPath: "cusFName", ascending: false)
//
//        tvMemo.layer.cornerRadius = 10
//        tvMemo.clipsToBounds = true
//
//        btnConfirm.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)
//        btnCancel.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
//        btnSetPhoto.addTarget(self, action: #selector(onSetPhoto), for: .touchUpInside)
//        btnBirthday.addTarget(self, action: #selector(onSetBirthday(_:)), for: .touchUpInside)
//        btnAddress.addTarget(self, action: #selector(onSetAddress), for: .touchUpInside)
//        btnBloodType.addTarget(self, action: #selector(onSetBloodType), for: .touchUpInside)
//
//        changeButtonText()
//
//        if (index != nil) {
//            tfFName.text = customers[index!].cusFName
//            tfFNameKana.text = customers[index!].cusFNameKana
//            tfLName.text = customers[index!].cusLName
//            tfLNameKana.text = customers[index!].cusLNameKana
//
//            btnBirthday.setTitle(convertUnixTimestamp(time: customers[index!].cusBirth), for: .normal)
//            birthDate = Date(timeIntervalSince1970: TimeInterval(customers[index!].cusBirth))
//
//            if customers[index!].cusGenre != 0 {
//                btnMale.setImage(UIImage(named: "radioBlueSelectedIcon"), for: .normal)
//                btnFemale.setImage(UIImage(named: "radioRedIcon"), for: .normal)
//                genreSelect = 1
//            } else {
//                btnMale.setImage(UIImage(named: "radioBlueIcon"), for: .normal)
//                btnFemale.setImage(UIImage(named: "radioRedSelectedIcon"), for: .normal)
//                genreSelect = 0
//            }
//
//            tfPostalCode.text = "\(customers[index!].cusPostalCode)"
//
//            tfPrefecture.text = customers[index!].cusPrefectures
//            tfCity.text = customers[index!].cusCity
//            tfSubAdd1.text = customers[index!].cusSubAdd1
//            tfSubAdd2.text = customers[index!].cusSubAdd2
//
//            tfMobile.text = "\(customers[index!].cusMobile)"
//            tfPhone.text = "\(customers[index!].cusPhone)"
//            tfMail.text = "\(customers[index!].cusEmail)"
//
//            tfHobby.text = "\(customers[index!].cusHobby)"
//            tvMemo.text = "\(customers[index!].cusMemo)"
//            tfResponsible.text = "\(customers[index!].cusResponsible)"
//            tfCusNumber.text = "\(customers[index!].cusNo)"
//
//            btnBloodType.setTitle(checkBloodType(type: customers[index!].cusBloodType), for: .normal)
//            print(customers[index!].cusPicURL)
//            if customers[index!].cusPicURL != "" {
//                imvCus.image = UIImage(contentsOfFile: customers[index!].cusPicURL)
//            } else {
//                imvCus.image = UIImage(named: "nophotoIcon")
//            }
//            imvCus.layer.cornerRadius = 5
//            imvCus.clipsToBounds = true
//        }
//    }
//
//    func changeButtonText() {
//        if popupType == PopUpType.Edit.rawValue {
//            if language == 0 {
//                btnConfirm.setTitle("更 新", for: .normal)
//            } else {
//                btnConfirm.setTitle("Update", for: .normal)
//            }
//        }
//        if popupType == PopUpType.AddNew.rawValue {
//            if language == 0 {
//                btnConfirm.setTitle("登 録", for: .normal)
//            } else {
//                btnConfirm.setTitle("Register", for: .normal)
//            }
//        }
//        if popupType == PopUpType.Review.rawValue {
//            btnConfirm.setTitle("OK", for: .normal)
//        }
//    }
//
//    func validatePostalCode()->Bool {
//        if (tfPostalCode.text?.isNumber())! {
//            return true
//        } else {
//            showAlert(message: "Please Check your Postal Code", view: self)
//            return false
//        }
//    }
//
//    func updateData() {
//        var birthTime = 0
//        if birthDate != nil {
//            birthTime = Int((birthDate?.timeIntervalSince1970)!)
//        }
//
//        var urlpath: String = ""
//        if customers[index!].cusPicURL == "" {
//            if imageTemp != nil {
//                let url = saveImageToLocal(imageDownloaded: imageTemp!, name: self.customers[self.index!].cusID)
//                print(url.path)
//                urlpath = url.path
//            }
//        } else {
//            urlpath = customers[index!].cusPicURL
//        }
//
//        let dict : [String : Any?] = ["cusFName" : tfFName.text,
//                                      "cusLName" : tfLName.text,
//                                      "cusFNameKana": tfFNameKana.text,
//                                      "cusLNameKana": tfLNameKana.text,
//                                      "cusPostalCode": tfPostalCode.text,
//                                      "cusGenre":genreSelect,
//                                      "cusBirth":birthTime,
//                                      "cusPicURL":urlpath,
//                                      "cusBloodType":bloodSelect,
//                                      "cusHobby":tfHobby.text,
//                                      "cusPhone":tfPhone.text,
//                                      "cusMobile":tfMobile.text,
//                                      "cusPrefectures":tfPrefecture.text,
//                                      "cusCity":tfCity.text,
//                                      "cusSubAdd1":tfSubAdd1.text,
//                                      "cusSubAdd2":tfSubAdd2.text,
//                                      "cusEmail":tfMail.text,
//                                      "cusMemo":tvMemo.text,
//                                      "cusResponsible":tfResponsible.text,
//                                      "cusNo":tfCusNumber.text]
//        RealmServices.shared.update(customers[index!], with: dict)
//        delegate.didConfirm(type: 2)
//        dismiss(animated: true, completion: nil)
//    }
//
//    func addData() {
//        if (tfFName.text?.isEmpty)! || (tfLName.text?.isEmpty)! {
//            showAlert(message: "Please at least input full customer's name", view: self)
//            return
//        }
//
//        var lastID: Int = 0
//        if customers.sorted(byKeyPath: "ID").last?.ID != nil {
//            lastID = (customers.sorted(byKeyPath: "ID").last?.ID)! + 1
//        }
//
//        var birthTime = 0
//        if birthDate != nil {
//            birthTime = Int((birthDate?.timeIntervalSince1970)!)
//        }
//
//        var url:URL? = nil
//        if imageTemp != nil {
//            url = saveImageToLocal(imageDownloaded: imageTemp!, name: String(lastID))
//        }
//
//        let newCustomer = CustomerData(ID: lastID, cusID: "customer\(lastID)", cusFName: tfFName.text!, cusFNameKana: tfFNameKana.text!, cusLName: tfLName.text!, cusLNameKana: tfLNameKana.text!, cusGenre: genreSelect!, cusBirth: birthTime, cusPicURL:url?.path ?? "", cusBloodType: bloodSelect!, cusHobby: tfHobby.text!, cusPhone: tfPhone.text!, cusMobile: tfMobile.text!, cusPostalCode: tfPostalCode.text!, cusPrefectures: tfPrefecture.text!, cusCity: tfCity.text!, cusSubAdd1: tfSubAdd1.text!, cusSubAdd2: tfSubAdd2.text!, cusEmail: tfMail.text!, cusMemo: tvMemo.text!, cusResponsible: tfResponsible.text!, cusNo: tfCusNumber.text!,selectedStatus:0)
//
//        RealmServices.shared.create(newCustomer)
//        delegate.didConfirm(type: 1)
//        dismiss(animated: true, completion: nil)
//    }
//
//    func reloadAvatar(photo: UIImage) {
//        imvCus.image = photo
//    }
//
//    func changeLanguage(mode: Int) {
//        switch mode {
//        case 0:
//            lblTitle.text = "お客様を新規作成します。必要事項を記入してください。"
//            lblName.text = "名 前"
//            lblKana.text = "か な"
//            lblCusNumber.text = "お客様番号"
//            lblAddress.text = "住 所"
//            lblGenre.text = "性 別"
//            lblMale.text = "男性"
//            lblFemale.text = "女性"
//            lblBirthday.text = "生年月日"
//            lblPhone.text = "電 話"
//            lblMobile.text = "携 帯"
//            lblMail.text = "メール"
//            lblMailNote.text = "メール受信許可"
//            lblBloodType.text = "血液型"
//            lblHobby.text = "趣味"
//            lblMemo.text = "メモ"
//            lblResponsible.text = "担当"
//            lblEntry.text = "記 入"
//
//            btnSetPhoto.setTitle("画像挿入", for: .normal)
//            btnAddress.setTitle("住所変換", for: .normal)
//            btnCancel.setTitle("取 消", for: .normal)
//
//            tfFName.placeholder = "名を入力"
//            tfLName.placeholder = "姓を入力"
//            tfFNameKana.placeholder = "めい"
//            tfLNameKana.placeholder = "せい"
//            tfPostalCode.placeholder = "郵便番号(ハイフンなし)"
//            tfPrefecture.placeholder = "都道府県"
//            tfCity.placeholder = "市区町村/郡"
//            tfSubAdd1.placeholder = " 以 降 の井 住 上所"
//            tfSubAdd2.placeholder = "マンション・建物名・号室"
//            tfPhone.placeholder = "設定されていません"
//            tfMobile.placeholder = "設定されていません"
//            tfMail.placeholder = "設定されていません"
//            tfResponsible.placeholder = "名前を入力"
//            tfEntry.placeholder = "名前を入力"
//        case 1:
//            lblTitle.text = "Please fill out the necessary information to create a New Customer"
//            lblName.text = "Name"
//            lblKana.text = "Kana"
//            lblCusNumber.text = "CustomerID"
//            lblAddress.text = "Address"
//            lblGenre.text = "Genre"
//            lblMale.text = "Male"
//            lblFemale.text = "Female"
//            lblBirthday.text = "Birthday"
//            lblPhone.text = "Phone"
//            lblMobile.text = "Mobile"
//            lblMail.text = "Email"
//            lblMailNote.text = "Mailbox Reception Permission"
//            lblBloodType.text = "BloodType"
//            lblHobby.text = "Hobby"
//            lblMemo.text = "Memo"
//            lblResponsible.text = "Responsible"
//            lblEntry.text = "Entry"
//
//            btnSetPhoto.setTitle("Add Photo", for: .normal)
//            btnAddress.setTitle("Convert", for: .normal)
//            btnCancel.setTitle("Cancel", for: .normal)
//
//            tfFName.placeholder = "First Name"
//            tfLName.placeholder = "Last Name"
//            tfFNameKana.placeholder = "First Name Kana"
//            tfLNameKana.placeholder = "Last Name Kana"
//            tfPostalCode.placeholder = "Postal Code"
//            tfPrefecture.placeholder = "Prefecture"
//            tfCity.placeholder = "City / Town / County"
//            tfSubAdd1.placeholder = "Street"
//            tfSubAdd2.placeholder = "Apartment / Building name / Room number"
//            tfPhone.placeholder = "Not set"
//            tfMobile.placeholder = "Not set"
//            tfMail.placeholder = "Not set"
//            tfResponsible.placeholder = "Input Name"
//            tfEntry.placeholder = "Input Name"
//        default:
//            break
//        }
//        changeButtonText()
//    }
//
//    //*****************************************************************
//    // MARK: - Actions
//    //*****************************************************************
//
//    @IBAction func onLanguageChange(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            print("first segement clicked")
//            language = 0
//            changeLanguage(mode: language!)
//        case 1:
//            print("second segment clicked")
//            language = 1
//            changeLanguage(mode: language!)
//        default:
//            language = 0
//            changeLanguage(mode: language!)
//            break;
//        }
//    }
//
//    @IBAction func onGenreSet(_ sender: UIButton) {
//        if sender.tag == 1 {
//            btnMale.setImage(UIImage(named: "radioBlueSelectedIcon"), for: .normal)
//            btnFemale.setImage(UIImage(named: "radioRedIcon"), for: .normal)
//            genreSelect = 1
//        } else {
//            btnMale.setImage(UIImage(named: "radioBlueIcon"), for: .normal)
//            btnFemale.setImage(UIImage(named: "radioRedSelectedIcon"), for: .normal)
//            genreSelect = 0
//        }
//    }
//
//    @objc func onConfirm() {
//        if popupType == PopUpType.Edit.rawValue  {
////            let success = validatePostalCode()
////
////            if success {
////                updateData()
////            }
//            updateData()
//        } else {
//            addData()
//        }
//    }
//
//    @objc func onCancel() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @objc func onSetPhoto() {
//        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let takeNew = UIAlertAction(title: "写真を撮る", style: .default) { UIAlertAction in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//                self.imagePicker.cameraCaptureMode = .photo
//                self.imagePicker.allowsEditing = false
//                self.present(self.imagePicker,animated: true,completion: nil)
//            } else {
//                showAlert(message: "No Camera", view: self)
//            }
//        }
//        let selectPhoto = UIAlertAction(title: "デバイスから写真を選択", style: .default) { UIAlertAction in
//            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
//
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//                self.imagePicker.allowsEditing = false
//
//                self.present(self.imagePicker, animated: true, completion: nil)
//            }
//        }
//        alert.addAction(cancel)
//        alert.addAction(takeNew)
//        alert.addAction(selectPhoto)
//
//        alert.popoverPresentationController?.sourceView = self.btnSetPhoto
//        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//        alert.popoverPresentationController?.sourceRect = self.btnSetPhoto.bounds
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        self.dismiss(animated: true, completion: { () -> Void in
//            print("image data = \(String(describing: image))")
//            let imgRotated = image?.updateImageOrientionUpSide()
//
//            if self.popupType == PopUpType.Edit.rawValue || self.popupType == PopUpType.Review.rawValue {
////                let url = saveImageToLocal(imageDownloaded: imgRotated!, name: self.customers[self.index!].cusID)
////                print(url.path)
////                let dict : [String : Any?] = ["cusPicURL" : url.path]
////                RealmServices.shared.update(self.customers[self.index!], with: dict)
//                self.imageTemp = imgRotated
//            } else {
//                self.imageTemp = imgRotated
//            }
//            self.reloadAvatar(photo: image!)
//        })
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @objc func onSetBirthday(_ sender: UIButton) {
//        let datePicker = UIDatePicker()//Date picker
//        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
//        datePicker.datePickerMode = .date
//        datePicker.minuteInterval = 5
//        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
//
//        let popoverView = UIView()
//        popoverView.backgroundColor = UIColor.clear
//        popoverView.addSubview(datePicker)
//        // here you can add tool bar with done and cancel buttons if required
//
//        let popoverViewController = UIViewController()
//        popoverViewController.view = popoverView
//        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
//        popoverViewController.modalPresentationStyle = .popover
//        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
//        popoverViewController.popoverPresentationController?.sourceView = sender // source button
//        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
//        self.present(popoverViewController, animated: true, completion: nil)
//    }
//
//    @objc func dateChanged(_ datePicker: UIDatePicker) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy年MM月dd日"
//        print("DATE :: \(datePicker.date)")
//        birthDate = datePicker.date
//        btnBirthday.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
//    }
//
//    @objc func onSetAddress() {
//        performGoogleSearch(code: tfPostalCode.text!)
//    }
//
//    func performGoogleSearch(code: String) {
//        let components = URLComponents(string: "http://maps.googleapis.com/maps/api/geocode/json?address=&components=postal_code:\(code)&sensor=false&language=ja")!
//
//        Alamofire.request(components, method: .get, parameters: nil, encoding: URLEncoding.default)
//            .responseJSON { response in
//                print(response)
//                guard response.result.isSuccess else {
//                    showAlert(message: "郵便番号が正しくありません。", view: self)
//                    return
//                }
//
//                guard let value = response.result.value as? [String: Any],
//                    let status = value["status"] as? String,
//                    status == "OK" else {
//                        showAlert(message: "Can not find out", view: self)
//                        self.tfPrefecture.text = ""
//                        self.tfCity.text = ""
//                        self.tfSubAdd1.text = ""
//                        return
//                }
//
//                if let arr = value["results"] as? NSArray {
//                    if let firstResult = arr[0] as? NSDictionary {
//                        if let addComps = firstResult["address_components"] as? NSArray {
//                            if let prefecture = addComps[3] as? NSDictionary {
//                                self.tfPrefecture.text = prefecture["long_name"] as? String
//                            }
//                            if let city = addComps[2] as? NSDictionary {
//                                self.tfCity.text = city["long_name"] as? String
//                            }
//                            if let subAdd1 = addComps[1] as? NSDictionary {
//                                self.tfSubAdd1.text = subAdd1["long_name"] as? String
//                            }
//                        }
//                    }
//                }
//        }
//    }
//
//    @objc func onSetBloodType() {
//        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        let bloodA = UIAlertAction(title: "A 型", style: .default) { UIAlertAction in
//            self.btnBloodType.setTitle("A 型", for: .normal)
//            self.bloodSelect = 1
//        }
//        let bloodB = UIAlertAction(title: "B 型", style: .default) { UIAlertAction in
//            self.btnBloodType.setTitle("B 型", for: .normal)
//            self.bloodSelect = 2
//        }
//        let bloodO = UIAlertAction(title: "O 型", style: .default) { UIAlertAction in
//            self.btnBloodType.setTitle("O 型", for: .normal)
//            self.bloodSelect = 3
//        }
//        let bloodAB = UIAlertAction(title: "AB 型", style: .default) { UIAlertAction in
//            self.btnBloodType.setTitle("AB 型", for: .normal)
//            self.bloodSelect = 4
//        }
//        let bloodUndefined = UIAlertAction(title: "不明", style: .default) { UIAlertAction in
//            self.btnBloodType.setTitle("不明", for: .normal)
//            self.bloodSelect = 0
//        }
//        alert.addAction(cancel)
//        alert.addAction(bloodA)
//        alert.addAction(bloodB)
//        alert.addAction(bloodO)
//        alert.addAction(bloodAB)
//        alert.addAction(bloodUndefined)
//        alert.popoverPresentationController?.sourceView = self.btnBloodType
//        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//        alert.popoverPresentationController?.sourceRect = self.btnBloodType.bounds
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
}

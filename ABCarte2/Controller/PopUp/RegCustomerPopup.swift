//
//  RegCustomerPopup.swift
//  ABCarte2
//
//  Created by Long on 2018/07/24.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SDWebImage
import SwiftyJSON

protocol RegCustomerPopupDelegate: class {
    func didConfirm(type:Int)
}

class RegCustomerPopup: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate, SecretPopupVCDelegate {

    //Variable
    weak var delegate:RegCustomerPopupDelegate?
    
    var customer = CustomerData()
    var language: Int = 0
    var popupType: Int?
    var imagePicker = UIImagePickerController()
    var imageTemp: UIImage? = nil
    var imageConverted: Data?
    var birthDate: Int = 0
    var bloodSelect: Int = 0
    var genderSelect: Int = 0
    var cusIndex: Int?
    var onProgress: Bool = false
    var lat: Double = 0
    var long: Double = 0
    var isEdit: Bool = false
    var dateString : String?
    
    //IBOutlet
    @IBOutlet weak var viewContent: RoundUIView!
    @IBOutlet var viewEssential: UIView!
    @IBOutlet var viewPrivate: UIView!
    @IBOutlet var viewNote: UIView!
    @IBOutlet weak var btnEssential: RoundButton!
    @IBOutlet weak var btnPrivate: RoundButton!
    @IBOutlet weak var btnNote: RoundButton!
    @IBOutlet weak var lblDayCreate: UILabel!
    @IBOutlet weak var lblDayEdit: RoundLabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnConfirm: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    @IBOutlet weak var btnPreview: RoundButton!
    
    //Essential
    @IBOutlet weak var radioName: RoundUIView!
    @IBOutlet weak var radioNameKana: RoundUIView!
    @IBOutlet weak var radioCusNo: RoundUIView!
    @IBOutlet weak var radioEmergency: RoundUIView!
    @IBOutlet weak var radioResponsible: RoundUIView!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastNameKana: UITextField!
    @IBOutlet weak var tfFirstNameKana: UITextField!
    @IBOutlet weak var tfCusNo: UITextField!
    @IBOutlet weak var tfEmergency: UITextField!
    @IBOutlet weak var tfResponsible: UITextField!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameKana: UILabel!
    @IBOutlet weak var lblCusNo: UILabel!
    @IBOutlet weak var lblEmergency: UILabel!
    @IBOutlet weak var lblResponsible: UILabel!
    @IBOutlet weak var btnUSA: UIButton!
    @IBOutlet weak var btnChina: UIButton!
    @IBOutlet weak var btnKorea: UIButton!
    
    //Private
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var btnGender: RoundButton!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var btnBirthday: RoundButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var tfPostalCode: UITextField!
    @IBOutlet weak var btnAddConvert: RoundButton!
    @IBOutlet weak var tfPrefecture: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfSubAdd: UITextField!
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var tfMail: UITextField!
    @IBOutlet weak var swMailReceive: UISwitch!
    @IBOutlet weak var lblMailReceive: UILabel!
    @IBOutlet weak var lblBloodType: UILabel!
    @IBOutlet weak var btnBloodType: RoundButton!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var btnAddPhoto: RoundButton!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var tvHobby: UITextView!
    @IBOutlet weak var tfAge: UITextField!
    
    //Note
    @IBOutlet weak var lblNote1: UILabel!
    @IBOutlet weak var tvNote1: UITextView!
    @IBOutlet weak var lblNote2: UILabel!
    @IBOutlet weak var tvNote2: UITextView!
    @IBOutlet weak var tfSecretCode: UITextField!
    @IBOutlet weak var btnSecretAccess: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        
        setupUI()
    }

    func loadData() {
        if popupType == PopUpType.Edit.rawValue || popupType == PopUpType.Review.rawValue {
            let dayCreate = convertUnixTimestamp(time: customer.created_at)
            lblDayCreate.text = "作成日: \(dayCreate + getDayOfWeek(dayCreate)!)"
            
            let dayUpdate = convertUnixTimestamp(time: customer.updated_at)
            lblDayEdit.text = "最終更新日: \(dayUpdate + getDayOfWeek(dayUpdate)!)"
        } else {
            lblDayCreate.isHidden = true
            lblDayEdit.isHidden = true
        }
    }
    
    func setupUI() {
        viewContent.addSubview(viewEssential)
        tfFirstName.delegate = self
        tfLastName.delegate = self
        tfFirstNameKana.delegate = self
        tfLastNameKana.delegate = self
        tfCusNo.delegate = self
        tfEmergency.delegate = self
        tfResponsible.delegate = self
        tfMail.delegate = self
        
        changeLanguage(mode: language)
        
        resetAllButtonState()
        btnEssential.alpha = 1
        
        //check if open exist user
        if popupType == PopUpType.Edit.rawValue {
            //Essential
            tfLastName.text = customer.last_name
            tfFirstName.text = customer.first_name
            tfLastNameKana.text = customer.last_name_kana
            tfFirstNameKana.text = customer.first_name_kana
            tfCusNo.text = customer.customer_no
            tfEmergency.text = customer.urgent_no
            tfResponsible.text = customer.responsible
            
            //Private
            if customer.gender == 0 {
                btnGender.setTitle("不明", for: .normal)
                genderSelect = 0
            } else if customer.gender == 1 {
                btnGender.setTitle("男性", for: .normal)
                genderSelect = 1
            } else {
                btnGender.setTitle("女性", for: .normal)
                genderSelect = 2
            }
        
            if customer.birthday == 0 {
                btnBirthday.setTitle("不明", for: .normal)
            } else {
                btnBirthday.setTitle(convertUnixTimestamp(time: customer.birthday), for: .normal)
                birthDate = customer.birthday
                
                let dateB = Date(timeIntervalSince1970: TimeInterval(customer.birthday))
                if let age = Calendar.current.dateComponents([.year], from: dateB, to: Date()).year {
                    tfAge.text = "\(age) 歳"
                }
            }

            tfPostalCode.text = customer.postal_code
            tfPrefecture.text = customer.address1
            tfCity.text = customer.address2
            tfSubAdd.text = customer.address3
            tfMail.text = customer.email
            
            btnBloodType.setTitle(checkBloodType(type: customer.bloodtype), for: .normal)
            bloodSelect = customer.bloodtype
            
            if customer.thumb != "" {
                let url = URL(string: customer.thumb)
                imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
            } else {
                imvCus.image = UIImage(named: "nophotoIcon")
            }
            imvCus.layer.cornerRadius = 5
            imvCus.clipsToBounds = true
            
            tvHobby.text = customer.hobby

            //Note
            tvNote1.text = customer.memo1
            tvNote2.text = customer.memo2
           
            checkCondition()
            
            enableUserInput(status: false)
        }
        
        checkAccType()
    }
    
    func checkAccType() {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMultiLanguage.rawValue) {
            btnUSA.isHidden = false
            btnChina.isHidden = false
            btnKorea.isHidden = false
        } else {
            btnUSA.isHidden = true
            btnChina.isHidden = true
            btnKorea.isHidden = true
        }
    }
    
    func checkCondition() {
        if (tfFirstName.text?.count)! > 0 && (tfLastName.text?.count)! > 0 {
            radioName.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfFirstNameKana.text?.count)! > 0 && (tfLastNameKana.text?.count)! > 0 {
            radioNameKana.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfCusNo.text?.count)! > 0 {
            radioCusNo.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfEmergency.text?.count)! > 0 {
            radioEmergency.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
        if (tfResponsible.text?.count)! > 0 {
            radioResponsible.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        }
    }
    
    func removeView() {
        if viewContent.subviews.count > 0 {
            for subview in viewContent.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    func changeLanguage(mode: Int) {
        
        let dayCreate = convertUnixTimestamp(time: customer.created_at)
        let dayUpdate = convertUnixTimestamp(time: customer.updated_at)
        
        switch mode {
        case 0:
            //general
            lblTitle.text = "顧客情報を登録/編集"
            btnEssential.setTitle("必須事項", for: .normal)
            btnPrivate.setTitle("プライベート情報", for: .normal)
            btnNote.setTitle("備考", for: .normal)
            btnConfirm.setTitle("登 録", for: .normal)
            btnCancel.setTitle("取 消", for: .normal)
            btnPreview.setTitle("登録情報一覧", for: .normal)
            
            //essential
            lblName.text = "名     前"
            lblNameKana.text = "か     な"
            lblCusNo.text = "顧  客  番  号"
            lblEmergency.text = "緊  急  連  絡  先"
            lblResponsible.text = "担  当  者"
            tfLastName.placeholder = "(姓を入力)"
            tfFirstName.placeholder = "(名を入力)"
            tfLastNameKana.placeholder = "(せい)"
            tfFirstNameKana.placeholder = "(めい)"
            tfCusNo.placeholder = "(入力)"
            tfEmergency.placeholder = "(電話番号入力(ハイフンなし)"
            tfResponsible.placeholder = "(名前を入力)"
            
            //private
            lblGender.text = "性 別"
            btnGender.setTitle("未登録", for: .normal)
            lblBirthday.text = "生年月日"
            btnBirthday.setTitle("未登録", for: .normal)
            lblAddress.text = "住所"
            tfPostalCode.placeholder = "郵便番号"
            btnAddConvert.setTitle("住所変換", for: .normal)
            tfPrefecture.placeholder = "都道府県"
            tfCity.placeholder = "市区町村/郡"
            tfSubAdd.placeholder = "マンション・建物名・号室"
            lblMail.text = "メ ー ル"
            tfMail.placeholder = "設定されていません"
            lblMailReceive.text = "メール受信許可"
            lblBloodType.text = "血液型"
            btnBloodType.setTitle("未登録", for: .normal)
            btnAddPhoto.setTitle("画像挿入", for: .normal)
            lblHobby.text = "趣味"
            
            //note
            lblNote1.text = "備考 1"
            lblNote2.text = "備考 2"
            tfSecretCode.placeholder = "暗証番号を入力"
            
            lblDayCreate.text = "作成日: \(dayCreate + getDayOfWeek(dayCreate)!)"
            lblDayEdit.text = "最終更新日: \(dayUpdate + getDayOfWeek(dayUpdate)!)"
        case 1:
            //general
            lblTitle.text = "Register / Edit Customer Information"
            btnEssential.setTitle("Requirement", for: .normal)
            btnPrivate.setTitle("Private", for: .normal)
            btnNote.setTitle("Note", for: .normal)
            btnConfirm.setTitle("Confirm", for: .normal)
            btnCancel.setTitle("Cancel", for: .normal)
            btnPreview.setTitle("Preview", for: .normal)
            
            //essential
            lblName.text = "Name"
            lblNameKana.text = "Kana"
            lblCusNo.text = "Customer's No"
            lblEmergency.text = "Urgent Contact"
            lblResponsible.text = "Responsible"
            tfLastName.placeholder = "Last Name"
            tfFirstName.placeholder = "First Name"
            tfLastNameKana.placeholder = "Last Name Kana"
            tfFirstNameKana.placeholder = "First Name Kana"
            tfCusNo.placeholder = "Customer Number"
            tfEmergency.placeholder = "Emergency Number(No Hyphen)"
            tfResponsible.placeholder = "Person in Charge"
            
            //private
            lblGender.text = "Gender"
            btnGender.setTitle("Unregistered", for: .normal)
            lblBirthday.text = "Birthday"
            btnBirthday.setTitle("Unregistered", for: .normal)
            lblAddress.text = "Address"
            tfPostalCode.placeholder = "Postal Code"
            btnAddConvert.setTitle("Convert", for: .normal)
            tfPrefecture.placeholder = "Prefecture"
            tfCity.placeholder = "City/Town/Village"
            tfSubAdd.placeholder = "Building Name - Room No"
            lblMail.text = "E-Mail"
            tfMail.placeholder = "Not Set"
            lblMailReceive.text = "Mailbox Reception Permission"
            lblBloodType.text = "Blood Type"
            btnBloodType.setTitle("Unregistered", for: .normal)
            btnAddPhoto.setTitle("Add Photo", for: .normal)
            lblHobby.text = "Hobby"
            
            //note
            lblNote1.text = "Memo 1"
            lblNote2.text = "Memo 2"
            tfSecretCode.placeholder = "Enter Secret Code"
            
            lblDayCreate.text = "Created: \(dayCreate + getDayOfWeek(dayCreate)!)"
            lblDayEdit.text = "Updated: \(dayUpdate + getDayOfWeek(dayUpdate)!)"
        case 2:
            //general
            lblTitle.text = "顧客情報を登録/編集"
            btnEssential.setTitle("必須事項", for: .normal)
            btnPrivate.setTitle("プライベート情報", for: .normal)
            btnNote.setTitle("備考", for: .normal)
            btnConfirm.setTitle("登 録", for: .normal)
            btnCancel.setTitle("取 消", for: .normal)
            btnPreview.setTitle("登録情報一覧", for: .normal)
            
            //essential
            lblName.text = "名     前"
            lblNameKana.text = "か     な"
            lblCusNo.text = "顧  客  番  号"
            lblEmergency.text = "緊  急  連  絡  先"
            lblResponsible.text = "担  当  者"
            tfLastName.placeholder = "(姓を入力)"
            tfFirstName.placeholder = "(名を入力)"
            tfLastNameKana.placeholder = "(せい)"
            tfFirstNameKana.placeholder = "(めい)"
            tfCusNo.placeholder = "(入力)"
            tfEmergency.placeholder = "(電話番号入力(ハイフンなし)"
            tfResponsible.placeholder = "(名前を入力)"
            
            //private
            lblGender.text = "性 別"
            btnGender.setTitle("未登録", for: .normal)
            lblBirthday.text = "生年月日"
            btnBirthday.setTitle("未登録", for: .normal)
            lblAddress.text = "住所"
            tfPostalCode.placeholder = "郵便番号"
            btnAddConvert.setTitle("住所変換", for: .normal)
            tfPrefecture.placeholder = "都道府県"
            tfCity.placeholder = "市区町村/郡"
            tfSubAdd.placeholder = "マンション・建物名・号室"
            lblMail.text = "メ ー ル"
            tfMail.placeholder = "設定されていません"
            lblMailReceive.text = "メール受信許可"
            lblBloodType.text = "血液型"
            btnBloodType.setTitle("未登録", for: .normal)
            btnAddPhoto.setTitle("画像挿入", for: .normal)
            lblHobby.text = "趣味"
            
            //note
            lblNote1.text = "備考 1"
            lblNote2.text = "備考 2"
            tfSecretCode.placeholder = "暗証番号を入力"
            
            lblDayCreate.text = "作成日: \(dayCreate + getDayOfWeek(dayCreate)!)"
            lblDayEdit.text = "最終更新日: \(dayUpdate + getDayOfWeek(dayUpdate)!)"
        case 3:
            //general
            lblTitle.text = "고객 정보 등록/편집"
            btnEssential.setTitle("필수사항", for: .normal)
            btnPrivate.setTitle("개인정보", for: .normal)
            btnNote.setTitle("비고", for: .normal)
            btnConfirm.setTitle("비고", for: .normal)
            btnCancel.setTitle("취소", for: .normal)
            btnPreview.setTitle("등록정보열람", for: .normal)
            
            //essential
            lblName.text = "이  름"
            lblNameKana.text = "영 어"
            lblCusNo.text = "고객번호"
            lblEmergency.text = "긴급연락처"
            lblResponsible.text = "담당자"
            tfLastName.placeholder = "(성을 기입)"
            tfFirstName.placeholder = "(이름을 기입)"
            tfLastNameKana.placeholder = "(성을 기입)"
            tfFirstNameKana.placeholder = "(이름을 기입)"
            tfCusNo.placeholder = "(기입)"
            tfEmergency.placeholder = "(전화번호 기입（-없이)）"
            tfResponsible.placeholder = "(이름기입)"
            
            //private
            lblGender.text = "성 별"
            btnGender.setTitle("미등록", for: .normal)
            lblBirthday.text = "생년월일"
            btnBirthday.setTitle("미등록", for: .normal)
            lblAddress.text = "주소"
            tfPostalCode.placeholder = "우편 번호"
            btnAddConvert.setTitle("주소 변환", for: .normal)
            tfPrefecture.placeholder = "도도부 현"
            tfCity.placeholder = "도시 / 군"
            tfSubAdd.placeholder = "아파트 · 건물명 · 호실"
            lblMail.text = "메일"
            tfMail.placeholder = "설정되어 있지 않습니다"
            lblMailReceive.text = "메일수신가능"
            lblBloodType.text = "혈액형"
            btnBloodType.setTitle("미등록", for: .normal)
            btnAddPhoto.setTitle("사진삽입", for: .normal)
            lblHobby.text = "취미"
            
            //note
            lblNote1.text = "비고1"
            lblNote2.text = "비고2"
            tfSecretCode.placeholder = "비밀번호를 입력"
            
            lblDayCreate.text = "작성일: \(dayCreate + getDayOfWeek(dayCreate)!)"
            lblDayEdit.text = "마지막 검토: \(dayUpdate + getDayOfWeek(dayUpdate)!)"
        default:
            break
        }
        changeButtonText()
    }
    
    func changeButtonText() {
        if popupType == PopUpType.Edit.rawValue {
            if language == 0 {
                btnConfirm.setTitle("編集", for: .normal)
            } else if language == 3 {
                btnConfirm.setTitle("업데이트", for: .normal)
            } else {
                btnConfirm.setTitle("Edit", for: .normal)
            }
        }
        if popupType == PopUpType.AddNew.rawValue {
            if language == 0 {
                btnConfirm.setTitle("登録", for: .normal)
            } else if language == 3 {
                btnConfirm.setTitle("등록", for: .normal)
            } else {
                btnConfirm.setTitle("Register", for: .normal)
            }
        }
        if popupType == PopUpType.Review.rawValue {
            btnConfirm.setTitle("OK", for: .normal)
        }
    }
    
    func reloadAvatar(photo: UIImage) {
        imvCus.image = photo
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年 MM月 dd日"
        print("DATE :: \(datePicker.date)")
        
        if let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date()).year {
            if language == 0 {
                tfAge.text = "\(age) 歳"
            } else if language == 3 {
                tfAge.text = "\(age) 나이"
            } else {
                tfAge.text = "\(age) years old"
            }
        }
        
        birthDate = Int(datePicker.date.timeIntervalSince1970)
        btnBirthday.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
        
        dateString = dateFormatter.string(from: datePicker.date)
    }
    
    //Get location from api zipaddress
    func getLocationFromPostalCode(postalCode : String){
        
        let url = "https://api.zipaddress.net/?zipcode=\(postalCode)"
            
        Alamofire.request(url, method: .get, parameters: nil, encoding:  JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
                
            case.success(let data):
                let json = JSON(data)
                let code = json["code"]
                if code == 200 {
                    self.tfPrefecture.text = json["data"]["pref"].stringValue
                    self.tfCity.text = json["data"]["city"].stringValue
                    self.tfSubAdd.text = json["data"]["town"].stringValue
                } else {
                    showAlert(message: json["message"].stringValue, view: self)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func resetAllButtonState() {
        btnEssential.alpha = 0.6
        btnPrivate.alpha = 0.6
        btnNote.alpha = 0.6
    }
    
    func enableUserInput(status:Bool) {
        
        //Essential
        tfLastName.isEnabled = status
        tfFirstName.isEnabled = status
        tfLastNameKana.isEnabled = status
        tfFirstNameKana.isEnabled = status
        tfCusNo.isEnabled = status
        tfEmergency.isEnabled = status
        tfResponsible.isEnabled = status
        
        //Private
        btnGender.isEnabled = status
        btnBirthday.isEnabled = status
        tfPostalCode.isEnabled = status
        btnAddConvert.isEnabled = status
        tfPrefecture.isEnabled = status
        tfCity.isEnabled = status
        tfSubAdd.isEnabled = status
        tfMail.isEnabled = status
        btnBloodType.isEnabled = status
        btnAddPhoto.isEnabled = status
        tvHobby.isSelectable = status
        tvHobby.isEditable = status
        //Note
        tvNote1.isSelectable = status
        tvNote1.isEditable = status
        tvNote2.isSelectable = status
        tvNote2.isEditable = status
        tfSecretCode.isEnabled = status
        btnSecretAccess.isEnabled = status
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            
        } else {
            tfSecretCode.isEnabled = false
            btnSecretAccess.isEnabled = false
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onTabSelect(_ sender: UIButton) {
        removeView()
        resetAllButtonState()
        switch sender.tag {
        case 0:
            btnEssential.alpha = 1
            viewContent.addSubview(viewEssential)
            break
        case 1:
            btnPrivate.alpha = 1
            viewContent.addSubview(viewPrivate)
            tvHobby.layer.cornerRadius = 5
            tvHobby.clipsToBounds = true
            break
        case 2:
            btnNote.alpha = 1
            viewContent.addSubview(viewNote)
            break
        default:
            break
        }
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        
        if onProgress == false {
            onProgress = true
            
            //check network connection first
            NetworkManager.isUnreachable { _ in
                showAlert(message: MSG_ALERT.kALERT_INTERNET_NOT_CONNECTED_PLEASE_CHECK_AGAIN, view: self)
                return
            }
            
            //Check Popup type
            if popupType == PopUpType.AddNew.rawValue {
                if (tfLastName.text?.count)! > 0 && (tfFirstName.text?.count)! > 0 {
                    if (tfLastNameKana.text?.count)! > 0 && (tfFirstNameKana.text?.count)! > 0 {
                        if imageTemp != nil {
                            imageConverted = UIImageJPEGRepresentation(imageTemp!, 1.0)
                        } else {
                            imageConverted = UIImageJPEGRepresentation(UIImage(named: "nophotoIcon")!, 0.5)
                        }
                        
                        SVProgressHUD.show(withStatus: "読み込み中")
                        SVProgressHUD.setDefaultMaskType(.clear)
                        
                        addCustomer(first_name: tfFirstName.text!, last_name: tfLastName.text!, first_name_kana: tfFirstNameKana.text!, last_name_kana: tfLastNameKana.text!, gender: genderSelect, bloodtype: bloodSelect,avatar_image: imageConverted!, birthday: birthDate, hobby:tvHobby.text,email: tfMail.text!, postal_code: tfPostalCode.text!, address1: tfPrefecture.text!, address2: tfCity.text!, address3: tfSubAdd.text!, responsible: tfResponsible.text!, mail_block: 0, urgent_no: tfEmergency.text!, memo1: tvNote1.text!, memo2: tvNote2.text!,cusNo:tfCusNo.text!) { (success) in
                                        if success {
                                            showAlert(message: MSG_ALERT.kALERT_CREATE_CUSTOMER_INFO_SUCCESS, view: self)
                                            self.onProgress = false
                                            self.delegate?.didConfirm(type: 1)
                                            self.dismiss(animated: true, completion: nil)
                                        } else {
                                            showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                            self.onProgress = false
                                        }
                            SVProgressHUD.dismiss()
                                    }
                    } else {
                        showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME_KANA, view: self)
                        onProgress = false
                    }
                } else {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME, view: self)
                    onProgress = false
                }
            }
            
            if popupType == PopUpType.Edit.rawValue {
                
                if isEdit == false {
                    if language == 0 {
                        btnConfirm.setTitle("更新", for: .normal)
                    } else if language == 3 {
                        btnConfirm.setTitle("업데이트", for: .normal)
                    } else {
                        btnConfirm.setTitle("Update", for: .normal)
                    }
                    isEdit = true
                    enableUserInput(status: true)
                    self.onProgress = false
                } else {
                    
                    if (tfLastName.text?.count)! > 0 && (tfFirstName.text?.count)! > 0 {
                        if (tfLastNameKana.text?.count)! > 0 && (tfFirstNameKana.text?.count)! > 0 {
                                        if imageTemp != nil {
                                            imageConverted = UIImageJPEGRepresentation(imageTemp!, 1)
                                            
                                            SVProgressHUD.show(withStatus: "読み込み中")
                                            SVProgressHUD.setDefaultMaskType(.clear)
                                            
                                            editCustomerInfowAvatar(cusID:customer.id,first_name: tfFirstName.text!, last_name: tfLastName.text!, first_name_kana: tfFirstNameKana.text!, last_name_kana: tfLastNameKana.text!, gender: genderSelect, bloodtype: bloodSelect,avatar_image:imageConverted!, birthday: birthDate, hobby:tvHobby.text,email: tfMail.text!, postal_code: tfPostalCode.text!, address1: tfPrefecture.text!, address2: tfCity.text!, address3: tfSubAdd.text!, responsible: tfResponsible.text!, mail_block: 0, urgent_no: tfEmergency.text!, memo1: tvNote1.text!, memo2: tvNote2.text!,cusNo:tfCusNo.text!) { (success) in
                                                if success {
                                            
                                                    showAlert(message: MSG_ALERT.kALERT_UPDATE_CUSTOMER_INFO_SUCCESS, view: self)
                                                    self.delegate?.didConfirm(type: 2)
                                                    self.dismiss(animated: true, completion: nil)
                                            
                                                } else {
                                                   
                                                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                                    
                                                }
                                                self.onProgress = false
                                                self.isEdit = false
                                                self.enableUserInput(status: false)
                                                SVProgressHUD.dismiss()
                                            }
                                        } else {
                                            SVProgressHUD.show(withStatus: "読み込み中")
                                            SVProgressHUD.setDefaultMaskType(.clear)
                                            
                                            editCustomerInfo(cusID:customer.id,first_name: tfFirstName.text!, last_name: tfLastName.text!, first_name_kana: tfFirstNameKana.text!, last_name_kana: tfLastNameKana.text!,gender: genderSelect, bloodtype: bloodSelect, birthday: birthDate, hobby:tvHobby.text,email: tfMail.text!, postal_code: tfPostalCode.text!, address1: tfPrefecture.text!, address2: tfCity.text!, address3: tfSubAdd.text!, responsible: tfResponsible.text!, mail_block: 0, urgent_no: tfEmergency.text!, memo1: tvNote1.text!, memo2: tvNote2.text!,cusNo:tfCusNo.text!) { (success) in
                                                if success {
                                                    showAlert(message: MSG_ALERT.kALERT_UPDATE_CUSTOMER_INFO_SUCCESS, view: self)
                                                    self.delegate?.didConfirm(type: 2)
                                                    self.dismiss(animated: true, completion: nil)
                                                } else {
                                                    showAlert(message: MSG_ALERT.kALERT_CANT_GET_CUSTOMER_INFO_PLEASE_CHECK_NETWORK, view: self)
                                                }
                                                self.onProgress = false
                                                self.isEdit = false
                                                self.enableUserInput(status: false)
                                                SVProgressHUD.dismiss()
                                            }
                                        }
                        } else {
                            showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME_KANA, view: self)
                            self.onProgress = false
                            self.isEdit = false
                            enableUserInput(status: false)
                        }
                    } else {
                        showAlert(message: MSG_ALERT.kALERT_INPUT_LAST_FIRST_NAME, view: self)
                        self.onProgress = false
                        self.isEdit = false
                        enableUserInput(status: false)
                    }
                }
            }
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPreview(_ sender: UIButton) {
        
    }
    
    @IBAction func onLanguageChange(_ sender: UIButton) {
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMultiLanguage.rawValue) {
            switch sender.tag {
            case 0:
                print("japan")
                language = 0
                changeLanguage(mode: language)
                break
            case 1:
                print("us")
                language = 1
                changeLanguage(mode: language)
                break
            case 2:
                print("china")
                language = 2
                showAlert(message: MSG_ALERT.kALERT_FUNCTION_UNDER_CONSTRUCTION, view: self)
                break
            case 3:
                print("korea")
                language = 3
                changeLanguage(mode: language)
                break
            default:
                break
            }
        } else {
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
    @IBAction func onGenderChange(_ sender: UIButton) {
        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let male = UIAlertAction(title: "男性", style: .default) { UIAlertAction in
            self.btnGender.setTitle("男性", for: .normal)
            self.genderSelect = 1
        }
        let female = UIAlertAction(title: "女性", style: .default) { UIAlertAction in
            self.btnGender.setTitle("女性", for: .normal)
            self.genderSelect = 2
        }
        let undefined = UIAlertAction(title: "不明", style: .default) { UIAlertAction in
            self.btnGender.setTitle("不明", for: .normal)
            self.genderSelect = 0
        }
        
        alert.addAction(cancel)
        alert.addAction(female)
        alert.addAction(male)
        alert.addAction(undefined)
        alert.popoverPresentationController?.sourceView = self.btnGender
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnGender.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onBirthdayChange(_ sender: UIButton) {
        let datePicker = UIDatePicker()//Date picker
        datePicker.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 5
        
        //change to Japanese style
        let loc = Locale(identifier: "ja")
        datePicker.locale = loc
        
        if (dateString == nil) {
            dateString = "1990年 01月 01日"
        }
 
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年 MM月 dd日"
        let date = dateFormatter.date(from: dateString!)
        datePicker.setDate(date!, animated: false)
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        let timeInterval = Int(date!.timeIntervalSince1970)
        
        btnBirthday.setTitle(dateFormatter.string(from: date!), for: .normal)
        birthDate = timeInterval
        
        if let age = Calendar.current.dateComponents([.year], from: date!, to: Date()).year {
            if language == 0 {
                tfAge.text = "\(age) 歳"
            } else if language == 3 {
                tfAge.text = "\(age) 나이"
            } else {
                tfAge.text = "\(age) years old"
            }
        }
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    @IBAction func onBloodTypeChange(_ sender: UIButton) {
        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let bloodA = UIAlertAction(title: "A 型", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle("A 型", for: .normal)
            self.bloodSelect = 1
        }
        let bloodB = UIAlertAction(title: "B 型", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle("B 型", for: .normal)
            self.bloodSelect = 2
        }
        let bloodO = UIAlertAction(title: "O 型", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle("O 型", for: .normal)
            self.bloodSelect = 3
        }
        let bloodAB = UIAlertAction(title: "AB 型", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle("AB 型", for: .normal)
            self.bloodSelect = 4
        }
        let bloodUndefined = UIAlertAction(title: "不明", style: .default) { UIAlertAction in
            self.btnBloodType.setTitle("不明", for: .normal)
            self.bloodSelect = 0
        }
        alert.addAction(cancel)
        alert.addAction(bloodA)
        alert.addAction(bloodB)
        alert.addAction(bloodO)
        alert.addAction(bloodAB)
        alert.addAction(bloodUndefined)
        alert.popoverPresentationController?.sourceView = self.btnBloodType
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnBloodType.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onAddPhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let takeNew = UIAlertAction(title: "写真を撮る", style: .default) { UIAlertAction in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker,animated: true,completion: nil)
            } else {
                showAlert(message: "No Camera", view: self)
            }
        }
        let selectPhoto = UIAlertAction(title: "デバイスから写真を選択", style: .default) { UIAlertAction in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: {
                    self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
                })
            }
        }
        
        let selectGallery = UIAlertAction(title: "Galleryから写真を選択", style: .default) { UIAlertAction in
            let newPopup = CustomerGalleryPopupVC(nibName: "CustomerGalleryPopupVC", bundle: nil)
            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
            newPopup.preferredContentSize = CGSize(width: 600, height: 800)
            newPopup.customer = self.customer
            newPopup.delegate = self
            self.present(newPopup, animated: true, completion: nil)
        }
        alert.addAction(cancel)
        alert.addAction(takeNew)
        alert.addAction(selectPhoto)
        alert.addAction(selectGallery)
        
        alert.popoverPresentationController?.sourceView = self.btnAddPhoto
        alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        alert.popoverPresentationController?.sourceRect = self.btnAddPhoto.bounds
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didCloseSecret() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onConvertAddress(_ sender: UIButton) {
        getLocationFromPostalCode(postalCode: tfPostalCode.text!)
    }
    
    @IBAction func onSwitchMailReceive(_ sender: UISwitch) {
        
    }
    
    @IBAction func onSecretMemoAccess(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kSecretMemo.rawValue) {
            if popupType == PopUpType.AddNew.rawValue {
                showAlert(message: MSG_ALERT.kALERT_CREATE_CUSTOMER_FIRST_ADD_SECRET_LATER, view: self)
            } else {
                if tfSecretCode.text != "" {
                    SVProgressHUD.show(withStatus: "読み込み中")
                    SVProgressHUD.setDefaultMaskType(.clear)
                    
                    getAccessSecretMemo(password: tfSecretCode.text!) { (success, msg) in
                        if success {
                            let newPopup = SecretPopupVC(nibName: "SecretPopupVC", bundle: nil)
                            newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
                            newPopup.preferredContentSize = CGSize(width: 560, height: 450)
                            newPopup.customer = self.customer
                            newPopup.authenPass = self.tfSecretCode.text!
                            newPopup.delegate = self
                            self.present(newPopup, animated: true, completion: nil)
                        } else {
                            showAlert(message: msg, view: self)
                        }
                        SVProgressHUD.dismiss()
                    }
                } else {
                    showAlert(message: MSG_ALERT.kALERT_INPUT_PASSWORD, view: self)
                }
            }
        } else {
            showAlert(message: MSG_ALERT.kALERT_ACCOUNT_CANT_ACCESS, view: self)
        }
    }
    
    //*****************************************************************
    // MARK: - UIImagePicker Delegate
    //*****************************************************************
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let newImage = imageWithImage(sourceImage: image!, scaledToWidth:768)
        
        self.dismiss(animated: true, completion: { () -> Void in
            let imgRotated = newImage.updateImageOrientionUpSide()
            
            if self.popupType == PopUpType.Edit.rawValue || self.popupType == PopUpType.Review.rawValue {
                self.imageTemp = imgRotated
            } else {
                self.imageTemp = imgRotated
            }
            self.reloadAvatar(photo: image!)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //*****************************************************************
    // MARK: - Textfield Delegate
    //*****************************************************************
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //add hiragana from kanji
        switch textField.tag {
        case 1:
            tfLastNameKana.text = TextConverter.convert(tfLastName.text!, to: .hiragana)
        case 2:
            tfFirstNameKana.text = TextConverter.convert(tfFirstName.text!, to: .hiragana)
        default:
            break
        }
        
        if (tfLastName.text?.count)! > 0 && (tfFirstName.text?.count)! > 0 {
            radioName.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioName.backgroundColor = UIColor.white
        }
        if (tfLastNameKana.text?.count)! > 0 && (tfFirstNameKana.text?.count)! > 0 {
            radioNameKana.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioNameKana.backgroundColor = UIColor.white
        }
        if (tfCusNo.text?.count)! > 0 {
            radioCusNo.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioCusNo.backgroundColor = UIColor.white
        }
        if (tfEmergency.text?.count)! > 0 {
            radioEmergency.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioEmergency.backgroundColor = UIColor.white
        }
        if (tfResponsible.text?.count)! > 0 {
            radioResponsible.backgroundColor = COLOR_SET.kLINE_CORRECT_COLOR
        } else {
            radioResponsible.backgroundColor = UIColor.white
        }
        
        //check email validation
        if (tfMail.text?.count)! > 0 {
            
            switch isValidEmail(email: tfMail.text!) {
            case true:
                print("Mail is valid")
            case false:
                showAlert(message: MSG_ALERT.kALERT_INPUT_EMAIL, view: self)
            }
        }
        
        if (tfEmergency.text?.count)! > 0 {
            let isPhone = tfEmergency.text?.isPhoneNumber
        
            if isPhone == true {
            } else {
                showAlert(message: MSG_ALERT.kALERT_INPUT_PHONE, view: self)
            }
        }
        
        if popupType == PopUpType.Edit.rawValue {
            if language == 0 {
                btnConfirm.setTitle("更新", for: .normal)
            } else if language == 3 {
                btnConfirm.setTitle("업데이트", for: .normal)
            } else {
                btnConfirm.setTitle("Update", for: .normal)
            }
        }
    }
}

//*****************************************************************
// MARK: - CustomerGalleryPopupVC Delegate
//*****************************************************************

extension RegCustomerPopup: CustomerGalleryPopupVCDelegate {
    
    func onAddCusAvatar(image: UIImage) {
        self.imageTemp = image
        self.reloadAvatar(photo: image)
    }
}

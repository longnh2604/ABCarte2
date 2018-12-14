//
//  CustomerCell.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage
import ExpyTableView

class CustomerCell: UITableViewCell,ExpyTableViewHeaderCell {

    //IBOutlet
    @IBOutlet weak var imageViewArrow: UIImageView!
    @IBOutlet weak var PointGender: UIView!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblHiragana: UILabel!
    @IBOutlet weak var lblKanji: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblLastCome: UILabel!
    @IBOutlet weak var lblCusID: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var viewCell: UIView!
    
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {

        switch state {
        case .willExpand:
            print("WILL EXPAND")
            hideSeparator()
            arrowDown(animated: !cellReuse)

        case .willCollapse:
            print("WILL COLLAPSE")
            arrowRight(animated: !cellReuse)

        case .didExpand:
            viewCell.backgroundColor = UIColor.init(red: 246/255, green: 240/255, blue: 230/255, alpha: 1)
            print("DID EXPAND")

        case .didCollapse:
            showSeparator()
            viewCell.backgroundColor = UIColor.clear
            print("DID COLLAPSE")
        }
    }

    private func arrowDown(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) {
//            self.imageViewArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi / 2))

            if GlobalVariables.sharedManager.onMultiSelect! == true {
//                self.imageViewArrow.image = UIImage(named: "checkBoxIcon")
            } else {
                self.imageViewArrow.image = UIImage(named: "arrowDownIcon")
            }
        }
    }

    private func arrowRight(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) {
//            self.imageViewArrow.transform = CGAffineTransform(rotationAngle: 0)

            if GlobalVariables.sharedManager.onMultiSelect! == true {
//                self.imageViewArrow.image = UIImage(named: "uncheckBoxIcon")
            } else {
                self.imageViewArrow.image = UIImage(named: "arrowIcon")
            }
        }
    }

    func configure(with customer: CustomerData) {
        
        PointGender.layer.cornerRadius = 5
        PointGender.clipsToBounds = true
        
        lblCusID.text = customer.customer_no
        
        if customer.birthday != 0 {
            lblBirthday.text = convertUnixTimestamp(time: customer.birthday)
        } else {
            lblBirthday.text = ""
        }

        if customer.last_daycome != 0 {
            let dayCome = convertUnixTimestamp(time: customer.last_daycome)
            lblLastCome.text = dayCome + getDayOfWeek(dayCome)!
        } else {
            lblLastCome.text = ""
        }

        lblKanji.text = customer.last_name + " " + customer.first_name
        lblHiragana.text = customer.last_name_kana + " " + customer.first_name_kana
        
        if customer.gender == 0 {
            lblGender.text = "不明"
            PointGender.backgroundColor = UIColor.lightGray
        } else if customer.gender == 1 {
            lblGender.text = "男性"
            PointGender.backgroundColor = kMALE_COLOR
        } else {
            lblGender.text = "女性"
            PointGender.backgroundColor = kFEMALE_COLOR
        }
        
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            self.imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvCus.image = UIImage(named: "nophotoIcon")
        }

        imvCus.layer.borderWidth = 1
        imvCus.layer.borderColor = UIColor.black.cgColor
        imvCus.layer.cornerRadius = 35
        imvCus.clipsToBounds = true

        if GlobalVariables.sharedManager.onMultiSelect == true {
            if customer.selected_status == 1 {
                imageViewArrow.image = UIImage(named: "icon_check_box_black")
            } else {
                imageViewArrow.image = UIImage(named: "uncheckBoxIcon")
            }
        } else {
            imageViewArrow.image = UIImage(named: "arrowIcon")
        }
    }
}

protocol DetailCustomerCellDelegate: class {
    func didPressButton(type:Int)
}

class DetailCustomerCell: UITableViewCell {
    
    weak var delegate:DetailCustomerCellDelegate?

    //IBOutlet
    @IBOutlet weak var pointGender: UIView!
    @IBOutlet weak var imvDetailCus: UIImageView!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblCusID: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cusView: UIView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSecret: UIButton!
    @IBOutlet weak var btnInDetail: UIButton!
    @IBOutlet weak var lblLastCome: UILabel!
    @IBOutlet weak var lblFirstCome: UILabel!
    @IBOutlet weak var lblHobby: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var lblBloodType: UILabel!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var btnMemo1: RoundButton!
    @IBOutlet weak var btnMemo2: RoundButton!
    @IBOutlet weak var btnCounsel: RoundButton!
    @IBOutlet weak var btnAgree: RoundButton!
    @IBOutlet weak var imv_lock_memo_secret: UIImageView!
    
    func configure(with customer: CustomerData) {

        pointGender.layer.cornerRadius = 5
        pointGender.clipsToBounds = true

        mainView.layer.cornerRadius = 10
        mainView.clipsToBounds = true

        cusView.layer.cornerRadius = 5
        cusView.clipsToBounds = true

        btnEdit.layer.cornerRadius = 5
        btnEdit.clipsToBounds = true
        btnSecret.layer.cornerRadius = 5
        btnSecret.clipsToBounds = true
        btnInDetail.layer.cornerRadius = 5
        btnInDetail.clipsToBounds = true

        lblCusID.text = customer.customer_no
        
        if customer.gender == 0 {
            lblGender.text = "不明"
            pointGender.backgroundColor = UIColor.lightGray
        } else if customer.gender == 1 {
            lblGender.text = "男性"
            pointGender.backgroundColor = kMALE_COLOR
        } else {
            lblGender.text = "女性"
            pointGender.backgroundColor = kFEMALE_COLOR
        }

        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvDetailCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvDetailCus.image = UIImage(named: "nophotoIcon")
        }
    
        if customer.last_daycome != 0 {
            let ldayCome = convertUnixTimestamp(time: customer.last_daycome)
            lblLastCome.text = ldayCome + getDayOfWeek(ldayCome)!
        } else {
            lblLastCome.text = ""
        }
        
        if customer.first_daycome != 0 {
            let fdayCome = convertUnixTimestamp(time: customer.first_daycome)
            lblFirstCome.text = fdayCome + getDayOfWeek(fdayCome)!
        } else {
            lblFirstCome.text = ""
        }
        
        if customer.birthday != 0 {
            lblBirthday.text = convertUnixTimestamp(time: customer.birthday)
        } else {
            lblBirthday.text = ""
        }
        
        lblBloodType.text = checkBloodType(type: customer.bloodtype)

        lblHobby.text = customer.hobby
        lblMobile.text = customer.urgent_no

        btnEdit.addTarget(self, action: #selector(onEdit), for: .touchUpInside)
        btnInDetail.addTarget(self, action: #selector(onViewDetail), for: .touchUpInside)
        btnSecret.addTarget(self, action: #selector(onSecret), for: .touchUpInside)
        
        if customer.memo1 != "" {
            btnMemo1.backgroundColor = kMEMO_HAS_CONTENT_COLOR
        } else {
            btnMemo1.backgroundColor = UIColor.lightGray
        }
        if customer.memo2 != "" {
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

    @objc func onEdit() {
        delegate?.didPressButton(type: 1)
    }

    @objc func onViewDetail() {
        delegate?.didPressButton(type: 4)
    }

    @objc func onSecret() {
        delegate?.didPressButton(type: 5)
    }
    
    @IBAction func onCounsellingSelect(_ sender: UIButton) {
        delegate?.didPressButton(type: 2)
    }
    
    @IBAction func onAgreeSelect(_ sender: UIButton) {
        delegate?.didPressButton(type: 3)
    }
}

//*****************************************************************
// MARK: - TableViewCell
//*****************************************************************

extension UITableViewCell {

    func showSeparator() {
        DispatchQueue.main.async {
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    func hideSeparator() {
        DispatchQueue.main.async {
            self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
        }
    }
}

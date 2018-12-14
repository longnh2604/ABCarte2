//
//  CarteCell.swift
//  ABCarte2
//
//  Created by Wayne Lee on 2018/05/14.
//  Copyright © 2018年 Oluxe. All rights reserved.
//

import UIKit
import SDWebImage

protocol CarteCellDelegate: class {
    func didPressButton(type:Int,tag:Int)
    func didAvatarPress(tag:Int)
    func didDailyReportPress(tag:Int)
}

class CarteCell: UITableViewCell {

    //Variable
    weak var delegate:CarteCellDelegate?
    
    var categories: [String] = []
    var maxFree: Int = 1
    var maxStamp: Int = 1
    
    //IBOutlet
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var lblNoImg: UILabel!
    @IBOutlet weak var btnMemo1: RoundButton!
    @IBOutlet weak var btnMemo2: RoundButton!
    @IBOutlet weak var btnMemo3: RoundButton!
    @IBOutlet weak var btnMemo4: RoundButton!
    @IBOutlet weak var btnMemo5: RoundButton!
    @IBOutlet weak var btnMemo6: RoundButton!
    @IBOutlet weak var btnMemo7: RoundButton!
    @IBOutlet weak var btnMemo8: RoundButton!
    @IBOutlet weak var btnDailyReport: UIButton!
    @IBOutlet weak var imvCheckBox: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(carte: CarteData){
        
        btnEdit.layer.cornerRadius = 5
        btnEdit.clipsToBounds = true
        
        btnImage.tag = carte.id
        
        hideFreeMemo()
        hideStampMemo()
        
        //check carte has representative photo or not
        if carte.carte_photo.isEmpty {
            if carte.medias.count > 0 {
                lblNoImg.text = "\(carte.medias.count)"
                let url = URL(string: (carte.medias.last?.url)!)
                
                btnImage.sd_setImage(with: url, for: .normal) { (image, error, cache, url) in
                    let img = image?.crop(to: CGSize(width: 768, height: 1004))
                    self.btnImage.setImage(img, for: .normal)
                }
            } else {
                lblNoImg.text = "\(carte.medias.count)"
                btnImage.setImage(UIImage(named: "nophotoIcon"), for: .normal)
            }
        } else {
            lblNoImg.text = "\(carte.medias.count)"
            let url = URL(string: carte.carte_photo)
    
            btnImage.sd_setImage(with: url, for: .normal) { (image, error, cache, url) in
                let img = image?.crop(to: CGSize(width: 768, height: 1004))
                self.btnImage.setImage(img, for: .normal)
            }
        }
   
        let carteDate = convertUnixTimestamp(time: carte.select_date)

        let day : String? = getDayOfWeek(carteDate)
        if let dayUnwrapped = day {
            lblDate.text = carteDate + dayUnwrapped
        }
        
        if GlobalVariables.sharedManager.onMultiSelect == true {
            imvCheckBox.isHidden = false
            if carte.selected_status == 1 {
                imvCheckBox.image = UIImage(named: "icon_check_box_black")
            } else {
                imvCheckBox.image = UIImage(named: "uncheckBoxIcon")
            }
        } else {
            imvCheckBox.isHidden = true
        }
        
        for i in 1 ..< 5 {
            setMemoUnSelect(position: i, title: "フリーメモ\(i)", content: "")
        }
        
        //check memo has included or not
        if carte.free_memo.count > 0 {
            for i in 0 ..< carte.free_memo.count {
                setMemo(position: carte.free_memo[i].position, title: carte.free_memo[i].title, content: carte.free_memo[i].content)
            }
        }
        
        if categories.count > 0 {
            if carte.stamp_memo.count > 0 {
                for i in 0 ..< carte.stamp_memo.count {
                    setMemo(position: carte.stamp_memo[i].position, title: categories[i], content: carte.stamp_memo[i].content)
                }
            }
        }
        
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
    
    func setMemoUnSelect(position:Int,title:String,content:String) {
        switch position {
        case 1:
            btnMemo1.setTitle("\(title)", for: .normal)
            btnMemo1.backgroundColor = UIColor.lightGray
        case 2:
            btnMemo2.setTitle("\(title)", for: .normal)
            btnMemo2.backgroundColor = UIColor.lightGray
        case 3:
            btnMemo3.setTitle("\(title)", for: .normal)
            btnMemo3.backgroundColor = UIColor.lightGray
        case 4:
            btnMemo4.setTitle("\(title)", for: .normal)
            btnMemo4.backgroundColor = UIColor.lightGray
        case 5:
            btnMemo5.setTitle("\(title)", for: .normal)
            btnMemo5.backgroundColor = UIColor.lightGray
        case 6:
            btnMemo6.setTitle("\(title)", for: .normal)
            btnMemo6.backgroundColor = UIColor.lightGray
        case 7:
            btnMemo7.setTitle("\(title)", for: .normal)
            btnMemo7.backgroundColor = UIColor.lightGray
        case 8:
            btnMemo8.setTitle("\(title)", for: .normal)
            btnMemo8.backgroundColor = UIColor.lightGray
        default:
            break
        }
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
        default:
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onEdit(_ sender: UIButton) {
        delegate?.didPressButton(type: 1, tag:sender.tag)
    }

    @IBAction func onAvatarPress(_ sender: UIButton) {
        delegate?.didAvatarPress(tag: sender.tag)
    }
    
    @IBAction func onDailyReport(_ sender: UIButton) {
        delegate?.didDailyReportPress(tag: sender.tag)
    }
    
}

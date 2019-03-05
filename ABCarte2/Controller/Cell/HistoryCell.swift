//
//  HistoryCell.swift
//  ABCarte2
//
//  Created by Long on 2018/12/13.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol HistoryCellDelegate: class {
    func onSelectDetail(index: Int)
}

class HistoryCell: UITableViewCell {

    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblCusPhone: UILabel!
    @IBOutlet weak var viewGender: RoundUIView!
    @IBOutlet weak var btnDetail: UIButton!
    
    //Variable
    weak var delegate: HistoryCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(data: CarteData){
        
        viewGender.layer.cornerRadius = 5
        viewGender.clipsToBounds = true
        
        if data.cus[0].gender == 0 {
            lblGender.text = "不明"
            viewGender.backgroundColor = UIColor.lightGray
        } else if data.cus[0].gender == 1 {
            lblGender.text = "男性"
            viewGender.backgroundColor = COLOR_SET.kMALE_COLOR
        } else {
            lblGender.text = "女性"
            viewGender.backgroundColor = COLOR_SET.kFEMALE_COLOR
        }
        
        lblCusName.text = data.cus[0].last_name_kana + " " + data.cus[0].first_name_kana
        
        lblCusPhone.text = "連　絡　先 : " + data.cus[0].urgent_no
        
        if data.cus[0].pic_url == "" {
            imvCus.image = UIImage(named: "nophotoIcon")
        } else {
            let url = URL(string: data.cus[0].pic_url)
            imvCus.sd_setImage(with: url) { (image, error, cache, url) in
            }
        }
        
        setButtonColorStyle(button: btnDetail,type: 1)
    }
    
    @IBAction func onSelectDetail(_ sender: UIButton) {
        delegate?.onSelectDetail(index: sender.tag)
    }
}

//
//  MemoCell.swift
//  ABCarte2
//
//  Created by Long on 2018/06/25.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol MemoCellDelegate: class {
    func didEndEditing(onCell cell: MemoCell)
}

class MemoCell: UITableViewCell,UITextViewDelegate {

    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btnTypo: RoundButton!
    @IBOutlet weak var btnKeyboard: RoundButton!
    @IBOutlet weak var btnMicro: RoundButton!
    @IBOutlet weak var lblMemo: UILabel!
    
    weak var delegate: MemoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tvContent.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with carte: CarteData,index:Int) {
        lblMemo.text = "メ  モ  \(index + 1)"
        
//        switch index {
//        case 0:
//            tvContent.text = carte.memo1
//            break
//        case 1:
//            tvContent.text = carte.memo2
//            break
//        case 2:
//            tvContent.text = carte.memo3
//            break
//        default:
//            break
//        }
        
    }

    @IBAction func onToolSelect(_ sender: UIButton) {
        
    }
    
    //*****************************************************************
    // MARK: - TextView Delegate
    //*****************************************************************
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didEndEditing(onCell: self)
    }
}

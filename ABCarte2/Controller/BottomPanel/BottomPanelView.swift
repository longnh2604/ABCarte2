//
//  BottomPanelView.swift
//  ABCarte2
//
//  Created by Long on 2019/01/16.
//  Copyright © 2019 Oluxe. All rights reserved.
//

import UIKit

@objc protocol BottomPanelViewDelegate: class {
    @objc optional func tapSetting()
    @objc optional func tapLogout()
    @objc optional func tapDocument()
    @objc optional func tapInfo()
}

class BottomPanelView: UIView {

    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnDocument: UIButton!
    
    weak var delegate: BottomPanelViewDelegate?
    
    class func instanceFromNib(_ delegate: BottomPanelViewDelegate?) -> BottomPanelView {
        let panelView : BottomPanelView = UINib(
            nibName: "BottomPanelView",
            bundle: Bundle.main
            ).instantiate(
                withOwner: self,
                options: nil
            ).first as! BottomPanelView
        
        panelView.delegate = delegate
        
        if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            switch set {
            case 0:
                panelView.backgroundColor = COLOR_SET000.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET000.kACCENT_COLOR
            case 1:
                panelView.backgroundColor = COLOR_SET001.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET001.kACCENT_COLOR
            case 2:
                panelView.backgroundColor = COLOR_SET002.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET002.kACCENT_COLOR
            case 3:
                panelView.backgroundColor = COLOR_SET003.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET003.kACCENT_COLOR
            case 4:
                panelView.backgroundColor = COLOR_SET004.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET004.kACCENT_COLOR
            case 5:
                panelView.backgroundColor = COLOR_SET005.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET005.kACCENT_COLOR
            case 6:
                panelView.backgroundColor = COLOR_SET006.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET006.kACCENT_COLOR
            case 7:
                panelView.backgroundColor = COLOR_SET007.kCOMMAND_BUTTON_BACKGROUND_COLOR
                panelView.btnInfo.backgroundColor = COLOR_SET007.kACCENT_COLOR
            default:
                break
            }
        }
        
        return panelView
    }
 
    @IBAction func tapLogoutButton(_ sender: UIButton) {
        delegate?.tapLogout?()
    }
    
    @IBAction func tapSettingButton(_ sender: UIButton) {
        delegate?.tapSetting?()
    }
    
    @IBAction func tapDocumentButton(_ sender: UIButton) {
        delegate?.tapDocument?()
    }
    
    @IBAction func tapInfoButton(_ sender: UIButton) {
        delegate?.tapInfo?()
    }
    
}

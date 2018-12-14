//
//  SilhouettePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol SilhouettePopupVCDelegate: class {
    func didSelectType(type:Int)
}

class SilhouettePopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var viewSilhouette: UIView!
    
    //Variable
    weak var delegate:SilhouettePopupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewSilhouette.layer.cornerRadius = 10
        viewSilhouette.clipsToBounds = true
    }

    @IBAction func onSilhouetteSelect(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            delegate?.didSelectType(type: 0)
            dismiss(animated: true, completion: nil)
            break
        case 1:
            delegate?.didSelectType(type: 1)
            dismiss(animated: true, completion: nil)
            break
        case 2:
            delegate?.didSelectType(type: 2)
            dismiss(animated: true, completion: nil)
            break
        case 3:
            delegate?.didSelectType(type: 3)
            dismiss(animated: true, completion: nil)
            break
        case 4:
            delegate?.didSelectType(type: 4)
            dismiss(animated: true, completion: nil)
            break
        case 5:
            delegate?.didSelectType(type: 5)
            dismiss(animated: true, completion: nil)
            break
        case 6:
            delegate?.didSelectType(type: 6)
            dismiss(animated: true, completion: nil)
            break
        case 7:
            delegate?.didSelectType(type: 7)
            dismiss(animated: true, completion: nil)
            break
        case 8:
            delegate?.didSelectType(type: 8)
            dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
}

//
//  StickerPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/08/31.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol StickerPopupVCDelegate: class {
    func didStickerSelect(imv:String)
}

class StickerPopupVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var viewSticker: UIView!
    @IBOutlet weak var collectSticker: UICollectionView!
    @IBOutlet weak var constraintH: NSLayoutConstraint!
    
    //Variable
    weak var delegate:StickerPopupVCDelegate?
    
    var arrPhotoAttender = ["JBS_stamp_01.png","JBS_stamp_02.png","JBS_stamp_03.png","JBS_stamp_04.png","JBS_stamp_05.png","JBS_stamp_06.png","JBS_stamp_07.png","JBS_stamp_08.png","JBS_stamp_09.png","JBS_stamp_10.png","JBS_stamp_11.png","JBS_stamp_12.png","JBS_stamp_13.png","JBS_stamp_14.png"]
    var arrPhotoSerment = ["serment_stamp001.png","JBS_stamp_04.png","JBS_stamp_05.png","JBS_stamp_06.png","JBS_stamp_07.png","JBS_stamp_08.png","JBS_stamp_09.png","JBS_stamp_10.png","JBS_stamp_11.png","JBS_stamp_12.png","JBS_stamp_13.png","JBS_stamp_14.png"]
    var arrPhotoShisei = ["SHISEI_stamp1.png","JBS_stamp_04.png","JBS_stamp_05.png","JBS_stamp_06.png","JBS_stamp_07.png","JBS_stamp_08.png","JBS_stamp_09.png","JBS_stamp_10.png","JBS_stamp_11.png","JBS_stamp_12.png","JBS_stamp_13.png","JBS_stamp_14.png"]
    var arrPhotoDefault = ["JBS_stamp_04.png","JBS_stamp_05.png","JBS_stamp_06.png","JBS_stamp_07.png","JBS_stamp_08.png","JBS_stamp_09.png","JBS_stamp_10.png","JBS_stamp_11.png","JBS_stamp_12.png","JBS_stamp_13.png","JBS_stamp_14.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadData()
    }
    
    func setupUI() {
        viewSticker.layer.cornerRadius = 10
        viewSticker.clipsToBounds = true
    }
    
    func loadData() {
        collectSticker.delegate = self
        collectSticker.dataSource = self
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension StickerPopupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"StickerCell", for: indexPath) as! StickerCell
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kFullStampSticker.rawValue) {
            #if SERMENT
            cell.configure(imv: arrPhotoSerment[indexPath.row])
            #elseif SHISEI
            cell.configure(imv: arrPhotoShisei[indexPath.row])
            #else
            cell.configure(imv: arrPhotoAttender[indexPath.row])
            #endif
        } else {
            cell.configure(imv: arrPhotoDefault[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kFullStampSticker.rawValue) {
            #if SERMENT
            return arrPhotoSerment.count
            #elseif SHISEI
            return arrPhotoShisei.count
            #else
            return arrPhotoAttender.count
            #endif
        } else {
            return arrPhotoDefault.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kFullStampSticker.rawValue) {
            #if SERMENT
            delegate?.didStickerSelect(imv: arrPhotoSerment[indexPath.row])
            #elseif SHISEI
            delegate?.didStickerSelect(imv: arrPhotoShisei[indexPath.row])
            #else
            delegate?.didStickerSelect(imv: arrPhotoAttender[indexPath.row])
            #endif
        } else {
            delegate?.didStickerSelect(imv: arrPhotoDefault[indexPath.row])
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension StickerPopupVC: UICollectionViewDelegateFlowLayout {
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 30)
    }
    
}

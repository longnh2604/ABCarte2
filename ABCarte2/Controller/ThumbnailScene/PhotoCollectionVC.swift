//
//  PhotoCollectionVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import JGProgressHUD

class PhotoCollectionVC: UIViewController {

    //Variable
    var customer = CustomerData()
    
    var cartes: Results<CarteData>!
    var cartesData : [CarteData] = []
    
    var thumbs: Results<ThumbData>!
    var thumbsData : [ThumbData] = []
    
    var indexDelete : [Int] = []
    var needLoad: Bool = true
    let hud = JGProgressHUD(style: .dark)
    
    //IBOutlet
    @IBOutlet weak var collectGallery: UICollectionView!
    @IBOutlet weak var lblNoPhoto: UILabel!
    @IBOutlet weak var btnCamera: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupUI()
        
        loadData()
    }
    
    func setupUI() {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        collectGallery.delegate = self
        collectGallery.dataSource = self
        collectGallery.allowsMultipleSelection = true
        
        guard let fl = collectGallery?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        fl.sectionHeadersPinToVisibleBounds = true
        
        collectGallery?.register(XibHeader.nib(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: XibHeader.identifier)
        
        let nib = UINib(nibName: "photoCollectCell", bundle: nil)
        collectGallery.register(nib, forCellWithReuseIdentifier: "photoCollectCell")
    }
    
    func removeAllData() {
        self.indexDelete.removeAll()
        thumbsData.removeAll()
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        needLoad = true
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }
    
    func loadData() {
        
        if needLoad == true {
            
            showLoading()
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(ThumbData.self))
            }
            
            getCustomerMedias(cusID: customer.id) { (success) in
                if success {
                    
                    let realm = RealmServices.shared.realm
                    self.thumbs = realm.objects(ThumbData.self)
                    
                    var number = 0
                    for i in 0 ..< self.thumbs.count {
                        self.thumbsData.append(self.thumbs[i])
                        
                        for _ in 0 ..< self.thumbs[i].medias.count {
                            number += 1
                        }
                    }
                    self.thumbsData = self.thumbsData.sorted(by: { $0.date > $1.date })
                    
                    self.collectGallery.reloadData()
                    
                    self.lblNoPhoto.text = "全 :\(number)枚"
                    self.hud.dismiss()
                    
                } else {
                    showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    self.lblNoPhoto.text = "全 :0枚"
                    self.hud.dismiss()
                }
            }
            needLoad = false
        }   
    }
    
    func checkButtonStatus() {
        if GlobalVariables.sharedManager.selectedImageIds.count > 1 {
            btnCamera.isEnabled = false
        } else {
            btnCamera.isEnabled = true
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onCamera(_ sender: UIButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 || GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            
            showLoading()
            
            //get current date
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            
            var carte = CarteData()
            var statusData = false
            
            //check all carte of customer
            for i in 0 ..< cartesData.count {
                let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                let isSame = date.isInSameDay(date: currDate)
                if isSame {
                    statusData = true
                    carte = cartesData[i]
                }
            }
            
            if statusData == true {
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "ShootingVC") as? ShootingVC {
                    if let navigator = self.navigationController {
                        viewController.customer = self.customer
                        viewController.carte = carte
                        
                        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                            
                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                                
                                for i in 0 ..< self.thumbsData.count {
                                    
                                    for j in 0 ..< self.thumbsData[i].medias.count {
                                        
                                        if self.thumbsData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                            viewController.media = self.thumbsData[i].medias[j]
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        self.removeAllData()
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
                self.hud.dismiss()
                
            } else {
                
                addCarte(cusID: customer.id, date: timeInterval) { (success) in
                    if success {
                       
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(CarteData.self))
                        }
                        
                        getCustomerCartesWithMemos(cusID: self.customer.id) { (success) in
                            if success {
                         
                                let realm = RealmServices.shared.realm
                                self.cartes = realm.objects(CarteData.self)
                                
                                self.cartesData.removeAll()
                                
                                for carte in self.cartes.filter("fc_customer_id = \(self.customer.id)") {
                                    self.cartesData.append(carte)
                                }
                                
                                for i in 0 ..< self.cartesData.count {
                                    if self.cartesData[i].select_date == timeInterval {
                                        carte = self.cartesData[i]
                                    }
                                }
                                
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                                if let viewController = storyBoard.instantiateViewController(withIdentifier: "ShootingVC") as? ShootingVC {
                                    if let navigator = self.navigationController {
                                        viewController.customer = self.customer
                                        viewController.carte = carte
                                        
                                        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                                            
                                            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                                                
                                                for i in 0 ..< self.thumbsData.count {
                                                    
                                                    for j in 0 ..< self.thumbsData[i].medias.count {
                                                        
                                                        if self.thumbsData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                                            viewController.media = self.thumbsData[i].medias[j]
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                        self.removeAllData()
                                        navigator.pushViewController(viewController, animated: true)
                                    }
                                }
                                
                                self.hud.dismiss()
                            } else {
                              
                                self.hud.dismiss()
                                showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                        }
                    } else {
                        self.hud.dismiss()
                        showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            }
        }
    }
    
    @IBAction func onCompare(_ sender: UIButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            showAlert(message: kALERT_PLEASE_SELECT_PHOTO, view: self)
            return
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 13 {
            showAlert(message: kALERT_CHOOSE_2_TO_12_PHOTOS, view: self)
            return
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count == 2 {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "ComparisonVC") as? ComparisonVC {
                if let navigator = navigationController {
                    viewController.customer = customer
                    viewController.onTemp = true
                    viewController.cartesData = cartesData
                    
                    for i in 0 ..< self.thumbsData.count {
                        
                        for j in 0 ..< self.thumbsData[i].medias.count {
                            
                            if self.thumbsData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                viewController.media1 = self.thumbsData[i].medias[j]
                            } else if self.thumbsData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[1] {
                                viewController.media2 = self.thumbsData[i].medias[j]
                            }
                            
                        }
                        
                    }
                    
                    navigator.pushViewController(viewController, animated: true)
                    removeAllData()
                }
            }
            return
        }
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 2 && GlobalVariables.sharedManager.selectedImageIds.count < 13 {
            
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMorphing.rawValue) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "MorphingVC") as? MorphingVC {
                    if let navigator = navigationController {
                        viewController.customer = customer
                        viewController.onTemp = true
                        viewController.cartesData = cartesData
                        
                        for i in 0 ..< GlobalVariables.sharedManager.selectedImageIds.count {
                            
                            for j in 0 ..< thumbsData.count {
                                
                                for k in 0 ..< thumbsData[j].medias.count {
                                    
                                    if GlobalVariables.sharedManager.selectedImageIds[i] == thumbsData[j].medias[k].media_id {
                                        viewController.mediasData.append(thumbsData[j].medias[k])
                                    }
                                }
                            }
                        }
                        
                        navigator.pushViewController(viewController, animated: true)
                        removeAllData()
                    }
                }
            } else {
                showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
            
            return
        }
    }
    
    @IBAction func onDrawing(_ sender: UIButton) {
    
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "NewDrawingVC") as? NewDrawingVC {
                if let navigator = self.navigationController {
                    viewController.customer = self.customer
                    viewController.onTemp = true
                    viewController.cartesData = cartesData
                    
                    for i in 0 ..< self.thumbsData.count {
                        
                        for j in 0 ..< self.thumbsData[i].medias.count {
                            
                            if self.thumbsData[i].medias[j].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                viewController.media = self.thumbsData[i].medias[j]
                            }
                            
                        }
                        
                    }
                    
                    navigator.pushViewController(viewController, animated: true)
                    removeAllData()
                }
            }
        } else {
            showAlert(message: kALERT_DRAWING_ACCESS_NOT_SATISFY, view: self)
        }
        return
    }
    
}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension PhotoCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "photoCollectCell", for: indexPath) as! photoCollectCell
    
        cell.type = 1
        cell.configure(media: thumbsData[indexPath.section].medias[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return thumbsData[section].medias.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return thumbsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 
        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectCell
        
        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds.append(imageID!)
        
        checkButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectCell
        
        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds = GlobalVariables.sharedManager.selectedImageIds.filter({ $0 != imageID })
        
        checkButtonStatus()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
                fatalError("Could not find proper header")
            }
            header.sectionLabel.text = "Day \(thumbsData[indexPath.section].date)"
            return header
            
        }
        
        return UICollectionReusableView()
    }
    
}

extension PhotoCollectionVC: UICollectionViewDelegateFlowLayout {
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 30)
    }
    
}

//*****************************************************************
// MARK: - photoCollectCell Delegate
//*****************************************************************

extension PhotoCollectionVC: photoCollectCellDelegate {
    
    func didZoom(index: Int) {
        let newPopup = PhotoViewPopup(nibName: "PhotoViewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        
        for i in 0 ..< self.thumbsData.count {
            
            for j in 0 ..< self.thumbsData[i].medias.count {
                if thumbsData[i].medias[j].id == index {
                    newPopup.imgURL = thumbsData[i].medias[j].url
                    newPopup.mediaID = thumbsData[i].medias[j].media_id
                    newPopup.type = 2
                }
            }
        }
        
        self.present(newPopup, animated: true, completion: nil)
    }
}
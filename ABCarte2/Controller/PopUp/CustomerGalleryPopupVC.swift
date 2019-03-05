//
//  CustomerGalleryPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/10/22.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

protocol CustomerGalleryPopupVCDelegate: class {
    func onAddCusAvatar(image:UIImage)
}

class CustomerGalleryPopupVC: UIViewController {

    //Variable
    weak var delegate:CustomerGalleryPopupVCDelegate?
    
    var customer = CustomerData()
    
    var thumbs: Results<ThumbData>!
    var thumbsData: [ThumbData] = []
    
    var imgURL: String?
    
    //IBOutlet
    @IBOutlet weak var collectionGallery: UICollectionView!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    func loadData() {
        guard let fl = collectionGallery?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        fl.sectionHeadersPinToVisibleBounds = true
    
        collectionGallery.register(UINib(nibName: "SectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        let nib = UINib(nibName: "photoCollectCell", bundle: nil)
        collectionGallery.register(nib, forCellWithReuseIdentifier: "photoCollectCell")
        
        collectionGallery.delegate = self
        collectionGallery.dataSource = self
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
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
                
                self.collectionGallery.reloadData()
            } else {
                showAlert(message: "お客様の写真がありません", view: self)
            }
            SVProgressHUD.dismiss()
        }
    }

    @IBAction func onSave(_ sender: UIButton) {
        guard let url = imgURL else {
            return
        }
        
        let uiimage = UIImageView()
        uiimage.sd_setImage(with: URL(string: url)) { (image, error, cache, url) in
            self.delegate?.onAddCusAvatar(image: image!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension CustomerGalleryPopupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "photoCollectCell", for: indexPath) as! photoCollectCell
    
        cell.type = 2
        cell.configure(media: thumbsData[indexPath.section].medias[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return thumbsData[section].medias.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return thumbsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        imgURL = thumbsData[indexPath.section].medias[indexPath.row].url
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
                fatalError("Could not find proper header")
            }
            header.sectionLabel.text = "\(thumbsData[indexPath.section].date)"
            return header
            
        }
        
        return UICollectionReusableView()
    }
    
}

extension CustomerGalleryPopupVC: UICollectionViewDelegateFlowLayout {
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 20)
    }
    
}

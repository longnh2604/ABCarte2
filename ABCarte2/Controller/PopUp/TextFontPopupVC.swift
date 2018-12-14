//
//  TextFontPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/01.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol TextFontPopupVCDelegate: class {
    func onFontSelect(font:String)
}

class TextFontPopupVC: UIViewController {

    //Variable
    weak var delegate:TextFontPopupVCDelegate?
    
    var arrFontData = ["HelveticaNeue-Bold","MarkerFelt-Wide","Arial-BoldMT","PartyLetPlain","Chalkduster","Zapfino","AcademyEngravedLetPlain","AlNile-Bold"]
    var arrFontName = ["Helvetica Neue","MarkerFelt","Arial","Party","Chalkduster","Zapfino","Academy Engraved","AlNile"]
    var indexSelected: Int?
    
    //IBOutlet
    @IBOutlet weak var collectionFont: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "FontCell", bundle: nil)
        collectionFont.register(nib, forCellWithReuseIdentifier: "FontCell")
        
        collectionFont.delegate = self
        collectionFont.dataSource = self
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onSave(_ sender: UIButton) {
        guard let index = indexSelected else {
            return
        }
        
        self.delegate?.onFontSelect(font: arrFontData[index])
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

//*****************************************************************
// MARK: - CollectionView Delegate, Datasource
//*****************************************************************

extension TextFontPopupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "FontCell", for: indexPath) as! FontCell
        cell.configure(font: arrFontName[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrFontData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        indexSelected = indexPath.row
    }
    
}

extension TextFontPopupVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}

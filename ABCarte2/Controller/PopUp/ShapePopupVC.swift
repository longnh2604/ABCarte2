//
//  ShapePopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/10/29.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol ShapePopupVCDelegate: class {
    func didShapeSelect(index:Int)
}

class ShapePopupVC: UIViewController {
    
    //IBOutlet
    @IBOutlet weak var viewShape: RoundUIView!
    @IBOutlet weak var collectShape: UICollectionView!
    
    //Variable
    weak var delegate:ShapePopupVCDelegate?
    
    var arrShape = ["icon_line_black.png","icon_arrow_black.png","icon_rectangle_black.png","icon_rectangle_black_fill.png","icon_ellipse_black.png","icon_ellipse_black_fill.png","icon_star_black.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadData()
    }
    
    func setupUI() {
        viewShape.layer.cornerRadius = 10
        viewShape.clipsToBounds = true
    }
    
    func loadData() {
        collectShape.delegate = self
        collectShape.dataSource = self
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

extension ShapePopupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"StickerCell", for: indexPath) as! StickerCell
        
        cell.configure(imv: arrShape[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrShape.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didShapeSelect(index:indexPath.row)
        
        dismiss(animated: true, completion: nil)
    }
}

extension ShapePopupVC: UICollectionViewDelegateFlowLayout {
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 30)
    }
    
}

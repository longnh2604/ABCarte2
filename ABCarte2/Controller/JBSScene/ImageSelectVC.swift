//
//  ImageSelectVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class ImageSelectVC: UIViewController {

    //Variable
    var arrRealFace = ["JBS_selectA.png","JBS_selectB.png","JBS_selectC.png","JBS_selectD.png","JBS_selectA_no.png","JBS_selectE.png"]
    var arrFace = ["JBS_UIkit-02select-A.png","JBS_UIkit-02select-B.png","JBS_UIkit-02select-C.png","JBS_UIkit-02select-D.png","JBS_UIkit-02select-A_noline.png","JBS_UIkit-02select-D_noline.png"]
    var cellSelected: Int?
    
    //IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    func setupUI() {
        navigationController?.navigationBar.isHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onReset(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate
//*****************************************************************

extension ImageSelectVC : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 360)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 70
    }
}

extension ImageSelectVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSelectCell", for: indexPath) as! ImageSelectCell
        cell.layer.cornerRadius = 10
        cell.imvPhoto.image = UIImage(named: arrFace[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFace.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellSelected == indexPath.row {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "JBSDrawingVC") as? JBSDrawingVC {
                viewController.imgSelected = arrRealFace[indexPath.row]
                viewController.cellSelected = cellSelected
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else {
           cellSelected = indexPath.row
        }
    }
}

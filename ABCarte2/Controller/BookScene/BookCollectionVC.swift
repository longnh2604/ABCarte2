//
//  BookCollectionVC.swift
//  ABCarte2
//
//  Created by Long on 2018/12/21.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class BookCollectionVC: UIViewController {

    //Variable
    var arrRealFace = ["JBS_selectA.png","JBS_selectB.png","JBS_selectC.png","JBS_selectD.png","JBS_selectA_no.png","JBS_selectE.png"]
    var arrFace = ["JBS_UIkit-02select-A.png","JBS_UIkit-02select-B.png","JBS_UIkit-02select-C.png","JBS_UIkit-02select-D.png","JBS_UIkit-02select-A_noline.png","JBS_UIkit-02select-D_noline.png"]
    var cellSelected: Int?
    var accounts: Results<AccountData>!
    
    weak var bottomPanelView: BottomPanelView!
    
    //IBOutlet
    @IBOutlet weak var collectBook: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        collectBook.layer.cornerRadius = 10
        collectBook.layer.borderWidth = 3
        collectBook.layer.borderColor = COLOR_SET.kBLUENAVY.cgColor
        
        bottomPanelView = BottomPanelView.instanceFromNib(self)
        view.addSubview(bottomPanelView)
        bottomPanelView.snp.makeConstraints { (make) -> Void in
            make.height.height.equalTo(60)
            make.trailing.equalTo(self.view)
            make.leading.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        bottomPanelView.btnLogout.isHidden = true
        bottomPanelView.btnSetting.isHidden = true
    }
    
    func loadData() {
        collectBook.delegate = self
        collectBook.dataSource = self
        
        let realm = RealmServices.shared.realm
        self.accounts = realm.objects(AccountData.self)
    }

    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onHelp(_ sender: Any) {
        displayInfo(acc_name: accounts[0].acc_name, acc_id: accounts[0].account_id,view: self)
    }
}

//*****************************************************************
// MARK: - CollectionView Delegate
//*****************************************************************

extension BookCollectionVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
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

extension BookCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
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
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "BookVC") as? BookVC {
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            
        } else {
            cellSelected = indexPath.row
        }
    }
}

//*****************************************************************
// MARK: - BottomPanelView Delegate
//*****************************************************************

extension BookCollectionVC: BottomPanelViewDelegate {
    
    func tapInfo() {
        
    }
}

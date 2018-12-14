//
//  CarteImageListVC.swift
//  ABCarte2
//
//  Created by Long on 2018/06/25.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import JGProgressHUD

class CarteImageListVC: UIViewController,UINavigationControllerDelegate {

    //Variable
    var customer = CustomerData()
    
    var carte = CarteData()
    
    var medias: Results<MediaData>!
    var mediasData : [MediaData] = []
    
    var carteID: String?
    var needLoad: Bool = true
    var imageSelected: UIImage?
    var imageConverted: Data?
    var indexDelete : [Int] = []
    var account_name: String = ""
    var account_id: String = ""
    let hud = JGProgressHUD(style: .dark)

    //IBOutlet
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var collectionImage: UICollectionView!
    
    @IBOutlet weak var btnComparison: UIButton!
    @IBOutlet weak var btnDrawing: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    
    @IBOutlet weak var constraintWCamera: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        needLoad = true
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }

    func loadData() {
        if needLoad == true {
            //add loading view
            showLoading()
          
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(MediaData.self))
            }
            
            getCarteMedias(carteID: carte.id) { (success) in
                if success {
   
                    let realm = RealmServices.shared.realm
                    self.medias = realm.objects(MediaData.self)
                    
                    self.mediasData.removeAll()
                    
                    for i in 0 ..< self.medias.count {
                        self.mediasData.append(self.medias[i])
                    }
                    self.mediasData = self.mediasData.sorted(by: { $0.date > $1.date })
                    
                    self.collectionImage.reloadData()
                    
                    self.hud.dismiss()
                } else {
           
                    self.navigationController?.popToRootViewController(animated: true)
                    self.hud.dismiss()
                }
            }
            needLoad = false
        }
    }

    func setupUI() {
        //set navigation bar title
        let logo = UIImage(named: "CarteImageListNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton

        collectionImage.delegate = self
        collectionImage.dataSource = self
        collectionImage.layer.cornerRadius = 10
        collectionImage.clipsToBounds = true
        collectionImage.allowsMultipleSelection = true

        updateTopView()
        
        //Check current with carte date to show Camera Button
        let dayCome = convertUnixTimestamp(time: carte.select_date)
        lblDayCome.text = dayCome + getDayOfWeek(dayCome)!
        
        let currDate = Date()
        let timeInterval = Int(currDate.timeIntervalSince1970)
        let date = convertUnixTimestamp(time: timeInterval)
        
        if dayCome != date {
            //different date
            btnCamera.isHidden = true
            constraintWCamera.constant = 0
        } else {
            //same with current date
            btnCamera.isHidden = false
            constraintWCamera.constant = 120
        }
    }
    
    func updateTopView() {
        if customer.thumb != "" {
            let url = URL(string: customer.thumb)
            imvCus.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: nil)
        } else {
            imvCus.image = UIImage(named: "nophotoIcon")
        }
        
        imvCus.layer.cornerRadius = 25
        imvCus.clipsToBounds = true
        
        lblCusName.text = customer.last_name + " " + customer.first_name
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }

    func removeAllMemoData() {
        let dict : [String : Any?] = ["selected_status" : 0]
        
        for i in 0 ..< mediasData.count {
            RealmServices.shared.update(self.mediasData[i], with: dict)
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }

    //*****************************************************************
    // MARK: - Action
    //*****************************************************************

    @IBAction func onHelp(_ sender: UIButton) {
        displayInfo(acc_name: account_name, acc_id: account_id,view:self)
    }

    @IBAction func onCamera(_ sender: UIButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 || GlobalVariables.sharedManager.selectedImageIds.count == 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "ShootingVC") as? ShootingVC {
                if let navigator = navigationController {
                    viewController.customer = customer
                    viewController.carte = carte
                    
                    if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                        
                        if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kShootingTranmission.rawValue) {
                            for i in 0 ..< self.mediasData.count {
                                if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                    viewController.media = mediasData[i]
                                }
                            }
                        }
                    }

                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else {
            showAlert(message: kALERT_SHOOTING_TRANMISSION_NOT_SATISFY, view: self)
        }
    }

    @IBAction func onCameraRoll(_ sender: UIButton) {
    
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .formSheet
            
            self.present(imagePicker, animated: true, completion: {
                imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
            })
     
        }
    }

    @IBAction func onDelete(_ sender: UIButton) {
        
        if GlobalVariables.sharedManager.selectedImageIds.count > 0 {
            let alert = UIAlertController(title: "選択画像を削除", message: "選択されている画像を削除してよろしいですか?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
            let confirm = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                self.showLoading()
                
                for i in 0 ..< self.mediasData.count {
                    if self.mediasData[i].selected_status == 1 {
                        self.indexDelete.append(self.mediasData[i].id)
                    }
                }
                deleteMedias(ids: self.indexDelete, completion: { (success) in
                    if success {
                        self.needLoad = true
                        self.loadData()
                        self.hud.dismiss()
         
                    } else {
                        self.hud.dismiss()
            
                        showAlert(message: "削除に失敗しました。", view: self)
                    }
                })
                
                GlobalVariables.sharedManager.selectedImageIds.removeAll()
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            showAlert(message: kALERT_PLEASE_SELECT_PHOTO, view: self)
        }
        
    }

    @IBAction func onComparison(_ sender: UIButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 2 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "ComparisonVC") as? ComparisonVC {
                if let navigator = navigationController {
                    viewController.customer = customer
                    viewController.carte = carte

                    for i in 0 ..< mediasData.count {
                        if mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                            viewController.media1 = mediasData[i]
                        }
                        if mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[1] {
                            viewController.media2 = mediasData[i]
                        }
                    }
                    GlobalVariables.sharedManager.selectedImageIds.removeAll()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else if GlobalVariables.sharedManager.selectedImageIds.count > 2 && GlobalVariables.sharedManager.selectedImageIds.count < 13 {
            
            if GlobalVariables.sharedManager.appLimitation.contains(AppFunctions.kMorphing.rawValue) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "MorphingVC") as? MorphingVC {
                    if let navigator = navigationController {
                        viewController.customer = customer
                        viewController.carte = carte
                        
                        for i in 0 ..< GlobalVariables.sharedManager.selectedImageIds.count {
                            for j in 0 ..< mediasData.count {
                                if GlobalVariables.sharedManager.selectedImageIds[i] == mediasData[j].media_id {
                                    viewController.mediasData.append(mediasData[j])
                                }
                            }
                        }
                        GlobalVariables.sharedManager.selectedImageIds.removeAll()
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            } else {
                showAlert(message: kALERT_ACCOUNT_CANT_ACCESS, view: self)
            }
        } else {
            showAlert(message: kALERT_CHOOSE_2_TO_12_PHOTOS, view: self)
        }
    }

    @IBAction func onDrawing(_ sender: UIButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {

            let alert = UIAlertController(title: "内容を選択してください", message: nil, preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let drawing = UIAlertAction(title: "描画画面", style: .default) { UIAlertAction in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "NewDrawingVC") as? NewDrawingVC {
                    if let navigator = self.navigationController {
                        viewController.customer = self.customer
                        viewController.carte = self.carte

                        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                            for i in 0 ..< self.mediasData.count {
                                if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                    viewController.media = self.mediasData[i]
                                }
                            }
                        }
                        GlobalVariables.sharedManager.selectedImageIds.removeAll()
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
            let jbs = UIAlertAction(title: "JBSシミュレーション", style: .default) { UIAlertAction in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
                if let viewController = storyBoard.instantiateViewController(withIdentifier: "JBSSimulationVC") as? JBSSimulationVC {
                    if let navigator = self.navigationController {
                        viewController.customer = self.customer
                        viewController.carte = self.carte
                        
                        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                            for i in 0 ..< self.mediasData.count {
                                if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                    viewController.media = self.mediasData[i]
                                }
                            }
                        }
                        GlobalVariables.sharedManager.selectedImageIds.removeAll()
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
            alert.addAction(cancel)
            alert.addAction(drawing)
            alert.addAction(jbs)

            alert.popoverPresentationController?.sourceView = self.btnDrawing
            alert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            alert.popoverPresentationController?.sourceRect = self.btnDrawing.bounds
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }

        } else {
            showAlert(message: kALERT_DRAWING_ACCESS_NOT_SATISFY, view: self)
        }
    }
    
    @IBAction func onFaceAnalyze(_ sender: UIButton) {
        if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Media", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "FaceAnalyseVC") as? FaceAnalyseVC {
                if let navigator = self.navigationController {
                    viewController.customer = self.customer
                    viewController.carte = self.carte
                    
                    if GlobalVariables.sharedManager.selectedImageIds.count == 1 {
                        for i in 0 ..< self.mediasData.count {
                            if self.mediasData[i].media_id == GlobalVariables.sharedManager.selectedImageIds[0] {
                                viewController.media = self.mediasData[i]
                            }
                        }
                    }
                    GlobalVariables.sharedManager.selectedImageIds.removeAll()
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else {
            showAlert(message: kALERT_DRAWING_ACCESS_NOT_SATISFY, view: self)
        }
    }
}

//*****************************************************************
// MARK: - ImagePicker Delegate
//*****************************************************************

extension CarteImageListVC: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let newImage = imageWithImage(sourceImage: image, scaledToWidth:self.view.frame.width)
        
        self.dismiss(animated: true, completion: { () -> Void in
            
            self.showLoading()
            
            let imgRotated = newImage.updateImageOrientionUpSide()
            self.imageConverted = UIImageJPEGRepresentation(imgRotated!, 100)
            
            addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageConverted!, completion: { (success) in
                if success {
                    self.needLoad = true
                    self.loadData()
                    self.hud.dismiss()
                } else {
                    self.hud.dismiss()
              
                    showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
            })
            
            GlobalVariables.sharedManager.selectedImageIds.removeAll()
        })
    }
    
}

//*****************************************************************
// MARK: - CollectionView Delegate
//*****************************************************************

extension CarteImageListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarteImageCell", for: indexPath) as? CarteImageCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.configure(media: mediasData[indexPath.row])
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediasData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? CarteImageCell else {
            return
        }
        let dict : [String : Any?] = ["selected_status" : 1]
        RealmServices.shared.update(self.mediasData[indexPath.row], with: dict)

        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds.append(imageID!)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? CarteImageCell else {
            return
        }
        let dict : [String : Any?] = ["selected_status" : 0]
        RealmServices.shared.update(self.mediasData[indexPath.row], with: dict)

        let imageID = cell.imageId
        GlobalVariables.sharedManager.selectedImageIds = GlobalVariables.sharedManager.selectedImageIds.filter({ $0 != imageID })
    }
}

extension CarteImageListVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

//*****************************************************************
// MARK: - CarteImageCell Delegate
//*****************************************************************

extension CarteImageListVC: CarteImageCellDelegate {
    
    func didZoom(index: Int) {
        let newPopup = PhotoViewPopup(nibName: "PhotoViewPopup", bundle: nil)
        newPopup.modalPresentationStyle = UIModalPresentationStyle.formSheet
        newPopup.preferredContentSize = CGSize(width: 700, height: 900)
        
        for i in 0 ..< mediasData.count {
            if mediasData[i].id == index {
                newPopup.imgURL = mediasData[i].url
                newPopup.mediaID = mediasData[i].media_id
                newPopup.delegate = self
                newPopup.type = 1
            }
        }
        
        self.present(newPopup, animated: true, completion: nil)
    }
}

//*****************************************************************
// MARK: - PhotoCollectionVC Delegate
//*****************************************************************

extension CarteImageListVC: PhotoViewPopupDelegate {
    
    func onSetCartePhoto(mediaID: String,url: String) {
        
        showLoading()
        
        editCarte(carteID: carte.id, mediaURL: url) { (success) in
            if success {
                self.hud.dismiss()
                self.dismiss(animated: true, completion: {
                    showAlert(message: kALERT_REGISTER_CARTE_REPRESENTATIVE_SUCCESS, view: self)
                })
                
            } else {
                self.hud.dismiss()
                
                self.dismiss(animated: true, completion: {
                    showAlert(message: kALERT_CANT_GET_CARTE_INFO_PLEASE_CHECK_NETWORK, view: self)
                })
            }
        }
    }
}

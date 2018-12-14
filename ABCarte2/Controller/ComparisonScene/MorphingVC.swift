//
//  MorphingVC.swift
//  ABCarte2
//
//  Created by Long on 2018/07/30.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import JGProgressHUD

class MorphingVC: UIViewController, UIScrollViewDelegate {
    
    //Variable
    var customer = CustomerData()
    var carte = CarteData()
    var mediasData : [MediaData] = []
    var cartesData : [CarteData] = []
    var lockStatus: Bool = false
    var currIndex: Int?
    var lastIndex: Int?
    var onSlideIndex: Int?
    var imageConverted: Data?
    var onTemp: Bool = false
    let hud = JGProgressHUD(style: .dark)
    
    //IBOutlet
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var collectionImg: UICollectionView!
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var sliderTrans: MySlider!
    @IBOutlet weak var btnLock: RoundButton!
    @IBOutlet weak var widthGeneral: NSLayoutConstraint!
    @IBOutlet weak var heightGeneral: NSLayoutConstraint!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        //set navigation bar title
        let logo = UIImage(named: "CarteImageNav.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton

        updateTopView()

        collectionImg.delegate = self
        collectionImg.dataSource = self

        arrangeImage()
        currIndex = 0
        lastIndex = 0

        sliderTrans.minimumValue = 1
        sliderTrans.maximumValue = Float(mediasData.count)
        sliderTrans.value = 1

        sliderTrans.isEnabled = true
        collectionImg.isUserInteractionEnabled = false
        let index = IndexPath.init(row: 0, section: 0)
        collectionImg.selectItem(at: index, animated: true, scrollPosition: .centeredVertically)
        
        viewGeneral.isUserInteractionEnabled = false
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
        
        if onTemp == false {
            let dayCome = convertUnixTimestamp(time: carte.select_date)
            lblDayCome.text = dayCome + getDayOfWeek(dayCome)!
        } else {
            let currDate = Date()
            let timeInterval = Int(currDate.timeIntervalSince1970)
            let date = convertUnixTimestamp(time: timeInterval)
            lblDayCome.text = date + getDayOfWeek(date)!
        }
    }
    
    func showLoading() {
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
    }

    func arrangeImage() {
        for subview in viewGeneral.subviews {
            subview.removeFromSuperview()
        }

        showLoading()
        
        for i in 0 ..< mediasData.count {
            
            let imageView = UIImageView()
            imageView.sd_setImage(with: URL(string: mediasData[i].url), placeholderImage: nil, options: SDWebImageOptions.continueInBackground, progress: nil, completed: nil)
            imageView.frame = viewGeneral.bounds
            imageView.contentMode = .scaleAspectFit
            imageView.tag = i
            
            if i == 0 {
                imageView.alpha = 1
            } else {
                imageView.alpha = 0
            }
            
            imageView.isUserInteractionEnabled = true

            viewGeneral.addSubview(imageView)

        }
        viewGeneral.clipsToBounds = true
        
        self.hud.dismiss()
    }
    
    func reArrangeImage() {
        
        for i in 0 ..< viewGeneral.subviews.count {
            
            if i == 0 {
                viewGeneral.subviews[i].alpha = 1
            } else {
                viewGeneral.subviews[i].alpha = 0
            }
        }
    }

    @objc func back(sender: UIBarButtonItem) {
        // Go back to the previous ViewController
        GlobalVariables.sharedManager.selectedImageIds.removeAll()
        _ = navigationController?.popViewController(animated: true)
    }

    //*****************************************************************
    // MARK: - Gestures
    //*****************************************************************

    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }

    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)

        if recognizer.state == UIGestureRecognizerState.ended {
            // 1
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
           
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)

            // 5
            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           // 6
                options: UIViewAnimationOptions.curveEaseOut, animations: {
                    recognizer.view!.center = finalPoint
            }) { (success) in
                self.view.updateConstraints()
            }
        }
    }

    func removeAllGestures() {
        for subview in viewGeneral.subviews {
            for recognizer in subview.gestureRecognizers ?? [] {
                subview.removeGestureRecognizer(recognizer)
            }
        }
    }

    func saveImageEdit(viewMake:UIView)->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(viewMake.frame.size)
        viewMake.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func onSaveImage(image: UIImage) {
        showLoading()
        
        self.imageConverted = UIImageJPEGRepresentation(image, 100)
        
        if onTemp == false {
            addMedias(cusID: self.customer.id, carteID: self.carte.id,mediaData: self.imageConverted!, completion: { (success) in
                if success {
          
                    self.hud.dismiss()
                } else {
                    self.hud.dismiss()
           
                    showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                }
            })
        } else {
            //Check current date
            var isAdded: Bool = false
            
            for i in 0 ..< cartesData.count {
                let today = Date()
                
                let date = Date(timeIntervalSince1970: TimeInterval(cartesData[i].select_date))
                let isSame = date.isInSameDay(date: today)
                
                if isSame {
                 
                    isAdded = true
                    
                    addMedias(cusID: self.customer.id, carteID: self.cartesData[i].id,mediaData: self.imageConverted!, completion: { (success) in
                        if success {
                    
                            self.hud.dismiss()
                        } else {
                            self.hud.dismiss()
                     
                            showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                        }
                    })
                    return
                    
                } else {
          
                    isAdded = false
                }
            }
            
            if isAdded == false {
                
                let currDate = Date()
                let timeInterval = Int(currDate.timeIntervalSince1970)
                
                //Create Carte first
                addCarteWithIDReturn(cusID: customer.id, date: timeInterval) { (carteID) in
                    if carteID != 0 {
                     
                        
                        addMedias(cusID: self.customer.id, carteID: carteID,mediaData: self.imageConverted!, completion: { (success) in
                            if success {
                           
                                self.hud.dismiss()
                            } else {
                                self.hud.dismiss()
                           
                                showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                            }
                        })
                        
                    } else {
                        self.hud.dismiss()
                    
                        showAlert(message: kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
                    }
                }
            }
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onSlideTransChange(_ sender: UISlider) {
       
        let sliderValue = Int(sender.value)

        let remainder = sender.value.truncatingRemainder(dividingBy: 1)
       
        for i in 0 ..< viewGeneral.subviews.count {
            
            if viewGeneral.subviews[i].tag + 1 == sliderValue {
                viewGeneral.subviews[i].alpha = CGFloat(1 - remainder)
            } else if viewGeneral.subviews[i].tag + 1 == sliderValue + 1 {
                viewGeneral.subviews[i].alpha = CGFloat(remainder)
            } else {
                viewGeneral.subviews[i].alpha = 0
            }
        }
    }

    @IBAction func onLockScreen(_ sender: UIButton) {
        if lockStatus == false {
            
            lockStatus = true
            btnLock.setImage(UIImage(named:"lockIcon_ab"), for: .normal)
            
            collectionImg.isUserInteractionEnabled = true
            let index = IndexPath(row: 0, section: 0)
            collectionImg.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
            
            for i in 0 ..< viewGeneral.subviews.count {
                
                    if i == 0 {
                        viewGeneral.subviews[i].isUserInteractionEnabled = true
                        viewGeneral.subviews[i].alpha = 0.6
                        viewGeneral.subviews[i].addGestureRecognizer(panGesture)
                        viewGeneral.subviews[i].addGestureRecognizer(pinchGesture)
                    }
                    else if i == 1 {
                        viewGeneral.subviews[i].isUserInteractionEnabled = false
                        viewGeneral.subviews[i].alpha = 0.3
                    } else {
                        viewGeneral.subviews[i].isUserInteractionEnabled = false
                        viewGeneral.subviews[i].alpha = 0
                    }
            }
            viewGeneral.isUserInteractionEnabled = true
            sliderTrans.isEnabled = false
            
        } else {
            
            lockStatus = false
            btnLock.setImage(UIImage(named:"unlockIcon_ab"), for: .normal)
            
            collectionImg.isUserInteractionEnabled = false
            viewGeneral.isUserInteractionEnabled = false
            sliderTrans.isEnabled = true
            sliderTrans.value = 1
            
            reArrangeImage()
        }
    }

    @IBAction func onSaveImage(_ sender: UIButton) {
        onSaveImage(image: saveImageEdit(viewMake: viewGeneral))
    }
    
}

//*****************************************************************
// MARK: - CollectionView Delegate
//*****************************************************************

extension MorphingVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MorphingCell", for: indexPath) as! MorphingCell
        cell.configure(media: mediasData[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediasData.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        removeAllGestures()
        currIndex = indexPath.row
        
        for i in 0 ..< viewGeneral.subviews.count {
            
            //first time select
            if currIndex == 0 && lastIndex == 0 {
                if i == 0 {
                    viewGeneral.subviews[i].isUserInteractionEnabled = true
                    viewGeneral.subviews[i].alpha = 0.6
                    viewGeneral.subviews[i].addGestureRecognizer(panGesture)
                    viewGeneral.subviews[i].addGestureRecognizer(pinchGesture)
                }
                else if i == 1 {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0.3
                } else {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0
                }
            } else {
                //not first time
                
                if currIndex == viewGeneral.subviews[i].tag {
                    viewGeneral.subviews[i].isUserInteractionEnabled = true
                    viewGeneral.subviews[i].alpha = 0.6
                    viewGeneral.subviews[i].addGestureRecognizer(panGesture)
                    viewGeneral.subviews[i].addGestureRecognizer(pinchGesture)
                    lastIndex = currIndex
                } else if viewGeneral.subviews[i].tag == 0 {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0.3
                } else {
                    viewGeneral.subviews[i].isUserInteractionEnabled = false
                    viewGeneral.subviews[i].alpha = 0
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

    }
}

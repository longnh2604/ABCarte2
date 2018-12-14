//
//  ImageProcessVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/16.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift

class ImageProcessVC: UIViewController, UIScrollViewDelegate {

    //Variable
    var cusIndex: Int?
    var carteIndex: Int?
    var compareMode: Int?
    var customers: Results<CustomerData>!
    var cartes: Results<CarteData>!
    var medias: Results<MediaData>!
    var cartesData = [CarteData]()
    var mediasData = [MediaData]()
    
    //IBOutlet
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var imvCus: UIImageView!
    @IBOutlet weak var lblCusName: UILabel!
    @IBOutlet weak var lblDayCome: UILabel!
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var viewCompare: UIView!
    @IBOutlet weak var hCompare: NSLayoutConstraint!
    @IBOutlet weak var wCompare: NSLayoutConstraint!
    @IBOutlet weak var scrView1: UIScrollView!
    @IBOutlet weak var imvView1: UIImageView!
    @IBOutlet weak var scrView2: UIScrollView!
    @IBOutlet weak var imvView2: UIImageView!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupUI()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func setupUI() {
//        self.navigationItem.title = "比較画像を作成"
//        
//        btnReset.layer.cornerRadius = 10
//        btnReset.clipsToBounds = true
//        btnHelp.layer.cornerRadius = 10
//        btnHelp.clipsToBounds = true
//        
//        let realm = RealmServices.shared.realm
//        customers = realm.objects(CustomerData.self)
//        cartes = realm.objects(CarteData.self)
//        medias = realm.objects(MediaData.self)
//        
//        for carte in cartes.filter("cusID = '\(customers[cusIndex!].cusID)'") {
//            cartesData.append(carte)
//        }
//        for media in medias.filter("carteID = '\(cartes[carteIndex!].carteID)'") {
//            mediasData.append(media)
//        }
//        
//        imvCus.image = UIImage(contentsOfFile: customers[cusIndex!].cusPicURL)
//        lblCusName.text = customers[cusIndex!].cusFName + " " + customers[cusIndex!].cusLName
//        
//        let dayCome = convertUnixTimestamp(time: cartes[carteIndex!].date)
//        lblDayCome.text = dayCome + getDayOfWeek(dayCome)!
//        
//        viewCompare.backgroundColor = UIColor.clear
//        viewCompare.layer.borderColor = UIColor.black.cgColor
//        viewCompare.layer.borderWidth = 3
//        
//        if kLandscape {
//            switch compareMode {
//            case 0:
//                hCompare.constant = 460
//                wCompare.constant = 720
//            case 1:
//                hCompare.constant = 345
//                wCompare.constant = 540
//            case 2:
//                hCompare.constant = 500
//                wCompare.constant = 390
//            default:
//                break
//            }
//        } else {
//            switch compareMode {
//            case 0:
//                hCompare.constant = 460
//                wCompare.constant = 720
//            case 1:
//                hCompare.constant = 720
//                wCompare.constant = 460
//            case 2:
//                hCompare.constant = 600
//                wCompare.constant = 470
//            default:
//                break
//            }
//        }
//        print("in viewcompare = \(viewCompare)")
//        
//        setupPhotoView()
//    }
//    
//    func setupPhotoView() {
//        scrView1.delegate = self
//        scrView1.minimumZoomScale = 0.5
//        scrView1.maximumZoomScale = 5.0
//        scrView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        scrView2.delegate = self
//        scrView2.minimumZoomScale = 0.5
//        scrView2.maximumZoomScale = 5.0
//        scrView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        imvView1.image = UIImage(named: "faceorigin")
//        imvView2.image = UIImage(named: "facepoint")
//    }
//    
//    func changeCompareViewLayout(_ isLandscape: Bool = true) {
//        if isLandscape {
//            switch compareMode {
//            case 0:
//                viewCompare.frame = CGRect(x: (viewBorder.frame.width - 720)/2, y: (viewBorder.frame.height - 460)/2, width: 720, height: 460)
//            case 1:
//                viewCompare.frame = CGRect(x: (viewBorder.frame.width - 345)/2, y: (viewBorder.frame.height - 540)/2 - 30, width: 345, height: 540)
//            case 2:
//                viewCompare.frame = CGRect(x: (viewBorder.frame.width - 390)/2, y: (viewBorder.frame.height - 500)/2 - 30, width: 390, height: 500)
//            default:
//                break
//            }
//        } else {
//            switch compareMode {
//            case 0:
//                viewCompare.frame = CGRect(x: (viewBorder.frame.width - 720)/2, y: (viewBorder.frame.height - 460)/2, width: 720, height: 460)
//            case 1:
//                viewCompare.frame = CGRect(x: (viewBorder.frame.width - 460)/2, y: (viewBorder.frame.height - 720)/2, width: 460, height: 720)
//            case 2:
//                viewCompare.frame = CGRect(x: (viewBorder.frame.width - 470)/2, y: (viewBorder.frame.height - 600)/2, width: 470, height: 600)
//            default:
//                break
//            }
//        }
//        print("in viewcompare = \(viewCompare)")
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//
//        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
//
//            let orient = UIApplication.shared.statusBarOrientation
//
//            switch orient {
//
//            case .portrait:
//                self.changeCompareViewLayout(false)
//                print("Portrait")
//
//            case .landscapeLeft,.landscapeRight :
//                self.changeCompareViewLayout()
//                print("Landscape")
//
//            default:
//                self.changeCompareViewLayout(false)
//                print("Anything But Portrait")
//            }
//
//        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
//            //refresh view once rotation is completed not in will transition as it returns incorrect frame size.Refresh here
//            self.viewWillLayoutSubviews()
//        })
//        super.viewWillTransition(to: size, with: coordinator)
//        print("in viewcompare = \(viewCompare)")
//    }
//
//    //*****************************************************************
//    // MARK: - Actions
//    //*****************************************************************
//    
//    @IBAction func onReset(_ sender: UIButton) {
//        navigationController?.popToRootViewController(animated: true)
//    }
//    
//    //*****************************************************************
//    // MARK: - ScrollView Delegate
//    //*****************************************************************
//    
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        var imageViewSize = CGSize()
//        switch scrollView.tag {
//        case 1:
//            imageViewSize = imvView1.frame.size
//        case 2:
//            imageViewSize = imvView2.frame.size
//        default:
//            break
//        }
//        let scrollViewSize = scrollView.bounds.size
//        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
//    }
//    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        if scrollView.tag == 1 {
//            return imvView1
//        } else {
//            return imvView2
//        }
//    }
    
}

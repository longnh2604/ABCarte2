//
//  ResultVC.swift
//  JBSDemo
//
//  Created by Long on 2018/05/28.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class ResultVC: UIViewController {

    //Variable
    var imgEdited: UIImage? = nil
    var imgOriginal: UIImage? = nil
    var image: UIImage!
    var mode: Int? = 0
    var picSelected: Int? = 0
    var arrConcept = ["JBS_UIkit-design-concept-01a.png","JBS_UIkit-design-concept-02a.png","JBS_UIkit-design-concept-03a.png","JBS_UIkit-design-concept-04a.png","JBS_UIkit-design-concept-05a.png","JBS_UIkit-design-concept-06a.png"]
    
    //IBOutlet
    @IBOutlet weak var btnCompare: UIButton!
    @IBOutlet weak var btnUpDown: UIButton!
    @IBOutlet weak var btnTranmission: UIButton!
    //view compare
    @IBOutlet weak var viewCompare: UIView!
    @IBOutlet weak var scrUComp: UIScrollView!
    @IBOutlet weak var scrBComp: UIScrollView!
    @IBOutlet weak var imvUComp: UIImageView!
    @IBOutlet weak var imvBComp: UIImageView!
    
    //view updown
    @IBOutlet weak var viewUpDown: UIView!
    @IBOutlet weak var scrUUpDown: UIScrollView!
    @IBOutlet weak var scrBUpDown: UIScrollView!
    @IBOutlet weak var imvUUpDown: UIImageView!
    @IBOutlet weak var imvBUpDown: UIImageView!
    
    //view tranmission
    @IBOutlet weak var viewTranmission: UIView!
    @IBOutlet weak var imvURepresent: UIImageView!
    @IBOutlet weak var imvBRepresent: UIImageView!
    @IBOutlet weak var scrUTrans: UIScrollView!
    @IBOutlet weak var imvUTrans: UIImageView!
    @IBOutlet weak var scrBTrans: UIScrollView!
    @IBOutlet weak var imvBTrans: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var imvConcept: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
  
    func setupUI() {
        
        imvConcept.image = UIImage(named: arrConcept[picSelected!])

        //compare view
        scrUComp.delegate = self
        scrBComp.delegate = self
        
//        scrUComp.minimumZoomScale = 0.5
//        scrUComp.maximumZoomScale = 5.0
//        scrUComp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        scrBComp.minimumZoomScale = 0.5
//        scrBComp.maximumZoomScale = 5.0
//        scrBComp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imvUComp.image = imgEdited
        imvBComp.image = imgOriginal
        
        //updown view
        scrUUpDown.delegate = self
        scrBUpDown.delegate = self
        
//        scrUUpDown.minimumZoomScale = 0.5
//        scrUUpDown.maximumZoomScale = 5.0
//        scrUUpDown.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        scrBUpDown.minimumZoomScale = 0.5
//        scrBUpDown.maximumZoomScale = 5.0
//        scrBUpDown.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imvUUpDown.image = imgEdited
        imvBUpDown.image = imgOriginal
        
        scrUUpDown.contentInset.top = 100
        scrBUpDown.contentInset.top = 100
        
        //tranmission view
        scrUTrans.delegate = self
        scrBTrans.delegate = self
        
//        scrUTrans.minimumZoomScale = 0.5
//        scrUTrans.maximumZoomScale = 5.0
//        scrUTrans.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        scrBTrans.minimumZoomScale = 0.5
//        scrBTrans.maximumZoomScale = 5.0
//        scrBTrans.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5

        imvUTrans.alpha = 1
        imvBTrans.alpha = CGFloat(slider.value)

        imvURepresent.image = imgEdited
        imvBRepresent.image = imgOriginal
        
        imvUTrans.image = imgEdited
        imvBTrans.image = imgOriginal
        
        setButtonStatus()
    }
    
    func setButtonStatus() {
        if mode == 0 {
            btnCompare.setImage(UIImage(named: "JBS_UIkit-comparison-LR_ON.png"), for: .normal)
            btnUpDown.setImage(UIImage(named: "JBS_UIkit-comparison-UD_OFF.png"), for: .normal)
            btnTranmission.setImage(UIImage(named: "JBS_UIkit-comparison-transparent_OFF.png"), for: .normal)
        } else if mode == 1 {
            btnCompare.setImage(UIImage(named: "JBS_UIkit-comparison-LR_OFF.png"), for: .normal)
            btnUpDown.setImage(UIImage(named: "JBS_UIkit-comparison-UD_ON.png"), for: .normal)
            btnTranmission.setImage(UIImage(named: "JBS_UIkit-comparison-transparent_OFF.png"), for: .normal)
        } else {
            btnCompare.setImage(UIImage(named: "JBS_UIkit-comparison-LR_OFF.png"), for: .normal)
            btnUpDown.setImage(UIImage(named: "JBS_UIkit-comparison-UD_OFF.png"), for: .normal)
            btnTranmission.setImage(UIImage(named: "JBS_UIkit-comparison-transparent_ON.png"), for: .normal)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onReset(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onMakeComparison(_ sender: RoundButton) {
        switch sender.tag {
        case 1:
       
            viewCompare.isHidden = false
            viewUpDown.isHidden = true
            viewTranmission.isHidden = true
            mode = 0
        case 2:
      
            viewUpDown.isHidden = false
            viewCompare.isHidden = true
            viewTranmission.isHidden = true
            mode = 1
        case 3:
        
            viewTranmission.isHidden = false
            viewCompare.isHidden = true
            viewUpDown.isHidden = true
            mode = 2
        default:
            return
        }
        setButtonStatus()
    }

    @IBAction func onNext(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "EndingVC") as? EndingVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func onTranmissionSlide(_ sender: UISlider) {
        imvBTrans.alpha = CGFloat(sender.value)
//        imvUTrans.alpha = CGFloat(1.0 - sender.value)
    }
    
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension ResultVC: UIScrollViewDelegate {
 
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var imageViewSize = CGSize()
        switch scrollView.tag {
        case 1:
            if mode == 0 {
                imageViewSize = imvUComp.frame.size
            } else if mode == 1 {
                imageViewSize = imvUUpDown.frame.size
            } else {
                imageViewSize = imvUTrans.frame.size
            }
        case 2:
            if mode == 0 {
                imageViewSize = imvBComp.frame.size
            } else if mode == 1 {
                imageViewSize = imvBUpDown.frame.size
            } else {
                imageViewSize = imvBTrans.frame.size
            }
        default:
            break
        }
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
      
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView.tag == 1 {
            if mode == 0 {
                return imvUComp
            } else if mode == 1 {
                return imvUUpDown
            } else {
                return imvUTrans
            }
        } else {
            if mode == 0 {
                return imvBComp
            } else if mode == 1 {
                return imvBUpDown
            } else {
                return imvBTrans
            }
        }
    }
}

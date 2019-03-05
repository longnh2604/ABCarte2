//
//  PhotoViewPopup.swift
//  ABCarte2
//
//  Created by Long on 2018/10/03.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

protocol PhotoViewPopupDelegate: class {
    func onSetCartePhoto(mediaID:String,url:String)
}

class PhotoViewPopup: UIViewController {

    //Variable
    weak var delegate:PhotoViewPopupDelegate?
    
    var imgURL: String?
    var mediaID: String?
    var type: Int?
    
    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var btnSetCartePhoto: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        guard let url = imgURL else { return }
        
        SVProgressHUD.show(withStatus: "読み込み中")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        imvPhoto.sd_setImage(with: URL(string: url)) { (image, error, cache, url) in
            if (error != nil) {
                showAlert(message: MSG_ALERT.kALERT_CANT_GET_PHOTO_INFO_PLEASE_CHECK_NETWORK, view: self)
            }
            SVProgressHUD.dismiss()
        }
        
        guard let ty = type else {
            btnSetCartePhoto.isHidden = true
            return
        }
        if ty == 1 {
            btnSetCartePhoto.isHidden = false
        } else {
            btnSetCartePhoto.isHidden = true
        }
        setButtonColorStyle(button: btnSetCartePhoto, type: 1)
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************

    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSetCartePhoto(_ sender: UIButton) {
        guard let id = mediaID,let url = imgURL else {
            return
        }
        
        self.delegate?.onSetCartePhoto(mediaID: id,url:url)
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension PhotoViewPopup: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let imageViewSize = imvPhoto.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imvPhoto
    }
}

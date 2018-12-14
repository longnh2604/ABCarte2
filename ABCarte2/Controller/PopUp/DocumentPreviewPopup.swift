//
//  DocumentPreviewPopup.swift
//  ABCarte2
//
//  Created by Long on 2018/11/27.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import JGProgressHUD

class DocumentPreviewPopup: UIViewController {

    //Variable
    var documentsData = DocumentData()
    var isTemp : Bool?
    var pageNo: Int?
    
    //IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTotalPage: UILabel!
    @IBOutlet weak var lblPageNo: UILabel!
    @IBOutlet weak var btnClose: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    func loadData() {
        
        pageNo = 1
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.textLabel.text = "LOADING"
        hud.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0)
        hud.show(in: self.view)
        
        guard let temp = isTemp else {
            return
        }
        
        if temp == true {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[0].url_original)) { (image, error, cache, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    
                } else {
                    
                }
                hud.dismiss()
            }
        } else {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[0].url_edit)) { (image, error, cache, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    
                } else {
                    
                }
                hud.dismiss()
            }
        }
        
        setupPage()
    }
    
    func setupPage() {
        lblTotalPage.text = "合計ページ： \(documentsData.document_pages.count)"
        lblPageNo.text = "ページ： \(pageNo ?? 1)"
        
        if documentsData.document_pages.count > 1 {
            if pageNo == 1 {
                btnPrev.isEnabled = false
                btnNext.isEnabled = true
            } else if pageNo! < documentsData.document_pages.count {
                btnNext.isEnabled = true
                btnPrev.isEnabled = true
            } else {
                btnPrev.isEnabled = true
                btnNext.isEnabled = false
            }
            
        } else {
            btnPrev.isEnabled = false
            btnNext.isEnabled = false
        }
    }

    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPrevious(_ sender: UIButton) {
        
        pageNo = pageNo! - 1
        
        if isTemp == true {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_original)) { (image, error, cache, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    
                }
            }
        } else {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_edit)) { (image, error, cache, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    
                }
            }
        }
        
        setupPage()
    }
    
    @IBAction func onNext(_ sender: UIButton) {

        pageNo = pageNo! + 1
        
        if isTemp == true {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_original)) { (image, error, cache, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    
                }
            }
        } else {
            imvPhoto.sd_setImage(with: URL(string: documentsData.document_pages[pageNo! - 1].url_edit)) { (image, error, cache, url) in
                if (error != nil) {
                    showAlert(message: kALERT_CANT_GET_DOCUMENT_INFO_PLEASE_CHECK_NETWORK, view: self)
                    
                }
            }
        }
        
        setupPage()
    }
}

//*****************************************************************
// MARK: - ScrollView Delegate
//*****************************************************************

extension DocumentPreviewPopup: UIScrollViewDelegate {
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

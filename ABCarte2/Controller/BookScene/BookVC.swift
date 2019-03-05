//
//  BookVC.swift
//  ABCarte2
//
//  Created by Long on 2018/09/19.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import PDFKit
import Photos
import MessageUI
import UIKit.UIGestureRecognizerSubclass

class BookVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var viewThumbnail: PDFThumbnailView!
    @IBOutlet weak var constraintViewThumbnailHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewTitleLabel: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewPageNo: UIView!
    @IBOutlet weak var lblPageNo: UILabel!
    @IBOutlet weak var viewThumbnailContainer: UIView!
    
    //Variable
    var pdfdocument: PDFDocument?
    var pdfthumbView: PDFThumbnailView!
    
    let barHideOnTapGestureRecognizer = UITapGestureRecognizer()
    let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        
        //set gradient navigation bar
        guard let navi = navigationController else { return }
        
        if let set = UserDefaults.standard.integer(forKey: "colorset") as Int? {
            addNavigationBarColor(navigation: navi,type: set)
        } else {
            addNavigationBarColor(navigation: navi,type: 0)
        }
    
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)
        
        barHideOnTapGestureRecognizer.addTarget(self, action: #selector(gestureRecognizedToggleVisibility(_:)))
        view.addGestureRecognizer(barHideOnTapGestureRecognizer)
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        
        pdfView.addGestureRecognizer(pdfViewGestureRecognizer)
        
        pdfView.document = pdfdocument
        
        viewThumbnail.layoutMode = .horizontal
        viewThumbnail.pdfView = pdfView
        
        viewTitleLabel.isHidden = true

        viewTitleLabel.layer.cornerRadius = 4
        viewPageNo.layer.cornerRadius = 4
        
        loadData()
        
        resume()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustThumbnailViewHeight()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.adjustThumbnailViewHeight()
        }, completion: nil)
    }
    
    private func adjustThumbnailViewHeight() {
        self.constraintViewThumbnailHeight.constant = 44 + self.view.safeAreaInsets.bottom
    }
    
    @objc func pdfViewPageChanged(_ notification: Notification) {
        if pdfViewGestureRecognizer.isTracking {
            hideBars()
        }
        updatePageNumberLabel()
    }
    
    @objc func gestureRecognizedToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        if let navigationController = navigationController {
            if navigationController.navigationBar.alpha > 0 {
                hideBars()
            } else {
                showBars()
            }
        }
    }
    
    private func resume() {
        viewThumbnailContainer.alpha = 1
        
        pdfView.isHidden = false
//        viewTitleLabel.alpha = 1
        viewPageNo.alpha = 1

        barHideOnTapGestureRecognizer.isEnabled = true

        updatePageNumberLabel()
    }
    
    private func updatePageNumberLabel() {
        if let currentPage = pdfView.currentPage, let index = pdfView.document?.index(for: currentPage), let pageCount = pdfView.document?.pageCount {
            lblPageNo.text = String(format: "%d/%d", index + 1, pageCount)
        } else {
            lblPageNo.text = nil
        }
    }
    
    private func showBars() {
//        UIView.animate(withDuration: CATransaction.animationDuration()) {
//            self.viewThumbnailContainer.alpha = 1
//            self.viewTitleLabel.alpha = 1
//            self.viewPageNo.alpha = 1
//        }
    }
    
    private func hideBars() {
//        UIView.animate(withDuration: CATransaction.animationDuration()) {
//            self.viewThumbnailContainer.alpha = 0
//            self.viewTitleLabel.alpha = 0
//            self.viewPageNo.alpha = 0
//        }
    }
    
    func loadData() {
        var bookPDF: String?
        #if SERMENT
        bookPDF = "SERMENT_theory"
        #else
        bookPDF = "JBS_designbook"
        #endif
        
        guard let path = Bundle.main.url(forResource: bookPDF, withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path) {
            pdfView.document = document
        }
        
    }
    
    @objc func back(sender: UIBarButtonItem) {
        #if SERMENT
        _ = navigationController?.popViewController(animated: true)
        #else
        guard let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else { return }
        self.present(loginPageView, animated: true, completion: nil)
        #endif 
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
 
}

//*****************************************************************
// MARK: - PDFViewGestureRecognizer
//*****************************************************************

class PDFViewGestureRecognizer: UIGestureRecognizer {
    var isTracking = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
}

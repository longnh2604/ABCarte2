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

class BookVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var pdfView: PDFView!
    
    //Variable
    var pdfdocument: PDFDocument?
    var pdfthumbView: PDFThumbnailView!
    weak var observe : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        loadData()
    }
    
    func setupUI() {
        
        //set gradient navigation bar
        var colors = [UIColor]()
        colors.append(UIColor(red: 69/255, green: 13/255, blue: 1/255, alpha: 1))
        colors.append(UIColor(red: 166/255, green: 123/255, blue: 89/255, alpha: 1))
        navigationController?.navigationBar.apply(gradient: colors)
        
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "icon_back_white.png"), for: UIControlState())
        btnLeftMenu.addTarget(self, action: #selector(self.back(sender:)), for: UIControlEvents.touchUpInside)
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func loadData() {
        guard let path = Bundle.main.url(forResource: "JBS_designbook_20180927", withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path) {
            pdfView.document = document
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        guard let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else {
            return
        }
        self.present(loginPageView, animated: true, completion: nil)
    }
    
    func deleteAllPhotos() {
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            albumsPhoto.enumerateObjects({(collection, index, object) in
                if collection.localizedTitle == "Screenshots"{
                    let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
                    print(photoInAlbum.count) //Screenshots albums count
                    PHAssetChangeRequest.deleteAssets(photoInAlbum)
                }
            })
        }) { (success, error) in
            // Handle success & errors
        }
    }
    
    func detectScreenShot(action: @escaping () -> ()) {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: .UIApplicationUserDidTakeScreenshot, object: nil, queue: mainQueue) { notification in
            // executes after screenshot
            action()
        }
    }
    
    @objc func applicationDidBecomeActive() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as! AppSelectVC
            self.present(loginPageView, animated: true, completion: nil)
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                }
                    
                else {
                    guard let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else {
                        return
                    }
                    self.present(loginPageView, animated: true, completion: nil)
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
            guard let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else {
                return
            }
            self.present(loginPageView, animated: true, completion: nil)
        }
    }
    
    //*****************************************************************
    // MARK: - Actions
    //*****************************************************************
    
    @IBAction func onBack(_ sender: UIButton) {
        guard let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "AppSelectVC") as? AppSelectVC else {
            return
        }
        self.present(loginPageView, animated: true, completion: nil)
    }
}

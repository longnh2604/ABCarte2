//
//  TextInputPopupVC.swift
//  ABCarte2
//
//  Created by Long on 2018/11/20.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit

class TextInputPopupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:44)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.white
        
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Title"
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Save", style:   .plain, target: self, action: #selector(self.btn_clicked(_:)))
        
        let rightButton = UIBarButtonItem(title: "Right", style: .plain, target: self, action: nil)
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    }

    @objc func btn_clicked(_ sender: UIBarButtonItem) {
        // Do something
    }

}

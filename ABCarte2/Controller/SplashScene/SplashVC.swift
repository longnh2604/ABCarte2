//
//  SplashVC.swift
//  ABCarte2
//
//  Created by Long on 2018/05/09.
//  Copyright © 2018 Oluxe. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import Lottie
import SnapKit

class SplashVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var wallpaper: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //lock Screen orientation
        AppUtility.lockOrientation(.portrait)
        
        var animationString = ""
        //load splash image
        #if SERMENT
        animationString = "floral_loading_animation"
        wallpaper.image = UIImage(named: "serment_splash.jpg")
        #elseif SHISEI
        animationString = "floral_loading_animation"
        wallpaper.image = UIImage(named: "SHISEI_splash.png")
        #elseif AIMB
        animationString = "floral_loading_animation"
        wallpaper.image = UIImage(named: "AIMB_splash.png")
        #else
        animationString = "material_wave_loading"
        wallpaper.image = UIImage(named: "JBS_attender_splash.jpg")
        #endif
        
        // Create Loading Animation
        let loadAnimation = LOTAnimationView(name: animationString)
        
        // Set view to full screen, aspectFill
        loadAnimation.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadAnimation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        loadAnimation.contentMode = .scaleAspectFill
        loadAnimation.play(fromFrame: 1, toFrame: 60) { (success) in
            if success {
                self.goToLoginView()
            } else {
                self.goToLoginView()
            }
        }
    
        view.addSubview(loadAnimation)
        loadAnimation.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(200)
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).inset(200)
        }
    }
    
    //Go To Login View
    func goToLoginView() {
        guard let loginPageView = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        self.present(loginPageView, animated: true, completion: nil)
    }

}

//
//  TapBarController.swift
//  Joeppie
//
//  Created by Ercan kalan on 09/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

class TapBarController: UITabBarController {
    
    let homeButton = UIButton.init(type: .custom)
    override func viewDidLoad() {
    
        super.viewDidLoad()
        selectedIndex=1
        
        //Copy this bit to wherever you need the user
        UserService.getPatientInstance(withCompletionHandler: { patient in
            guard patient != nil else {
                //TODO log out, throw message
                return
            }
            //Do what you need to do with the patient here
        })
    }
    
    
    @objc func handleTap() {
       print("testeeee")
    }
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.1, 1.2, 0.9, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // find index if the selected tab bar item, then find the corresponding view and get its image, the view position is offset by 1 because the first item is the background (at least in this case)
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1, let imageView = tabBar.subviews[idx + 1].subviews.first as? UIImageView else {
            return
        }

        imageView.layer.add(bounceAnimation, forKey: nil)
    }
    
    func testen(){
   
         NSLog("testeeeeeennnn")
    }
    
    
}

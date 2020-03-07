//
//  tapbarUi.swift
//  Joeppie
//
//  Created by Ercan kalan on 11/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

class TapBarUI: UITabBar {

    private var middleButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center

        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    }

    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 90, height: 90)
        middleButton.setImage(UIImage(named:"navigation_home"), for: UIControl.State.normal)
        middleButton.layer.cornerRadius = 35
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
//        middleButton.addTarget(self, action: #selector(self.test), for: .touchUpInside)
        addSubview(middleButton)
    }

//    @objc func test() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let medvc = storyboard.instantiateViewController(withIdentifier: "MedicineViewController") as! MedicineViewController
//        (superview?.next as? TapBarController)?.navigationController?.pushViewController(medvc, animated: true)
//    }
}

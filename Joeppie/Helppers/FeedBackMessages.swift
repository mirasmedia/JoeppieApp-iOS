//
//  FeedBackMessages.swift
//  Joeppie
//
//  Created by Shahin Mirza on 24/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

open class FeedbackMessages{    
    fileprivate static func messageDisplay(vC: UIViewController, msg: String, img: UIImage?){
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        imageView.image = UIImage(named: "vinkje")
        
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.view.addSubview(imageView)
        vC.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    class func confirmDeleteMessage(vC: UIViewController){
        let img = UIImage(named: "vinkje")
        let msg = NSLocalizedString("verwijderd", comment: "")
        messageDisplay(vC: vC, msg: msg, img: img)
    }
    
    class func operationFailedMessage(vC: UIViewController){
        let img = UIImage(named: "x-icon")
        let msg = NSLocalizedString("failure_message", comment: "")
        messageDisplay(vC: vC, msg: msg, img: img)
    }
    
    class func confirmSaveDataMessage(vC: UIViewController){
        let img = UIImage(named: "vinkje")
        let msg = NSLocalizedString("saved_data_msg", comment: "")
        messageDisplay(vC: vC, msg: msg, img: img)
    }
}

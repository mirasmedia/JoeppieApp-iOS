//
//  ErrorMessage.swift
//  Joeppie
//
//  Created by Shahin Mirza on 09/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

public class Errorpopup {
    fileprivate static func displayMessage(_ title: String, _ msg: String, _ vc: UIViewController) {
        let alertView = UIAlertController(title: title,
                                          message: msg,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertView.addAction(okAction)
        vc.present(alertView, animated: true)
    }
    
    class func displayErrorMessage(vc: UIViewController, title: String, msg: String){
        displayMessage(title, msg, vc)
    }
    
    class func displayConnectionErrorMessage(vc: UIViewController) {
        let title = NSLocalizedString("connection_error_title", comment: "")
        let msg = NSLocalizedString("connection_error_msg", comment: "")
        displayMessage(title, msg, vc)
    }
}

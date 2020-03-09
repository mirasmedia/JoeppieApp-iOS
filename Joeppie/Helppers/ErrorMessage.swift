//
//  ErrorMessage.swift
//  Joeppie
//
//  Created by Shahin on 09/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

public class Errorpopup {
    class func displayErrorMessage(vc: UIViewController, title: String, msg: String){
        let alertView = UIAlertController(title: title,
                                          message: msg,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertView.addAction(okAction)
        vc.present(alertView, animated: true)
    }
    
    class func displayConnectionErrorMessage(vc: UIViewController) {
        let alertView = UIAlertController(title: NSLocalizedString("connection_error_title", comment: ""),
                                          message: NSLocalizedString("connection_error_msg", comment: ""),
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertView.addAction(okAction)
        vc.present(alertView, animated: true)
    }
}

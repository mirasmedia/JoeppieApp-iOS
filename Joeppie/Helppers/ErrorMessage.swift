////
////  ErrorMessage.swift
////  Joeppie
////
////  Created by qa on 09/03/2020.
////  Copyright © 2020 Bever-Apps. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//public class Errorpopup {
//    class func showConnectionError(vc: PatientTableViewController) {
//        let alertView = UIAlertController(title: NSLocalizedString("connection_error_title", comment: ""), message: NSLocalizedString("connection_error_message", comment: ""), preferredStyle: .alert)
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction) in
//            vc.fetchArticles()
//        }
//        alertView.addAction(OKAction)
//        if let presenter = alertView.popoverPresentationController {
//            presenter.sourceView = vc.view
//            presenter.sourceRect = vc.view.bounds
//        }
//        vc.present(alertView, animated: true, completion: nil)
//    }
//
//    class func displayMessage(vc: UIViewController, message: String, title: String) {
//        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction) in
//        }
//        alertView.addAction(OKAction)
//        if let presenter = alertView.popoverPresentationController {
//            presenter.sourceView = vc.view
//            presenter.sourceRect = vc.view.bounds
//        }
//        vc.present(alertView, animated: true, completion: nil)
//    }
//}

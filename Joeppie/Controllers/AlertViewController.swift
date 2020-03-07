//
//  AlertViewController.swift
//  Joeppie
//
//  Created by Ercan kalan on 10/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

class AlertViewController: UIViewController {
    @IBOutlet weak var titleAlertView: UILabel!
    @IBOutlet weak var nameAlertView: UILabel!
    @IBOutlet weak var imageAlertView: UIImageView!
    @IBOutlet weak var stateAlertView: UILabel!
    @IBOutlet weak var titleNextMedicine: UILabel!
    @IBOutlet weak var timeNextMedicine: UILabel!
    @IBOutlet weak var crossicon: UIButton!
    

    
    @IBAction func crossIcon(_ sender: Any) {
       disMissAlert()
    }
    
    func disMissAlert(){
        self.dismiss(animated: true, completion: nil)
    }

    
}

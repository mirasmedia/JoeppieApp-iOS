//
//  MedicineAddViewController.swift
//  Joeppie
//
//  Created by qa on 14/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class MedicineAddViewController: UIViewController {
    var patient: Patient?
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel.text = "Hier medicine toevoegen vorm maken en afhandelen."
        
    }
}

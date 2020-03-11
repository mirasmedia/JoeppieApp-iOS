//
//  PatientViewController.swift
//  Joeppie
//
//  Created by Shahin on 11/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

class PatientViewController: UIViewController {
    
    @IBOutlet weak var patientName: UILabel!
    var patient: Patient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(showEditPatientView))

        
        patientName.text = patient?.firstName
    }
    
    @objc func showEditPatientView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let patientViewController = storyboard.instantiateViewController(withIdentifier:
            "PatientTableViewController") as? PatientTableViewController else {
                fatalError("Unexpected destination:")
        }
        patientViewController.patient = patient
        self.navigationController?.present(patientViewController, animated: true)
    }
    
}

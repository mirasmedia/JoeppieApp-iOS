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
    @IBOutlet weak var addMediButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(showEditPatientView))
        
        addMediButton.setTitle("Medicatie Toevoegen", for: .normal)

        
        patientName.text = patient?.firstName
    }
    @IBAction func addMedicine(_ sender: Any) {
        print("TAOOED")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addMedicineVc = storyboard.instantiateViewController(withIdentifier:
            "MedicineAddViewController") as? MedicineAddViewController else {
                fatalError("Unexpected destination:")
        }
        addMedicineVc.patient = patient
        self.navigationController?.pushViewController(addMedicineVc, animated: true)
    }
    
    @objc func showEditPatientView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let patientViewController = storyboard.instantiateViewController(withIdentifier:
            "PatientTableViewController") as? PatientTableViewController else {
                fatalError("Unexpected destination:")
        }
        patientViewController.patient = patient
//        self.navigationController?.pushViewController(patientViewController, animated: true)
        self.navigationController?.present(patientViewController, animated: true)
    }
    
}

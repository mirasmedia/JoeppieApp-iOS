//
//  MedicineAddViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 14/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class MedicineAddViewController: UIViewController {
    var patient: Patient?
    var listOfMedicines = [Medicine]()
    let dateFormatter = DateFormatter()
    let timePicker = UIDatePicker()
    @IBOutlet weak var inputTime: UITextField!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var addNewDose: UIButton!
    var frames = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTimepicker()
        
        let dismessTimepicker = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureReconizer:)))
        view.addGestureRecognizer(dismessTimepicker)
        lblTime.text = NSLocalizedString("intake_time", comment: "")
        addNewDose.setTitle(NSLocalizedString("add_doses", comment: ""), for: .normal)
        
    }
    
    func addDosesToList (_ dose: String){
        print("ADDED DOSE: \(dose)")
    }
    
    private func initTimepicker(){
        timePicker.datePickerMode = .time
        inputTime.inputView = timePicker
        timePicker.addTarget(self, action: #selector(self.timePickerChanged(datePicker:)), for: .valueChanged)
        timePicker.frame = CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200)
    }
    
    @objc func viewTapped(gestureReconizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func timePickerChanged(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "HH mm"
        inputTime.text = dateFormatter.string(from: timePicker.date)
    }
    
    @IBAction func addDosePopUP(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addDoseVc = storyboard.instantiateViewController(withIdentifier:
            "AddDoseController") as? AddDoseController else {
                fatalError("Unexpected destination:")
        }
        addDoseVc.addDosesToList = addDosesToList
        
        self.navigationController?.present(addDoseVc, animated: true)
    }
    
}

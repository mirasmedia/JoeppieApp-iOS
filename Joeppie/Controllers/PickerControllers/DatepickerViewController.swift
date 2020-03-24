//
//  DatepickerViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 20/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class DatepickerViewController: UIViewController{
    @IBOutlet weak var lblDatepickerTitle: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    var setTimeFromDatepicker: ((_ dose: Date) -> ())?
    var type = String()
    var selection = Date()
    var isTimePicker = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSave.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        btnSave.layer.cornerRadius = 5
        btnCancel.layer.cornerRadius = 5
        
        if isTimePicker{
            lblDatepickerTitle.text = NSLocalizedString("intake_time", comment: "")
            datePicker.datePickerMode = .time
            datePicker.minuteInterval = 15
            datePicker.locale = Locale(identifier: "en_GB")
        }else{
            lblDatepickerTitle.text = NSLocalizedString("date_of_birth_title", comment: "")
            datePicker.datePickerMode = .date
            datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
            datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        }
        
        if let bDay: Date = selection{
            datePicker.setDate(bDay, animated: false)
        }
        
        datePicker.addTarget(self, action: #selector(self.timePickerChanged(datePicker:)), for: .valueChanged)
    }
    
    @IBAction func saveData(_ sender: Any) {
        setTimeFromDatepicker?(selection)
        dismiss(animated: true)
    }
    
    @IBAction func dissmissView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func timePickerChanged(datePicker: UIDatePicker) {
        selection = datePicker.date
    }
    
}

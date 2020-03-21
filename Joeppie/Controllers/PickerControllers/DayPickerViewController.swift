//
//  DayPickerViewController.swift
//  Joeppie
//
//  Created by qa on 20/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class DayPickerViewController: UIViewController {
    var weekDays = [String]()
    var selectedDay: String?
    var setTimeFromDatepicker: ((_ dose: String) -> ())?
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekDays = [NSLocalizedString("day_all_week", comment: ""),
        NSLocalizedString("day_monday", comment: ""),
        NSLocalizedString("day_tuesday", comment: ""),
        NSLocalizedString("day_wednesday", comment: ""),
        NSLocalizedString("day_thursday", comment: ""),
        NSLocalizedString("day_friday", comment: ""),
        NSLocalizedString("day_saturday", comment: ""),
        NSLocalizedString("day_sunday", comment: "")]
        
        pickerView.delegate = self
        
        btnSave.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        btnSave.layer.cornerRadius = 5
        btnCancel.layer.cornerRadius = 5
        
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        if let day = selectedDay{
            setTimeFromDatepicker?(day)
        }
        closeView()
    }
    
    @IBAction func dissmissView(_ sender: UIButton) {
        closeView()
    }
    
    private func closeView(){
        dismiss(animated: true)
    }
    
}

extension DayPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weekDays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weekDays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDay = weekDays[row]
        print("Selected: \(selectedDay)")
    }
}

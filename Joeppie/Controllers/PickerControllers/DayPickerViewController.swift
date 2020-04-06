//
//  DayPickerViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 20/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class DayPickerViewController: UIViewController {
    var weekDays = [WeekDays]()
    var selectedDay: String?
    var selectedDayWeekDays: WeekDays?
    var setChoosenDay: ((_ day: WeekDays, _ dayTitle: String) -> ())?
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for day in WeekDays.allValues{
            weekDays.append(day)
        }
        
        pickerView.delegate = self
        
        btnSave.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        btnSave.layer.cornerRadius = 5
        btnCancel.layer.cornerRadius = 5
        
        selectedDay = weekDays[0].rawValue
        selectedDayWeekDays = weekDays[0]
        
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        if let dayTitle = selectedDay, let select = selectedDayWeekDays{
            setChoosenDay?(select, dayTitle)
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
        let getDay = NSLocalizedString(weekDays[row].rawValue, comment: "")
        return getDay
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDay = weekDays[row].rawValue
        selectedDayWeekDays = weekDays[row]
    }
}

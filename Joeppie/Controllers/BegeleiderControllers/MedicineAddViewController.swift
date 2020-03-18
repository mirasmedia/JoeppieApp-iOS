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
    var listOfCreatedDoses = [Dose]()
    let dateFormatter = DateFormatter()
    let decoder = JSONDecoder()
    let timePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var weekDays = [String]()
    var selectedDay: String?
    @IBOutlet weak var inputTime: UITextField!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var dayOfWeek: UITextField!
    @IBOutlet weak var addedDosesTable: UITableView!
    
    @IBOutlet weak var addNewDose: UIButton!
    @IBOutlet weak var btnSaveData: UIButton!
    var frames = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTimepicker()
        
        let dismessTimepicker = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureReconizer:)))
        view.addGestureRecognizer(dismessTimepicker)
        lblTime.text = NSLocalizedString("intake_time", comment: "")
        addNewDose.setTitle(NSLocalizedString("add_doses", comment: ""), for: .normal)
        
        weekDays = [NSLocalizedString("day_all_week", comment: ""),
        NSLocalizedString("day_monday", comment: ""),
        NSLocalizedString("day_tuesday", comment: ""),
        NSLocalizedString("day_wednesday", comment: ""),
        NSLocalizedString("day_thursday", comment: ""),
        NSLocalizedString("day_friday", comment: ""),
        NSLocalizedString("day_saturday", comment: ""),
        NSLocalizedString("day_sunday", comment: "")]
        
        createPickerView()
        
    }
    
    @IBAction func saveDataTapped(_ sender: Any) {
        if let txt = dayOfWeek.text, weekDays.contains(txt) {
            print("the textfield'd value is from the array")
        }
        
        print("GGGGG")
    }
    
    func addDosesToList (_ doseId: Int){
        getJustAddedDose(doseId: doseId)
    }
    
    private func getJustAddedDose(doseId: Int){
        if Reachability.isConnectedToNetwork(){
            ApiService.getOneDose(doseId: doseId)
                    .responseData(completionHandler: { (response) in
                    guard let jsonData = response.data else { return }
                        
                        switch(response.result) {
                        case .success(_):
                            self.dateFormatter.locale = Locale.current
                            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                            self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                            guard let dose = try? self.decoder.decode(Dose.self, from: jsonData) else { return }
                            self.listOfCreatedDoses.append(dose)
                            print(self.listOfCreatedDoses)
                            
                        case .failure(_):
                            print("EROOR MESSAGr\(response.result.error)")
                        }
                })
        }
    }
    
    private func initTimepicker(){
        timePicker.datePickerMode = .time
        inputTime.inputView = timePicker
        timePicker.addTarget(self, action: #selector(self.timePickerChanged(datePicker:)), for: .valueChanged)
    }
    
    func createPickerView() {
        pickerView.delegate = self
        dayOfWeek.inputView = pickerView
    }
    
    @objc func viewTapped(gestureReconizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func timePickerChanged(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "HH : mm"
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

extension MedicineAddViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
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
        dayOfWeek.text = selectedDay
    }
}

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
    var deletePlanetIndexPath: IndexPath? = nil
    var deletePlantDose: Dose? = nil
    var baxterTime = Date()
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
        
        addedDosesTable.delegate = self
        addedDosesTable.dataSource = self
        addedDosesTable.register(UINib(nibName: "AddedDoseCell", bundle: nil), forCellReuseIdentifier: "AddedDoseCell")
        addedDosesTable.isHidden = true
        
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
        // Check for input dayofWeek
        if let txt = dayOfWeek.text, weekDays.contains(txt) {
            print("the textfield'd value is from the array")
            if listOfCreatedDoses.count > 0{
                // TODO Save BAXTER into DB
            }else{
                Errorpopup.displayErrorMessage(vc: self, title: "Empty Dose", msg: "You must at least add one dose to the baxter.")
            }
        }
        
        // TODO Throw Error
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
                            self.addedDosesTable.reloadData()
                            
                            if self.addedDosesTable.isHidden{
                                self.addedDosesTable.isHidden = false
                            }
                            
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
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        baxterTime = timePicker.date
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
    
    private func confirmDelete(planet: String) {
        // TODO REPLACE HARDCODED STRINGS
        let alert = UIAlertController(title: "Delete DOSE", message: "Are you sure you want to permanently delete \(planet) dose?", preferredStyle: .actionSheet)
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeletePlanet)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeletePlanet)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    private func cancelDeletePlanet(alertAction: UIAlertAction!) {
        deletePlanetIndexPath = nil
    }
    
    private func handleDeletePlanet(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deletePlanetIndexPath {
            listOfCreatedDoses.remove(at: indexPath.row)
            addedDosesTable.deleteRows(at: [indexPath], with: .fade)
            deletePlanetIndexPath = nil
            addedDosesTable.reloadData()
            
            // Delete Dose from DB
            if let dose = self.deletePlantDose{
                print("DELETING DOSE: \(String(dose.id))")
                self.deleteDose(doseId: dose.id)
                
                self.deletePlantDose = nil
            }
            
            
            if listOfCreatedDoses.count <= 0{
                addedDosesTable.isHidden = true
            }
        }
    }
    
    private func deleteDose(doseId: Int){
        if Reachability.isConnectedToNetwork(){
            ApiService.deleteOneDose(doseId: doseId)
        }
    }
    
}

extension MedicineAddViewController: UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            listOfCreatedDoses.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            deletePlanetIndexPath = indexPath
            let planetToDelete = listOfCreatedDoses[indexPath.row]
            deletePlantDose = planetToDelete
            self.confirmDelete(planet: planetToDelete.medicine.name)
        }
    }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return listOfCreatedDoses.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddedDoseCell", for: indexPath) as? AddedDoseCell else {
                fatalError("The dequeued cell is not an instance of AddedDoseCell")
            }
            
            let x = listOfCreatedDoses[indexPath.row]
            cell.lblAmountValue.text = String(x.amount)
            cell.lblMedicineName.text = x.medicine.name
            cell.lblReasonValue.text = x.medicine.reason
            return cell
        }
    
        
//        TODO: EDIT ADDED DOSE
//        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            self.selectedMedicine = listOfMedicines[indexPath.row]
//            selectMedicineBtn.setTitle(listOfMedicines[indexPath.row].name, for: .normal)
//            medicineId = listOfMedicines[indexPath.row].id
//            removeTransparantView()
//        }
}

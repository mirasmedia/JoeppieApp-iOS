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
    var selectedDay: String?
    var weekDaySelected: WeekDays?
    var deletePlanetIndexPath: IndexPath? = nil
    var deletePlantDose: Dose? = nil
    var baxterTime = String()
    @IBOutlet weak var addedDosesTable: UITableView!
    
    @IBOutlet weak var addNewDose: UIButton!
    @IBOutlet weak var btnSaveData: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSelectTime: UIButton!
    @IBOutlet weak var btnSelectDay: UIButton!
    
    var frames = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // TODO change color and title string
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = NSLocalizedString("add_new_baxter", comment: "")
        
        dateFormatter.locale = Locale.current

        initButtonsAndLabel()
        
        addedDosesTable.delegate = self
        addedDosesTable.dataSource = self
        addedDosesTable.register(UINib(nibName: "AddedDoseCell", bundle: nil), forCellReuseIdentifier: "AddedDoseCell")
        addedDosesTable.isHidden = true

    }
    
    @IBAction func cancelBaxterTapped(_ sender: Any) {
        // TODO SHOW CONFIRM ALERT
        // DELETE ALL CREATED DOSES
        
        self.closeView()
    }
    
    @IBAction func saveDataTapped(_ sender: Any) {
        // Check for input dayofWeek
        if listOfCreatedDoses.count > 0 && selectedDay != nil && baxterTime.count > 5{
            // Everyday loop
            guard let day = self.weekDaySelected else {return}
            if day == WeekDays.EVERYDAY{
                    for everyDay in WeekDays.allValues{
                        if everyDay != WeekDays.EVERYDAY{
                            self.saveBaxterForSevenDays(day: everyDay.rawValue)
                            }
                        }
                    // DELETE ORIGINAL DOSES
                    for x in listOfCreatedDoses{
                        ApiService.deleteOneDose(doseId: x.id)
                    }
                    
                }else{
                    saveBaxter(listOfDoses: listOfCreatedDoses, listOfDoseId: nil)
                }
        }else{
                // TODO REMOVE HARDCODED STRINGS
                Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("empty_value", comment: ""), msg: NSLocalizedString("select_atleast", comment: ""))
            }
    }
    
    private func saveBaxterForSevenDays(day: String){
        var tempList = [Int]()
        var count = 0
        for dose in listOfCreatedDoses{
            saveNewDose(doseAmount: dose.amount, medicineId: dose.medicine.id, completionHandler: {doseId in
                tempList.append(doseId)
                count += 1
                if count == self.listOfCreatedDoses.count{
                    self.selectedDay = day
                    self.saveBaxter(listOfDoses: nil, listOfDoseId: tempList)
                }
            })
        }
    }
    
    private func saveNewDose(doseAmount: Int, medicineId: Int, completionHandler cH : @escaping (Int) -> ()) {
        ApiService.createNewDose(amount: doseAmount, medicineId: medicineId)
                .responseData(completionHandler: { (response) in
                guard let jsonData = response.data else { return }
                    
                    switch(response.result) {
                    case .success(_):
                        self.dateFormatter.locale = Locale.current
                        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                        self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                        guard let dose = try? self.decoder.decode(DoseCreate.self, from: jsonData) else { return }
                        cH(dose.id)
                        
                        
                    case .failure(_):
                        print("EROOR MESSAGr\(response.result.error)")
                    }
            })
            
        }
    
    private func saveBaxter(listOfDoses:[Dose]?, listOfDoseId:[Int]?){
        guard let patientId = patient?.id else { return }
        guard let day = selectedDay else {return}
        var doses = [Int]()
        
        if let list = listOfDoses{
            for x in list{
                doses.append(x.id)
            }
        }
        
        if let list = listOfDoseId{
            doses = list
        }
        
        if Reachability.isConnectedToNetwork(){
            ApiService.createNewBaxter(patientId: patientId, intakeTime: baxterTime, doses: doses, dayOfWeek: day)
            .responseData(completionHandler: { (response) in
                switch(response.result) {
                case .success(_):
                    self.closeView()
                case .failure(_):
                    Errorpopup.displayErrorMessage(vc: self, title: "Failed", msg: "Oeps! something went wrong!")
                }
            })
        }
    }
    
    private func closeView(){
        navigationController?.popViewController(animated: true)
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
    
    private func pickerChanged(time: Date) -> (){
        dateFormatter.dateFormat = "HH : mm"
        btnSelectTime.setTitle(dateFormatter.string(from: time), for: .normal)
        
//        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        baxterTime = dateFormatter.string(from: time)
    }
    
    private func setChoosenDay(day: WeekDays, dayTitle: String) -> (){
        selectedDay = dayTitle
        weekDaySelected = day
        btnSelectDay.setTitle(NSLocalizedString(dayTitle, comment: ""), for: .normal)
    }
    
    @IBAction func selectTimePopUp(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pickerVc = storyboard.instantiateViewController(withIdentifier:
            "DatepickerViewController") as? DatepickerViewController else {
                fatalError("Unexpected destination:")
        }
        pickerVc.setTimeFromDatepicker = pickerChanged
        pickerVc.isTimePicker = true
        self.navigationController?.present(pickerVc, animated: true)
    }
    
    @IBAction func selectDayPopUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pickerVc = storyboard.instantiateViewController(withIdentifier:
            "DayPickerViewController") as? DayPickerViewController else {
                fatalError("Unexpected destination:")
        }
        pickerVc.setChoosenDay = setChoosenDay
        self.navigationController?.present(pickerVc, animated: true)
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
                .responseData { (response) in
                    switch(response.result){
                    case .success(_):
                        FeedbackMessages.confirmDeleteMessage(vC: self)
                    case .failure(_):
                        FeedbackMessages.operationFailedMessage(vC: self)
                    @unknown default:
                        break
                    }
            }
        }
    }
    
    fileprivate func initButtonsAndLabel() {
        addNewDose.setTitle(NSLocalizedString("add_doses", comment: ""), for: .normal)
        btnSaveData.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        btnSelectTime.setTitle(NSLocalizedString("intake_time", comment: ""), for: .normal)
        btnSelectDay.setTitle(NSLocalizedString("intake_day", comment: ""), for: .normal)
        
        
        btnSaveData.layer.cornerRadius = 5
        btnCancel.layer.cornerRadius = 5
        addNewDose.layer.cornerRadius = 5
        btnSelectTime.layer.cornerRadius = 5
        btnSelectDay.layer.cornerRadius = 5
    }
}

extension MedicineAddViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
            
            switch x.medicine.type {
            case "tablet":
                cell.imgMedicineType.image = UIImage(named:"medicine_intake_icon")
            case "liquid":
                cell.imgMedicineType.image = UIImage(named:"Drop_medicine")
            case "capsule":
                cell.imgMedicineType.image = UIImage(named:"capsule")
            default:
                cell.imgMedicineType.image = UIImage(named:"medicine_intake_icon")
            }
            
            return cell
        }
    
}

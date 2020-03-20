//
//  AddDoseController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 18/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class DropDownCell: UITableViewCell {
}

class AddDoseController: UIViewController{
    var listOfMedicines = [Medicine]()
    var selectedMedicine: Medicine?
    var frames = CGRect()
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    let transparantView = UIView()
    let mediListTblView = UITableView()
    var barHeight = CGFloat()
    var addDosesToList: ((_ dose: Int) -> ())?
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var selectMedicineBtn: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var doseAmount = Int()
    var medicineId = Int()
    

    @IBOutlet weak var amountInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMedicines()
        frames = selectMedicineBtn.frame
        
        barHeight = UIApplication.shared.statusBarFrame.size.height +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
        mediListTblView.delegate = self
        mediListTblView.dataSource = self
        mediListTblView.register(DropDownCell.self, forCellReuseIdentifier: "dropDownCell")
        selectMedicineBtn.setTitle(NSLocalizedString("select_medicine", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        btnSave.setTitle(NSLocalizedString("save_button", comment: ""), for: .normal)
        lblAmount.text = NSLocalizedString("amount_lbl", comment: "")
        amountInput.delegate = self
        view.layer.cornerRadius = 5
        btnCancel.layer.cornerRadius = 5; btnSave.layer.cornerRadius = 5
        selectMedicineBtn.layer.borderWidth = 1
        selectMedicineBtn.layer.borderColor = UIColor(red: 11/255, green: 186/255, blue: 69/225, alpha: 1).cgColor
                
    }
    
    
    @IBAction func displayDropDown(_ sender: UIButton) {
        addTransparantView()
    }
    
    @IBAction func saveDoses(_ sender: UIButton) {
        var count = Int()
        if let temp = amountInput.text?.count{
            count = temp
            if let x = Int(amountInput.text ?? "0"){
                self.doseAmount = x
            }
        }
        
        if selectedMedicine == nil{
            // TODO: Error popup
            print("NO MEDICINE")
        }else if count <= 0{
            // TODO ERROR POPUP
                print("NO AMOUNT")
            }
        else{
            saveNewDose()
            dismiss(animated: true)
        }

    }
    
    @IBAction func dissmissView(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    private func addTransparantView(){
//        keyWindow was depardecated in iOS 13
//        let window = UIApplication.shared.keyWindow
        let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        transparantView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparantView)
        
        mediListTblView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(mediListTblView)
        mediListTblView.layer.cornerRadius = 5
        
        transparantView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparantView))
        transparantView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0,
        initialSpringVelocity:1.0,
        options: .curveEaseInOut, animations: {
            self.transparantView.alpha = 0.7
            self.mediListTblView.frame = CGRect(x: self.frames.origin.x, y: self.frames.origin.y + self.frames.height + self.barHeight, width: (self.transparantView.frame.width - CGFloat(40)), height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparantView(){
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity:1.0,
                       options: .curveEaseInOut, animations: {
            self.transparantView.alpha = 0
                        self.mediListTblView.frame = CGRect(x: self.frames.origin.x, y: self.frames.origin.y + self.frames.height, width: self.frames.width, height: 0)
        }, completion: nil)
    }
    
    private func getMedicines(){
        ApiService.getAllMedicines().responseData(completionHandler: { (response) in
            guard let jsonData = response.data else { return }
            self.dateFormatter.locale = Locale.current
            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

            self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
            guard let medi = try? self.decoder.decode([Medicine].self, from: jsonData) else { print("here 2"); return }
            self.listOfMedicines = medi.sorted(by: {$0.name < $1.name})
        })
    }
    
    private func saveNewDose() {
        ApiService.createNewDose(amount: doseAmount, medicineId: medicineId)
                .responseData(completionHandler: { (response) in
                guard let jsonData = response.data else { return }
//                print(String(decoding: jsonData, as: UTF8.self))
                    
                    switch(response.result) {
                    case .success(_):
                        self.dateFormatter.locale = Locale.current
                        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                        self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                        guard let dose = try? self.decoder.decode(DoseCreate.self, from: jsonData) else { return }
                        
                        if let temp = self.addDosesToList{
                            temp(dose.id)
                        }
                        
                    case .failure(_):
                        print("EROOR MESSAGr\(response.result.error)")
                    }
            })
        
    }
    
}

extension AddDoseController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfMedicines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dropDownCell", for: indexPath)
        cell.textLabel?.text = listOfMedicines[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMedicine = listOfMedicines[indexPath.row]
        selectMedicineBtn.setTitle(listOfMedicines[indexPath.row].name, for: .normal)
        medicineId = listOfMedicines[indexPath.row].id
        removeTransparantView()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var bool = Bool()
      if textField == amountInput {
                  let allowedCharacters = "123456789"
                  let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
                  let typedCharacterSet = CharacterSet(charactersIn: string)
                  let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
                  let Range = range.length + range.location > (amountInput.text?.count)!

        let NewLength = (amountInput.text?.count)! + string.count - range.length
        bool = NewLength <= 1
          
        if Range == false && alphabet == false {
              bool =  false
          }
      }else{
        bool = false
        }
        
        if !bool{
            Errorpopup.displayErrorMessage(vc: self,
                                           title: NSLocalizedString("invalide_input_title", comment: ""),
                                           msg: NSLocalizedString("dose_amount_input_error", comment: ""))
            }
        return bool
    }
    
}

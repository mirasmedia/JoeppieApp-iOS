//
//  PatientViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 09/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import UIKit
import Foundation

class PatientTableViewController: UIViewController {
    
    //Shahin: - Outlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var insertionTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var btnBirthday: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    //Shahin: - Properties
    var selected = false
    var textFields = [UITextField]()
    let dateFormatter = DateFormatter()
    var patient: Patient?
    var coach: Coach?
    var newUser: NewUser?
    let decoder = JSONDecoder()
    var upDatePatientVc: ((_ patient: Patient) -> ())?
    var reloadPatientsList: (() -> ())?
    var patientBirthday: Date?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //Shahin: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @IBAction func showDatePicker(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pickerVc = storyboard.instantiateViewController(withIdentifier:
            "DatepickerViewController") as? DatepickerViewController else {
                fatalError("Unexpected destination:")
        }
        if patient != nil{
            if let date = patient?.dateOfBirth{
                pickerVc.selection = date
            }
        }
        pickerVc.setTimeFromDatepicker = pickerChanged
        self.navigationController?.present(pickerVc, animated: true)
    }
    
    private func pickerChanged(date: Date) -> (){
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let bDay = dateFormatter.string(from: date)
        patientBirthday = date
        btnBirthday.setTitle(bDay, for: .normal)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let color = UIColor(red: 122/255, green: 107/255, blue: 139/255, alpha: 1.0)
        textField.layer.borderColor = color.cgColor
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
           textField.layer.borderWidth = 0.0
       }
    
    //Shahin: - Functions
    fileprivate func initNewPatient() {
        titleLbl.text = NSLocalizedString("new_patient_title", comment: "")
        firstNameTextField.placeholder = NSLocalizedString("first_name_placeholder", comment: "")
        insertionTextField.placeholder = NSLocalizedString("insertion_placeholder", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("last_name_placeholder", comment: "")
        btnBirthday.setTitle(NSLocalizedString("date_of_birth_title", comment: ""), for: .normal)
        usernameTextField.placeholder = NSLocalizedString("username_placeholder", comment: "")
        emailTextField.placeholder = NSLocalizedString("email_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password_placeholder", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("confirm_password_placeholder", comment: "")
    }
    
    fileprivate func initEditPatient() {
        titleLbl.text = NSLocalizedString("edit_patient_title", comment: "")
        firstNameTextField.text = patient?.firstName
        if patient?.insertion != nil{
            insertionTextField.text = patient?.insertion
        }else{
            insertionTextField.placeholder = NSLocalizedString("insertion_placeholder", comment: "")
        }
        lastNameTextField.text = patient?.lastName

        if let ddd = patient?.dateOfBirth{
            dateFormatter.dateFormat = "dd MMMM yyyy"
            let bDay = dateFormatter.string(from: ddd)
            btnBirthday.setTitle(bDay, for: .normal)
            patientBirthday = ddd
        }else{
            btnBirthday.setTitle(NSLocalizedString("date_of_birth_title", comment: ""), for: .normal)
        }
        
        usernameTextField.text = patient?.user.username
        emailTextField.text = patient?.user.email
        passwordTextField.placeholder = NSLocalizedString("password_placeholder", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("confirm_password_placeholder", comment: "")
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        print("Save tapped")
        self.savePatientData()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
    private func setup(){
        saveButton.setTitle(NSLocalizedString("done_button", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("cancel_button", comment: ""), for: .normal)
        
        saveButton.layer.cornerRadius = 4
        cancelButton.layer.cornerRadius = 4
        
        
        if patient != nil{
            initEditPatient()
        }else{
            initNewPatient()
        }
        
        textFields = [firstNameTextField, insertionTextField, lastNameTextField, usernameTextField, passwordTextField, confirmPasswordTextField]
        
        for field in textFields {
            field.delegate = self
        }
    }
    
    fileprivate func checkBirthday(_ dateOfBirth: Date) -> Bool{
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let setBirthay = dateFormatter.string(from: dateOfBirth)
        let dateToday = dateFormatter.string(from: Date())
        
        if (setBirthay == dateToday){
            Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("birthday_fields_title", comment: ""), msg: NSLocalizedString("empty_birthday_fields_msg", comment: ""))
            return false
        }
        
        return true
    }
    
    fileprivate func checkEmptyFields(_ fields: [String]) -> Bool {
        for value in fields{
            if value.isEmpty{
                Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("empty_fields_title", comment: ""), msg: NSLocalizedString("empty_fields_msg", comment: ""))
                return false
            }
        }
        return true
    }
    
    fileprivate func checkEmail(_ email: String) -> Bool {
        if !InputValidator.isValidEmail(email){
            Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("invalide_email_title", comment: ""), msg: NSLocalizedString("invalide_email_msg", comment: ""))
            return false
        }
        return true
    }
    
    fileprivate func checkPassword(_ pass: String, conf: String) -> Bool{
        if pass != conf{
            Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("invalide_pass_title", comment: ""), msg: NSLocalizedString("invalide_conf_pass_msg", comment: ""))
            return false
        }
        
        if !InputValidator.validatePassword(input: pass){
            Errorpopup.displayErrorMessage(vc: self, title: NSLocalizedString("invalide_pass_title", comment: ""), msg: NSLocalizedString("invalide_pass_msg", comment: ""))
            return false
        }
        
        return true
    }
    
    
    fileprivate func createNewPatient(_ username: String, _ email: String, _ password: String, _ dateOfBirth: Date, _ firstName: String, _ insertion: String, _ lastName: String) -> Bool {
        if Reachability.isConnectedToNetwork(){
            ApiService.createUser(withUsername: username, email: email, andPassword: password)
                .responseData(completionHandler: { (response) in
                    guard let jsonData = response.data else { return }
                    switch(response.result) {
                    case .success(_):
                        guard let addedUser = try? self.decoder.decode(NewUser.self, from: jsonData) else { return }
                        self.newUser = addedUser
                        guard let coachId = self.coach?.id else { return }
                        guard let userId = self.newUser?.user.id else { return }
                        
                        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        ApiService.createPatient(user: userId,
                                                 first_name: firstName,
                                                 insertion: insertion,
                                                 last_name: lastName,
                                                 date_of_birth: self.dateFormatter.string(from: dateOfBirth),
                                                 coach_id: coachId)
                            .responseData(completionHandler: { (response) in
                                
                                switch(response.result){
                                case .success(_):
                                    self.jobFinished()
                                case .failure(_):
                                    FeedbackMessages.operationFailedMessage(vC: self)
                                }
                            })
                        
                    case .failure(_):
                        print("Error message:\(response.result.error)")
                    }
                })
            return true
            
        }else{
            Errorpopup.displayConnectionErrorMessage(vc: self)
        }
        
        return false
    }
    
    fileprivate func updatePatient(_ username: String, _ email: String, _ dateOfBirth: Date, _ firstName: String, _ insertion: String?, _ lastName: String, password: String? = nil) -> Bool {
        guard let getPatient = self.patient else { return false}
        
        if Reachability.isConnectedToNetwork(){
            ApiService.updateUser(userId: getPatient.user.id, username: username, email: email, password: password)
                .responseData(completionHandler: { (response) in
                    self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    ApiService.updatePatient(patinetId: getPatient.id,
                                             first_name: firstName,
                                             insertion: insertion,
                                             last_name: lastName,
                                             date_of_birth: self.dateFormatter.string(from: dateOfBirth))
                        .responseData(completionHandler: { (response) in                        
                            
                            self.dateFormatter.locale = Locale.current
                            self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                            guard let jsonData = response.data else { return }
                            guard let pat = try? self.decoder.decode(Patient.self, from: jsonData) else { return }
                            self.patient = pat
                            self.jobFinished()
                            self.reloadInputViews()
                        })
                    })
            return true
                }else{
            Errorpopup.displayConnectionErrorMessage(vc: self)
        }

        return false
    }

    
    private func savePatientData() {
        let firstName = firstNameTextField.text ?? ""
        let insertion = insertionTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let bDay = patientBirthday ?? Date()
        let username = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        let dateOfBirth = bDay
        
        //Get Coach instance
        UserService.getCoachInstance(withCompletionHandler: { coach in
            guard let coach = coach else {
                UserService.logOut()
                return
            }
            self.coach = coach
        })
        
        //Shahin: Check for birthday field
        //Shahin: Check for empty fields
        let fields = [firstName, lastName, username, email]
        if checkEmptyFields(fields) &&
            checkBirthday(dateOfBirth) &&
            checkEmail(email){
            
            if patient != nil{
                print("Editing patient")
                if let text = passwordTextField.text, !text.isEmpty && checkPassword(password, conf: confirmPassword){
                    updatePatient(username, email,dateOfBirth, firstName, insertion, lastName, password: password)
                }else{
                    updatePatient(username, email,dateOfBirth, firstName, insertion, lastName)
                }
            }else{
                print("Saving new patient")
                if checkPassword(password, conf: confirmPassword){
                    print("Saving new after pass check patient")
                    createNewPatient(username, email, password, dateOfBirth, firstName, insertion, lastName)
                    
                }
            }
        }
    }
    
   private func jobFinished(){
    navigationController?.popViewController(animated: true)
        if let p = patient{
            self.upDatePatientVc?(p)
        }
    }
}

extension PatientTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         
        let nextTag = textField.tag + 1
        for field in textFields {
            if field.tag == nextTag {
                field.becomeFirstResponder()
                return true
            }
        }
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
      }
}

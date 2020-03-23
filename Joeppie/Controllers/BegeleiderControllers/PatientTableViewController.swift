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
    
    @IBOutlet weak var dateOfBirthTitle: UILabel!
    @IBOutlet weak var dateOfBirth: UITextField!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var test: UITextField!
    
    //Shahin: - Properties
    var selected = false
    var textFields = [UITextField]()
    let dateFormatter = DateFormatter()
    var patient: Patient?
    var coach: Coach?
    var newUser: NewUser?
    let dateOfBirthPicker = UIDatePicker()
    let decoder = JSONDecoder()
    var upDatePatientVc: ((_ patient: Patient) -> ())?
    var reloadPatientsList: (() -> ())?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //Shahin: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateOfBirthPicker.datePickerMode = .date
        dateOfBirthPicker.addTarget(self, action: #selector(self.dateOfBirthChanged(datePicker:)), for: .valueChanged)
        dateOfBirth.inputView = dateOfBirthPicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureReconizer:)))
        view.addGestureRecognizer(tapGesture)
        
        setup()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let color = UIColor(red: 122/255, green: 107/255, blue: 139/255, alpha: 1.0)

        textField.layer.borderColor = color.cgColor
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
           textField.layer.borderWidth = 0.0
       }
    
    @objc func viewTapped(gestureReconizer: UIGestureRecognizer){
        view.endEditing(true)
    }
    
    // Change birthday label when picker is changed
    @objc func dateOfBirthChanged(datePicker: UIDatePicker) {
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirth.text = dateFormatter.string(from: dateOfBirthPicker.date)
    }
    
    //Shahin: - Functions
    fileprivate func initNewPatient() {
        titleLbl.text = NSLocalizedString("new_patient_title", comment: "")
        firstNameTextField.placeholder = NSLocalizedString("first_name_placeholder", comment: "")
        insertionTextField.placeholder = NSLocalizedString("insertion_placeholder", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("last_name_placeholder", comment: "")
        
        dateOfBirthTitle.text = NSLocalizedString("date_of_birth_title", comment: "")
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirth.text = dateFormatter.string(from: dateOfBirthPicker.date)
        
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
        
        dateOfBirthTitle.text = NSLocalizedString("date_of_birth_title", comment: "")
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirth.text = dateFormatter.string(from: patient?.dateOfBirth ?? dateOfBirthPicker.date)
        guard let ddd = patient?.dateOfBirth else{return}
        dateOfBirthPicker.setDate(ddd, animated: false)
        
        usernameTextField.text = patient?.user.username
        emailTextField.text = patient?.user.email
        passwordTextField.placeholder = NSLocalizedString("password_placeholder", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("confirm_password_placeholder", comment: "")
    }
    @IBAction func saveTapped(_ sender: UIButton) {
        savePatientData()
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
      
        dateOfBirthPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
        dateOfBirthPicker.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
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
                                guard let jsonData = response.data else { return }
                                guard let pat = try? self.decoder.decode(Patient.self, from: jsonData) else { return }
                                self.patient = pat
                                self.jobFinished()
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
                            print("RAWRESPONSE \(response.result.value)")
                            
                            
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
        guard let firstName = firstNameTextField.text else { return }
        guard let insertion = insertionTextField.text else { return }
        guard let lastName = lastNameTextField.text else { return }
        
        let dateOfBirth = dateOfBirthPicker.date
        
        guard let username = usernameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let confirmPassword = confirmPasswordTextField.text else { return }
        
        
        //Shahin: Check for birthday field
        //Shahin: Check for empty fields
        let fields = [firstName, lastName, username, email]
        if checkEmptyFields(fields) &&
            checkBirthday(dateOfBirth) &&
            checkEmail(email){
            
            //Get Coach instance
            UserService.getCoachInstance(withCompletionHandler: { coach in
                guard let coach = coach else {
                    UserService.logOut()
                    return
                }
                
                self.coach = coach
            })
            
            
            if patient != nil{
                
                if let text = passwordTextField.text, !text.isEmpty && checkPassword(password, conf: confirmPassword){
                        updatePatient(username, email,dateOfBirth, firstName, insertion, lastName, password: password)
                }else{
                    updatePatient(username, email,dateOfBirth, firstName, insertion, lastName)
                }
            }else{
                if checkPassword(password, conf: confirmPassword){
                    createNewPatient(username, email, password, dateOfBirth, firstName, insertion, lastName)
            }
            
            
        }
        
    }
    }
    
   private func jobFinished(){
        if let p = patient{
            self.upDatePatientVc?(p)
        }
    
        self.reloadPatientsList?()
        self.dismiss(animated: true)
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



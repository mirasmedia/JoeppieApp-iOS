//
//  PatientViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 09/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import UIKit
import Foundation

class PatientTableViewController: UITableViewController {
    
    //Shahin: - Outlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var insertionTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthTitle: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //Shahin: - Properties
    var patientsView: PatientsTableViewController?
    var selected = false
    var textFields = [UITextField]()
    let dateFormatter = DateFormatter()
    var patient: Patient?
    var coach: Coach?
    var newUser: NewUser?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //Shahin: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    //Shahin: - Functions
    fileprivate func initNewPatient() {
        firstNameTextField.placeholder = NSLocalizedString("first_name_placeholder", comment: "")
        insertionTextField.placeholder = NSLocalizedString("insertion_placeholder", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("last_name_placeholder", comment: "")
        
        dateOfBirthTitle.text = NSLocalizedString("date_of_birth_title", comment: "")
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirthLabel.text = dateFormatter.string(from: dateOfBirthPicker.date)
        
        usernameTextField.placeholder = NSLocalizedString("username_placeholder", comment: "")
        emailTextField.placeholder = NSLocalizedString("email_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password_placeholder", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("confirm_password_placeholder", comment: "")
    }
    
    fileprivate func initEditPatient() {
        firstNameTextField.text = patient?.firstName
        if patient?.insertion != nil{
            insertionTextField.text = patient?.insertion
        }else{
            insertionTextField.placeholder = NSLocalizedString("insertion_placeholder", comment: "")
        }
        lastNameTextField.text = patient?.lastName
        
        dateOfBirthTitle.text = NSLocalizedString("date_of_birth_title", comment: "")
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirthLabel.text = dateFormatter.string(from: patient?.dateOfBirth ?? dateOfBirthPicker.date)
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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        dateOfBirthPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
        dateOfBirthPicker.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        textFields = [firstNameTextField, insertionTextField, lastNameTextField, usernameTextField, passwordTextField, confirmPasswordTextField]
        
        for field in textFields {
            field.delegate = self
        }
    }
    
    fileprivate func checkBirthday(_ dateOfBirth: Date) -> Bool{
        dateFormatter.locale = Locale.current
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
                        if let data = response.result.value{
                            let decoder = JSONDecoder()
                            guard let addedUser = try? decoder.decode(NewUser.self, from: jsonData) else { return }
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
                                    let decoder = JSONDecoder()
                                    guard let pat = try? decoder.decode(Patient.self, from: jsonData) else { return }
                                    self.patient = pat
                                })
                        }
                        
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
        let fields = [firstName, lastName, username, email, password, confirmPassword]
        if checkEmptyFields(fields) &&
            checkBirthday(dateOfBirth) &&
            checkPassword(password, conf: confirmPassword) &&
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
                //UPDATE PATIENT
                print("Edir patient")
            }else{
                if createNewPatient(username, email, password, dateOfBirth, firstName, insertion, lastName){
                    self.dismiss(animated: true, completion: {
                        self.patientsView?.reloadPatients()
                    })
                }
            }
            
            
        }
        
    }
    
    // Change birthday label when picker is changed
    @IBAction func dateOfBirthChanged(_ sender: Any) {
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirthLabel.text = dateFormatter.string(from: dateOfBirthPicker.date)
    }
    
    // Shahin: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            if selected {
                return 2
            } else {
                return 1
            }
        case 2:
            return 4
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //do something
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 1 || indexPath.row != 0 { return }
        
        tableView.beginUpdates()
        
        var path = indexPath
        path.row = path.row + 1
        
        if !selected {
            tableView.insertRows(at: [path], with: .fade)
            self.view.endEditing(true)
        } else {
            tableView.deleteRows(at: [path], with: .fade)
        }
        selected = !selected
        tableView.endUpdates()
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



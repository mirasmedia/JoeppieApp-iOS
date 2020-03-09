//
//  PatientViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 09/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import UIKit

class PatientTableViewController: UITableViewController {
    
    //Shahin: - Outlets
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var insertionTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthTitle: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Shahin: - Properties
    var selected = false
    var textFields = [UITextField]()
    
    
    //Shahin: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setup()
    }
    
    //Shahin: - Functions
    private func setup(){
        cancelButton.title = NSLocalizedString("cancel_button", comment: "")
        doneButton.title = NSLocalizedString("done_button", comment: "")
        navigationTitle.title = NSLocalizedString("new_patient_title", comment: "")
        
        firstNameTextField.placeholder = NSLocalizedString("first_name_placeholder", comment: "")
        insertionTextField.placeholder = NSLocalizedString("insertion_placeholder", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("last_name_placeholder", comment: "")
        
        dateOfBirthPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
        dateOfBirthPicker.maximumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())

        
        dateOfBirthTitle.text = NSLocalizedString("date_of_birth_title", comment: "")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirthLabel.text = dateFormatter.string(from: dateOfBirthPicker.date)
        
        usernameTextField.placeholder = NSLocalizedString("username_placeholder", comment: "")
        emailTextField.placeholder = NSLocalizedString("email_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("password_placeholder", comment: "")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        textFields = [firstNameTextField, insertionTextField, lastNameTextField, usernameTextField, passwordTextField]
        
        for field in textFields {
            field.delegate = self
        }
    }
    
    //Shahin: - Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let firstName = firstNameTextField.text else { return }
        guard let insertion = insertionTextField.text else { return }
        guard let lastName = lastNameTextField.text else { return }
        
        let dateOfBirth = dateOfBirthPicker.date
        
        guard let username = usernameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        print("First name: \(firstName)")
        print("Insertion: \(insertion)")
        print("Last name: \(lastName)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        print("Birthday: \(dateFormatter.string(from: dateOfBirth))")
        
        print("Username: \(username)")
        print("Email: \(email)")
        print("Password: \(password)")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateOfBirthChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirthLabel.text = dateFormatter.string(from: dateOfBirthPicker.date)
    }
    
    
    // Shahin: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
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
            return 3
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



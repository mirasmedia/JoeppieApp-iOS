//
//  PatientsTableViewController.swift
//  Joeppie
//
//  Created by Shahin Mirza on 07/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class PatientsTableViewController: UITableViewController {

    var patients = [Patient]()
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var addPatientButton: UIBarButtonItem!
    @IBOutlet var patientsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        logOutButton.title = NSLocalizedString("log_out_button", comment: "")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        patientsTableView.register(UINib(nibName: "PatientTableViewCell", bundle: nil), forCellReuseIdentifier: "PatientTableViewCell")
        
        getPatients()
    }
    
    private func getPatients() {
        UserService.getCoachInstance(withCompletionHandler: { coach in
            guard let coach = coach else {
                UserService.logOut()
                return
            }
            
            ApiService.getPatients(forCoachId: coach.id).responseData(completionHandler: { (response) in
                guard let jsonData = response.data else { return }
                //print(String(decoding: jsonData, as: UTF8.self))
                let decoder = JSONDecoder()
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                guard let patients = try? decoder.decode([Patient].self, from: jsonData) else { return }
                self.patients = patients.sorted(by: {$0.firstName < $1.firstName})
                // TODO : Delete print
                print(patients)
                self.patientsTableView.reloadData()
            })
        })
    }
    
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        UserService.logOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addPatientButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let patientViewController = storyboard.instantiateViewController(withIdentifier:
            "PatientTableViewController") as? PatientTableViewController else {
                fatalError("Unexpected destination:")
        }
        self.navigationController?.present(patientViewController, animated: true)
    }
    
    // Shahin: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return patients.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PatientTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PatientTableViewCell else {
            fatalError("The dequeued cell is not an instance of PatientTableViewCell")
        }

        let patient = patients[indexPath.row]
        if let insertion = patient.insertion {
            cell.patientNameLabel.text = "\(patient.firstName) \(insertion) \(patient.lastName)"
        } else {
            cell.patientNameLabel.text = "\(patient.firstName) \(patient.lastName)"
        }
        cell.badgeImageView.isHidden = true
        
        //Shahin : TODO Find a way to enable the badge for users
//        cell.badgeImageView.isHidden = indexPath.row % 2 == 0

        return cell
    }
}

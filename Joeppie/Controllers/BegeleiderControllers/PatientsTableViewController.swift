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
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var addPatientButton: UIBarButtonItem!
    @IBOutlet var patientsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        logOutButton.title = NSLocalizedString("log_out_button", comment: "")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(realoadPtientsList), for: .valueChanged)
        self.refreshControl = refreshControl
        
        patientsTableView.register(UINib(nibName: "PatientTableViewCell", bundle: nil), forCellReuseIdentifier: "PatientTableViewCell")
        
        getPatients()
    }
    
    @objc func realoadPtientsList() {
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
//                print(String(decoding: jsonData, as: UTF8.self))

                
                self.dateFormatter.locale = Locale.current
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                guard let patients = try? self.decoder.decode([Patient].self, from: jsonData) else { return }
                self.patients = patients.sorted(by: {$0.firstName < $1.firstName})
                self.patientsTableView.reloadData()
                self.refreshControl?.endRefreshing()
            })
        })
    }
    
    public func reloadPatients(){
        self.getPatients()
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
        patientViewController.patientsView = self
        self.navigationController?.present(patientViewController, animated: true, completion: nil)
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
        
        // Shahin : TODO Find a way to enable the badge for users
        // Exmaple isHidden = function(user.Id) {Calculte, return true}
//        cell.badgeImageView.isHidden = indexPath.row % 2 == 0

        return cell
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientVc = storyboard.instantiateViewController(withIdentifier:
            "PatientViewController") as! PatientViewController
        patientVc.patient = patients[indexPath.row]
        navigationController?.pushViewController(patientVc, animated: true)
    }
}

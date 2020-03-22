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
    var patientsNeedAttention = [PatientForBegeleider]()
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
        refreshControl.addTarget(self, action:  #selector(realoadPatientsList), for: .valueChanged)
        self.refreshControl = refreshControl

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        patientsTableView.register(UINib(nibName: "PatientTableViewCell", bundle: nil), forCellReuseIdentifier: "PatientTableViewCell")
        
        getPatients()
    }
    
    @objc func realoadPatientsList() {
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

                self.dateFormatter.locale = Locale.current
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

                self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                guard let patients = try? self.decoder.decode([Patient].self, from: jsonData) else { return }
//                self.patients = patients.sorted(by: {$0.firstName < $1.firstName})
                self.patients = patients
                self.checkPatients()
            })
        })
    }
    
    private func checkPatients(){
        var index: Int = 0
        patientsNeedAttention.removeAll()
        
        for p in self.patients{
            self.getPatientIntakes(patient: p, withCompletionHandler: { intakes in
                self.patientNeedsMoreAttention(intakes: intakes, withCompletionHandler: { bool in
                    self.patientsNeedAttention.append(PatientForBegeleider(patient: p, needsAttention: bool))
                    index += 1
                    
                    if index == self.patients.count {
                        self.reloadView()
                    }
                })
            })
        }
    }
    
    private func reloadView(){
        
        var arr = [PatientForBegeleider]()
        var arr2 = [PatientForBegeleider]()

        for p in patientsNeedAttention{
            if p.needsAttention{
                arr.append(p)
            }else{
                arr2.append(p)
            }
        }

        patientsNeedAttention = arr.sorted(by: {$0.patient.firstName < $1.patient.firstName})
        patientsNeedAttention += arr2.sorted(by: {$0.patient.firstName < $1.patient.firstName})
        
        self.patientsTableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    private func getPatientIntakes(patient: Patient, withCompletionHandler cH : @escaping ([Intake]) -> ()){
        var mondaysDate: Date {
            return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        }
         
        let calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startdayofWeek = dateFormatter.string(from: mondaysDate)
        let enddayofweek = dateFormatter.string(from: calendar.date(byAdding: .day, value: 6, to: mondaysDate)!)
        
        ApiService.getIntakesCountAll(greaterthandate: startdayofWeek, lowerthandate: enddayofweek, patientId: patient.id)
            .responseData(completionHandler: { (response) in
                guard let jsonData = response.data else { return }
//                    print(String(decoding: response.data!, as: UTF8.self))
                
                switch(response.result) {
                case .success(_):
                    self.dateFormatter.locale = Locale.current
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
                    guard let json = try? self.decoder.decode([Intake].self, from: jsonData) else { return }
                    cH(json)
                    
                case .failure(_):
                    print("EROOR MESSAGr\(response.result.error)")
                }
            })
    }
    
    // Deze func bepaalt welke patient meer aandacht nodig heeft
    // value is nu hardcoded gezet op meer dan 5 keer in huidige week niet op tijd met med inname
    private func patientNeedsMoreAttention(intakes: [Intake], withCompletionHandler cH : @escaping (Bool) -> ()){
        var count = Int()
        print("AMOUNt INTAKES: \(intakes.count)")
        for i in intakes{
            if i.state != "0" {
                count += 1
            }
        }
        
        if count > 5 {
            cH(true)
        }else{
            cH(false)
        }
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
    
    
}

extension PatientsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return patientsNeedAttention.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PatientTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PatientTableViewCell else {
            fatalError("The dequeued cell is not an instance of PatientTableViewCell")
        }
        
        let patient = patientsNeedAttention[indexPath.row]
        if let insertion = patient.patient.insertion {
            cell.patientNameLabel.text = "\(patient.patient.firstName) \(insertion) \(patient.patient.lastName)"
        } else {
            cell.patientNameLabel.text = "\(patient.patient.firstName) \(patient.patient.lastName)"
        }
        
        cell.badgeImageView.isHidden = !patientsNeedAttention[indexPath.row].needsAttention
        
        return cell
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientVc = storyboard.instantiateViewController(withIdentifier:
            "PatientViewController") as! PatientViewController
        patientVc.patient = patientsNeedAttention[indexPath.row].patient
        navigationController?.pushViewController(patientVc, animated: true)
    }
}

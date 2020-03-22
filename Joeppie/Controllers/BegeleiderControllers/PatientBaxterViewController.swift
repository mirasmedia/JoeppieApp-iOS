//
//  PatientViewController.swift
//  Joeppie
//
//  Created by Ercan kalan on 08/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class PatientBaxterViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    
    var patient:Patient?
    var baxterlist: [Baxter] = []
    var medicinelist: [Medicine] = []
    var popup:UIView!
    var alertvc:AlertViewController!
    let notificationCenter = UNUserNotificationCenter.current()
    var indicator:UIActivityIndicatorView? = nil
    var checkinTested = false;
    
    
    @IBOutlet weak var tapBarItem_home: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
           
        setup()
    }
    
    private func setup(){
        setIndicator()
        
        self.tableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0);
        tableview.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        let nib = UINib(nibName: "MedicineCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "MedicineCell")
        tableview.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        tableview.allowsSelection = false
 
        getMedicines()
    }
    
    
    @objc func applicationWillEnterForeground(notification: Notification) {
        getBaxters()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBaxters()
    }
    
    // TODO : make all func private
    
    func setIndicator(){
        indicator = UIActivityIndicatorView()
        indicator!.style = UIActivityIndicatorView.Style.large
        indicator!.center = self.view.center
        indicator!.color = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
        self.view.addSubview(indicator!)
        indicator!.startAnimating()
        indicator!.backgroundColor = UIColor.white
        indicator?.startAnimating()
    }
    


    func getBaxters(){
        
        ApiService.getAllBaxtersPatient(patientId: self.patient!.id)
            .responseData(completionHandler: { [weak self] (response) in
                guard let jsonData = response.data else { return }
                //                print(jsonData)
                
                if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    //                    print(String(decoding: jsonData, as: UTF8.self))
                } else {
                    print("json data malformed")
                }
                
                let decoder = JSONDecoder()
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let rs = try? decoder.decode([Baxter].self, from: response.data!)
                self!.baxterlist = rs!.sorted(by: {$0.dayOfWeek < $1.dayOfWeek})
                self!.handleBaxters()
                self!.tableview.dataSource = self
                self!.tableview.delegate = self
                self!.tableview.reloadData()
                
                guard response.error == nil else {
                    print("error")
                    
                    if response.response?.statusCode == 409 {
                        print("error")
                    }
                    return
                    
                }
            })
    }
    
    func handleBaxters(){

        for indexbaxter in stride(from: baxterlist.count-1, to: -1, by: -1){
            if(self.baxterlist[indexbaxter].doses?.count==0){
                ApiService.deleteBaxter(baxter: baxterlist[indexbaxter])
                .responseData(completionHandler: { [weak self] (response) in
                })
                self.baxterlist.remove(at: indexbaxter)

    
            }
        }
        

        self.tableview.reloadData()
        
    }
    
    func getMedicines(){
        ApiService.getMedicines()
            .responseData(completionHandler: { [weak self] (response) in
                let jsonData = response.data
                
                
                if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    //                    print(String(decoding: jsonData, as: UTF8.self))
                } else {
                    print("json data malformed")
                }
                
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let rs = try! decoder.decode([Medicine].self, from: response.data!)
                self!.medicinelist = rs
                
                guard response.error == nil else {
                    print("error")
                    
                    if response.response?.statusCode == 409 {
                        print("error")
                    }
                    return
                    
                }
            })
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indicator?.stopAnimating()
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell",for: indexPath) as!  MedicineCell
        let b = medicinelist.firstIndex(where: { $0.id == baxterlist[indexPath.section].doses![indexPath.row].medicine})
        
        if medicinelist.count<=1{
            getMedicines()
            tableview.reloadData()
        }
        let index:Int = medicinelist.firstIndex(where: { $0.id == baxterlist[indexPath.section].doses![indexPath.row].medicine })!
        
        
        cell.amount.text = "x " + String(baxterlist[indexPath.section].doses![indexPath.row].amount)
        cell.amount.textColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
        cell.amount.font = UIFont.systemFont(ofSize: 23)
        
        cell.textMedicine.text = medicinelist[index].name
        cell.textMedicine.textColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
        cell.textMedicine.font = UIFont.systemFont(ofSize: 23)
        
        cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        cell.medicine_intake_image.image = UIImage(named:"medicine_intake_icon")
        return cell
        
    }
    
    func deleteDose(dose:NestedDose){
        ApiService.deleteDose(id: String(dose.id))
        .responseData(completionHandler: { [weak self] (response) in
        })
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          let ingenomen = UIContextualAction(style: .destructive, title: "Verwijderen") { (action, sourceView, completionHandler) in
              let alert = UIAlertController(title: NSLocalizedString("are_you_sure", comment: ""), message: "Weet u zeker dat u dit wilt verwijderen?", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { action in
                self.deleteDose(dose: self.baxterlist[indexPath.section].doses![indexPath.row])
                self.baxterlist[indexPath.section].doses?.remove(at: indexPath.row)
                self.handleBaxters()
                  
              }))

              alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
              self.present(alert, animated: true)
              
          }
          ingenomen.backgroundColor =  UIColor(red:0.96, green:0.74, blue:0.12, alpha:1.0)
          let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
          swipeAction.performsFirstActionWithFullSwipe = false

          return swipeAction
    }
    
    

}

extension PatientBaxterViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        let label = UILabel(frame: CGRect(x: 0, y: 8, width: tableView.bounds.size.width, height: 21))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        
        let calendar = Calendar.current
        
        let dateTime:Date =  baxterlist[section].intakeTime
        let hour = calendar.component(.hour, from: dateTime)
        let minutes = calendar.component(.minute, from: dateTime)
        
        let time:String = String.init(format: "%02d:%02d", hour, minutes)
        label.text = baxterlist[section].dayOfWeek.capitalizingFirstLetter()+" "+time + " "+NSLocalizedString("hour", comment: "")
        label.textColor = .white
        headerView.addSubview(label)
        headerView.backgroundColor = UIColor(red:0.95, green:0.55, blue:0.13, alpha:1.0)
        return headerView
        
    }
    
    
}



extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}


extension PatientBaxterViewController:UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var amount:Int = 0
        for baxter in baxterlist{
            if baxter.doses!.count>0{
                amount = amount + 1
            }
        }
        if amount == 0{
            indicator?.stopAnimating()
        }
        
        return amount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.baxterlist[section].doses!.count
    }
    
}

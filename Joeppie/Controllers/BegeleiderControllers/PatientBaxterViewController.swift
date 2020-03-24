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

enum Weekday: Int {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday
}

class PatientBaxterViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    
    var patient:Patient?
    var baxterlist: [Baxter] = []
    var medicinelist: [Medicine] = []
    var popup:UIView!
    var alertvc:AlertViewController!
    var indicator:UIActivityIndicatorView? = nil
    var checkinTested = false
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var tapBarItem_home: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setIndicator()
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
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
    


    private func getBaxters(){
        ApiService.getAllBaxtersPatient(patientId: self.patient!.id)
            .responseData(completionHandler: { (response) in
                guard let jsonData = response.data else { return }
                
                let rs = try? self.decoder.decode([Baxter].self, from: response.data!)
                self.baxterlist = rs!.reordered()
                
                self.handleBaxters()
                self.tableview.dataSource = self
                self.tableview.delegate = self
                self.tableview.reloadData()
                
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
        var equipments = [[Int:Baxter]]()
        for indexbaxter in stride(from: baxterlist.count-1, to: -1, by: -1){
            
            if(self.baxterlist[indexbaxter].doses?.count==0){
                ApiService.deleteBaxter(baxter: baxterlist[indexbaxter])
                self.baxterlist.remove(at: indexbaxter)
            }
            
        }

        self.tableview.reloadData()
        
    }
    
    func getMedicines(){
        ApiService.getMedicines()
            .responseData(completionHandler: { (response) in
                guard let jsonData = response.data else { return }
                let rs = try? self.decoder.decode([Medicine].self, from: jsonData)
                if let list = rs{
                    self.medicinelist = list
                }
                
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
        
        
        let index:Int = medicinelist.firstIndex(where: { $0.id == baxterlist[indexPath.section].doses![indexPath.row].medicine })!
        
        
        cell.amount.text = "x " + String(baxterlist[indexPath.section].doses![indexPath.row].amount)
        cell.amount.textColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
        cell.amount.font = UIFont.systemFont(ofSize: 23)
        
        cell.textMedicine.text = medicinelist[index].name
        cell.textMedicine.textColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
        cell.textMedicine.font = UIFont.systemFont(ofSize: 23)
        
        cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        switch self.medicinelist[index].type{
            case "tablet":
                cell.medicine_intake_image.image = UIImage(named:"medicine_intake_icon")
            case "Druppel":
                cell.medicine_intake_image.image = UIImage(named:"Drop_medicine")
            case "Capsule":
                cell.medicine_intake_image.image = UIImage(named:"capsule")
            default:
                cell.medicine_intake_image.image = UIImage(named:"medicine_intake_icon")
            }
        
        return cell
        
    }
    
    func deleteDose(dose:NestedDose){
        ApiService.deleteDose(id: String(dose.id))
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          let ingenomen = UIContextualAction(style: .destructive, title: NSLocalizedString("verwijderen", comment: "")) { (action, sourceView, completionHandler) in
              let alert = UIAlertController(title: NSLocalizedString("are_you_sure", comment: ""), message: NSLocalizedString("are_you_sure_to_delete_it", comment: ""), preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { action in
                self.deleteDose(dose: self.baxterlist[indexPath.section].doses![indexPath.row])
                self.baxterlist[indexPath.section].doses?.remove(at: indexPath.row)
                self.handleBaxters()
                var imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
                imageView.image = UIImage(named: "vinkje")
                
                let alert = UIAlertController(title: "", message: NSLocalizedString("verwijderd", comment: ""), preferredStyle: .alert)
                alert.view.addSubview(imageView)
                self.present(alert, animated: true, completion: nil)

                // change to desired number of seconds (in this case 5 seconds)
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when){
                  // your code with delay
                  alert.dismiss(animated: true, completion: nil)
                }
                  
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
       
        let df = DateFormatter()
        df.dateFormat = "HH : mm"
        
        let day = baxterlist[section].dayOfWeek.capitalizingFirstLetter()
        let time = df.string(from: baxterlist[section].intakeTime)
        let time:String = String.init(format: "%02d:%02d", hour, minutes)
        
        var day:String = ""
        switch baxterlist[section].dayOfWeek.capitalizingFirstLetter() {
        case "Monday":
            day = NSLocalizedString("Monday", comment: "")
        case "Tuesday":
            day = NSLocalizedString("Tuesday", comment: "")
        case "Wednesday":
            day = NSLocalizedString("Wednesday", comment: "")
        case "Thursday":
            day = NSLocalizedString("Thursday", comment: "")
        case "Friday":
            day = NSLocalizedString("Friday", comment: "")
        case "Saturday":
            day = NSLocalizedString("Saturday", comment: "")
        case "Sunday":
            day = NSLocalizedString("Sunday", comment: "")
        
        default:
            ""
        }
        
        label.text = "\(day) \(time) \(NSLocalizedString("hour", comment: ""))"
            
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

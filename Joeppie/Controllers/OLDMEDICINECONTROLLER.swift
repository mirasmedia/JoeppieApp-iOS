////
////  PatientViewController.swift
////  Joeppie
////
////  Created by Ercan kalan on 08/12/2019.
////  Copyright © 2019 Bever-Apps. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class OLDMEDICINECONTROLLER: UIViewController {
//    @IBOutlet weak var tableview: UITableView!
//    var baxterlist = [Baxter]()
//    var popup:UIView!
//    var alertvc:AlertViewController!
//    
//    @IBOutlet weak var tapBarItem_home: UITabBarItem!
//    override func viewDidLoad() {
//        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
//        
//        let nib = UINib(nibName: "MedicineCell", bundle: nil)
//        tableview.register(nib, forCellReuseIdentifier: "MedicineCell")
//        tableview.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
//        tableview.allowsSelection = false;
//        
//        
//        getBaxters()
//        checkMedicineList()
//        setNavigation()
//    }
//    
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.tableview.reloadData()
//        setNavigation()
//    }
//    
//    func setNavigation(){
//        self.parent?.navigationController?.navigationBar.barTintColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
//            let labelName = UILabel()
//            labelName.textColor = UIColor.white
//            labelName.font = UIFont.systemFont(ofSize: 20)
//            labelName.text = "Hallo Sabine"
//            self.parent!.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: labelName)
//             
//            
//            let logOutButton = UIBarButtonItem(title: "Uitloggen", style: .plain, target: self, action: #selector(uitloggen))
//            logOutButton.tintColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
//            self.parent!.navigationItem.rightBarButtonItems = [logOutButton]
//    }
//    
//    @objc func uitloggen(){
//        self.navigationController?.popToRootViewController(animated: false)
//    }
//    
//    
//    func checkMedicineList(){
//        let now = Date()
//        let dateFormatter : DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        for medicine in baxterlist{
//            let calendar = Calendar.current
//            let dateFormatter : DateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            //TODO: fix intake time
//            let timeMedicine = Date() //medicine.intakeTime
//            _ = calendar.date(byAdding: .minute, value: -30, to: timeMedicine)!
//            let endTime = calendar.date(byAdding: .minute, value: 30, to: timeMedicine)!
//            _ = dateFormatter.string(from: endTime)
//            if(endTime < now){
//                let indexrm = baxterlist.firstIndex(where: {$0.id == medicine.id})!
//                baxterlist.remove(at: indexrm)
//            }
//    
//        }
//            
//    }
//    
//
//    
//    
//    func getBaxters(){
//        //TODO: fix getmedicine
//        //self.medicinelist = ApiService.getMedicine()
//        
//            ApiService.getBaxterClient(dayOfWeek: "monday", patientId: "2")
//            .responseData(completionHandler: { [weak self] (response) in
//            guard let jsonData = response.data else { return }
//            print(jsonData)
//
//                if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
//                print(String(decoding: jsonData, as: UTF8.self))
//            } else {
//                print("json data malformed")
//            }
//            
//            let decoder = JSONDecoder()
//                let rs = try? decoder.decode([Baxter].self, from: response.data!)
//                self!.baxterlist = rs!
//
//            guard response.error == nil else {
//                print("error")
//
//                if response.response?.statusCode == 409 {
//                    print("error")
//                }
//                return
//                
//            }
//            })
//    }
//    
//    func showAlertEarly(medicine:Baxter) {
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    alertvc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
//        // Add the child's View as a subview
//    alertvc.modalPresentationStyle = .fullScreen
//    self.present(alertvc, animated: true, completion: nil)
//
//        alertvc.timeNextMedicine.text = ""
//        alertvc.titleNextMedicine.text = ""
//
//        alertvc.view.frame = view.bounds
//        alertvc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        alertvc.titleAlertView.text = "Komt er aan..."
//        alertvc.nameAlertView.text = "Sabine"
//        alertvc.stateAlertView.text = "Nog even wachten!"
//        alertvc.imageAlertView.image = UIImage(named:"Joeppie_surprised")
//        
//
//      // set the timer
//        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
//    }
//    
//    func showAlertOntime(medicine:Baxter) {
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    alertvc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
//        // Add the child's View as a subview
//    alertvc.modalPresentationStyle = .fullScreen
//    self.present(alertvc, animated: true, completion: nil)
//        //TODO: fix intake time
//        if let medicineNext = baxterlist.first(where: { _ in /*$0.intakeTime*/ Date() > Date() /*medicine.intakeTime*/})
//    {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        //TODO: fix intake time
//        let timeString = formatter.string(from: Date() /*medicineNext.intakeTime as Date*/)
//        alertvc.timeNextMedicine.text = String(timeString)+" uur"
//        alertvc.titleNextMedicine.text = "Volgende medicijn om"
//    }
//    else{
//        alertvc.timeNextMedicine.text=""
//        alertvc.titleNextMedicine.text = ""
//        }
//    
//        alertvc.view.frame = view.bounds
//        alertvc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        alertvc.titleAlertView.text = "Goed zo!"
//        alertvc.nameAlertView.text = "Sabine"
//        alertvc.stateAlertView.text = "Je was op tijd!"
//        alertvc.imageAlertView.image = UIImage(named:"Joeppie_happy_icon")
//
//      // set the timer
//        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
//    }
//
//    @objc func dismissAlert(){
//      // Dismiss the view from here
//        alertvc.disMissAlert()
//    }
//
//    
//}
//
////extension MedicineViewController:UITableViewDelegate{
////
////    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        //dit is om door te sturen
////    }
////}
//
//////extension MedicineViewController:UITableViewDataSource{
//// //   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//// //       return baxterlist.count
//// //   }
////
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        var formatter = DateFormatter()
////        formatter.dateFormat = "HH:mm"
////
////        //TODO: fix intake time
////        let timeString = "needs fix" //formatter.string(from: medicinelist[indexPath.row].intakeTime as Date)
////
////        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell",for: indexPath) as!  MedicineCell
////        cell.textMedicine.text = "Pakket "+String(baxterlist[indexPath.row].id)
////        cell.timeMedicine.text = String(timeString)+" uur"
////        cell.timeMedicine.textColor = .white
////        cell.timeMedicine.font = UIFont.systemFont(ofSize: 23)
////
////        cell.textMedicine.textColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
////        cell.textMedicine.font = UIFont.systemFont(ofSize: 23)
////        cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
////        cell.medicine_intake_image.image = UIImage(named:"medicine_intake_icon")
////        return cell
////    }
////
//
//    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let calendar = Calendar.current
//        let dateFormatter : DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        //TODO: fix intake time
//        let timeMedicine = Date() //medicinelist[indexPath.row].intakeTime
//        let startTime = calendar.date(byAdding: .minute, value: -30, to: timeMedicine)!
//        let endTime = calendar.date(byAdding: .minute, value: 30, to: timeMedicine)!
//        let timeprint = dateFormatter.string(from: endTime)
//        print(timeprint)
//        
//        
//        let now = Date()
//        let StartTime = calendar.date(
//            bySettingHour: calendar.component(.hour, from: startTime),
//          minute: calendar.component(.minute, from: startTime),
//          second:0,
//          of: startTime)!
//
//        let EndTime = calendar.date(
//          bySettingHour: calendar.component(.hour, from: endTime),
//              minute: calendar.component(.minute, from: endTime),
//          second: 0,
//          of: endTime)!
//
//
//        if now >= StartTime &&
//          now <= EndTime
//        {
//          print("The time is between the range")
//          let ingenomen = UIContextualAction(style: .destructive, title: "Medicatie ingenomen") { (action, sourceView, completionHandler) in
////              self.showAlertOntime(medicine: self.baxterlist[indexPath.row])
////              self.baxterlist.remove(at: indexPath.row)
////              self.tableview.reloadData()
//              
//          }
//          ingenomen.backgroundColor = UIColor(red:0.36, green:0.87, blue:0.55, alpha:1.0)
//          let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
//          swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
//          return swipeAction
//            
//        }
//        else if(now>EndTime){
//            let ingenomen = UIContextualAction(style: .destructive, title: "Je bent te laat!") { (action, sourceView, completionHandler) in
//                   
//               }
//               ingenomen.backgroundColor = UIColor(red:0.36, green:0.87, blue:0.55, alpha:1.0)
//               let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
//               swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
//               print(endTime)
//               return swipeAction
//            
//        }
//        else{
//        let ingenomen = UIContextualAction(style: .destructive, title: "Je bent te vroeg!") { (action, sourceView, completionHandler) in
////            self.showAlertEarly(medicine: self.baxterlist[indexPath.row])
////            self.tableview.reloadData()
//              }
//              ingenomen.backgroundColor = UIColor(red:0.36, green:0.87, blue:0.55, alpha:1.0)
//              let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
//              swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
//              return swipeAction
//        }
//        
//    }
//
//

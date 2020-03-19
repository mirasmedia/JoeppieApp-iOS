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




class MedicineViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var backgroundLabelJoeppie: UILabel!
    @IBOutlet weak var backgroundJoeppie: UIImageView!
    
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

        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
        self.tableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0);
        tableview.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        let nib = UINib(nibName: "MedicineCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "MedicineCell")
        tableview.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        tableview.allowsSelection = false
        
        setNavigation()
        getMedicines()
        setBackground()
        
        let myTimer = Timer(timeInterval: 60.0, target: self, selector:#selector(self.refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
    }
    
    
    @objc func applicationWillEnterForeground(notification: Notification) {
        getBaxters()
        setNavigation()
    }
    
    func setBackground(){
        backgroundLabelJoeppie.text = NSLocalizedString("today_we_finish", comment: "")
        backgroundJoeppie.image = UIImage(named: "Joeppie_happy_icon")
    }
    
    func setPushNotifications(){
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        let dt = Date()
        let dateformatter = DateFormatter()
        dateformatter.timeZone = .current
        dateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateformatter.dateFormat = "EEEE"
        
        
        let calendar = Calendar.current
        let nextDay = calendar.date(byAdding: .day, value: 1, to: dt)!
        let nextdayString = dateformatter.string(from: nextDay)
        //        print(nextDay)
        
        
        let date = Date()
        for indexbaxter in stride(from: baxterlist.count-1, to: -1, by: -1){
            if baxterlist[indexbaxter].doses!.count>0{
                let content = UNMutableNotificationContent()
                content.title =  NSLocalizedString("time_medicine_text", comment: "")+(patient?.firstName ?? "")
                content.body = NSLocalizedString("take_medicine", comment: "")
                content.sound = UNNotificationSound.default
                
                
                let dateBaxter = baxterlist[indexbaxter].intakeTime
                
                let calendar = Calendar.current
                var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())
                
                dateComponents?.day = calendar.component(.day, from: date)
                dateComponents?.month = calendar.component(.month, from: date)
                dateComponents?.year = calendar.component(.year, from: date)
                dateComponents?.hour = calendar.component(.hour, from: dateBaxter)
                dateComponents?.minute = calendar.component(.minute, from: dateBaxter)
                dateComponents?.second = calendar.component(.second, from: dateBaxter)
                dateComponents?.nanosecond = calendar.component(.nanosecond, from: dateBaxter)
                
                var requestDate = calendar.date(from: dateComponents!)!
                
                let datecomponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: requestDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: datecomponents, repeats: false)
                
                
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                notificationCenter.add(request) { (error) in
                    //errorhandling
                }
                
            }
            
        }
        
        // TODO : hardcoded id ?!?!? add connection checker, move additional func to an helper
        var baxters:[Baxter]?
        
        //Copy this bit to wherever you need the user
        var id = Int()
        UserService.getPatientInstance(withCompletionHandler: { patient in
            if let temp = patient{
                id = temp.id
            }
        })
        ApiService.getBaxterClient(dayOfWeek: nextdayString, patientId: id)
            .responseData(completionHandler: { [weak self] (response) in
                guard let jsonData = response.data else { return }
                //                print(jsonData)
                
                if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    //                    print(String(decoding: jsonData, as: UTF8.self))
                } else {
                    //                    print("json data malformed")
                }
                
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let rs = try! decoder.decode([Baxter].self, from: response.data!)
                baxters = rs
                
                for indexbaxter in stride(from: baxters!.count-1, to: -1, by: -1){
                    
                    let content = UNMutableNotificationContent()
                    content.title = NSLocalizedString("time_medicine_text", comment: "")+(self!.patient?.firstName ?? "")
                    content.body = NSLocalizedString("take_medicine", comment: "")
                    content.sound = UNNotificationSound.default
                    
                    
                    let dateBaxter = baxters![indexbaxter].intakeTime
                    
                    let calendar = Calendar.current
                    var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())
                    
                    dateComponents?.day = calendar.component(.day, from: nextDay)
                    dateComponents?.month = calendar.component(.month, from: nextDay)
                    dateComponents?.year = calendar.component(.year, from: nextDay)
                    dateComponents?.hour = calendar.component(.hour, from: dateBaxter)
                    dateComponents?.minute = calendar.component(.minute, from: dateBaxter)
                    dateComponents?.second = calendar.component(.second, from: dateBaxter)
                    dateComponents?.nanosecond = calendar.component(.nanosecond, from: dateBaxter)
                    
                    var requestDate = calendar.date(from: dateComponents!)!
                    
                    let datecomponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: requestDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: datecomponents, repeats: false)
                    
                    
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                    self!.notificationCenter.add(request) { (error) in
                        //errorhandling
                    }
                    
                }
            })
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBaxters()
        setNavigation()
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
    
    func setNavigation(){
        let labelName = UILabel()
        UserService.getPatientInstance(withCompletionHandler: { patient in
            guard let patient = patient else {
                self.uitloggen()
                return
            }
            labelName.textColor = UIColor.white
            labelName.font = UIFont.systemFont(ofSize: 20)
            labelName.text = NSLocalizedString("greetting", comment: "") + patient.firstName
            self.patient = patient
            
            self.parent?.navigationController?.navigationBar.barTintColor = UIColor(red:0.38, green:0.33, blue:0.46, alpha:1.0)
            self.parent!.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: labelName)
            
            
            let logOutButton = UIBarButtonItem(title: NSLocalizedString("logout", comment: ""), style: .plain, target: self, action: #selector(self.uitloggen))
            logOutButton.tintColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
            self.parent!.navigationItem.rightBarButtonItems = [logOutButton]
        })
        
    }
    
    @objc func uitloggen(){
        UserService.logOut()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    func handleBaxters(){
        
        let now = Date()
        let calendar = Calendar.current
        
        
        for indexbaxter in stride(from: baxterlist.count-1, to: -1, by: -1){
            let baxterTime:Date = baxterlist[indexbaxter].intakeTime
            let lastTakeMoment = calendar.date(byAdding: .minute, value: +45, to: baxterTime)!
            
            var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())
            
            dateComponents?.day = calendar.component(.day, from: now)
            dateComponents?.month = calendar.component(.month, from: now)
            dateComponents?.year = calendar.component(.year, from: now)
            dateComponents?.hour = calendar.component(.hour, from: lastTakeMoment)
            dateComponents?.minute = calendar.component(.minute, from: lastTakeMoment)
            dateComponents?.second = calendar.component(.second, from: lastTakeMoment)
            dateComponents?.nanosecond = calendar.component(.nanosecond, from: lastTakeMoment)
            
            var intakeTime = calendar.date(from: dateComponents!)!
            
            if(intakeTime<now){
                baxterlist.remove(at: indexbaxter)
                
            }
            
        }
        
        var anyDose=false
        //-1 because count returns 1
        for indexbaxter in stride(from: baxterlist.count-1, to: -1, by: -1){
            for indexdose in stride(from: baxterlist[indexbaxter].doses!.count-1, to: -1, by: -1){
                let lastTakenTime = baxterlist[indexbaxter].doses![indexdose].lastTaken
                if(calendar.isDate(now, equalTo: lastTakenTime, toGranularity:.day) && calendar.isDate(now, equalTo: lastTakenTime, toGranularity:.month)&&calendar.isDate(now, equalTo: lastTakenTime, toGranularity:.year))
                {
                    
                    //                    print(baxterlist[indexbaxter].doses?.count)
                    if(baxterlist[indexbaxter].doses?.count==1)
                    {
                        // if dose is nil remove baxter. always return 1
                        self.baxterlist.remove(at: indexbaxter)
                        //                        print("remove baxter")
                    }
                    else{
                        self.baxterlist[indexbaxter].doses?.remove(at: indexdose)
                    }
                    //                    print("Already taken")
                    
                }
                else{
                    //                    print("Not taken")
                    anyDose = true
                    
                }
                
            }
            
            
        }
        
        if(anyDose){
            tableview.isHidden = false
        }
        else{
            tableview.isHidden = true
        }
        
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.reloadData()
        setPushNotifications()
        
    }
    
    @objc func refresh() {
        setIntake()
        tableview.reloadData()
    }
    
    func setIntake(){
        let now = Date()
        let calendar = Calendar.current
        
        
        for indexbaxter in stride(from: baxterlist.count-1, to: -1, by: -1){
            let baxterTime:Date = baxterlist[indexbaxter].intakeTime
            let lastTakeMoment = calendar.date(byAdding: .minute, value: +45, to: baxterTime)!
            
            var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())
            
            dateComponents?.day = calendar.component(.day, from: now)
            dateComponents?.month = calendar.component(.month, from: now)
            dateComponents?.year = calendar.component(.year, from: now)
            dateComponents?.hour = calendar.component(.hour, from: lastTakeMoment)
            dateComponents?.minute = calendar.component(.minute, from: lastTakeMoment)
            dateComponents?.second = calendar.component(.second, from: lastTakeMoment)
            dateComponents?.nanosecond = calendar.component(.nanosecond, from: lastTakeMoment)
            var intakeTime = calendar.date(from: dateComponents!)!
            
            if(intakeTime<now){
                let dateFormatter : DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                let dateString = dateFormatter.string(from: now)
                for indexdose in stride(from: baxterlist[indexbaxter].doses!.count-1, to: -1, by: -1){
                    let lastTakenTimeChanged:Date = baxterlist[indexbaxter].doses![indexdose].lastTaken
                    
                    
                    let b = calendar.isDate(now, equalTo: lastTakenTimeChanged, toGranularity:.day)
                    print(b)
                    if(!calendar.isDate(now, equalTo: lastTakenTimeChanged, toGranularity:.day) && calendar.isDate(now, equalTo: lastTakenTimeChanged, toGranularity:.month)&&calendar.isDate(now, equalTo: lastTakenTimeChanged, toGranularity:.year)){
                        setIntake(dose: (baxterlist[indexbaxter].doses?[indexdose])! , patient: self.patient!, timeNow: dateString, state: String(DoseTakenTime.NOT_TAKEN.rawValue))
                        print(baxterlist[indexbaxter].doses![indexdose].lastTaken)
                        print(baxterlist[indexbaxter].intakeTime)
                        self.updateDose(id: String(self.baxterlist[indexbaxter].doses![indexdose].id), lasttaken: dateString)
                        baxterlist[indexbaxter].doses![indexdose].lastTaken = now
                    }
                    
                }
                
            }
            
        }
    }
    
    func backgroundUpdate(){
        UserService.getPatientInstance(withCompletionHandler: { patient in
            guard let patient = patient else {
                self.uitloggen()
                return
            }
            self.getBaxters()
        })
        
    }
    
    
    func getBaxters(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: date)

        //Copy this bit to wherever you need the user
        UserService.getPatientInstance(withCompletionHandler: { patient in
            guard let patient = patient else {
                UserService.logOut()
                return
            }
        
        print("TEESSSSTT: \(dayInWeek) \(patient.id)")
        
            ApiService.getBaxterClient(dayOfWeek: dayInWeek, patientId: patient.id)
            .responseData(completionHandler: { [weak self] (response) in
                guard let jsonData = response.data else { return }
                //                print(jsonData)
                
                if let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers),
                    let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    //                    print(String(decoding: jsonData, as: UTF8.self))
                } else {
                    print("json data malformed")
                }
                
                let decoder = JSONDecoder()
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let rs = try? decoder.decode([Baxter].self, from: jsonData)
                self!.baxterlist = rs!
                self!.setIntake()
                self!.handleBaxters()
                
                guard response.error == nil else {
                    print("error")
                    
                    if response.response?.statusCode == 409 {
                        print("error")
                    }
                    return
                    
                }
            })
        })
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let calendar = Calendar.current
        
        let dateTime:Date = baxterlist[section].intakeTime
        let hour = calendar.component(.hour, from: dateTime)
        let minutes = calendar.component(.minute, from: dateTime)
        
        print(String(hour) + ":" + String(minutes))
        
        let curTime:String = String.init(format: "%02d:%02d", hour, minutes)
        
        
        return curTime + " uur"
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indicator?.stopAnimating()
        print("row" + String(indexPath.row))
        print ("sec" + String(indexPath.section))
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
    
    func updateDose(id:String, lasttaken:String){
        ApiService.updateDose(id: id, lastTaken: lasttaken)
            .responseData(completionHandler: { [weak self] (response) in
                //                print(response)
            })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    //TODO: move this to an helper - MOVE
    func showAlertOntime(indexpath:IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        alertvc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        
        // Add the child's View as a subview
        alertvc.modalPresentationStyle = .fullScreen
        self.present(alertvc, animated: true, completion: nil)
        
        alertvc.imageAlertView.image = UIImage(named:"Joeppie_happy_icon")
        alertvc.titleAlertView.text = NSLocalizedString("goed_zo", comment: "")
        if baxterlist[indexpath.section].doses!.count > 1
        {
            alertvc.timeNextMedicine.text = NSLocalizedString("take_now", comment: "")
            alertvc.titleNextMedicine.text = NSLocalizedString("take_next_medicine", comment: "")
        }
        else if (baxterlist.indices.contains(indexpath.section+1)){
            let calendar = Calendar.current
            
            print(indexpath.section)
            let dateTime:Date =  baxterlist[indexpath.section+1].intakeTime
            let hour = calendar.component(.hour, from: dateTime)
            let minutes = calendar.component(.minute, from: dateTime)
            
            let time:String = String.init(format: "%02d:%02d", hour, minutes)
            alertvc.timeNextMedicine.text = NSLocalizedString("till", comment: "") + " "+time+" "+NSLocalizedString("hour", comment: "")
            alertvc.titleNextMedicine.text = NSLocalizedString("we_want_see_you_back", comment: "")
            alertvc.nameAlertView.text = self.patient?.firstName
            alertvc.stateAlertView.text = NSLocalizedString("was_on_time_text", comment: "")
        }
        else{
            alertvc.timeNextMedicine.text = NSLocalizedString("today_we_finish", comment: "")
            alertvc.titleNextMedicine.text = NSLocalizedString("we_want_see_you_back", comment: "")
            alertvc.view.frame = view.bounds
            alertvc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            alertvc.nameAlertView.text = self.patient?.firstName
            alertvc.stateAlertView.text = NSLocalizedString("was_on_time_text", comment: "")
        }
        
        // set the timer
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
        
    }
    
    func showAlertLate(indexpath:IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        alertvc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        
        // Add the child's View as a subview
        alertvc.modalPresentationStyle = .fullScreen
        self.present(alertvc, animated: true, completion: nil)
        alertvc.imageAlertView.image = UIImage(named:"Joeppie_surprised")
        alertvc.titleAlertView.text = "Kan beter!"
        alertvc.nameAlertView.text = patient?.firstName
        alertvc.stateAlertView.text = "Net niet op tijd!"
        if baxterlist[indexpath.section].doses!.count > 1
        {
            alertvc.timeNextMedicine.text = NSLocalizedString("take_now", comment: "")
            alertvc.titleNextMedicine.text = NSLocalizedString("get_next_medicine", comment: "")
        }
        else if (baxterlist.indices.contains(indexpath.section+1)){
            let calendar = Calendar.current
            let dateTime:Date = baxterlist[indexpath.section+1].intakeTime
            let hour = calendar.component(.hour, from: dateTime)
            let minutes = calendar.component(.minute, from: dateTime)
            
            let time:String = String.init(format: "%02d:%02d", hour, minutes)
            alertvc.timeNextMedicine.text = NSLocalizedString("till", comment: "")+" "+time + NSLocalizedString("hour", comment: "")
            alertvc.titleNextMedicine.text = NSLocalizedString("we_want_see_you_back", comment: "")
        }
        else{
            alertvc.timeNextMedicine.text = NSLocalizedString("today_we_finish", comment: "")
            alertvc.titleNextMedicine.text = NSLocalizedString("we_want_see_you_back", comment: "")
            alertvc.view.frame = view.bounds
            alertvc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    func showAlertEarly(indexpath:IndexPath){
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          alertvc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
          
          // Add the child's View as a subview
          alertvc.modalPresentationStyle = .fullScreen
          self.present(alertvc, animated: true, completion: nil)
          alertvc.imageAlertView.image = UIImage(named:"Joeppie_surprised")
          alertvc.titleAlertView.text = NSLocalizedString("can_better_text", comment: "")
          alertvc.nameAlertView.text = patient?.firstName
          alertvc.stateAlertView.text = NSLocalizedString("you_are_to_early", comment: "")
        
          alertvc.timeNextMedicine.text = NSLocalizedString("hope_next_time_better", comment: "")
          alertvc.titleNextMedicine.text = NSLocalizedString("thank_you", comment: "")
          Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
      }
    
    func setIntake(dose:NestedDose, patient:Patient, timeNow:String, state:String){
        ApiService.setIntake(dose:dose, patient: patient, timeNow: timeNow, state: state)
            .responseData(completionHandler: { [weak self] (response) in
                print(response)
            })
    }
    
    @objc func dismissAlert(){
        // Dismiss the view from here
        alertvc.disMissAlert()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let calendar = Calendar.current
        
        let timeNow = Date() //medicinelist[indexPath.row].intakeTime
        let lastTakenTime:Date = baxterlist[indexPath.section].doses![indexPath.row].lastTaken
        var intakeTime:Date = baxterlist[indexPath.section].intakeTime
        var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: Date())
        
        dateComponents?.day = calendar.component(.day, from: timeNow)
        dateComponents?.month = calendar.component(.month, from: timeNow)
        dateComponents?.year = calendar.component(.year, from: timeNow)
        dateComponents?.hour = calendar.component(.hour, from: intakeTime)
        dateComponents?.minute = calendar.component(.minute, from: intakeTime)
        dateComponents?.second = calendar.component(.second, from: intakeTime)
        dateComponents?.nanosecond = calendar.component(.nanosecond, from: intakeTime)
        
        intakeTime = calendar.date(from: dateComponents!)!
        
        
        let maxStartTime = calendar.date(byAdding: .minute, value: -15, to: intakeTime)!
        let maxEndTime = calendar.date(byAdding: .minute, value: 15, to: intakeTime)!
        let lateEndtime = calendar.date(byAdding: .minute, value: 45, to: intakeTime)!
        
        var date = Date()
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let formatedDate = dateFormatter.string(from: date)
        
        
        if timeNow >= maxStartTime && timeNow <= maxEndTime
        {
            print("The time is between the range")
            let ingenomen = UIContextualAction(style: .destructive, title: "Medicatie ingenomen") { (action, sourceView, completionHandler) in
                
      
                print(formatedDate)
                
                self.updateDose(id: String(self.baxterlist[indexPath.section].doses![indexPath.row].id), lasttaken: formatedDate)
                self.setIntake(dose: self.baxterlist[indexPath.section].doses![indexPath.row], patient: self.patient!, timeNow: formatedDate, state: String(DoseTakenTime.ON_TIME.rawValue))
                self.getBaxters()
                self.showAlertOntime(indexpath: indexPath)
                
            }
            ingenomen.backgroundColor = UIColor(red:0.36, green:0.87, blue:0.55, alpha:1.0)
            let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
            swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
            return swipeAction
            
        }
        else if(timeNow<maxStartTime){
            let ingenomen = UIContextualAction(style: .destructive, title: NSLocalizedString("you_are_to_early", comment: "")) { (action, sourceView, completionHandler) in
                let alert = UIAlertController(title: NSLocalizedString("are_you_sure", comment: ""), message: NSLocalizedString("you_take_medicine_to_early", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { action in
                    self.updateDose(id: String(self.baxterlist[indexPath.section].doses![indexPath.row].id), lasttaken: formatedDate)
                    self.setIntake(dose: self.baxterlist[indexPath.section].doses![indexPath.row], patient: self.patient!, timeNow: formatedDate, state: String(DoseTakenTime.EARLY.rawValue))
                    self.showAlertEarly(indexpath: indexPath)
                    self.getBaxters()
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
            }
            ingenomen.backgroundColor = UIColor(red:0.36, green:0.87, blue:0.55, alpha:1.0)
            let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
            swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
            print(maxEndTime)
            return swipeAction
            
        }
        else{
            let ingenomen = UIContextualAction(style: .destructive, title: NSLocalizedString("you_are_to_late", comment: "")) { (action, sourceView, completionHandler) in
                
                var date = Date()
                let dateFormatter : DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                let formatedDate = dateFormatter.string(from: date)
                
                self.updateDose(id: String(self.baxterlist[indexPath.section].doses![indexPath.row].id), lasttaken: formatedDate)
                self.setIntake(dose: self.baxterlist[indexPath.section].doses![indexPath.row], patient: self.patient!, timeNow: formatedDate, state: String(DoseTakenTime.LATE.rawValue))
                self.getBaxters()
                self.showAlertLate(indexpath: indexPath)
            }
            ingenomen.backgroundColor = UIColor(red:0.36, green:0.87, blue:0.55, alpha:1.0)
            let swipeAction = UISwipeActionsConfiguration(actions: [ingenomen])
            swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
            return swipeAction
        }
        
    }
    
    
}

extension MedicineViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        let label = UILabel(frame: CGRect(x: 0, y: 8, width: tableView.bounds.size.width, height: 21))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        
        let calendar = Calendar.current
        
        let dateTime:Date =  baxterlist[section].intakeTime
        let hour = calendar.component(.hour, from: dateTime)
        let minutes = calendar.component(.minute, from: dateTime)
        
        print(String(hour) + ":" + String(minutes))
        
        let time:String = String.init(format: "%02d:%02d", hour, minutes)
        
        label.text = time + " "+NSLocalizedString("hour", comment: "")
        label.textColor = .white
        headerView.addSubview(label)
        headerView.backgroundColor = UIColor(red:0.95, green:0.55, blue:0.13, alpha:1.0)
        return headerView
        
    }
}


extension MedicineViewController: UITableViewDataSource{
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

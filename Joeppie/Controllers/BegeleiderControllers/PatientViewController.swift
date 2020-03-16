//
//  PatientViewController.swift
//  Joeppie
//
//  Created by Shahin on 11/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit
import Charts

class PatientViewController: UIViewController {
    

    @IBOutlet weak var arrowImageBaxter: UIImageView!
    @IBOutlet weak var imageNoChartData: UIImageView!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var patientchartstableview: UITableView!
    @IBOutlet weak var labelNoChartData: UILabel!
    var patient: Patient?
    var chartsArray: [Charts] = []
    @IBOutlet weak var addMediButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(showEditPatientView))
        
        addMediButton.setTitle("Medicatie Toevoegen", for: .normal)
        patientName.text = patient!.firstName+" "+patient!.lastName
        arrowImageBaxter.image=UIImage(named: "arrow_right")
        let nib = UINib(nibName: "ChartViewCell", bundle: nil)
        patientchartstableview.register(nib, forCellReuseIdentifier: "ChartViewCell")
        patientchartstableview.allowsSelection = false;
        generateGeneralObject()
        getAllChartMedicineUser()
    }
    
    @IBAction func addMedicine(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addMedicineVc = storyboard.instantiateViewController(withIdentifier:
            "MedicineAddViewController") as? MedicineAddViewController else {
                fatalError("Unexpected destination:")
        }
        addMedicineVc.patient = patient
        self.navigationController?.pushViewController(addMedicineVc, animated: true)
    }
    
    @objc func showEditPatientView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let patientViewController = storyboard.instantiateViewController(withIdentifier:
            "PatientTableViewController") as? PatientTableViewController else {
                fatalError("Unexpected destination:")
        }
        patientViewController.patient = patient
//        self.navigationController?.pushViewController(patientViewController, animated: true)
        self.navigationController?.present(patientViewController, animated: true)
    }
    
    
        var mondaysDate: Date {
             return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
         }
    
       func getAllChartMedicineUser(){
           
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let startdayofWeek = df.string(from: mondaysDate)
           
       let calendar = Calendar.current
       var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: mondaysDate)
       let endofweek = calendar.date(byAdding: .day, value: 6, to: mondaysDate)!
      
       let enddayofweek = df.string(from: endofweek)
           
           
        ApiService.getIntakesCountAll(greaterthandate: startdayofWeek, lowerthandate: enddayofweek, patientId: patient!.id)
               .responseData(completionHandler: { [weak self] (response) in
                   
                   guard response.data != nil else { return }
//                   print(String(decoding: response.data!, as: UTF8.self))
                   
                   let decoder = JSONDecoder()
                   let dateFormatter = DateFormatter()
                   dateFormatter.locale = Locale.current
                   dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                   decoder.dateDecodingStrategy = .formatted(dateFormatter)
                   let rs = try! decoder.decode([Intake].self, from: response.data!)
                   self!.handleintake(rs: rs)
                   
               })
       
           
       }
    
    
    func handleintake(rs:[Intake]){
        
        for var item in rs {
            var check=true;
            for var indexchartobject in chartsArray.indices{
                if(chartsArray[indexchartobject].naam==item.medicine.name){
                    check=false;
                    if(item.state=="0"){
                        chartsArray[indexchartobject].optijd!+=1
                        chartsArray[0].optijd!+=1
                    }
                    else if(item.state=="1"){
                        chartsArray[indexchartobject].laat!+=1
                        chartsArray[0].laat!+=1
        
                    }
                    else if(item.state=="2"){
                        chartsArray[indexchartobject].nietIngenomen!+=1
                        chartsArray[0].nietIngenomen!+=1
                    }
                    else if(item.state=="3")
                    {
                        chartsArray[indexchartobject].vroeg!+=1
                        chartsArray[0].vroeg!+=1
                    }
                }
            }
            if(check){
                var cs=Charts()
                cs.naam=item.medicine.name
                if(item.state==String(DoseTakenTime.ON_TIME.rawValue)){
                    cs.optijd=1
                    chartsArray[0].optijd!+=1
                }
                else if(item.state==String(DoseTakenTime.LATE.rawValue)){
                    cs.laat=1
                    chartsArray[0].laat!+=1
                }
                else if(item.state==String(DoseTakenTime.NOT_TAKEN.rawValue)){
                    cs.nietIngenomen=1
                    chartsArray[0].nietIngenomen!+=1
                }
                else if(item.state==String(DoseTakenTime.EARLY.rawValue)){
                    cs.vroeg=1
                    chartsArray[0].vroeg!+=1
                }
                chartsArray.append(cs)
            }
        }
        if(chartsArray.count==1){
            self.patientchartstableview.isHidden=true
            self.imageNoChartData.image=UIImage(named: "Parrot")
            self.labelNoChartData.text = NSLocalizedString("there_is_no_data", comment: "")
        }
        else{
            self.patientchartstableview.dataSource = self
            self.patientchartstableview.reloadData()
        }
        
    }
    
    func generateGeneralObject(){
        self.chartsArray.append(Charts(naam:NSLocalizedString("chart_general", comment: ""),laat: 0, optijd: 0, vroeg: 0, nietIngenomen: 0))
    }
    
}

extension PatientViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartViewCell",for: indexPath) as!  ChartViewCell
        var nr = [PieChartDataEntry]()
        
        let opTijd = PieChartDataEntry(value:0)
        opTijd.label = NSLocalizedString("on_time_text", comment: "")
        opTijd.value = Double(chartsArray[indexPath.row].optijd!)
        let teLaat = PieChartDataEntry(value:0)
        teLaat.label = NSLocalizedString("to_late_text", comment: "")
        teLaat.value = Double(chartsArray[indexPath.row].laat!)
        let niet = PieChartDataEntry(value:0)
        niet.label = NSLocalizedString("not_text", comment: "")
        niet.value = Double(chartsArray[indexPath.row].nietIngenomen!)
        let vroeg = PieChartDataEntry(value:0)
        vroeg.label = NSLocalizedString("to_early_text", comment: "")
        vroeg.value = Double(chartsArray[indexPath.row].vroeg!)
        
        
        nr = [opTijd,teLaat,niet,vroeg]
        
        let chartDataSet = PieChartDataSet(entries: nr, label: nil)
        let chartData = PieChartData(dataSet:chartDataSet)
        let colors = [UIColor(red:0.44, green:0.76, blue:0.52, alpha:1.0),UIColor(red:0.94, green:0.78, blue:0.09, alpha:1.0),UIColor(red:0.94, green:0.47, blue:0.35, alpha:1.0),UIColor(red:0.88, green:0.58, blue:0.15, alpha:1.0)]
        chartDataSet.colors = colors
        cell.chart.data = chartData
//        if(indexPath.row == 0){
//            cell.labelChart.font = UIFont.boldSystemFont(ofSize: 28.0)
//        }
        cell.toLate.text = NSLocalizedString("to_late_text", comment: "")+": "+String(chartsArray[indexPath.row].laat!)
        cell.not.text = NSLocalizedString("not_text", comment: "")+": "+String(chartsArray[indexPath.row].nietIngenomen!)
        cell.onTime.text = NSLocalizedString("on_time_text", comment: "")+": "+String(chartsArray[indexPath.row].optijd!)
        cell.early.text = NSLocalizedString("to_early_text", comment: "")+": "+String(chartsArray[indexPath.row].vroeg!)
        cell.labelChart.text = chartsArray[indexPath.row].naam
        cell.chart.legend.enabled = false
        cell.chart.data?.setValueFont(UIFont.systemFont(ofSize: 8))
        
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        cell.chart.data?.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        return cell
    }
}

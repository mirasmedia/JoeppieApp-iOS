//
//  tapbarUi.swift
//  Joeppie
//
//  Created by Ercan kalan on 11/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit
import Charts

class ChartsViewController: UIViewController {
    @IBOutlet weak var bckimage: UIImageView!
    @IBOutlet weak var labeldate: UILabel!
    var chartsArray: [Charts] = []
    var patient: Patient?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var labelHiddenText: UILabel!
    
    override func viewDidLoad() {
        getUser()
        tableview.dataSource = self
        let nib = UINib(nibName: "ChartViewCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "ChartViewCell")
        tableview.allowsSelection = false;

    }
    

    
    var mondaysDate: Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
    
    func getAllChartMedicine(){
        
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    let startdayofWeek = df.string(from: mondaysDate)
    let formatterLabel = DateFormatter()
    formatterLabel.dateFormat = "dd-MM-yyyy"
    let startdateLabel = formatterLabel.string(from: mondaysDate)
    
    let calendar = Calendar.current
    var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: mondaysDate)
    let endofweekdb = calendar.date(byAdding: .day, value: 7, to: mondaysDate)!
    let endofweeklbl = calendar.date(byAdding: .day, value: 6, to: mondaysDate)!
   
    let enddayofweek = df.string(from: endofweekdb)
    let enddayofweekLabel = formatterLabel.string(from: endofweeklbl)
    self.labeldate.text = "\(startdateLabel) \(NSLocalizedString("till_small", comment: "")) \(enddayofweekLabel)"

        
        ApiService.getIntakesCountAll(greaterthandate: startdayofWeek, lowerthandate: enddayofweek, patientId: patient!.id)
            .responseData(completionHandler: { [weak self] (response) in
                
                guard response.data != nil else { return }
                //print(String(decoding: response.data!, as: UTF8.self))
                

                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let rs = try! decoder.decode([Intake].self, from: response.data!)
                self!.handleintake(rs: rs)
                
   
                self!.tableview.reloadData()
            })
    
        
    }
    
    func generateGeneralObject(){
        self.chartsArray.append(Charts(naam:NSLocalizedString("chart_general", comment: ""),laat: 0, optijd: 0, vroeg: 0, nietIngenomen: 0))
        self.parent!.navigationItem.leftBarButtonItem = nil
    }
    
    func handleintake(rs:[Intake]){
        for var item in rs {
            var check=true;
            for var indexchartobject in chartsArray.indices{
                if(chartsArray[indexchartobject].naam == item.medicine.name){
                    check=false;
                    switch item.state {
                    case "0":
                        chartsArray[indexchartobject].optijd!+=1
                        chartsArray[0].optijd!+=1
                    case "1":
                        chartsArray[indexchartobject].laat!+=1
                        chartsArray[0].laat!+=1
                    case "2":
                        chartsArray[indexchartobject].nietIngenomen!+=1
                        chartsArray[0].nietIngenomen!+=1
                    case "3":
                        chartsArray[indexchartobject].vroeg!+=1
                        chartsArray[0].vroeg!+=1
                    default:
                        continue
                    }

                }
            }
            if(check){
                var cs=Charts()
                cs.naam=item.medicine.name
                switch item.state {
                case String(DoseTakenTime.ON_TIME.rawValue):
                        cs.optijd=1
                        chartsArray[0].optijd!+=1
                    
                    case String(DoseTakenTime.LATE.rawValue):
                        cs.laat=1
                        chartsArray[0].laat!+=1
                    
                
                    case String(DoseTakenTime.NOT_TAKEN.rawValue):
                        cs.nietIngenomen=1
                        chartsArray[0].nietIngenomen!+=1
                    
                    case String(DoseTakenTime.EARLY.rawValue):
                        cs.vroeg=1
                        chartsArray[0].vroeg!+=1
                default:
                    continue
            }
                chartsArray.append(cs)
            }
        }
        if(chartsArray.count==1){
            tableview.isHidden=true;
            bckimage.image=UIImage(named: "Parrot")
            labelHiddenText.text=NSLocalizedString("there_is_no_data", comment: "")
        }
        else
        {
            self.tableview.reloadData()
        }

        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.chartsArray.removeAll()
        generateGeneralObject()
        getAllChartMedicine()
        super.viewWillAppear(animated)
        self.parent!.navigationItem.leftBarButtonItem = nil
        self.parent!.navigationItem.setHidesBackButton(true,animated: true)
    }
    
}

extension ChartsViewController:UITableViewDataSource{
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
    
    func getUser(){
            UserService.getPatientInstance(withCompletionHandler: { patient in
                guard patient != nil else {
                    return
                }
                self.patient=patient
            })
    }
    
}





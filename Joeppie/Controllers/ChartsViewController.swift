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
    @IBOutlet weak var labeldate: UILabel!
    var chartsArray: [Charts] = []
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        
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
        
    let calendar = Calendar.current
    var dateComponents: DateComponents? = calendar.dateComponents([.hour, .minute, .second], from: mondaysDate)
    let endofweek = calendar.date(byAdding: .day, value: 6, to: mondaysDate)!
   
    let enddayofweek = df.string(from: endofweek)
    self.labeldate.text = startdayofWeek+" tot "+enddayofweek
    print(startdayofWeek)
    print(enddayofweek)
        
        
        
        ApiService.getIntakesCountAll(greaterthandate: startdayofWeek, lowerthandate: enddayofweek)
            .responseData(completionHandler: { [weak self] (response) in
                
                guard response.data != nil else { return }
                print(String(decoding: response.data!, as: UTF8.self))
                

                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let rs = try! decoder.decode([Intake].self, from: response.data!)
                self!.handleintake(rs: rs)
                
                print(rs)
   
                self!.tableview.reloadData()
            })
    
        
    }
    
    func generateGeneralObject(){
        self.chartsArray.append(Charts(naam:"Algemeen",laat: 0, optijd: 0, vroeg: 0, nietIngenomen: 0))
        self.parent!.navigationItem.leftBarButtonItem = nil
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
                if(item.state=="0"){
                    cs.optijd=1
                    chartsArray[0].optijd!+=1
                }
                else if(item.state=="1"){
                    cs.laat=1
                    chartsArray[0].laat!+=1
                }
                else if(item.state=="2"){
                    cs.nietIngenomen=1
                    chartsArray[0].nietIngenomen!+=1
                }
                else if(item.state=="3"){
                    cs.vroeg=1
                    chartsArray[0].vroeg!+=1
                }
                chartsArray.append(cs)
            }
        }
        self.tableview.reloadData()
        
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
        opTijd.label = "Op tijd"
        opTijd.value = Double(chartsArray[indexPath.row].optijd!)
        let teLaat = PieChartDataEntry(value:0)
        teLaat.label = "Te laat"
        teLaat.value = Double(chartsArray[indexPath.row].laat!)
        let niet = PieChartDataEntry(value:0)
        niet.label = "Niet"
        niet.value = Double(chartsArray[indexPath.row].nietIngenomen!)
        let vroeg = PieChartDataEntry(value:0)
        vroeg.label = "Vroeg"
        vroeg.value = Double(chartsArray[indexPath.row].vroeg!)
        
        
        nr = [opTijd,teLaat,niet,vroeg]
        
        let chartDataSet = PieChartDataSet(entries: nr, label: nil)
        let chartData = PieChartData(dataSet:chartDataSet)
        let colors = [UIColor(red:0.44, green:0.76, blue:0.52, alpha:1.0),UIColor(red:0.94, green:0.78, blue:0.09, alpha:1.0),UIColor(red:0.94, green:0.47, blue:0.35, alpha:1.0)]
        chartDataSet.colors = colors
        cell.chart.data = chartData
//        if(indexPath.row == 0){
//            cell.labelChart.font = UIFont.boldSystemFont(ofSize: 28.0)
//        }
        cell.toLate.text = "Te laat: "+String(chartsArray[indexPath.row].laat!)
        cell.not.text = "Niet: "+String(chartsArray[indexPath.row].nietIngenomen!)
        cell.onTime.text = "Op tijd: "+String(chartsArray[indexPath.row].optijd!)
        cell.early.text = "Te vroeg: "+String(chartsArray[indexPath.row].vroeg!)
        cell.labelChart.text = chartsArray[indexPath.row].naam
        cell.chart.legend.enabled = false
        cell.chart.data?.setValueFont(UIFont.systemFont(ofSize: 8))
        
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        cell.chart.data?.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        return cell
    }
    
}





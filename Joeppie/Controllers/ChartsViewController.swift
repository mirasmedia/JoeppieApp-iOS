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

struct chartss{
    var title:String=""
    var opTijd:Int=0
    var teLaat:Int=0
    var niet:Int=0
    
}

class ChartsViewController: UIViewController {
    var chartsArray: [chartss] = []
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        
        tableview.dataSource = self
        let nib = UINib(nibName: "ChartViewCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "ChartViewCell")
        tableview.allowsSelection = false;
        
        
        self.chartsArray.append(chartss(title:"Algemeen",opTijd: 0,teLaat: 0,niet: 0))
        self.parent!.navigationItem.leftBarButtonItem = nil
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getChartsDataGeneral(dosetakentime: DoseTakenTime.ON_TIME)
        getChartsDataGeneral(dosetakentime: DoseTakenTime.LATE)
        getChartsDataGeneral(dosetakentime: DoseTakenTime.NOT_TAKEN)
    }
    
    func getChartsDataGeneral(dosetakentime:DoseTakenTime){
        var count:Int = 5
        
        ApiService.getIntakesCount(takenTime: dosetakentime)
            .responseData(completionHandler: { [weak self] (response) in
                
                guard response.data != nil else { return }
                print(String(decoding: response.data!, as: UTF8.self))
                let decoder = JSONDecoder()
                let rs = try? decoder.decode(Int.self, from: response.data!)
                print(rs)
                count = rs!
                
                if dosetakentime == DoseTakenTime.LATE{
                    self!.chartsArray[0].teLaat = rs!
                }
                else if dosetakentime == DoseTakenTime.NOT_TAKEN{
                    self!.chartsArray[0].niet = rs!
                }
                else{
                    self!.chartsArray[0].opTijd = rs!
                }
                self!.tableview.reloadData()
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        opTijd.value = Double(chartsArray[indexPath.row].opTijd)
        let teLaat = PieChartDataEntry(value:0)
        teLaat.label = "Te laat"
        teLaat.value = Double(chartsArray[indexPath.row].teLaat)
        let niet = PieChartDataEntry(value:0)
        niet.label = "Niet"
        niet.value = Double(chartsArray[indexPath.row].niet)
        
        
        nr = [opTijd,teLaat,niet]
        
        let chartDataSet = PieChartDataSet(entries: nr, label: nil)
        let chartData = PieChartData(dataSet:chartDataSet)
        let colors = [UIColor(red:0.44, green:0.76, blue:0.52, alpha:1.0),UIColor(red:0.94, green:0.78, blue:0.09, alpha:1.0),UIColor(red:0.94, green:0.47, blue:0.35, alpha:1.0)]
        chartDataSet.colors = colors
        cell.chart.data = chartData
//        if(indexPath.row == 0){
//            cell.labelChart.font = UIFont.boldSystemFont(ofSize: 28.0)
//        }
        cell.toLate.text = "Te laat: "+String(chartsArray[indexPath.row].teLaat)
        cell.not.text = "Niet: "+String(chartsArray[indexPath.row].niet)
        cell.onTime.text = "Op tijd: "+String(chartsArray[indexPath.row].opTijd)
        cell.labelChart.text = chartsArray[indexPath.row].title
        cell.chart.legend.enabled = false
        cell.chart.data?.setValueFont(UIFont.systemFont(ofSize: 8))
        
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        cell.chart.data?.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        return cell
    }
    
}





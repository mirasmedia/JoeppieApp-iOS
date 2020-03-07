//
//  PatientTableViewCell.swift
//  Joeppie
//
//  Created by Mark van den Berg on 07/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import UIKit
import Charts

class ChartViewCell: UITableViewCell {
    @IBOutlet weak var chart: PieChartView!
    @IBOutlet weak var labelChart: UILabel!
    @IBOutlet weak var onTime: UILabel!
    @IBOutlet weak var toLate: UILabel!
    @IBOutlet weak var not: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

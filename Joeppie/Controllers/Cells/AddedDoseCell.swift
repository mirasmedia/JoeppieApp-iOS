//
//  AddedDoseCell.swift
//  Joeppie
//
//  Created by qa on 19/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit


class AddedDoseCell: UITableViewCell{
    
    @IBOutlet weak var lblAmountTitle: UILabel!
    @IBOutlet weak var lblAmountValue: UILabel!
    @IBOutlet weak var lblReasonTitle: UILabel!
    @IBOutlet weak var lblReasonValue: UILabel!
    @IBOutlet weak var lblMedicineName: UILabel!
    @IBOutlet weak var imgMedicineType: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblReasonTitle.text = "REDEN:"
        lblAmountTitle.text = "AANTAL:"
        imgMedicineType.image = UIImage(named: "medicine_intake_icon")
    }

    override func prepareForReuse() {
        lblAmountValue.text = ""
        lblReasonValue.text = ""
        lblMedicineName.text = ""
        imgMedicineType.image = UIImage(named: "medicine_intake_icon")
        
    }
}

//
//  AddedDoseCell.swift
//  Joeppie
//
//  Created by Shahin Mirza on 19/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit


class AddedDoseCell: UITableViewCell{
    
    @IBOutlet weak var lblAmountTitle: UILabel!
    @IBOutlet weak var lblAmountValue: UILabel!
    @IBOutlet weak var lblReasonValue: UILabel!
    @IBOutlet weak var lblMedicineName: UILabel!
    @IBOutlet weak var imgMedicineType: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblAmountTitle.text = "\(NSLocalizedString("amount", comment: "")):"
        
        lblReasonValue.lineBreakMode = .byWordWrapping
        lblReasonValue.numberOfLines = 2
    }

    override func prepareForReuse() {
        lblAmountValue.text = ""
        lblReasonValue.text = ""
        lblMedicineName.text = ""
        imgMedicineType.image = UIImage(named: "medicine_intake_icon")
        
    }
}

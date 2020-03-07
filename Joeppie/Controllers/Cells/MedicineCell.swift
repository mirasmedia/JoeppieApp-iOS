//
//  TableCell.swift
//  Ercan_IOS_496932
//
//  Created by Ercan kalan on 21/10/2019.
//  Copyright © 2019 Inholland. All rights reserved.
//

import Foundation
import UIKit


class MedicineCell: UITableViewCell{
    

    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var medicine_intake_image: UIImageView!
    @IBOutlet weak var textMedicine: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        textMedicine.text = "Medicine naam"
        medicine_intake_image.image = UIImage(named: "placeholder")
    }
}

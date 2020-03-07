//
//  PatientTableViewCell.swift
//  Joeppie
//
//  Created by Mark van den Berg on 07/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var patientNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        badgeImageView.isHidden = true
        patientNameLabel.text = "empty"
    }
    
}

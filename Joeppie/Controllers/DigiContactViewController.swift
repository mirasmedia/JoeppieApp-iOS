//
//  DigiContactViewController.swift
//  Joeppie
//
//  Created by Ercan kalan on 11/12/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import UIKit

class DigiContactViewController: UIViewController {
    
    @IBOutlet weak var digiContactJoeppieImage: UIImageView!
    @IBOutlet weak var callButton_digicontact: UILabel!
    @IBOutlet weak var labelCallButton: UIImageView!
    @IBOutlet weak var callView: UIView!
    @IBOutlet weak var imgDigicontact: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgDigicontact.image = UIImage(named:"Digicontact_icon")
        digiContactJoeppieImage.contentMode = .scaleAspectFit
        digiContactJoeppieImage.image = UIImage(named: "Joeppie_conversation")
        callButton_digicontact.text = NSLocalizedString("Call", comment: "")
        labelCallButton.image = UIImage(named: "phone_icon")
        let tapaction = UITapGestureRecognizer(target: self, action: #selector(callDigiContact))
        callView.addGestureRecognizer(tapaction)
        self.parent!.navigationItem.leftBarButtonItem = nil
    }
    

    
      @objc func callDigiContact(){
        guard let number = URL(string: "tel://" + Constants.telDigicontact) else { return }
        UIApplication.shared.open(number)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent!.navigationItem.leftBarButtonItems = nil
        self.parent!.navigationItem.setHidesBackButton(true,animated: true)
     }
    
}



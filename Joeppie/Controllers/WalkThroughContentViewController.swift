//
//  WalkThroughContentViewController.swift
//  Joeppie
//
//  Created by Ercan kalan on 22/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class WalkThroughContentViewController: UIViewController {


    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subheading: UILabel!
    
    var headingtext = ""
    var subheadingtext = ""
    var index = 0
    var imageFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.image = UIImage(named: imageFile)
        heading.text = headingtext
        subheading.text = subheadingtext

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

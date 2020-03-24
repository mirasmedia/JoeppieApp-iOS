//
//  WalkThroughViewController.swift
//  Joeppie
//
//  Created by Ercan kalan on 22/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController,WalkthroughPageViewControllerDelegate {
    
    
    @IBOutlet var pagecontrol: UIPageControl!
    @IBOutlet var  nextbutton:UIButton!
    @IBOutlet var skipbutton:UIButton!

    var walkthroughPageViewController: WalkthroughPageViewController?
    
    override func viewDidLoad() {
        nextbutton.layer.cornerRadius = 15
        nextbutton.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        skipbutton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func skipbuttonclicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func skipclicked(_ sender: Any) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...2:
                walkthroughPageViewController?.forward()
            case 3:
                dismiss(animated: true, completion: nil)
            default:break
                
            }
        }
        updateUI()
    }
    
    func updateUI(){
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...2:
                nextbutton.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
                skipbutton.isHidden = false
            case 3:
                nextbutton.setTitle(NSLocalizedString("get_started", comment: ""), for: .normal)
                skipbutton.isHidden = true
            default:break
                
            }
            pagecontrol.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageviewcontroller = destination as? WalkthroughPageViewController{
            walkthroughPageViewController = pageviewcontroller
            walkthroughPageViewController?.walkThroughDelegate = self
        }
        
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

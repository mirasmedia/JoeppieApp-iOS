//
//  WalkthroughPageViewController.swift
//  Joeppie
//
//  Created by Ercan kalan on 22/03/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import UIKit

protocol WalkthroughPageViewControllerDelegate:class {
    func didUpdatePageIndex(currentIndex:Int)
}

class WalkthroughPageViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    weak var walkThroughDelegate:WalkthroughPageViewControllerDelegate?
    
    var pageHeadings = ["test1","test2","test3","test4"]
    var images = ["boarding1","boarding2","boarding3","boarding4"]
    var pageSubHeadings = ["Welkom op Joeppie","Medicijn innemen", "Digicontact","statistieken"]
    var currentIndex = 0 
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        if let startingViewController = contentViewController(at: 0){
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkThroughContentViewController).index
        index-=1
        
        return contentViewController(at:index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkThroughContentViewController).index
        index+=1
        
        return contentViewController(at:index)
    }
    
    func contentViewController(at index:Int) -> WalkThroughContentViewController?{
        if index < 0 || index>=pageHeadings.count{
            return nil
        }
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:
            "WalkThroughContentViewController") as? WalkThroughContentViewController
        controller!.headingtext = pageHeadings[index]
        controller!.imageFile = images[index]
        controller!.subheadingtext = pageSubHeadings[index]
        controller!.index = index
        
        return controller
        


    }
    
    func forward(){
        currentIndex+=1
        if let nextViewController = contentViewController(at: currentIndex){
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            if let contentViewController = pageViewController.viewControllers?.first as? WalkThroughContentViewController{
                currentIndex = contentViewController.index
                walkThroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
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

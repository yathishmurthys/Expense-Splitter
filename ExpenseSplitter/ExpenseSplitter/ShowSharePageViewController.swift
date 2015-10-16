//
//  ShowSharePageViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/24/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit

let INDIVIDUAL_EXP_VC   = "IndividualExpensesVC"
let SHARE_EXP_VC        = "ShareExpensesVC"
let PERSONAL_EXP_VC     = "PersonalExpensesVC"

class ShowSharePageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var currentExpenses: [Expense] = []
    var viewControllerIdentifiers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageController.currentPageIndicatorTintColor = UIColor.blueColor()
        pageController.backgroundColor = UIColor.whiteColor()

        self.viewControllerIdentifiers = [INDIVIDUAL_EXP_VC, SHARE_EXP_VC, PERSONAL_EXP_VC]

        self.dataSource = self
        
        let startVC = self.viewControllerAtIndex(1)
        let viewControllers = [startVC]
        
        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.didMoveToParentViewController(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func viewControllerAtIndex(index: Int) -> UIViewController {
        switch index {
        case 0:
//            self.title = "Individual Expenses"

            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(INDIVIDUAL_EXP_VC) as! IndividualExpensesViewController
            vc.currentExpenses = self.currentExpenses
            return vc

        case 1:
//            self.title = "Share Expenses"

            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SHARE_EXP_VC) as! ShareExpensesViewController
            vc.currentExpenes = self.currentExpenses
            return vc
            
        case 2:
//            self.title = "Personal Expenses"

            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(PERSONAL_EXP_VC) as! PersonalExpensesViewController
            vc.currentExpenes = self.currentExpenses
            return vc
            
        default:
            return UIViewController()
        }
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vcIdentifier = viewController.restorationIdentifier
        var index = self.viewControllerIdentifiers.indexOf(vcIdentifier!)!
        
        if (index == NSNotFound) {
            return nil
        }
        
        if (index == 0) {
            index = self.viewControllerIdentifiers.count - 1
        }
        
         index--
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vcIdentifier = viewController.restorationIdentifier
        var index = self.viewControllerIdentifiers.indexOf(vcIdentifier!)!
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if index == self.viewControllerIdentifiers.count {
            index = 0
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.viewControllerIdentifiers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
    }
}

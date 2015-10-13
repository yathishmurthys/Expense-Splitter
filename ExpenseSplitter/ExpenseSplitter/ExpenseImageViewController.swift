//
//  ExpenseImageViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/24/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit

class ExpenseImageViewController: UIViewController {

    var image: UIImage? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = self.image
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }

    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

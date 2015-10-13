//
//  PersonalExpensesViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/24/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit

class PersonalExpensesViewController: UIViewController, UITableViewDataSource {

    var currentExpenes: [Expense] = []
    var userPersonalExpTuples : [(expensor: String, expense: Float)] = []
    var totalExpense: Float = 0.0
    
    let numberFormatter = NSNumberFormatter()
    
    @IBOutlet weak var personalExpensesTableView: UITableView!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        personalExpensesTableView.dataSource = self
        personalExpensesTableView.tableFooterView = UIView()
        
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        self.calculatePersonalExpenses()
        self.calculateTotalExpense()
    }

    
    override func viewWillAppear(animated: Bool) {
        totalExpenseLabel.text! = numberFormatter.stringFromNumber(self.totalExpense)!
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

    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.userPersonalExpTuples.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personalExpenseCell", forIndexPath: indexPath)
        
        var font: UIFont
        
        if indexPath.section == 0 {
            font = UIFont.systemFontOfSize(16.0, weight: 0.2)
            
            cell.textLabel?.text = "User"
            cell.detailTextLabel?.text = "Share"

        } else {
            font = UIFont.systemFontOfSize(13.0)

            cell.textLabel!.text = self.userPersonalExpTuples[indexPath.row].expensor
            cell.detailTextLabel!.text = numberFormatter.stringFromNumber(self.userPersonalExpTuples[indexPath.row].expense)

        }
        
        cell.textLabel?.font = font
        cell.detailTextLabel?.font = font

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Personal Expenses"
        } else {
            return nil
        }
    }
        
    // MARK: - Helper Methods
    
    func calculatePersonalExpenses() {
        if !self.currentExpenes.isEmpty {
            let allUsers: [String] = self.currentExpenes[0].expenseManager.users.allObjects as! [String]
            
            for user in allUsers {
                var personalExp: Float = 0.0
                
                for exp in self.currentExpenes {
                    if exp.type != "Common" && user == exp.expensor {
                        personalExp += exp.amount.floatValue
                    }
                }
                
                self.userPersonalExpTuples += [(user, personalExp)]
            }
        }
    }
    
    func calculateTotalExpense() {
        var totalExp: Float = 0.0
        
        for uPET in self.userPersonalExpTuples {
            totalExp += uPET.expense
        }
        
        self.totalExpense = totalExp
    }
}

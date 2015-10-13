//
//  IndividualExpensesViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/24/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit

class IndividualExpensesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var currentExpenses: [Expense] = []
    let numberFormatter = NSNumberFormatter()
    var userInidividualExpTuples : [(expensor: String, expense: Float)] = []
    var totalExpense: Float = 0.0
    
    @IBOutlet weak var individualExpenseTableView: UITableView!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        individualExpenseTableView.dataSource = self
        individualExpenseTableView.tableFooterView = UIView()
        
        self.calculateIndividualExpenses()
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
            return self.userInidividualExpTuples.count
        }
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("individualExpenseCell", forIndexPath: indexPath)

        var font: UIFont
        
        if indexPath.section == 0 {
            font = UIFont.systemFontOfSize(16.0, weight: 0.2)
            
            cell.textLabel?.text = "User"
            cell.detailTextLabel?.text = "Share"
            
        } else {
            font = UIFont.systemFontOfSize(13.0)

            let tuple = self.userInidividualExpTuples[indexPath.row]
            cell.textLabel?.text = tuple.expensor
            cell.detailTextLabel?.text =  numberFormatter.stringFromNumber(tuple.expense)
        }
        
        cell.textLabel?.font = font
        cell.detailTextLabel?.font = font

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Individual Expenses"
        } else {
            return nil
        }
    }
        
    // MARK: - Helper Methods
    
    func calculateIndividualExpenses() {
        if !self.currentExpenses.isEmpty {
            let allUsers: [String] = self.currentExpenses[0].expenseManager.users.allObjects as! [String]
            for user in allUsers {
                var indExp: Float = 0.0
                
                for exp in self.currentExpenses {
                    if user == exp.expensor {
                        indExp += exp.amount.floatValue
                    }
                }
                
                self.userInidividualExpTuples += [(user, indExp)]
            }
        }
    }
    
    func calculateTotalExpense() {
        var totalExp : Float = 0.0
        
        for uIET in self.userInidividualExpTuples {
            totalExp += uIET.expense
        }
        
        self.totalExpense = totalExp
    }


}

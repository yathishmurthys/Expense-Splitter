//
//  ShareExpensesViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/24/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit

class ShareExpensesViewController: UIViewController, UITableViewDataSource {
    
    var currentExpenes: [Expense] = []
    var userShareTuples: [(user: String, spent: Float, share: Float, balance: Float)] = []
    var totalExpense: Float = 0.0
    
    let numberFormatter = NSNumberFormatter()

    @IBOutlet weak var shareExpenseTableView: UITableView!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        shareExpenseTableView.dataSource = self
        shareExpenseTableView.tableFooterView = UIView()
        
        self.calculateShare()
        self.calculateTotalExpense()
    }

    override func viewWillAppear(animated: Bool) {
        totalExpenseLabel.text = numberFormatter.stringFromNumber(self.totalExpense)
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
            return self.userShareTuples.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareExpenseCell", forIndexPath: indexPath) as! ShareExpenseTableViewCell
        
        var font: UIFont
        
        if indexPath.section == 0 {
            font = UIFont.systemFontOfSize(13.0, weight: 0.2)
            
            cell.userLabel?.text = "User"
            cell.spentAmtLabel?.text = "Spent"
            cell.shareAmtLabel.text = "Share"
            cell.balanceAmtLabel.text = "Balance"

        } else {
            font = UIFont.systemFontOfSize(13.0)

            let cellData = self.userShareTuples[indexPath.row]
            cell.userLabel.text = cellData.user
            cell.spentAmtLabel.text = numberFormatter.stringFromNumber(cellData.spent)
            cell.shareAmtLabel.text = numberFormatter.stringFromNumber(cellData.share)
            cell.balanceAmtLabel.text = numberFormatter.stringFromNumber(cellData.balance)
            
            if cellData.balance < 0 {
                cell.balanceAmtLabel.textColor = UIColor.redColor()
            } else {
                cell.balanceAmtLabel.textColor = UIColor.blueColor()
            }
        }
        
        cell.userLabel?.font = font
        cell.spentAmtLabel?.font = font
        cell.shareAmtLabel.font = font
        cell.balanceAmtLabel.font = font

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Share Expenses"
        } else {
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    func calculateShare() {
        if !self.currentExpenes.isEmpty {
            let allUsers: [String] = self.currentExpenes[0].expenseManager.users.allObjects as! [String]
            
            for user in allUsers {
                var spent: Float = 0.0
                var share: Float = 0.0
                var balance: Float = 0.0
                
                for exp in self.currentExpenes {
                    if (exp.expensor == user && exp.type == "Common") {
                        spent += exp.amount.floatValue
                    }
                    
                    for (var index = 0; index < exp.allUsers.count; index++) {
                        if exp.allUsers[index] == user && exp.isSelected[index] && exp.type == "Common"{
                            share += numberFormatter.numberFromString(exp.usersShare[index])!.floatValue
                        }
                    }
                }
                
                balance = spent - share
                self.userShareTuples += [(user, spent, share, balance)]
            }
        }
    }
    
    func calculateTotalExpense() {
        var totalExp: Float = 0.0
        
        for tuple in self.userShareTuples {
            totalExp += tuple.spent
        }
        
        self.totalExpense = totalExp
    }
    
}

class ShareExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var spentAmtLabel: UILabel!
    @IBOutlet weak var shareAmtLabel: UILabel!
    @IBOutlet weak var balanceAmtLabel: UILabel!
    
}
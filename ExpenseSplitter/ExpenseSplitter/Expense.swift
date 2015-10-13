//
//  Expense.swift
//  
//
//  Created by Yathish on 09/09/2015.
//
//

import Foundation
import CoreData

@objc(Expense)
class Expense: NSManagedObject {

    @NSManaged var expensor: String
    @NSManaged var amount: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var type: String
    @NSManaged var image: NSData
    @NSManaged var info: String
    @NSManaged var mode: String
    @NSManaged var isSelected: [Bool]
    @NSManaged var usersShare: [String]
    @NSManaged var allUsers: [String]
    @NSManaged var expenseManager: ExpensesManager

    override func awakeFromInsert() {
        self.date = NSDate()
        self.image = NSData()
    }
    
    
}

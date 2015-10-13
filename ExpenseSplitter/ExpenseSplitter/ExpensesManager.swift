//
//  ExpensesManager.swift
//  
//
//  Created by Yathish on 09/09/2015.
//
//

import Foundation
import CoreData

@objc(ExpensesManager)
class ExpensesManager: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var creationDate: NSDate
    @NSManaged var users: AnyObject
    @NSManaged var expenses: NSSet

    override func awakeFromInsert() {
        self.creationDate = NSDate()
    }
}

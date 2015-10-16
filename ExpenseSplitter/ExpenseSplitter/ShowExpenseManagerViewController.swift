//
//  ShowExpenseManagerViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/16/15.
//  Copyright (c) 2015 Yathish. All rights reserved.
//

import UIKit
import CoreData

class ShowExpenseManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, AddNewExpenseViewControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var currentExpenseManager: ExpensesManager? = nil
    var selectedIndexPath: NSIndexPath?
    var isNewExpense: Bool = false
    
    let dateFormatter = NSDateFormatter()
    let numberFormatter = NSNumberFormatter()
    
    @IBOutlet weak var optionsSegementedControl: UISegmentedControl!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var noExpensesLabel: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonClicked")
        
        self.expensesTableView.dataSource = self
        self.expensesTableView.tableFooterView = UIView()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        if self.currentExpenseManager!.expenses.count == 0 {
            expensesTableView.hidden = true
            noExpensesLabel.hidden = false
        } else {
            expensesTableView.hidden = false
            noExpensesLabel.hidden = true
        }
        
        var totalExpense : Float = 0.0
        let expenseArray = self.fetchedResultsController.fetchedObjects as! [Expense]
        for exp in expenseArray {
            totalExpense += exp.amount.floatValue
        }
        totalExpenseLabel.text = numberFormatter.stringFromNumber(totalExpense)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addNewExpenseSegue" {
            let addNewExpenseVC = segue.destinationViewController as! AddNewExpenseViewController
            addNewExpenseVC.managedObjectContect = self.fetchedResultsController.managedObjectContext
            addNewExpenseVC.delegate = self
            addNewExpenseVC.allUsers = (self.currentExpenseManager!.users as! [String])
            addNewExpenseVC.editMode = false
            
            let newExpense = NSEntityDescription.insertNewObjectForEntityForName("Expense", inManagedObjectContext: self.fetchedResultsController.managedObjectContext) as! Expense
            addNewExpenseVC.currentExpense = newExpense
            newExpense.expenseManager = self.currentExpenseManager!

            self.isNewExpense = true
            
        } else if segue.identifier == "showShareSegue" {
            let showShareVC = segue.destinationViewController as! ShowSharePageViewController
            showShareVC.currentExpenses = self.fetchedResultsController.fetchedObjects as! [Expense]
            
        } else if segue.identifier == "editExpenseSegue" {
            let editExpenseVC = segue.destinationViewController as! AddNewExpenseViewController
            editExpenseVC.managedObjectContect = self.fetchedResultsController.managedObjectContext
            editExpenseVC.delegate = self
            editExpenseVC.allUsers = (self.currentExpenseManager!.users as! [String])
            editExpenseVC.editMode = true
            
            let currentExpense = self.fetchedResultsController.objectAtIndexPath(self.selectedIndexPath!) as! Expense
            editExpenseVC.currentExpense = currentExpense
            
            self.isNewExpense = false
        }
        
        
    }
    
    // MARK: - Actions
    func addButtonClicked() {
        self.performSegueWithIdentifier("addNewExpenseSegue", sender: self)
    }

    @IBAction func showShareButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("showShareSegue", sender: self)
    }
    
    @IBAction func optionSelected(sender: AnyObject) {
        let selectedSegment = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        
        if selectedSegment == "Add New Expense"{
            self.performSegueWithIdentifier("addNewExpenseSegue", sender: sender)
        } else {
            self.performSegueWithIdentifier("showShareSegue", sender: sender)
        }
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("expenseCell", forIndexPath: indexPath) as! ExpenseTableViewCell
        let expense = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Expense
        
        cell.userLabel!.text = expense.expensor
        cell.infoLable!.text = expense.info
        cell.dateLabel!.text = dateFormatter.stringFromDate(expense.date)
        cell.amountLabel!.text = numberFormatter.stringFromNumber(expense.amount)
        
        if expense.mode == "Cash" {
            cell.modeImageView.image = UIImage(named: "cash")
        } else {
            cell.modeImageView.image = UIImage(named: "card")
        }
        
        if expense.type == "Common" {
            cell.typeImageView.image = UIImage(named: "common")
        } else {
            cell.typeImageView.image = UIImage(named: "personal")
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)

            var error: NSError? = nil
            do {
                try context.save() 
            } catch let error1 as NSError {
                error = error1
                print("ERROR: Deleting a expense in ShowExpensesViewController")
                print(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedIndexPath = indexPath
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Fetch Results Controller
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Expense", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let predicate = NSPredicate(format: "expenseManager == %@", self.currentExpenseManager!)
        fetchRequest.predicate = predicate
        
        let aFetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        aFetchRequestController.delegate = self
        
        _fetchedResultsController = aFetchRequestController
        
        var error: NSError? = nil
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            print("ERROR: Fetching expenses in ShowExpensesManager")
            print(error)
        }
        
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.expensesTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.expensesTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.expensesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.expensesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let expense = self.fetchedResultsController.objectAtIndexPath(indexPath!) as! Expense
            let expenseTableViewCell = self.expensesTableView.cellForRowAtIndexPath(indexPath!) as! ExpenseTableViewCell
            expenseTableViewCell.userLabel.text! = expense.expensor
            expenseTableViewCell.infoLable.text! = expense.info
            expenseTableViewCell.amountLabel.text! = numberFormatter.stringFromNumber(expense.amount)!
        case .Move:
            self.expensesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.expensesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }

    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.expensesTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.expensesTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }

    }
    
    // MARK: - Add New Expense View Controller Delegate
    
    func addNewExpenseViewControllerDidCancel(expense: Expense) {
        
        if self.isNewExpense {
            self.fetchedResultsController.managedObjectContext.deleteObject(expense)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func addNewExpenseViewControllerDidSave() {
        var error: NSError? = nil
        
        do {
            try self.fetchedResultsController.managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("ERROR: Creating New Expenses Manager")
            print(error)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
}


class ExpenseTableViewCell : UITableViewCell {
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var infoLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var modeImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
}
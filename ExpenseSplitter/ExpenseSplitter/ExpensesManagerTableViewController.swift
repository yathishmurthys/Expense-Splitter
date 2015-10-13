//
//  ExpensesManagerTableViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish on 09/09/2015.
//  Copyright (c) 2015 Yathish. All rights reserved.
//

import UIKit
import CoreData

class ExpensesManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, CreateExpensesManagerViewControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var selectedExpenseManager: ExpensesManager? = nil
    var isNewExpenseManager: Bool = false
    
    let dateFormatter = NSDateFormatter()

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        expensesTableView.dataSource = self
        expensesTableView.delegate = self
        expensesTableView.editing = false
        expensesTableView.allowsSelectionDuringEditing = true
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
    }

    override func viewWillAppear(animated: Bool) {
        self.handleEditBittonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Actions
    
    @IBAction func editButtonClicked(sender: AnyObject) {
        if expensesTableView.editing == true {
            expensesTableView.editing = false
            editButton.title = "Edit"
            editButton.style = UIBarButtonItemStyle.Plain
            
        } else {
            expensesTableView.editing = true
            editButton.title = "Done"
            editButton.style = UIBarButtonItemStyle.Done

        }

    }
    
    @IBAction func createNewExpenseManager(sender: AnyObject) {
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("expensesManagerCell", forIndexPath: indexPath) 
        let expensesManager = self.fetchedResultsController.objectAtIndexPath(indexPath) as! ExpensesManager
        cell.textLabel?.text = expensesManager.title
        
        cell.detailTextLabel?.text = dateFormatter.stringFromDate(expensesManager.creationDate)

        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! ExpensesManager)
            
            var error: NSError? = nil
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                print("ERROR: Deleting Expenses Manager")
                print(error)
            }
        }
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedExpenseManager = self.fetchedResultsController.objectAtIndexPath(indexPath) as? ExpensesManager
        return indexPath
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if expensesTableView.editing == true {
            self.performSegueWithIdentifier("editExpenseManagerSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("showExpenseManagerSegue", sender: self)
        }
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "createExpenseManagerSegue" {
            let createExpMngrVC = segue.destinationViewController as! CreateExpensesManagerViewController
            createExpMngrVC.managedObjectContext = self.fetchedResultsController.managedObjectContext
            createExpMngrVC.delegate = self
            
            let newExpensesManager = NSEntityDescription.insertNewObjectForEntityForName("ExpensesManager", inManagedObjectContext: self.fetchedResultsController.managedObjectContext) as! ExpensesManager
            createExpMngrVC.currentExpensesManager = newExpensesManager
            createExpMngrVC.editMode = false
            
            self.isNewExpenseManager = true
            
        } else if segue.identifier == "showExpenseManagerSegue" {
            let showExpenseManagerVC = segue.destinationViewController as! ShowExpenseManagerViewController
            showExpenseManagerVC.title = self.selectedExpenseManager?.title
            showExpenseManagerVC.managedObjectContext = self.fetchedResultsController.managedObjectContext
            showExpenseManagerVC.currentExpenseManager = self.selectedExpenseManager
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
        } else if segue.identifier == "editExpenseManagerSegue" {
            let editExpMngrVC = segue.destinationViewController as! CreateExpensesManagerViewController
            editExpMngrVC.managedObjectContext = self.fetchedResultsController.managedObjectContext
            editExpMngrVC.delegate = self
            
            editExpMngrVC.currentExpensesManager = self.selectedExpenseManager
            editExpMngrVC.editMode = true
            
            self.isNewExpenseManager = false
        }
        
    }

    
    // MARK: - Fetched Results Controller
    
    var _fetchedResultsController: NSFetchedResultsController! = nil
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController
        }
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("ExpensesManager", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "title", cacheName: nil)
        
        aFetchResultsController.delegate = self
        
        _fetchedResultsController = aFetchResultsController
        
        var error: NSError? = nil
        
        do {
            try _fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print("ERROR: Fetching Expense Manager")
            print(error)
        }
        
        return _fetchedResultsController
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        expensesTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        expensesTableView.endUpdates()
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            expensesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            expensesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let expenseManager = self.fetchedResultsController.objectAtIndexPath(indexPath!) as? ExpensesManager
            expensesTableView.cellForRowAtIndexPath(indexPath!)!.textLabel!.text! = expenseManager!.title
            expensesTableView.cellForRowAtIndexPath(indexPath!)!.detailTextLabel!.text! = dateFormatter.stringFromDate(expenseManager!.creationDate)
        case .Move:
            expensesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            expensesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            expensesTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            expensesTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
        
        self.handleEditBittonState()
    }
    // MARK: - Create Expenses Manager View Controller Delegate
    
    func createExpensesManagerViewControllerDidCancel(expensesManager: ExpensesManager) {
        if isNewExpenseManager {
            self.fetchedResultsController.managedObjectContext.deleteObject(expensesManager)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if !isNewExpenseManager {
            self.editButtonClicked(self)
        }
    }
    
    func createExpensesManagerViewControllerDidSave() {
        var error: NSError? = nil
        
        do {
            try self.fetchedResultsController.managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("ERROR: Creating New Expenses Manager")
            print(error)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

        if !isNewExpenseManager {
            self.editButtonClicked(self)
        }
    }
    
    // MARK: - Helper Methods
    
    func handleEditBittonState() {
        if self.fetchedResultsController.fetchedObjects!.isEmpty {
            editButton.enabled = false
        } else {
            editButton.enabled = true
        }
    }

}

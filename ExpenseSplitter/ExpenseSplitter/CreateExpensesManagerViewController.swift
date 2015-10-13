//
//  CreateExpensesManagerViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish on 09/09/2015.
//  Copyright (c) 2015 Yathish. All rights reserved.
//

import UIKit
import CoreData

class CreateExpensesManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate {

    var currentExpensesManager: ExpensesManager? = nil
    var userArray: [String] = []
    var editMode: Bool = false
    
    var delegate: CreateExpensesManagerViewControllerDelegate?
    
    var managedObjectContext: NSManagedObjectContext? = nil

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var vcTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        saveButton.enabled = false
        
        titleTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        titleTextField.delegate = self
        
        usersTableView.dataSource = self
        usersTableView.delegate = self
        usersTableView.tableFooterView = UIView()
        
        if !self.editMode {
            self.userArray = []
            vcTitle.title = "Create New Expense"
        } else {
            titleTextField.text = self.currentExpensesManager!.title
            self.userArray = self.currentExpensesManager!.users as! [String]
            vcTitle.title = "Edit Expense"
        }
        
        self.handleSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.delegate!.createExpensesManagerViewControllerDidCancel(self.currentExpensesManager!)
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        self.currentExpensesManager!.title = self.titleTextField.text!
        self.currentExpensesManager!.users = self.userArray
        self.delegate!.createExpensesManagerViewControllerDidSave()

    }
    
    @IBAction func addUser(sender: AnyObject) {
        
        self.titleTextField.resignFirstResponder()
        
        let alertView = UIAlertView(title: "Add New User", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.textFieldAtIndex(0)?.placeholder = "Name"
        alertView.textFieldAtIndex(0)?.delegate = self
        alertView.textFieldAtIndex(0)?.autocapitalizationType = UITextAutocapitalizationType.Words
        alertView.show()
    }

    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) 
        cell.textLabel?.text = userArray[indexPath.row]
        
        return cell
    }
    
    
    //MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            userArray.removeAtIndex(indexPath.row)
            self.usersTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Alert View Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let user = alertView.textFieldAtIndex(0)!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            if !user.isEmpty{
                userArray.append(user)
                self.usersTableView.reloadData()

            }
        }
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.handleSaveButtonState()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    
    func handleSaveButtonState() {
        if self.userArray.count > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }

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

protocol CreateExpensesManagerViewControllerDelegate {
    func createExpensesManagerViewControllerDidSave()
    func createExpensesManagerViewControllerDidCancel(expensesManager: ExpensesManager)
}
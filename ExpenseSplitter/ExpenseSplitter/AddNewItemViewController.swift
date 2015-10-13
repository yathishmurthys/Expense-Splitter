//
//  AddNewItemViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/26/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit

class AddNewItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var data: (key: String, selectedValue: String?, values: [String])?
    var selectedIndexPath =  NSIndexPath()
    var returnValue: String = ""

    lazy var vcTitle: String = {
        return self.data!.key
    }()
    
    lazy var textData: String = {
        return self.data!.values[0]
    }()
    
    lazy var tableData: [String] = {
        return self.data!.values
    }()
    
    lazy var chosenData: String = {
        return self.data!.selectedValue!
    }()
    
    var delegate: AddNewItemViewControllerDelegate?
        
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var expenseItemTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.topItem?.title = self.vcTitle
        
        expenseItemTableView.dataSource = self
        expenseItemTableView.delegate = self
        expenseItemTableView.tableFooterView = UIView()
        
        textField.delegate = self
        textField.text = self.chosenData
        
        self.showHideViews()
        
        for var row = 0; row < self.tableData.count; row++ {
            if self.chosenData == self.tableData[row] {
                self.selectedIndexPath = NSIndexPath(forRow: row, inSection: 0)
            }
        }
        
        self.returnValue = self.chosenData

        textField.endOfDocument
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
    
    // MARK: - Actions
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        textField.resignFirstResponder()
        
        if isInputValid() {
            self.delegate!.AddNewItemViewControllerDelegateDidSelectItem(self.returnValue)
        }
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dataCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.row]
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    // MARK: - Table View Delegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        self.selectedIndexPath = indexPath
        
        self.returnValue = tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text!
        tableView.reloadData()
        
        self.delegate!.AddNewItemViewControllerDelegateDidSelectItem(self.returnValue)
    }

    /* Below two methods are used to center the rows in the tableView by adjusting
        the header section and loading with an empty view */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var contentHeight: CGFloat = 0.0

        for _ in self.tableData {
            contentHeight += 44.0
        }
        
        return (tableView.bounds.size.height - contentHeight)/2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    // MARK: - Text Field Delegate
    
    // Set cursor position to end of the input always
    func textFieldDidBeginEditing(textField: UITextField) {
        let ending = textField.endOfDocument
        
        textField.selectedTextRange = textField.textRangeFromPosition(ending, toPosition: ending)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        self.returnValue = str
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if isInputValid() {
            textField.resignFirstResponder()
            self.delegate?.AddNewItemViewControllerDelegateDidSelectItem(self.returnValue)
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    func showHideViews() {
        if self.vcTitle == "Amount" {
            textField.hidden = false
            textField.keyboardType = UIKeyboardType.DecimalPad
            textField.becomeFirstResponder()
            expenseItemTableView.hidden = true
            
        } else if self.vcTitle == "Description" {
            textField.hidden = false
            textField.keyboardType = UIKeyboardType.Alphabet
            textField.becomeFirstResponder()
            expenseItemTableView.hidden = true

        } else {
            textField.hidden = true
            expenseItemTableView.hidden = false

        }
    }
    
    func isInputValid() -> Bool {
        
        if self.returnValue.isEmpty {
            let alert = UIAlertView(title: "ERROR!", message: "Please input a value", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert.show()
            return false
        } else {
            return true
        }
    }
}

protocol AddNewItemViewControllerDelegate {
    func AddNewItemViewControllerDelegateDidSelectItem(item: String)
}
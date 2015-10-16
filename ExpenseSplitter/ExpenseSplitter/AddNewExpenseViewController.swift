//
//  AddNewExpenseViewController.swift
//  ExpenseSplitter
//
//  Created by Yathish Murthy on 9/26/15.
//  Copyright © 2015 Yathish. All rights reserved.
//

import UIKit
import CoreData

let EXPENSOR_KEY                = "Expensor"

let AMOUNT_KEY                  = "Amount"
let AMOUNT_SELECTED_VALUE       = "0.00"
let AMOUNT_VALUES               = ["0.00"]

let DESCRIPTION_KEY             = "Description"
let DESCRIPTION_SELECTED_VALUE  = "Description"
let DESCRIPTION_VALUES          = ["Description"]

let PAYMENT_MODE_KEY            = "Payment Mode"
let PAYMENT_MODE_SELECTED_VALUE = "Cash"
let PAYMENT_MODE_VALUES         = ["Cash", "Card"]

let EXPENSE_TYPE_KEY            = "Expense Type"
let EXPENSE_TYPE_SELECTED_VALUE = "Common"
let EXPENSE_TYPE_VALUES         = ["Common", "Personal"]

class AddNewExpenseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddNewItemViewControllerDelegate {

    var managedObjectContect: NSManagedObjectContext? = nil
    var currentExpense: Expense? = nil
    var allUsers = [String]()
    var editMode: Bool = false
    
    var usersShare = [String]()
    var isSelected = [Bool]()
    var image: UIImage? = nil
    var newPhoto: Bool = false
    
    var delegate: AddNewExpenseViewControllerDelegate?
    
    var section0ItemTuples: [(key: String, selectedValue: String?, values: [String])] = []
    
    var rowIndex = 0
    
    let numberFormatter = NSNumberFormatter()

    @IBOutlet weak var vcTitle: UINavigationItem!
    @IBOutlet weak var expenseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Views
        expenseTableView.dataSource = self
        expenseTableView.delegate = self
        
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        /* For NewExpense set all default values 
            For Editing existing expense reload the values from currentExpense  */

        self.usersShare = [String](count: allUsers.count, repeatedValue: "00.00")
        self.isSelected = [Bool](count: allUsers.count, repeatedValue: true)

        if !self.editMode {
            vcTitle.title = "Add New Expense"
            
            self.section0ItemTuples = [(EXPENSOR_KEY, self.allUsers[0], self.allUsers),
                                        (AMOUNT_KEY, AMOUNT_SELECTED_VALUE, AMOUNT_VALUES),
                                        (DESCRIPTION_KEY, DESCRIPTION_SELECTED_VALUE, DESCRIPTION_VALUES),
                                        (PAYMENT_MODE_KEY, PAYMENT_MODE_SELECTED_VALUE, PAYMENT_MODE_VALUES),
                                        (EXPENSE_TYPE_KEY, EXPENSE_TYPE_SELECTED_VALUE, EXPENSE_TYPE_VALUES)]
            

        } else {
            vcTitle.title = "Edit Expense"
            
            self.section0ItemTuples = [(EXPENSOR_KEY, self.currentExpense!.expensor, self.allUsers),
                                        (AMOUNT_KEY, numberFormatter.stringFromNumber(self.currentExpense!.amount), ["0.00"]),
                                        (DESCRIPTION_KEY, self.currentExpense!.info, DESCRIPTION_VALUES),
                                        (PAYMENT_MODE_KEY, self.currentExpense!.mode, PAYMENT_MODE_VALUES),
                                        (EXPENSE_TYPE_KEY, self.currentExpense!.type, EXPENSE_TYPE_VALUES)]
            
            for var i = 0; i < self.currentExpense!.usersShare.count; i++ {
                self.usersShare[i] = self.currentExpense!.usersShare[i]
                self.isSelected[i] = self.currentExpense!.isSelected[i]
            }

            self.image = UIImage(data: self.currentExpense!.image)
        }

        self.calculateShare()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addItemSegue" {
            let addNewItemVC = segue.destinationViewController as! AddNewItemViewController
            addNewItemVC.data = self.section0ItemTuples[rowIndex]
            addNewItemVC.delegate = self
        }
        
        else if segue.identifier == "addImageSegue" {
            let expenseImageVC = segue.destinationViewController as! ExpenseImageViewController
            expenseImageVC.image = self.image
        }
    }

    // MARK: - Actions
    
    @IBAction func cancelbuttonClicked(sender: AnyObject) {
        self.delegate!.addNewExpenseViewControllerDidCancel(self.currentExpense!)
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        self.currentExpense!.expensor = self.section0ItemTuples[0].selectedValue!
        self.currentExpense!.amount = numberFormatter.numberFromString(self.section0ItemTuples[1].selectedValue!)!
        self.currentExpense!.info = self.section0ItemTuples[2].selectedValue!
        self.currentExpense!.mode = self.section0ItemTuples[3].selectedValue!
        self.currentExpense!.type = self.section0ItemTuples[4].selectedValue!
        self.currentExpense!.allUsers = self.allUsers
        self.currentExpense!.usersShare = self.usersShare
        self.currentExpense!.isSelected = self.isSelected
        
        if self.image != nil {
            self.currentExpense!.image = UIImagePNGRepresentation(self.image!)!

        }
        
        self.delegate!.addNewExpenseViewControllerDidSave()

    }
    
    // MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.section0ItemTuples.count
        } else if section == 1 {
            return 1
        } else {
            return self.allUsers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("itemCell", forIndexPath: indexPath)
            cell.textLabel?.text = self.section0ItemTuples[indexPath.row].key
            cell.detailTextLabel?.text = self.section0ItemTuples[indexPath.row].selectedValue
            
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ExpenseImageCell

            (cell as! ExpenseImageCell).titleLabel.text = "Image"
            if self.image == nil {
                cell.imageView?.hidden = true
                (cell as! ExpenseImageCell).expImageView.hidden = true
                
            } else {
                cell.imageView?.hidden = false
                (cell as! ExpenseImageCell).expImageView.hidden = false
                (cell as! ExpenseImageCell).expImageView.image = self.image
                
            }
            
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)
            cell.textLabel?.text = self.allUsers[indexPath.row]
            cell.detailTextLabel?.text = self.usersShare[indexPath.row]
            
            if isSelected[indexPath.row] == true {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell

    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Users"
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        self.selectedCellTitle = (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!
        self.rowIndex = indexPath.row
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // Add/View Image
        if indexPath.section == 1 {
            self.addImage()
        }
            
            // Select or un-select users for share
        else if indexPath.section == 2 {
            self.isSelected[indexPath.row] = !self.isSelected[indexPath.row]
            self.calculateShare()
        }

    }
    
    // MARK: - Image Picker Controller Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.image = image
        
        if (self.newPhoto == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        
        expenseTableView.reloadData()

    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    
    // MARK: - Add New Item View Controller Delegate
    
    func AddNewItemViewControllerDelegateDidSelectItem(item: String) {
        self.section0ItemTuples[self.rowIndex].selectedValue = item
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.calculateShare()
    }
        
    // MARK: - Helper Methods
    
    func calculateShare() {
        let expensor = self.section0ItemTuples[0].selectedValue
        let expenseType = self.section0ItemTuples[4].selectedValue
        let amount = numberFormatter.numberFromString(self.section0ItemTuples[1].selectedValue!)
        var numberOfShares : Float = 0.0
        
//        if expenseType == "Common" {
////            expenseTableView.allowsSelection = true
//            
//            for (var i = 0; i < self.allUsers.count; i++) {
//                self.isSelected[i] = true
//            }
//        } else {
////            expenseTableView.allowsSelection = false
        if expenseType != "Common" {
            for (var i = 0; i < self.allUsers.count; i++) {
                if expensor == self.allUsers[i] {
                    self.isSelected[i] = true
                } else {
                    self.isSelected[i] = false
                }
            }
        }
        
        for selected in isSelected {
            if selected {
                numberOfShares++
            }
        }
        
        let sharePerUser = amount!.floatValue / numberOfShares
        
        for (var i = 0; i < self.allUsers.count; i++) {
            if isSelected[i] {
                self.usersShare[i] = numberFormatter.stringFromNumber(sharePerUser)!
            } else {
                self.usersShare[i] = "0.00"
            }
        }
        
        self.expenseTableView.reloadData()
    }
    
    func addImage() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newPhoto = true
            }
            
        }
        
        let choosePhotoAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newPhoto = false
            }
            
        }
        
        let viewPhotoAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("addImageSegue", sender: self)
        }
        
        let deletePhotoAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.image = nil
            self.expenseTableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(choosePhotoAction)
        
        if self.image != nil {
            alertController.addAction(viewPhotoAction)
            alertController.addAction(deletePhotoAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
}

protocol AddNewExpenseViewControllerDelegate {
    func addNewExpenseViewControllerDidSave()
    func addNewExpenseViewControllerDidCancel(expense: Expense)
}

class ExpenseImageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expImageView: UIImageView!
    
}

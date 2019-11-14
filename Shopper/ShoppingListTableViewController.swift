//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by Roy, Bishakha on 11/12/19.
//  Copyright © 2019 Roy, Bishakha. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    
    // create a refernce to a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // create a variable that will contain the row of the selected Shopping List
    var selectedShoppingList: ShoppingList?
    
    // create an array to store Shopping List Item
    var shoppingListItems = [ShoppingListItem] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call load shopping list items method
        loadShoppingListItems()
        
        // if we have a valid Shopping List
        if let selectedShoppingList = selectedShoppingList {
            // get the Shopping List name and set the tittle
            title = selectedShoppingList.name!
        } else {
            // set the title to Shopping List Items
            title = "Shopping List Items"
        
        }
    }
    self.tableView.rowHeight = 84.0
    
    // fetch ShoppingListItems from CoreData
    func loadShoppingListItems (){
        // check if Shopper Table View Controller has passed a valid Shopping List
        if let list = selectedShoppingList {
            // if the Shopping List has items cast them to an array of ShoppingListItems
            if let listItems = list.items?.allObjects as? [ShoppingListItem] {
                // store constant in Shopping List Items array
                shoppingListItems = listItems
            }
        }
        // reload fetched data in Table View Controller
        tableView.reloadData()
    }
    // save ShoppingList
    func saveShoppingListItems () {
        do {
            // use context to save ShoppingLists
            try context.save()
        }catch {
            print("Error saving ShoppingListItems to Core Data!")
        }
        // reload the data in the Table View Controller
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // declare Text Fields variables for the input of the name, store, and date
               var nameTextfeild = UITextField()
               var priceTextfeild = UITextField()
               var quantityTextfeild = UITextField()
               
               // create an Alert Controller
               let alert = UIAlertController(title: "Add Shopping List Item", message: "", preferredStyle: .alert)
               
               // define an action that will occur when the Add List button is pushed
               let action = UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
                   
                   // create an instance of a ShoppingList entity
                   let newShoppingListItem = ShoppingListItem(context: self.context)
                   
                   // get name, store, and date input by user and store them in the ShoppingList entity
                   newShoppingListItem.name = nameTextfeild.text!
                   newShoppingListItem.price = Double(priceTextfeild.text!)!
                   newShoppingListItem.quantity = Int64(quantityTextfeild.text!)!
                   newShoppingListItem.purchased = false
                   newShoppingListItem.shoppingList = self.selectedShoppingList
                   
                   // add ShoppingListItem entity into array
                   self.shoppingListItems.append(newShoppingListItem)
                   
                   // save ShoppingLists into Core Data
                   self.saveShoppingListItems()
                   
               })
               
               // disable the action that will occure whe the Add List button is pushed
               action.isEnabled = false
               
               // define an action that will occure when the Cancel is pushed
               let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (cancelAction) in
                   
               })
               
               // add actions into Alert Controller
               alert.addAction(action)
               alert.addAction(cancelAction)
               
               // add the Text fields into the Alert Controller
               alert.addTextField(configurationHandler: { (field) in
                   nameTextfeild = field
                   nameTextfeild.placeholder = "Enter Name"
                   nameTextfeild.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
               })
               alert.addTextField(configurationHandler: { (field) in
                   priceTextfeild = field
                   priceTextfeild.placeholder = "Enter Price"
                   priceTextfeild.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
               })
               alert.addTextField(configurationHandler: { (field) in
                   quantityTextfeild = field
                   quantityTextfeild.placeholder = "Enter Quantity"
                   quantityTextfeild.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
               })
               
               // display the Alert Controller
               present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange () {
        
        // get a refernce to the Alert Controller
        let alertController = self.presentedViewController as!
            UIAlertController
        
        // get a refernce to the action that allows the user to add a ShoppingList
        let action = alertController.actions[0]
        
        // get refernce to the text in the Text Fields
        if let name = alertController.textFields![0].text,
            let price = alertController.textFields![1].text,
            let quantity = alertController.textFields![2].text{
            
            // trim whitespaces from the text
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
            let trimmedQuantity = quantity.trimmingCharacters(in: .whitespaces)
            
            //check if the trimmed text isn't empty and if it isn't enable the action that allows the user to add ShoppingList
            if (!trimmedName.isEmpty && !trimmedPrice.isEmpty && !trimmedQuantity.isEmpty){
                action.isEnabled = true
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  return the number of rows
        // we will have as many rows as there are shopping list items
        return shoppingListItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

        // Configure the cell...
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        // set the cell title equal to the shopping list item name
        cell.textLabel?.text = shoppingListItem.name!
        
        // set detailTextLable numberOfLines property to zero
        cell.detailTextLabel!.numberOfLines = 0
        // set the cell subtitle equal to the shopping list item quantity and price
        cell.detailTextLabel?.text = String(shoppingListItem.quantity) + "\n" +
            String( shoppingListItem.price)
        
        // set the cell accessory type to checkmark if purchased is equal to true, else set it to none
        if (shoppingListItem.purchased == false){
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

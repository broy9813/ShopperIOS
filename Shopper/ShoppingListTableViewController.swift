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
        // make row height larger
        self.tableView.rowHeight = 84.0
        
        setTitle()
    }
    
    func setTitle(){
        
        // declare local variable to store total cost of shopping list and initialize it to zero
        var totalCost = 0.0
        
        // loop through shopping list items and compute total cost
        for list in shoppingListItems{
            totalCost += Double(list.price) * Double(list.quantity)
        }
        // if we have a valid Shopping List
        if let selectedShoppingList = selectedShoppingList {
            // get the Shopping List name and set the tittle
            title = selectedShoppingList.name! + String(format: " $%.2f", totalCost)
        } else {
            // set the title to Shopping List Items
            title = "Shopping List Items"
        
        }
        
    }
    
    
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
    
    // delete ShoppingListItem entities from Core Data
    func deleteShoppingListItem(item: ShoppingListItem){
        context.delete(item)
        do {
            // use context to delete ShoppingList Item from Core Data
            try context.save()
        }catch {
            print("Error deleting ShoppingListItems from Core Data!")
        }
        loadShoppingListItems()
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
                
                    // update the title to incorporate the cost of the addded shopping list item
                   self.setTitle()
                   
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
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

        // getting the selected shopping list item
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        // get quantity, price, and purchased indicator for selected shopping list item
        let sQuantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        let purchased = shoppingListItem.purchased
        
        if (purchased == true){
            // if purchased indicator is true, set it to false and remove checkmark
            cell.accessoryType = .none
            shoppingListItem.purchased = false
        } else {
            // if purchased indicator is false, set it to true and remove checkmark
          cell.accessoryType = .checkmark
            shoppingListItem.purchased = true
        }
        
        //configure the table view cell
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel?.text = sQuantity + "\n" + sPrice
        
        //save update to purchased indicator
        self.saveShoppingListItems()
        
        //call deselect Row method to allow update to be visinle in table view controller
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            let item = shoppingListItems[indexPath.row]
            deleteShoppingListItem(item: item)
            setTitle()
    
        }    
    }
    

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

//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Harshit Agrawal on 14/03/19.
//  Copyright © 2019 Amrit. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class CategoryTableViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90.0
        loadItems()
        tableView.separatorStyle = .none

    }
    
    @IBAction func addCategoryPressed(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        // create the alert popup
        
        let action = UIAlertAction(title: "Add Category", style: .default){
            (action) in
            
            // what should happen when user clicked the add button
            let newItem = Category(context: self.context)
            newItem.name = textField.text!
            newItem.color = UIColor.randomFlat.hexValue()
            
            self.categoryArray.append(newItem)
            //self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
            self.SavaItems()
            
        }
        alert.addTextField{
            (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            
        }
        alert.addAction(action)
        self.present(alert,animated: true,completion: nil)
        
        
    }
    
    // MARK dataSource
    //MARk -- table view datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count 
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        // check the accessory of cell property
        let item = categoryArray[indexPath.row]
        cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].color ?? "#1D98F6")
        cell.textLabel?.text = item.name
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: categoryArray[indexPath.row].color!)!, returnFlat: true)
        
        return cell
    }
    
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showItems", sender:self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
        
    }
    func SavaItems(){
        
        do{
            try  context.save()
        }catch{
            print("Error in saving the Data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request :NSFetchRequest<Category> = Category.fetchRequest()){
        
        do {
            categoryArray = try context.fetch(request)
        }catch{
            print("Error in fetching the data\(error)")
        }
    }
    
    
}
extension CategoryTableViewController : SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete")
        {
            action, indexPath in
            
            self.context.delete(self.categoryArray[indexPath.row])
            self.categoryArray.remove(at: indexPath.row)
        
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    
    
}


//
//  ViewController.swift
//  Todoey
//
//  Created by Amritpal singh on 14/03/19.
//  Copyright © 2019 Amrit. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()    // array of item Objects
   // let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   // let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    
    @IBOutlet weak var seachBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        if let color = selectedCategory?.color {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: color)
        }
        /*
        if let item = defaults.array(forKey: "ToDoListArray") as? [String]{
            itemArray = item
        }
         load all the items in the database
       */
        title = selectedCategory?.name
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let hexColor = selectedCategory?.color{
            
            guard let navBar = navigationController?.navigationBar else{
                fatalError("Navigation controller does not exists")}
            if let navbarColor = UIColor(hexString: hexColor){
                
            navBar.barTintColor = navbarColor
            navBar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
            seachBar.barTintColor = navbarColor
            }
        }
    }
    
    
    //MARk -- table view datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
  
        // check the accessory of cell property
        let item = itemArray[indexPath.row];
        cell.textLabel?.text = item.title
        cell.delegate = self
        
        
        if let color = UIColor(hexString: selectedCategory!.color!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray.count)){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.deselectRow(at: indexPath, animated: true)
        SavaItems()
        
    }
    // MARK _ add new item
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        // create the alert popup
        let action = UIAlertAction(title: "Add Item", style: .default){
            (action) in
            // what should happen when user clicked the add button
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            //self.defaults.setValue(self.itemArray, forKey: "ToDoListArray")
            self.SavaItems()
         
        }
        alert.addTextField{
            (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        alert.addAction(action)
        self.present(alert,animated: true,completion: nil)
        }
    
    func SavaItems(){
        /*
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataPath!)
        }catch{
            print("Error encoding item array\(error)")
        }
        */
        do{
           try  context.save()
        }catch{
            print("Error in saving the Data \(error)")
        }
        self.tableView.reloadData()
      }
 
    
    func loadItems(with request :NSFetchRequest<Item> = Item.fetchRequest(), predicate :NSPredicate? = nil){
     
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@",(selectedCategory!.name!))
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[categoryPredicate,additionalPredicate])
        }else{
             request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
            print(itemArray.count)
        }catch{
            print("Error in fetching the data\(error)")
        }
        tableView.reloadData()
        
    }
    
    /*
     if let data = try? Data(contentsOf: dataPath!){
     let decoder = PropertyListDecoder()
     do{
     itemArray = try decoder.decode([Item].self , from: data)
     }catch{
     print("Error in decoding \(error)")
     }
     }
     }
     */
   // to delete the context
   // context.delete(itemArray[indxpath.row])

}
extension TodoListViewController :UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        let request :NSFetchRequest<Item> = Item.fetchRequest()
        
         let predicatee = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
         request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request,predicate: predicatee)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
extension TodoListViewController : SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete")
        {
            action, indexPath in
            
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            
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



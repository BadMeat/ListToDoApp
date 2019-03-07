//
//  ListTableViewController.swift
//  Todoey
//
//  Created by ogya 1 on 05/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {

    var listArray = [List]()
    let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ListArray.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category?{
        didSet{
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataPath!)
    }

    // MARK: - Table view data source
    @IBAction func addDataPressed(_ sender: Any) {
        var field = UITextField()
        let alert = UIAlertController(title:  "List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let list = List(context: self.context)
            list.title = field.text!
            list.done = false
            list.parentCategory = self.selectedCategory
            self.listArray.append(list)
            
            self.saveEncoder()
            
            self.tableView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (textField) in
            field = textField
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = listArray[indexPath.row].title
        
        cell.accessoryType = listArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        listArray[indexPath.row].done = !listArray[indexPath.row].done
//        context.delete(listArray[indexPath.row])
//        listArray.remove(at: indexPath.row)
        self.saveEncoder()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveEncoder(){
        do{
            try context.save()
        }catch{
            print("Save Context Error = \(error)")
        }
    }
    
    func loadData(with request : NSFetchRequest<List> = List.fetchRequest(), predicate : NSPredicate? = nil){
        if let pr = selectedCategory?.name{
            print("category = \(pr)")
        }
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do{
            listArray = try context.fetch(request)
        }catch{
            print("Error load = \(error)")
        }
        tableView.reloadData()
    }
}

extension ListTableViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<List> = List.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS [cd]%@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadData(with: request,predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

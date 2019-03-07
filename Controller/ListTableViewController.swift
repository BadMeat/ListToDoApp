//
//  ListTableViewController.swift
//  Todoey
//
//  Created by ogya 1 on 05/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import UIKit
import RealmSwift

class ListTableViewController: DeleteTableViewController {

    let realm = try! Realm()
    var listArray : Results<Item>?
    
    var selectedCategory : Category?{
        didSet{
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    @IBAction func addDataPressed(_ sender: Any) {
        var field = UITextField()
        let alert = UIAlertController(title:  "List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let currentCat = self.selectedCategory{
                do{
                    try self.realm.write {
                        let list = Item()
                        list.title = field.text!
                        currentCat.items.append(list)
                    }
                }catch{
                    print("Save Context Error = \(error)")
                }
            }
            
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
        return listArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = listArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Item Added"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let done = listArray?[indexPath.row]{
            do{
                try realm.write {
                    done.done = !done.done
                }
            }catch{
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadData(){
        listArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func deleteData(index: IndexPath) {
        if let currentItem = listArray?[index.row]{
            do{
                try realm.write {
                    realm.delete(currentItem)
                }
            }catch{
                print("error delete \(error)")
            }
        }
    }
}

extension ListTableViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        listArray = listArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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

//
//  ListTableViewController.swift
//  Todoey
//
//  Created by ogya 1 on 05/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ListTableViewController: DeleteTableViewController {

    let realm = try! Realm()
    var listArray : Results<Item>?
    
    var selectedCategory : Category?{
        didSet{
            loadData()
        }
    }
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name ?? "No Name"
        guard let navbar = navigationController?.navigationBar else {fatalError("cant load nav bar")}
        guard let barColor = UIColor(hexString: selectedCategory?.color ?? "#44755d")else{fatalError("Cannot get bar color")}
        navbar.barTintColor = barColor
        navbar.tintColor = ContrastColorOf(barColor, returnFlat: true)
        searchBarOutlet.barTintColor = barColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateColor(hexCode: "#44755d")
    }
    
    func updateColor(hexCode : String){
        guard let navbar = navigationController?.navigationBar else {fatalError("cant load nav bar")}
        guard let barColor = UIColor(hexString: hexCode)else{fatalError("Cannot get bar color")}
        navbar.barTintColor = barColor
        navbar.tintColor = ContrastColorOf(barColor, returnFlat: true)
        searchBarOutlet.barTintColor = barColor
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
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:
            CGFloat(indexPath.row)/CGFloat(listArray!.count)
                ){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
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

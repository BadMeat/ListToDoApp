//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by ogya 1 on 07/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: DeleteTableViewController {

    let realm = try! Realm()
    var categoryArray : Results<Category>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Category added"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! ListTableViewController
        if let rowSelected = tableView.indexPathForSelectedRow{
            desti.selectedCategory = categoryArray?[rowSelected.row]
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let cat = Category()
            cat.name = textField.text!
            self.saveData(category: cat)
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
        }
        present(alert, animated: true, completion: nil)
    }
    
    func loadData(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func saveData(category : Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Gagal simpan \(error)")
        }
        tableView.reloadData()
    }
    
    override func deleteData(index : IndexPath) {
        if let currentCategory = categoryArray?[index.row]{
            do{
                try realm.write {
                    realm.delete(currentCategory)
                }
            }catch{
                print("gagal delete \(error)")
            }
        }
    }
}

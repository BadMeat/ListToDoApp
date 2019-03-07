//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by ogya 1 on 07/03/19.
//  Copyright © 2019 ogya 1. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! ListTableViewController
        if let rowSelected = tableView.indexPathForSelectedRow{
            desti.selectedCategory = categoryArray[rowSelected.row]
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let cat = Category(context: self.context)
            cat.name = textField.text
            self.categoryArray.append(cat)
            self.saveData()
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
        }
        present(alert, animated: true, completion: nil)
    }
    
    func loadData(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("Error Load \(error)")
        }
        tableView.reloadData()
    }
    
    func saveData(){
        do{
            try context.save()
        }catch{
            print("Gagal simpan \(error)")
        }
        tableView.reloadData()
    }
    
}

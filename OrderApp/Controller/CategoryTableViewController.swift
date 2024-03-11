//
//  CategoryTableViewController.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import UIKit

class CategoryTableViewController: UITableViewController {

    var categories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task.init {
            do{
                let categories = try await MenuController.shared.fetchCategories()
                updateUI(with: categories)
            }catch{
                displayError(error, title: "Failed to fetch categories")
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenuController.shared.updateUserActivity(with: .categories)
    }
    
    func updateUI(with categories: [String]){
        self.categories = categories
        tableView.reloadData()
    }
    
    func displayError(_ error: Error, title: String){
        guard let _ = viewIfLoaded?.window else{
            return
        }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dissmiss", style: .default))
        self.present(alert, animated: true)
        
    }
    
    func config(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath){
        let category = categories[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = category.capitalized
        cell.contentConfiguration = content
    }
    
    
    @IBSegueAction func showMenu(_ coder: NSCoder, sender: Any?) -> MenuTableViewController? {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else{
                return nil
            }
            let category = categories[indexPath.row]
            return MenuTableViewController(coder: coder, category: category)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
        config(cell, forCategoryAt: indexPath)
        
        return cell
    }
    
    

  

}

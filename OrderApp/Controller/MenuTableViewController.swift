//
//  MenuTableViewController.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import UIKit

class MenuTableViewController: UITableViewController {

    let category: String
    var menuItems: [MenuItem] = []
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    required init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category.capitalized
        Task.init {
            do{
                let menuItems = try await MenuController.shared.fetchMenuItems(forCategory: category)
                updateUI(with: menuItems)
            }catch{
                displayError(error, title: "Failed to fetch Menu Item")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenuController.shared.updateUserActivity(with: .menu(category: category))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageLoadTasks.forEach { key, value in
            value.cancel()
        }
    }
    
    func updateUI(with menuItems: [MenuItem]){
        self.menuItems = menuItems
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
    
    func configCell(_ cell: UITableViewCell, forItemAt indexPath: IndexPath){
        guard let cell = cell as? MenuItemCell else{
            return
        }
        
        let menuItem = menuItems[indexPath.row]
        cell.itemName = menuItem.name
        cell.price = menuItem.price

        imageLoadTasks[indexPath]  =  Task{
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageUrl){
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath{
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
    }

    @IBSegueAction func showMenuItemDetail(_ coder: NSCoder, sender: Any?) -> MenuItemDetailViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        let menuItem = menuItems[indexPath.row]
        return MenuItemDetailViewController(coder: coder, menuItem: menuItem)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItem", for: indexPath)
        configCell(cell, forItemAt: indexPath)
        return cell
    }

   
//    MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }

}

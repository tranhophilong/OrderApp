//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
    var minutesToPrepare = 0
    
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        NotificationCenter.default.addObserver(tableView!, selector: #selector(tableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenuController.shared.updateUserActivity(with: .order)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageLoadTasks.forEach { key, value in
            value.cancel()
        }
    }
    
    @IBSegueAction func confirmOrder(_ coder: NSCoder, sender: Any?) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepare)
    }
    
    @IBAction  func unwindToOrderList(for segue: UIStoryboardSegue) {
        guard  segue.identifier == "dissmissConfirmation" else{
            return
        }
        
        MenuController.shared.order.menuItems.removeAll()
    }
  
    @IBAction func submitButtonTapped(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        
        let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
        let alertController = UIAlertController(title: "Confirm Order", message: "you are about to submit your order with a total of \(formattedTotal)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            self.uploadOrder()
        }))
        
        present(alertController, animated: true)
    }
    
    func uploadOrder(){
        let menuIds = MenuController.shared.order.menuItems.map { $0.id }
        Task.init {
            do{
                let minutesToPrepare = try await MenuController.shared.submitOrder(forMenuIds: menuIds)
                self.minutesToPrepare = minutesToPrepare
                performSegue(withIdentifier: "conformOrder", sender: nil)
            }catch{
                print(error)
                displayError(error, title: "Order Submission Failed")
            }
        }
    }
    
    func displayError(_ error: Error, title: String){
        guard let _ = viewIfLoaded?.window else{
            return
        }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dissmiss", style: .default))
        self.present(alert, animated: true)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MenuController.shared.order.menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath)
        config(cell, forMenuItemAt: indexPath)
        return cell
    }
    
    func config(_ cell: UITableViewCell, forMenuItemAt indexPath: IndexPath){
        guard let cell = cell as? MenuItemCell else{
            return
        }
        
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
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
    
//      MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }
}

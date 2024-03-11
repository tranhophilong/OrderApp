//
//  MenuItemDetailViewController.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import UIKit

class MenuItemDetailViewController: UIViewController {

    @IBOutlet weak var addToOrderButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    let menuItem: MenuItem
     
    required init?(coder: NSCoder, menuItem: MenuItem) {
        self.menuItem = menuItem
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenuController.shared.updateUserActivity(with: .menuItemDetail(menuItem: menuItem))
    }

    func updateUI(){
        nameLabel.text = menuItem.name
        detailTextLabel.text = menuItem.description
        priceLabel.text = menuItem.price.formatted(.currency(code: "usd"))
        
        Task{
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageUrl){
                imageView.image = image
            }
        }
    }

    @IBAction func orderButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1) {
            self.addToOrderButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.addToOrderButton.transform = CGAffineTransformIdentity
        }
        MenuController.shared.order.menuItems.append(menuItem)
    }
}

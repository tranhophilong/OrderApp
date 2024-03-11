//
//  OrderConfirmationViewController.swift
//  OrderApp
//
//  Created by Long Tran on 09/03/2024.
//

import UIKit

class OrderConfirmationViewController: UIViewController {

    let minutesToPrepare: Int
    
    @IBOutlet weak var confirmationLabel: UILabel!
    
    required init?(coder: NSCoder, minutesToPrepare: Int) {
        self.minutesToPrepare = minutesToPrepare
        super.init(coder: coder)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmationLabel.text = "Thanks you for your order. Your wait time is oppotunity \(self.minutesToPrepare) minutes"
        // Do any additional setup after loading the view.
    }
    

    
}

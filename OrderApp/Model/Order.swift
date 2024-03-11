//
//  Order.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import Foundation


struct Order: Codable{
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}

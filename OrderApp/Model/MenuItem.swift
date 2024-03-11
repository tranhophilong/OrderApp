//
//  MenuItem.swift
//  OrderApp
//
//  Created by Long Tran on 09/03/2024.
//

import Foundation


struct MenuItem: Codable {
    var id: Int
    var name: String
    var description: String
    var price: Double
    var category: String
    var imageUrl: URL
    
   
}

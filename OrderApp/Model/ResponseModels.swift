//
//  ResponseModels.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import Foundation


struct MenuResponse: Codable{
    let items: [MenuItem]
}

struct CategoriesResponse: Codable{
    let categories: [String]
}

struct OrderResponse: Codable{
    let preparationTime: Int
    
}

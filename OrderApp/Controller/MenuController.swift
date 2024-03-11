//
//  MenuController.swift
//  OrderApp
//
//  Created by Long Tran on 08/03/2024.
//

import UIKit

class MenuController{
    
    let baseURL = URL(string: "http://localhost:8080/")!
    var userActivity = NSUserActivity(activityType: "com.example.OrderApp.order")
    typealias MinutesToPrepare = Int
    static let shared = MenuController()
    static let orderUpdatedNotification = Notification.Name(rawValue: "MenuController.orderUpdated")
    var order = Order(){
        didSet{
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
            userActivity.order = order
        }
    }
    
    func fetchCategories() async throws -> [String] {
        let catogoriesURL = baseURL.appendingPathComponent("categories")
        let (data, response) = try await URLSession.shared.data(from: catogoriesURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
            throw MenuControllerError.categoriesNotFound
        }
        let jsonDecoder = JSONDecoder()
        let categoriesResponse = try jsonDecoder.decode(CategoriesResponse.self, from: data)
        return categoriesResponse.categories
    }
    
    func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem]{
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        var component = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        component.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = component.url!
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
            throw MenuControllerError.menuItemsNotFound
        }
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let menuResponse = try jsonDecoder.decode(MenuResponse.self, from: data)
        return menuResponse.items
    }
    
    func submitOrder(forMenuIds menuIds: [Int]) async throws  -> MinutesToPrepare{
        let orderURL = baseURL.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let menuIdsDict = ["menuIds": menuIds]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIdsDict)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let preTimeResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
        
        return preTimeResponse.preparationTime
        
    }
    
    func fetchImage( from url: URL) async throws -> UIImage{
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
            throw MenuControllerError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else{
            throw MenuControllerError.imageDataMissing
        }
        
        return image
    }
    
    func updateUserActivity(with controller: StateRestorationController){
        switch controller{
       
        case .menu(category: let category):
            userActivity.menuCategory = category
        case .menuItemDetail(menuItem: let menuItem):
            userActivity.menuItem = menuItem
        case .order, .categories:
            break
        }
        
        userActivity.controllerIdentifier = controller.identifier
    }
}


enum MenuControllerError: Error, LocalizedError{
    case categoriesNotFound
    case menuItemsNotFound
    case orderRequestFailed
    case imageDataMissing
}

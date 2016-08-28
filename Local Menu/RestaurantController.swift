//
//  RestaurantController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/29/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit
import Mapbox

// bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Mapbox.framework/strip-frameworks.sh"

class RestaurantController {
    
    static let sharedInstance = RestaurantController()
    
    var myRestaurants = [Restaurant]()
    
    func fetchRestaurantsForCategory(category: CuisineType, distance: Float, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, distance]
        
        let name = category.rawValue
        //        if category == .All {
        //            name = ""
        //        } else {
        //            name = category.rawValue
        //        }
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location", "categories"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":name]]],
                        "api_key": "08f3f647d0de281100b36fa8f91f71bb821203e1"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
    
    func fetchRestaurantsForMenus(category: CuisineType, distance: Float, menuURL: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        //hmm we might have to create a whole other model...
        //well thats what I was thinking, but I think it should be simpler than that. i think we just need to modify our fetchLocuData in the viewController... is it cool if i show you what i was trying to do?
        //Go for it. I agree. But also making another model should be simple. It would be the same, only making menu urls not optionnal.
        ////haha k, check this out.
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, distance]
        
        let name = category.rawValue
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location", "categories"],
                        "venue_queries": [["location": ["geo": locationRequest],"menu_url": menuURL, "categories" : ["name":name]]],
                        "api_key": "08f3f647d0de281100b36fa8f91f71bb821203e1"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }

    
    
    func bakeryFetchRestaurantsForAll(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, 5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":category]]],
                        "api_key": "44be813e6e30f7c82da90e5369aa0618ac294d73"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
    
    func pizzaFetchRestaurantsForAll(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, 5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":category]]],
                        "api_key": "44be813e6e30f7c82da90e5369aa0618ac294d73"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
    
    func europeanFetchRestaurantsForAll(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, 5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":category]]],
                        "api_key": "44be813e6e30f7c82da90e5369aa0618ac294d73"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            //            if restaurantsArray.count != 0 {
            //               restaurantsArray.removeAll()
            //            } else {
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
            //            }
        }
    }
    
    func easternFetchRestaurantsForAll(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, 5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":category]]],
                        "api_key": "44be813e6e30f7c82da90e5369aa0618ac294d73"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
    
    func sushiFetchRestaurantsForAll(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, 5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":category]]],
                        "api_key": "08f3f647d0de281100b36fa8f91f71bb821203e1"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
    
    func latinAmericanFetchRestaurantsForAll(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //look inot NSOperations
        //Dave Delonge
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude, 5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location": ["geo": locationRequest], "categories" : ["name":category]]],
                        "api_key": "44be813e6e30f7c82da90e5369aa0618ac294d73"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            
            
            
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
    
    func searchForRestaurantsByItem(searchTerm: String, city: String, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        let bodyDict = ["fields": ["name", "menu_items"],
                        "venue_queries": [["location": ["locality": city]]],
                        "menu_item_queries" : [["name": searchTerm]],
                        "api_key": "08f3f647d0de281100b36fa8f91f71bb821203e1"]
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                completion(restaurants: [], success: false)
                return
            }
            //            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [], success: false)
                return
            }
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            self.myRestaurants.appendContentsOf(restaurantsArray)
            self.myRestaurants = restaurantsArray
            completion(restaurants: restaurantsArray, success: true)
        }
    }
}





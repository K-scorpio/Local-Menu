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
    
    var myRestaurant = [Restaurant]()
    
    func getRestaurants() {
        
    }
    
    func fetchLocuData(location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant]) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [])
            return
        }
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude,5000]
        
        
        let bodyDict = ["fields": ["name", "locu_id", "menu_url", "contact", "website_url", "extended", "open_hours", "location"],
                        "venue_queries": [["location"   : ["geo": locationRequest] ,"categories" : ["name":"Italian"]] /*, ["menus": ["sections": ["subsections": ["contents": "price"]]]]*/],
                        "api_key": "44be813e6e30f7c82da90e5369aa0618ac294d73"]
        
        
        guard let data = try? NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted) else {
            return
        }
        
        NetworkController.performRequestForURL(baseURL, httpMethod: .Post, body: data) { (data, response, error) in
            guard let _ = response, data = data, serializedData = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments), dataDictionary = serializedData as? [String: AnyObject] else {
                return
            }
            print(dataDictionary)
            guard let restaurants = dataDictionary["venues"] as? [[String: AnyObject]] else {
                completion(restaurants: [])
                return
            }
            
            
            
            let restaurantsArray = restaurants.flatMap { Restaurant(dictionary: $0) }
            //            restaurantsArray.forEach { print($0.name) }
            //            restaurantsArray.forEach { print($0.menuURL) }
            //            restaurantsArray.forEach { print($0.address1) }
            //            restaurantsArray.forEach { print($0.locality) }
            //            restaurantsArray.forEach { print($0.region) }
            //            restaurantsArray.forEach { print($0.postalCode) }
            //            restaurantsArray.forEach { print($0.country) }
            //            restaurantsArray.forEach { print($0.longitude) }
            //            restaurantsArray.forEach { print($0.latitude) }
            
            completion(restaurants: restaurantsArray)
        }
    }
}





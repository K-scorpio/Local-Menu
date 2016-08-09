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
    
    func fetchRestaurantsForCategory(category: String, location: CLLocationCoordinate2D, completion: (restaurants: [Restaurant], success: Bool) -> Void) {
        
        guard let baseURL = NSURL(string: "https://api.locu.com/v2/venue/search/") else {
            completion(restaurants: [], success: false)
            return
        }
        
        //        func request(location: CLLocationCoordinate2D) {
        //            let location: CLLocationCoordinate2D
        var locationRequest = [String:AnyObject]()
        locationRequest["$in_lat_lng_radius"] = [location.latitude,location.longitude,5000]
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
            completion(restaurants: restaurantsArray, success: true)
        }
    }
}





//
//  Restaurant.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/29/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import Foundation

struct Restaurant {
    
    let name: String
    let menuURL: String
    let address1: String
    let locality: String
    let region: String
    let postalCode: String
    let country: String
    let longitude: Double
    let latitude: Double
    
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"] as? String,
            let menuURL = dictionary["menu_url"] as? String,
            let location = dictionary["location"] as? [String: AnyObject],
            let address1 = location["address1"] as? String,
            let region = location["region"] as? String,
            let locality = location["locality"] as? String,
            let postalCode = location["postal_code"] as? String,
            let country = location["country"] as? String,
            let geo = location["geo"] as? [String: AnyObject],
            let coordinates = geo["coordinates"] as? [Double]
            else {
                return nil
        }
        guard coordinates.count >= 2 else {
            return nil
        }
        
        let longitude = coordinates[0]
        let latitude = coordinates[1]
        
        self.name = name
        self.menuURL = menuURL
        self.address1 = address1
        self.locality = locality
        self.region = region
        self.postalCode = postalCode
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}
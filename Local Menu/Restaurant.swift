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
    let locuID: String
    let address1: String
    let locality: String
    let region: String
    let postalCode: String
    let country: String
    let longitude: Double
    let latitude: Double
    let alcohol: String?
    let wifi: String?
    let music: [String]?
    let reservations: Bool?
    let goodForKids: Bool?
    let takeout: Bool?
    let noiseLevel: String?
    let attire: String?
    let highRange: String?
    let lowRange: String?
    let price: String?
    
    
    
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"] as? String,
            let locuID = dictionary["locu_id"] as? String,
            let location = dictionary["location"] as? [String: AnyObject],
            let address1 = location["address1"] as? String,
            let region = location["region"] as? String,
            let locality = location["locality"] as? String,
            let postalCode = location["postal_code"] as? String,
            let country = location["country"] as? String,
            let geo = location["geo"] as? [String: AnyObject],
            let coordinates = geo["coordinates"] as? [Double] else {
                return nil
        }
        guard coordinates.count >= 2 else {
            return nil
        }
        
        let longitude = coordinates[0]
        let latitude = coordinates[1]
        
        self.name = name
        self.locuID = locuID
        self.address1 = address1
        self.locality = locality
        self.region = region
        self.postalCode = postalCode
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        
        if let menus = dictionary["menus"] as? [[String: AnyObject]],
            let sections = menus[1]["sections"] as? [[String: AnyObject]],
            let subsections = sections[1]["subsections"] as? [[String : AnyObject]],
            let contents = subsections[1]["contents"] as? [[String: AnyObject]],
            let price = contents[0]["price"] as? String {
            self.price = price
        } else {
            return nil
        }
      
        
        if let extended = dictionary["extended"] as? [String: AnyObject] {
            self.alcohol = extended["alcohol"] as? String ?? nil
            self.wifi = extended["wifi"] as? String ?? nil
            self.music = extended["music"] as? [String] ?? nil
            self.reservations = extended["reservations"] as? Bool ?? nil
            self.goodForKids = extended["good_for_kids"] as? Bool ?? nil
            self.takeout = extended["takeout"] as? Bool ?? nil
            self.noiseLevel = extended["noise_level"] as? String ?? nil
            self.attire = extended["attire"] as? String ?? nil
            if let priceRange = extended["price_range"] as? [String: AnyObject] {
                self.highRange = priceRange["high"] as? String ?? nil
                self.lowRange = extended["low"] as? String ?? nil
            } else {
                self.highRange = nil
                self.lowRange = nil
            }
        } else {
            self.alcohol = nil
            self.wifi = nil
            self.music = nil
            self.reservations = nil
            self.goodForKids = nil
            self.takeout = nil
            self.noiseLevel = nil
            self.attire = nil
            self.highRange = nil
            self.lowRange = nil
        }
    }
}
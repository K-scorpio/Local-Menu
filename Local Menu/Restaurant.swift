//
//  Restaurant.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/29/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import Foundation

struct Restaurant {
    
    private let kName = "name"
    private let kLocuID = "locu_id"
    private let kAddress1 = "address1"
    private let kLocality = "locality"
    private let kRegion = "region"
    private let kPostalCode = "postal_code"
    private let kCountry = "country"
    private let kLongitude = "latitude"
    private let kLatitude = "longitude"
    private let kAlcohol = "alcohol"
    private let kWifi = "wifi"
    private let kMusic = "music"
    private let kReservations = "reservations"
    private let kGoodForKids = "good_for_kids"
    private let kTakeout = "takeout"
    private let kNoiseLevel = "noise_level"
    private let kAttire = "attire"
    private let kHighRange = "high"
    private let kLowRange = "low"
    private let kPrice = "price"
    private let kPriceRange = "price_range"
    private let kLocation = "location"
    private let kGeo = "geo"
    private let kCoordinates = "coordinates"
    private let kMenus = "menus"
    private let kExtended = "extended"
    private let kSections = "sections"
    private let kSubsections = "subsections"
    private let kContents = "contents"
    private let kMenuUrl = "menu_url"
    private let kWebsiteURL = "website_url"
    private let kContact = "contact"
    private let kPhoneNumber = "phone"
    private let kCategoryName = "name"
    
    let name: String
    let locuID: String
    let menuURL: String?
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
    let prices: [String]?
    let websiteURL: String?
    let phoneNumber: String?
    let categoryName: String?
    
    // these ^ are my objects in a restaurant finder app
    
    //andrew@devmountain.com
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary[kName] as? String,
            let locuID = dictionary[kLocuID] as? String,
            let location = dictionary[kLocation] as? [String: AnyObject],
            let address1 = location[kAddress1] as? String,
            let region = location[kRegion] as? String,
            let locality = location[kLocality] as? String,
            let postalCode = location[kPostalCode] as? String,
            let country = location[kCountry] as? String,
            let geo = location[kGeo] as? [String: AnyObject],
            let coordinates = geo[kCoordinates] as? [Double] else {
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

        
    /////////// Category Name /////////////
        
        if let categories = dictionary["categories"] as? [[String: AnyObject]] {
            self.categoryName = categories[0][kCategoryName] as? String ?? nil
        } else {
            self.categoryName = nil
        }
        
    /////////// Menu Item Prices /////////////

        
        if let menus = dictionary[kMenus] as? [[String: AnyObject]],
            let sections = menus[0][kSections] as? [[String: AnyObject]],
            let subsections = sections[0][kSubsections] as? [[String : AnyObject]],
            let contents = subsections[0][kContents] as? [[String: String]] {
            let prices = contents.flatMap({$0["price"]})
            self.prices = prices
        } else {
            self.prices = nil
        }
        
        
    //////////// Menu URL ///////////////
        
        if let menuURL = dictionary[kMenuUrl] as? String ?? nil {
            self.menuURL = menuURL
        } else {
            self.menuURL = nil
        }
        
    //////////// Website URL ///////////////

        if let websiteURL = dictionary[kWebsiteURL] as? String ?? nil {
            self.websiteURL = websiteURL
        } else {
            self.websiteURL = nil
        }
        
        
    //////////// Phone ///////////////
        
        if let contact = dictionary[kContact] as? [String: AnyObject] {
            self.phoneNumber = contact[kPhoneNumber] as? String ?? nil
        } else {
            self.phoneNumber = nil
        }
        
    ////////// Extended Options ////////////
        
        if let extended = dictionary[kExtended] as? [String: AnyObject] {
            self.alcohol = extended[kAlcohol] as? String ?? nil
            self.wifi = extended[kWifi] as? String ?? nil
            self.music = extended[kMusic] as? [String] ?? nil
            self.reservations = extended[kReservations] as? Bool ?? nil
            self.goodForKids = extended[kGoodForKids] as? Bool ?? nil
            self.takeout = extended[kTakeout] as? Bool ?? nil
            self.noiseLevel = extended[kNoiseLevel] as? String ?? nil
            self.attire = extended[kAttire] as? String ?? nil
            if let priceRange = extended[kPriceRange] as? [String: AnyObject] {
                self.highRange = priceRange[kHighRange] as? String ?? nil
                self.lowRange = extended[kLowRange] as? String ?? nil
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







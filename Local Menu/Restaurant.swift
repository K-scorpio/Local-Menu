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
    
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"] as? String,
        let menuURL = dictionary["menu_url"] as? String else {
            return nil
        }
        self.name = name
        self.menuURL = menuURL
    }
}
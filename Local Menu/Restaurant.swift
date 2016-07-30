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
    
    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"] as? String else {
            return nil
        }
        self.name = name
    }
}
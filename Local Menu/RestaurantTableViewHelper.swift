//
//  RestaurantTableViewHelper.swift
//  Local Menu
//
//  Created by Kevin Hartley on 8/11/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

class RestaurantTableViewHelper {
    
    class func EmptyMessage(message:String, viewController: UITableView) {
        let messageLabel = UILabel(frame: CGRectMake(0,0,viewController.bounds.size.width, viewController.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.init(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont(name: "PierSans", size: 58)
//        for family: String in UIFont.familyNames()
//        {
//            print("\(family)")
//            for names: String in UIFont.fontNamesForFamilyName(family)
//            {
//                print("== \(names)")
//            }
//        }
        messageLabel.sizeToFit()
        
        viewController.backgroundView = messageLabel
        viewController.separatorStyle = .None
    }
}

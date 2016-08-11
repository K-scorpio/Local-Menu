//
//  RestaurantTableViewCell.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/29/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    @IBOutlet weak var restaurantTypeLabel: UILabel!
    
    @IBOutlet weak var restaurantDistanceLabel: UILabel!
    
    @IBOutlet weak var restaurantMenuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

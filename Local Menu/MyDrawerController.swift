//
//  MyDrawerController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 8/10/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

class MyDrawerController : MMDrawerController, CuisineViewControllerDelegate {
    func cuisineTypeSelected(type: CuisineType) {
        if let navController = centerViewController as? UINavigationController,
        let restaurantViewController = navController.viewControllers.first as? RestaurantViewController {
            restaurantViewController.cuisineType = type
        }
    }
}

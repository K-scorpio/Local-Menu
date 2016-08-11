//
//  CuisineViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 8/9/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

protocol CuisineViewControllerDelegate: class {
    func cuisineTypeSelected(type: CuisineType)
}
/*
 
 
 Sushi & Japanese
 
 
 
 European: French - fish n chips - German
 : Greek - Turkey - Spain - Italian
 Latin American: Peruvian - Brazilian - Salvadorian - Columbian - Caribbean
 Ethic: Indian - Afghani - Armenian Bakeries
 let categoryArray = ["Mexican", "Italian", "Chinese", "Burgers", "Japanese", "Indian", "Bakeries", "Coffee", "Thai", "Greek", "French", "German", "Brazilian", "Peruvian", "Salvadorian", "Latin", "Spanish", "Salvadorian", "Spanish", "Bars", "Ice Cream", "Pizza", "Italian", "American", "Middle Eastern"]
 
*/
enum CuisineType: String {
    
    case Burgers
    case Pizza
    case Coffee
    case Bakery
    case IceCream
    case Mexican
    case Italian
    case Chinese
    case Japanese
    case Sushi
    case Indian
    case Eastern
    case American
    case Thai
    case European
    case Mediterranean
    case Seafood
    case Bar
    case All
    
    static let allTypes = [All, Burgers, Pizza, Coffee, Bakery, IceCream, Mexican, Italian, Chinese, Japanese, Sushi, Indian, Eastern, American, Thai, European, Mediterranean, Seafood, Bar]
}

class CuisineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: CuisineViewControllerDelegate?

    let categories: [String] = CuisineType.allTypes.map { type in
        let uppercased = type.rawValue.uppercaseString
        var finishedString = ""
        for character in uppercased.characters {
            finishedString += "\(character) "
        }
        return finishedString
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cuisineCell", forIndexPath: indexPath) as! CuisineTableViewCell
        
        cell.cuisineLabel.text = categories[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let type = CuisineType.allTypes[indexPath.row]
        delegate?.cuisineTypeSelected(type)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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

enum CuisineType: String {
    
    case Burgers
    case Pizza
    case Coffee
    case Bakeries
    case Mexican
    case Italian
    case Chinese
    case Japanese
    case Sushi
    case Indian
    case American
    case Thai
    case French
    case Greek
    case Seafood
    case Korean
    case Bars
    
    static var allTypes = [Burgers, Pizza, Coffee, Bakeries, Mexican, Italian, Chinese, Japanese, Sushi, Indian, American, Thai, French, Greek, Seafood, Korean, Bars]
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
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
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

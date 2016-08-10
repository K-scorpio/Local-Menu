//
//  CuisineViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 8/9/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

class CuisineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    let categories = ["A L L", "M E X I C A N", "I T A L I A N", "C H I N E S E", "B U R G E R S", "J A P E N E S E", "I N D I A N", "C O F F E E", "T H A I", "G R E E K", "S E A F O O D", "O T H E R"]
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cuisineCell", forIndexPath: indexPath) as! CuisineTableViewCell
        
        cell.cuisineLabel.text = categories[indexPath.row]
        
        return cell
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

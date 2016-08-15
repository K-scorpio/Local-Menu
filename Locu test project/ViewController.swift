//
//  ViewController.swift
//  LocuEx
//
//  Created by Nathan on 7/29/16.
//  Copyright © 2016 Falcone Development. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var restaurantTableView: UITableView!
    
    let restaurant = [Restaurant]()
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UIButton!
    @IBOutlet weak var randomLabel: UIButton!
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        if filterView.hidden == false {
            filterView.hidden = true
            filterLabel.setTitleColor(.grayColor(), forState: .Normal)
        } else if filterView.hidden == true {
            filterView.hidden = false
            filterLabel.setTitleColor(.redColor(), forState: .Normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        RestaurantController.sharedInstance.fetchLocuData { (restaurants) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                RestaurantController.sharedInstance.myRestaurant = restaurants
                self.restaurantTableView.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return RestaurantController.sharedInstance.myRestaurant.count
        return RestaurantController.sharedInstance.myRestaurant.count
        //        return restaurant.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath)
        let restaurant = RestaurantController.sharedInstance.myRestaurant[indexPath.row]
        
        cell.textLabel?.text = restaurant.name
        cell.detailTextLabel?.text = restaurant.menuURL
        print(restaurant.name)
        
        return cell
    }
    
    /*
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let detailViewController = segue.destinationViewController as? DetailViewController
            if segue.identifier == "segue" {
                guard let indexPath = restaurantTableView.indexPathForSelectedRow,
                    restaurant = RestaurantController.sharedInstance.myRestaurant.
            }
        }
    */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


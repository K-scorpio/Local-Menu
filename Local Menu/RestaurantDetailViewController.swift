//
//  RestaurantDetailViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/30/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
    let myRestaurant = [Restaurant]()
    
    var restaurant: Restaurant?

    @IBOutlet weak var myMenu: UIWebView!
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let locuID = restaurant?.locuID else {
            return
        }
        
        let path = NSBundle.mainBundle().pathForResource("widget", ofType: "html")!
        var html = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        
        html = html.stringByReplacingOccurrencesOfString("{venue_id}", withString: "\(locuID)")
        
        myMenu.loadHTMLString(html, baseURL: NSURL(string: "https://locu.com")!)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }

}

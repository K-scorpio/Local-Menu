//
//  RestaurantDetailViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/30/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var iconView: UIView!
    let myRestaurant = [Restaurant]()
    
    var restaurant: Restaurant?

    @IBOutlet weak var myMenu: UIWebView! {
        didSet {
            myMenu.scrollView.delegate = self
        }
    }
    
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
    
    var maxConstraintValue: CGFloat!
//    @IBOutlet weak var webViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var web: NSLayoutConstraint!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        maxConstraintValue = web.constant
        maxConstraintValue = iconsTopConstraint.constant
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        let offset: CGFloat = scrollView.contentOffset.y * 1.5
        guard offset > 0 else { return }
        web.constant = max(20, maxConstraintValue - offset + iconView.frame.height)
        
        iconsTopConstraint.constant = max(20, maxConstraintValue - offset)
    }
    

    
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }

}

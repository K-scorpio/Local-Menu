//
//  RestaurantDetailViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/30/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit
import SafariServices

class RestaurantDetailViewController: UIViewController, UIScrollViewDelegate {
    
    
    let myRestaurant = [Restaurant]()
    var restaurant: Restaurant?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        takeoutIconDisplay()
        wifiIconDisplay()
        reservationIconDisplay()
        noiseLevelIconDisplay()
        alcoholIconDisplay()
        kidFriendlyIconDisplay()
        liveMusicIconDisplay()
        
        guard let locuID = restaurant?.locuID else {
            return
        }
        
        let path = NSBundle.mainBundle().pathForResource("widget", ofType: "html")!
        var html = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        
        html = html.stringByReplacingOccurrencesOfString("{venue_id}", withString: "\(locuID)")
        
        myMenu.loadHTMLString(html, baseURL: NSURL(string: "https://locu.com")!)
        
        
        restaurantNameLabel.text = restaurant?.name
//        hoursOfOperationLabel.text =
//        openClosedNowLabel.text = restaurant.
        dressTypeLabel.text = restaurant?.attire
        restaurantAddressLabel.text = restaurant?.address1
        
        
    }

    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var cuisineBackgroundImage: UIImageView!
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var hoursOfOperationLabel: UILabel!
    @IBOutlet weak var openClosedNowLabel: UILabel!
    @IBOutlet weak var dressTypeLabel: UILabel!
    
    // MARK: - Detail Button outlets:
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var driveButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    
    
    
    @IBOutlet weak var restaurantAddressLabel: UILabel!
    
    
    // MARK: - Icon Outlets and functions:
    
    @IBOutlet weak var wifiIcon: UIImageView!
    @IBOutlet weak var alcoholIcon: UIImageView!
    @IBOutlet weak var kidFriendlyIcon: UIImageView!
    @IBOutlet weak var noiseIcon: UIImageView!
    @IBOutlet weak var takeOutIcon: UIImageView!
    @IBOutlet weak var reservationsIcon: UIImageView!
    @IBOutlet weak var liveMusicIcon: UIImageView!
    
    @IBOutlet weak var wifiUnknown: UIImageView!
    @IBOutlet weak var alcoholUnknown: UIImageView!
    @IBOutlet weak var kidFriendlyUnknown: UIImageView!
    @IBOutlet weak var noiseLevelUnknown: UIImageView!
    @IBOutlet weak var takeoutUnknown: UIImageView!
    @IBOutlet weak var reservationsUnknown: UIImageView!
    @IBOutlet weak var liveMusicUnknown: UIImageView!
    
    func wifiIconDisplay() {
        if restaurant?.wifi != nil {
            if (restaurant?.wifi)! == "free" {
                wifiIcon.image = UIImage(named: "Wifi Icon True")
                wifiUnknown.image = UIImage(named: "Unknown Icon Blank")
            } else if (restaurant?.wifi) == "paid" {
                wifiIcon.image = UIImage(named: "Wifi Icon True")
                wifiUnknown.image = UIImage(named: "Unknown Icon Blank")
            } else if (restaurant?.wifi)! == "no" {
                wifiIcon.image = UIImage(named: "Wifi Icon False")
                wifiUnknown.image = UIImage(named: "Unknown Icon Blank")
            }
        } else {
            wifiIcon.image = UIImage(named: "Wifi Icon False")
        }
    }
    
    func alcoholIconDisplay() {
        if restaurant?.alcohol != nil {
            if (restaurant?.alcohol)! == "beer_and_wine" {
                alcoholIcon.image = UIImage(named: "Alcohol Icon True")
                alcoholUnknown.image = UIImage(named:"Unknown Icon Blank" )
            } else if (restaurant?.alcohol)! == "full_bar" {
                alcoholIcon.image = UIImage(named: "Alcohol Icon True" )
                alcoholUnknown.image = UIImage(named: "Unknown Icon Blank")
            } else if (restaurant?.alcohol)! == "no_alcohol" {
                alcoholIcon.image = UIImage(named: "Alcohol Icon False")
                alcoholUnknown.image = UIImage(named: "Unknown Icon Blank")
            }
        } else {
            alcoholIcon.image = UIImage(named: "Alcohol Icon False")
        }

    }
    
    func kidFriendlyIconDisplay() {
        if restaurant?.goodForKids != nil {
            if (restaurant?.goodForKids)! == true {
                kidFriendlyIcon.image = UIImage(named: "Kid Friendly Icon True")
                kidFriendlyUnknown.image = UIImage(named:"Unknown Icon Blank" )
            } else if (restaurant?.goodForKids)! == false {
                kidFriendlyIcon.image = UIImage(named: "Kid Friendly Icon False")
                kidFriendlyUnknown.image = UIImage(named: "Unknown Icon Blank")
            }
        } else {
            kidFriendlyIcon.image = UIImage(named: "Kid Friendly Icon False")
        }
        
    }
    
    func noiseLevelIconDisplay() {
        if restaurant?.noiseLevel != nil {
            if (restaurant?.noiseLevel)! == "quiet" {
                noiseIcon.image = UIImage(named: "Noise Icon 13")
                noiseLevelUnknown.image = UIImage(named: "Unknown Icon Blank")
            } else if (restaurant?.noiseLevel)! == "typical" {
                noiseIcon.image = UIImage(named: "Noise Icon 23")
                noiseLevelUnknown.image = UIImage(named: "Unknown Icon Blank")
            } else if (restaurant?.noiseLevel)! == "typical" {
                noiseIcon.image = UIImage(named: "Noise Icon 33")
                noiseLevelUnknown.image = UIImage(named: "Unknown Icon Blank")
            }
        } else {
            noiseIcon.image = UIImage(named: "Noise Icon NA")
        }
    }
    //quiet, typical, loud, Noise Icon 13, Noise Icon 23, Noise Icon 33, Noise Icon NA
    func takeoutIconDisplay() {
        
        if restaurant?.takeout != nil {
            if (restaurant?.takeout)! == true {
                takeOutIcon.image = UIImage(named: "Take Out Icon True")
                takeoutUnknown.image = UIImage(named: "Unknown Icon Blank")
            } else if (restaurant?.takeout)! == false {
                takeOutIcon.image = UIImage(named: "Take Out Icon False")
                takeoutUnknown.image = UIImage(named: "Unknown Icon Blank")
            }
        } else {
            takeOutIcon.image = UIImage(named: "Take Out Icon False")
        }

    }
    
    
    func reservationIconDisplay() {
        if restaurant?.reservations != nil {
            if (restaurant?.reservations)! == true {
                reservationsIcon.image = UIImage(named: "Reservation Icon True")
                reservationsUnknown.image = UIImage(named:"Unknown Icon Blank" )
            } else if (restaurant?.reservations)! == false {
                reservationsIcon.image = UIImage(named: "Reservation Icon False")
                reservationsUnknown.image = UIImage(named: "Unknown Icon Blank")
            }
        } else {
            reservationsIcon.image = UIImage(named: "Reservation Icon False")
        }
        
    }
    
    func liveMusicIconDisplay() {
//        if restaurant?.music != nil {
//            if (restaurant?.music)! == true {
//                <#String#>.image = UIImage(named: <#String#>)
//                if <#String#>.hidden == false {
//                    <#String#>.image = UIImage(named: <#String#>)
//                }
//            } else if (restaurant?.<#String#>)! == false {
//                <#String#>.image = UIImage(named: <#String#>)
//                <#String#>.image = UIImage(named: <#String#>)
//            }
//        } else {
//            <#String#>.image = UIImage(named: <#String#>)
//        }
    }
    // dj, live, jukebox, background_music, karaoke, no_music
    
    
    // MARK: - Detail "Call", "Walk", "Drive", "Web" Button Actions:
    
    @IBAction func callButtonTapped(sender: AnyObject) {
        if let phoneNumber = restaurant?.phoneNumber {
        let formatedNumber = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        let phoneUrl = "tel://\(formatedNumber)"
        let url:NSURL = NSURL(string: phoneUrl)!
        UIApplication.sharedApplication().openURL(url)
        } else {
            
            let alert = UIAlertController()
            alert.title = "Sorry! This venue hasen't provided Locu with a phone number."
            alert.message = "Please try again later!"
            let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)

        }
    }
        
    

    @IBAction func walkButtonTapped(sender: AnyObject) {
        guard let latitude = restaurant?.latitude, let longitude = restaurant?.longitude else {
            return
        }
        let url = NSURL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=w")!
        UIApplication.sharedApplication().openURL(url)
    }
  
    @IBAction func driveButtonTapped(sender: AnyObject) {
        guard let latitude = restaurant?.latitude, let longitude = restaurant?.longitude else {
            return
        }
        let url = NSURL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func websiteButtonTapped(sender: AnyObject) {
        
        if let website = restaurant?.websiteURL {
            let url = NSURL(string: website)
            let svc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
            self.presentViewController(svc, animated: true, completion: nil)

            } else {
            
            let alert = UIAlertController()
            alert.title = "Sorry! This venue hasen't provided Locu with a website."
            alert.message = "Please try again later!"
            let okAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)

        }
        
    }
    
    
    // MARK: Menu widget outlet and scroll actions:
    
    @IBOutlet weak var myMenu: UIWebView! {
        didSet {
            myMenu.scrollView.delegate = self
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.y)
        if restaurant?.menuURL == nil {
            return
        } else {
        let offset: CGFloat = scrollView.contentOffset.y * 1.5
        guard offset > 0 else { return }
            // if scroll height is reached { do max val + height difference } else {
        web.constant = max(20, maxConstraintValue - offset + iconView.frame.height)
        
        iconsTopConstraint.constant = max(-98, maxConstraintValue - offset)
        }
    }
    
    // MARK: - Top Navigation Item:
    
//    @IBAction func backButton(sender: AnyObject) {
//        
//        performSegueWithIdentifier("unwindToRestaurantView", sender: self)
//    }
    
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
    
    

    
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }

}

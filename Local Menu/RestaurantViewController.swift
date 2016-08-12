//
//  RestaurantViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/29/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit
import Mapbox
//import MapboxGeocoder
import CoreLocation

class RestaurantViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    var service: RestaurantController!
    
    var isOpen = false
    
    
    let pizzaArray = ["Pizza", "Italian"]
    let sushiArray = ["Sushi", "Japanese"]
    let europeanArray = ["French", "German", "Greek"]
    let easternArray = ["Indian", "Middle Eastern"]
    let latinAmericanArray = ["Brazilian", ""]
    let categoryArray = [/*"Mexican", "Italian", "Chinese", "Burgers", "Japanese", "Indian", "Bakeries", "Coffee", "Thai", "Greek", "French", "German", "Brazilian", "Peruvian", "Salvadorian", "Latin", "Spanish", "Salvadorian", "Spanish", "Bars", "Ice Cream", "Pizza", "Italian", "American", "Middle Eastern", "Sushi"*/]
    
    @IBOutlet weak var restaurantTableView: UITableView!
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UIButton!
    @IBOutlet weak var swipeRightImageView: UIImageView!
    @IBOutlet weak var randomLabel: UIButton!
    @IBOutlet weak var mapAndTableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarField: UISearchBar!
    
    var locuData = [Restaurant]() {
        didSet {
            if mapView != nil {
                updateMap(mapView)
            }
        }
    }
    
    var cuisineType: CuisineType? {
        didSet {
            requestLocuData()
            UIView.animateWithDuration(0.4, delay: 0.3, options: [], animations: {
                self.swipeRightImageView.alpha = 0
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setupMyLocationManager()
        setupMyLocationManager()
        requestLocuData()
        
        
        
        RestaurantController.sharedInstance.searchForRestaurantsByItem("pizza", city: "Salt Lake City") { (restaurants, success) in
            if success {
                print(restaurants.count)
            }
        }
    }
    
    var restaurants: [Restaurant] {
        return RestaurantController.sharedInstance.myRestaurants
    }
    var locationManager: CLLocationManager!
    
    
    var userCurrentLocation: CLLocation? {
        return locationManager.location
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        if isOpen == false {
            searchBarField.searchBarStyle = .Minimal
            isOpen = true
            UIView.animateWithDuration(0.2, delay: 0.3, options: [], animations: {
                self.mapAndTableTopConstraint.constant += 45
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            //            mapAndTableTopConstraint.constant += searchBarField.bounds.height
        } else if isOpen == true {
            isOpen = false
            
            UIView.animateWithDuration(0.2, delay: 0.3, options: [], animations: {
                self.mapAndTableTopConstraint.constant -= 45
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            searchBarField.resignFirstResponder()
            //            mapAndTableTopConstraint.constant -= searchBarField.bounds.height
        }
    }
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        if filterView.hidden == false {
            filterView.hidden = true
            filterLabel.setTitleColor(UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.62, alpha: 1.0), forState: .Normal)
        } else if filterView.hidden == true {
            filterView.hidden = false
            filterLabel.setTitleColor(UIColor.init(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0), forState: .Normal)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isOpen == true {
            isOpen = false
            //            mapAndTableTopConstraint.constant = searchBarField.bounds.height
            UIView.animateWithDuration(0.2, delay: 0.3, options: [], animations: {
                self.mapAndTableTopConstraint.constant -= 45
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        searchBarField.resignFirstResponder()
    }
    
    func updateMap(mapView:MGLMapView){
        if let annotations = mapView.annotations {
            for a in annotations {
                mapView.removeAnnotation(a)
                mapView.addAnnotation(a)
                mapView.showAnnotations(a as! [MGLAnnotation], animated: false)
            }
        }
    }
    
    func requestLocuData() {
        
        if mapView.annotations != nil {
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations!)
            restaurantTableView.reloadData()
        }
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
        mapView.delegate = self
        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        guard let type = cuisineType else { return }
         if type == .European {
            europeanRequest()
        } else if type == .Sushi {
            sushiRequest()
        } else if type == .Pizza {
            pizzaRequest()
        } else {
            RestaurantController.sharedInstance.fetchRestaurantsForCategory(type, location: center, completion: { (restaurants, success) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.restaurantTableView.reloadData()
                })
                var annotations = [MGLAnnotation]()
                let group = dispatch_group_create()
                for myRestaurant in restaurants {
                    dispatch_group_enter(group)
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
                    point.title = myRestaurant.name
                    point.subtitle = myRestaurant.address1
                    
                    annotations.append(point)
                    dispatch_group_leave(group)
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    self.mapView.addAnnotations(annotations)
                    
                })
            })
        }
        
        //        func initialRequest() {
        //            self.swipeRightImageView.hidden = false
        //            mapView.showsUserLocation = true
        //            mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
        //            mapView.delegate = self
        //            let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
        //            mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        //            for category in categoryArray {
        //                RestaurantController.sharedInstance.initialFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
        //                    dispatch_async(dispatch_get_main_queue(), {
        //                        self.restaurantTableView.reloadData()
        //                    })
        //                    var annotations = [MGLAnnotation]()
        //                    let group = dispatch_group_create()
        //                    for myRestaurant in restaurants {
        //                        dispatch_group_enter(group)
        //                        let point = MGLPointAnnotation()
        //                        point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
        //                        point.title = myRestaurant.name
        //                        point.subtitle = myRestaurant.address1
        //
        //                        annotations.append(point)
        //                        dispatch_group_leave(group)
        //                    }
        //                    dispatch_group_notify(group, dispatch_get_main_queue(), {
        //                        self.mapView.addAnnotations(annotations)
        //
        //                    })
        //                }
        //            }
        //        }
    }
    
//    func easternRequest() {
//        self.swipeRightImageView.hidden = false
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
//        mapView.delegate = self
//        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
//        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
//        for category in easternArray {
//            RestaurantController.sharedInstance.easternFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.restaurantTableView.reloadData()
//                })
//                var annotations = [MGLAnnotation]()
//                let group = dispatch_group_create()
//                for myRestaurant in restaurants {
//                    dispatch_group_enter(group)
//                    let point = MGLPointAnnotation()
//                    point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
//                    point.title = myRestaurant.name
//                    point.subtitle = myRestaurant.address1
//                    
//                    annotations.append(point)
//                    dispatch_group_leave(group)
//                }
//                dispatch_group_notify(group, dispatch_get_main_queue(), {
//                    self.mapView.addAnnotations(annotations)
//                    
//                })
//            }
//        }
//    }
    
    
    func europeanRequest() {
        self.swipeRightImageView.hidden = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
        mapView.delegate = self
        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        for category in europeanArray {
            RestaurantController.sharedInstance.europeanFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.restaurantTableView.reloadData()
                })
                var annotations = [MGLAnnotation]()
                let group = dispatch_group_create()
                for myRestaurant in restaurants {
                    dispatch_group_enter(group)
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
                    point.title = myRestaurant.name
                    point.subtitle = myRestaurant.address1
                    
                    annotations.append(point)
                    dispatch_group_leave(group)
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    self.mapView.addAnnotations(annotations)
                    
                })
            }
        }
    }
    
    
    func sushiRequest() {
        self.swipeRightImageView.hidden = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
        mapView.delegate = self
        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        for category in sushiArray {
            RestaurantController.sharedInstance.sushiFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.restaurantTableView.reloadData()
                })
                var annotations = [MGLAnnotation]()
                let group = dispatch_group_create()
                for myRestaurant in restaurants {
                    dispatch_group_enter(group)
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
                    point.title = myRestaurant.name
                    point.subtitle = myRestaurant.address1
                    
                    annotations.append(point)
                    dispatch_group_leave(group)
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    self.mapView.addAnnotations(annotations)
                    
                })
            }
        }
    }
    
    func pizzaRequest() {
        self.swipeRightImageView.hidden = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
        mapView.delegate = self
        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        for category in pizzaArray {
            RestaurantController.sharedInstance.pizzaFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.restaurantTableView.reloadData()
                })
                var annotations = [MGLAnnotation]()
                let group = dispatch_group_create()
                for myRestaurant in restaurants {
                    dispatch_group_enter(group)
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
                    point.title = myRestaurant.name
                    point.subtitle = myRestaurant.address1
                    
                    annotations.append(point)
                    dispatch_group_leave(group)
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), {
                    self.mapView.addAnnotations(annotations)
                    
                })
            }
        }
    }
    
    
    
    
    //    let center = CLLocationCoordinate2D(latitude: userCurrentLocation.coordinate.latitude, longitude: userCurrentLocation.coordinate.longitude)
    //    let region = MGLCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    //-----------------------------
    
    func setupMyLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
    }
    
    func myLocationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("present location : \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
    }
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRectMake(0, 40, 20, 20)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            _ = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: 0.02, saturation: 0.93, brightness: 0.53, alpha: 1)
        }
        
        return annotationView
    }
    
    // MGLAnnotationView subclass
    class CustomAnnotationView: MGLAnnotationView {
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Force the annotation view to maintain a constant size when the map is tilted.
            scalesWithViewingDistance = false
            
            // Use CALayer’s corner radius to turn this view into a circle.
            layer.cornerRadius = frame.width / 2
            layer.borderWidth = 2
            layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        override func setSelected(selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Animate the border width in/out, creating an iris effect.
            let animation = CABasicAnimation(keyPath: "borderWidth")
            animation.duration = 0.1
            layer.borderWidth = selected ? frame.width / 4 : 2
            layer.addAnimation(animation, forKey: "borderWidth")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //                return RestaurantController.sharedInstance.myRestaurants.count
        return restaurants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as! RestaurantTableViewCell
        let restaurant = restaurants[indexPath.row]
        
        //        cell.textLabel?.text = restaurant.name
        
        cell.restaurantNameLabel.text = restaurant.name
        //        cell.restaurantDistanceLabel.text
        //        cell.restaurantTypeLabel.text
        cell.restaurantTypeLabel.text = restaurant.categoryName
        if restaurant.menuURL != nil {
            cell.restaurantMenuLabel.text = "M E N U"
        } else {
            cell.restaurantMenuLabel?.text = ""
        }
        
        print(restaurant.name)
        //        print("\(restaurant.address1) \(restaurant.locality), \(restaurant.region) \(restaurant.postalCode)")
        //        print("wifi: \(restaurant.wifi) \n alcohol \(restaurant.alcohol) \n kid Friendly \(restaurant.goodForKids) \n noise level \(restaurant.noiseLevel) \n takeout \(restaurant.takeout) \n reservations \(restaurant.reservations) \n music \(restaurant.music) \n high range \(restaurant.highRange) \n low range \(restaurant.lowRange)")
        //        print("price \(restaurant.prices)")
        print(restaurant.takeout)
        print("Reservation \(restaurant.reservations)")
        print("Music \(restaurant.music)")
        print("Wifi \(restaurant.wifi)")
        print("Category: \(restaurant.categoryName)")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - Navigation
    
    //    enum toggledDrawer {
    //        case toggled
    //    }
    
    @IBAction func cuisineButtonTapped(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToRestaurantView(segue: UIStoryboardSegue) {
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailViewController = segue.destinationViewController as? RestaurantDetailViewController
        if segue.identifier == "toRestaurantDetail" {
            guard let indexPath = restaurantTableView.indexPathForSelectedRow,
                let restaurant = RestaurantController.sharedInstance.myRestaurants[indexPath.row] as? Restaurant else {return}
            detailViewController?.restaurant = restaurant
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}

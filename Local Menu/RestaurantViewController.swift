//
//  RestaurantViewController.swift
//  Local Menu
//
//  Created by Kevin Hartley on 7/29/16.
//  Copyright © 2016 Rum & Burbon Development. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder
import CoreLocation

class RestaurantViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    var service: RestaurantController!
    
    var restaurant: Restaurant?
    
    var isOpen = false
    
    let geocoder = Geocoder.sharedGeocoder
    
    var isInitialView = true
    
    let categoryArray = [/*"Mexican", "Italian", "Chinese", "Burgers", "Japanese", "Indian", "Bakeries", "Coffee", "Thai", "Greek", "French", "German", "Brazilian", "Peruvian", "Salvadorian", "Latin", "Spanish", "Salvadorian", "Spanish", "Bars", "Ice Cream", "Pizza", "Italian", "American", "Middle Eastern", "Sushi"*/]
    
    @IBOutlet weak var restaurantTableView: UITableView!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UIButton!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var filterViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var allCuisineLabel: UILabel!
    @IBOutlet weak var onlyMenusLabel: UILabel!
    @IBOutlet weak var allCuisineButton: UIButton!
    @IBOutlet weak var onlyMenusButton: UIButton!
    
    
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
            isInitialView = false
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setupMyLocationManager()
        setupMyLocationManager()
        requestLocuData()
        setUpSliderValues()
        filterView.hidden = false
        
        if isOpen == true {
            resignFirstResponder()
        }
        
        //        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //        appDelegate.centerContainer?.centerHiddenInteractionMode
        
        //        if appDelegate.centerContainer?.centerViewController
        
        RestaurantController.sharedInstance.searchForRestaurantsByItem("pizza", city: "Salt Lake City") { (restaurants, success) in
            if success {
                print(restaurants.count)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer?.openDrawerGestureModeMask = .All
    }
    
    var restaurants: [Restaurant] {
        return RestaurantController.sharedInstance.myRestaurants
    }
    
    //    var filteredRestaurants: [Restaurant] {
    //        for restaurant in restaurants {
    //        if restaurant.menuURL != nil {
    //            return RestaurantController.sharedInstance.myRestaurants
    //            }
    //        }
    //     return restaurants
    //    }
    
    //    func filterRestaurants() -> [Restaurant] {
    //        return restaurants.filter { $0.menuURL != nil }
    //    }
    var filteredRestaurants: [Restaurant] {
        //        let menurestaurant
        return RestaurantController.sharedInstance.myRestaurants.filter { $0.menuURL != nil }
    }
    
    var locationManager: CLLocationManager!
    
    var userCurrentLocation: CLLocation? {
        // var postsearch = false unless searching happens, then locationManager.location = coordinates of searchBarField.text
        return locationManager.location
    }
    
    func restaurantDistance(restaurant: Restaurant) -> Double {
        let latitude = restaurant.latitude
        let longitude = restaurant.longitude
        let loc = CLLocation(latitude: (userCurrentLocation?.coordinate.latitude)!, longitude: (userCurrentLocation?.coordinate.longitude)!)
        let distance = loc.distanceFromLocation(CLLocation(latitude: latitude, longitude: longitude))
        print(distance)
        return distance
    }
    
    func setUpSliderValues() {
        
        filterView.alpha = 0
        filterViewBottomConstraint.constant = -30
        allCuisineLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
        allCuisineLabel.layer.backgroundColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
        allCuisineLabel.textColor = UIColor.blackColor()
        onlyMenusLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
        onlyMenusLabel.layer.borderWidth = 3
        
        distanceSlider.minimumValue = 160.934
        distanceSlider.maximumValue = 8046.72
        if isInitialView == true {
            distanceSlider.value = 3218.69
            distanceLabel.text = "2.0mi"
        } else {
            return
        }
    }
    
    // okay, so i want to know when the slider is sliding, and update label thats converting meters to miles. then after i let go of the slider, i want to make a network request with the last value the slider was at.
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //        guard let searchTerm = searchBar.text else {
        //            return
        //        }
        //        RestaurantController.sharedInstance.searchForRestaurantsByItem(searchTerm, city: "Salt Lake City") { (restaurants) in
        //            self. = restaurants
        //            dispatch_async(dispatch_get_main_queue(), {
        //                if restaurants.count > 0 {
        //                    self.tableView.reloadData()
        //                } else {
        //                    self.noResultsFound()
        //                }
        //            })
        //        }
    }
    
    @IBAction func distanceSliderChanged(sender: AnyObject) {
        distanceSlider.minimumValue = 160.934
        distanceSlider.maximumValue = 8046.72
        let rawDistance = distanceSlider.value
        let milesDistance = rawDistance * 0.000621371
        let roundedMiles = String(format: "%.1f", milesDistance)
        distanceLabel.text = "\(roundedMiles)mi"
    }
    
    @IBAction func distanceSliderEndedChange(sender: AnyObject) {
        requestLocuData()
    }
    
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        if filterViewHasDissapeared == false {
            //IF THE FILTER IS SHOWING, THEN:
            hideFilterView()
        }
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
    
    @IBAction func cuisineButtonTapped(sender: AnyObject) {
        if filterViewHasDissapeared == false {
            //IF THE FILTER IS SHOWING, THEN:
            hideFilterView()
        }
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        if isOpen == true {
            isOpen = false
            
            UIView.animateWithDuration(0.2, delay: 0.3, options: [], animations: {
                self.mapAndTableTopConstraint.constant -= 45
                self.view.layoutIfNeeded()
                }, completion: nil)
            
            searchBarField.resignFirstResponder()
            //            mapAndTableTopConstraint.constant -= searchBarField.bounds.height
        }
    }
    
    @IBAction func dismissKeyboardTapGesture(sender: AnyObject) {
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
    
    @IBAction func closeDrawerTapGesture(sender: AnyObject) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //        appDelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        appDelegate.centerContainer?.closeDrawerAnimated(true, completion: nil)
    }
    
    
    //-----------------------------------//
    
    // my initial view's alpha is 0
    // if my view is hidden when button tapped: ---> unhide and animate to alpha of 1
    // if my view is not hidden when button tapped: ---> first animate to alpha of 0 and then hide
    
    
    
    func hideFilterView() {
        filterViewHasDissapeared = true
        UIView.animateWithDuration(0.2, delay: 0.1, options: [], animations: {
            self.filterView.alpha = 0.0
            self.filterViewBottomConstraint.constant += 30
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        filterLabel.setTitleColor(UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.62, alpha: 1.0), forState: .Normal)
    }
    
    func unhideFilterView() {
        filterViewHasDissapeared = false
        UIView.animateWithDuration(0.2, delay: 0.1, options: [], animations: {
            self.filterView.alpha = 1.0
            self.filterViewBottomConstraint.constant -= 30
            self.view.layoutIfNeeded()
            }, completion: nil)
        filterLabel.setTitleColor(UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.62, alpha: 1.0), forState: .Normal)
    }
    
    var filterViewHasDissapeared = true
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        if isInitialView == true {
            return
        } else {
            if filterViewHasDissapeared == false {
                hideFilterView()
            } else if filterViewHasDissapeared == true {
                unhideFilterView()
            }
        }
    }
    
    var allCuisineSelected = true
    
    @IBAction func allCuisineButtonTapped(sender: AnyObject) {
        allCuisineSelected = true
        UIView.animateWithDuration(0.5, animations: {
            self.allCuisineLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
            self.allCuisineLabel.layer.backgroundColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
            self.allCuisineLabel.textColor = UIColor.blackColor()
            self.onlyMenusLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
            self.onlyMenusLabel.layer.backgroundColor = UIColor.clearColor().CGColor
            self.onlyMenusLabel.layer.borderWidth = 3
            self.onlyMenusLabel.textColor = UIColor.grayColor()
        })
        requestLocuData()
        restaurantTableView.reloadInputViews()
    }
    
    @IBAction func onlyMenusButtonTapped(sender: AnyObject) {
        allCuisineSelected = false
        UIView.animateWithDuration(0.5, animations: {
            self.onlyMenusLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
            self.onlyMenusLabel.layer.backgroundColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
            self.onlyMenusLabel.textColor = UIColor.blackColor()
            self.allCuisineLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
            self.allCuisineLabel.layer.backgroundColor = UIColor.clearColor().CGColor
            self.allCuisineLabel.layer.borderWidth = 3
            self.allCuisineLabel.textColor = UIColor.grayColor()
        })
        requestLocuData()
        restaurantTableView.reloadInputViews()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if filterViewHasDissapeared == false {
            hideFilterView()
        }
        if isOpen == true {
            isOpen = false
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
        if type != cuisineType {
            return
        } else {
            if allCuisineSelected == true {
                RestaurantController.sharedInstance.fetchRestaurantsForCategory(type, distance: distanceSlider.value, location: center, completion: { (restaurants, success) in
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
            } else if allCuisineSelected == false {
                RestaurantController.sharedInstance.fetchRestaurantsForCategory(type, distance: distanceSlider.value, location: center, completion: { (restaurants, success) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.restaurantTableView.reloadData()
                    })
                    var annotations = [MGLAnnotation]()
                    let group = dispatch_group_create()
                    for myRestaurant in self.filteredRestaurants {
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
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allCuisineSelected == true {
            return restaurants.count
        } else if allCuisineSelected == false {
            return filteredRestaurants.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as! RestaurantTableViewCell
        if allCuisineSelected == true {
            let restaurant = restaurants[indexPath.row]
            if restaurant.menuURL != nil {
                cell.hidden = false
                cell.restaurantMenuLabel.text = "M E N U"
            } else {
                cell.restaurantMenuLabel?.text = ""
            }
            let distance = restaurantDistance(restaurant)
            let roundedDistance = round(distance)
            let milesDistance = roundedDistance * 0.000621371
            let roundedMiles = String(format: "%.1f", milesDistance)
            cell.restaurantNameLabel.text = restaurant.name
            cell.restaurantDistanceLabel.text = "\(roundedMiles) mi"
            cell.restaurantTypeLabel.text = "Distance:"
        } else if allCuisineSelected == false {
            let restaurant = filteredRestaurants[indexPath.row]
            if restaurant.menuURL != nil {
                cell.restaurantMenuLabel.text = "M E N U"
                cell.restaurantNameLabel.text = restaurant.name
                let distance = restaurantDistance(restaurant)
                let roundedDistance = round(distance)
                let milesDistance = roundedDistance * 0.000621371
                let roundedMiles = String(format: "%.1f", milesDistance)
                cell.restaurantDistanceLabel.text = "\(roundedMiles) mi"
                cell.restaurantTypeLabel.text = "Distance:"
            } else {
                return cell
            }
            print(restaurant.name)
            print(restaurant.menuURL)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as! RestaurantTableViewCell
        if let cellTitle = cell.restaurantNameLabel.text {
            print("User tapped on annotation with title: \(cellTitle)")
        }
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotationView annotationView: MGLAnnotationView) {
        if let annotationTitle = annotationView.annotation?.title {
            print("User tapped on annotation with title: \(annotationTitle!)")
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToRestaurantView(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailViewController = segue.destinationViewController as? RestaurantDetailViewController
        if segue.identifier == "toRestaurantDetail" {
            guard let indexPath = restaurantTableView.indexPathForSelectedRow else { return }
            if allCuisineSelected == true {
                guard let restaurant = restaurants[indexPath.row] as? Restaurant else { return }
                detailViewController?.restaurant = restaurant
            } else if allCuisineSelected == false {
                guard let restaurant = filteredRestaurants[indexPath.row] as? Restaurant else {return}
                detailViewController?.restaurant = restaurant
            }
        }
        if isInitialView == true {
            return
        } else if segue.identifier == "toDetailFromRandom" {
            if allCuisineSelected == true {
                let randomIndex = Int(arc4random_uniform(UInt32(restaurants.count)))
                let indexPath = randomIndex
                guard let restaurant = restaurants[indexPath] as? Restaurant else { return }
                detailViewController?.restaurant = restaurant
            } else if allCuisineSelected == false {
                let randomIndex = Int(arc4random_uniform(UInt32(filteredRestaurants.count)))
                let indexPath = randomIndex
                guard let restaurant = filteredRestaurants[indexPath] as? Restaurant else {return}
                detailViewController?.restaurant = restaurant
            }
        }
    }
}

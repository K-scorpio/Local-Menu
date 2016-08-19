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
        //        filterView.hidden = true
        //        filterLeftConstraint.constant += 600
    }
    
    func unhideFilterView() {
        
        filterViewHasDissapeared = false
        //        filterView.hidden = false
        UIView.animateWithDuration(0.2, delay: 0.1, options: [], animations: {
            self.filterView.alpha = 1.0
            self.filterViewBottomConstraint.constant -= 30
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        filterLabel.setTitleColor(UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.62, alpha: 1.0), forState: .Normal)
    }
    
    //-----------------------------------//
    
    var filterViewHasDissapeared = true
    
    @IBAction func filterButtonTapped(sender: AnyObject) {
        if isInitialView == true {
            return
        } else {
            if filterViewHasDissapeared == false {
                //IF THE FILTER IS SHOWING, THEN:
                hideFilterView()
            } else if filterViewHasDissapeared == true {
                //IF THE FILTER IS NOT SHOWING, THEN:
                unhideFilterView()
            }
        }
    }
    
    var allCuisineSelected = true
    
    @IBAction func allCuisineButtonTapped(sender: AnyObject) {
        if allCuisineSelected == false {
            UIView.animateWithDuration(0.5, animations: {
                self.allCuisineLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
                self.allCuisineLabel.layer.backgroundColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
                self.allCuisineLabel.textColor = UIColor.blackColor()
                self.onlyMenusLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
                self.onlyMenusLabel.layer.backgroundColor = UIColor.clearColor().CGColor
                self.onlyMenusLabel.layer.borderWidth = 3
                self.onlyMenusLabel.textColor = UIColor.grayColor()
            })
            allCuisineSelected = true
            requestLocuData()
        } else {
            return
        }
    }
    
    @IBAction func onlyMenusButtonTapped(sender: AnyObject) {
        if allCuisineSelected == true {
            UIView.animateWithDuration(0.5, animations: {
                self.onlyMenusLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
                self.onlyMenusLabel.layer.backgroundColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
                self.onlyMenusLabel.textColor = UIColor.blackColor()
                self.allCuisineLabel.layer.borderColor = UIColor(hue: 0.09, saturation: 0.44, brightness: 0.55, alpha: 1.0).CGColor
                self.allCuisineLabel.layer.backgroundColor = UIColor.clearColor().CGColor
                self.allCuisineLabel.layer.borderWidth = 3
                self.allCuisineLabel.textColor = UIColor.grayColor()
            })
            allCuisineSelected = false
            requestLocuData()
        } else {
            return
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if filterViewHasDissapeared == false {
            //IF THE FILTER IS SHOWING, THEN:
            hideFilterView()
        }
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
        if type != cuisineType {
            return
        } else {
//            if allCuisineSelected == false { // I believe here we need to say manuURL is optional yes. I think we can add that code here.
                // I mean, there's gotta be multiple ways to do this... but, I think instead of doing either of these options, we should just take the current data that comes in from a network request and filter that to only show the menuURLs. I'm almost done doing that in cellForRowAtIndexPath.. can i show you that quick?For sure
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
//            } else { //Somehow here we need to say that the menuURL is the menuURL
//                RestaurantController.sharedInstance.fetchRestaurantsForCategory(type, distance: distanceSlider.value, location: center, completion: { (restaurants, success) in
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
//                })
//                
//            }
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
    
    
    //    func europeanRequest() {
    //        self.swipeRightImageView.hidden = false
    //        mapView.showsUserLocation = true
    //        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
    //        mapView.delegate = self
    //        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
    //        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
    //        for category in europeanArray {
    //            RestaurantController.sharedInstance.europeanFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
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
    //
    //
    //    func sushiRequest() {
    //        self.swipeRightImageView.hidden = false
    //        mapView.showsUserLocation = true
    //        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
    //        mapView.delegate = self
    //        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
    //        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
    //        for category in sushiArray {
    //            RestaurantController.sharedInstance.sushiFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
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
    //
    //    func pizzaRequest() {
    //        self.swipeRightImageView.hidden = false
    //        mapView.showsUserLocation = true
    //        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
    //        mapView.delegate = self
    //        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
    //        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
    //        for category in pizzaArray {
    //            RestaurantController.sharedInstance.pizzaFetchRestaurantsForAll(category, location: center) { (restaurants, success) in
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
    
    
    //haha so much green ^
    
    
    
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
        
        //-------------------------------------------------------------------//
        
        //up here it works, it displays all the cells and if they have menu's or not
        if allCuisineSelected == true {
            if restaurant.menuURL != nil {
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
        } else {
            if restaurant.menuURL != nil {
                //so here, we are saying if the allCuisine button is not selected (meaning that the onlyMenus button is selected) that we should filter that...
                //so  for some weird reason, right here it's not filtering correctly and I feel like i've just been staring at this too long hahaha
                // OH NO! ^ Ok. Let me take a quick look and orient myself with this.
                // if it's cool, they are showing all the projects right now upstairs. could we possibly resume this like later tonight or tomorrow or something? I can push this over to you and you can check it out while it's going on?  Yea. Push it. We can play it by ear tonight or tomorrow. 
                //Rad, catch ya later! Peach brotha
                cell.restaurantMenuLabel.text = "M E N U" //hahahabib
                // i dont know how to tell it to not return
                //cells that dont have a menuURL.
                // I should probably do a SORT function or something
                //but i'm stuck... IDK man...
                let distance = restaurantDistance(restaurant)
                let roundedDistance = round(distance)
                let milesDistance = roundedDistance * 0.000621371
                let roundedMiles = String(format: "%.1f", milesDistance)
                cell.restaurantNameLabel.text = restaurant.name
                cell.restaurantDistanceLabel.text = "\(roundedMiles) mi"
                cell.restaurantTypeLabel.text = "Distance:"
            }
            
            // if menuURL has something in it, let the restaurant cell be full of stuff.
            
        }
        
        //-------------------------------------------------------------------//
        
        
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
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as! RestaurantTableViewCell
        //        let restaurant = restaurants[indexPath.row]
        
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
    
    //    enum toggledDrawer {
    //        case toggled
    //    }
    
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

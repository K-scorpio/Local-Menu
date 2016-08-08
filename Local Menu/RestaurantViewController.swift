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
    //Populate with a prepare for segue.
    let categoryArray = ["Mexican", "Italian", "Chinese", "Burgers", "Japanese", "Indian", "Bakery", "Coffee", "Thai", "Greek"]
    
    @IBOutlet weak var restaurantTableView: UITableView!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    var locuData = [Restaurant]() {
        didSet {
            if mapView != nil {
                updateMap(mapView)
            }
        }
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
    
    var restaurants: [Restaurant] {
        return RestaurantController.sharedInstance.myRestaurants
    }
    var locationManager: CLLocationManager!
    
    
    var userCurrentLocation: CLLocation? {
        return locationManager.location
    }
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterLabel: UIButton!
    @IBOutlet weak var randomLabel: UIButton!
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBAction func searchButtonPressed(sender: AnyObject) {
        if searchBarField.hidden == true {
            searchBarField.hidden = false
        } else {
            searchBarField.hidden = true
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
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setupMyLocationManager()
        setupMyLocationManager()
        requestLocuData()
        
        // Do any additional setup after loading the view.
        
        //-------------------------
    }
    
    var service: RestaurantController!
    
    func requestLocuData() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MGLUserTrackingMode(rawValue: 2)!
        mapView.delegate = self
        let center = CLLocationCoordinate2DMake(userCurrentLocation?.coordinate.latitude ?? 0.0, userCurrentLocation?.coordinate.longitude ?? 0.0)
        mapView.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        
<<<<<<< Updated upstream
        let fetchRestaurantsGroup = dispatch_group_create()
=======
        //-------------------------
        RestaurantController.sharedInstance.fetchLocuData(center) { (restaurants) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                RestaurantController.sharedInstance.myRestaurant = restaurants
                // for restaurant in [restaurant] add a point. let the title = restaurant.title let subtitle = restaurant.streetAddress1
                
                for myRestaurant in self.restaurants {
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
                    point.title = myRestaurant.name
                    point.subtitle = myRestaurant.address1
//                    let happy = "\(point.coordinate.longitude)"
//                    let annotation = self.mapView.dequeueReusableAnnotationViewWithIdentifier(happy)
//                    
//                    func customMap(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
//                    annotation.backgroundColor = UIColor.blueColor()
//                    }

>>>>>>> Stashed changes

        for category in categoryArray {
            dispatch_group_enter(fetchRestaurantsGroup)
            RestaurantController.sharedInstance.fetchRestaurantsForCategory(category, location: center) { (success) in
                
                if success {
                    dispatch_group_leave(fetchRestaurantsGroup)
                }
            }
        }
        
        dispatch_group_notify(fetchRestaurantsGroup, dispatch_get_main_queue(), {
            RestaurantController.sharedInstance.myRestaurants = RestaurantController.sharedInstance.myRestaurants
            // for restaurant in [restaurant] add a point. let the title = restaurant.title let subtitle = restaurant.streetAddress1
            
            for myRestaurant in self.restaurants {
                let point = MGLPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: myRestaurant.latitude, longitude: myRestaurant.longitude)
                point.title = myRestaurant.name
                point.subtitle = myRestaurant.address1
                
                self.mapView.addAnnotation(point)
            }
            self.restaurantTableView.reloadData()
        })
    }
    
       //    let center = CLLocationCoordinate2D(latitude: userCurrentLocation.coordinate.latitude, longitude: userCurrentLocation.coordinate.longitude)
    //    let region = MGLCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
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
            annotationView!.frame = CGRectMake(0, 40, 27, 27)
            
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
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath)
        let restaurant = restaurants[indexPath.row]
        
        cell.textLabel?.text = restaurant.name
        
        if restaurant.menuURl != nil {
            cell.detailTextLabel?.text = "MENU"
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        print(restaurant.name)
        //        print("\(restaurant.address1) \(restaurant.locality), \(restaurant.region) \(restaurant.postalCode)")
        //        print("wifi: \(restaurant.wifi) \n alcohol \(restaurant.alcohol) \n kid Friendly \(restaurant.goodForKids) \n noise level \(restaurant.noiseLevel) \n takeout \(restaurant.takeout) \n reservations \(restaurant.reservations) \n music \(restaurant.music) \n high range \(restaurant.highRange) \n low range \(restaurant.lowRange)")
        //        print("price \(restaurant.prices)")
        
        
        return cell
    }
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        <#code#>
    //    }
    
    
    // MARK: - Navigation
    
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

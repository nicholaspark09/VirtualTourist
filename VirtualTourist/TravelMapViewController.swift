//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/10/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {

    struct Constants{
        static let MapCenterLatitudeKey = "MapCenterLatitude"
        static let MapCenterLongitudeKey = "MapCenterLongitude"
        static let MapCenterLatDeltaKey = "MapLatitudeDelta"
        static let MapCenterLongDeltaKey = "MapLongitudeDelta"
    }
    
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //Check to see if there's already things set up
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let savedLatitude = userDefaults.valueForKey(Constants.MapCenterLatitudeKey) as? Double{
            let savedLongitude = userDefaults.valueForKey(Constants.MapCenterLongitudeKey) as! Double
            let savedLatDelta = userDefaults.valueForKey(Constants.MapCenterLatDeltaKey) as! Double
            let savedLongDelta = userDefaults.valueForKey(Constants.MapCenterLongDeltaKey) as! Double
            let span = MKCoordinateSpan(latitudeDelta: savedLatDelta, longitudeDelta: savedLongDelta)
            let center = CLLocationCoordinate2D(latitude: savedLatitude, longitude: savedLongitude)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            print("found a saved lat of : \(savedLatitude)")
        }else{
            print("Couldn't find anything")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("You are disappearing...")
        //Save the map's center location
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(mapView.region.center.latitude, forKey: Constants.MapCenterLatitudeKey)
        userDefaults.setValue(mapView.region.center.longitude, forKey: Constants.MapCenterLongitudeKey)
        userDefaults.setValue(mapView.region.span.longitudeDelta, forKey: Constants.MapCenterLongDeltaKey)
        userDefaults.setValue(mapView.region.span.latitudeDelta, forKey: Constants.MapCenterLatDeltaKey)
        userDefaults.synchronize()
        print("Saving the center as \(mapView.region.center.latitude)")
    }


}


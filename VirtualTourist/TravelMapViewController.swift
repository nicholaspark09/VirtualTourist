//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/10/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import MapKit

@objc protocol TravelMapProtocol{
    func appToBackground()
}

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    struct Constants{
        static let MapCenterLatitudeKey = "MapCenterLatitude"
        static let MapCenterLongitudeKey = "MapCenterLongitude"
        static let MapCenterLatDeltaKey = "MapLatitudeDelta"
        static let MapCenterLongDeltaKey = "MapLongitudeDelta"
        static let PinReuseIdentifier = "Pin"
    }
    
    
    @IBAction func mapHeld(sender: UILongPressGestureRecognizer) {
        
        let point = sender.locationOfTouch(0, inView:mapView)
        let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    @IBOutlet var mapView: MKMapView!{
        didSet{
            mapView!.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TravelMapProtocol.appToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
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
        super.viewWillDisappear(true)
        
    }
    
    func appToBackground(){
        //GO ahead and remove notification and save data
        print("Disappearing")
        saveMapData()
    }
    
    // MARK: SaveMapData - Save relevant coordinates into nsuserdefaults
    func saveMapData(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(mapView.region.center.latitude, forKey: Constants.MapCenterLatitudeKey)
        userDefaults.setValue(mapView.region.center.longitude, forKey: Constants.MapCenterLongitudeKey)
        userDefaults.setValue(mapView.region.span.longitudeDelta, forKey: Constants.MapCenterLongDeltaKey)
        userDefaults.setValue(mapView.region.span.latitudeDelta, forKey: Constants.MapCenterLatDeltaKey)
        userDefaults.synchronize()
        print("Saving the center as \(mapView.region.center.latitude)")
    }
    
    // MARK: MapViewDelegates 
    // MARK: - MKMapViewDelegate Add Pin to MapView
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.PinReuseIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.PinReuseIdentifier)
            //pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //let app = UIApplication.sharedApplication()
            
        }
    }
    
    /*override func viewWillDisappear(animated: Bool) {
        print("You are disappearing...")
        //Save the map's center location
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(mapView.region.center.latitude, forKey: Constants.MapCenterLatitudeKey)
        userDefaults.setValue(mapView.region.center.longitude, forKey: Constants.MapCenterLongitudeKey)
        userDefaults.setValue(mapView.region.span.longitudeDelta, forKey: Constants.MapCenterLongDeltaKey)
        userDefaults.setValue(mapView.region.span.latitudeDelta, forKey: Constants.MapCenterLatDeltaKey)
        userDefaults.synchronize()
        print("Saving the center as \(mapView.region.center.latitude)")
                super.viewWillDisappear(animated)
    }
 */


}


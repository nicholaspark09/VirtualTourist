//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/10/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import MapKit
import CoreData

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
        static let PhotoAlbumSegue = "PhotoAlbum Segue"
        static let PinIdKey = "PinIDKey"
    }
    
    // MARK: SharedInstance of CoreDataStackManager
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var pins = [Pin]()

    
    
    @IBAction func mapHeld(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended{
            let point = sender.locationOfTouch(0, inView:mapView)
            let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //Add the point to the local DB First
            let dictionary: [String:AnyObject] = [
                Pin.Keys.Latitude : coordinate.latitude,
                Pin.Keys.Longitude : coordinate.longitude,
                Pin.Keys.Created : NSDate()
            ]
            let pin = Pin(dictionary: dictionary, context: sharedContext)
            
            CoreDataStackManager.sharedInstance().saveContext()
            //Add the object id into the annotation
            annotation.subtitle = pin.objectID.URIRepresentation().absoluteString
            mapView.addAnnotation(annotation)
            //Start loading the photos
        }
        
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
        
        pins = indexPins()
        print("The length of pins is \(pins.count)")
        addPinsToView()
    }
    
    
    
    
    
    /**     Add the pins to the map after loading them from CoreData
    *
    *
    */
    func addPinsToView(){
        for pin in pins{
            let lat = pin.latitude!.doubleValue
            let long = pin.longitude!.doubleValue
            let coordinate = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.subtitle = pin.objectID.URIRepresentation().absoluteString
            mapView.addAnnotation(annotation)
        }
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
        }
    }
    
    
    func appToBackground(){
        //GO ahead and remove notification and save data
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
    }
    
    // MARK: MapViewDelegates 
    // MARK: - MKMapViewDelegate Add Pin to MapView
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.PinReuseIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.PinReuseIdentifier)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("YOu selected a pin")
        if let absoluteString = view.annotation!.subtitle!{
            let url = NSURL(string: absoluteString)
            if url != nil{
                //The url from the pin should, in fact, be the objectID of the coredata instance for Pin
                performSegueWithIdentifier(Constants.PhotoAlbumSegue, sender: url)
            }
        }
    }
    
    // MARK: Index Pins
    func indexPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        //No need for extra child entities here, keep it quick
        fetchRequest.includesSubentities = false
        do{
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError{
            print("The error was \(error)")
            return [Pin]()
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.PhotoAlbumSegue{
            if let pabc = segue.destinationViewController.contentViewController as? PhotoAlbumViewController{
                let url = sender as? NSURL
                let objectId = CoreDataStackManager.sharedInstance().persistentStoreCoordinator!.managedObjectIDForURIRepresentation(url!)
                pabc.objectID = objectId
            }
        }
    }


}


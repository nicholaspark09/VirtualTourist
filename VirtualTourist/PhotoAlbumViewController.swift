//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/10/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc protocol PhotoAlbumProtocol{
    func goBack()
}

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct Constants{
        static let Title = "Photo Album"
        static let PhotoAlbumCell = "PhotoAlbum Cell"
    }
    
    @IBOutlet var collectionView: UICollectionView!{
        didSet{
            performOnMain(){
                self.collectionView!.delegate = self
                self.collectionView!.dataSource = self
            }
        }
    }
    @IBOutlet var theMapView: MKMapView!{
        didSet{
            performOnMain(){
                self.theMapView!.delegate = self
            }
        }
    }
    /*
    @IBOutlet var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
            
        }
    }
 */
    var objectID: NSManagedObjectID?
    var pin:Pin?
    // MARK: SharedInstance of CoreDataStackManager
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PhotoAlbumProtocol.goBack))
        
        //Get the Pin
        if objectID != nil{
            do{
                
                let object = try CoreDataStackManager.sharedInstance().managedObjectContext.existingObjectWithID(objectID!)
                pin = object as! Pin
                
                centerMap()
                FlickrClient.sharedInstance.findWithPin(pin!){(results,error) in
                
                }
                
            }catch {
                
                let nserror = error as NSError
                print("The error was \(nserror)")
            }
            
        }
    }
    
    
    //Set the map and add the pin
    func centerMap(){
        let lat = pin!.latitude!.doubleValue
        let long = pin!.longitude!.doubleValue
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        theMapView.setCenterCoordinate(center, animated: true)
        //Add Pin
        let coordinate = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        theMapView.addAnnotation(annotation)
    }
 

    // MARK: - Return to Previous
    func goBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: UICollectionView Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.PhotoAlbumCell, forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // I keep these constants local so I can see them while I'm coding
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

    var objectID: NSManagedObjectID?
    var pin:Pin?
    
    /*
    // MARK: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format: "parent == %@", objectID)
    }()
 */
    
    // MARK: SharedInstance of CoreDataStackManager
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // This invocation prepares the table to recieve a number of changes. It will store them up
        // until it receives endUpdates(), and then perform them all at once.
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    // When endUpdates() is invoked, the table makes the changes visible.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.setNeedsUpdateConstraints()
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
                if pin!.photoAlbum == nil{
                    print("Couldn't find an album")
                    createAlbum()
                }else{
                    print("Found an album with name: \(pin!.photoAlbum!.title)")
                    if pin!.photoAlbum!.photos.count > 0{
                        print("Found photos")
                        self.collectionView.reloadData()
                    }else{
                        pullPhotosFromFlickr()
                    }
                }
            }catch {
                
                let nserror = error as NSError
                print("The error was \(nserror)")
            }
            
        }
    }
    
    func createAlbum(){
        
        let dictionary = [
            PhotoAlbum.Keys.Title : "Photos",
            PhotoAlbum.Keys.Created : NSDate(),
            PhotoAlbum.Keys.UpdatedAt : NSDate(),
            ]
        let Album = PhotoAlbum.init(dictionary: dictionary, context: sharedContext)
        Album.place = pin!
        self.saveContext()
        do{
            
            let object = try CoreDataStackManager.sharedInstance().managedObjectContext.existingObjectWithID(objectID!)
            pin = object as! Pin
        } catch {
            let nserror = error as NSError
            print("The error was \(nserror.localizedDescription)")
        }
        //Since this is a new album, go fetch some photos from flickr
        pullPhotosFromFlickr()
    }
    
    //Get the photos from flickr
    /**
    *       This is happening on a separate thread
    *           Update everything on the main thread
    *
    *
    */
    func pullPhotosFromFlickr(){
        FlickrClient.sharedInstance.findWithPin(pin!){(results,error) in
            if let error = error{
                performOnMain(){
                    self.simpleError(error)
                }
            }else{
                if let photoDictionary = results![FlickrClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                    let _ = photoDictionary.map() { (dictionary: [String:AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        photo.localDirectory = ""
                        photo.album = self.pin!.photoAlbum!
                        return photo
                    }
                }
                self.saveContext()
                performOnMain(){
                    print("YOu got them")
                    //Grab the pin again to refresh the photos
                    do{
                        let object = try CoreDataStackManager.sharedInstance().managedObjectContext.existingObjectWithID(self.objectID!)
                        self.pin = object as! Pin
                        self.collectionView.reloadData()
                    } catch {
                        let nserror = error as NSError
                        print("The error was \(nserror)")
                    }
                    
                }
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
    
    
    func saveContext(){
        performOnMain(){
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
 

    // MARK: - Return to Previous
    func goBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: UICollectionView Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pin!.photoAlbum != nil{
            print("You found \(pin!.photoAlbum!.photos.count)")
            return pin!.photoAlbum!.photos.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.PhotoAlbumCell, forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        let photo = pin!.photoAlbum!.photos[indexPath.row]
        // if an image exists at the url, set the image and title
        var placedImage = UIImage(named: "NoImage")
        if photo.localDirectory != nil && photo.localDirectory != ""{
            print("Found an image")
            placedImage = photo.photoImage
        }else if photo.url_m != nil{
            let imageURL = NSURL(string: photo.url_m!)
            FlickrClient.sharedInstance.taskForImageWithSize(imageURL!, filePath: photo.url_m!){(imageData,error) in
                if let error = error{
                    print("Error: \(error)")
                }else{
                    photo.localDirectory = photo.url_m!
                    photo.photoImage = UIImage(data: imageData!)
                    performOnMain(){
                        placedImage = photo.photoImage
                        cell.imageView.image = photo.photoImage
                    }
                    self.saveContext()
                }
            }
        }
        cell.imageView.image = placedImage
        return cell
    }
    
    
    @IBAction func clearAlbum(sender: UIButton) {
        if pin!.photoAlbum != nil{
            //Clear the cache of images first
            performOnMain(){
                self.pin!.photoAlbum = nil
                CoreDataStackManager.sharedInstance().saveContext()
                self.createAlbum()
            }
            
        }
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

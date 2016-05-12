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
        static let AlertTitle = "Delete?"
        static let AlertMessage = "Delete the photo from the album?"
        static let AlertDelete = "Delete"
        static let AlertCancel = "Cancel"
        static let PhotoViewSegue = "PhotoView Segue"
    }
    
    // MARK: -IBOutlets
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
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!{
        didSet{
            collectionViewFlowLayout!.minimumInteritemSpacing = 0
            collectionViewFlowLayout!.minimumLineSpacing = 0
        }
    }
    @IBOutlet var newCollectionButton: UIButton!
    
    
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
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PhotoAlbumProtocol.goBack))
        
        //Get the Pin
        if objectID != nil{
            do{
                
                let objectpin = try CoreDataStackManager.sharedInstance().managedObjectContext.existingObjectWithID(objectID!) as! Pin
                pin = objectpin
                centerMap()
                if pin!.photoAlbum == nil{
                    createAlbum()
                }else{
                    print("Found an album with name: \(pin!.photoAlbum!.title)")
                    if pin!.photoAlbum!.photos.count > 0{
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
            
            let object = try CoreDataStackManager.sharedInstance().managedObjectContext.existingObjectWithID(objectID!) as! Pin
            pin = object
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
        newCollectionButton.enabled = false
        FlickrClient.sharedInstance.findWithPin(pin!){(results,error) in
            if let error = error{
                performOnMain(){
                    self.simpleError(error)
                }
            }else{
                if let photoDictionary = results![FlickrClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                    let _ = photoDictionary.map() { (dictionary: [String:AnyObject]) -> Photo in
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        photo.album = self.pin!.photoAlbum!
                        return photo
                    }
                }
                performOnMain(){
                    self.saveContext()

                    //Grab the pin again to refresh the photos
                    do{
                        let object = try CoreDataStackManager.sharedInstance().managedObjectContext.existingObjectWithID(self.objectID!) as! Pin
                        self.pin = object
                        self.collectionView.reloadData()
                    } catch {
                        let nserror = error as NSError
                        print("The error was \(nserror)")
                    }
                    
                }
            }
            performOnMain(){
                self.newCollectionButton.enabled = true
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
        if photo.photoImage != nil{
            placedImage = photo.photoImage!
        }else if photo.url_m != nil{
            let imageURL = NSURL(string: photo.url_m!)
            FlickrClient.sharedInstance.taskForImageWithSize(imageURL!, filePath: photo.url_m!){(imageData,error) in
                if let error = error{
                    print("Error: \(error)")
                }else{
                    photo.blob = imageData!
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
    
    
    // MARK: - SelectedPhoto
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = pin!.photoAlbum!.photos[indexPath.row]
        /**  This is what the app requires, but I wanted to see the images
         *
         *
        let deleteAlert = UIAlertController(title: Constants.AlertTitle, message: Constants.AlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        deleteAlert.addAction(UIAlertAction(title: Constants.AlertDelete, style: .Default, handler: { (action: UIAlertAction!) in
            print("Delete this things")
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo as NSManagedObject)
            self.saveContext()
            self.collectionView.reloadData()
        }))
        deleteAlert.addAction(UIAlertAction(title: Constants.AlertCancel, style: .Cancel, handler: { (action: UIAlertAction!) in
            print("You decided to cancel")
        }))
        presentViewController(deleteAlert, animated: true, completion: nil)
         */
        performSegueWithIdentifier(Constants.PhotoViewSegue, sender: photo)
    }
    
    @IBAction func unwindToDeletePhoto(sender: UIStoryboardSegue){
        if let sourceViewController = sender.sourceViewController as? PhotoViewController{
            let photo = sourceViewController.photo!
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo as NSManagedObject)
            self.saveContext()
            self.collectionView.reloadData()
        }
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.PhotoViewSegue{
            if let pvc = segue.destinationViewController as? PhotoViewController{
                if let photo = sender as? Photo{
                    pvc.photo = photo
                }
            }
        }
    }
    

}

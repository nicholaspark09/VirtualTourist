//
//  Photo.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/12/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

    @NSManaged var title: String?
    @NSManaged var height_m: NSNumber?
    @NSManaged var width_m: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var isfamily: NSNumber?
    @NSManaged var isfriend: NSNumber?
    @NSManaged var ispublic: NSNumber?
    @NSManaged var url_m: String?
    @NSManaged var localDirectory: String?
    @NSManaged var album: PhotoAlbum?
    
    struct Keys{
        static let Title = "title"
        static let Height = "height_m"
        static let Width = "width_m"
        static let Url = "url_m"
        static let ID = "id"
        static let IsFamily = "isfamily"
        static let IsPublic = "ispublic"
        static let IsFriend = "isfriend"
        static let LocalDirectory = "localDirectory"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        title = dictionary[Keys.Title] as? String
        
        //Set the Dates
        height_m = dictionary[Keys.Height] as? NSNumber
        width_m = dictionary[Keys.Width] as? NSNumber
        url_m = dictionary[Keys.Url] as? String
        isfamily = dictionary[Keys.IsFamily] as? NSNumber
        isfriend = dictionary[Keys.IsFriend] as? NSNumber
        ispublic = dictionary[Keys.IsPublic] as? NSNumber
        id = dictionary[Keys.ID] as? NSNumber
        localDirectory = dictionary[Keys.LocalDirectory] as? String
    }

    var photoImage: UIImage? {
        get{
            return CoreDataStackManager.Caches.imageCache.imageWithIdentifier(localDirectory!)
        }
        set{
            return CoreDataStackManager.Caches.imageCache.storeImage(newValue, withIdentifier: localDirectory!)
            print("Saving into db with \(localDirectory!)")
        }
    }

}

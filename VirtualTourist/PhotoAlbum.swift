//
//  PhotoAlbum.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/11/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import CoreData


class PhotoAlbum: NSManagedObject {

    @NSManaged var title: String?
    @NSManaged var created: NSDate?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var place: Pin?
    
    struct Keys{
        static let Title = "title"
        static let Created = "created"
        static let UpdatedAt = "updatedAt"
        static let Place = "place"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        title = dictionary[Keys.Title] as? String
        
        //Set the Dates
        if let dateString = dictionary[Keys.Created] as? String {
            if let date = FlickrClient.sharedDateFormatter.dateFromString(dateString) {
                created = date
            }
        }
        if let updatedString = dictionary[Keys.UpdatedAt] as? String{
            if let date = FlickrClient.sharedDateFormatter.dateFromString(updatedString){
                updatedAt = date
            }
        }
    }

}

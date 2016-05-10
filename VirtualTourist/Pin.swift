//
//  Pin.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/11/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

    @NSManaged var id: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var created: NSDate?
    
    struct Keys{
        static let Id = "id"
        static let Created = "created"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        latitude = dictionary[Keys.Latitude] as? NSNumber
        longitude = dictionary[Keys.Longitude] as? NSNumber
        
        if let dateString = dictionary[Keys.Created] as? String {
            if let date = FlickrClient.sharedDateFormatter.dateFromString(dateString) {
                created = date
            }
        }
    }
    
}

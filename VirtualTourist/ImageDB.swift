//
//  ImageDB.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/12/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

class ImageDB: NSObject {
    
    
    override init() {
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ImageDB {
        
        struct Singleton {
            static var sharedInstance = ImageDB()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}

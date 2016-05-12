//
//  ImagesCache.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/12/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation
import UIKit

class ImagesCache{
    
    private var memoryCache = NSCache()
    
    //Get an image with the String name
    func imageWithIdentifier( id: String?) -> UIImage? {
        
        if id == nil || id == ""{
            return nil
        }
        
        let path = pathForIdentifier(id!)
        
        if let image = memoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        //Try the hard drive
        /*
            This method should take a bit longer as it prevents other executions from fetching or writing data
        */
        if let data = NSData(contentsOfFile: path){
            return UIImage(data: data)
        }
        return nil
    }
    
    func storeImage(image: UIImage?, withIdentifier id: String){
        let path = pathForIdentifier(id)
        
        // If there is no image, remove the image
        /*
            Anytime you need to remove something from the cache, just put in the path name and
            it will remove the image if it's there
        */
        if image == nil{
            memoryCache.removeObjectForKey(path)
            do{
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _{}
            return
        }
        
        //Keep the image in cache
        memoryCache.setObject(image!, forKey: path)
        
        //Add to the documents directory
        //Has to actually store into the Drive preventing other executions from executing
        //Will take up time
        let data = UIImagePNGRepresentation(image!)!
        data.writeToFile(path, atomically: true)
    }
    
    
    // MARK: -GetFullPath Get the Full Path from the Documents Directory
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}

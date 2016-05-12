//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/11/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

extension FlickrClient{
    
    func findWithPin(pin: Pin, completionHandlerForFindPin: (results:[String:AnyObject]?, error: String?) -> Void){
        let methodParameters = [
            ParameterKeys.Method : ParameterValues.SearchMethod,
            ParameterKeys.APIKey : ParameterValues.ApiKey,
            ParameterKeys.SafeSearch : ParameterValues.UseSafeSearch,
            ParameterKeys.Extras : ParameterValues.MediumURL,
            ParameterKeys.Latitude :pin.latitude!,
            ParameterKeys.Longitude : pin.longitude!,
            ParameterKeys.Format : ParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback : ParameterValues.DisableJSONCallback,
            ParameterKeys.PerPage : 50
        ]
        httpGet("", parameters: methodParameters){ (results,error) in
            
            func sendError(error: String){
                print("The error was \(error)")
                completionHandlerForFindPin(results: nil, error: error)
                return
            }
            
            guard error == nil else{
                sendError("\(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = results[JSONResponseKeys.Status] as? String where stat == JSONResponseValues.OKStatus else {
                sendError("Flickr API returned an error. See error code and message in \(results)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = results[JSONResponseKeys.Photos] as? [String:AnyObject] else {
                 sendError("Cannot find key '\(JSONResponseKeys.Photos)' in \(results)")
                return
            }
            
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[JSONResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(JSONResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.findWithParams(methodParameters, withPageNumber: randomPage){(results,error) in
                completionHandlerForFindPin(results: results, error: error)
            }
        }
    }
    
    func findWithParams(var params: [String:AnyObject], withPageNumber: Int, completionHandlerForFindPin: (results:[String:AnyObject]?, error: String?) -> Void){
        params[ParameterKeys.Page] = withPageNumber
        httpGet("", parameters: params){ (results,error) in
            
            func sendError(error: String){
                print("The error was \(error)")
                completionHandlerForFindPin(results: nil, error: error)
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = results[JSONResponseKeys.Status] as? String where stat == JSONResponseValues.OKStatus else {
                sendError("Flickr API returned an error. See error code and message in \(results)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = results[JSONResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find key '\(JSONResponseKeys.Photos)' in \(results)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[JSONResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(JSONResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            //Got shtuff back
            completionHandlerForFindPin(results: photosDictionary, error: nil)
            //print("The data is \(photosDictionary)")
        }
    }
    
    // MARK: - All purpose task method for images

    func taskForImageWithSize(url: NSURL, filePath: String, completionHandler: (imageData: NSData?, error:String?) ->  Void) -> NSURLSessionTask {
        
        let request = NSURLRequest(URL: url)
        print("Looking for image with \(url)")
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                print("ERROR: \(error.localizedDescription)")
                completionHandler(imageData: nil, error: "Couldn't get the image: \(error.localizedDescription)")
            } else {
                print("FOund it")
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
 
}
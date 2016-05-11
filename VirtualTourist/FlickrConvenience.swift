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
            ParameterKeys.NoJSONCallback : ParameterValues.DisableJSONCallback
        ]
        httpGet("", parameters: methodParameters){ (results,error) in
            
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
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError("Cannot find key '\(JSONResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                sendError("No Photos Found. Search Again.")
                return
            } else {
                print("You got things back! \(photosDictionary)")
            }
        }
    }
}
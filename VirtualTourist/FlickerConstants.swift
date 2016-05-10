//
//  FlickerConstants.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/10/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import Foundation

extension FlickrClient{
    struct Constants{
        static let ApiSecret = "bf9e2cc3da5ceb00"
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct ParameterKeys{
        static let APIKey = "api_key"
        static let SafeSearch = "safe_search"
        static let Format = "format"
        static let Extras = "extras"
    }
    
    struct ParameterValues{
        static let ApiKey = "991a7e44cb35c8ada257eebc679778de"
        static let UseSafeSearch = "1"
        static let MediumURL = "url_m"
    }
    
    struct JSONResponseKeys{
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    struct JSONResponseValues{
        static let OKStatus = "ok"
    }
    
    
}

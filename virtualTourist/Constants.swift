//
//  Constants.swift
//  virtualTourist
//
//  Created by Nikki L on 8/3/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import UIKit // (why UIKIT???)
// import UIKit - need this?

/* how to construct what parameters constant?
When "exploring the API here - https://www.flickr.com/services/api/explore/flickr.photos.search
At the end, there is an URL like below - kinda like a tip to help you to construct the API call
 
 URL: https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3f8c7ede36466be0fce36d3c3f571747&bbox=0%2C0%2C0%2C0&safe_search=1&extras=url_m&page=1&format=json&nojsoncallback=1&auth_token=72157684532351144-7af0f18392c6e934&api_sig=a2e56123f43c92e5993f96196c1bbb69
 
 */

struct Constants {
    
    // MARK: Flickr 
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys - FlickrParameterKeys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let SafeSearch = "safe_search"
        static let Extras = "extras" // extras=url_m&....
        static let Format = "format"
        static let NoJsonCallback = "nojsoncallback"
        static let BoundingBox = "bbox" // do we need bbox? YES - pro: want to show photo around that area i/o exact lon/lat...
        static let Page = "page" // for its value, we will assign a random page from view controller. The value is not a constant - &page=1& -> page=randomPage that will be assign @ VC.swift
        static let PhotosPerCall = "per_page"
        
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "de81659817b7cef439bb69480279b510"
        static let UseSafeSearch = "1"
        static let MediumURL = "url_m" // value of key extras
        static let ResponseFormat = "json" // format=json
        static let DisableJSONCallback = "1" // nojsoncallback=1
        static let PhotosPerCall = "27"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}





























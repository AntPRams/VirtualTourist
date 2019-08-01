//
//  EndPoints.swift
//  Virtual Tourist
//
//  Created by António Ramos on 22/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation



enum EndPoints {
    //Construct URL to comunicate with Flickr API search Method
    
    static let api = "API_KEY_GOES_HERE"
    static let numberOfResultsPerPage = 15
    
    static let base =           "https://www.flickr.com/services/rest/"
    static let searchMethod =   "?method=flickr.photos.search"
    static let apiKey =         "&api_key=\(api)"
    static let accuracy =       "&accuracy=9"
    static let contentType =    "&content_type=1"
    static let latitude =       "&lat="
    static let longitude =      "&lon="
    static let resultsPerPage = "&per_page=\(String(numberOfResultsPerPage))"
    static let pageNumber =     "&page="
    static let format =         "&format=json"
    static let callBack =       "&nojsoncallback=1"
    
    case getImagesForLocation(String, String, String)
    case downloadImagesUrl(String, String, String, String)
    
    var stringValue: String {
        
        switch self {
        case .getImagesForLocation(let latitude, let longitude, let pageNumber):
            return
                EndPoints.base +
                EndPoints.searchMethod +
                EndPoints.apiKey +
                EndPoints.accuracy +
                EndPoints.contentType +
                EndPoints.latitude + latitude +
                EndPoints.longitude + longitude +
                EndPoints.resultsPerPage +
                EndPoints.pageNumber + pageNumber +
                EndPoints.format +
                EndPoints.callBack
            
        case .downloadImagesUrl(let farmId, let photoServer, let photoId, let photoSecret):
            return "https://farm\(farmId).staticflickr.com/\(photoServer)/\(photoId)_\(photoSecret).jpg"
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
    
    var string: String {
        return stringValue
    }
}

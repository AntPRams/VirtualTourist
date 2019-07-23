//
//  EndPoints.swift
//  Virtual Tourist
//
//  Created by António Ramos on 22/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation

enum EndPoints {
    
    static let base =           "https://www.flickr.com/services/rest/"
    static let method =         "?method=flickr.photos.search"
    static let apiKey =         "&api_key=eccb4ab3d58a3ccf0452fa2fd2422b8a"
    static let accuracy =       "&accuracy=9"
    static let contentType =    "&content_type=1"
    static let latitude =       "&lat="
    static let longitude =      "&lon="
    static let resultsPerPage = "&per_page=10"
    static let pageNumber =     "&page=\(Int.random(in: 1...100))"
    static let format =         "&format=json"
    static let callBack =       "&nojsoncallback=1"
    
    case getPhotosForLocation(String, String)
    
    var stringValue: String {
        
        switch self {
        case .getPhotosForLocation(let latitude, let longitude):
            return
                EndPoints.base +
                EndPoints.method +
                EndPoints.apiKey +
                EndPoints.accuracy +
                EndPoints.contentType +
                EndPoints.latitude + latitude +
                EndPoints.longitude + longitude +
                EndPoints.resultsPerPage +
                EndPoints.pageNumber +
                EndPoints.format +
                EndPoints.callBack
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
}

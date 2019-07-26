//
//  PhotosArrayResponse.swift
//  Virtual Tourist
//
//  Created by António Ramos on 23/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    
    let rawImages: RawImages
    
    enum CodingKeys: String, CodingKey {
        case rawImages = "photos"
    }
}

struct RawImages: Codable {
    
    let array: [RawImage]
    let pages: Int
    
    enum CodingKeys: String, CodingKey {
        case array = "photo"
        case pages
    }
}

struct RawImage: Codable {
    
    let id:     String
    let secret: String
    let server: String
    let farm:   Int
    let title:  String

}

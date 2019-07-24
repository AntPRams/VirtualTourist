//
//  PhotosArrayResponse.swift
//  Virtual Tourist
//
//  Created by António Ramos on 23/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    
    let photos: Photos
}

struct Photos: Codable {
    
    let array: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case array = "photo"
    }
}

struct Photo: Codable {
    
    let id:     String
    let secret: String
    let server: String
    let farm:   Int
    let title:  String

}

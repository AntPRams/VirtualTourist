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
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

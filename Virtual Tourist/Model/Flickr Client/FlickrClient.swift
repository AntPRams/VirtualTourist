//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by António Ramos on 21/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    class func taskForGETRequest<ResponseType: Decodable> (url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            print("url: \(url)")
            guard let data = data else {
               
                completionHandler(nil, error)
                return
            }
            
             print("data: \(data)")
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func getPhotosOfLocation(latitude: Double, longitude: Double, pages: Int? = nil, completionHandler: @escaping (PhotosResponse?, Error?) -> Void) {
        
        var page: Int {
            guard let pages = pages else {return 1}
            return Int.random(in: 1...pages)
        }
        
        taskForGETRequest(url: EndPoints.getImagesForLocation(String(latitude),
                                                              String(longitude),
                                                              String(page)).url,
                                                              response: PhotosResponse.self
            ){
            (response, error) in
                
            if let response = response {
                
                DispatchQueue.main.async {
                    completionHandler(response, nil)
                }
            }  else {
                DispatchQueue.main.async {
                    print("Error in get photos ofr loc: \(error?.localizedDescription)")
                    completionHandler(nil, error)
                }
            }
        }
    }
}


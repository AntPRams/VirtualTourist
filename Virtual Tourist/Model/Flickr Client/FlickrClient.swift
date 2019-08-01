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
            guard let data = data else {
               
                completionHandler(nil, error)
                return
            }
            
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
    
    class func getImagesOfLocation(latitude: Double, longitude: Double, pages: Int? = nil, completionHandler: @escaping (PhotosResponse?, Error?) -> Void) {
        
        var page: Int {
            if let pages = pages {
                let page = min(pages, 4000/EndPoints.numberOfResultsPerPage)
                return Int.random(in: 1...page + 1)
            }
            return 1
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
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    class func downloadImageData(image: Image, completionHandler: @escaping(UIImage?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if image.data == nil {
                guard let imageUrl = image.url, let url = URL(string: imageUrl) else {return}
                do {
                    let imageData = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        image.data = imageData
                        
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    guard let imageData = image.data else {return}
                    let image = UIImage(data: imageData)

                    completionHandler(image, nil)
                }
            }
        }
    }
    
    class func downloadImageDataTest(image: Image, completionHandler: @escaping(Data?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if image.data == nil {
                guard let imageUrl = image.url, let url = URL(string: imageUrl) else {return}
                do {
                    let imageData = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        completionHandler(imageData, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    guard let imageData = image.data else {return}
                    completionHandler(imageData, nil)
                }
            }
        }
    }
}


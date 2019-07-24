//
//  DataController.swift
//  Virtual Tourist
//
//  Created by António Ramos on 22/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError()
            }
            completionHandler?()
        }
    }
}

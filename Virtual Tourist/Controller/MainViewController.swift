//
//  MainViewController.swift
//  Virtual Tourist
//
//  Created by António Ramos on 31/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import CoreData
import UIKit

class MainViewController: UIViewController {
    
    func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("success on saving!!")
            } catch {
                print("Error saving")
            }
        }
    }
    
    func delete(_ context: NSManagedObjectContext, object: NSManagedObject) {
        
        context.delete(object)
        save(context)
        
    }
    
}

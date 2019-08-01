//
//  MainViewController.swift
//  Virtual Tourist
//
//  Created by António Ramos on 31/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import CoreData
import UIKit

//Helper extension with features that needs to be use in both view controllers

extension UIViewController {
    
    //Core data save and delete
    
    func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func delete(_ context: NSManagedObjectContext, object: NSManagedObject) {
        
        context.delete(object)
        save(context)
    }
    
    //Show alert
    
    func showAlert(message: String) {
        
        let alert = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
}

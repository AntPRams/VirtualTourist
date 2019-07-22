//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by António Ramos on 21/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualTourist")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        let navController = window?.rootViewController as! UINavigationController
        let pinsCollectionController = navController.topViewController as! MapViewController
        pinsCollectionController.dataController = dataController
        return true
    }


}


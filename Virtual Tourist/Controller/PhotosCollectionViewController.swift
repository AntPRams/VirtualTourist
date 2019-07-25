//
//  PhotosCollectionViewController.swift
//  Virtual Tourist
//
//  Created by António Ramos on 24/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosCollectionController: UIViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    var pin: Pin?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Collection VC Pin Lat: \(pin?.latitude)")
        print("Collection VC Pin Long: \(pin?.longitude)")
        
    }
}

extension PhotosCollectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reusableIdentifier, for: indexPath) as! CollectionViewCell
        
        return cell
    }
    
    
}

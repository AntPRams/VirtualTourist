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

class ImagesCollectionViewController: UIViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    var pin: Pin!
    var totalPages: Int?
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImagesForSelectedPin(pin)
        
        if pin?.images?.count == 0 {
            getImagesFromFlickrForSelectedPin(latitude: pin?.latitude, longitude: pin?.longitude)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    private func fetchImagesForSelectedPin(_ pin: Pin) {
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print("SECTIONS COUNT: \(fetchedResultsController.sections!.count)")
        } catch {
            print("error getting images fetched results controller")
        }
    }
    
    private func getImagesFromFlickrForSelectedPin (latitude: Double?, longitude: Double?) {
        guard let latitude = latitude, let longitude = longitude else {return}
        
        FlickrClient.getPhotosOfLocation(latitude: latitude, longitude: longitude, pages: totalPages, completionHandler: handlePhotos(response:error:))
    }
    
    private func handlePhotos(response: PhotosResponse?, error: Error?) {
        
        if error == nil {
            
            totalPages = response?.rawImages.pages
            guard let response = response?.rawImages.array else {return}
            var photosToStore: [Image] = []
            for rawImage in response {
                let image = Image(context: dataController.viewContext)
                let url = EndPoints.downloadImagesUrl(String(rawImage.farm),
                                                      rawImage.server,
                                                      rawImage.id,
                                                      rawImage.secret).string
                image.url = url
                image.pin = pin
                photosToStore.append(image)
            }
            
            do {
                pin.images?.addingObjects(from: photosToStore)
                try dataController.viewContext.save()
            } catch {
                print("error")
            }
        } else {
            print("error")
        }
    }
    
    private func saveContextIfNeeded() {
        if dataController.viewContext.hasChanges {
            do {
                try dataController.viewContext.save()
                print("SAVED")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension ImagesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reusableIdentifier, for: indexPath) as! CollectionViewCell
    
        cell.cellImageView.image = nil
        cell.activityIndicator.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let image = fetchedResultsController.object(at: indexPath)
        let cell = cell as! CollectionViewCell
        
        FlickrClient.downloadImageData(image: image) { (image, error) in
            if let image = image {
                cell.activityIndicator.stopAnimating()
                cell.cellImageView.image = image
                self.saveContextIfNeeded()
                print("image loaded")
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}
    
    
    
    extension ImagesCollectionViewController: NSFetchedResultsControllerDelegate {
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            insertedIndexPaths = [IndexPath]()
            deletedIndexPaths = [IndexPath]()
            updatedIndexPaths = [IndexPath]()
        }
        
        func controller(
            _ controller: NSFetchedResultsController<NSFetchRequestResult>,
            didChange anObject: Any,
            at indexPath: IndexPath?,
            for type: NSFetchedResultsChangeType,
            newIndexPath: IndexPath?) {
            
            switch (type) {
            case .insert:
                insertedIndexPaths.append(newIndexPath!)
                break
            case .delete:
                deletedIndexPaths.append(indexPath!)
                break
            case .update:
                updatedIndexPaths.append(indexPath!)
                break
            case .move:
                print("Move an item. We don't expect to see this in this app.")
                break
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            
            collectionView.performBatchUpdates({() -> Void in
                
                for indexPath in self.insertedIndexPaths {
                    self.collectionView.insertItems(at: [indexPath])
                }
                
                for indexPath in self.deletedIndexPaths {
                    self.collectionView.deleteItems(at: [indexPath])
                }
                
                for indexPath in self.updatedIndexPaths {
                    self.collectionView.reloadItems(at: [indexPath])
                }
                
            }, completion: nil)
        }
        
}


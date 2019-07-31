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

class ImagesCollectionViewController: MainViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    
    var pin: Pin!
    var totalPages: Int?
    
    var insertIndexPath: [IndexPath]!
    var deleteIndexPath: [IndexPath]!
    var updateIndexPath: [IndexPath]!
    
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
    
    private func checkImagesForSelected(_ pin: Pin) {
        
        guard let imagesSetForSelectedPin = pin.images else {return}
        
        if imagesSetForSelectedPin.count == 0 {
            getImagesFromFlickrForSelectedPin(latitude:  pin.latitude,
                                              longitude: pin.longitude
            )
        }
    }
    
    private func fetchImagesForSelectedPin(_ pin: Pin) {
        
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@",
                                    argumentArray: [pin]
        )
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: dataController.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error getting images fetched results controller")
        }
    }
    
    private func getImagesFromFlickrForSelectedPin (latitude: Double?, longitude: Double?) {
        
        guard let latitude = latitude,
            let longitude = longitude
            else {return}
        
        FlickrClient.getImagesOfLocation(latitude:          latitude,
                                         longitude:         longitude,
                                         pages:             totalPages,
                                         completionHandler: handleImagesResponse(response:error:)
        )
    }
    
    private func handleImagesResponse(response: PhotosResponse?, error: Error?) {
        
        if error == nil {
            
            totalPages = response?.rawImages.pages
            guard let response = response?.rawImages.array else {return}
            var imagesToSave: [Image] = []
            
            for rawImage in response {
                let image = Image(context: dataController.viewContext)
                let url = EndPoints.downloadImagesUrl(String(rawImage.farm),
                                                      rawImage.server,
                                                      rawImage.id,
                                                      rawImage.secret).string
                image.url = url
                image.pin = pin
                imagesToSave.append(image)
            }
            
            pin.images?.addingObjects(from: imagesToSave)
            save(dataController.viewContext)
            
            if response.count == 0 {
                print("NO IMAGES")
            }
            
        } else {
            print("error")
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
                self.save(self.dataController.viewContext)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("YOU PICK")
    }
}

    extension ImagesCollectionViewController: NSFetchedResultsControllerDelegate {
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            insertIndexPath = [IndexPath]()
            deleteIndexPath = [IndexPath]()
            updateIndexPath = [IndexPath]()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch (type) {
            case .insert:
                insertIndexPath.append(newIndexPath!)
                break
            case .update:
                updateIndexPath.append(indexPath!)
                break
            case .delete:
                deleteIndexPath.append(indexPath!)
                break
            case .move:
                print("This feature is not implemented in this app.")
                break
            @unknown default:
                print("Unknow feature not yet implemented")
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            
            collectionView.performBatchUpdates( {() -> Void in
                for indexPath in self.insertIndexPath {
                    self.collectionView.insertItems(at: [indexPath])
                }
                for indexPath in self.deleteIndexPath {
                    self.collectionView.deleteItems(at: [indexPath])
                }
                for indexPath in self.updateIndexPath {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }, completion: nil)
        }
}


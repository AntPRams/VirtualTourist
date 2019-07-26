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
    var insertIndexPaths: [IndexPath]!
    var deleteIndexPaths: [IndexPath]!
    var updateIndexPaths: [IndexPath]!
    
    
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
            print("erro getting images fetched results controller")
        }
    }
    
    private func getImagesFromFlickrForSelectedPin (latitude: Double?, longitude: Double?) {
        guard let latitude = latitude, let longitude = longitude else {return}
    
        FlickrClient.getPhotosOfLocation(latitude: latitude, longitude: longitude, pages: totalPages, completionHandler: handlePhotos(response:error:))
    }
    
    func handlePhotos(response: PhotosResponse?, error: Error?) {
    
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
    
    func downloadDataInBackground(images: [Image]) {
        
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
        cell.cellImageView = nil
        cell.activityIndicator.startAnimating()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let image = fetchedResultsController.object(at: indexPath)
        guard let url = image.url else {return}
        let cell = cell as! CollectionViewCell
        
        let downloadQueue = DispatchQueue(label: "download", qos: .background)
        
        downloadQueue.async {
            if let url = URL(string: url), let imageData = try? Data(contentsOf: url) {
                image.data = imageData
                print(imageData)
                
                DispatchQueue.main.async {
                    let newImage = UIImage(data: image.data!)
                    print(image.data)
                    print(newImage)
                    cell.cellImageView.image = newImage
                    cell.activityIndicator.stopAnimating()
               }
            }
        }
    }
    
    func getImageData(handler: @escaping(Data?, Error?)) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let image = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = image.url {
        var tasks: [String: URLSessionDataTask] = [:]
        tasks[imageUrl]?.cancel()
        }
        
    }
   
        
    
    
    
}

extension ImagesCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertIndexPaths = [IndexPath]()
        deleteIndexPaths = [IndexPath]()
        updateIndexPaths = [IndexPath]()
    
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            insertIndexPaths.append(newIndexPath!)
        case .update:
            updateIndexPaths.append(indexPath!)
        case .delete:
            deleteIndexPaths.append(indexPath!)
        default:
            print("ITS A BREAK")
            break
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            
            for indexPath in self.insertIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.updateIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            for indexPath in self.deleteIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            
        }, completion: nil)
        }
    
    
    
}

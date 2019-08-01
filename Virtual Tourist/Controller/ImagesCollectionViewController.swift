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
    
    //MARK: Properties
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    var pin: Pin!
    var totalPages: Int?
    
    var insertIndexPath: [IndexPath]!
    var deleteIndexPath: [IndexPath]!
    var updateIndexPath: [IndexPath]!
    
    var coordinate: CLLocationCoordinate2D!
    
    //Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var downloadNewCollectionButton: UIBarButtonItem!
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadNewCollectionButton.isEnabled = false
        fetchOrDownloadImagesForSelected(pin)
        setMapInLocation(pin)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        downloadNewCollectionButton.isEnabled = false
        fetchedResultsController = nil
    }
    
    //MARK: Actions
    
    @IBAction func downloadNewCollectionOnButtonTapped(_ sender: Any) {
        
        guard let images = pin.images else {return}
        downloadNewCollectionButton.isEnabled = false
        for image in images {
            delete(dataController.viewContext, object: image as! NSManagedObject)
        }
        
        getImagesFromFlickrForSelectedPin(latitude: pin.latitude, longitude: pin.longitude)
    }
    
    //MARK: Methods
    
    fileprivate func fetchOrDownloadImagesForSelected(_ pin: Pin) {
        
        fetchImagesForSelected(pin)
        
        if pin.images?.count == 0 {
            getImagesFromFlickrForSelectedPin(latitude: pin.latitude, longitude: pin.longitude)
        }
        
    }
    
    private func checkImagesForSelected(_ pin: Pin) {
        
        guard let imagesSetForSelectedPin = pin.images else {return}
        
        if imagesSetForSelectedPin.count == 0 {
            getImagesFromFlickrForSelectedPin(latitude:  pin.latitude,
                                              longitude: pin.longitude
            )
        }
    }
    
    fileprivate func fetchImagesForSelected(_ pin: Pin) {
        
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
            showAlert(message: error.localizedDescription)
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
                FlickrClient.downloadImageDataTest(image: image) { (data, error) in
                    if error == nil {
                        image.data = data
                        self.save(self.dataController.viewContext)
                    } else {
                        self.showAlert(message: error?.localizedDescription ?? "Error")
                    }
                }
            }
            
            downloadNewCollectionButton.isEnabled = true
            
            pin.images?.addingObjects(from: imagesToSave)
            save(dataController.viewContext)
            
            if response.count == 0 {
                showAlert(message: "There are no images for this location")
                downloadNewCollectionButton.isEnabled = false
            }
        } else {
            showAlert(message: error?.localizedDescription ?? "Error")
            downloadNewCollectionButton.isEnabled = false
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
        
        let image = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reusableIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.cellImageView.image = nil
        cell.activityIndicator.startAnimating()
        cell.backgroundColor = .gray
        
        if image.data != nil {
            if let data = image.data {
                cell.backgroundColor = .clear
                cell.cellImageView.image = UIImage(data: data)
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        downloadNewCollectionButton.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if downloadNewCollectionButton.isEnabled == true {
            let imageToDelete = fetchedResultsController.object(at: indexPath)
            delete(dataController.viewContext, object: imageToDelete)
        } else {
            return
        }
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
                showAlert(message: "This feature was not implemented in this app.")
                break
            @unknown default:
                showAlert(message: "Unknow feature not yet implemented")
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

extension ImagesCollectionViewController: MKMapViewDelegate {
    
    func setMapInLocation(_ pin: Pin) {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), animated: false)
        //mapView.isZoomEnabled = false
        mapView.isUserInteractionEnabled = false
        
        mapView.addAnnotation(annotation)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
}


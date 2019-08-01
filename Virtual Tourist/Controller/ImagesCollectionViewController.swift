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
    
    //Outlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var downloadNewCollectionButton: UIBarButtonItem!
    
    
    @IBOutlet weak var cell: UICollectionViewCell!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadNewCollectionButton.isEnabled = false
        fetchOrDownloadImagesForSelected(pin)
        setMapInLocation(pin)
        setFlowLayout(interItemInLine: 8, cellsPerRow: 3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    //MARK: Actions
    
    @IBAction func downloadNewCollectionOnButtonTapped(_ sender: Any) {
        
        guard let images = pin.images else {return}
        for image in images {
            delete(dataController.viewContext, object: image as! NSManagedObject)
        }
        
        getImagesFromFlickrForSelectedPin(latitude: pin.latitude, longitude: pin.longitude)
    }
    
    //MARK: Methods
    
    private func setFlowLayout(interItemInLine spacing: CGFloat, cellsPerRow: CGFloat) {
        
        let collectionViewFrameWidth = collectionView.frame.width
        let dimension = (collectionViewFrameWidth - ((cellsPerRow + 1) * spacing)) / cellsPerRow
        
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing =      spacing
        
        flowLayout.itemSize = CGSize(
            width: dimension,
            height: dimension
        )
        
        flowLayout.sectionInset = UIEdgeInsets(
            top: spacing,
            left: spacing,
            bottom: spacing,
            right: spacing
        )
        
    }
    
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
        
        downloadNewCollectionButton.isEnabled = false
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
            
            pin.images?.addingObjects(from: imagesToSave)
            save(dataController.viewContext)
            
            if response.count == 0 {
                showAlert(message: "There are no images for this location")
            }
        } else {
            showAlert(message: error?.localizedDescription ?? "Error")
        }
    }
}






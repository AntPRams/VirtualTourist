//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by António Ramos on 21/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: Properties
    
    var annotations =            [MKPointAnnotation]()
    var dataController:           DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        setupFetchedResultsController()
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnootationThroughGesture(_:)) )
        longPressGestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func addAnootationThroughGesture(_ gestureRecognizer: UIGestureRecognizer) {
        let annotation = MKPointAnnotation()
        
        
        switch (gestureRecognizer.state){
        
        case .began:
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            annotation.coordinate = coordinates
            let lat = annotation.coordinate.latitude
            let long = annotation.coordinate.longitude
            saveLocation(latitude: lat, longitude: long)
            mapView.addAnnotation(annotation)
            
            
        case .changed:
            break
        default:
            print("")
        }
    }
    
    func handlePhotos(response: PhotosResponse?, error: Error?) {
        if error == nil {
            for photo in (response?.photos.array)! {
            print("https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")
            }
        } else {
            print("error")
        }
    }
    
    func saveLocation(latitude: Double, longitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        
        pin.latitude =  latitude
        pin.longitude = longitude
        FlickrClient.getPhotosOfLocation(latitude: latitude, longitude: longitude, completionHandler: handlePhotos(response:error:))
        do {
            try dataController.viewContext.save()
            print("success on saving pin")
        } catch {
            print("an error ocurred while trying to save pin")
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest:         fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath:   nil,
            cacheName:            nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            guard let pins = fetchedResultsController.fetchedObjects else {return}
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.latitude
                annotation.coordinate.longitude = pin.longitude
                mapView.addAnnotation(annotation)
            }
        } catch {
            fatalError()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
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

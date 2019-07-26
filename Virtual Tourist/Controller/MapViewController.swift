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
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var dataController:           DataController!
    var pin:                      Pin?
    
    //Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPinsAndPopulateMapWithAnnotations()
        addGestureRecognizer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    fileprivate func addGestureRecognizer() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnootationThroughGesture(_:)) )
        longPressGestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func addAnootationThroughGesture(_ gestureRecognizer: UIGestureRecognizer) {
        
        let annotation = MKPointAnnotation()
        
        switch (gestureRecognizer.state){
        case .began:
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(touchPoint,
                                              toCoordinateFrom: mapView
            )
            annotation.coordinate = coordinates
            saveLocation(latitude: annotation.coordinate.latitude,
                         longitude: annotation.coordinate.longitude
            )
            mapView.addAnnotation(annotation)
        case .changed:
            break
        default:
            print("")
        }
    }
   
    func saveLocation(latitude: Double, longitude: Double) {
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude =  latitude
        pin.longitude = longitude
        do {
            try dataController.viewContext.save()
            print("success on saving pin")
        } catch {
            print("an error ocurred while trying to save pin")
        }
    }
    
    fileprivate func fetchPinsAndPopulateMapWithAnnotations() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            guard let fetchedPins = fetchedResultsController.fetchedObjects else {return}
            for pin in fetchedPins {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude =  pin.latitude
                annotation.coordinate.longitude = pin.longitude
                mapView.addAnnotation(annotation)
            }
        } catch {
            fatalError()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let controller = segue.destination as? ImagesCollectionViewController,
              let pin = sender as? Pin
              else {return}
        
        controller.dataController = dataController
        controller.pin = pin
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let latitude =  view.annotation?.coordinate.latitude,
              let longitude = view.annotation?.coordinate.longitude
              else {return}
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format:"longitude == %@ AND latitude == %@", String(longitude), String(latitude))
        print("map vc lat is: \(latitude)")
        do {
            pin = try dataController.viewContext.fetch(fetchRequest).first
        } catch {
            print("error")
        }
        performSegue(withIdentifier: "mapToCollection", sender: pin)
    }
}


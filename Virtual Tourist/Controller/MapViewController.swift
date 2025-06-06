//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by António Ramos on 21/07/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import UIKit

import CoreData
import MapKit

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: Properties
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var dataController:           DataController!
    var annotations =             [MKPointAnnotation]()
    var pin: Pin?
    
    //Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPinsAndPopulateMapWithAnnotations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mapView.removeAnnotations(annotations)
        fetchedResultsController = nil
    }
    
    //MARK: Methods
    
    func loadPinFromDataBase(_ longitude: CLLocationDegrees, _ latitude: CLLocationDegrees) -> Pin? {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format:"longitude == %@ AND latitude == %@",
            String(longitude),
            String(latitude)
        )
        do {
            pin = try dataController.viewContext.fetch(fetchRequest).first
            guard pin != nil else {return nil}
        } catch {
            showAlert(message: error.localizedDescription)
        }
        return pin
    }
    
    fileprivate func addGestureRecognizer() {
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(addAnootationThroughGesture(_:))
        )
        
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
            annotations.append(annotation)
        default:
            break
        }
    }
   
    func saveLocation(latitude: Double, longitude: Double) {
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude =  latitude
        pin.longitude = longitude
        save(dataController.viewContext)
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
                annotations.append(annotation)
            }
        } catch {
            showAlert(message: error.localizedDescription)
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




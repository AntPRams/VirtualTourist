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

struct TestImage {
    let image: UIImage
}

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: Properties
    
    var annotations =            [MKPointAnnotation]()
    var dataController:           DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var images: [TestImage] = []
    var pin: Pin?
    var pins: [Pin]?
    
    
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
                let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!
                do {
                    let imageData = try Data(contentsOf: url)
                    let image = UIImage(data: imageData)!
                    let newImage = TestImage(image: image)
                    images.append(newImage)
                    print("success")
                }catch{
                    print("erro converting")
                }
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
        
        do {
            let fetchedPins = try dataController.viewContext.fetch(fetchRequest)
            pins = fetchedPins
            
            for pin in fetchedPins {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.latitude
                annotation.coordinate.longitude = pin.longitude
                mapView.addAnnotation(annotation)
            }
        } catch {
            fatalError()
        }
    }
    
    
    private func preparePinForSegue(latitude: Double, longitude: Double) -> Pin? {
        
        return nil
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? PhotosCollectionController, let pin = sender as? Pin else {return}
        controller.dataController = dataController
        controller.images = images
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
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format:"longitude == %@ AND latitude == %@", String(longitude), String(latitude))
        
        do {
            self.pin = try dataController.viewContext.fetch(fetchRequest).first as? Pin
        } catch {
            print("error")
        }
        performSegue(withIdentifier: "mapToCollection", sender: pin)
    }
}


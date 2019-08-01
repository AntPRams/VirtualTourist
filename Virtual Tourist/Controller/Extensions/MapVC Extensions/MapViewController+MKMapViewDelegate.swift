//
//  MapViewController+MKMapViewDelegate.swift
//  Virtual Tourist
//
//  Created by António Ramos on 01/08/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation
import MapKit

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
        
        guard let annotation = view.annotation,
            let pin = loadPinFromDataBase(
                annotation.coordinate.longitude,
                annotation.coordinate.latitude
            )
            else {return}
        
        if isEditing {
            mapView.removeAnnotation(annotation)
            delete(dataController.viewContext, object: pin)
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        performSegue(withIdentifier: "mapToCollection", sender: pin)
    }
}

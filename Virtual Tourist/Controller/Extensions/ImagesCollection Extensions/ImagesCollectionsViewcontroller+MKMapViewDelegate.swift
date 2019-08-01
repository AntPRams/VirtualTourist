//
//  ImagesCollectionsViewcontroller+MKMapViewDelegate.swift
//  Virtual Tourist
//
//  Created by António Ramos on 01/08/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation
import MapKit

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

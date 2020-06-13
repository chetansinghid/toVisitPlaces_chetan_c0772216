//
//  ViewController.swift
//  Find My Place
//
//  Created by Chetan on 2020-06-13.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
//reference to storyboard mapview
    @IBOutlet weak var mapView: MKMapView!
    
//    location manager declaration
    var locationManager = CLLocationManager()
    
//    on load function
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        sets up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

//        adds double tap recognizer
        let addLocation = UITapGestureRecognizer(target: self, action: #selector(setDestination))
        addLocation.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(addLocation)
    }

//    MARK: updates location in map when user moves - displays current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        delta region specifiers
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
//        create region to show to user
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: locations.last!.coordinate, span: span)
        
//        displays region
        mapView.setRegion(region, animated: true)
    }
    
//    MARK: method to set up the destination on double tap
    @objc func setDestination(sender: UITapGestureRecognizer) {
        
        let destination = sender.location(in: mapView)
        let desCoordinate = mapView.convert(destination, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "My destination"
        annotation.coordinate = desCoordinate
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }

}


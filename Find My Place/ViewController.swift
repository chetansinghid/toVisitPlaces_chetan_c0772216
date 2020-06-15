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
    
//    zoom value for map
    var zoomVal: Double = 1.0
    
//    direction preference mode
    var transitMode: Bool = true
    
//    location manager declaration
    var locationManager = CLLocationManager()
    
//    coordinates to get address location
    var locCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
//    directions variable
    var srcCoordinates: MKMapItem = MKMapItem()
    var destCoordinates: MKMapItem = MKMapItem()
    
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
        let latDelta: CLLocationDegrees = 0.15
        let lngDelta: CLLocationDegrees = 0.15
        
//        create region to show to user
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: locations.last!.coordinate, span: span)
        
//        sets coordinates for source
        let placemark = MKPlacemark(coordinate: locations.last!.coordinate)
        srcCoordinates = MKMapItem(placemark: placemark)
        
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
        
//        sets value for address details
        locCoordinates = desCoordinate
        
//        adds placemark for directions
        let placemark = MKPlacemark(coordinate: desCoordinate)
        destCoordinates = MKMapItem(placemark: placemark)

//           removes previous route
        self.mapView.removeOverlays(self.mapView.overlays)
        
//        removes previous annotation and adds new one
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    
    
//    MARK: zoom map stepper
    @IBAction func zoomMap(_ sender: UIStepper) {
        
        let check: Bool = (sender.value > zoomVal)
        print(sender.value)
        if(check) {
            var region: MKCoordinateRegion = mapView.region
            region.span.latitudeDelta /= 2.0
            region.span.longitudeDelta /= 2.0
            mapView.setRegion(region, animated: true)
            zoomVal += 0.1
        }
        else {
            var region: MKCoordinateRegion = mapView.region
            region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
            region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
            mapView.setRegion(region, animated: true)
            zoomVal -= 0.1
        }
    }
    
    
    
    //    MARK: shows the usage info
    @IBAction func showAlert(_ sender: UIButton) {
        
        let alertMsg = UIAlertController(title: "Ready to add places?", message: "Usage is simple.\n\n1.Just toggle the button above the screen to switch between walking or automobile mode (Highlighted means walking).\n\n2.Press the FindMyWay icon below and see the route.\n\n3.Tap on place flag to see options to add it to your list\n\n4. If you can you can drag the flag to change your place location. Simple!", preferredStyle: .alert)
        alertMsg.addAction(UIAlertAction(title: "Cool!", style: .default))
        self.present(alertMsg, animated: true)
    }
    
    
    
    //    MARK: changes the direction mode
    @IBAction func toggleMode(_ sender: UISwitch) {
        transitMode = !transitMode
        print(transitMode)
    }
    
    
    
    //    MARK: shows directions on clicking the button
    @IBAction func showDirections(_ sender: Any) {
//        creates request
        let dirRequest = MKDirections.Request()
        
//        sets source and destination
        dirRequest.source = srcCoordinates
        dirRequest.destination = destCoordinates
        
//        sets transportation mode
        if(transitMode) {
            dirRequest.transportType = .walking
        }
        else {
            dirRequest.transportType = .automobile
        }
        
//        shows route to destination
        let directions = MKDirections(request: dirRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            
//           removes previous route
            self.mapView.removeOverlays(self.mapView.overlays)
            
//           creates the route
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
//           defining the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        }
    }
}



//MARK: make ui changes
extension ViewController: MKMapViewDelegate {
//     MARK: - change annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        checks if no annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        // add custom annotation with image
        let newAnnotation = self.mapView.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        newAnnotation.image = UIImage(named: "finish")
        newAnnotation.canShowCallout = true
        newAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return newAnnotation
    }
    

//      MARK: - add item annotation view
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Place", message: "This place seems fun!", preferredStyle: .alert)
        let addPlacebutton = UIAlertAction(title: "Add to List", style: .default) { action in
//            calls the method to add data
            self.addPlace()
        }
        let cancelButton = UIAlertAction(title: "Nah", style: .cancel, handler: nil)
        alertController.addAction(addPlacebutton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    
//    MARK: routes overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let line = MKPolylineRenderer(overlay: overlay)
            line.lineWidth = 5
//            sets different line color for each mode
            if(self.transitMode) {
                line.strokeColor = UIColor.green
            }
            else {
                line.strokeColor = UIColor.blue
            }
            return line
        }
        return MKOverlayRenderer()
    }
    
    
    
//    MARK: method to add place to userdefaults
    func addPlace() {
        let geocoder = CLGeocoder()
        
//        convert coordinates to CLLocation to pass as argument
        let point = CLLocation(latitude: locCoordinates.latitude, longitude: locCoordinates.longitude)
//        fetches the result
        geocoder.reverseGeocodeLocation(point) { (placemarks,error) in
            guard let placemark = placemarks?.first else {
                print("No placemark available")
                return
            }
//            takes required value as stores as string
            let locationName = placemark.name ?? ""
            let street = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let zipCode = placemark.postalCode ?? ""
            let country = placemark.country ?? ""
            
            let placeName = "\(locationName) \(street) \(city) \(zipCode) \(country)"
            
//            calls function to store to userdefault
            MyPlaceItem.addPlace(latitude: self.locCoordinates.latitude, longitude: self.locCoordinates.longitude, address: placeName)
        }
        
    }
}



//  MARK: class to store and retrieve the values in userdefaults
public class MyPlaceItem: Codable {
    var latitude: Double
    var longitude: Double
//    stores address
    var name: String
//     constructor
    init(lat : Double, long: Double, name: String) {
        self.latitude = lat
        self.longitude = long
        self.name = name
    }
//      adds new place
    public static func addPlace(latitude: Double, longitude: Double, address: String){
//        new array created as returned array is immutable
        var newPlaceArray = [MyPlaceItem]()
        var oldPlaceArray = [MyPlaceItem]()
        if(self.getPlace() != nil) {
            oldPlaceArray = self.getPlace()!
        }
//        adds new item
        let newPlace = MyPlaceItem(lat: latitude, long: longitude, name: address)
        newPlaceArray = oldPlaceArray
        newPlaceArray.append(newPlace)
        let placeData = try! JSONEncoder().encode(newPlaceArray)
        UserDefaults.standard.set(placeData, forKey: "places")
    }
//      fetching the items
    public static func getPlace() -> [MyPlaceItem]?{
        guard let placeData = UserDefaults.standard.data(forKey: "places") else{ return nil}
        let placeArray = try! JSONDecoder().decode([MyPlaceItem].self, from: placeData)
        return placeArray
    }
}


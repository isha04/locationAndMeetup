//
//  ViewController.swift
//  locationAndJSON
//
//  Created by isha on 8/22/18.
//  Copyright © 2018 isha. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps


protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    var locationManager:CLLocationManager!
    var userLatitude: CLLocationDegrees = 0.0
    var userLongitude: CLLocationDegrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()
        
        let placeSearchResult = storyboard!.instantiateViewController(withIdentifier: "placeSearchResult") as! placeSearchResult
        resultSearchController = UISearchController(searchResultsController: placeSearchResult)
        resultSearchController?.searchResultsUpdater = placeSearchResult
        placeSearchResult.mapView = mapView
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        placeSearchResult.handleMapSearchDelegate = self
    }

   
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 0.10
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            userLongitude = location.coordinate.longitude
            userLatitude = location.coordinate.latitude
            mapView.setRegion(region, animated: true)
        }
        self.mapView.showsUserLocation = true
    }
    
    
    func locationManager(manager: CLLocationManager, _didUpdateHeading status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
        // Notify the user of any errors.
    }

    @IBAction func locateUser(_ sender: UIButton) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    
    @IBAction func seeMeetup(_ sender: UIButton) {
        performSegue(withIdentifier: "seeEvents", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeEvents" {
            if let vc = segue.destination as? meetupViewController  {
                vc.userLatitude = self.userLatitude
                vc.userLongitude = self.userLongitude
            }
        }
    }
    
    
    @objc func getDirections() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let alertController = UIAlertController(title: "Choose Application", message: "", preferredStyle: .actionSheet)
            
            let mapsButton = UIAlertAction(title: "Maps", style: .default, handler: { (action) -> Void in
                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMaps(launchOptions: launchOptions)
            })
            
            let  googleMapsButton = UIAlertAction(title: "Google Maps", style: .default, handler: { (action) -> Void in
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    UIApplication.shared.open(URL(string:
                        "comgooglemaps://?saddr=&daddr=\(selectedPin.coordinate.latitude),\(selectedPin.coordinate.longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
                } else {
                    print("Can't use comgooglemaps://");
                }
            })
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(mapsButton)
            alertController.addAction(googleMapsButton)
            alertController.addAction(cancelButton)
            self.navigationController!.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        locationManager.stopUpdatingLocation()
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.subLocality {
            annotation.subtitle = "\(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.10, 0.10)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}



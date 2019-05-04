//
//  AlertInfoViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AlertInfoViewController: UIViewController, CLLocationManagerDelegate {
    var alert: [String:Any] = [:]
    var alertLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var doctorLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    let locationManager = CLLocationManager();
    var alertMarker = MKPointAnnotation();
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var symptoms: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.descriptionText.text = self.alert["description"] as! String;
        self.alertLocation = CLLocation(latitude: self.alert["latitude"] as! CLLocationDegrees, longitude:self.alert["longitude"] as! CLLocationDegrees)
        self.distance.text = String(format:"%f", doctorLocation.distance(from: alertLocation))
        
        // not sure if this view needs to request location permissions again? leaving it out for now.
        
        if (CLLocationManager.locationServicesEnabled()) {
            // set delegate, accuracy
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.startUpdatingLocation();
        }
        mapView.showsUserLocation = true;
        mapView.showsPointsOfInterest = false;
        mapView.addAnnotation(alertMarker);
        alertMarker.title = "Alert";
    }
    
    // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
         manager: "location manager obj that generated the update event"
         locations: array of CLLocations. always contains at least 1 element representing current location.
         if updates were deferred or multiple locations arrived before they could be delivered, array contains
         additional entries (in order they occurred. most recent at the end).
         */
        doctorLocation = locations[locations.endIndex - 1];
        updateDoctorLoc();
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription);
    }
    
    func updateDoctorLoc() {
        // getting CLLocationCoordinate2D instead of CLLocation cause it's shorter to access latitude and longitude
        let docLoc2D = doctorLocation.coordinate;
        let alertLoc2D = alertLocation.coordinate;
        // find distance between doctor and given alert location to establish regionRadius
        let distanceBetweenCoordinates = alertLocation.distance(from: doctorLocation);
        // set zoom distance to max of 100m and one computed above (don't want to zoom in too close as doctor approaches)
        let regionRadius = max(distanceBetweenCoordinates, 100);
        
        // update marker position to given alert coordinates
        alertMarker.coordinate = CLLocationCoordinate2D(latitude: alertLocation.coordinate.latitude, longitude: alertLocation.coordinate.longitude);
        
        // recenter map between the two
        var center = CLLocationCoordinate2D(latitude: docLoc2D.latitude, longitude: docLoc2D.longitude);
        if (docLoc2D.latitude > alertLoc2D.latitude) {
            center.latitude -= (docLoc2D.latitude - alertLoc2D.latitude)/2;
        } else {
            center.latitude += (alertLoc2D.latitude - docLoc2D.latitude)/2;
        }
        if (docLoc2D.longitude > alertLoc2D.longitude) {
            center.longitude -= (docLoc2D.longitude - alertLoc2D.longitude)/2;
        } else {
            center.longitude += (alertLoc2D.longitude - docLoc2D.longitude)/2;
        }
        let coordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius);
        mapView.setRegion(coordinateRegion, animated: true);
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

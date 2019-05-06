//
//  PatientAlertViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class PatientAlertViewController: UIViewController, CLLocationManagerDelegate {

    var alert: [String:Any] = [:]
    var doctor: [String:Any] = [:]
    let locationManager = CLLocationManager();
    var docMarker = MKPointAnnotation();
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.doctor)
        // Do any additional setup after loading the view.
        
        if (CLLocationManager.locationServicesEnabled()) {
            // set delegate, accuracy
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.startUpdatingLocation();
        }
        mapView.showsUserLocation = true;
        mapView.showsPointsOfInterest = false;
        mapView.addAnnotation(docMarker);
        docMarker.title = "Doctor";
    }
    
    // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
         manager: "location manager obj that generated the update event"
         locations: array of CLLocations. always contains at least 1 element representing current location.
         if updates were deferred or multiple locations arrived before they could be delivered, array contains
         additional entries (in order they occurred. most recent at the end).
         */
        // locations[locations.endIndex - 1];
        updateDoctorLoc();
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription);
    }
    
    func updateDoctorLoc() {
        let docLat = doctor["latitude"] as! CLLocationDegrees;
        let docLong = doctor["longitude"] as! CLLocationDegrees;
        let docLoc2D = CLLocationCoordinate2D(latitude: docLat, longitude: docLong);
        
        // location of alert is user's current location
        let alertLoc2D = mapView.userLocation.coordinate;
        // find distance between doctor and given alert location to establish regionRadius
        let distanceBetweenCoordinates = CLLocation(latitude: docLat, longitude: docLong).distance(from: CLLocation(latitude: alertLoc2D.latitude, longitude: alertLoc2D.longitude));
        // set zoom distance to max of 100m and one computed above (plus a bit so markers are not right on the edge)
        let regionRadius = max(distanceBetweenCoordinates*1.1, 100);
        
        // update marker position to given alert coordinates
        docMarker.coordinate = CLLocationCoordinate2D(latitude: docLat, longitude: docLong);
        
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

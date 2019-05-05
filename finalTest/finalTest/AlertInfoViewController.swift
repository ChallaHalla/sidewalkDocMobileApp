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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var alert: [String:Any] = [:]
    var alertLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var doctorLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    let locationManager = CLLocationManager();
    var alertMarker = MKPointAnnotation();
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var symptoms: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let alertView = segue.destination as? ResolveAlertViewController {
            alertView.alert = self.alert
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.descriptionText.text = self.alert["description"] as! String;
        let tagsArr = self.alert["tags"] as? [String]
        self.symptoms.text = tagsArr!.joined(separator:", ")
        self.alertLocation = CLLocation(latitude: self.alert["latitude"] as! CLLocationDegrees, longitude:self.alert["longitude"] as! CLLocationDegrees)
//        distance converted to miles
        self.distance.text = String(format:"%.2f", doctorLocation.distance(from: alertLocation)*0.00062137) + " miles"
        
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
        // set zoom distance to max of 100m and one computed above (plus a bit so markers are not right on the edge)
        let regionRadius = max(distanceBetweenCoordinates*1.1, 100);
        
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
    
    @IBAction func acceptAlert(_ sender: Any) {
        respondToAlert()
    }
    
    @IBAction func rejectAlert(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "infoToFindAlertsSegue", sender: self)
        }
    }
    func respondToAlert(){
        
        print("trying to respond")
        print(self.alert["_id"])
        let urlString = self.appDelegate.endpoint+"/respondToAlert"
        
        
        var params: [String: Any] = ["doctorId": self.appDelegate.userId as? String ,"alertId":self.alert["_id"]]
        
        let requestBody = try? JSONSerialization.data(withJSONObject: params)
        
        var request = URLRequest(url:URL(string: urlString)!)
        request.httpBody = requestBody
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else {
                print("in guard")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                print(json["status"]!)
                if((json["status"]! as AnyObject).isEqual("success")){
                    print("back here")
                    // perform segue
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "resolveAlertSegue", sender: self)
                    }
                    
                    
                    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
                    {
                        UIApplication.shared.openURL(NSURL(string:
                            "comgooglemaps://?saddr=&daddr=\(Float(self.alert["latitude"] as! CLLocationDegrees)),\(Float(self.alert["latitude"] as! CLLocationDegrees))&directionsmode=driving")! as URL)
                    } else
                    {
                        NSLog("Can't use com.google.maps://");
                        self.openTrackerInBrowser()
                    }
                    
                    
                } else{
                    print("something went wrong")
                }
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
        
    }
    func openTrackerInBrowser(){
        if let urlDestination = URL.init(string: "https://www.google.com/maps/dir/?saddr=&daddr=\(Float(self.alert["latitude"] as! CLLocationDegrees)),\(Float(self.alert["longitude"] as! CLLocationDegrees))&directionsmode=driving") {
            UIApplication.shared.openURL(urlDestination)
        }
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

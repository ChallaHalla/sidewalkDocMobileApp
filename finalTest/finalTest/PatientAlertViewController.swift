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

    let locationManager = CLLocationManager();
    var docMarker = MKPointAnnotation();
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            print("timer loop")
            self?.getAlert()
            self?.updateDoctorLoc()
        }
    }
    
    
    // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateDoctorLoc();
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription);
    }
    
    func updateDoctorLoc() {
        let docLat = self.appDelegate.doctor!["latitude"] as! CLLocationDegrees;
        let docLong = self.appDelegate.doctor!["longitude"] as! CLLocationDegrees;
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
    
    func getAlert(){
        print("refreshing alert")
        var components = URLComponents(string: self.appDelegate.endpoint+"/getAlert")!
        components.queryItems = [
            URLQueryItem(name: "alertId", value: self.appDelegate.alert!["_id"] as! String)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else {
                print("in guard")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                print(json["status"]!)
                if((json["status"]! as AnyObject).isEqual("success")){
                    self.appDelegate.alert = json["alert"] as! [String:Any]
                    self.appDelegate.doctor = json["doctor"] as! [String:Any]
                    
                    if(self.appDelegate.alert!["resolved"] as! Bool == true){
                        self.timer?.invalidate()
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "resolvePatientAlertSegue", sender: self)
                        }
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
    @IBAction func resolveAlert(_ sender: Any) {
        let urlString = self.appDelegate.endpoint+"/resolveAlert"
        let params: [String: Any] = ["alertId": self.appDelegate.alert!["_id"] as! String]
        
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
                
                if((json["status"]! as AnyObject).isEqual("success")){
                    self.timer?.invalidate()
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "resolvePatientAlertSegue", sender: self)
                    }
                } else{
                    print("could not resolve alert")
                }
                
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
        
    }
    
    @IBAction func editAlert(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "alertEditSegue", sender: self)
        }
    }
}

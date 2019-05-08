//
//  ResolveAlertViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import CoreLocation

class ResolveAlertViewController: UIViewController, CLLocationManagerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var descriptionText: UITextView!
    var alert: [String:Any] = [:]
    
    @IBOutlet weak var symptoms: UITextView!
    
    let locationManager = CLLocationManager();
    var latitude = 0.0;
    var longitude = 0.0;
    weak var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization();
        locationManager.requestWhenInUseAuthorization();
        if (CLLocationManager.locationServicesEnabled()) {
            // set delegate, accuracy
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.startUpdatingLocation();
        }

        
        self.descriptionText.text = self.alert["description"] as! String;
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
            // send lat and long to backend
            self.updateDocLocation()
            self.descriptionText.text = self.alert["description"] as! String
            let tagsArr =  self.alert["tags"] as! [String]
            self.symptoms.text = "\u{2022}" +  tagsArr.joined(separator:"\n\u{2022}")
//            self.symptoms.sizeToFit()
            print("time")
        }
        self.openTrackerInBrowser()
//        self.symptoms.text = self.alert["tags"] as! String;

        // update doc lation every x seconds in bg
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*
         manager: "location manager obj that generated the update event"
         locations: array of CLLocations. always contains at least 1 element representing current location.
         if updates were deferred or multiple locations arrived before they could be delivered, array contains
         additional entries (in order they occurred. most recent at the end).
         */
        let mostRecentLocationIndex = locations.count - 1;
        let lastKnownUserLocation = locations[mostRecentLocationIndex]
        
        self.latitude = lastKnownUserLocation.coordinate.latitude
        self.longitude = lastKnownUserLocation.coordinate.longitude
    }
    
    func updateDocLocation(){
        print("udate loc")
        let urlString = self.appDelegate.endpoint+"/updateDocLocation"
        
        print(self.latitude)
        print(self.longitude)
        var params: [String: Any] = ["doctorId": self.appDelegate.userId, "latitude": self.latitude, "longitude": self.longitude, "alertId": self.alert["_id"]]
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
                    self.alert = json["alert"] as! [String:Any]
                    if(self.alert["resolved"] as! Bool == true){
                        self.timer?.invalidate()
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "resolveAlertSegue", sender: self)
                        }
                    }
                    print("updated succesfully")
                } else{
                    print("something is wrong")
                }
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
        
    }
    
    
    @IBAction func resolveAlert(_ sender: Any) {
        let urlString = self.appDelegate.endpoint+"/resolveAlert"
        let params: [String: Any] = ["alertId": self.alert["_id"] as! String]
        
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
                        self.performSegue(withIdentifier: "resolveAlertSegue", sender: self)
                    }
                } else{
                    print("could not resolve alert")
                    // should it still return to alert creation view if it fails?
                }
                
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
    
    }
    
    func openTrackerInBrowser(){
        UIApplication.shared.openURL(NSURL(string:
            "comgooglemaps://?saddr=&daddr=\(self.alert["latitude"]!),\(self.alert["longitude"]!)&directionsmode=driving")! as URL)
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



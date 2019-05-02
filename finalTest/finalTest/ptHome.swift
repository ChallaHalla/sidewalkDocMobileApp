//
//  ptHome.swift
//  finalTest
//
//  Created by Soaptarshi Paul on 4/24/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import CoreLocation

class ptHome: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UITableViewDelegate {
    
    let tags = ["Faint/no heartbeat", "Broken appendage", "Not breathing", "Heart attack", "Stroke", "Allergic reaction", "Car accident", "Fainting", "Heat stroke"]
    
    // selectedTags holds all the tags the user selects - this needs to be added to the alert
    var selectedTags: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        
        let text = tags[indexPath.row] //2.
        
        cell.textLabel?.text = text //3.
        
        return cell //4.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            
            if let index = selectedTags.index(of: tags[indexPath.row]) {
                selectedTags.remove(at: index)
            }
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            selectedTags.append(tags[indexPath.row])
        }
    }
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let locationManager = CLLocationManager();
    var latitude = 0.0;
    var longitude = 0.0;

    

    @IBOutlet weak var desc: UITextView!
    
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
        // Input the data into the array
        // Do any additional setup after loading the view.
    
        
        tableView.dataSource = self
        tableView.delegate = self
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
        
        // when updated user location is received:
        // if there is not a doctor on the way (AKA no active alert), recenter map on new user location
        // if there is an active alert/doctor, recenter map between doctor info and new user info
//        if (!activeAlert) {
//            centerOnLocation(location: mapView.userLocation.coordinate);
//        } else {
//            updateDoctorLoc(docLocation: lastKnownDocLocation);
//        }
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func alertCreation(_ sender: Any) {
        createAlert()
    }
    
    func createAlert(){
        let urlString = self.appDelegate.endpoint+"/createAlert"
        var params: [String: Any] = ["description": self.desc.text, "latitude": self.latitude, "longitude": self.longitude,
        "userId": self.appDelegate.userId]
        
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
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "alertWaitSegue", sender: self)
                    }
                } else{
                    print("incorrect credentials")
                }
                
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
    }
    @IBAction func tagTableView(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "tagSegue", sender: self)
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

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
    
    var alert: [String:Any] = [:]
    
    let tags = ["Faint/no heartbeat", "Broken appendage", "Not breathing", "Heart attack", "Stroke", "Allergic reaction", "Car accident", "Fainting", "Heat stroke"]
    var selectedTags: [String] = []
    
    let defaults = UserDefaults.standard
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager();
    var latitude = 0.0;
    var longitude = 0.0;
    @IBOutlet weak var desc: UITextView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        locationManager.requestAlwaysAuthorization();
        locationManager.requestWhenInUseAuthorization();
        if (CLLocationManager.locationServicesEnabled()) {
            // set delegate, accuracy
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.startUpdatingLocation();
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mostRecentLocationIndex = locations.count - 1;
        let lastKnownUserLocation = locations[mostRecentLocationIndex]
        self.latitude = lastKnownUserLocation.coordinate.latitude
        self.longitude = lastKnownUserLocation.coordinate.longitude
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func alertCreation(_ sender: Any) {
        self.createAlert()
    }
    
    func createAlert(){
        let urlString = self.appDelegate.endpoint+"/createAlert"
        var params: [String: Any] = ["description": self.desc.text, "latitude": self.latitude, "longitude": self.longitude, "userId": self.appDelegate.userId, "tags":self.selectedTags as? [String]]
        
        let requestBody = try? JSONSerialization.data(withJSONObject: params)
        
        var request = URLRequest(url:URL(string: urlString)!)
        request.httpBody = requestBody
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                
                if((json["status"]! as AnyObject).isEqual("success")){
                    self.appDelegate.alert = (json["alert"] as? [String:Any])!
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

    
    @IBAction func logout(_ sender: Any) {
        defaults.set(nil, forKey:"userType")
        defaults.set(nil, forKey:"username")
        defaults.set(nil, forKey:"password")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "patientLogoutSegue", sender: self)
        }
    }
    
}

//
//  EditAlertViewController.swift
//  finalTest
//
//  Created by dsadmin on 5/7/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import CoreLocation

class EditAlertViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UITableViewDelegate  {
    
    var alert: [String:Any] = [:]
    var doctor: [String:Any] = [:]
    
    let tags = ["Faint/no heartbeat", "Broken appendage", "Not breathing", "Heart attack", "Stroke", "Allergic reaction", "Car accident", "Fainting", "Heat stroke"]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager();
    var latitude = 0.0;
    var longitude = 0.0;
    
    // selectedTags holds all the tags the user selects - this needs to be added to the alert
    var selectedTags: [String] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let alertView = segue.destination as? PatientAlertViewController {
            alertView.alert = self.alert
            alertView.doctor = self.doctor
        }
        if let alertView = segue.destination as? PairAlertViewController {
            alertView.alert = self.alert
            alertView.doctor = self.doctor
        }
    }
    
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
    
    
    @IBOutlet weak var desc: UITextView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for tag in self.selectedTags{
            let index = self.tags.firstIndex(of: tag)
            self.tableView.cellForRow(at: IndexPath(row: index!, section: 0))?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        print(self.alert)
        self.selectedTags = self.alert["tags"] as! [String]
        self.desc.text = self.alert["description"] as! String
        
        
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
        let mostRecentLocationIndex = locations.count - 1;
        let lastKnownUserLocation = locations[mostRecentLocationIndex]
        
        self.latitude = lastKnownUserLocation.coordinate.latitude
        self.longitude = lastKnownUserLocation.coordinate.longitude
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func updateAlert(_ sender: Any) {
        print(self.selectedTags)
        createAlert()
    }
    
    func createAlert(){
        let urlString = self.appDelegate.endpoint+"/updateAlert"
        var params: [String: Any] = ["alertId":self.alert["_id"] ,"description": self.desc.text,                                     "tags":self.selectedTags as? [String]]
        
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
                    self.alert = (json["alert"] as? [String:Any])!
                    DispatchQueue.main.async {
                        if self.presentingViewController is PatientAlertViewController{
                            self.performSegue(withIdentifier: "editAlertSegue", sender: self)
                            
                        }
                        if self.presentingViewController is PairAlertViewController{
                            self.performSegue(withIdentifier: "editToPairSegue", sender: self)
                        }
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

}

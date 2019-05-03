//
//  FindAlertsViewController.swift
//  finalTest
//
//  Created by dsadmin on 5/2/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import CoreLocation

class FindAlertsViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let locationManager = CLLocationManager();
    var latitude = 0.0;
    var longitude = 0.0;
    var alerts:[[String:Any]] = []
    
    
    
    var alertTable = ["Alert1","Alert2"]
    
    
    // selectedAlert holds the selected string from alertTable
    var selectedAlert = -1
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let alertView = segue.destination as? AlertInfoViewController {
            alertView.alert = alerts[selectedAlert]
            alertView.doctorLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        
        let text = alertTable[indexPath.row] //2.
        
        cell.textLabel?.text = text //3.
        
        return cell //4.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedAlert = indexPath.row
        print(selectedAlert)
        
        performSegue(withIdentifier: "alertInfoSegue", sender: self)
    }

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
        
        // latitude not updated in time for get alerts so initially none are found. need to fix
        getalerts();
       
        
        
        // Add the label to the view controller's root 
        

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
        
    }
    func getalerts(){
        print("entered get alerts")
        
        var components = URLComponents(string: self.appDelegate.endpoint+"/nearbyAlerts")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(format:"%f", self.latitude)),
            URLQueryItem(name: "longitude", value: String(format:"%f", self.longitude))
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        
        
        request.httpMethod = "GET"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        
        URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else {
                print("in guard")
                return
            }
            
            do {
                print("entered");
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                print(json["status"]!)
                if((json["status"]! as AnyObject).isEqual("success")){
                    self.alerts = json["alerts"] as! [[String:Any]]
                    print(self.alerts.count)
                    self.alertTable = []
                    for i in 0..<(self.alerts.count){
                        var alert = self.alerts[i]
                        self.alertTable.append(alert["description"] as! String)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
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
    

    @IBAction func getAlertsButton(_ sender: Any) {
        print("entered");
        getalerts();
    }
    
     @IBAction func selectAlert(_ sender:UIButton!){
        print("HERE in select alert")
        let alertIndex = sender.tag
        let urlString = self.appDelegate.endpoint+"/respondToAlert"
        let alert = self.alerts[alertIndex]
        var params: [String: Any] = ["alertId": alert["_id"]]
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
                print("entered");
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                
                if((json["status"]! as AnyObject).isEqual("success")){
                    print("alert accepted!")
                } else{
                    print("something went wrong credentials")
                }
                
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
        
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

//
//  AlertInfoViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 5/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import CoreLocation

class AlertInfoViewController: UIViewController {
    var alert: [String:Any] = [:]
    var alertLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var doctorLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var symptoms: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.descriptionText.text = self.alert["description"] as! String;
        self.alertLocation = CLLocation(latitude: self.alert["latitude"] as! CLLocationDegrees, longitude:self.alert["longitude"] as! CLLocationDegrees)
        self.distance.text = String(format:"%f", doctorLocation.distance(from: alertLocation))
        
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

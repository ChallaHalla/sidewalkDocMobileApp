//
//  PairAlertViewController.swift
//  finalTest
//
//  Created by Soaptarshi Paul on 4/29/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class PairAlertViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var alert: [String:Any] = [:]
    var doctor: [String:Any] = [:]
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let alertView = segue.destination as? PatientAlertViewController {
            alertView.alert = self.alert
            alertView.doctor = self.doctor
        }
        if let alertView = segue.destination as? EditAlertViewController {
            alertView.alert = self.alert
            alertView.doctor = self.doctor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(alert)
        // Do any additional setup after loading the view.
        startTimer()
    }
    weak var timer: Timer?
    
    func startTimer() {
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            print("AGIN")
            self?.getAlert()
        }
    }
    
    func getAlert(){
        print("refreshing alert")
        print(self.alert)
        var components = URLComponents(string: self.appDelegate.endpoint+"/getAlert")!
        components.queryItems = [
            URLQueryItem(name: "alertId", value: self.alert["_id"] as! String)
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
                    self.alert = json["alert"] as! [String:Any]
                    
                    // go to next screen if doctor not null
                    print(self.alert["doctor"]! as? String)
                    if(self.alert["doctor"]! as? String != nil){
                        self.doctor = json["doctor"] as! [String:Any]
                        self.timer?.invalidate()
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "doctorPairedSegue", sender: self)
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

    @IBAction func editAlert(_ sender: Any) {
        self.timer?.invalidate()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "editAlertSegue", sender: self)
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

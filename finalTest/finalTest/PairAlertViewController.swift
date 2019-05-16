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
    weak var timer: Timer?
    var alert:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load pair")
        self.alert = self.appDelegate.alert!
        self.startTimer()
    }
    
    func startTimer() {
        print("start timer")
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            print("timer loop")
            self?.getAlert()
        }
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
                    self.alert = self.appDelegate.alert!

                    // go to next screen if doctor not null
                    if(self.appDelegate.alert!["doctor"]! as? String != nil){
                        self.appDelegate.doctor = json["doctor"] as! [String:Any]
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
}

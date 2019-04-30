//
//  ViewController.swift
//  finalTest
//
//  Created by Soaptarshi Paul on 4/3/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    let endpoint = "http://192.168.1.154:3000"

    
    @IBOutlet weak var usernameInput: UITextField!

    @IBOutlet weak var passwordInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func providerEnter(_ sender: Any) {
        login(userType: "provider")
//        self.performSegue(withIdentifier: "providerSegue", sender: self)

    }
    
    @IBAction func patientEnter(_ sender: Any) {
        login(userType: "patient")
    }
    
    func login(userType:String){
        print("Perform login here")
        let username: String = usernameInput.text!
        let password: String = passwordInput.text!
        let urlString = endpoint+"/login"
        
     
        let requestLang: [String: Any] = ["username": username, "password": password]
        let requestBody = try? JSONSerialization.data(withJSONObject: requestLang)

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
                print("logged in")
                if(userType == "patient" && (json["status"]! as AnyObject).isEqual("cool")){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "ptHomesegue", sender: self)
                    }
                } else if(userType == "provider" && (json["status"]! as AnyObject).isEqual("cool")){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "providerSegue", sender: self)
                    }
                } else{
                    print("NUFFIN")
                }
                
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
        
    }
    
}


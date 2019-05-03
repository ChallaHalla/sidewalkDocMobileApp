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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var usernameInput: UITextField!

    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var loginHeader: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        
        self.appDelegate.checkCredentials = -1
    }
    
    
    @IBAction func providerEnter(_ sender: Any) {
        login(userType: "provider")
//        self.performSegue(withIdentifier: "providerSegue", sender: self)
        
        if self.appDelegate.checkCredentials == 1{
            self.loginHeader.text = "Invalid credentials. Try again"
        }

    }
    
    @IBAction func patientEnter(_ sender: Any) {
        login(userType: "patient")
        
        if self.appDelegate.checkCredentials == 1{
            self.loginHeader.text = "Invalid credentials. Try again"
        }
    }
    
    @IBAction func register(_ sender: Any) {
         self.performSegue(withIdentifier: "registerSegue", sender: self)
    }
    func login(userType:String){
        print("Perform login heres")
        let username: String = usernameInput.text!
        let password: String = passwordInput.text!
        let urlString = self.appDelegate.endpoint+"/login"
        
     
        var params: [String: Any] = ["username": username, "password": password]
        if(userType == "patient"){
            params["patient"] = "on"
        } else{
            params["doctor"] = "on"
        }
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
                    self.appDelegate.userId = json["userId"]! as! String
                    if(userType == "patient"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "ptHomesegue", sender: self)
                        }
                    } else if(userType == "provider"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "providerSegue", sender: self)
                        }
                    }
                } else{
                    print("incorrect credentials")
                    self.appDelegate.checkCredentials = 1
                    
                }
            } catch let error as NSError {
                print("in catch")
                print(error)
            }
        }).resume()
        
    }
    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


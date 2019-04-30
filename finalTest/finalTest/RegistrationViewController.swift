//
//  RegistrationViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 4/30/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    let endpoint = "http://192.168.1.154:3000"

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var userType: UIButton!
    
    
    @IBAction func userTypeClick(_ sender: Any) {
        if(userType.currentTitle! == "doctor"){
            userType.setTitle("patient", for: .normal)
        } else{
            userType.setTitle("doctor", for: .normal)
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        register(userType: userType.currentTitle!)
    }
    func register(userType:String){
        print("Perform login here")
        let username: String = usernameInput.text!
        let password: String = passwordInput.text!
        let name: String = nameInput.text!
        let urlString = endpoint+"/register"
        
        
        let params: [String: Any] = ["username": username, "password": password, "name": name]
//        add location info here
        
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
                print("logged in")
                if(userType == "patient" && (json["status"]! as AnyObject).isEqual("account created")){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "regToPatientSegue", sender: self)
                    }
                } else if(userType == "provider" && (json["status"]! as AnyObject).isEqual("account created")){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "regToDoctorSegue", sender: self)
                    }
                } else{
                    print("a problem occured")
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

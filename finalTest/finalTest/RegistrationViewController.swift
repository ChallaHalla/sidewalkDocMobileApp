//
//  RegistrationViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 4/30/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var registrationType = "provider"
    
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var userType: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var registerHeader: UILabel!
    
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = ["Internal Medicine", "Pediatrics", "Ob/Gyn", "Surgery", "Dermatology", "Emergency Medicine"]
        
        self.appDelegate.checkAccounts = -1
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Call this function to return the selected specialty
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    @IBAction func indexChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            registrationType = "provider"
            picker.isHidden = false;
        case 1:
            registrationType = "patient"
            // hide picker
            picker.isHidden = true;
        default:
            break
        }
    }
    
    @IBAction func userTypeClick(_ sender: Any) {
        if(userType.currentTitle! == "doctor"){
            userType.setTitle("patient", for: .normal)
        } else{
            userType.setTitle("doctor", for: .normal)
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        register(userType: registrationType)
        
        if self.appDelegate.checkAccounts == 1{
            self.registerHeader.text = "A problem ocurred. Try again"
        }
    }
    
    func register(userType:String){
        let username: String = usernameInput.text!
        let password: String = passwordInput.text!
        let name: String = nameInput.text!
        let urlString = self.appDelegate.endpoint+"/register"
        
        
        var params: [String: Any] = ["username": username, "password": password, "name": name]
        if(userType == "provider"){
            params["doctor"] = "on"
        } else if(userType == "patient"){
            params["patient"] = "on"
        }
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
                print(json["status"]!);
                if((json["status"]! as AnyObject).isEqual("account created")){
                    self.appDelegate.userId = json["userId"]! as! String
                    if(userType == "patient"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "regToPatientSegue", sender: self)
                        }
                        
                    } else if(userType == "provider"){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "regToDoctorSegue", sender: self)
                        }
                    }
                } else{
                    print("a problem occured")
                    
                    self.appDelegate.checkAccounts = 1
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

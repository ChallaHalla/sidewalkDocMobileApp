//
//  ResolveAlertViewController.swift
//  finalTest
//
//  Created by Siddarth Challa1 on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class ResolveAlertViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var descriptionText: UILabel!
    var alert: [String:Any] = [:]
    
    @IBOutlet weak var symptoms: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.descriptionText.text = self.alert["description"] as! String;
//        self.symptoms.text = self.alert["tags"] as! String;

        // make function to request updat eevery x seconds
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

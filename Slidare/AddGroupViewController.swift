//
//  AddGroupViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 07/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import Alamofire

class AddGroupViewController: UIViewController{
    
    var userToken: String = "";
    var userId: String = "";
    
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var messageSuccess: UILabel!

    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        view.addGestureRecognizer(tap)
        
    }
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func createGroup()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
            "name": self.groupName.text! as AnyObject]
        
        
        Alamofire.request("http://54.224.110.79:50000/createGroup", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                self.messageSuccess.text = "Group successfully created"
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.messageSuccess.text = "Your request failed"
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
                }
        }

    }
    
    
    @IBAction func createAction(_ sender: Any) {
        createGroup()
    }
    
    

    
}

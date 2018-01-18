//
//  AddContactViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 06/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AddContactViewController: UIViewController{
    
    var userToken: String = "";
    var userId: String = "";
    

    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var successMessage: UILabel!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
       buttonAdd.layer.cornerRadius = 5
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        view.addGestureRecognizer(tap)
        
    }

  
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func addContact()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
            "email": self.email.text! as AnyObject]
        
        
        Alamofire.request("http://34.238.153.180:50000/addContact", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                self.successMessage.text = "Contact successfully added"
                //self.displayContact()
            // self.contactId = response["id"] as! String
            case .failure(let error):
                print("Request failed with error: \(error)")
                
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                    self.successMessage.text = json
                }
                }
        }
        
    }
    
    
    @IBAction func addAction(_ sender: Any) {
        addContact();
    }

}

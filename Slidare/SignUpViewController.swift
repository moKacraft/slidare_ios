//
//  SignUpViewController.swift
//  Slidare
//
//  Created by JulienSup on 31/07/16.
//  Copyright © 2016 Julien. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var Passwords: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var failureMessage: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confPassword: UITextField!
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
                view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    @IBAction func accountCreatePressed(_ sender: AnyObject) {
        if (password.text! == confPassword.text! ) {
            Passwords.text = ""
            createUser()
        }
        else if ((firstName.text?.isEmpty)! && (lastName.text?.isEmpty)! && (email.text?.isEmpty)! && (password.text?.isEmpty)! && (confPassword.text?.isEmpty)!)
        {
            failureMessage.text = "Text does not filled"
        }
        else {
            Passwords.text = "Password does not match"
            
        }

        
    }
    
    func createUser() {
        let parameters: [String: AnyObject]
        parameters = [
            "first_name": firstName.text! as! AnyObject,
            "last_name": lastName.text! as! AnyObject,
            "email": email.text! as! AnyObject,
            "password": confPassword.text! as! AnyObject]
        Alamofire.request("http://34.227.142.101:50000/createUser", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
                let response = JSON as! NSDictionary
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.userId = response.object(forKey: "id") as! String
                appDelegate.userToken = response.object(forKey: "token") as! String
                
                let internVC = self.storyboard?.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                self.present(internVC, animated: true, completion: nil)
                
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    self.failureMessage.text = json
                    print("Failure Response: \(json)")
                }
            }
        }
    }
}

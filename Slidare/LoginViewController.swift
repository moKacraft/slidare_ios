//
//  ViewController.swift
//  Slidare
//
//  Created by JulienSup on 04/06/16.
//  Copyright © 2016 Julien. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */

    @IBOutlet weak var myFirstLabel: UILabel!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func signInPressed(_ sender: AnyObject) {
        loginOnApi(email.text!, password: password.text!, firstName: "", lastName: "")
        
    }
    
    @IBAction func SignUpPressed(_ sender: AnyObject) {
        let internVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.present(internVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        

        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        facebookButton.readPermissions = ["public_profile", "email", "user_friends"];
        facebookButton.delegate = self
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!){

        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email"]).start { (connection, result, error) -> Void in
            let data:[String:AnyObject] = result as! [String : AnyObject]
            let email: String = data["email"] as! String
            let firstName: String = data["first_name"] as! String
            let lastName: String = data["last_name"] as! String

            self.loginOnApi(email, password: "", firstName: firstName, lastName: lastName)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
    }
    
    func loginOnApi(_ email: String, password: String, firstName: String, lastName: String) {
        let parameters: [String: AnyObject];
        if (FBSDKAccessToken.current() != nil) {
            parameters = [
            "email": email as AnyObject,
            "first_name": firstName as AnyObject,
            "last_name": lastName as AnyObject,
            "fb_token": FBSDKAccessToken.current().tokenString as AnyObject,
            "fb_user_id": FBSDKAccessToken.current().userID as AnyObject]
        } else {
            parameters = [
                "email": email as AnyObject,
                "password": password as AnyObject]
        }
        Alamofire.request("http://34.227.142.101:50000/loginUser", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
                let response = JSON as! NSDictionary
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.userId = response.object(forKey: "id") as! String
                appDelegate.userToken = response.object(forKey: "token") as! String
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let internVC = storyboard.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                self.present(internVC, animated: true, completion: nil)
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                    self.errorMessage.text = "Wrong email/password"
                }
            }
        }
    }
}


//
//  SplashScreenViewController.swift
//  Slidare
//
//  Created by JulienSup on 19/06/16.
//  Copyright © 2016 Julien. All rights reserved.
//

import UIKit
import Alamofire

class SplashScreenViewController: UIViewController {
    var newViewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(
            timeInterval: 2.5, target: self, selector: #selector(SplashScreenViewController.myShow), userInfo: nil, repeats: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func myShow() {
        if (FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email"]).start { (connection, result, error) -> Void in
                let data:[String:AnyObject] = result as! [String : AnyObject]
                let email: String = data["email"] as! String
                let firstName: String = data["first_name"] as! String
                let lastName: String = data["last_name"] as! String
                
                self.loginOnApi(firstName, lastName: lastName, email: email)
            }

            
        } else {
            newViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as!LoginViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    func loginOnApi(_ firstName: String, lastName: String, email: String) {
        let parameters: [String: AnyObject]
        
        parameters = ([
            "first_name": firstName as AnyObject,
            "last_name": lastName  as AnyObject,
            "email": email  as AnyObject,
            "fb_token": FBSDKAccessToken.current().tokenString  as AnyObject,
            "fb_user_id": FBSDKAccessToken.current().userID]  as AnyObject) as! [String : AnyObject]
        Alamofire.request("http://54.224.110.79:50000/loginUser", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                //                print("Success with JSON: \(JSON)")
                
                let response = JSON as! NSDictionary
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.userId = response.object(forKey: "id") as! String
                appDelegate.userToken = response.object(forKey: "token") as! String
                
                let internVC = self.storyboard?.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                //                internVC.initUserData(firstName, lastname: lastName, email: email, pictureUrl: url!);
                self.present(internVC, animated: true, completion: nil)
                
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
            }
        }
    }

}

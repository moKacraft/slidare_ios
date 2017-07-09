//
//  MainPageViewController.swift
//  Slidare
//
//  Created by JulienSup on 12/06/16.
//  Copyright © 2016 Julien. All rights reserved.
//

import Foundation
import Alamofire

class MainPageViewController: UIViewController {
    @IBOutlet weak var facebookLogout: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var settingsButton: UIButton!
    var userToken: String = "";
    var userId: String = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        getUser()
        /*let image = UIImage(named : "userdefault")
        settingsButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        settingsButton.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)*/


        
    //        print(appDelegate.userToken)
//        print(appDelegate.userId)
    }

    
    @IBAction func fetchContacts(_ sender: AnyObject) {
        let headers = ["Authorization": "Bearer \(userToken)"]
        

        Alamofire.request("http://54.224.110.79:50000/userContacts", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
            }
        }
    }
    
    func getUser()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        Alamofire.request("http://54.224.110.79:50000/fetchUser", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary

                if (response["profile_picture_url"] as? String) != nil {
                    self.getProfilePicture(response["profile_picture_url"] as! String)
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
                }
        }

    }
    func getProfilePicture(_ url:String)
    {
        let url = URL(string: url)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            DispatchQueue.main.async(execute: {
                self.profilePicture.image = UIImage(data: data!)
            });
        }

    }

    
    internal func initUserData(_ firstname : String, lastname : String, email: String, pictureUrl : URL) -> Void {
        print(firstname, lastname, email, pictureUrl.absoluteString);
    }
    @IBAction func facebookLogoutPressed(_ sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let internVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.show(internVC, sender: internVC)
    }
}

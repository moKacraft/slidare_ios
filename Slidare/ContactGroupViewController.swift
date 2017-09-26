//
//  ContactGroupViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 07/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation

import UIKit
import Alamofire


class ContactGroupViewController: UIViewController{
    
    var userToken: String = "";
    var userId: String = "";
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var groupView: UIView!
 
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        view.addGestureRecognizer(tap)
        self.contactView.alpha = 1
         self.groupView.alpha = 0
        getUser()
        

        
    }

    func getUser()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        Alamofire.request("http://34.227.142.101:50000/fetchUser", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                if(response["profile_picture_url"] != nil){

                let url = URL(string: response["profile_picture_url"] as! String )
                
                print(url)
                if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
                    
                    self.settingButton.setImage(image, for: .normal)
                } else {

                let data = try? Data(contentsOf: url as! URL)
                if let imageData = data {
                    print(imageData)
                    let image = UIImage(data: data!)
                     imageCache.setObject(image as AnyObject, forKey: url as AnyObject)
                    self.settingButton.setImage(image, for: .normal)
                    // self.pictureProfile.image = image
                    
                } else {
                    print("nop")
                }
                
                }
                }
                
                
                /*   if (response["profile_picture_url"] as? String) != nil {
                 self.getProfilePicture(response["profile_picture_url"] as! String)
                 }*/
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
                }
        }
        
    }
    
    @IBAction func showView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.contactView.alpha = 1
                self.groupView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.contactView.alpha = 0
                self.groupView.alpha = 1
            })
        }
    }
    


  
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
}
}

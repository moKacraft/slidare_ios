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

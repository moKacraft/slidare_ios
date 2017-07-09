//
//  ShareViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 09/07/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ShareViewController: UIViewController{
    
    var userToken: String = "";
    var userId: String = "";

    
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var contactView: UIView!
    
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
    
    @IBAction func switchGroupContact(_ sender: UISegmentedControl) {
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
    
    
    
}

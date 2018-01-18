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
    var mainViewController: MainPageViewController!

    @IBOutlet weak var groupContainerView: UIView!
    @IBOutlet weak var contactContainerView: UIView!
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactContainer" {
            let viewController = segue.destination as! SendToContactViewController
            viewController.shareController = self
        } else if segue.identifier == "groupContainer" {
            let viewController = segue.destination as! SendToGroupViewController
            viewController.shareController = self
        }
    }
    
    func sendFile(image: UIImage, users: [String]) {
        mainViewController.sendFile(image: image, users: users)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
//        self.mainViewController.sendFile(image: <#T##UIImage#>)
        self.dismiss(animated: true)
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

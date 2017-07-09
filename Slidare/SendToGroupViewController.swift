//
//  SendToGroupViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 09/07/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SendToGroupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var userToken: String = "";
    var userId: String = "";
    var listGroup: [String] = []
    var valueSelected = "";

    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        view.addGestureRecognizer(tap)
        fetchGroup()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listGroup.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listGroup[row]
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let row = pickerView.selectedRow(inComponent: 0)
        self.valueSelected = self.listGroup[row] as String
    }
    
    func fetchGroup()
    {
        
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        
        Alamofire.request("http://34.227.142.101:50000/fetchGroups", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                let groupNames = response["groups"] as? [[String : AnyObject]]
                
                for groupNamess in groupNames! {
                    let name = groupNamess["name"]! as! String
                    self.listGroup.append(name)
                    self.pickerView.reloadAllComponents()
                    print("groupName: \(name)")
                    
                }
                for element in self.listGroup {
                    print(element)
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
    
    
   

    
}

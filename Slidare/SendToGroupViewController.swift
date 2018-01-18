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

class SendToGroupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    var userToken: String = "";
    var userId: String = "";
    var listGroup: [String] = []
    var valueSelected = "";
    var usersSelected: [String] = []
    var groupUsers: [[String]] = []
    let picker = UIImagePickerController()
    var shareController: ShareViewController!
    


    @IBOutlet weak var pickerView: UIPickerView!
        
 
    @IBAction func openLibrary(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }    }
    
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
        picker.delegate = self
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            imagePicked.image = image
            self.dismiss(animated: true, completion: nil)
            self.shareController.sendFile(image: image, users: usersSelected)
        } else{
            self.dismiss(animated: true, completion: nil)
            print("Something went wrong")
        }
        
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        self.usersSelected = self.groupUsers[row]
    }
    

    
        func fetchGroup()
    {
        
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        
        Alamofire.request("http://34.238.153.180:50000/fetchGroups", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                let groupNames = response["groups"] as? [[String : AnyObject]]
                for groupNamess in groupNames! {
                    let name = groupNamess["name"]! as! String
                    if let users = groupNamess["users"] as? [String] {
                        print("users")
                        print(users)
                        self.groupUsers.append(users)
                    } else {
                        self.groupUsers.append([])
                    }
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

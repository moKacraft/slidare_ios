//
//  AddGroupContactController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 07/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation

import UIKit
import Alamofire


class AddGroupContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    var userToken: String = "";
    var userId: String = "";
    var myId: String = "";
    var listGroup: [String] = []
    var listId: [String] = []
    var valueSelected = "";
    @IBOutlet weak var email: UITextField!
    var userName = "";
    @IBOutlet weak var messageSucess: UILabel!
    @IBOutlet weak var nameChange: UITextField!
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
       modifyButton.layer.cornerRadius = 5
       addButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        view.addGestureRecognizer(tap)
        getUser()
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
    
    
    @IBAction func addContact(_ sender: Any) {
        addContactToGroup(groupChosen: self.valueSelected)

        
    }
    
    @IBAction func changeName(_ sender: Any) {
        changeGroupName(name: self.valueSelected, newName: self.nameChange.text!)
    }
 
    
    func changeGroupName(name:String, newName:String)
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
         let parameters: [String: AnyObject]
        
        parameters = [
            "name": name as AnyObject, "new_name": newName as AnyObject]

    
        
        Alamofire.request("http://34.238.153.180:50000/renameGroup", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                self.messageSucess.text = "Group renamed successfully"
                self.listGroup.removeAll()
                self.fetchGroup()
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.messageSucess.text = "Your request failed"
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print(name)
                    print("Failure Response: \(json)")
                }
                }
        }
    }
    
    
    
    func addContactToGroup(groupChosen:String)
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        let escapedAddress = groupChosen.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        parameters = [
            "contact_identifier": self.email.text! as AnyObject]
        
        Alamofire.request("http://34.238.153.180:50000/addToGroup/" + escapedAddress!, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                print(groupChosen)
                self.messageSucess.text = "Contact successfully added"
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                    self.messageSucess.text = json

                }
                }
        }
        
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
                    let id = groupNamess["owner"]! as! String
                    if( id == self.myId){
                        self.listGroup.append(name)
                        self.listId.append(id)
                        self.pickerView.reloadAllComponents()
                        print("groupName: \(name)")
                        print("groupId: \(id)")
                    }
                    
                }
                if (self.listGroup.count > 0) {
                    self.valueSelected = self.listGroup[0];
                }
                self.pickerView.reloadAllComponents()

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
        
        Alamofire.request("http://34.238.153.180:50000/fetchUser", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                self.userName = response["email"] as! String
                self.myId = response["id"] as! String
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
                }
        }
    }

    
    @IBAction func groupDeleted(_ sender: Any) {
        deleteGroup(groupDeleted:self.valueSelected)
    }
    
    
    func deleteGroup(groupDeleted:String)
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        
        
        Alamofire.request("http://34.238.153.180:50000/removeGroup/" + groupDeleted, method: .delete, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
            // self.displayContact()
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

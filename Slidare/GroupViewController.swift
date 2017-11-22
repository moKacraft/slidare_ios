//
//  GroupViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 07/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation

import UIKit
import Alamofire

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var groupNameList: [String] = []
    var groupOwnerList: [String] = []
    var tmp: [String] = []
    var groupContactList: [[String]] = []
    
    var userToken: String = "";
    var userId: String = "";
       // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        fetchGroup()
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupContactList[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupNameList.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groupContactList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < groupNameList.count {
            return groupNameList[section]
        }
        
        return nil
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel?.text = self.groupContactList[indexPath.section][indexPath.row]
        
        return cell
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        print(indexPath.section)
        return self.groupOwnerList[indexPath.section] == self.userId
//        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
 let header = groupNameList[indexPath.section]
            print("header :" + header)
            print("contactName:" + self.groupContactList[indexPath.section][indexPath.row])
            
           
            deleteContactToGroup(groupChosen: header, emailDeleted: self.groupContactList[indexPath.section][indexPath.row])
            
            // remove the item from the data model
            self.groupContactList[indexPath.section].remove(at: indexPath.row)
     
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }    }
    
    func deleteContactToGroup(groupChosen:String, emailDeleted:String)
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
            "contact_identifier": emailDeleted as AnyObject]
        
        Alamofire.request("http://34.238.153.180:50000/removeFromGroup/" + groupChosen, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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

    
   func fetchGroup()
    {
        self.groupNameList.removeAll()
        self.groupContactList.removeAll()
        self.groupOwnerList.removeAll()
        
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        
        
        Alamofire.request("http://34.238.153.180:50000/fetchGroups", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
                let groupNames = response["groups"] as? [[String : AnyObject]]
                
                let peoplesArray = response["groups"]as? [[String : AnyObject]]
                
                for peopleArray in peoplesArray! {
                    
                    if (peopleArray["users"] != nil)
                    {
                        let name = peopleArray["users"]! as! [String]
                        for namess in name{
                            self.tmp.append(namess)
                        }
                    }
                    else{
                        self.tmp.append("")
                    }
                    self.groupOwnerList.append(peopleArray["owner"] as! String)
                    self.groupContactList.append(self.tmp)
                    self.tmp.removeAll()
                    
                    print("userList: \(self.groupContactList)")
                }
                
            
            if (groupNames == nil) {
                    self.groupNameList.removeAll()
                    self.groupContactList.removeAll()
                    self.tableView.reloadData();
                    return ;
                }
                for groupNamess in groupNames! {
                    let name = groupNamess["name"]! as! String
                    self.groupNameList.append(name)
                    self.tableView.reloadData();
                    print("groupName: \(name)")
                    
                }
                for element in self.groupNameList {
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
    


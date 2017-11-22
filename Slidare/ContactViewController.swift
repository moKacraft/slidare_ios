//
//  ContactViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 12/03/2017.
//  Copyright © 2017 Julien. All rights reserved.
//


import UIKit
import Alamofire

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var searchBar: UISearchBar!
   // @IBOutlet weak var mytableview: UITableView!
    
    @IBOutlet weak var mytableview: UITableView!
    var userToken: String = "";
    var userId: String = "";
    var contactId: String = "";
    var contactList = [String]()
    var filtered = [String]()

    
    @IBOutlet weak var emailDelete: UITextField!

    let cellReuseIdentifier = "cell"

    
    override func viewDidLoad() {
        self.title = "Contact"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        view.addGestureRecognizer(tap)
                displayContact()
        for element in self.contactList {
            print("coucou")
            print(element)
        }
        self.mytableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        mytableview.delegate = self
        mytableview.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        mytableview.tableHeaderView = searchController.searchBar
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filtered.removeAll()
        for contact in contactList {
            if (contact.lowercased().contains(searchText.lowercased())) {
                filtered.append(contact.lowercased());
            }
        }
        mytableview.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filtered.count
        }
        return self.contactList.count
    }
    
    
    
    
    
   /* override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let candy: Candy
        if searchController.active && searchController.searchBar.text != "" {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        cell.textLabel?.text = candy.name
        cell.detailTextLabel?.text = candy.category
        return cell
    }*/
    
    
    
/*    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCandies.count
        }
        return candies.count
    }*/

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
        /*        let cell:UITableViewCell = self.mytableview.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel?.text = self.contactList[indexPath.row]*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let contact: String
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = filtered[indexPath.row]
        } else {
            contact = contactList[indexPath.row]
        }
        cell.textLabel?.text = contact
        return cell
    }
    
    
    
    // method to run when table view cell is tapped
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            deleteContact(emailDeleted: contactList[indexPath.row])

            // remove the item from the data model
            contactList.remove(at: indexPath.row)
            
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)

            
        }     }
    
    
    
    
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
    @IBAction func contactDeleted(_ sender: Any) {
        deleteContact(emailDeleted: self.emailDelete.text!)
    }

    
    func deleteContact(emailDeleted:String)
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
    

        
        Alamofire.request("http://34.238.153.180:50000/removeContactByEmail/" + emailDeleted, method: .delete, encoding: JSONEncoding.default, headers: headers)
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

    
   func displayContact()
   {
    self.contactList.removeAll()
 
    let headers = ["Authorization": "Bearer \(userToken)"]
    
    

    Alamofire.request("http://34.238.153.180:50000/userContacts", method: .get, encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseJSON { response in switch response.result {
        case .success(let JSON):
            let response = JSON as! NSDictionary
            print(response)
            let contacts = response["contacts"] as? [[String : AnyObject]]
        
            if (contacts == nil) {
                self.contactList.removeAll()
                 self.mytableview.reloadData();
                return ;
            }
            for contact in contacts! {
              let username = contact["username"]! as! String
               self.contactList.append(username)
                self.mytableview.reloadData();

                print("contact: \(username)")
            }
            for element in self.contactList {
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

extension ContactViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

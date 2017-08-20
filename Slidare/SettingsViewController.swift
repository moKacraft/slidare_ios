//
//  SettingsViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 30/08/2016.
//  Copyright © 2016 Julien. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class SettingsViewController: UIViewController,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate {
    @IBOutlet weak var profilePicture: UIButton!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var stateMessage: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var imagePicked: UIImageView!
  //  var  chosenImage = UIImage()

    
    @IBOutlet weak var pictureProfile: UIImageView!
     var userToken: String = "";
    let picker = UIImagePickerController()
    
    
    @IBAction func library(_ sender: UIBarButtonItem) {
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
        picker.popoverPresentationController?.barButtonItem = sender
    }
    
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    }
    
    
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        picker.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        getUser()
//        uploadPicture()
       
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func fetchContacts(_ sender: AnyObject) {
        let headers = ["Authorization": "Bearer \(userToken)"]
        

        Alamofire.request("http://34.227.142.101:50000/userContacts", method: .get, encoding: JSONEncoding.default, headers: headers)
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
        
        Alamofire.request("http://34.227.142.101:50000/fetchUser", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                self.username.text = response["username"] as! String
                self.name.text = response["username"] as! String
                self.emailAddress.text = response["email"] as! String
                self.email.text = response["email"] as! String
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
    
    func updateUserName()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
            "username": self.username.text! as! AnyObject]
        
        Alamofire.request("http://34.227.142.101:50000/updateUserName", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate()
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
    
    
    func updateProfilePicture(urlPicture:String)
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
            "profile_picture_url": urlPicture as AnyObject]
        
        
        Alamofire.request("http://34.227.142.101:50000/updateUserPicture", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
    
    func updateEmail()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
            "email": self.email.text! as! AnyObject]

        
        Alamofire.request("http://34.227.142.101:50000/updateUserEmail", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
    
    func updatePassword()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        let parameters: [String: AnyObject]
        
        parameters = [
        "old_password": self.currentPassword.text! as AnyObject, "new_password": self.newPassword.text! as AnyObject]
        
        Alamofire.request("http://34.227.142.101:50000/updateUserPassword", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                print(response)
               // self.stateMessage.text = "Success"
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                   // self.stateMessage.text = "Fail"
                }
                }
        }
        
    }
    
    
    
    //MARK: - Delegates
    /*func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        var  chosenImage = UIImage()
        print("coucou")
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        print("coucou2")
        let globalURL = (info[UIImagePickerControllerReferenceURL] as! NSURL)
        print("searchthis\(globalURL)")
      //  uploadToFireBase(localFile: globalURL)
        pictureProfile.contentMode = .scaleAspectFit //3
        pictureProfile.image = chosenImage //4
        dismiss(animated:true, completion: nil) //5
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }*/
    
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        //        var  chosenImage = UIImage()
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           // pictureProfile.contentMode = .scaleAspectFit //3
            //pictureProfile.image = chosenImage //4
            dismiss(animated:true, completion: nil) //5
            let globalURL = (info[UIImagePickerControllerReferenceURL] as! URL)
            var data = NSData()
            data = UIImageJPEGRepresentation(chosenImage, 0.8)! as NSData
            uploadToFireBase(localFile: data)
        } else{
            print("Something went wrong")
        }
        
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadToFireBase(localFile: NSData) {
        
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference(forURL: "gs://slidare-c93d1.appspot.com/images/" + userToken + ".jpeg")
        
        
        
        _ = storageRef.putData(localFile as Data, metadata: nil) { metadata, error in
            if error != nil {
                print(error)
            } else {
                let url = metadata!.downloadURL()
                let strings = "\(url)"
                print ("test : ")
    
              //  self.updateProfilePicture(urlPicture:strring)
                let data = try? Data(contentsOf: url!)
                
                if let imageData = data {
                    let image = UIImage(data: data!)
                    self.pictureProfile.image = image
                }
                print (url)
                print("coucou")
                
            }
        }
  
        
       /* storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("ca marche pas")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.pictureProfile.contentMode = .scaleAspectFit
                self.pictureProfile.image = image
                print("ca marche")
            }
        }*/
        
    }

    
    
    @IBAction func saveButton(_ sender: AnyObject) {
        updateUserName()
        updateEmail()
        self.name.text = self.username.text
        
        self.emailAddress.text = self.email.text
        updatePassword()
    }

    
    
    @IBAction func logoutbutton(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let internVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.show(internVC, sender: internVC)
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

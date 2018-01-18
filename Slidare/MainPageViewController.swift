//
//  MainPageViewController.swift
//  Slidare
//
//  Created by JulienSup on 12/06/16.
//  Copyright © 2016 Julien. All rights reserved.
//

import Foundation
import Alamofire
import SocketIO
import Firebase
import SwiftSocket
import CryptoSwift
import IRCrypto
import IDZSwiftCommonCrypto
import ImagePicker



class MainPageViewController: UIViewController, ImagePickerDelegate, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var facebookLogout: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    let cellReuseIdentifier = "cell"
    var userToken: String = "";
    var userId: String = "";
    var socket: SocketIOClient? = nil
    var encryptedFile: Array<UInt8> = []
    var pictureUrls: [String] = []
    var senders: [String] = []
    var userName: String = "";
    
    @IBAction func sendFileClicked(_ sender: Any) {
        print("sendfile")
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print(images.count)
//        sendFile(image: images[0])
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(FirebaseApp.app() == nil){
            FirebaseApp.configure()
        }
        activityInd.startAnimating()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        getUser()
        tableView.delegate = self
        tableView.dataSource = self
//        getUser()
        getFiles()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
               activityInd.stopAnimating()
            }
        }
    }
    
    @IBAction func fetchContacts(_ sender: AnyObject) {
        let headers = ["Authorization": "Bearer \(userToken)"]
        

        Alamofire.request("http://34.238.153.180:50000/userContacts", method: .get, encoding: JSONEncoding.default, headers: headers)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pictureUrls.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        cell.textLabel?.text = "From : " + self.senders[self.senders.count - 1 - indexPath.row]
        let url = URL(string: self.pictureUrls[self.pictureUrls.count - 1 - indexPath.row])
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        if (data != nil) {
            cell.imageView?.image = UIImage(data: data!)
        }
//        cell.imageView?.image = UIImage(url)
//        cell.imageView
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.pictureUrls[self.pictureUrls.count - 1 - indexPath.row])
        print("You tapped cell number \(indexPath.row).")
        self.performSegue(withIdentifier: "Segue", sender: self.pictureUrls[self.pictureUrls.count - 1 - indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue"
        {
            let url = sender as! String
            let secondViewController = segue.destination as! ConversationViewController
            secondViewController.imageUrl = url;
        } else if segue.identifier == "shareSegue" {
            let shareViewController = segue.destination as! ShareViewController
            shareViewController.mainViewController = self
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
                if (response["profile_picture_url"] != nil){
                let url = URL(string: response["profile_picture_url"] as! String )
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

                    }}
                

                self.userName = (response["email"] as? String)!
                self.initSocketio(userName: self.userName)
//                if (response["profile_picture_url"] as? String) != nil {
//                    self.getProfilePicture(response["profile_picture_url"] as! String)
//                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
                }
        }

    }

    func getFiles()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        Alamofire.request("http://34.238.153.180:50000/getUserFiles", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                if let fileUrls = response["file_urls"] as? NSArray {
                    for fileUrl in fileUrls {
                        self.pictureUrls.append(fileUrl as! String)
                    }
                    self.tableView.reloadData()
                }
                    self.activityInd.stopAnimating()
          
                
                if let sendersName = response["senders"] as? NSArray {
                    for senderName in sendersName {
                        self.senders.append(senderName as! String)
                    }
                    self.tableView.reloadData()
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
    func getProfilePicture(_ url:String)
    {
        let url = URL(string: url)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            if (data != nil) {
                DispatchQueue.main.async(execute: {
                    self.profilePicture.image = UIImage(data: data!)
                });
            }
        }

    }

    
    internal func initUserData(_ firstname : String, lastname : String, email: String, pictureUrl : URL) -> Void {
        print(firstname, lastname, email, pictureUrl.absoluteString);
    }
    @IBAction func facebookLogoutPressed(_ sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let internVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.show(internVC, sender: internVC)
    }
    func sendFile(image: UIImage, users: [String]) {
        let salt: Array<UInt8> = Array("slidarep".utf8)
        let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
        let keys6 = PBKDF.deriveKey(password: "12341234123412341234123412341234", salt: salt, prf: .sha1, rounds: 65536, derivedKeyLength: 32)
        let data = UIImageJPEGRepresentation(image, 1.0)
        let saltString = salt.toBase64()
        let ivString = iv.toBase64()
        let keysString = "12341234123412341234123412341234"
        do {
            encryptedFile = try AES(key: keys6, iv: iv, blockMode: .CBC, padding: .pkcs7).encrypt(data!.bytes)
            let uuid = UUID().uuidString + ".jpg"
            socket?.emit("request file transfer", uuid,
                             uuid, users, "encrypted", "iosFile",
                             "nosha1", saltString!,
                             ivString!, keysString, encryptedFile.count, self.userName);
            print(encryptedFile.count)
        } catch {
            print(error)
        }
    }
    func initSocketio(userName: String) {
        if (socket == nil) {
            socket = SocketIOClient(socketURL: URL(string: "http://34.238.153.180:8090")!, config: [.log(false)])
            
            socket?.on("connect") {data, ack in
                print("socket connected")
                print("Type \"quit\" to stop")
            }
            socket?.on(userName) {data, ack in
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "New File", message: "\(data[10]) sent you a file", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
//
//                        let notification = UILocalNotification()
//                        notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
//                        notification.alertBody = "\(data[10]) sent you a file"
//                        notification.soundName = UILocalNotificationDefaultSoundName
//                        UIApplication.shared.scheduleLocalNotification(notification)
                    }
                    var client = TCPClient(address: "34.238.153.180", port: data[1] as! Int32)
                    let res = client.connect(timeout: 10);
                    let transferId = data[2] as! String
                    let file = data[4] as! String //this is the file. we will write to and read from it
                    
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        
                        let path = dir.appendingPathComponent(file as! String)
                        var count = 0;
                        var buffer: Data = Data();
                        while (true) {
                            guard let data2 = client.read(1024*4, timeout: 100) else {
                                break; }
                            let pointer = UnsafeBufferPointer(start:data2, count:data2.count)
                            let buf = Data(buffer:pointer)
                            buffer.append(buf)
                            do {
                                try buf.write(to: path)
                            }
                            catch {/* error handling here */}
                        }
                        self.socket?.emit("transfer finished", transferId);
                        var saltString: String = data[6] as! String
                        var ivString: String = data[7] as! String
                        if (saltString.characters.last == "\n") {
                            saltString.characters.removeLast();
                        }
                        if (ivString.characters.last == "\n") {
                            ivString.characters.removeLast();
                        }
                        print(data[7] as! String)
                        let iv: Data = Data(base64Encoded: ivString)!
                        let salt: Data = Data(base64Encoded: saltString)!
                        let key: Data = Data(base64Encoded: data[8] as! String)!
                        do {
                            let keys6 = PBKDF.deriveKey(password: key.base64EncodedString(), salt: salt.bytes, prf: .sha1, rounds: 65536, derivedKeyLength: 32)
                            let decrypted = try AES(key: keys6, iv: iv.bytes, blockMode: .CBC, padding: .pkcs7).decrypt(buffer.bytes)
                            let storage = Storage.storage()
                            
                            // Create a storage reference from our storage service
                            let storageRef = storage.reference(forURL: "gs://slidare-c93d1.appspot.com/" + (data[4] as! String))
                            _ = storageRef.putData(Data(decrypted), metadata: nil) { metadata, error in
                                if error != nil {
                                    print(error)
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "Download", message: "An error occured while downloading", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                } else {
                                    let url = metadata!.downloadURL()
                                    print(url?.absoluteString)
                                    DispatchQueue.main.async {
                                        let alert = UIAlertController(title: "Download", message: "File Downloaded successfully!", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                    let parameters = [
                                        "file_url": url?.absoluteString as AnyObject,
                                        "sender": data[10] as! AnyObject]
                                    
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    let userToken = appDelegate.userToken
                                    let headers = ["Authorization": "Bearer \(userToken)"]
                                    
                                    Alamofire.request("http://34.238.153.180:50000/addFileToList", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                                        .validate()
                                        .responseJSON { response in switch response.result {
                                        case .success(let JSON):
                                            let response = JSON as! NSDictionary
                                            print(response)
                                            self.pictureUrls.append((url?.absoluteString)!)
                                            self.senders.append(data[10] as! String)
                                            self.tableView.reloadData()
                                            
                                        case .failure(let error):
                                            print("Request failed with error: \(error)")
                                            }
                                    }
                                }
                            }
                            
                        } catch {
                            print(error)
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Download", message: "An error occured while decrypting the file", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }

                }
            }
            socket?.on("server ready") {data, ack in
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                    self.tcpClient = TCPClient(address: "34.238.153.180", port: data[0] as! Int32)
                    self.tcpClient.connect(timeout: 10);
                    print(self.encryptedFile.count)
                    let chunks = self.encryptedFile.chunks(size: 1024)
                    for chunk in chunks {
                        var res = self.tcpClient.send(data: chunk)
                        while res.isFailure {
                            res = self.tcpClient.send(data: chunk)
                        }
                        //                    usleep(1000)
                        //                    print(res)
                    }
                    self.tcpClient.close()
                }
                
            }
            
            socket?.connect();
        }
    }
    var tcpClient: TCPClient!
    @IBAction func onShareClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "shareSegue", sender: self)
    }
    
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

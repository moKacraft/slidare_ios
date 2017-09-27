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
import CommonCrypto
import IDZSwiftCommonCrypto
import ImagePicker

class MainPageViewController: UIViewController, ImagePickerDelegate, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var facebookLogout: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var webView: UIWebView!


    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var settingButton: UIButton!
   @IBOutlet weak var settingsButton: UIButton!

   // @IBOutlet weak var tableView: UITableView!
    let cellReuseIdentifier = "cell"
    var userToken: String = "";
    var userId: String = "";
    var socket: SocketIOClient?
    var encryptedFile: Array<UInt8> = []
    var pictureUrls: [String] = []
    
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
        sendFile(image: images[0])
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(FirebaseApp.app() == nil){
            FirebaseApp.configure()
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId

        getUser()

      /*  socket = SocketIOClient(socketURL: URL(string: "http://34.227.142.101:8090")!, config: [.log(false)])
        
        socket?.on("connect") {data, ack in
            print("socket connected")
            print("Type \"quit\" to stop")
        }
        socket?.on("testbeta@gmail.com") {data, ack in
            print("here")
            var client = TCPClient(address: "34.227.142.101", port: data[1] as! Int32)
            client.connect(timeout: 10);
            
            let file = data[4] as! String //this is the file. we will write to and read from it
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let path = dir.appendingPathComponent(file as! String)
                var count = 0;
                var buffer: Data = Data();
                while (true) {
                    guard let data2 = client.read(1024*4) else {
                        print("here2")
                        break; }
                    let pointer = UnsafeBufferPointer(start:data2, count:data2.count)
                    let buf = Data(buffer:pointer)
                    buffer.append(buf)
                    do {
                        try buf.write(to: path)
                    }
                    catch {/* error handling here */}
                }
                print(buffer.count)
                
                let storage = Storage.storage()
                
                // Create a storage reference from our storage service
                let storageRef = storage.reference(forURL: "gs://slidare-c93d1.appspot.com/" + (data[4] as! String))
                _ = storageRef.putData(buffer, metadata: nil) { metadata, error in
                    if error != nil {
                        print(error)
                    } else {
                        let url = metadata!.downloadURL()
                        print(url?.absoluteString)
                        let url2 = NSURL (string: (url?.absoluteString)!);
                        let requestObj = NSURLRequest(url: url2! as URL);
                        self.webView.scalesPageToFit = true;
                        self.webView.loadRequest(requestObj as URLRequest);
                    }
                }
                
                //                do {
                ////                    print(data[6] as! String)
                ////                    print(data[7] as! String)
                ////
                ////                    print((data[6] as! String).lengthOfBytes(using: .utf8))
                ////                    print((data[7] as! String).lengthOfBytes(using: .utf8))
                ////
                //                    let dataDec = Data(base64Encoded: data[6] as! String)
                //                    let dataDec2 = Data(base64Encoded: data[7] as! String)
                //
                ////                    let rep = try HMAC(key: Array<UInt8>("PBKDF2WithHmacSHA1".utf8), variant: .sha1).authenticate(buffer.bytes)
                //
                //  //                  print(rep);
                //
                //                    let rep2 = try PKCS5.PBKDF2(password: Array<UInt8>((data[8] as! String).utf8), salt: (dataDec?.bytes)!, iterations: 65536, variant: .sha256).calculate()
                //                    print(rep2)
                //
                //                    let decrypted = try AES(key: rep2, iv: dataDec2?.bytes, blockMode: .CBC, padding: PKCS7()).decrypt(buffer.bytes)
                //
                //                    print(decrypted)
                //                    let storage = Storage.storage()
                //
                //                    // Create a storage reference from our storage service
                //                    let storageRef = storage.reference(forURL: "gs://slidare-c93d1.appspot.com/" + (data[4] as! String))
                //                    _ = storageRef.putData(Data(decrypted), metadata: nil) { metadata, error in
                //                        if error != nil {
                //                            print(error)
                //                        } else {
                //                            let url = metadata!.downloadURL()
                //                            print(url?.absoluteString)
                //                            let url2 = NSURL (string: (url?.absoluteString)!);
                //                            let requestObj = NSURLRequest(url: url2! as URL);
                //                            self.webView.scalesPageToFit = true;
                //                            self.webView.loadRequest(requestObj as URLRequest);
                //                        }
                //                    }
                //
                //                } catch {
                //                    print(error)
                //                }
                //                do {
                //                    let decrypted = try AES(key: data[8] as! Array<UInt8>, iv: data[7] as! Array<UInt8>, blockMode: .CBC, padding: PKCS7()).decrypt(fileBuf)
                //                } catch {
                //                    print(error)
                //                }
                
            }
            
        }
        socket?.on("server ready") {data, ack in
            print(data);
        }
        
        socket?.connect();
        
        print("Type \"quit\" to stop")
        
        //        socket.connect()
        /*let image = UIImage(named : "userdefault")
         settingsButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
         settingsButton.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)*/
        
        
        
        //        print(appDelegate.userToken)
        //        print(appDelegate.userId)
        /*let image = UIImage(named : "userdefault")
        settingsButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        settingsButton.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)*/

*/

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        
        tableView.delegate = self
        tableView.dataSource = self
        getUser()
        getFiles()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pictureUrls.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.pictureUrls[indexPath.row]
        let url = URL(string: self.pictureUrls[indexPath.row])
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.imageView?.image = UIImage(data: data!)
//        cell.imageView?.image = UIImage(url)
//        cell.imageView
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.pictureUrls[indexPath.row])
        print("You tapped cell number \(indexPath.row).")
    }
    
    func getUser()
    {
        let headers = ["Authorization": "Bearer \(userToken)"]
        
        Alamofire.request("http://34.227.142.101:50000/fetchUser", method: .get, encoding: JSONEncoding.default, headers: headers)
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

                print(url)
                
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
                


                self.initSocketio(userName: (response["username"] as? String)!)
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
        
        Alamofire.request("http://34.227.142.101:50000/getUserFiles", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! NSDictionary
                let fileUrls = response["file_urls"] as! NSArray
                for fileUrl in fileUrls {
                    self.pictureUrls.append(fileUrl as! String)
                }
                self.tableView.reloadData()
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
    func sendFile(image: UIImage) {
        let salt: Array<UInt8> = Array("slidarep".utf8)
        let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
        let keys6 = PBKDF.deriveKey(password: "12341234123412341234123412341234", salt: salt, prf: .sha1, rounds: 65536, derivedKeyLength: 32)
        let data = UIImageJPEGRepresentation(image, 1.0)
        let saltString = salt.toBase64()
        let ivString = iv.toBase64()
        let keysString = "12341234123412341234123412341234"
        do {
            encryptedFile = try AES(key: keys6, iv: iv, blockMode: .CBC, padding: PKCS7()).encrypt(data!.bytes)
            socket?.emit("request file transfer", "iosFile.jpg",
                             "iosFile.jpg", ["juju@gmail.com"], "encrypted", "iosFile",
                             "nosha1", saltString!,
                             ivString!, keysString, encryptedFile.count);
            print(encryptedFile.count)
        } catch {
            print(error)
        }
    }
    func initSocketio(userName: String) {
        socket = SocketIOClient(socketURL: URL(string: "http://34.227.142.101:8090")!, config: [.log(false)])
        
        socket?.on("connect") {data, ack in
            print("socket connected")
            print("Type \"quit\" to stop")
        }
        socket?.on(userName) {data, ack in
            print("here")
            var client = TCPClient(address: "34.227.142.101", port: data[1] as! Int32)
            client.connect(timeout: 10);
            let transferId = data[2] as! String
            let file = data[4] as! String //this is the file. we will write to and read from it
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let path = dir.appendingPathComponent(file as! String)
                var count = 0;
                var buffer: Data = Data();
                while (true) {
                    guard let data2 = client.read(1024*4) else {
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
                    let decrypted = try AES(key: keys6, iv: iv.bytes, blockMode: .CBC, padding: PKCS7()).decrypt(buffer.bytes)
                    let storage = Storage.storage()
                    
                    // Create a storage reference from our storage service
                    let storageRef = storage.reference(forURL: "gs://slidare-c93d1.appspot.com/" + (data[4] as! String))
                    _ = storageRef.putData(Data(decrypted), metadata: nil) { metadata, error in
                        if error != nil {
                            print(error)
                        } else {
                            let url = metadata!.downloadURL()
                            print(url?.absoluteString)
                            let url2 = NSURL (string: (url?.absoluteString)!);
                            let requestObj = NSURLRequest(url: url2! as URL);
                            self.webView.scalesPageToFit = true;
                            self.webView.loadRequest(requestObj as URLRequest);
                        }
                    }
                    
                } catch {
                    print(error)
                }
                //                                do {
                //                    let decrypted = try AES(key: data[8] as! Array<UInt8>, iv: data[7] as! Array<UInt8>, blockMode: .CBC, padding: PKCS7()).decrypt(fileBuf)
                //                } catch {
                //                    print(error)
                //                }
                
            }
            
        }
        socket?.on("server ready") {data, ack in
            var client = TCPClient(address: "34.227.142.101", port: data[0] as! Int32)
            client.connect(timeout: 10);
            
            let res = client.send(data: self.encryptedFile)
            client.close()
            print(res)
        }
        
        socket?.connect();
   
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

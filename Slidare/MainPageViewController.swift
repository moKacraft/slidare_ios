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

class MainPageViewController: UIViewController {
    @IBOutlet weak var facebookLogout: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var settingsButton: UIButton!
    var userToken: String = "";
    var userId: String = "";
    var socket: SocketIOClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        userToken = appDelegate.userToken
        userId = appDelegate.userId
        getUser()
        socket = SocketIOClient(socketURL: URL(string: "http://34.227.142.101:8090")!, config: [.log(false)])
        
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


        
    //        print(appDelegate.userToken)
//        print(appDelegate.userId)
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

             /*   if (response["profile_picture_url"] as? String) != nil {
                    self.getProfilePicture(response["profile_picture_url"] as! String)
                }*/
            case .failure(let error):
                print("Request failed with error: \(error)")
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(json)")
                }
                }
        }

    }
  /*  func getProfilePicture(_ url:String)
    {
        let url = URL(string: url)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            DispatchQueue.main.async(execute: {
                self.profilePicture.image = UIImage(data: data!)
            });
        }

    }*/

    
    internal func initUserData(_ firstname : String, lastname : String, email: String, pictureUrl : URL) -> Void {
        print(firstname, lastname, email, pictureUrl.absoluteString);
    }
    @IBAction func facebookLogoutPressed(_ sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let internVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.show(internVC, sender: internVC)
    }
}

//
//  ConversationViewController.swift
//  Slidare
//
//  Created by Sophie DUMONT on 27/09/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import Foundation

import UIKit
import Alamofire

class ConversationViewController: UIViewController{
    var imageUrl: String = "";
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        print(imageUrl)
        let url2 = NSURL (string: imageUrl);
        let requestObj = NSURLRequest(url: url2! as URL);
        self.webView.scalesPageToFit = true;
        self.webView.loadRequest(requestObj as URLRequest);
        
    }
    
    
    
}

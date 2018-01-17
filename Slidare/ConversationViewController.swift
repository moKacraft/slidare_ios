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

class ConversationViewController: UIViewController, UIWebViewDelegate{
    var imageUrl: String = "";
    
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        activityInd.startAnimating()
        print(imageUrl)

        let url2 = NSURL (string: imageUrl);
        let requestObj = NSURLRequest(url: url2! as URL);
        self.webView.scalesPageToFit = true;
        self.webView.loadRequest(requestObj as URLRequest);
        self.webView.delegate = self;
        
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        activityInd.stopAnimating()
    }

    
    
}

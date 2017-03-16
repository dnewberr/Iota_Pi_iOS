//
//  IotaPiPageViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/23/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import Log

class IotaPiPageViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped =  true
        
        self.webView.scalesPageToFit = true
        self.webView.contentMode = UIViewContentMode.scaleAspectFit
        Logger().trace("[IotaPi Page] Beginning to load the iotapi.com web view.")
        DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
            self?.webView.loadRequest(URLRequest(url: URL(string: "http://www.iotapi.com/")!))
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.webView.addSubview(Utilities.createNoDataLabel(message: "There was an error loading the web page.", width: self.view.frame.width, height: self.view.frame.height))
    }
}

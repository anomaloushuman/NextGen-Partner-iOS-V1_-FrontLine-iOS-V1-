//
//  ViewController.swift
//  NXGN Partner App
//
//  Created by Patrick Garcia on 4/12/20.
//  Copyright © 2020 NextGen AutoGlass, Inc. All rights reserved.
//

import UIKit
import WebKit
import Lottie
import UserNotifications

// Enable Timer Functionality

extension UIViewController {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
        
    }
}

// Links UIViewController On Main.Storyboard

class ViewController: UIViewController, WKNavigationDelegate {
    
    // Main Storyboard Outlets
    
    @IBOutlet var webview: WKWebView!
    @IBOutlet var RefreshButton: UIButton!
    @IBOutlet var ConnLabel: UILabel!
    @IBOutlet var OfflineOne: UILabel!
    @IBOutlet var OfflineTwo: UILabel!
    @IBOutlet var Spinner: UIActivityIndicatorView!
    
    @IBAction func RetryLoading(_ sender: Any) {
        self.animationView.alpha = 1.0
        self.animationView.isHidden = false
        self.Spinner.isHidden = false
        self.ConnLabel.isHidden = true
        self.OfflineOne.isHidden = true
        self.OfflineTwo.isHidden = true
        self.RefreshButton.isHidden = true
        webview.load(URLRequest(url: URL(string: "<ENDPOINT>")!))
        
    }
    
    // Define Vars & Settings
    
    let webView = WKWebView()
    
    let animationView = AnimationView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // Initalize App
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate WKWebView settings & requests in background
        
        webview.load(URLRequest(url: URL(string: "<ENDPOINT>")!))
        webview.scrollView.alwaysBounceVertical = false
        webview.scrollView.bounces = false
        webview.navigationDelegate = self
        
        // Run startup animation while loading
        
        startAnimation()

    }
    
    // Start Bootup Process (Webpage Loading)
    
    internal func startAnimation() {
        Spinner.isHidden = true
        ConnLabel.isHidden = true
        OfflineOne.isHidden = true
        OfflineTwo.isHidden = true
        RefreshButton.isHidden = true
        animationView.alpha = 1.0
        animationView.animation = Animation.named("boot")
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFill
        //animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        view.addSubview(animationView)
        
        

    }
    
    // WKProgressListener
    // Show splash screen on page load until complete
    
    internal func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.Spinner.isHidden = false
    }
    
    // Fade out splash screen on page load completion
    
    internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.Spinner.isHidden = true
        self.delay(2.5, closure: {
            UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
                self.animationView.alpha = 0.0
            })
        })
        self.delay(3.1, closure: {
            UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.animationView.isHidden = true
            })
        })
        webview.isHidden = false
    }
    
    // WKWebView Failed Show Offline Message
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)

    {

    if((error as NSError).code == NSURLErrorNotConnectedToInternet)

    {
        Spinner.isHidden = true
        animationView.alpha = 1.0
        animationView.isHidden = true
        webview.isHidden = true
        ConnLabel.isHidden = false
        OfflineOne.isHidden = false
        OfflineTwo.isHidden = false
        RefreshButton.isHidden = false
    }

        }
    
    // Enable WKWebView Cookie Storage

    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 11, *) {
            let cookie = HTTPCookie(properties: [
                .domain: "*.nxgnauto.com",
                .path: "/",
                .name: "devid",
                .value: "MyCookieValue",
                .secure: "TRUE",
                .expires: NSDate(timeIntervalSinceNow: 31556926)
            ])!
            let dataStore = WKWebsiteDataStore.default()
            dataStore.httpCookieStore.setCookie(cookie)
            dataStore.httpCookieStore.getAllCookies({ (cookies) in
                print(cookies)
            })
        } else {
            guard let cookies = HTTPCookieStorage.shared.cookies else {
                return
            }
            print(cookies)
        }
        
    }
    
    
    
}


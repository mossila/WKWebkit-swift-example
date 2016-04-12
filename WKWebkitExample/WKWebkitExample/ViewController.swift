//
//  ViewController.swift
//  WKWebkitExample
//
//  Created by Sutean Rutjanalard on 4/12/2559 BE.
//  Copyright © 2559 Sutean Rutjanalard. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate {
    var defaultWebsite: Int! //Automatic unwrap optional, willset before segue
    var websites: [String]!
    var webView: WKWebView!
    var progressView:  UIProgressView!
    override func loadView() {
        setupWebView()

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupProgressbar()
        setupKVO()
        loadDefaultWebView()
        navigationController?.hidesBarsOnSwipe = true

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        teardownKVO()
        navigationController?.hidesBarsOnSwipe = false

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupWebView()
        title = websites[defaultWebsite]
        setupToolbar()
        setNavigationButton()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - WebView
    func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView.sizeToFit()
        let frame = view.frame
        progressView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 2)
        view.addSubview(progressView)
        
        
    }
    func setupProgressbar() {
        let navBar = self.navigationController?.navigationBar
        let navBarHeight = navBar?.frame.height
        let progressFrame = progressView.frame
        let pSetX = progressFrame.origin.x
        let pSetY = CGFloat(navBarHeight!)
        let pSetWidth = self.view.frame.width
        let pSetHight = progressFrame.height
        
        progressView.frame = CGRectMake(pSetX, pSetY, pSetWidth, pSetHight)
        self.navigationController?.navigationBar.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
    }

    func loadDefaultWebView() {
        let url = NSURL(string: "https://\(websites[defaultWebsite])")!
        webView.loadRequest(NSURLRequest(URL: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
    }
    // MARK: - Navigation bar
    func setupToolbar() {
        
       
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(WKWebView.reload))
        
        toolbarItems = [spacer, refresh]
        navigationController?.toolbarHidden = false
        
    }
    func setNavigationButton() {
//        let open = UIBarButtonItem(title: "Open",
//                                   style: .Plain,
//                                   target: self,
//                                   action: #selector(ViewController.openTapped))
        
        let back = UIBarButtonItem(barButtonSystemItem: .Rewind, target: webView, action: #selector(WKWebView.goBack))
        let forward = UIBarButtonItem(barButtonSystemItem: .FastForward, target: webView, action: #selector(WKWebView.goForward))
        //rightBarButtonItem with `s`, need to reverse to currect order
        navigationItem.rightBarButtonItems = [back, forward].reverse()
    }

    // MARK: - KVO
    func setupKVO() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    func teardownKVO() {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.hidden = (progressView.progress == 1)
            print("estimate progress \(webView.estimatedProgress * 100) %")
        }
    }
}


//
//  ViewController.swift
//  WKWebkitExample
//
//  Created by Sutean Rutjanalard on 4/12/2559 BE.
//  Copyright © 2559 Sutean Rutjanalard. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    var defaultWebsite: Int! //Automatic unwrap optional, willset before segue
    var websites: [String]!
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = websites[defaultWebsite]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


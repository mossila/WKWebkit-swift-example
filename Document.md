1. Create project as SingleView controller
2. Embeded NavigationController 
3. make UITableViewController as rootViewController
4. segue from `UITableViewCell` to `ViewController` 
5. Create Swift file for it named `SelectWebsiteTableViewController`
6. Create var for holding `websites`

 ```swift
     let websites = ["apple.com", "hackingwithswift.com"]
```

7. Implement `tableView delegate`

 ```swift
 // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("websiteCell", forIndexPath: indexPath)

        cell.textLabel!.text = websites[indexPath.row]

        return cell
    }
    ```

8. prepare for segue to another ViewController

  ```swift
 // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ViewController
        vc.websites = websites
        if let indexPath = tableView.indexPathForSelectedRow {
            vc.defaultWebsite = indexPath.row
        }
    }
 ```

9. Prepare `ViewController` ready to receive data from `SelectWebsiteViewController`

 ```swift
  class ViewController: UIViewController {
 	  var defaultWebsite: Int! //Automatic unwrap optional, willset before segue
 	  var websites: [String]!
 ```
 
10. Update `title` on `ViewController` to show that data we send over `prepareForSegue` is right!

 ```swift
 override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = websites[defaultWebsite]
    }
```

11. Import `WebKit` to `ViewController` file and create `var` for `WKWebKit`, than let's `ViewController` implement `WKNavigationDelegate`

 ```swift
    import WebKit
    class ViewController: UIViewController,WKNavigationDelegate {
    ...
		var webView: WKWebView!
 ```
 
12. Override `loadView` method to load our custom view
 
 ```swift
    // MARK: - View life cycle
    override func loadView() {
        setupWebView()
    }
 // MARK: - WebView
 func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
 ```
 
13. Create method that `loadDefaultWebView` for us. and call it in `viewWillAppear`

  ```swift
  // MARK: - WebView
  ...
  func loadDefaultWebView() {
        let url = NSURL(string: "https://\(websites[defaultWebsite])")!
        webView.loadRequest(NSURLRequest(URL: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    override func viewWillAppear() {
        ...
        loadDefaultWebView()
    }
  ```
  
14. Now when we navigate to `ViewController` it will load the website that we select automatically. try it!
15. Playing with `WKNavigationDelegate` now try to update title

 ```swift
   // MARK: - WKNavigationDelegate

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
    }
 ```

16. setup toolbar with `progress`, `space`, `reload` 
 
 ```swift 
    // MARK: - Navigation bar
    func setupToolbar() {
        
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(WKWebView.reload))
        
        toolbarItems = [progressButton,spacer, refresh]
        navigationController?.toolbarHidden = false

    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        ...
        setupToolbar()
    }
 ```

17. Now you browser can reload, but not for updating progress yet. Now we use **KVO** to do the trick

 ```swift
 
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
        }
    }
    // MARK: - View life cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //setup KVO before load website, just we have to wait before it will happen.
        setupKVO()
        loadDefaultWebView()

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //remove it when we don't use it.
        teardownKVO()
    }
 ```

18. set `back` and `forward` so you can complete web feature. set this beneath set toolbar 

 ```swift 
 func setNavigationButton() {
        
        
        let back = UIBarButtonItem(barButtonSystemItem: .Rewind, target: webView, action: #selector(WKWebView.goBack))
        let forward = UIBarButtonItem(barButtonSystemItem: .FastForward, target: webView, action: #selector(WKWebView.goForward))
		//rightBarButtonItem with `s`, need to reverse to currect order
		navigationItem.rightBarButtonItems = [back, forward].reverse()
    }
 ```
 
19. Hide toolbar and navigation bar on Swipe.

 ```swift 
 	override func viewWillAppear(animated: Bool) {
    	...
    	navigationController?.hidesBarsOnSwipe = true
	}
	override func viewWillDisappear(animated: Bool) {
    	...
    	navigationController?.hidesBarsOnSwipe = false
	}
 ```
 
20. Controll policy by not allow user to go out the list of available websites.

 ```swift
 		// MARK :- WKNavigationDelegate
     func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.URL
        if let host = url!.host {
            for website in websites {
                if host.rangeOfString(website)  != nil{
                    decisionHandler(.Allow)
                    return
                }
            }
        }
        decisionHandler(.Cancel)
    }
 ```
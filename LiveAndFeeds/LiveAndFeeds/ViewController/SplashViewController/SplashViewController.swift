//
//  SplashViewController.swift
//  Live and Feed
//
//  Created by Krishantha Sunil on 21/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData




class SplashViewController: ParentViewController,NSXMLParserDelegate {
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var parser = NSXMLParser()
    var feeds = [NSManagedObject]()
    var element = NSString()
    var utils = Utils()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var xmlAttributeDictionary = NSDictionary()
     let constant = Constants()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(false);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if !Utils.isConnectedToNetwork() {
            
            var alert = UIAlertController(title: "Error!", message: "Cannot connect to the Internet, Please check your internet settings.. Your application will exit now", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                
                switch action.style {
                case .Default:
                   exit(0)
                case .Destructive:
                    self.println("Destructive")
                    
                case .Cancel:
               self.println("Cancel")
                    
                    
                }
            }))
                        self.presentViewController(alert, animated: true, completion: nil);
            
            return;
        }
        
        dispatch_async(utils.GlobalUserInitiatedQueue){
            self.DownloadLiveData()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func LiveMediaInsertSuccess() {
     self.beginParsingXml()
    }
    

    
    // MARK: - Call XML Url
    
    func beginParsingXml(){
        feeds = []
        let url = NSURL(string: constant.xmlServerUrl)
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    
    // MARK: - Parser Delegate
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        element = elementName;
        
        if(elementName as NSString).isEqualToString("Feed"){
            
            xmlAttributeDictionary = attributeDict
            
            println ("\(xmlAttributeDictionary)")
            println("\(attributeDict)")
            
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        if(element as NSString).isEqualToString("Feed"){
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedObjectContext = appDelegate.managedObjectContext!
            
            var  feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
            
            var feed = Feed(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            
            feed.name = xmlAttributeDictionary["name"]! as! String
            feed.airingCategory = xmlAttributeDictionary["airingCategory"]! as! String
            feed.urlValue = string!
            
            println("Url is \(string)")
            
            var error: NSError?
            
            if !managedObjectContext.save(&error){
                println("could not save \(error), \(error?.userInfo)")
            }
            
            
            
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        println("Element name \(elementName)")
        println("Qualified name \(qName)")
        element = "";
        
        if ((elementName as NSString).isEqualToString("feedList")){
            
            dispatch_async(utils.GlobalMainQueue){
                
                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                   self.setupPhoneScreens()
                } else {
                    self.setupPadScreen()
                }
                
                
                self.activityIndicator.stopAnimating()
                
                
            }
            
        }
    }
    
    
    // SetUp Tab Bar Controller For Phone
    func setupPhoneScreens() {
        
        let tabBarController = UITabBarController();
       
        //Live_iPhone
        let liveViewController = LiveViewController(nibName : self.getNibName("Live"), bundle: nil)
        let feedListViewController = FeedListViewController(nibName : "FeedList_iPhone" , bundle : nil)
        
        var liveNavigationController = UINavigationController(rootViewController: liveViewController);
        var feedNavigationController = UINavigationController(rootViewController: feedListViewController)

        let viewControllers = [liveNavigationController,feedNavigationController]
        tabBarController.viewControllers = viewControllers;


        self.appDelegate.window?.rootViewController = tabBarController;
        
        liveNavigationController.tabBarItem = UITabBarItem(title: "Live", image: nil, selectedImage: nil)
        feedNavigationController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
        
    }
    
    func setupPadScreen() {
        let tabBarController = UITabBarController();
        //Live_iPhone
        let liveViewController = LiveViewController(nibName : self.getNibName("Live"), bundle: nil)
        let feedListViewController = FeedListViewController(nibName : "FeedList_iPhone" , bundle : nil)
        let splitViewController = UISplitViewController()
        
        var liveNavigationController = UINavigationController(rootViewController: liveViewController);
       
        var feedMediaViewController = FeedMediaViewController(nibName: self.getNibName("FeedMeida"), bundle:nil)
        
        
        
        let splitViewControllers = [feedListViewController,feedMediaViewController]
         splitViewController.viewControllers = splitViewControllers
        let viewControllers = [liveNavigationController,splitViewController]
       
        tabBarController.viewControllers = viewControllers;

        
        self.appDelegate.window?.rootViewController = tabBarController;
        
        liveNavigationController.tabBarItem = UITabBarItem(title: "Live", image: nil, selectedImage: nil)
        splitViewController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
        //                splitViewController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
        
        

    }
    
    override func println(object:Any){
        
        #if DEBUG
        Swift.println(object)
        #endif
        
        
    }
    
    
}

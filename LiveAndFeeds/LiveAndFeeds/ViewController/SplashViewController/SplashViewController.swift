//
//  SplashViewController.swift
//  Live and Feed
//
//  Created by Krishantha Sunil on 21/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData




class SplashViewController: UIViewController,NSXMLParserDelegate {
    
    
    
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
        dispatch_async(utils.GlobalUserInitiatedQueue){
            self.DownloadLiveData()
            
//            self.beginParsingXml();
            
        }
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(false);
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Downlod Live Feed
    
    func DownloadLiveData(){
        
       
        var backgroundDownload = BackgroundDownload();
        var mediaAccess = MediaAccess()
        
        backgroundDownload.DownloadData(constant.liveFeedUrl, success: { (response: AnyObject!)->Void in
            println("Success")
            
            var mediaArray = response["entries"]! as! NSMutableArray
           
            mediaAccess.insertIntoMedia(response)
            
            self.beginParsingXml()
            
            }, failure: { (error:NSError?)->Void in
                println("Failure")
        })
        
        
        
        
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
                self.activityIndicator.stopAnimating()
                let tabBarController = UITabBarController();
                let liveViewController = LiveViewController(nibName : "Live_iPhone", bundle: nil)
                let feedListViewController = FeedListViewController(nibName : "FeedList_iPhone" , bundle : nil)
                
                var liveNavigationController = UINavigationController(rootViewController: liveViewController);
                var feedNavigationController = UINavigationController(rootViewController: feedListViewController)
                let viewControllers = [liveNavigationController,feedNavigationController]
                tabBarController.viewControllers = viewControllers;
                
                self.appDelegate.window?.rootViewController = tabBarController;
                
                liveNavigationController.tabBarItem = UITabBarItem(title: "Live", image: nil, selectedImage: nil)
                feedNavigationController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
                
           

                
            }
            
        }
    }
    
    
    
    
    
    
}

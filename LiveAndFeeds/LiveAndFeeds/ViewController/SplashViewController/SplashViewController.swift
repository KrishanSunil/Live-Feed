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
//    var parser = NSXMLParser()
//    var feeds = [NSManagedObject]()
//    var element = NSString()
    var utils = Utils()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    var xmlAttributeDictionary = NSMutableDictionary()
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
                    println("Destructive")
                    
                case .Cancel:
                    println("Cancel")
                    
                    
                }
            }))
                        self.presentViewController(alert, animated: true, completion: nil);
            
            return;
        }
        
        dispatch_async(utils.GlobalUserInitiatedQueue){
//            self.DownloadLiveData()
            self.beginParsingXml()
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
//    
//    func beginParsingXml(){
//        feeds = []
//        let url = NSURL(string: constant.xmlServerUrl)
//        parser = NSXMLParser(contentsOfURL: url)!
//        parser.delegate = self
//        parser.parse()
//    }
//    
//    
//    // MARK: - Parser Delegate
//    
//    
//    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
//        element = elementName;
//        println("Element Name \(element)")
//        
//        if((elementName as NSString).isEqualToString("Feed")||(elementName as NSString).isEqualToString("User")){
//
//            xmlAttributeDictionary.removeAllObjects()
//            var attributes:NSDictionary = attributeDict as NSDictionary
//            xmlAttributeDictionary = attributes.mutableCopy() as! NSMutableDictionary
//            
//            println ("\(xmlAttributeDictionary)")
//            println("\(attributeDict)")
//            
//        }
//    }
//    
//    func parser(parser: NSXMLParser, foundCharacters string: String?)
//    {
//        
//        println("Element Name **** \(element)")
//        if(element as NSString).isEqualToString("Feed"){
//            
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            let managedObjectContext = appDelegate.managedObjectContext!
//            
//            var  feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
//            
//            var feed = Feed(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
//            
//            feed.name = xmlAttributeDictionary["name"]! as! String
//            feed.airingCategory = xmlAttributeDictionary["airingCategory"]! as! String
//            feed.urlValue = string!
//            
//            println("Url is \(string)")
//            
//            var error: NSError?
//            
//            if !managedObjectContext.save(&error){
//                println("could not save \(error), \(error?.userInfo)")
//            }
//            
//           return
//            
//        }
//        
//        if (element as NSString).isEqualToString("User"){
//            
//            var userDataAccess = UserDataAccess()
//            userDataAccess.insertUser(xmlAttributeDictionary["userName"] as! NSString, password: xmlAttributeDictionary["password"] as! NSString)
//            
//        }
//    }
    
    override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        println("Element Name  End \(element)")
        element = "";
        
        if ((elementName as NSString).isEqualToString("feedList")){
            
            dispatch_async(utils.GlobalMainQueue){
                
//                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//                   self.setupPhoneScreens()
//                } else {
//                    self.setupPadScreen()
//                }
                
                let loginViewController = LoginViewController(nibName :self.getNibName("LoginView"), bundle:nil)
                    self.appDelegate.window?.rootViewController = loginViewController;
                
                
                self.activityIndicator.stopAnimating()
                
                
            }
            
        }
    }
    
    
       

    
}

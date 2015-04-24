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
    
    let xmlServerUrl:String = "http://tv.foxsportsasia.com/FeedList.xml"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var parser = NSXMLParser()
    var feeds = [NSManagedObject]()
    var element = NSString()
    var utils = Utils()
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var xmlAttributeDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        beginParsingXml()
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(false);
        dispatch_async(utils.GlobalUserInitiatedQueue){
            self.beginParsingXml();
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Call XML Url
    
    func beginParsingXml(){
        feeds = []
        let url = NSURL(string: xmlServerUrl)
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    
    // MARK: - Parser Delegate
    
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        element = elementName;
        
        if(elementName as NSString).isEqualToString("Feed"){
            
            xmlAttributeDictionary = attributeDict
            
            println ("\(xmlAttributeDictionary)")
            println("\(attributeDict)")
            
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        if(element as NSString).isEqualToString("Feed"){
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            let managedObjectContext = appDelegate.managedObjectContext!
            
            var  feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
            
            var feed = Feed(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            
            feed.name = xmlAttributeDictionary["name"]! as String
            feed.airingCategory = xmlAttributeDictionary["airingCategory"]! as String
            feed.urlValue = string
            
            println("Url is \(string)")
            
            var error: NSError?
            
            if !managedObjectContext.save(&error){
                println("could not save \(error), \(error?.userInfo)")
            }
            
            
            
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        println("Element name \(elementName)")
        println("Qualified name \(qName)")
        element = "";
    }
    
    
    
    
    
    
}

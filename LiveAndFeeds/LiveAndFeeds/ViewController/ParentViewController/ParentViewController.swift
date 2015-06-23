//
//  ParentViewController.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 6/5/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData


class ParentViewController: UIViewController,NSXMLParserDelegate {
    
     let M3U = "M3U"
     let MPEG4 = "MPEG4"
    let ariringCategory = "Live"
    
    var parser = NSXMLParser()
    var feeds = [NSManagedObject]()
    var element = NSString()
    var xmlAttributeDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars  = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func processMedia(clickedMedia:Media) {
        
        var contentObjects:NSArray = clickedMedia.contentRelationShip.allObjects as NSArray
        
        if contentObjects.count==0{
            
            
            return;
        }
        
        for (index, content) in enumerate(contentObjects){
            
            
            var clickedContent = content as! Content
            
            if clickedContent.format == M3U{
                
                let videoViewController = VideoViewController(nibName : getNibName("Video") , bundle: nil)
                videoViewController.clickedMediaUrl = clickedContent.url
                videoViewController.hidesBottomBarWhenPushed = true
                
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    self.splitViewController?.presentViewController(videoViewController, animated: true, completion: {
                        
                    });
                    return
                }
                
                self.navigationController?.pushViewController(videoViewController, animated: true);
                break
                
            } else if clickedContent.format == MPEG4 {
                
               
//                dispatch_async(utils.GlobalUserInitiatedQueue){
                
                    self.processSmilFile(clickedContent.url);
                    break
                    
//                }
                
            }
        }
        
    }
    
    func processSmilFile(clickedContentUrl:NSString) {
         var utils = Utils()
         dispatch_async(utils.GlobalUserInitiatedQueue){
            
            var backgroudnProcess = BackgroundDownload()
            backgroudnProcess.ProcessSmilFileForVOD(clickedContentUrl, success:{ (videoUrl:NSString) -> Void in
                
                 dispatch_async(utils.GlobalMainQueue){
                
                    
                    let videoViewController = VideoViewController(nibName : self.getNibName("Video") , bundle: nil)
                    videoViewController.clickedMediaUrl = videoUrl
                    videoViewController.hidesBottomBarWhenPushed = true
                    
                    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                        self.splitViewController?.presentViewController(videoViewController, animated: true, completion: {
                            
                        });
                        return
                    }
                    
                    self.navigationController?.pushViewController(videoViewController, animated: true);
                   

                }
                
                }, failure: { (error:NSError?) -> Void in
                    
                    println("Failed to obtain url from feed")
            })
        }
        
      
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false;
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    func getNibName(name : String) -> String {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return (name as String)+"_iPad"
        }
        return (name as String)+"_iPhone"
    }
    
    
    // MARK - Download Live Media
    
    func DownloadLiveData(){
        
        
        var backgroundDownload = BackgroundDownload();
        var mediaAccess = MediaAccess()
        var constant = Constants()
        backgroundDownload.DownloadData(constant.liveFeedUrl, success: { (response: AnyObject!)->Void in
       println("Success")
            
            var mediaArray = response["entries"]! as! NSMutableArray
            mediaAccess.feedName = mediaAccess.live
//            mediaAccess.insertIntoMedia(response)
            mediaAccess.insertIntoMedia(response, feedname: mediaAccess.live)
            
            self.LiveMediaInsertSuccess()
            
            }, failure: { (error:NSError?)->Void in
                println("Failure")
        })

    }
    
    func LiveMediaInsertSuccess(){
        println("Overwrite this function")
    }
    
//    func println(object:Any){
//        
//        #if DEBUG
//            Swift.println(object)
//        #endif
//        
//        
//    }
    
    
    // MARK: - Call XML Url
    
    func beginParsingXml(){
        feeds = []
        let constant = Constants()
        let url = NSURL(string: constant.xmlServerUrl)
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    
    // MARK: - Parser Delegate
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        element = elementName;
        println("Element Name \(element)")
        
        if((elementName as NSString).isEqualToString("Feed")||(elementName as NSString).isEqualToString("User")){
            
            xmlAttributeDictionary.removeAllObjects()
            var attributes:NSDictionary = attributeDict as NSDictionary
            xmlAttributeDictionary = attributes.mutableCopy() as! NSMutableDictionary
            
            println ("\(xmlAttributeDictionary)")
            println("\(attributeDict)")
            
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        
        println("Element Name **** \(element)")
        if(element as NSString).isEqualToString("Feed"){
            
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
             var feedMediaAccess = FeedMediaAccess()
            feedMediaAccess.deleteAllFeedEntries(xmlAttributeDictionary["name"] as! NSString )
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedObjectContext = appDelegate.managedObjectContext!
            
            var  feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
            
            var feed = Feed(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
             println("Url is \(string!)")
            
            feed.name = xmlAttributeDictionary["name"]! as! String
            feed.airingCategory = xmlAttributeDictionary["airingCategory"]! as! String
            feed.urlValue = string!
            

            
            var error: NSError?
            
            if !managedObjectContext.save(&error){
                println("could not save \(error), \(error?.userInfo)")
            }

            
//            var urlString:NSString  = string!
//            println("String Url is *************** \(urlString)")
//            var feedMediaAccess = FeedMediaAccess()
//            feedMediaAccess.insertIntoFeed(xmlAttributeDictionary, string: string!)
            
            return
            
        }
        
        if (element as NSString).isEqualToString("User"){
            
            var userDataAccess = UserDataAccess()
            userDataAccess.insertUser(xmlAttributeDictionary["userName"] as! NSString, password: xmlAttributeDictionary["password"] as! NSString)
            
        }
    }
    

   override func  prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        println("Element Name  End \(element)")
//        element = "";
//        var utils = Utils()
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        if ((elementName as NSString).isEqualToString("feedList")){
//            
//            dispatch_async(utils.GlobalMainQueue){
//                
//                //                if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//                //                   self.setupPhoneScreens()
//                //                } else {
//                //                    self.setupPadScreen()
//                //                }
//                
//                let loginViewController = LoginViewController(nibName :self.getNibName("LoginView"), bundle:nil)
////                self.appDelegate.window?.rootViewController = loginViewController;
////                
////                
////                self.activityIndicator.stopAnimating()
////                
//                
//            }
//            
//        }
    }

}

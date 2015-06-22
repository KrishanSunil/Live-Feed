//
//  FeedListViewController.swift
//  Live and Feed
//
//  Created by Krishantha Sunil on 17/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class FeedListViewController: ParentViewController,UITableViewDataSource,UITableViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var _fetchedResultsController :NSFetchedResultsController?
    var isClicked:Bool = false
    var pullDownRefreshController:UIRefreshControl!
    @IBOutlet weak var feedTableViewController: UITableView!
    var utils = Utils()
    
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feeds"
        self.feedTableViewController.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.pullDownRefreshController = UIRefreshControl()
        self.pullDownRefreshController.addTarget(self, action:Selector("refreshCollectionView"), forControlEvents: UIControlEvents.ValueChanged)
        self.feedTableViewController.addSubview(self.pullDownRefreshController)
      
        var error:NSError?
        if !self.fetchedResultsController.performFetch(&error){
            println("Fetch Error : \(error?.localizedDescription)")
            abort()
        }

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var fetchedResultsController:NSFetchedResultsController {
        
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
      
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = feedEntityDescription;
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self._fetchedResultsController = aFetchedResultsController

        return self._fetchedResultsController!
        
    }
    

// MARK - Table View Data Source and Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        var sectionInfo = self._fetchedResultsController?.sections![section] as! NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell:UITableViewCell = self.feedTableViewController.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        var feed = self._fetchedResultsController?.objectAtIndexPath(indexPath) as! Feed
        cell.textLabel!.text = feed.name
        
        if indexPath.row == 0 && !isClicked {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        } else if(indexPath.row == selectedIndex && UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            
//            let firstFeed = self._fetchedResultsController?.fetchedObjects?.first as! Feed
            
            var feedMediaViewController = self.splitViewController?.viewControllers[1] as! FeedMediaViewController
            feedMediaViewController.clickedFeed = feed
            feedMediaViewController.feedMediaClicked();
        }
        
        return cell
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !isClicked && UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let firstFeed = self._fetchedResultsController?.fetchedObjects?.first as! Feed
            
            var feedMediaViewController = self.splitViewController?.viewControllers[1] as! FeedMediaViewController
            feedMediaViewController.clickedFeed = firstFeed
            feedMediaViewController.feedMediaClicked();
            selectedIndex = 0
            return
        }
        

    }
    
// MARK - Table View Delegate Method
    
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    isClicked = true
    selectedIndex = indexPath.row
     var selectedFeed = self._fetchedResultsController?.objectAtIndexPath(indexPath) as! Feed
    if self.splitViewController != nil {
        var feedMediaViewController = self.splitViewController?.viewControllers[1] as! FeedMediaViewController
        feedMediaViewController.clickedFeed = selectedFeed
        
        feedMediaViewController._fetchedResultsController = nil
        feedMediaViewController.feedMediaClicked();
        return;
    }
//        var selectedFeed = self._fetchedResultsController?.objectAtIndexPath(indexPath) as! Feed
        var feedMediaViewController = FeedMediaViewController(nibName:"FeedMeida_iPhone", bundle:nil)
        feedMediaViewController.clickedFeed = selectedFeed
        navigationController?.pushViewController(feedMediaViewController, animated: true)
 
    }
    
    func refreshCollectionView() {
        if !Utils.isConnectedToNetwork() {
            
            var alert = UIAlertController(title: "Error!", message: "Cannot connect to the Internet, Please check your internet settings..", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                
                switch action.style {
                case .Default:
                    println("Default")

//                    self.activityIndicator.stopAnimating()
//                    self.activityIndicator.hidden = true
                case .Destructive:
                    println("Destructive")
                    
                case .Cancel:
                    println("Cancel")
                    
                    
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil);
            
            //            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil);
            
            return;
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.splitViewController!.view.userInteractionEnabled = false
        }else{
            self.view.userInteractionEnabled = false
        }
        
//        dispatch_async(utils.GlobalUserInitiatedQueue){
//            self.DownloadMedia()
            self.beginParsingXml()
            
//        }
        
    }
    
    func deleteAllFeeds(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let manageOBC:NSManagedObjectContext  = appDelegate.managedObjectContext!
    
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        
        
        
        var error : NSError?
        
        var fetchResults = manageOBC.executeFetchRequest(fetchRequest, error: &error) as! [Feed]
        
         var feedObjects:[Feed] = fetchResults
        
        if feedObjects.count>0 {
            for entity in feedObjects {
                manageOBC.deleteObject(entity)
                
                manageOBC.save(nil)
            }
            
        }else{
            println("No media found for the Feed")
        }

    }
    
//    override func beginParsingXml() {
//        println("Start Downloading")
//      
////        var feedMediaAccess = FeedMediaAccess()
////        self.deleteAllFeeds()
////        feedMediaAccess.deleteAllFeedEntries()
////        dispatch_async(utils.GlobalUserInitiatedQueue){
//            super.beginParsingXml()
//        //
////        }
//    }
    
  override func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        
        println("Element Name  End \(element)")
        element = "";
        
        if ((elementName as NSString).isEqualToString("feedList")){
            self._fetchedResultsController = nil
            var error:NSError?
            if !self.fetchedResultsController.performFetch(&error){
                println("Fetch Error : \(error?.localizedDescription)")
                abort()
            }
            self.pullDownRefreshController.endRefreshing()
            self.feedTableViewController.reloadData()
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                self.splitViewController!.view.userInteractionEnabled = true
            }else{
                self.view.userInteractionEnabled = true
            }

            
                
            }
            
        }
}

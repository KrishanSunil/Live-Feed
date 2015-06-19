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
    @IBOutlet weak var feedTableViewController: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Feeds"
        self.feedTableViewController.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
      
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
            
            return
        }
    }
    
// MARK - Table View Delegate Method
    
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    isClicked = true
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

}

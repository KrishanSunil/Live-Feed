//
//  FeedMediaViewController.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 6/5/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class FeedMediaViewController: ParentViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    

    
    
    @IBOutlet weak var flowlayout: UICollectionViewFlowLayout!
    var clickedFeed : Feed!
    
    @IBOutlet weak var feedMediaCollectionView: UICollectionView!
    var pullDownRefreshController:UIRefreshControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var _fetchedResultsController :NSFetchedResultsController?
    var utils = Utils()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pullDownRefreshController = UIRefreshControl()
        self.pullDownRefreshController.addTarget(self, action:Selector("refreshCollectionView"), forControlEvents: UIControlEvents.ValueChanged)
        self.feedMediaCollectionView.addSubview(self.pullDownRefreshController)

        loadMediaDetails()
    
    }
    
    func loadMediaDetails(){
        if clickedFeed == nil {
            return
        }
        self.title = clickedFeed.name
        self.activityIndicator.startAnimating()
        
        var meediAccess = MediaAccess()
        var mediaCount = meediAccess.getMediaCount(clickedFeed.name)
        
        let nib = UINib(nibName: "LiveCollectionView_iPhone", bundle: nil)
        self.feedMediaCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
        
        if mediaCount > 0 {
            self._fetchedResultsController = nil;
            var error:NSError?
            if !self.fetchedResultsController.performFetch(&error){
                ////println("Fetch Error : \(error?.localizedDescription)")
                abort()
            }
            
            self.enableFeedMediaCollectionView()
            
            return;
        }
        
        if !Utils.isConnectedToNetwork() {
            
            var alert = UIAlertController(title: "Error!", message: "Cannot connect to the Internet, Please check your internet settings..", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                
                switch action.style {
                case .Default:
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                case .Destructive:
                   self.println("Destructive")
                    
                case .Cancel:
                    self.println("Cancel")
                    
                    
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil);
            
            //            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil);
            
            return;
        }
        
        
        dispatch_async(utils.GlobalUserInitiatedQueue){
            self.DownloadMedia()
            
        }
        
        

    }
    
    var fetchedResultsController:NSFetchedResultsController {
        
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let feedEntityDescription = NSEntityDescription.entityForName("Media", inManagedObjectContext: managedObjectContext)
        let livePredicate = NSPredicate(format: "feedName == %@", clickedFeed.name )
        
        let sortDescriptor = NSSortDescriptor(key: "availableDate", ascending: false)
        
        let fetchRequest = NSFetchRequest()
        
        fetchRequest.entity = feedEntityDescription;
        fetchRequest.predicate = livePredicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self._fetchedResultsController = aFetchedResultsController

        return self._fetchedResultsController!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableFeedMediaCollectionView(){
        self.feedMediaCollectionView.dataSource = self;
        self.feedMediaCollectionView.delegate = self;
        self.feedMediaCollectionView .reloadData();
        self.feedMediaCollectionView.hidden = false;
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        self.pullDownRefreshController.endRefreshing()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.splitViewController!.view.userInteractionEnabled = true
        }else{
            self.view.userInteractionEnabled = true
        }
    }

    // MARK - Media Data
    func DownloadMedia() {
        
        var backgroundDownload = BackgroundDownload();
        var mediaAccess = MediaAccess()
        
        backgroundDownload.DownloadData(clickedFeed.urlValue, success: { (response: AnyObject!)->Void in
            //println("Success")
            
            var mediaArray = response["entries"]! as! NSMutableArray
            
            mediaAccess.insertIntoMedia(response, feedname: self.clickedFeed.name)
            
            dispatch_async(self.utils.GlobalMainQueue){
            
                var error:NSError?
                if !self.fetchedResultsController.performFetch(&error){
                    //println("Fetch Error : \(error?.localizedDescription)")
                    abort()
                }
            
                self.enableFeedMediaCollectionView()
            }
            }, failure: { (error:NSError?)->Void in
                //println("Failure")
        })

        
    }
    
    
    // MARK - Collection View Data Source Method
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var sectionInfo = self._fetchedResultsController?.sections![section] as! NSFetchedResultsSectionInfo
        
        return sectionInfo.numberOfObjects
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! LiveCollectionViewCell
        
        var media = self._fetchedResultsController?.objectAtIndexPath(indexPath) as! Media
        cell.nameLable.text = media.title
        
        
        cell.image.sd_setImageWithURL(NSURL(string:media.defaultThumbnailUrl), placeholderImage: UIImage(named: "placeholder.png"))
        

        return cell
    }
    
    // MARK - Collection View Flow Delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return CGSizeMake(341.0, 180.0)
        }
        
        let widthForCell:CGFloat = CGRectGetWidth(collectionView.frame)-self.flowlayout.sectionInset.left - self.flowlayout.sectionInset.right - self.flowlayout.minimumInteritemSpacing * 0
        
        let cellWidth :CGFloat = widthForCell/1
        
        //        self.flowlayout.itemSize = CGSizeMake(cellWidth, self.flowlayout.itemSize.height)
        return CGSizeMake(cellWidth, cellWidth/1.7)
        
        
        //        let isIphone:Bool = UIDevice.currentDevice().userInterfaceIdiom == .Phone
        //
        //        if isIphone {
        //            let screenSize : CGRect = UIScreen.mainScreen().bounds
        //
        //            let screenWidth = screenSize.width
        //            let screenHeight = screenSize.height
        //
        //            return CGSize(width: 400.0, height: screenWidth/1.7)
        //        }
        //        
        //        return CGSize (width: 331, height: 180)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var selectedMedia = self._fetchedResultsController?.objectAtIndexPath(indexPath) as! Media
        
        
        
        self.processMedia(selectedMedia)
    }
    
    // MARK - Feed Media Clicked Delegate Method
    
    func feedMediaClicked() {
        //////println("Split View Method Called")
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.splitViewController!.view.userInteractionEnabled = false
        }else{
            self.view.userInteractionEnabled = false
        }
        loadMediaDetails()
    }
    
    
    func refreshCollectionView() {
        if !Utils.isConnectedToNetwork() {
            
            var alert = UIAlertController(title: "Error!", message: "Cannot connect to the Internet, Please check your internet settings..", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                
                switch action.style {
                case .Default:
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                case .Destructive:
                    self.println("Destructive")
                    
                case .Cancel:
                    self.println("Cancel")
                    
                    
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
        
        dispatch_async(utils.GlobalUserInitiatedQueue){
            self.DownloadMedia()
            
        }

    }

}

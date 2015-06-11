//
//  LiveViewController.swift
//  Live and Feed
//
//  Created by Krishantha Sunil on 17/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class LiveViewController: ParentViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var liveCollectionView: UICollectionView!
    var pullDownRefreshController:UIRefreshControl!
    @IBOutlet weak var flowlayout: UICollectionViewFlowLayout!
   var utils = Utils()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var _fetchedResultsController :NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Live"
        
        
        let nib = UINib(nibName: "LiveCollectionView_iPhone", bundle: nil)
        self.liveCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
       
        self.pullDownRefreshController = UIRefreshControl()
        self.pullDownRefreshController.addTarget(self, action:Selector("refreshCollectionView"), forControlEvents: UIControlEvents.ValueChanged)
        self.liveCollectionView.addSubview(self.pullDownRefreshController)
        var error:NSError?
        if !self.fetchedResultsController.performFetch(&error){
            println("Fetch Error : \(error?.localizedDescription)")
            abort()
        }
    }
    
    var fetchedResultsController:NSFetchedResultsController {
        
        
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let feedEntityDescription = NSEntityDescription.entityForName("Media", inManagedObjectContext: managedObjectContext)
//        let livePredicate = NSPredicate(format: "isLive == %@", true as NSNumber )
        let livePredicate = NSPredicate(format: "feedName == %@", "Live" )
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
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
        
        cell.image.sd_setImageWithURL(NSURL(string: media.defaultThumbnailUrl), placeholderImage: UIImage(named: "placeholder.png"))
        
        println("Cell Detail : \(cell)")
        return cell
    }
    
    // MARK - Collection View Flow Delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            return CGSizeMake(341.0, 180.0)
        }
        
        let widthForCell:CGFloat = CGRectGetWidth(collectionView.frame)-self.flowlayout.sectionInset.left - self.flowlayout.sectionInset.right - self.flowlayout.minimumInteritemSpacing * 0
        
        let cellWidth :CGFloat = widthForCell/1
        
        return CGSizeMake(cellWidth, cellWidth/1.7)

        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var selectedMedia = self._fetchedResultsController?.objectAtIndexPath(indexPath) as! Media
        self.processMedia(selectedMedia)
    }
    
    
    
    // MARK - View Will Appear Method
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true;
        self.tabBarController?.tabBar.hidden = false
    }
    
  // MARK - Pull Down Refresh View 
    func refreshCollectionView() {
        
       
        
      
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
        self.view.userInteractionEnabled = false;
        dispatch_async(utils.GlobalUserInitiatedQueue){
            self.DownloadLiveData()  
        }

        
    }

    
    override func LiveMediaInsertSuccess() {
        
        self._fetchedResultsController = nil
        var error:NSError?
        if !self.fetchedResultsController.performFetch(&error){
            println("Fetch Error : \(error?.localizedDescription)")
            abort()
        }
        self.liveCollectionView.reloadData()
        self.pullDownRefreshController.endRefreshing()
        self.view.userInteractionEnabled = true
    
    }
    


}

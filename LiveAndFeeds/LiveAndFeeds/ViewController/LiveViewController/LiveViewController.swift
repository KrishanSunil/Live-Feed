//
//  LiveViewController.swift
//  Live and Feed
//
//  Created by Krishantha Sunil on 17/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class LiveViewController: ParentViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var liveCollectionView: UICollectionView!
    
    @IBOutlet weak var flowlayout: UICollectionViewFlowLayout!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var _fetchedResultsController :NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Live"
        
        let nib = UINib(nibName: "LiveCollectionView_iPhone", bundle: nil)
        self.liveCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
        
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
        let livePredicate = NSPredicate(format: "isLive == %@", true as NSNumber )
        
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

}

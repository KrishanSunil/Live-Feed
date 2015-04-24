//
//  LiveViewController.swift
//  Live and Feed
//
//  Created by Krishantha Sunil on 17/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class LiveViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var liveCollectionView: UICollectionView!
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var _fetchedResultsController :NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
        let livePredicate = NSPredicate(format: "airingCategory == %@", "Live")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

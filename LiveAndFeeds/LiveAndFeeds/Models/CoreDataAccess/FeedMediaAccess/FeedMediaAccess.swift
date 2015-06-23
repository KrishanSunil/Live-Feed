//
//  FeedMediaAccess.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 22/6/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class FeedMediaAccess: NSObject {
    
    func insertIntoFeed(xmlAttributeDictionary:NSMutableDictionary, string: String) {
        self.deleteAllFeedEntries(xmlAttributeDictionary["name"] as! NSString )
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        var  feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext)
        
        var feed = Feed(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        feed.name = xmlAttributeDictionary["name"]! as! String
        feed.airingCategory = xmlAttributeDictionary["airingCategory"]! as! String
        feed.urlValue = string
        
        println("Url is \(string)")
        
        var error: NSError?
        
        if !managedObjectContext.save(&error){
            println("could not save \(error), \(error?.userInfo)")
        }

    }
    
    
    func deleteAllFeedEntries(feedName:NSString){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let manageOBC  = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        let predicate = NSPredicate(format: "name == %@", feedName )
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchResults:[Feed] = (manageOBC.executeFetchRequest(fetchRequest, error: &error) as? [Feed])!
        
        if fetchResults.count>0 {
            
            for media in fetchResults {
                manageOBC.deleteObject(media)
                manageOBC.save(nil)
            }
        }else{
            println("No media found for the Feed")
        }
        
    }
    
    
   
}

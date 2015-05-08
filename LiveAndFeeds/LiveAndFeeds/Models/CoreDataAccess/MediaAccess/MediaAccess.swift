//
//  MediaAccess.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 28/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class MediaAccess: NSObject {
    
    var feedName : NSString?
    
    func convertTimeStampStringToNSDate(timeStamp:NSNumber) -> NSDate {
//        var timeInt:Double = (timeStamp as NSString).doubleValue;
        var time = (timeStamp as Double)/(1000) as NSTimeInterval
        var date = NSDate(timeIntervalSince1970: time)
        
        return date
    }

    
    func insertIntoMedia(responseObject:AnyObject!){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        var  feedEntityDescription = NSEntityDescription.entityForName("Media", inManagedObjectContext: managedObjectContext)
        
        
        
        var mediaArray = responseObject["entries"]! as! NSMutableArray
        
        for index in 0...mediaArray.count-1 {
            var media = Media(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            var mediaObject = mediaArray[index] as! NSMutableDictionary
            media.title = mediaObject["title"]! as! String
            media.guid = mediaObject["guid"]! as! String
            
            var available = mediaObject["availableDate"]! as! NSNumber
            
            media.availableDate = self.convertTimeStampStringToNSDate(mediaObject["availableDate"]! as! NSNumber)
            media.expirationDate = self.convertTimeStampStringToNSDate(mediaObject["expirationDate"]! as! NSNumber)
            media.isLive = true
            media.defaultThumbnailUrl = mediaObject["defaultThumbnailUrl"]! as! String
            
            if self.feedName != nil{
                media.feedName = self.feedName as! String
            }
            
            
            // add content relation ship
            var contentArray = mediaObject["content"]! as! NSMutableArray
            
            for i in 0...contentArray.count-1 {
                var content = contentArray[i] as! NSMutableDictionary
                var contentEntityDescription = NSEntityDescription.entityForName("Content", inManagedObjectContext: managedObjectContext)
                var contentEntity = Content(entity: contentEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                
                contentEntity.url = content["url"] as! NSString as String
                contentEntity.format = content["format"] as! NSString as String
                
                media.addContentToMedia(contentEntity)
            }
            
            // add Categories relationship ( Usually each media will have only one categories but their are some possibilites that media will have multiple categories )
            
            var categoriesArray = mediaObject["categories"]! as! NSMutableArray
            
            for i in 0...categoriesArray.count-1 {
                var category = categoriesArray[i] as! NSMutableDictionary
                var categoryEntityDescription = NSEntityDescription.entityForName("Categories", inManagedObjectContext: managedObjectContext)
                
                var categoryEntity = Categories(entity:categoryEntityDescription!, insertIntoManagedObjectContext:managedObjectContext)
                
                categoryEntity.name = category["name"] as! NSString as String
                
                media.addCategoriesToMedia(categoryEntity)
            }
            
            
            
            var error: NSError?
            
            if !managedObjectContext.save(&error){
                println("could not save \(error), \(error?.userInfo)")
            }
        }

    }
    
    func insertIntoMedia(responseObject:AnyObject!, feedname name:NSString){
        self.feedName = name;
        self.insertIntoMedia(responseObject)
    }
    
    
    func getMedia(feedname:NSString) -> [Media] {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let manageOBC  = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Media")
        let predicate = NSPredicate(format: "feedName == %@", feedname )
        
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchResults = manageOBC.executeFetchRequest(fetchRequest, error: &error) as? [Media]
        
        if fetchResults?.count>0 {
            println("Media found for the feed")
        }else{
            println("No media found for the Feed")
        }
        
        return fetchResults!
  
    }
    
    func getMediaCount(feedname:NSString) -> Int {
        
        var mediaObjects:[Media] = getMedia(feedname);
        
        if mediaObjects.count > 0 {
            return mediaObjects.count
        }
        return 0
    }
}

//
//  UserDataAccess.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 18/6/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class UserDataAccess: NSObject {
    
    func isValidUser(userName:NSString!,password:NSString!) -> Bool{
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let manageOBC  = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Users")
        let predicate = NSPredicate(format: "userName == %@ AND password == %@", userName,password )
        
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchResults = manageOBC.executeFetchRequest(fetchRequest, error: &error) as? [Users]
        
        if fetchResults?.count>0 {
            return true
        }else{
            return false
        }
    }
    
    func insertUser(userName:NSString!,password:NSString!) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        var  usersEntityDescription = NSEntityDescription.entityForName("Users", inManagedObjectContext: managedObjectContext)
        
        var user = Users(entity: usersEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        user.userName = userName as! String
        user.password = password as! String
        
        var error: NSError?
        
        if !managedObjectContext.save(&error){
            println("could not save \(error), \(error?.userInfo)")
        }

    }
   
}

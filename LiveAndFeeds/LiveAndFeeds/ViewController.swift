//
//  ViewController.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 22/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext
        
         var  feedEntityDescription = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedObjectContext!)
        
        var feed = NSManagedObject(entity: feedEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


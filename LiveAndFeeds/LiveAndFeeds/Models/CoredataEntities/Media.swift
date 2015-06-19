//
//  Media.swift
//  
//
//  Created by Krishantha Sunil on 6/5/15.
//
//

import Foundation
import CoreData

class Media: NSManagedObject {

    @NSManaged var availableDate: NSDate
    @NSManaged var defaultThumbnailUrl: String
    @NSManaged var expirationDate: NSDate
    @NSManaged var guid: String
    @NSManaged var isLive: NSNumber
    @NSManaged var title: String
    @NSManaged var feedName: String
    @NSManaged var categoriesRelationShip: NSSet
    @NSManaged var contentRelationShip: NSSet

}

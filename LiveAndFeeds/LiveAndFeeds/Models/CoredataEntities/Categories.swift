//
//  Categories.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 28/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import Foundation
import CoreData

class Categories: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var mediaRelationShip: Media

}

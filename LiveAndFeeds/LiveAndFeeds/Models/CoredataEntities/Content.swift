//
//  Content.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 28/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import Foundation
import CoreData

class Content: NSManagedObject {

    @NSManaged var format: String
    @NSManaged var url: String
    @NSManaged var mediaRelationShip: Media

}


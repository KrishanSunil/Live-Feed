//
//  Feed.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 24/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import Foundation
import CoreData

class Feed: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var airingCategory: String
    @NSManaged var urlValue: String

}

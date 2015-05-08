//
//  Media+CoreData.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 28/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit

extension Media {
    
    func addContentToMedia(content:Content){
        var contents:NSMutableSet
        contents = self.mutableSetValueForKey("contentRelationShip")
        contents.addObject(content)
    }
    
    func addCategoriesToMedia(category:Categories){
        var categories:NSMutableSet
        categories = self.mutableSetValueForKey("categoriesRelationShip")
        categories.addObject(category)
    }
    
    
}

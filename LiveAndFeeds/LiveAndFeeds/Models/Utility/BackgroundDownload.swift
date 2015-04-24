//
//  BackgroundDownload.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 24/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit


class BackgroundDownload: NSObject {
    
    // Download Live Data from feed (http://feed.theplatform.com/f/ZwuVLC/sg_live)
    func DownloadLiveData(){
        
        let liveFeedUrl = "http://feed.theplatform.com/f/ZwuVLC/sg_live"
        
        let afNetworkingManager = AFHTTPRequestOperationManager()
    }
    
    func DownloadFeedData(feedurl:NSString){
        
    }
   
}

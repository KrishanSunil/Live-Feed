//
//  BackgroundDownload.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 24/4/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit


class BackgroundDownload: NSObject {
    
    
    // Download data from MPX 
    // Parameters : Pass mpx url to download
    func DownloadData(url:NSString, success:(response: AnyObject!)->Void, failure : (error:NSError?)->Void){
        
        let afNetworkingManager = AFHTTPRequestOperationManager()
        
        var success = { (operation:AFHTTPRequestOperation!,response:AnyObject!) -> Void in
            println(response.description)
            success(response: response)
            
        }
        
        var failure = { (operation:AFHTTPRequestOperation!,response:NSError!) -> Void in
            println(response.description)
            failure(error: response)
            
        }
        
        afNetworkingManager.GET(url as String, parameters: nil, success: success, failure: failure)

    }
   
}

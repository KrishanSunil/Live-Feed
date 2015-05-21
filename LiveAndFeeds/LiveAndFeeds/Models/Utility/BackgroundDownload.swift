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
    
    
    func ProcessSmilFileForVOD(url:NSString, success:(videoUrl:NSString) -> Void, failure:(error:NSError?) -> Void){
        var urlStirg:NSString = (url as String) + "&manifest=m3u"
        var smilUrl:NSURL = NSURL(string: urlStirg as String)!
        var data:NSData = NSData(contentsOfURL: smilUrl)!
        var dataString:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
      
        
       
        
        var smilData:TFHpple = TFHpple(HTMLData: data)
        var xpathQueryString = "//seq/video"
        var nodes = smilData.searchWithXPathQuery(xpathQueryString) as NSArray
        
        for (index, content) in enumerate(nodes) {
            
            var element = content as! TFHppleElement
            var videoUrl = element.objectForKey("src")
            println("Url To Play \(videoUrl)")
            
            success(videoUrl: videoUrl)
            
            break
        }
        
        failure(error: nil)
        
        
        // 4
        


    }
    
 
   
}

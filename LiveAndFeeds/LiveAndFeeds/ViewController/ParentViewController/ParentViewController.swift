//
//  ParentViewController.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 6/5/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit


class ParentViewController: UIViewController {
    
     let M3U = "M3U"
     let MPEG4 = "MPEG4"
    let ariringCategory = "Live"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func processMedia(clickedMedia:Media) {
        
        var contentObjects:NSArray = clickedMedia.contentRelationShip.allObjects as NSArray
        
        if contentObjects.count==0{
            
            
            return;
        }
        
        for (index, content) in enumerate(contentObjects){
            
            
            var clickedContent = content as! Content
            
            if clickedContent.format == M3U{
                
                let videoViewController = VideoViewController(nibName : getNibName("Video") , bundle: nil)
                videoViewController.clickedMediaUrl = clickedContent.url
                videoViewController.hidesBottomBarWhenPushed = true
                
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    self.tabBarController?.presentViewController(videoViewController, animated: true, completion: {
                        
                    });
                    return
                }
                
                self.navigationController?.pushViewController(videoViewController, animated: true);
                break
                
            } else if clickedContent.format == MPEG4 {
                
               
//                dispatch_async(utils.GlobalUserInitiatedQueue){
                
                    self.processSmilFile(clickedContent.url);
                    break
                    
//                }
                
            }
        }
        
    }
    
    func processSmilFile(clickedContentUrl:NSString) {
         var utils = Utils()
         dispatch_async(utils.GlobalUserInitiatedQueue){
            
            var backgroudnProcess = BackgroundDownload()
            backgroudnProcess.ProcessSmilFileForVOD(clickedContentUrl, success:{ (videoUrl:NSString) -> Void in
                
                 dispatch_async(utils.GlobalMainQueue){
                
                    
                    let videoViewController = VideoViewController(nibName : self.getNibName("Video") , bundle: nil)
                    videoViewController.clickedMediaUrl = videoUrl
                    videoViewController.hidesBottomBarWhenPushed = true
                    
                    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                        self.tabBarController?.presentViewController(videoViewController, animated: true, completion: {
                            
                        });
                        return
                    }
                    
                    self.navigationController?.pushViewController(videoViewController, animated: true);
                   

                }
                
                }, failure: { (error:NSError?) -> Void in
                    
                    println("Failed to obtain url from feed")
            })
        }
        
      
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false;
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    func getNibName(name : String) -> String {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return (name as String)+"_iPad"
        }
        return (name as String)+"_iPhone"
    }
    
    
    // MARK - Download Live Media
    
    func DownloadLiveData(){
        
        
        var backgroundDownload = BackgroundDownload();
        var mediaAccess = MediaAccess()
        var constant = Constants()
        backgroundDownload.DownloadData(constant.liveFeedUrl, success: { (response: AnyObject!)->Void in
       println("Success")
            
            var mediaArray = response["entries"]! as! NSMutableArray
            mediaAccess.feedName = mediaAccess.live
//            mediaAccess.insertIntoMedia(response)
            mediaAccess.insertIntoMedia(response, feedname: mediaAccess.live)
            
            self.LiveMediaInsertSuccess()
            
            }, failure: { (error:NSError?)->Void in
                println("Failure")
        })

    }
    
    func LiveMediaInsertSuccess(){
        println("Overwrite this function")
    }
    
//    func println(object:Any){
//        
//        #if DEBUG
//            Swift.println(object)
//        #endif
//        
//        
//    }

}

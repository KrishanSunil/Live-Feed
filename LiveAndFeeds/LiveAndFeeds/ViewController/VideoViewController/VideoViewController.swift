//
//  VideoViewController.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 18/5/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit
import MediaPlayer


class VideoViewController: UIViewController  {
    
    @IBAction func buttonDoneClicked(sender: AnyObject) {
        
//           NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: MPMoviePlayerPlaybackDidFinishNotification)
//        self.moviePlayer.stop()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.dismissViewControllerAnimated(true, completion: {
                
            });
            return
        }

        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var clickedMediaUrl:NSString = ""
    var movieViewController:MPMoviePlayerController!
    
    var moviePlayer:MPMoviePlayerController!
    
    @IBOutlet weak var videoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true;
        self.activityIndicator.startAnimating()
    
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "movieDoneClicked:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "PlayBackStateChanged:", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
//    
//    override func supportedInterfaceOrientations() -> Int {
//        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
//    }
    
//    override func viewDidAppear(animated: Bool) {
//        self.presentMoviePlayerViewControllerAnimated(movieViewController)
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        var videoUrl:NSURL = NSURL(string: clickedMediaUrl as String)!
        moviePlayer = MPMoviePlayerController(contentURL: videoUrl)
        moviePlayer.fullscreen = true
        moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
        moviePlayer.scalingMode = MPMovieScalingMode.AspectFit
        moviePlayer.prepareToPlay()
        moviePlayer.play()
        
        var playerFrame:CGRect = CGRectZero
        
        if  self.view.frame.size.height > self.view.frame.size.width{
            playerFrame.origin.x = self.view.frame.origin.x
            playerFrame.origin.y = self.view.frame.origin.y
            playerFrame.size.width = self.view.frame.size.height
            playerFrame.size.height = self.view.frame.size.width
        }else {
            playerFrame = self.view.frame
        }
        moviePlayer.view.frame = playerFrame
        self.view.addSubview(moviePlayer.view)
        moviePlayer.view.hidden = true;
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
        self.transfromViewToLandscape()
        }

    }
    
    func stopVideoPlaying() {
        
                self.moviePlayer.stop()
                if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                    self.dismissViewControllerAnimated(true, completion: {
        
                    });
                    return
                }
        
                self.navigationController?.popViewControllerAnimated(true)
    }
    
    func movieDoneClicked(argument:NSNotification){
        

        
        var reason = argument.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! NSNumber?
        
        if let theReason = reason {
            
                let reasonValue  = MPMovieFinishReason(rawValue: theReason.integerValue)
            
            switch reasonValue! {
            case .PlaybackEnded:
                self.stopVideoPlaying()
            case .PlaybackError:
                self.stopVideoPlaying()
            case .UserExited:
                self.stopVideoPlaying()
             
            default:
                println("Antoher Event happent")
            }
        }
        
    }
    
    func PlayBackStateChanged(argument:NSNotification?){
        
        
        if moviePlayer.loadState != MPMovieLoadState.Unknown {
            
            println("Movie Loaded")
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            self.moviePlayer.view.hidden = false;
        }
//        else {
//            println("Movie Loading Error")
//            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//                self.tabBarController?.dismissViewControllerAnimated(true, completion: {
//                    
//                });
//            }
//            
//            self.navigationController?.popViewControllerAnimated(true)
//        }
        
    }
    
   func transfromViewToLandscape(){
    
    var rotationDirecton:NSInteger = NSInteger()
    var currentOrientation:UIDeviceOrientation = UIDevice.currentDevice().orientation
    
    if (currentOrientation ==  UIDeviceOrientation.LandscapeLeft ) {
    rotationDirecton = 1;
    }else{
    rotationDirecton = -1;
    }
    
    var transform:CGAffineTransform = self.view.transform
    transform = CGAffineTransformRotate(transform, CGFloat(degreeToRadians(rotationDirecton*90)));
    self.view.transform = transform
    }
    
    func degreeToRadians(angle:Int) -> Double {
//        var angleDouble:Double = angle / 180.0  as Double
        
        return (Double( angle) / 180.0) * M_PI
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: MPMoviePlayerPlaybackDidFinishNotification)
    }

}

//
//  LoginViewController.swift
//  LiveAndFeeds
//
//  Created by Krishantha Sunil on 18/6/15.
//  Copyright (c) 2015 FIC. All rights reserved.
//

import UIKit

class LoginViewController: ParentViewController,UITextFieldDelegate {

    @IBOutlet weak var loginViewiPad: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isKeyBoardShown:Bool = false;
    
    
    var kbHeight : CGFloat!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func loginButtonClicked(sender: AnyObject) {
        
        if userNameTextField.text.isEmpty || passwordTextField.text.isEmpty {
            var alert = UIAlertController(title: "Error!", message: "Fields Cannot be empty", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                
                switch action.style {
                case .Default:
                    println("Ok")
                case .Destructive:
                    println("Destructive")
                    
                case .Cancel:
                    println("Cancel")
                    
                    
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil);
            
            return;

        }
        
        var userDataAccess = UserDataAccess()
        
        var isValidUser:Bool = userDataAccess.isValidUser(userNameTextField.text, password: passwordTextField.text)
        
        if !isValidUser {
            
            var alert = UIAlertController(title: "Error!", message: "Incorrect Username or Password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                
                switch action.style {
                case .Default:
                    println("Ok")
                case .Destructive:
                    println("Destructive")
                    
                case .Cancel:
                    println("Cancel")
                    
                    
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil);
            
            return;

        }
        
                        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                           self.setupPhoneScreens()
                        } else {
                            self.setupPadScreen()
                        }
    }
    // SetUp Tab Bar Controller For Phone
    func setupPhoneScreens() {
        
//        let tabBarController = UITabBarController();
//        
//        //Live_iPhone
//        let liveViewController = LiveViewController(nibName : self.getNibName("Live"), bundle: nil)
        let feedListViewController = FeedListViewController(nibName : "FeedList_iPhone" , bundle : nil)
        
//        var liveNavigationController = UINavigationController(rootViewController: liveViewController);
        var feedNavigationController = UINavigationController(rootViewController: feedListViewController)
//        
//        let viewControllers = [liveNavigationController,feedNavigationController]
//        tabBarController.viewControllers = viewControllers;
        
        
        self.appDelegate.window?.rootViewController = feedNavigationController;
        
//        liveNavigationController.tabBarItem = UITabBarItem(title: "Live", image: nil, selectedImage: nil)
//        feedNavigationController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
        
    }
    
    func setupPadScreen() {
//        let tabBarController = UITabBarController();
//        //Live_iPhone
//        let liveViewController = LiveViewController(nibName : self.getNibName("Live"), bundle: nil)
        let feedListViewController = FeedListViewController(nibName : "FeedList_iPhone" , bundle : nil)
        let splitViewController = UISplitViewController()
//        
//        var liveNavigationController = UINavigationController(rootViewController: liveViewController);
        
        var feedMediaViewController = FeedMediaViewController(nibName: self.getNibName("FeedMeida"), bundle:nil)
        
        
        
        let splitViewControllers = [feedListViewController,feedMediaViewController]
        splitViewController.viewControllers = splitViewControllers
//        let viewControllers = [liveNavigationController,splitViewController]
//        
//        tabBarController.viewControllers = viewControllers;
        
        
        self.appDelegate.window?.rootViewController = splitViewController;
        
//        liveNavigationController.tabBarItem = UITabBarItem(title: "Live", image: nil, selectedImage: nil)
//        splitViewController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
        //                splitViewController.tabBarItem = UITabBarItem(title: "Feeds", image: nil, selectedImage: nil)
 
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    func keyboardWillShow(notification:NSNotification){
        
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                kbHeight = keyboardSize.height
               
                self.animateTextField(true)
                 self.isKeyBoardShown = true
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        
            self.animateTextField(false)
            self.isKeyBoardShown = false
        }
        
        func animateTextField(up : Bool) {
            
            if (self.isKeyBoardShown == true && up == true){
                return
            }
            kbHeight = 100.0
            var movement  = (up ? -kbHeight : kbHeight)
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, movement)
            })
        }
        
        
    

    
    

}

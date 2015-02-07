//
//  AppDelegate.swift
//  Piki
//
//  Created by Adrien Dulong on 08/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import ParseCrashReporting


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var startTimeSession:NSDate?
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        ParseCrashReporting.enable()
        
        
        //Dev
        Parse.setApplicationId("BA7FMG5LmMRx0RIPw3XdrOkR7FTnnSe4SIMRrnRG", clientKey: "DrWgjs7EII2Sm1tVYwJICkjoWGA23oW42JXcI3BF")
        Mixpanel.sharedInstanceWithToken(Utils().mixpanelDev)
        
        //PROD
        //Parse.setApplicationId("Yw204Svyg7sXIwvWdAZ9EmOOglqxpqk71ICpHDY9", clientKey: "EPCJfqJIWtsTzARaPE4GvFsWHzfST8atBw3NCuxj")
        //Mixpanel.sharedInstanceWithToken(Utils().mixpanelProd)
        
        
        Fabric.with([Crashlytics()])

       
        Mixpanel.sharedInstance().identify(Mixpanel.sharedInstance().distinctId)
        
        
        if PFUser.currentUser() == nil {
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            var phoneViewController:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("loginNav") as UINavigationController
            //self.window?.makeKeyAndVisible()
            self.window!.rootViewController = phoneViewController
        
        }
        else{
            PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                if error != nil {
                    
                }
                else{
                    var userFriends:Array<String>? = user["usersFriend"] as? Array<String>
                    
                    if userFriends != nil {
                        Mixpanel.sharedInstance().people.set(["Nb Friends" : userFriends!.count])
                        Mixpanel.sharedInstance().people.set(["Username" : PFUser.currentUser().username])
                    }
                    
                }
            })
        }
        
        

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        Mixpanel.sharedInstance().track("Session")
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        
        var currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            currentInstallation.saveEventually()
        }
        
        //track open app
        FBAppEvents.activateApp()
        Mixpanel.sharedInstance().timeEvent("Session")
        Mixpanel.sharedInstance().people.set(["Last App Open" : NSDate()])
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if PFUser.currentUser() != nil {
            //var navController:UINavigationController = window!.rootViewController as UINavigationController
            //var rootController:MainViewController = navController.viewControllers[0] as MainViewController
            //rootController.updatePikis()
            
            
            PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                if error != nil {
                    
                }
                else{
                    let usersFriend = PFUser.currentUser()["usersFriend"] as Array<String>
                    
                    
                    var userFriends:Array<String>? = user["usersFriend"] as? Array<String>
                    
                    if userFriends != nil {
                        Mixpanel.sharedInstance().people.set(["Nb Friends" : userFriends!.count])
                        Mixpanel.sharedInstance().people.set(["Username" : PFUser.currentUser().username])
                    }
                    
                }
            })
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        
        if PFUser.currentUser() != nil {
            currentInstallation["notificationsEnabled"] = true
            currentInstallation["user"] = PFUser.currentUser()
        }
        
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    
    //Get notification
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        
        let type:NSString = userInfo["type"] as NSString
        
        
        switch application.applicationState{
        case UIApplicationState.Active:
            println("Active")
        case UIApplicationState.Background:
            println("Background")
        case UIApplicationState.Inactive:
            println("Inactive")
        }
        
        println("Application State : \(application.applicationState)")
        
        if application.applicationState == UIApplicationState.Background{
            switch type {
                
            case "newReact":
                let pikiId: NSString? = userInfo["pikiId"] as? NSString
                
                if pikiId != nil{
                    var pikiObject:PFObject = PFObject(withoutDataWithClassName: "Piki", objectId: pikiId!)
                    
                    var queryPiki:PFQuery = PFQuery(className: "Piki")
                    queryPiki.whereKey("objectId", equalTo: pikiId)
                    queryPiki.includeKey("user")
                    
                    queryPiki.getFirstObjectInBackgroundWithBlock({ (pikiObject, error) -> Void in
                        if error != nil {
                            completionHandler(UIBackgroundFetchResult.Failed)
                        }
                        else{
                            let photoFile:PFFile = pikiObject["photo"] as PFFile
                            photoFile.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                                if error != nil {
                                    completionHandler(UIBackgroundFetchResult.Failed)
                                }
                                else{
                                    
                                    //var navController:UINavigationController = self.window!.rootViewController as UINavigationController
                                    //var rootController:MainViewController = navController.viewControllers[0] as MainViewController
                                    //rootController.goToPiki(pikiObject)
                                    completionHandler(UIBackgroundFetchResult.NewData)
                                }
                            })
                        }
                    })
                }
                
            case "newPiki":
                let pikiId: NSString? = userInfo["pikiId"] as? NSString
                
                if pikiId != nil{
                    var pikiObject:PFObject = PFObject(withoutDataWithClassName: "Piki", objectId: pikiId!)
                    
                    var queryPiki:PFQuery = PFQuery(className: "Piki")
                    queryPiki.whereKey("objectId", equalTo: pikiId)
                    queryPiki.includeKey("user")
                    
                    queryPiki.getFirstObjectInBackgroundWithBlock({ (pikiObject, error) -> Void in
                        if error != nil {
                            completionHandler(UIBackgroundFetchResult.Failed)
                        }
                        else{
                            let photoFile:PFFile = pikiObject["photo"] as PFFile
                            photoFile.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                                if error != nil {
                                    completionHandler(UIBackgroundFetchResult.Failed)
                                }
                                else{
                                    
                                    //var navController:UINavigationController = self.window!.rootViewController as UINavigationController
                                    //var rootController:MainViewController = navController.viewControllers[0] as MainViewController
                                    //rootController.goToPiki(pikiObject)
                                    
                                    completionHandler(UIBackgroundFetchResult.NewData)
                                }
                            })
                        }
                    })
                }
                
                
            default:
                println("wrong type")
                
            }
        }
        else{
            completionHandler(UIBackgroundFetchResult.NoData)
        }

        
        

    }
    

}


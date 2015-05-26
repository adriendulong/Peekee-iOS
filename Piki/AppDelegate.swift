
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FBSDKMessengerURLHandlerDelegate {

    var window: UIWindow?
    var startTimeSession:NSDate?
    var _messengerUrlHandler:FBSDKMessengerURLHandler?
    var _replyMessengerContext:FBSDKMessengerContext?
    var friendsIdList:Array<String> = Array<String>()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        #if DEBUG
            let AppID = "BA7FMG5LmMRx0RIPw3XdrOkR7FTnnSe4SIMRrnRG"
            let ClientKey = "DrWgjs7EII2Sm1tVYwJICkjoWGA23oW42JXcI3BF"
            let mixpanelKey = "8ed35339994dd90dec6bda7d83c3d3eb"
             println("\n\n\n\n\n\n DEV \n\n\n\n\n")
        #else
            let AppID = "Yw204Svyg7sXIwvWdAZ9EmOOglqxpqk71ICpHDY9"
            let ClientKey = "EPCJfqJIWtsTzARaPE4GvFsWHzfST8atBw3NCuxj"
            let mixpanelKey = "bdde62cd933f58205b7cb98da8a2bca8"
            println("\n\n\n\n\n\n PROD \n\n\n\n\n")
        #endif
        
       
        User.registerSubclass()
        
        Parse.setApplicationId(AppID, clientKey: ClientKey)
        Mixpanel.sharedInstanceWithToken(mixpanelKey)
        
        Fabric.with([Crashlytics()])
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)


        //AppsFlyer
        AppsFlyerTracker.sharedTracker().appsFlyerDevKey = "yDYHfJU4mxGatiELBhyx83"
        AppsFlyerTracker.sharedTracker().appleAppID = "959354291"


        //See if present mandatory screen add friends
        getIfFriendsMandatory()

        
        if let user = PFUser.currentUser() {
            if user["userInfos"] == nil {
                PFUser.logOut()
                var storyboard = UIStoryboard(name: "Subscribe", bundle: nil)
                if let phoneNavController = storyboard.instantiateInitialViewController() as? UINavigationController {
                    self.window!.rootViewController = phoneNavController
                }
            } else {
                let vc = InboxViewController()
                vc.view.backgroundColor = UIColor.whiteColor()
                
                let root = InboxNavigationController()
                root.view.frame = self.window!.frame
                
                root.viewControllers = [vc]
                self.window?.rootViewController = root
            }
        } else {
            Mixpanel.sharedInstance().identify(Mixpanel.sharedInstance().distinctId)
            
            var storyboard = UIStoryboard(name: "Subscribe", bundle: nil)
            if let phoneNavController = storyboard.instantiateInitialViewController() as? UINavigationController {
                self.window!.rootViewController = phoneNavController
            }

        }
        
        _messengerUrlHandler = FBSDKMessengerURLHandler()
        _messengerUrlHandler!.delegate = self

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        Mixpanel.sharedInstance().track("Session")

        Utils().removeAllComeFromMessenger()
        _replyMessengerContext = nil

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {

        AppsFlyerTracker.sharedTracker().trackAppLaunch()

        var currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0) {
            var bundleVersion:String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
            if let version = bundleVersion{
                currentInstallation["applicationVersion"] = version
            }

            currentInstallation.badge = 0;
            currentInstallation.saveEventually()
        }

        //track open app
        FBSDKAppEvents.activateApp()
        Mixpanel.sharedInstance().timeEvent("Session")
        Mixpanel.sharedInstance().people.set(["Last App Open" : NSDate()])
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var currentInstallation:PFInstallation = PFInstallation.currentInstallation()

        if PFUser.currentUser() != nil {
            currentInstallation["notificationsEnabled"] = true
            currentInstallation["user"] = PFUser.currentUser()
            currentInstallation.setDeviceTokenFromData(deviceToken)
            currentInstallation.saveInBackground()
        }
        else{
            println("Waiting list subscription")
        }
    }


    //Get notification
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {


        let type:NSString? = userInfo["type"] as? NSString


        if type != nil{


            if (application.applicationState == UIApplicationState.Background || application.applicationState == UIApplicationState.Inactive){
                switch type! {

                case "newReact", "newPiki":
                    let pikiId: NSString? = userInfo["pikiId"] as? NSString

                    if pikiId != nil{
                        var pikiObject:PFObject = PFObject(withoutDataWithClassName: "Piki", objectId: pikiId! as String)

                        var queryPiki:PFQuery = PFQuery(className: "Piki")
                        queryPiki.whereKey("objectId", equalTo: pikiId!)
                        queryPiki.includeKey("user")

                        queryPiki.getFirstObjectInBackgroundWithBlock({ (piki, error) -> Void in
                            if error != nil {
                                completionHandler(UIBackgroundFetchResult.Failed)
                            }
                            else{
                                
                                
                                if let navController = self.window!.rootViewController as? UINavigationController,
                                    let rootController = navController.viewControllers[0] as? InboxViewController,
                                    let pleek = piki as? Pleek {
                                        
                                    rootController.showPleek(pleek)
                                }

                                
                                NSNotificationCenter.defaultCenter().postNotificationName("reloadPikis", object: nil)
                                completionHandler(UIBackgroundFetchResult.NewData)
                            }
                        })


                    }

                default:
                    completionHandler(UIBackgroundFetchResult.NoData)

                }
            }
            else{
                completionHandler(UIBackgroundFetchResult.NoData)
            }
        }

    }



    func getIfFriendsMandatory(){

        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("mandatoryFriends") == nil{

            PFCloud.callFunctionInBackground("inviteFriendsParams",
                withParameters: ["Test" : "Test"],
                block: { (result, error ) -> Void in
                    println("Result : \(result)")
                    if error == nil {
                        var resultDict : [String:AnyObject] = result as! [String:AnyObject]
                        var invitFriends:Bool = resultDict["forceFriends"] as! Bool
                        var limitFriends:Int = resultDict["numberToAdd"] as! Int

                        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(invitFriends, forKey: "mandatoryFriends")
                        defaults.setObject(limitFriends, forKey: "numberToAdd")
                    }
                    else{
                        println("Error : \(error!.localizedDescription)")
                    }

            })

        }
    }


}

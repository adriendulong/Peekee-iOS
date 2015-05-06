//
//  Pleek.swift
//  Peekee
//
//  Created by Kevin CATHALY on 05/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

protocol ReactManagerDelegate {
    func quitCameraMenu()
    func addPhotoToCollectionView(modifyImage: UIImage, randomNumber: Int)
    func addVideoToCollectionView(photo: UIImage, path: String, randomNumber: Int)
    func modifyImageWithTextAndMeme(modifyImage: UIImage) -> (UIImage?, String?)
    func updateMainCellPleek()
    func setNewReacts(react: AnyObject, randomNumber: Int) -> Int?
}

class PleekManager {
    
    var delegate: ReactManagerDelegate?
    var isPublicPleek: Bool = false
    var mainPleek: PFObject?
    //MARK: PARSE UPLOAD PHOTO
    func uploadNewReact(imageData:NSData){
        
        var typeReact: String = "Photo"
        
        Mixpanel.sharedInstance().timeEvent("Send React")
        
        var bgTaskIdentifierUploadReact:UIBackgroundTaskIdentifier?
        var squareImage: UIImage = Utils().resizeSquareImage(Utils().cropMiddle(UIImage(data: imageData)!), size: CGSize(width: 200, height: 200))
        var modifyImage: UIImage = squareImage
        
        let randomNumber = self.randomNumber()
        
        if let delegate = self.delegate {
            var result = delegate.modifyImageWithTextAndMeme(modifyImage)
            if let im = result.0, let text = result.1 {
                modifyImage = im
                typeReact = text
            }
            
            delegate.quitCameraMenu()
            
            delegate.addPhotoToCollectionView(modifyImage, randomNumber: randomNumber)
        }

        //Upload the image
        var imageFile = self.uploadImage(modifyImage)

        //Save the react

        if let mainPleek = self.mainPleek {
            
            var newReact:PFObject = PFObject(className: "React")
            newReact["photo"] = imageFile
            newReact["Piki"] = mainPleek
            newReact["user"] = PFUser.currentUser()
            
            //Set the ACL
            var reactACL:PFACL = PFACL()
            if self.isPublicPleek{
                reactACL.setPublicReadAccess(true)
            }
            else{
                if mainPleek["recipients"] != nil{
                    for userId in mainPleek["recipients"] as! Array<String>{
                        reactACL.setReadAccess(true, forUserId: userId)
                    }
                }
                
            }
            reactACL.setWriteAccess(true, forUser: PFUser.currentUser()!)
            if let user: PFUser = mainPleek["user"] as? PFUser{
                reactACL.setWriteAccess(true, forUser: user)
            }
            newReact.ACL = reactACL
            
            
            //Start a background task
            bgTaskIdentifierUploadReact = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
            })
            
            
            newReact.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError?) -> Void in
                if succeeded{
                    Mixpanel.sharedInstance().people.increment(["React Sent" : 1, "React Photo Sent" : 1])
                    FBSDKAppEvents.logEvent("Send React", parameters: ["React Type" : typeReact])
                    Mixpanel.sharedInstance().track("Send React", properties: ["React Type" : typeReact])
                    
                    var peekeeInfosPosition:Int? = nil
                    
                    if let delegate = self.delegate {
                        peekeeInfosPosition = delegate.setNewReacts(newReact, randomNumber: randomNumber)
                    }
                    
                    if let pleekPosition = peekeeInfosPosition {
                        
                        
                        //Push notif
                        self.sendPushNewComment(self.isPublicPleek).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                            bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                            
                            Utils().setPikiAsView(mainPleek)
                            return nil
                        })
                        
                        mainPleek.fetchInBackgroundWithBlock({ (newPiki, error) -> Void in
                            if error == nil{
                                if let delegate = self.delegate {
                                    delegate.updateMainCellPleek()
                                }
                            }
                        })
                    }
                    else{
                        println("delete")
                        newReact.deleteEventually()
                        
                        UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                        bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                    }
                }
                else{
                    println("Error while creating new react")
                    UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                    bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                }
            })
        }
    }
    
    
    //MARK: PARSE UPLOAD VIDEO
    
    func uploadNewVideoReact(videoPath: NSString){
        
        Mixpanel.sharedInstance().timeEvent("Send React")
        
        var bgTaskIdentifierUploadReact:UIBackgroundTaskIdentifier?
        
        let screenImage:UIImage = Utils().getImageFrameFromVideoBeginning(NSURL(fileURLWithPath: videoPath as String)!)
        var imageData:NSData = UIImageJPEGRepresentation(screenImage, 0.8)

        let randomNumber = self.randomNumber()

        if let delegate = self.delegate {
            delegate.quitCameraMenu()
            delegate.addVideoToCollectionView(screenImage, path: videoPath as String, randomNumber: randomNumber)
        }
        
        var imageFile = PFFile(name: "video.mp4", contentsAtPath: NSURL(fileURLWithPath: videoPath as String)!.path!)

        //Start a background task
        bgTaskIdentifierUploadReact = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
            bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
        })

        let previewFile: PFFile = PFFile(name: "photo.jpg", data: imageData)
        previewFile.saveInBackgroundWithBlock({ (succeeded : Bool, error) -> Void in
            
            }, progressBlock: { (progress : Int32) -> Void in
                println("Preview : \(progress)")
        })
      
        //Build React
        var newVideoReact:PFObject = PFObject(className: "React")
        imageFile.saveInBackgroundWithBlock({ (succeeded:Bool, error) -> Void in
            if succeeded{
                //self.pikiReacts.insert(newVideoReact, atIndex: 0)
                //self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0)])
            }
            
            }, progressBlock: { (progress:Int32) -> Void in
                println(progress)
        })

        newVideoReact["video"] = imageFile
        newVideoReact["previewImage"] = previewFile
        newVideoReact["Piki"] = self.mainPleek

        if PFUser.currentUser() != nil{
            newVideoReact["user"] = PFUser.currentUser()
            var reactACL:PFACL = PFACL()
            
            if self.isPublicPleek {
                reactACL.setPublicReadAccess(true)
            }
            else {
                if self.mainPleek!["recipients"] != nil{
                    for userId in self.mainPleek!["recipients"] as! Array<String>{
                        reactACL.setReadAccess(true, forUserId: userId)
                    }
                }
            }

            reactACL.setWriteAccess(true, forUser: PFUser.currentUser()!)
            if self.mainPleek!["user"] != nil {
                reactACL.setWriteAccess(true, forUser: self.mainPleek!["user"] as! PFUser)
            }
            newVideoReact.ACL = reactACL
        }

        newVideoReact.saveInBackgroundWithBlock({ (success :Bool, error) -> Void in
            if success{
                Mixpanel.sharedInstance().people.increment(["React Sent" : 1, "React Video Sent" : 1])
                FBSDKAppEvents.logEvent("Send React", parameters: ["React Type" : "Video"])
                Mixpanel.sharedInstance().track("Send React", properties: ["React Type" : "Video"])
                
                var peekeeInfosPosition:Int? = nil
                
                if let delegate = self.delegate {
                    peekeeInfosPosition = delegate.setNewReacts(newVideoReact, randomNumber: randomNumber)
                }
                
                if peekeeInfosPosition != nil{
                    
                    //Push notif
                    self.sendPushNewComment(self.isPublicPleek).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                        UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                        bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                        
                        Utils().setPikiAsView(self.mainPleek!)
                        return nil
                    })
                    
                    self.mainPleek!.fetchInBackgroundWithBlock({ (newPiki, error) -> Void in
                        if let delegate = self.delegate {
                            delegate.updateMainCellPleek()
                        }
                    })
                }
                else{
                    println("delete")
                    newVideoReact.deleteEventually()
                    
                    UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                    bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                }
                
            }
            
        })
    }
    
    func uploadImage(image : UIImage) -> PFFile {
        
        var imageData:NSData = UIImageJPEGRepresentation(image, 0.5)
        var imageFile = PFFile(name: "photo.jpg", data: imageData)

        imageFile.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError?) -> Void in
            println(succeeded)
            }, progressBlock: { (progress:Int32) -> Void in
                println(progress)
        })
        
        return imageFile
    }
    
    // MARK: Random Number
    
    func randomNumber() -> Int{
        var random:Int = 0
        
        random = Int(arc4random_uniform(100000))
        
        return random
    }
    
    func sendPushNewComment(isPublic : Bool) -> BFTask{
        
        var task = BFTaskCompletionSource()
        
        let userPiki:PFUser = self.mainPleek!["user"] as! PFUser
        
        var recipients:Array<String> = Array<String>()
        if !self.isPublicPleek{
            recipients = self.mainPleek!["recipients"] as! Array<String>
        }
        
        PFCloud.callFunctionInBackground("sendPushNewComment", withParameters:["recipients":recipients, "isPublic" : isPublic, "pikiId" : self.mainPleek!.objectId!, "ownerId" : userPiki.objectId!]) {
            (result, error) -> Void in
            
            if error != nil{
                task.setError(error!)
            }
            else{
                task.setResult(result!)
            }
        }

        return task.task
    }
}
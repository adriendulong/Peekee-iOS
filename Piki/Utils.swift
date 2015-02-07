//
//  Utils.swift
//  Piki
//
//  Created by Adrien Dulong on 09/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import AVFoundation
import UIKit
import MediaPlayer


class Utils {
    
    //URL Share App
    let shareAppUrl = "http://peekeeapp.com/beta"
    let websiteUrl = "http://peekeeapp.com"
    
    //TOKEN TOOLS
    let mixpanelDev = "8ed35339994dd90dec6bda7d83c3d3eb"
    let mixpanelProd = "bdde62cd933f58205b7cb98da8a2bca8"
    
    let sizeVideo:CGFloat = 250
    
    
    let greyColor:UIColor = UIColor(red: 238/255, green: 233/255, blue: 239/255, alpha: 1.0)
    let darkColor:UIColor = UIColor(red: 35/255, green: 41/255, blue: 44/255, alpha: 1.0)
    let blueColor:UIColor = UIColor(red: 51/255, green: 194/255, blue: 200/255, alpha: 1.0)
    let darkBlueColor:UIColor = UIColor(red: 44/255, green: 133/255, blue: 138/255, alpha: 1.0)
    let redColor:UIColor = UIColor(red: 255/255, green: 100/255, blue: 93/255, alpha: 1.0)
    let darkHeaderSectionColor:UIColor = UIColor(red: 23/255, green: 28/255, blue: 30/255, alpha: 1.0)
    let black:UIColor = UIColor(red: 35/255, green: 41/255, blue: 44/255, alpha: 1.0)
    let cyanColor:UIColor = UIColor(red: 60/255, green: 241/255, blue: 196/255, alpha: 1.0)
    let purple:UIColor = UIColor(red: 53/255, green: 45/255, blue: 60/255, alpha: 1.0)
    let greySearch:UIColor = UIColor(red: 76/255, green: 79/255, blue: 83/255, alpha: 1.0)
    let blackSeparatorHeaderSearch = UIColor(red: 23/255, green: 28/255, blue: 30/255, alpha: 1.0)
    
    
    //V2 Design Color
    let primaryColor:UIColor = UIColor(red: 62/255, green: 80/255, blue: 180/255, alpha: 1.0)
    let primaryColorDark:UIColor = UIColor(red: 48/255, green: 63/255, blue: 159/255, alpha: 1.0)
    let secondColor:UIColor = UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0)
    let statusBarColor:UIColor = UIColor(red: 31/255, green: 41/255, blue: 103/255, alpha: 1.0)
    
    let customFontNormal = "ProximaNova-Light"
    let customFontSemiBold = "ProximaNova-Semibold"
    let customGothamBol = "GothamRounded-Bold"
    
    let customFont = "HansomFY-Regular"
    
    
    func cropPhoto(image : UIImage, yOrigin : CGFloat, screenWidth : CGFloat) -> UIImage{
        
        var ratio = image.size.width / screenWidth

        
        switch image.imageOrientation{
        case UIImageOrientation.Up:
            println("Up")
        case UIImageOrientation.Down:
            println("Down")
        case UIImageOrientation.Left:
            println("Left")
        case UIImageOrientation.Right:
            println("Right")
        case  UIImageOrientation.UpMirrored:
            println("Up Mirrored")
        case UIImageOrientation.DownMirrored:
            println("Down Mrrored")
        case UIImageOrientation.LeftMirrored:
            println("Left Mirrored")
        case UIImageOrientation.RightMirrored:
            println("Right Mirrored")
        }
        
        var cropSquare = CGRectMake(yOrigin * ratio, 0, image.size.width, image.size.width)

        
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef, scale: 1, orientation: image.imageOrientation)!
        
    }
    
    func degreesToRadian(degrees : Int) -> CGFloat {
        return CGFloat((Double(degrees) * M_PI) / 180.0)
    }
    
    func mergeVideoTracks(urls : [NSURL]) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        var mixComposition:AVMutableComposition = AVMutableComposition()
        var totalDuration:Float64 = 0
        
        for url in urls {
            
            var asset:AVURLAsset = AVURLAsset(URL: url, options: nil)

            var track:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
            let arr = asset.tracksWithMediaType(AVMediaTypeVideo)
            track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: arr[0] as AVAssetTrack, atTime: CMTimeMake(Int64(totalDuration), 1), error: nil)
            
            totalDuration += CMTimeGetSeconds(asset.duration)
            
        }
        
        var exportError : NSError? = nil
        var exportSession:AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        var exportURL:NSURL = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())finalOutput.mov")!
        exportSession.outputURL = exportURL
        exportSession.outputFileType = "com.apple.quicktime-movie"
        
        var pathError : NSError? = nil
        var fileManager:NSFileManager = NSFileManager()
        if fileManager.fileExistsAtPath("\(NSTemporaryDirectory())finalOutput.mov"){
            var errPath : NSError? = nil
            if !fileManager.removeItemAtPath("\(NSTemporaryDirectory())finalOutput.mov", error: &pathError){
                //Handle error
            }
        }
        
        
        exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
            switch exportSession.status{
                
            case AVAssetExportSessionStatus.Failed:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                println("Success Export")
                successful.setResult(exportURL)
                
            default:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
 
            }
        }
        
        
        
        return successful.task
    }
    
    
    func cropVideo(url : NSURL, captureDevice : AVCaptureDevice) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        var asset:AVURLAsset = AVURLAsset(URL: url, options: nil)
        var mixComposition:AVMutableComposition = AVMutableComposition()
        var track:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        var assetTrack:AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        println("Natural Size : \(assetTrack.naturalSize)")
        
        let duration:NSTimeInterval = CMTimeGetSeconds(asset.duration)
        var videoCompositionTrack = AVVideoComposition(propertiesOfAsset: asset)
        var frameDuration = CMTimeGetSeconds(videoCompositionTrack.frameDuration)
        
        
        //Test orientation
        var t:CGAffineTransform = asset.preferredTransform
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            println("portrait")
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            println("Upside Down")
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            println("Landscape Right")
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            println("Landscape Left")
        }
        
        var videoComposition:AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSizeMake(sizeVideo, sizeVideo)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        var instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        
        
        var transformer:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        var t1:CGAffineTransform = CGAffineTransformTranslate(asset.preferredTransform, 0, sizeVideo)
        var rotation = CGAffineTransformMakeRotation(self.degreesToRadian(90))
        //var t2:CGAffineTransform = CGAffineTransformRotate(t1, self.degreesToRadian(90))
        var t3:CGAffineTransform = CGAffineTransformTranslate(rotation, -40, -sizeVideo)
        var finalTransform:CGAffineTransform = CGAffineTransformScale(t3, 0.70, 0.70)
        
        
        var currentPosition:AVCaptureDevicePosition = captureDevice.position
        
        switch currentPosition{
            
        case AVCaptureDevicePosition.Front:
            t3 = CGAffineTransformTranslate(rotation, -40, 0)
            finalTransform = CGAffineTransformScale(t3, 0.70, -0.70)
            
        case AVCaptureDevicePosition.Back:
            t3 = CGAffineTransformTranslate(rotation, -40, -sizeVideo)
            finalTransform = CGAffineTransformScale(t3, 0.70, 0.70)
            
        default:
            t3 = CGAffineTransformTranslate(rotation, -40, -sizeVideo)
            finalTransform = CGAffineTransformScale(t3, 0.70, 0.70)
        }
        
        
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        var export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        export.videoComposition = videoComposition
        println("\(NSTemporaryDirectory())finalOutputCropped-\(NSDate().description).mov")
        export.outputURL = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())finalOutputCropped-\(NSDate().description).mp4")!
        export.outputFileType = AVFileTypeMPEG4
        
        export.exportAsynchronouslyWithCompletionHandler { () -> Void in
            
            switch export.status{
                
            case AVAssetExportSessionStatus.Failed:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                println("Success Export")
                successful.setResult(export.outputURL)
                
            default:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            }
        }
        
        
        return successful.task
        
    }
    
    
    func cropVideoPeekee(url : NSURL, captureDevice : AVCaptureDevice, sizePeekee : CGSize) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        var asset:AVURLAsset = AVURLAsset(URL: url, options: nil)
        var mixComposition:AVMutableComposition = AVMutableComposition()
        var track:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        var assetTrack:AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        
        
        var scale:CGFloat = sizePeekee.width / assetTrack.naturalSize.height
        
        
        let duration:NSTimeInterval = CMTimeGetSeconds(asset.duration)
        var videoCompositionTrack = AVVideoComposition(propertiesOfAsset: asset)
        var frameDuration = CMTimeGetSeconds(videoCompositionTrack.frameDuration)
        
        
        //Orientation
        var isPortrait = false
        var firstTransform = track.preferredTransform
        if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
            isPortrait = true;
        }

        
        var videoComposition:AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = sizePeekee
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        var instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        
        
        var transformer:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        var t1:CGAffineTransform = CGAffineTransformMakeTranslation(sizePeekee.width, 0)
        var t2:CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        //var t3:CGAffineTransform = CGAffineTransformScale(t2, scale, scale)
        var finalTransform:CGAffineTransform?
        
        var currentPosition:AVCaptureDevicePosition = captureDevice.position
        
        switch currentPosition{
            
        case AVCaptureDevicePosition.Front:
            
            var t3:CGAffineTransform = CGAffineTransformTranslate(t2, 0, sizePeekee.width)
            finalTransform = CGAffineTransformScale(t3, scale, -scale)
            
        case AVCaptureDevicePosition.Back:
            finalTransform = CGAffineTransformScale(t2, scale, scale)
            
        default:
            finalTransform = CGAffineTransformScale(t2, scale, scale)
        }

        
        
        transformer.setTransform(finalTransform!, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        var export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset960x540)
        export.videoComposition = videoComposition
        println("\(NSTemporaryDirectory())finalOutputCropped-\(NSDate().description).mov")
        export.outputURL = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())finalOutputCropped-\(NSDate().description).mp4")!
        export.outputFileType = AVFileTypeMPEG4
        
        export.exportAsynchronouslyWithCompletionHandler { () -> Void in
            
            switch export.status{
                
            case AVAssetExportSessionStatus.Failed:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                println("Success Export")
                successful.setResult(export.outputURL)
                
            default:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            }
        }
        
        
        return successful.task
        
    }
    
    
    // MARK: Text above video
    
    func applyTextOverVideo(videoURL : NSURL, textView:UITextView) -> BFTask{
        
        var successful = BFTaskCompletionSource()
        
        var asset:AVURLAsset = AVURLAsset(URL: videoURL, options: nil)
        var assetTrack:AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        var videoComposition:AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = assetTrack.naturalSize
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        var instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        var transformer:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
        transformer.setTransform(CGAffineTransformIdentity, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        
        
        println("Video Size : \(assetTrack.naturalSize.width)")
        println("Screen Width : \(UIScreen.mainScreen().bounds.width)")
        
        println("Text View size : \(textView.frame)")
        
        var scaleTextViewSize = assetTrack.naturalSize.width / UIScreen.mainScreen().bounds.width
        println("Scale : \(scaleTextViewSize)")
        
        var textLayer:CATextLayer = CATextLayer()
        textLayer.font = Utils().customFontSemiBold
        textLayer.fontSize = textView.font.pointSize * scaleTextViewSize
        textLayer.frame = CGRectMake(0, 100, textView.frame.width * scaleTextViewSize, textView.frame.height * scaleTextViewSize)
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.string = textView.text
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.backgroundColor = UIColor.orangeColor().CGColor
        textLayer.foregroundColor = UIColor.whiteColor().CGColor
        
        // 2 - The usual overlay
        var overlayLayer:CALayer = CALayer()
        overlayLayer.rasterizationScale = UIScreen.mainScreen().scale
        overlayLayer.frame = CGRectMake(0, 0, assetTrack.naturalSize.width, assetTrack.naturalSize.height)
        overlayLayer.masksToBounds = true
        overlayLayer.addSublayer(textLayer)
        overlayLayer.shouldRasterize = true
        
        var parentLayer = CALayer()
        var videoLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, assetTrack.naturalSize.width, assetTrack.naturalSize.height)
        videoLayer.frame = CGRectMake(0, 0, assetTrack.naturalSize.width, assetTrack.naturalSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)

        
        var export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        export.videoComposition = videoComposition
        println("\(NSTemporaryDirectory())finalOutputCropped-\(NSDate().description).mov")
        export.outputURL = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())finalOutputCropped-\(NSDate().description).mp4")!
        export.outputFileType = AVFileTypeMPEG4
        
        export.exportAsynchronouslyWithCompletionHandler { () -> Void in
            
            switch export.status{
                
            case AVAssetExportSessionStatus.Failed:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                println("Success Export")
                successful.setResult(export.outputURL)
                
            default:
                println("Export Failed")
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            }
        }
        
        
        return successful.task
        
    }
    
    
    func getImageFrameFromVideo(videoURL : NSURL) -> UIImage{
        
        var asset:AVURLAsset = AVURLAsset(URL: videoURL, options: nil)
        var generate1:AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        generate1.appliesPreferredTrackTransform = true
        
        var time:CMTime = CMTimeMake(1, 2)
        var oneRef:CGImageRef = generate1.copyCGImageAtTime(time, actualTime: nil, error: nil)
        var one:UIImage = UIImage(CGImage: oneRef)!
        
        return one
        
    }
    
    
    
    // MARK: FIRST USE
    
    func hasEverViewUnlockFriend() -> Bool{
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("hasUnlockFriends") != nil{
            return true
        }
        else{
            return false
        }
        
    }
    
    func viewUnlockFriend(){
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "hasUnlockFriends")

        
    }
    
    func deleteUnlockFriends(){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("hasUnlockFriends")
    }
    
    func hasEverViewInLoop() -> Bool{
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("hasViewInLoop") != nil{
            return true
        }
        else{
            return false
        }
        
    }
    
    func viewInLoop(){
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "hasViewInLoop")
        
        
    }
    
    /*
    * Manage View Of Piki
    */
    
    func setPikiAsView(piki : PFObject){
        
        var infosPiki:[String : AnyObject] = [String : String]()
        infosPiki["lastView"] = NSDate()
        if piki["nbReaction"] != nil{
            infosPiki["nbReaction"] = piki["nbReaction"]
        }
        
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(infosPiki, forKey: piki.objectId)
        
    }
    
    func hasEverViewThisPiki(piki : PFObject) -> Bool {
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(piki.objectId) != nil{
            return true
        }
        else{
            return false
        }
    }
    
    func getInfosLastPikiView(piki : PFObject) -> [String : AnyObject] {
        var infosPiki:[String : AnyObject] = [String : AnyObject]()
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(piki.objectId) != nil{
            infosPiki = defaults.objectForKey(piki.objectId) as [String : AnyObject]
            return infosPiki
        }
        else{
            return infosPiki
        }

    }
    
    
    /*
    * Utils Friends
    */
    
    
    func isUserAFriend(user : PFUser) -> Bool{
        
        if PFUser.currentUser() != nil {
            
            var arrayFriends:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
            if arrayFriends != nil{
                for friend in arrayFriends!{
                    
                    if friend == user.objectId{
                        return true
                    }
                    
                }
            }
            else{
                return false
            }
        }
        
        
        return false
    }
    
    
    func isUserMuted(user : PFUser) -> Bool{
        
        if PFUser.currentUser() != nil {
            
            var arrayMuted:Array<String>? = PFUser.currentUser()["usersIMuted"] as? Array<String>
            
            if arrayMuted != nil{
                for friend in arrayMuted!{
                    if friend == user.objectId{
                        return true
                    }
                    
                }
            }
            else{
                return false
            }
        }
        
        
        return false
    }
    
    
    /*
    * SERVER
    */
    
    
    func addFriend(userId : String) -> BFTask {
        var successful = BFTaskCompletionSource()
     
        
        PFCloud.callFunctionInBackground("addFriend", withParameters: ["friendId" : userId], block: { (friend, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                    if error != nil{
                        successful.setError(error)
                    }
                    else{
                        successful.setResult(friend)
                    }
                    
                    PFCloud.callFunctionInBackground("addToLastPublicPiki",
                        withParameters: ["friendId" : userId],
                        block: { (result, error) -> Void in
                            if error == nil{
                                NSNotificationCenter.defaultCenter().postNotificationName("reloadPikis", object: nil)
                            }
                    })
                })
               
            }
        })
        
        return successful.task
    }
    
    
    func removeFriend(userId : String) -> BFTask{
        var successful = BFTaskCompletionSource()
        
        PFCloud.callFunctionInBackground("removeFriend", withParameters: ["friendId" : userId], block: { (result, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                    if error != nil{
                        successful.setError(error)
                    }
                    else{
                        successful.setResult(user)
                    }
                })
            }
        })
        
        return successful.task
        
        
    }
    
    
    
    
    func muteFriend(userId : String) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        
        PFCloud.callFunctionInBackground("muteFriend", withParameters: ["friendId" : userId], block: { (friend, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                    if error != nil{
                        successful.setError(error)
                    }
                    else{
                        successful.setResult(friend)
                    }
                })
            }
        })
        
        return successful.task
    }
    
    
    func unMuteFriend(userId : String) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        
        PFCloud.callFunctionInBackground("unMuteFriend", withParameters: ["friendId" : userId], block: { (friend, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                    if error != nil{
                        successful.setError(error)
                    }
                    else{
                        successful.setResult(friend)
                    }
                })
            }
        })
        
        return successful.task
    }
    
    
    
    // META: String
    
    func containsStringForAll(string : String, insideString : String) -> Bool{
        
        let stringNS :NSString = NSString(string: string)
        let insideStringNS : NSString = NSString(string: insideString)
        
        let versionHeight:NSString = NSString(string: "8.0")
        let currentVersion:NSString = NSString(string: UIDevice.currentDevice().systemVersion)
        
        if currentVersion.compare(versionHeight, options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending{
            if stringNS.containsString(insideStringNS){
                return true
            }
            else{
                return false
            }
        }
        else{
            if stringNS.rangeOfString(insideString).length > 0{
                return true
            }
            else{
                return false
            }
        }
    }
    
    
    
    // META: Device Type
    
    func isIpad() -> Bool{
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
            return true
        }
        
        return false
    }
    
    func isIphone() -> Bool{
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            return true
        }
        
        return false
    }
    
    func isIphone4() -> Bool{
        
        if isIphone(){
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            
            let screenMaxLength = max(screenWidth, screenHeight)
            
            if screenMaxLength < 568.0{
                return true
            }
            
        }
        
        return false
    }
    
    func isIphone5() -> Bool{
        
        if isIphone(){
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            
            let screenMaxLength = max(screenWidth, screenHeight)
            
            if screenMaxLength == 568.0{
                return true
            }
            
        }
        
        return false
    }
    
    
    func isIphone6Plus() -> Bool{
        
        if isIphone(){
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            
            let screenMaxLength = max(screenWidth, screenHeight)
            
            if screenMaxLength == 736.0{
                return true
            }
            
        }
        
        return false
    
    }
    
    
    // MARK: Trat View To Image
    
    func imageWithView(view : UIView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    
    
    // MARK: Username
    
    func usernameValid(username : String) -> Bool{
        
        var valid:Bool = true
        var acceptedCharacters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890-_"
        
        var countUsernameLength:Int = countElements(username)
        
        for character in username{
            if !contains(acceptedCharacters, character){
                valid = false
            }
        }
        
     
        
        return valid
    }

}
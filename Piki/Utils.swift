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
import ImageIO
import MobileCoreServices

//
//enum PLColor {
//    case lightGrey: UIColor = UIColor(white: 250/255, alpha: 1.0)
//}

func LocalizedString(string: String) -> String {
    return NSLocalizedString(string, comment: string)
}

class Utils {
    
    //URL Share App
    let shareAppUrl = "http://pleekapp.com"
    let websiteUrl = "http://pleekapp.com"
    
    //TOKEN TOOLS
    let mixpanelDev = "8ed35339994dd90dec6bda7d83c3d3eb"
    let mixpanelProd = "bdde62cd933f58205b7cb98da8a2bca8"
    
    // FB Messenger
    let facebookMessengerActivated:Bool = true
    
    let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
    let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
    
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
    let lightBlue:UIColor = UIColor(red: 151/255, green: 159/255, blue: 213/255, alpha: 1.0)
    let greyNotSelected:UIColor = UIColor(red: 174/255, green: 181/255, blue: 191/255, alpha: 1.0)
    
    let darkGrey:UIColor = UIColor(red: 33/255, green: 35/255, blue: 37/255, alpha: 1.0)
    
    let customFontNormal = "ProximaNova-Light"
    let customFontSemiBold = "ProximaNova-Semibold"
    let customGothamBol = "GothamRounded-Bold"
    let montserratBold = "Montserrat-Bold"
    let montserratRegular = "Montserrat-Regular"
    
    let customFont = "HansomFY-Regular"
    
    //MARK: FONTS REPLIES
    
    let fontReplies:[String] = ["BanzaiBros", "Volte-Bold", "TrashHand", "Impact", "PlasticaPro", "TrendSansFour", "story", "BaronNeueBlack"]
    let fontColors:[UIColor] = [UIColor(red: 53/255, green: 226/255, blue: 126/255, alpha: 1.0), UIColor(red: 81/255, green: 255/255, blue: 252/255, alpha: 1.0), UIColor(red: 228/255, green: 69/255, blue: 92/255, alpha: 1.0),UIColor(red: 128/255, green: 251/255, blue: 69/255, alpha: 1.0), UIColor(red: 255/255, green: 251/255, blue: 78/255, alpha: 1.0), UIColor(red: 239/255, green: 83/255, blue: 53/255, alpha: 1.0), UIColor(red: 218/255, green: 91/255, blue: 242/255, alpha: 1.0), UIColor(red: 54/255, green: 92/255, blue: 246/255, alpha: 1.0)]
    let fontSizes:[CGFloat] = [30, 30, 36, 30 , 30, 30, 45, 36]
    
    
    func getFontsWithSize(size:CGFloat) -> Array<[String : AnyObject]>{

        
        /*for familyName in UIFont.familyNames() as! [String]{
            
            println("Family name : \(familyName)")
            
            for name in UIFont.fontNamesForFamilyName(familyName) as! [String]{
                println("Name : \(name)")
            }
            
        }*/
        
        var arrayFont:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
        
        for (index, value) in enumerate(fontReplies){
            
            if let fontFound = UIFont(name: value as String, size: fontSizes[index]){

                var infosFontWhite = ["font" : fontFound, "color" : UIColor.whiteColor()]
                arrayFont.append(infosFontWhite)

                var infosFontColored = ["font" : fontFound, "color" : fontColors[index]]
                arrayFont.append(infosFontColored)
                
                
            }
            
        }
        
        return arrayFont
        
    }
    
    func getAppDelegate() -> AppDelegate{
        
        return (UIApplication.sharedApplication().delegate as! AppDelegate!)
        
    }
    
    func resizeSquareImage(image: UIImage, size:CGSize) -> UIImage{
        
        if size.width < image.size.width{
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
            image.drawInRect(CGRectMake(0, 0, size.width, size.height))
            var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return newImage
        }
        else{
            return image
        }
        
        
        
    }
    
    
    func cropPhoto(image : UIImage, yOrigin : CGFloat, screenWidth : CGFloat) -> UIImage{
        
        var ratio = image.size.width / screenWidth

        
        var cropSquare = CGRectMake(yOrigin * ratio, 0, image.size.width, image.size.width)

        
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef, scale: 1, orientation: image.imageOrientation)!
        
    }
    
    func cropTop(image : UIImage) -> UIImage{
        var cropSquare = CGRectMake(0, 0, image.size.width, image.size.width)
        
        
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef, scale: 1, orientation: image.imageOrientation)!
    }
    
    func cropMiddle(image : UIImage) -> UIImage{
        var cropSquare = CGRectMake((image.size.height - image.size.width)/2, 0, image.size.width, image.size.width)
        
        
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
            track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: arr[0] as! AVAssetTrack, atTime: CMTimeMake(Int64(totalDuration), 1), error: nil)
            
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
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                successful.setResult(exportURL)
                
            default:
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
        var assetTrack:AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        
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
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                successful.setResult(export.outputURL)
                
            default:
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
        var assetTrack:AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        
        
        
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
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                successful.setResult(export.outputURL)
                
            default:
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
        var assetTrack:AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        
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
                var exportAsyncError = NSError(domain: "export", code: 200, userInfo: [NSLocalizedDescriptionKey : "unable to export the video"])
                successful.setError(exportAsyncError)
                
            case AVAssetExportSessionStatus.Completed:
                successful.setResult(export.outputURL)
                
            default:
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
        
        var time:CMTime = CMTimeMakeWithSeconds(1, 600)
        var oneRef:CGImageRef = generate1.copyCGImageAtTime(time, actualTime: nil, error: nil)
        var one:UIImage = UIImage(CGImage: oneRef)!
        
        return one
        
    }
    
    func getImageFrameFromVideoBeginning(videoURL : NSURL) -> UIImage{
        
        var asset:AVURLAsset = AVURLAsset(URL: videoURL, options: nil)
        println("Size video : \((asset.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack).naturalSize)")
        var generate1:AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        generate1.appliesPreferredTrackTransform = true
        
        var time:CMTime = CMTimeMakeWithSeconds(0, 600)
        var oneRef:CGImageRef = generate1.copyCGImageAtTime(time, actualTime: nil, error: nil)
        var one:UIImage = UIImage(CGImage: oneRef)!
        
        println("ONE SIZE : \(one.size) and scale : \(one.scale)")
        
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
        defaults.setObject(infosPiki, forKey: piki.objectId!)
        
    }
    
    func hasEverViewThisPiki(piki : PFObject) -> Bool {
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(piki.objectId!) != nil{
            return true
        }
        else{
            return false
        }
    }
    
    func getInfosLastPikiView(piki : PFObject) -> [String : AnyObject] {
        var infosPiki:[String : AnyObject] = [String : AnyObject]()
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(piki.objectId!) != nil{
            infosPiki = defaults.objectForKey(piki.objectId!) as! [String : AnyObject]
            return infosPiki
        }
        else{
            return infosPiki
        }

    }
    
    
    /*
    * Utils Friends
    */
    
    
    
    
    
    func isUserMuted(user : User) -> Bool{
        
        if User.currentUser() != nil {
            
            var arrayMuted:Array<String>? = User.currentUser()!["usersIMuted"] as? Array<String>
            
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
    
    
    
    
    
    func muteFriend(userId : String) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        
        PFCloud.callFunctionInBackground("muteFriend", withParameters: ["friendId" : userId], block: { (friend, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                User.currentUser()!.fetchInBackgroundWithBlock({ (user, error) -> Void in
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
                User.currentUser()!.fetchInBackgroundWithBlock({ (user, error) -> Void in
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
        
        let stringNS :NSString = NSString(string: NSString(string: string).lowercaseString) 
        let insideStringNS : NSString = NSString(string: insideString)
        
        let versionHeight:String = "8.0"
        let currentVersion:NSString = NSString(string: UIDevice.currentDevice().systemVersion)
        
        if currentVersion.compare(versionHeight, options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending{
            if stringNS.containsString(insideStringNS as String){
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
        var acceptedCharacters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"
        
        var countUsernameLength:Int = count(username)
        
        for character in username{
            if !contains(acceptedCharacters, character){
                valid = false
            }
        }
        
     
        
        return valid
    }
    
    
    // MARK: GIF 
    
    func createGifInvit(username : String) -> NSURL{
        
        
        var kFrameCount:Int = 11


        var fileProperties:[String : [String : AnyObject]] = [kCGImagePropertyGIFDictionary as String : [kCGImagePropertyGIFLoopCount as String : 0]]
        
        
        var delay:Float = 0.5
        var frameProperties: [String : [String : AnyObject]] = [kCGImagePropertyGIFDictionary as String : [kCGImagePropertyGIFDelayTime as String : delay]]
        
        var documentsDirectoryURL = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)
        var fileURL = documentsDirectoryURL!.URLByAppendingPathComponent("\(username).gif")
        
        let path: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
        
        if NSFileManager.defaultManager().fileExistsAtPath("\(path)/\(username).gif") {
            return fileURL
        }

        var destination:CGImageDestinationRef = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, kFrameCount, nil)
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        
        for i in 0...(kFrameCount - 1){

            if iOS8{
                var viewToAdd = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
                
                
                switch i{
                    
                    //Parrot Pink
                case 0:
                    viewToAdd.backgroundColor = Utils().secondColor
                    
                    var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height - 40))
                    imageView.image = UIImage(named: "parrot_blue")
                    imageView.contentMode = UIViewContentMode.Center
                    viewToAdd.addSubview(imageView)
                    
                    var labelUsername:UILabel = UILabel(frame: CGRect(x: 0, y:  viewToAdd.frame.height - 60, width: viewToAdd.frame.width, height: 50))
                    labelUsername.text = "@\(username)"
                    labelUsername.font = UIFont(name: Utils().customGothamBol, size: 40)
                    labelUsername.textAlignment = NSTextAlignment.Center
                    labelUsername.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelUsername)
                    
                    //Parrot blue
                case 1:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height - 40))
                    imageView.image = UIImage(named: "parrot_pink")
                    imageView.contentMode = UIViewContentMode.Center
                    viewToAdd.addSubview(imageView)
                    
                    var labelUsername:UILabel = UILabel(frame: CGRect(x: 0, y:  viewToAdd.frame.height - 60, width: viewToAdd.frame.width, height: 50))
                    labelUsername.text = "@\(username)"
                    labelUsername.font = UIFont(name: Utils().customGothamBol, size: 40)
                    labelUsername.textAlignment = NSTextAlignment.Center
                    labelUsername.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelUsername)
                    
                    //Frist mozaic
                case 2:
                    
                    var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    imageView.image = UIImage(named: "mosaic_1")
                    viewToAdd.addSubview(imageView)
                    
                    //Second mozaic
                case 3:
                    
                    var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    imageView.image = UIImage(named: "mosaic_2")
                    viewToAdd.addSubview(imageView)
                    
                    //Third mozaic
                case 4:
                    
                    var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    imageView.image = UIImage(named: "mosaic_full")
                    viewToAdd.addSubview(imageView)
                    
                case 5:
                    
                    var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    imageView.image = UIImage(named: "mosaic_full")
                    viewToAdd.addSubview(imageView)
                    
                    //Screen Add
                case 6:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    labelAdd.text = "Add"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 80)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    //Screen Me
                case 7:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    labelAdd.text = "Me"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 80)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    //Screen On
                case 8:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    labelAdd.text = "On"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 80)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    //Screen On
                case 9:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2))
                    labelAdd.text = "Pleek"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 60)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    var imageViewRoundPerro = UIImageView(frame: CGRect(x: 0, y: viewToAdd.frame.width/2 + 5, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2 - 40))
                    imageViewRoundPerro.image = UIImage(named: "parrot_rounded")
                    imageViewRoundPerro.contentMode = UIViewContentMode.Center
                    viewToAdd.addSubview(imageViewRoundPerro)
                    
                case 10:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2))
                    labelAdd.text = "Pleek"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 60)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    var imageViewRoundPerro = UIImageView(frame: CGRect(x: 0, y: viewToAdd.frame.width/2 + 5, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2 - 40))
                    imageViewRoundPerro.image = UIImage(named: "parrot_rounded")
                    imageViewRoundPerro.contentMode = UIViewContentMode.Center
                    viewToAdd.addSubview(imageViewRoundPerro)
                    
                default:
                    viewToAdd.backgroundColor = Utils().secondColor
                    
                }
                
                UIGraphicsBeginImageContextWithOptions(viewToAdd.bounds.size, viewToAdd.opaque, 0.0);
                viewToAdd.layer.renderInContext(UIGraphicsGetCurrentContext())
                var img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                CGImageDestinationAddImage(destination, img.CGImage, frameProperties as CFDictionaryRef);
            }
            else{
                var viewToAdd = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
                
                switch i{
                    
                case 0:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    labelAdd.text = "Add"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 80)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    //Screen Me
                case 1:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    labelAdd.text = "Me"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 80)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    //Screen On
                case 2:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    labelAdd.text = "On"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 80)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    //Screen On
                case 3:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2))
                    labelAdd.text = "Pleek"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 60)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    var imageViewRoundPerro = UIImageView(frame: CGRect(x: 0, y: viewToAdd.frame.width/2 + 5, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2 - 40))
                    imageViewRoundPerro.image = UIImage(named: "parrot_rounded")
                    imageViewRoundPerro.contentMode = UIViewContentMode.Center
                    viewToAdd.addSubview(imageViewRoundPerro)
                    
                case 4:
                    viewToAdd.backgroundColor = Utils().primaryColor
                    
                    var labelAdd:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2))
                    labelAdd.text = "Pleek"
                    labelAdd.textAlignment = NSTextAlignment.Center
                    labelAdd.font = UIFont(name: Utils().customGothamBol, size: 60)
                    labelAdd.textColor = UIColor.whiteColor()
                    viewToAdd.addSubview(labelAdd)
                    
                    var imageViewRoundPerro = UIImageView(frame: CGRect(x: 0, y: viewToAdd.frame.width/2 + 5, width: viewToAdd.frame.width, height: viewToAdd.frame.height/2 - 40))
                    imageViewRoundPerro.image = UIImage(named: "parrot_rounded")
                    imageViewRoundPerro.contentMode = UIViewContentMode.Center
                    viewToAdd.addSubview(imageViewRoundPerro)
                    
                default:
                    viewToAdd.backgroundColor = Utils().secondColor
                    
                }
                
                UIGraphicsBeginImageContextWithOptions(viewToAdd.bounds.size, viewToAdd.opaque, 0.0);
                viewToAdd.layer.renderInContext(UIGraphicsGetCurrentContext())
                var img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                CGImageDestinationAddImage(destination, img.CGImage, frameProperties as CFDictionaryRef);
                
            } 
        }
        
        
        if (!CGImageDestinationFinalize(destination)) {
            println("failed to finalize image destination");
        }
        
        return fileURL
        
    }
    
    
    // MARK: Get Image Username to share
    
    func getShareUsernameImage() -> UIImage?{
        
        var imageToShare:UIImage?
        var username:String = User.currentUser()!.username!
        
        var viewToAdd = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        viewToAdd.backgroundColor = Utils().primaryColor
        
        var imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height - 40))
        imageView.image = UIImage(named: "parrot_pink")
        imageView.contentMode = UIViewContentMode.Center
        viewToAdd.addSubview(imageView)
        
        var labelUsername:UILabel = UILabel(frame: CGRect(x: 0, y:  viewToAdd.frame.height - 60, width: viewToAdd.frame.width, height: 50))
        labelUsername.text = "@\(username)"
        labelUsername.font = UIFont(name: Utils().customGothamBol, size: 40)
        labelUsername.textAlignment = NSTextAlignment.Center
        labelUsername.textColor = UIColor.whiteColor()
        viewToAdd.addSubview(labelUsername)
        
        UIGraphicsBeginImageContextWithOptions(viewToAdd.bounds.size, viewToAdd.opaque, 0.0);
        viewToAdd.layer.renderInContext(UIGraphicsGetCurrentContext())
        imageToShare = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageToShare
        
    }
    
    
    
    // MARK: Nb visit app
    
    func nbVisitAppIncrement(){

        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("nbVisitApp") != nil{
            var nbVisits:Int = defaults.objectForKey("nbVisitApp") as! Int
            
            var newNbVisits = nbVisits + 1
            defaults.setObject(newNbVisits, forKey: "nbVisitApp")
            
            var nbVisitTemp = defaults.objectForKey("nbVisitApp") as! Int
            println("Nb visits : \(nbVisitTemp)")
            
        }
        else{
            defaults.setObject(1, forKey: "nbVisitApp")
        }
        
    }
    
    func isMomentForRealName() -> Bool{
        
        var nbVisitForRealName:Int = 10
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("nbVisitApp") != nil{
            var nbVisits:Int = defaults.objectForKey("nbVisitApp") as! Int
            
            
            if nbVisits == nbVisitForRealName{
                return true
            }
            else{
                return false
            }
            
        }
        else{
            return false
        }
        
    }
    
    
    // MARK : Share MEssenger Facebook
    
    func shareFBMessenger(pathName: String, pleekId:String, context:FBSDKMessengerContext?){
        
        //println("Messanger capabilities : \(FBSDKMessengerSharer.messengerPlatformCapabilities())")
        
        if (FBSDKMessengerSharer.messengerPlatformCapabilities() != nil){
            
            println("Path Name : \(pathName) & pleekId : \(pleekId)")
            
            //var filePath : String = NSBundle.mainBundle().pathForResource(pathName, ofType: "gif")!
            var gifData:NSData = NSData(contentsOfFile: pathName)!
            
            
            FBSDKMessengerSharer.shareAnimatedGIF(gifData, withMetadata: pleekId, withContext: context)
            
        }
        else{
            // Not able to share
            println("Not able")
            
            var itunesLink:String = "itms://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8"
            UIApplication.sharedApplication().openURL(NSURL(string: itunesLink)!)
        }
        
        
    }

    
    func buildGifShareMessenger(imagePleek : UIImage, reactImage:UIImage, otherReact : Array<PFObject>?) -> BFTask{
        var successful = BFTaskCompletionSource()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var kFrameCount:Int = 20
            
            
            var fileProperties:[String : [String : AnyObject]] = [kCGImagePropertyGIFDictionary as String : [kCGImagePropertyGIFLoopCount as String : 0 as Int]]
            
            
            var delay:Float = 0.15
            var frameProperties: [String : [String : AnyObject]] = [kCGImagePropertyGIFDictionary  as String: [kCGImagePropertyGIFDelayTime as String : delay]]
            
            var documentsDirectoryURL = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true, error: nil)
            var fileURL:NSURL = documentsDirectoryURL!.URLByAppendingPathComponent("pleek_messenger.gif")
            
            var destination:CGImageDestinationRef = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, kFrameCount, nil)
            CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
            
            
            for i in 0...(kFrameCount - 1){
                var viewToAdd = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                
                
                
                switch i{
                    
                    // First State : React Image is 1/4 of the Pleek Image
                case 0, 14:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/4 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    reactImageView.image = reactImage
                    viewToAdd.addSubview(reactImageView)
                    
                    // Second State : React Image is  of the Pleek Image
                case 1, 13:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/8 * 5, y: viewToAdd.frame.height/8 * 5, width: viewToAdd.frame.width/8 * 3, height: viewToAdd.frame.height/8 * 3))
                    reactImageView.image = reactImage
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(reactImageView)
                    
                    // Second State : React Image is 1/2 of the Pleek Image
                case 2, 12:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/2, y: viewToAdd.frame.height/2, width: viewToAdd.frame.width/2, height: viewToAdd.frame.height/2))
                    reactImageView.image = reactImage
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(reactImageView)
                    
                case 3, 11:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/8 * 3, y: viewToAdd.frame.height/8 * 3, width: viewToAdd.frame.width/8 * 5, height: viewToAdd.frame.height/8 * 5))
                    reactImageView.image = reactImage
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(reactImageView)
                    
                    // Third State : React Image is 3/4 of the Pleek Image
                case 4, 10:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4, y: viewToAdd.frame.height/4, width: viewToAdd.frame.width/4 * 3, height: viewToAdd.frame.height/4 * 3))
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    reactImageView.image = reactImage
                    viewToAdd.addSubview(reactImageView)
                    
                case 5, 9:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/8, y: viewToAdd.frame.height/8, width: viewToAdd.frame.width/8 * 7, height: viewToAdd.frame.height/8 * 7))
                    reactImageView.image = reactImage
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(reactImageView)
                    
                    // Fourth State : React Image is same size than the Pleek Image
                case 6, 8:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    reactImageView.image = reactImage
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(reactImageView)
                    
                case 7:
                    // Pleek Image
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/2 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: -viewToAdd.frame.width/8, y: -viewToAdd.frame.height/8, width: viewToAdd.frame.width/8 * 9, height: viewToAdd.frame.height/8 * 9))
                    reactImageView.image = reactImage
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(reactImageView)
                    
                case 15, 19:
                    //Pleek image is now 3/4 of the view
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/4 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    reactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    reactImageView.image = reactImage
                    viewToAdd.addSubview(reactImageView)
                    
                    // 2 More react image
                    var secondLeftReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 2, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    secondLeftReactImageView.image = reactImage
                    secondLeftReactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(secondLeftReactImageView)
                    
                    var secondTopReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 2, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    secondTopReactImageView.image = reactImage
                    secondTopReactImageView.contentMode = UIViewContentMode.ScaleAspectFill
                    viewToAdd.addSubview(secondTopReactImageView)
                    
                case 16, 18:
                    //Pleek image is now 3/4 of the view
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/4 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    reactImageView.image = reactImage
                    viewToAdd.addSubview(reactImageView)
                    
                    // 2 More react image
                    var secondLeftReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 2, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    secondLeftReactImageView.image = reactImage
                    viewToAdd.addSubview(secondLeftReactImageView)
                    
                    var secondTopReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 2, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    secondTopReactImageView.image = reactImage
                    viewToAdd.addSubview(secondTopReactImageView)
                    
                    // 2 More react image
                    var thirdLeftReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    thirdLeftReactImageView.image = reactImage
                    viewToAdd.addSubview(thirdLeftReactImageView)
                    
                    var thirdTopReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    thirdTopReactImageView.image = reactImage
                    viewToAdd.addSubview(thirdTopReactImageView)
                    
                case 17:
                    //Pleek image is now 3/4 of the view
                    var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewToAdd.frame.width, height: viewToAdd.frame.height))
                    mainImageView.image = imagePleek
                    viewToAdd.addSubview(mainImageView)
                    
                    // React Image made 1/4 of the Pleek Image
                    var reactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    reactImageView.image = reactImage
                    viewToAdd.addSubview(reactImageView)
                    
                    // 2 More react image
                    var secondLeftReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 2, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    secondLeftReactImageView.image = reactImage
                    viewToAdd.addSubview(secondLeftReactImageView)
                    
                    var secondTopReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4 * 2, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    secondTopReactImageView.image = reactImage
                    viewToAdd.addSubview(secondTopReactImageView)
                    
                    // 2 More react image
                    var thirdLeftReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    thirdLeftReactImageView.image = reactImage
                    viewToAdd.addSubview(thirdLeftReactImageView)
                    
                    var thirdTopReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: viewToAdd.frame.height/4, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    thirdTopReactImageView.image = reactImage
                    viewToAdd.addSubview(thirdTopReactImageView)
                    
                    // 2 More react image
                    var fourthLeftReactImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: viewToAdd.frame.height/4 * 3, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    fourthLeftReactImageView.image = reactImage
                    viewToAdd.addSubview(fourthLeftReactImageView)
                    
                    var fourthTopReactImageView:UIImageView = UIImageView(frame: CGRect(x: viewToAdd.frame.width/4 * 3, y: 0, width: viewToAdd.frame.width/4, height: viewToAdd.frame.height/4))
                    fourthTopReactImageView.image = reactImage
                    viewToAdd.addSubview(fourthTopReactImageView)
                    
                    
                default:
                    println("default")
                    
                }
                
                
                UIGraphicsBeginImageContextWithOptions(viewToAdd.bounds.size, viewToAdd.opaque, 0.0);
                viewToAdd.layer.renderInContext(UIGraphicsGetCurrentContext())
                var img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                CGImageDestinationAddImage(destination, img.CGImage, frameProperties as CFDictionaryRef);
            }
            
            if (!CGImageDestinationFinalize(destination)) {
                println("failed to finalize image destination")
                successful.setError(NSError(domain: "Image Destination", code: 400, userInfo: ["description" : "Failed to finalize image destination"]))
            }
            else{
                successful.setResult(fileURL)
            }
        }
        
        
        
        
        return successful.task
        
    }
    
    
    func comeFromMessengerPleek(pleekId : String){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(pleekId, forKey: "comeFromMessenger")
    }
    
    func removeAllComeFromMessenger(){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("comeFromMessenger")
    }
    
    func isComingFromMessengerForThisPleek(pleek : PFObject) -> Bool{
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("comeFromMessenger") != nil{
            
            var pleekId:String = defaults.objectForKey("comeFromMessenger") as! String
            
            if pleekId == pleek.objectId{
                return true
            }
            
        }
        else{
            return false
        }
        
        return false
    }
    
    
    // MARK : Server Image
    
    func getImagePleekOrReact(pleek : PFObject) -> BFTask{
        var successful = BFTaskCompletionSource()
        
        var mainPleekImage:UIImage?
        
        var fileMainPleek:PFFile?
        
        if pleek["photo"] != nil{
            fileMainPleek = pleek["photo"] as? PFFile
            
            fileMainPleek!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error == nil{
                    println("Get Image without error")
                    mainPleekImage = UIImage(data: data!)
                    
                    successful.setResult(mainPleekImage!)
                    
                }
                else{
                    //Problem
                    println("error getting image")
                    successful.setError(error)
                }
                
            })
        }
        else{
            fileMainPleek = pleek["previewImage"] as? PFFile
            
            fileMainPleek!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if data != nil{
                     println("Get Image without error")
                    mainPleekImage = UIImage(data: data!)
                    
                    successful.setResult(mainPleekImage!)
                    
                }
                else{
                    //Problem
                    println("error getting image")
                    successful.setError(error)
                }
                
            })
        }
        
        return successful.task
    }
    
    
    
    //MARK : Build Pleek Id
    
    func buildPleekId() -> UIImage{
        
        var pleekIdImage:UIImage?
        
        
        var mainView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
        var backImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
        backImageView.image = UIImage(named: "pleek_id")
        mainView.addSubview(backImageView)
        
        var usernameLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 470, width: mainView.frame.width, height: 80))
        usernameLabel.text = "@\(User.currentUser()!.username!)"
        usernameLabel.font = UIFont(name: customGothamBol, size: 60)
        usernameLabel.textColor = UIColor.whiteColor()
        usernameLabel.textAlignment = NSTextAlignment.Center
        mainView.addSubview(usernameLabel)
        
        pleekIdImage = imageWithView(mainView)
        
        
        
        return pleekIdImage!
        
        
    }
    
    //MARK: USER
    
    func updateUser() -> BFTask{
        
        var updateUserCompletionTask = BFTaskCompletionSource()
        
        User.currentUser()!.fetchInBackgroundWithBlock { (user, error) -> Void in
            
            if error != nil{
                updateUserCompletionTask.setError(error!)
            }
            else{
                Mixpanel.sharedInstance().people.set(["Username" : User.currentUser()!.username!])

                //If need to be updated we make the request in order to have a cache now
                if Utils().friendsNeedsToBeUpdated(){
                    println("UPDATE FRIENDS")
                    
                    self.getFriends(false).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                        if task.error != nil{
                            updateUserCompletionTask.setError(task.error)
                        }
                        else{
                            self.updateLocalFriendsIdList(task.result as! Array<PFObject>)
                            self.friendsHaveBeenUpdated()
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadPikis", object: nil)
                            
                            Mixpanel.sharedInstance().people.set(["Nb Friends" : (task.result as! Array<PFObject>).count])
                            updateUserCompletionTask.setResult(user)
                        }
                        
                        return nil
                    })
                }
                else{
                    println("friends list ok")
                }
                
                updateUserCompletionTask.setResult(user)
            }
            
            
            
            
        }
        
        return updateUserCompletionTask.task
        
    }
    
    func updateLocalFriendsIdList(friendsObjects : Array<PFObject>){
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        appDelegate.friendsIdList.removeAll(keepCapacity: false)
        
        for friendObject in friendsObjects{
            appDelegate.friendsIdList.append(friendObject["friendId"] as! String)
        }
        
        
    }
    
    func addFriendIdInLocalList(friendId : String){
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        appDelegate.friendsIdList.append(friendId)
        
    }
    
    func removeFriendIdInLocalList(friendId : String){
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        var tempFriendIdList:Array<String> = Array<String>()
        
        for friendIdInList in appDelegate.friendsIdList{
            
            if friendIdInList != friendId{
                tempFriendIdList.append(friendIdInList)
            }
            
        }
        
        appDelegate.friendsIdList = tempFriendIdList
        
        
    }
    
    
    //MARK: FRIENDS
    func getListOfFriendIdFromJoinObjects(friendsObjects : Array<PFObject>) -> Array<String>{
        var friendsId:Array<String> = Array<String>()
        
        for friendObject in friendsObjects{
            friendsId.append(friendObject["friendId"] as! String)
        }

        return friendsId
    }
    
    func isUserAFriend(user : User) -> Bool{
        
        if contains(getAppDelegate().friendsIdList, user.objectId!){
            return true
        }
        
        
        return false
    }
    
    func addFriend(userId : String) -> BFTask {
        var successful = BFTaskCompletionSource()
        
        
        PFCloud.callFunctionInBackground("addFriendV2", withParameters: ["friendId" : userId], block: { (friend, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                //Update the user and reload pleek list
                self.addFriendIdInLocalList(userId)
                successful.setResult(friend)
                
            }
        })
        
        return successful.task
    }
    
    
    func removeFriend(userId : String) -> BFTask{
        var successful = BFTaskCompletionSource()
        
        PFCloud.callFunctionInBackground("removeFriendV2", withParameters: ["friendId" : userId], block: { (result, error) -> Void in
            if error != nil {
                successful.setError(error)
            }
            else{
                //Update the user and reload pleek list
                self.removeFriendIdInLocalList(userId)
                successful.setResult(result)
            }
        })
        
        return successful.task
        
        
    }
    
    func friendsNeedsToBeUpdated() -> Bool{
        
        //If we don't have the same number of friends that we should we update the user
        if let nbFriends = User.currentUser()!["nbFriends"] as? Int{
            if nbFriends != getAppDelegate().friendsIdList.count{
                return true
            }
        }
        else {
            return true
        }
        
        //If we have the same number but the date from the last modif is more recent, we update
        if let lastFriendsModif = User.currentUser()!["lastFriendsModification"] as? NSDate{
            var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if defaults.objectForKey("lastFriendsUpdate") != nil{
                
                var lastFriendsUpdate:NSDate = defaults.objectForKey("lastFriendsUpdate") as! NSDate
                var userFriendsUpdate:NSDate = lastFriendsModif
                
                if lastFriendsUpdate.compare(userFriendsUpdate) == NSComparisonResult.OrderedAscending{
                    return true
                }
                else{
                    return false
                }
                
            }
            else{
                return true
            }
        }
        else {
            return true
        }
        
        
        
    }
    
    func friendsHaveBeenUpdated(){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSDate(), forKey: "lastFriendsUpdate")
    }
    
    func addFriendTest(){
        var friendId:String = "xVZX7rMMZq"
        
        PFCloud.callFunctionInBackground("removeFriendV2", withParameters: ["friendId" : friendId]) { (result, error) -> Void in
            if error != nil{
                println("Error adding friend : \(error!.localizedDescription)")
            }
            else{
                println("Ok : \(result)")
            }
        }
    }
    
    func getRealFriends() -> Array<String>{
        
        
        var realFriends:Array<String> = Array<String>()
        
        var allFriends:Array<String>? = User.currentUser()!["usersFriend"] as? Array<String>
        var mutedFriends:Array<String>? = User.currentUser()!["usersIMuted"] as? Array<String>
        
        if mutedFriends != nil && allFriends != nil{
            realFriends = allFriends!.filter{!contains(mutedFriends!, $0)}
        }
        else if allFriends != nil{
            realFriends = allFriends!
        }
        
        
        return realFriends
        
    }
    
    func getFriends(withCache : Bool) -> BFTask {
        var friendsCompletionTask = BFTaskCompletionSource()
        var needToUpdateLocalFriendsList:Bool = false

        var queryFriends = PFQuery(className: "Friend")
        queryFriends.whereKey("user", equalTo: User.currentUser()!)
        queryFriends.limit = 500
        
        if withCache{
            if self.getAppDelegate().friendsIdList.count == 0{
                needToUpdateLocalFriendsList = true
            }
            
            if queryFriends.hasCachedResult(){
                queryFriends.cachePolicy = PFCachePolicy.CacheOnly
            }
            else{
                needToUpdateLocalFriendsList = true
                queryFriends.cachePolicy = PFCachePolicy.NetworkOnly
            }
            
            
        }
        else{
            needToUpdateLocalFriendsList = true
            queryFriends.cachePolicy = PFCachePolicy.NetworkOnly
        }
        
        queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
            
            if error != nil{
                friendsCompletionTask.setError(error!)
            }
            else{
                self.updateLocalFriendsIdList(friends as! [PFObject])
                friendsCompletionTask.setResult(friends)
            }
            
        }
        
        return friendsCompletionTask.task
        
        
    }
    
    func getListOfUserObjectFromJoinObject(joinFriendsObjects : Array<PFObject>) -> Array<User>{
        
        var friendsObjects:Array<User> = Array<User>()
        var friendsId:Array<String> = Array<String>()
        
        for joinFriendObject in joinFriendsObjects{
            
            friendsId.append(joinFriendObject["friendId"] as! String)
            
        }
        
        for friendId in friendsId{
            var friendObject:User = User(withoutDataWithObjectId: friendId)
            friendsObjects.append(friendObject)
        }
        
        return friendsObjects
        
    }
    
    
    //MARK: Hide a pleek
    
    func getHidesPleek() -> Array<String>{
        var pleeksHided:Array<String>? = User.currentUser()!["pleeksHided"] as? Array<String>
        
        if pleeksHided == nil{
            pleeksHided = Array<String>()
        }
        
        return pleeksHided!
    }
    
    func hidePleek(pleekId : String){
        
        var pleeksHided:Array<String>? = User.currentUser()!["pleeksHided"] as? Array<String>
        
        if pleeksHided == nil{
            pleeksHided = Array<String>()
        }

        
        pleeksHided!.append(pleekId)
        
        User.currentUser()!["pleeksHided"] = pleeksHided!
        
        User.currentUser()!.saveEventually()
        
    }
    
    
    //MARK : Format Number
    
    func formatNumber(number : Int) -> String{
        
        var formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        var formattedNumber:String = formatter.stringFromNumber(NSNumber(integer: number))!
        
        return formattedNumber
        
    }
    
    
    //MARK: LIKE REACT
    
    func likeReact(react : PFObject!, pleek : PFObject!, hasAlreadyLiked : Bool){

        if !hasAlreadyLiked{
            Mixpanel.sharedInstance().track("Like")
            
            var likeObject:PFObject = PFObject(className: "Like")
            var reactCopy:PFObject = PFObject(withoutDataWithClassName:"React", objectId: react.objectId)
            likeObject["react"] = reactCopy
            likeObject["piki"] = pleek
            likeObject["user"] = User.currentUser()
            
            var aclLike:PFACL = PFACL()
            aclLike.setPublicReadAccess(true)
            aclLike.setWriteAccess(true, forUser: User.currentUser()!)
            
            likeObject.ACL = aclLike
            
            likeObject.saveEventually { (done, error) -> Void in
                if error != nil{
                    println("Error saving like : \(error!.description)")
                }
            }
        }
        else{
            var likesQuery:PFQuery = PFQuery(className: "Like")
            likesQuery.whereKey("user", equalTo: User.currentUser()!)
            likesQuery.whereKey("piki", equalTo: pleek)
            likesQuery.whereKey("react", equalTo: react)
            
            likesQuery.findObjectsInBackgroundWithBlock { (likes, error) -> Void in
                if error == nil{
                    if likes != nil{
                        
                        PFObject.deleteAllInBackground(likes, block: nil)
                    }
                    
                }
            }
        }
     
        
        
    }
    
    
    // MARK: TUTO
    
    func justSeeVideoTuto(){
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "seenVideoTuto")
    }
    
    func hasSeenVideoTuto() -> Bool{
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("seenVideoTuto") != nil{
            
            return true
            
        }
        
        return false
        
    }
    
}
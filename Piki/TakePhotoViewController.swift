//
//  TakePhotoViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 19/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary
import MobileCoreServices

protocol TakePhotoProtocol {
    func newPiki()
}


class TakePhotoViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, PBJVisionDelegate{
    
    var delegate:TakePhotoProtocol? = nil
    var cameraView:UIView?
    var cameraTextView:UITextView?
    var topBarView:UIView?
    var bottomBarView:UIView?
    var loadingImageView:UIImageView?
    var quitButton:UIButton?
    var changeCameraSideButton:UIButton?
    var backToTakePhotoButton:UIButton?
    var saveImageButton:UIButton?
    var libraryButton:UIButton?
    var previewImageView:UIImageView?
    var takePhotoButton:UIImageView?
    var alreadyShow:Bool = false
    var imageToUpload:UIImage?
    var previewVideoUpload:UIImage?
    var urlVideoToUpload:NSURL?
    var finalImage:UIImage?
    var imageFile:PFFile?
    var previewFile:PFFile?
    var textViewHidden:UITextView?
    var isPhoto:Bool = true
    var progressBar:UIView!
    var timerReact:NSTimer?
    var isRecording:Bool = false
    
    var backKeyboardView:UIView?
    
    //Camera
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var audioCaptureDevice : AVCaptureDevice?
    var previewLayer :AVCaptureVideoPreviewLayer?
    var imageOutput : AVCaptureStillImageOutput?
    var videoOutput : AVCaptureMovieFileOutput?
    var captureDeviceInput:AVCaptureDeviceInput?
    var audioDeviceInput:AVCaptureDeviceInput?
    var isPressingRecordButton:Bool = false
    var isTakingPicture:Bool = true
    var noAuthCameraImageView:UIImageView!
    var tutorialView:UIView!
    var videoAsset:AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prefersStatusBarHidden()
        
        Mixpanel.sharedInstance().track("View Take Photo Screen")
        FBSDKAppEvents.logEvent("View Take Photo Screen")
        
        self.view.backgroundColor = Utils().darkColor
        loadingImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        //var tapGestureChangeCamera : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("changeCamera:"))
        cameraView = UIView(frame: self.view.bounds)
        //cameraView?.addGestureRecognizer(tapGestureChangeCamera)
        self.view.addSubview(cameraView!)
        
        
        self.previewImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
        self.previewImageView!.hidden = true
        self.previewImageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(self.previewImageView!)
        
        textViewHidden = UITextView(frame: CGRect(x: 0, y: -100, width: 50, height: 50))
        textViewHidden!.keyboardAppearance = UIKeyboardAppearance.Dark
        textViewHidden!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(textViewHidden!)
        
        var panGestureText:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("moveText:"))
        
        cameraTextView = UITextView(frame: CGRect(x: 0, y: -100, width: self.view.frame.size.width, height: 170))
        cameraTextView!.editable = true
        cameraTextView!.backgroundColor = UIColor.clearColor()
        cameraTextView!.textAlignment = NSTextAlignment.Center
        cameraTextView!.layer.shadowColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0, 0, 0, 0.5])
        cameraTextView!.layer.shadowOffset = CGSizeMake(0, 1)
        cameraTextView!.layer.shadowOpacity = 1.0
        cameraTextView!.layer.shadowRadius = 2
        cameraTextView!.font = UIFont(name: "BanzaiBros", size: 60.0)
        cameraTextView!.hidden = true
        cameraTextView!.delegate = self
        cameraTextView!.autocorrectionType = UITextAutocorrectionType.No
        cameraTextView!.textColor = UIColor.whiteColor()
        cameraTextView!.keyboardAppearance = UIKeyboardAppearance.Dark
        cameraTextView!.returnKeyType = UIReturnKeyType.Done
        cameraTextView!.tintColor = Utils().secondColor
        cameraTextView!.scrollEnabled = false
        cameraTextView!.addGestureRecognizer(panGestureText)
        self.view.addSubview(cameraTextView!)
        
        
        
        topBarView = UIView(frame: CGRect(x: 0, y: -40, width: self.view.frame.size.width, height: 40))
        topBarView!.backgroundColor = UIColor.blackColor()
        topBarView!.alpha = 0.9
        topBarView!.hidden = true
        self.view.addSubview(topBarView!)
        
        progressBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 6))
        progressBar.backgroundColor = UIColor(red: 236/255, green: 19/255, blue: 63/255, alpha: 1.0)
        self.view.addSubview(progressBar)
        progressBar.transform = CGAffineTransformMakeTranslation(-progressBar.frame.width, 0)
        
        
        //INIT CAMERA
        previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer!.frame = CGRect(x: 0, y: 0, width: cameraView!.frame.width, height: cameraView!.frame.width)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView!.layer.addSublayer(previewLayer)
        PBJVision.sharedInstance().presentationFrame = cameraView!.frame
        
        noAuthCameraImageView = UIImageView(frame: CGRect(origin: previewImageView!.frame.origin, size: previewImageView!.frame.size))
        noAuthCameraImageView.image = UIImage(named: "enable_camera_pleek")
        noAuthCameraImageView.hidden = true
        self.view.addSubview(noAuthCameraImageView)
        
        //Tutorial pop up
        tutorialView = UIView(frame: CGRect(x: self.view.frame.width/2 - 102, y: self.view.frame.width/2, width: 205, height: 40))
        tutorialView.backgroundColor = UIColor.clearColor()
        let backImageTutoriel:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tutorialView.frame.width, height: tutorialView.frame.height))
        backImageTutoriel.contentMode = UIViewContentMode.Center
        backImageTutoriel.image = UIImage(named: "tutorial_background_pleek")
        tutorialView!.addSubview(backImageTutoriel)
        let textTuto:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tutorialView!.frame.width, height: tutorialView!.frame.height - 5))
        textTuto.textAlignment = NSTextAlignment.Center
        textTuto.font = UIFont(name: Utils().montserratRegular, size: 11)
        let string:NSString = "TAP TO ENABLE YOUR CAMERA" as NSString
        let firstAttributes = [NSForegroundColorAttributeName: UIColor(red: 136/255, green: 146/255, blue: 159/255, alpha: 1.0)]
        let secondAttributes = [NSForegroundColorAttributeName: UIColor(red: 36/255, green: 35/255, blue: 35/255, alpha: 1.0)]
        var attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes(firstAttributes, range: string.rangeOfString("TAP TO"))
        attributedString.addAttributes(firstAttributes, range: string.rangeOfString("YOUR CAMERA"))
        attributedString.addAttributes(secondAttributes, range: string.rangeOfString("ENABLE"))
        textTuto.attributedText = attributedString
        tutorialView.addSubview(textTuto)
        tutorialView.alpha = 0.0
        self.view.addSubview(tutorialView!)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if urlVideoToUpload != nil{
            self.previewImageView!.hidden = false
            var player:AVPlayer = AVPlayer(URL: urlVideoToUpload)
            var playerLayer:AVPlayerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
            self.previewImageView!.layer.addSublayer(playerLayer)
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
            player.muted = false
            player.play()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        }
        
        cameraTextView!.becomeFirstResponder()
        prefersStatusBarHidden()
        setupCamera()
        
        /*
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        
        
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureSession.running{
            previewLayer?.frame = self.cameraView!.layer.frame
            self.cameraView!.layer.addSublayer(previewLayer)
        }
        else{
            beginSession(self.cameraView!)
        }*/
    }
    
    override func viewDidAppear(animated: Bool) {

        cameraTextView!.becomeFirstResponder()

    }
    

    
    func setupCamera(){
        
        
        
        var vision:PBJVision = PBJVision.sharedInstance()
        vision.delegate = self
        vision.cameraMode = PBJCameraMode.Video
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        if Utils().isIphone4(){
            vision.captureSessionPreset = AVCaptureSessionPresetMedium
        }
        else{
            vision.captureSessionPreset = AVCaptureSessionPresetiFrame960x540
        }
        
        vision.outputFormat = PBJOutputFormat.Square
        vision.maximumCaptureDuration = CMTimeMakeWithSeconds(12, 600)
        vision.videoRenderingEnabled = true
        
        
        if checkIfCanPresentCamera(){
            vision.startPreview()
        }
        else{
            noAuthCameraImageView.hidden = false
        }
        
        
    }
    
    
    //Keyboard Notifs
    func keyboardWillShow(notification : NSNotification){
        
        
        if !alreadyShow{
            alreadyShow = true
            let info:NSDictionary = notification.userInfo!
            let keyboardSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
            
            
            
            
            
            let animationDuration: NSTimeInterval = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                
                }) { (finished) -> Void in
                    let heightForTheRest = self.view.frame.size.height - keyboardSize.height
                    
                    var heightForTopBar:CGFloat = heightForTheRest - self.view.frame.size.width
                    
                    self.previewImageView!.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
                    
                    self.topBarView!.frame = CGRect(x: 0, y: self.view.frame.size.width, width: self.view.frame.size.width, height: heightForTopBar)
                    self.cameraTextView!.frame = CGRect(x   : 0, y: self.view.frame.size.width/2 - 35, width: self.view.frame.size.width, height: 170)
                    self.cameraTextView!.hidden = false
                    self.topBarView!.hidden = false
                    
                    
                    self.changeCameraSideButton = UIButton(frame: CGRect(x: 15, y: self.view.frame.size.width - 55, width: 40, height: 40))
                    self.changeCameraSideButton?.setImage(UIImage(named: "change_camera"), forState: UIControlState.Normal)
                    self.changeCameraSideButton!.addTarget(self, action: Selector("changeCamera:"), forControlEvents: UIControlEvents.TouchUpInside)
                    if !self.checkIfCanPresentCamera(){
                        self.changeCameraSideButton!.hidden = true
                        
                    }
                    self.view.addSubview(self.changeCameraSideButton!)
                    
                    
                    self.backToTakePhotoButton = UIButton(frame: CGRect(x: 15, y: self.view.frame.size.width - 55, width: 40, height: 40))
                    self.backToTakePhotoButton!.setImage(UIImage(named: "capture_small_icon"), forState: UIControlState.Normal)
                    self.backToTakePhotoButton!.addTarget(self, action: Selector("backToCameraMode:"), forControlEvents: UIControlEvents.TouchUpInside)
                    self.backToTakePhotoButton!.hidden = true
                    self.view.addSubview(self.backToTakePhotoButton!)
                    
                    
                    self.quitButton = UIButton(frame: CGRect(x: 15, y: 15, width: 30, height: 30))
                    self.quitButton!.setImage(UIImage(named: "quit_button"), forState: UIControlState.Normal)
                    self.quitButton!.addTarget(self, action: Selector("quit:"), forControlEvents: UIControlEvents.TouchUpInside)
                    self.view.addSubview(self.quitButton!)
                    
                    self.saveImageButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 50, y: self.view.frame.size.width - 50, width: 35, height: 35))
                    self.saveImageButton!.setImage(UIImage(named: "save_icon"), forState: UIControlState.Normal)
                    self.saveImageButton!.addTarget(self, action: Selector("saveImage:"), forControlEvents: UIControlEvents.TouchUpInside)
                    self.saveImageButton!.hidden = true
                    self.view.addSubview(self.saveImageButton!)
                    
                    self.libraryButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 50, y: self.view.frame.size.width - 55, width: 35, height: 35))
                    self.libraryButton!.setImage(UIImage(named: "library"), forState: UIControlState.Normal)
                    self.libraryButton!.addTarget(self, action: Selector("fromLibrary:"), forControlEvents: UIControlEvents.TouchUpInside)
                    self.libraryButton!.layer.borderWidth = 0.5
                    self.libraryButton!.layer.borderColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0).CGColor
                    if !self.checkIfCanPresentCamera(){
                        self.libraryButton!.hidden = true
                    }
                    self.view.addSubview(self.libraryButton!)
                    
                    self.backKeyboardView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - keyboardSize.height, width: self.view.frame.width, height: keyboardSize.height))
                    self.backKeyboardView!.backgroundColor = UIColor.blackColor()
                    self.backKeyboardView!.alpha = 0.9
                    self.view.addSubview(self.backKeyboardView!)
                    
                    var novideoLabel = UILabel(frame: CGRect(x: 25, y: 0, width: self.backKeyboardView!.frame.width - 50, height: self.backKeyboardView!.frame.height))
                    novideoLabel.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
                    novideoLabel.textColor = UIColor.whiteColor()
                    novideoLabel.numberOfLines = 2
                    novideoLabel.textAlignment = NSTextAlignment.Center
                    novideoLabel.text = "You can not add text on the video for the moment😪 Promise, it comes soon!"
                    self.backKeyboardView!.addSubview(novideoLabel)
                    
                    
                    self.accessLastLibPhoto()
                    
                    self.takePhotoButton = UIImageView(frame: CGRect(x: self.view.frame.size.width/2 - 35, y: self.view.frame.size.width - 75, width: 72, height: 75))
                    self.takePhotoButton!.image = UIImage(named: "capture_button")
                    self.takePhotoButton!.userInteractionEnabled = true
                    
                    var tapGestureTakePhoto  = UITapGestureRecognizer(target: self, action: Selector("takePhoto:"))
                    self.takePhotoButton!.addGestureRecognizer(tapGestureTakePhoto)
                    
                    var tapGestureRecordVideo = UILongPressGestureRecognizer(target: self, action: Selector("recordVideo:"))
                    self.takePhotoButton!.addGestureRecognizer(tapGestureRecordVideo)
                    
                    self.view.addSubview(self.takePhotoButton!)

                    if !self.checkIfCanPresentCamera(){
                        self.tutorialView.frame.origin = CGPoint(x: self.view.frame.width/2 - 102, y: self.takePhotoButton!.frame.origin.y - 60)
                        self.tutorialView.alpha = 1.0
                    }
                    
                    
                    if Utils().isIphone4(){
                        self.cameraTextView!.transform = CGAffineTransformMakeTranslation(0, -40)
                        self.changeCameraSideButton!.transform = CGAffineTransformMakeTranslation(0, -40)
                        self.backToTakePhotoButton!.transform = CGAffineTransformMakeTranslation(0, -40)
                        self.saveImageButton!.transform = CGAffineTransformMakeTranslation(0, -40)
                        self.libraryButton!.transform = CGAffineTransformMakeTranslation(0, -40)
                        self.takePhotoButton!.transform = CGAffineTransformMakeTranslation(0, -40)
                    }
                    
            }
        }
        
        
        
        
 
    }
    
    
    /*
    * Camera functions
    *
    */
    

    
    func quit(sender : UIButton){
        
        
        cameraTextView!.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        
        
    }
    
    func takePhoto(sender : UITapGestureRecognizer){
        
        if previewImageView!.hidden{
            //takePhoto()
            if checkIfCanPresentCamera(){
                isTakingPicture = true
                PBJVision.sharedInstance().startVideoCapture()
            }
            else{
                askPermissionCamera()
            }
            
        }
        else{
            newPiki()
        }
        
    }
    
    
    // MARK: Video
    
    func recordVideo(longGesture : UILongPressGestureRecognizer){
        
        if longGesture.state == UIGestureRecognizerState.Began{

            if previewImageView!.hidden{
                if checkIfCanPresentCamera(){
                    isPressingRecordButton = true
                    isTakingPicture = false
                    PBJVision.sharedInstance().startVideoCapture()
                    //self.cameraTextView!.resignFirstResponder()
                    //self.cameraTextView!.hidden = true
                }
                else{
                    askPermissionCamera()
                }
            }
            
            

            
            
        }
        else if longGesture.state == UIGestureRecognizerState.Ended {
            isPressingRecordButton = false
            
            
            if PBJVision.sharedInstance().recording{
                self.stopRecordingAnim()
                
                PBJVision.sharedInstance().endVideoCapture()
            }
            
            
        }
        
    }
    
    func visionDidStartVideoCapture(vision: PBJVision) {
        if !isTakingPicture{
            startRecordingAnim()
        }
        else{
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("endTakePicture"), userInfo: nil, repeats: false)
        }
        
    }
    
    func endTakePicture(){
        PBJVision.sharedInstance().endVideoCapture()
    }
    
    
    
    func visionDidEndVideoCapture(vision: PBJVision) {
        //PBJVision.sharedInstance().cameraMode = PBJCameraMode.Photo
    }
    
    func visionCameraModeDidChange(vision: PBJVision) {
        /*if vision.cameraMode == PBJCameraMode.Video{

            if isPressingRecordButton{

                if !PBJVision.sharedInstance().recording{
                    var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("startRecordVideo"), userInfo: nil, repeats: false)
                    
                }
            }
        }*/
        
    }
    
    func startRecordVideo(){
        PBJVision.sharedInstance().startVideoCapture()
    }
    
    func vision(vision: PBJVision, capturedVideo videoDict: [NSObject : AnyObject]?, error: NSError?) {
        
        isRecording = false
        
        
        
        if error != nil{
            
            //ALERT PROBLEM RECORDING VIDEO
            println("PROBLEM : \(error?.description)")
            
        }
        else{
            
            
            var videoPath:NSString? = videoDict![PBJVisionVideoPathKey] as? NSString
            
            
            if videoPath != nil{
                
                
                if isTakingPicture{
                    let screenImage:UIImage = Utils().getImageFrameFromVideoBeginning(NSURL(fileURLWithPath: videoPath as! String)!)
                    var croppedPhoto = Utils().resizeSquareImage(screenImage, size: CGSize(width: 400, height: 400))
                    
                    self.passInPreviewMode(croppedPhoto)
                    PBJVision.sharedInstance().startPreview()
                }
                else{
                    self.urlVideoToUpload = NSURL(fileURLWithPath: videoPath! as String)
                    
                    isTakingPicture = true
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.passInPreviewModeVideo(NSURL(fileURLWithPath: videoPath! as String)!)
                        
                    })
                }
                
                
                
            }
            
        }
        
    }
    

    
    func startRecordingAnim(){
        
        self.progressBar.hidden = false
        UIView.animateWithDuration(12,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                self.progressBar.transform = CGAffineTransformIdentity
        }) { (finished) -> Void in
            self.stopRecordingAnim()
        }
    }
    
    func stopRecordingAnim(){
        
        self.progressBar.hidden = true
        self.progressBar.layer.removeAllAnimations()
        
        
    }
    
    
    
    func videoDidEnd(notification : NSNotification){
        var player:AVPlayerItem = notification.object as! AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }
    
    
    func passInPreviewModeVideo(videoURL : NSURL){
        
        
        self.previewImageView!.hidden = false
        var player:AVPlayer = AVPlayer(URL: videoURL)
        var playerLayer:AVPlayerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
        self.previewImageView!.layer.addSublayer(playerLayer)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        player.muted = false
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
        self.cameraView!.hidden = true
        self.saveImageButton!.hidden = false
        self.takePhotoButton!.image = UIImage(named: "next_button")
        self.libraryButton!.hidden = true
        self.changeCameraSideButton!.hidden = true
        self.backToTakePhotoButton!.hidden = false
        cameraTextView!.returnKeyType = UIReturnKeyType.Send
        
    }
    
    func passInPreviewMode(image : UIImage){
        imageToUpload = image
        
        self.previewImageView!.image = image
        self.previewImageView!.hidden = false
        self.cameraView!.hidden = true
        
        self.saveImageButton!.hidden = false
        self.takePhotoButton!.image = UIImage(named: "next_button")
        self.libraryButton!.hidden = true
        self.changeCameraSideButton!.hidden = true
        self.backToTakePhotoButton!.hidden = false
        cameraTextView!.returnKeyType = UIReturnKeyType.Send
    }
    
    func fromLibrary(sender : UIButton){
        
        var imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage]
        
        self.presentViewController(imagePicker, animated: false) { () -> Void in
            
        }
    }
    
    /*
    * UIImagePickerController Delegate
    */
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var chosenImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
        var squareImage = RBSquareImageTo(chosenImage, CGSize(width: 800, height: 800))
        passInPreviewMode(squareImage)
        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    
    
    func uploadImage(image : UIImage){
        
        var imageData:NSData = UIImageJPEGRepresentation(image, 0.8)
        imageFile = PFFile(name: "photo.jpg", data: imageData)
        
        imageFile!.saveInBackgroundWithBlock({ (succeeded:Bool, error) -> Void in
            println(succeeded)
            
            }, progressBlock: { (progress:Int32) -> Void in
                println(progress)
        })
        
    }
    
    
    func newPiki(){
        textViewHidden!.becomeFirstResponder()
        
        self.imageFile = nil
        self.previewFile = nil
        
        if imageToUpload != nil{
            
            self.isPhoto = true
            
            //If Text, add it to the photo
            var imageLabel:UIImage?
            self.cameraTextView!.editable = false
            if (self.cameraTextView!.text as NSString).length > 0{
                UIGraphicsBeginImageContextWithOptions(cameraTextView!.frame.size, false, 0.0);
                self.cameraTextView!.layer.renderInContext(UIGraphicsGetCurrentContext())
                imageLabel = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
            
            var difPos:CGFloat = (imageToUpload!.size.width - self.view.frame.size.width)/2
            let scaleImage = imageToUpload!.scale
            
            UIGraphicsBeginImageContext(CGSize(width: imageToUpload!.size.width * scaleImage, height: imageToUpload!.size.height * scaleImage))
            imageToUpload!.drawInRect(CGRectMake(0, 0, imageToUpload!.size.width * scaleImage, imageToUpload!.size.height * scaleImage), blendMode: kCGBlendModeNormal, alpha: 1.0)
            if imageLabel != nil {
                imageLabel!.drawInRect(CGRectMake(difPos * scaleImage, (self.cameraTextView!.frame.origin.y + difPos) * scaleImage, imageLabel!.size.width * scaleImage, imageLabel!.size.height * scaleImage), blendMode: kCGBlendModeNormal, alpha: 1.0)
            }
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
            var imageData:NSData = UIImageJPEGRepresentation(finalImage!, 0.8)
            imageFile = PFFile(name: "photo.jpg", data: imageData)
            
            imageFile!.saveInBackgroundWithBlock({ (succeeded:Bool, error) -> Void in
                println(succeeded)
                
                }, progressBlock: { (progress:Int32) -> Void in
                    println(progress)
            })
            
            cameraTextView!.editable = true
            
            self.performSegueWithIdentifier("chooseRecipients", sender: self)
        }
        else if urlVideoToUpload != nil{
            
            if count(self.cameraTextView!.text) > 0{
                self.applyOverlay(self.urlVideoToUpload!.path!)
            }
            else{
                println("Upload video")
                self.isPhoto = false
                
                
                //Generate and upload preview image video
                self.finalImage = Utils().getImageFrameFromVideoBeginning(self.urlVideoToUpload!)
                var imageData:NSData = UIImageJPEGRepresentation(self.finalImage, 0.8)
                self.previewFile = PFFile(name: "photo.jpg", data: imageData)
                self.previewFile!.saveInBackgroundWithBlock({ (succeeded : Bool, error) -> Void in
                    
                    }, progressBlock: { (progress : Int32) -> Void in
                        println("Preview Progress: \(progress)")
                })
                
                
                //Upload video
                self.imageFile = PFFile(name: "video.mp4", contentsAtPath: self.urlVideoToUpload!.path!)
                self.imageFile!.saveInBackgroundWithBlock({ (succeedded, error) -> Void in
                    
                    }, progressBlock: { (progress : Int32) -> Void in
                        println("Video Progress : \(progress)")
                })
                
                self.performSegueWithIdentifier("chooseRecipients", sender: self)
            }
            
            
            
            
            
        }
        
        
        
        
        
        

    }
    
    func backToCameraMode(sender : UIButton){
        progressBar.transform = CGAffineTransformMakeTranslation(-progressBar.frame.width, 0)
        
        backToTakePhotoButton!.hidden = true
        changeCameraSideButton!.hidden = false
        
        self.imageToUpload = nil
        
        self.cameraTextView!.hidden = false
        self.cameraTextView!.becomeFirstResponder()
        
        self.saveImageButton!.hidden = true
        self.cameraView!.hidden = false
        self.previewImageView!.hidden = true
        self.previewImageView!.layer.sublayers = nil
        self.libraryButton!.hidden = false
        self.takePhotoButton!.image = UIImage(named: "capture_button")
        cameraTextView!.returnKeyType = UIReturnKeyType.Done
    }
    
    
    func changeCamera(sender : UIButton){
        
        var vision:PBJVision = PBJVision.sharedInstance()
        
        if vision.cameraDevice == PBJCameraDevice.Front{
            vision.cameraDevice = PBJCameraDevice.Back
        }
        else{
            vision.cameraDevice = PBJCameraDevice.Front
        }
        
    }
    
    
    func vision(vision: PBJVision, capturedPhoto photoDict: [NSObject : AnyObject]?, error: NSError?) {
        
        if error != nil{
            //Alert and return
            return
        }
        
        var photoData:NSData? = photoDict![PBJVisionPhotoJPEGKey] as? NSData
        
        if photoData != nil{
            
            var croppedPhoto = Utils().resizeSquareImage(Utils().cropMiddle(UIImage(data: photoData!)!), size: CGSize(width: 400, height: 400))
            
            self.passInPreviewMode(croppedPhoto)
            PBJVision.sharedInstance().startPreview()
            
        }
        else{
            //Alert and return
            return
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chooseRecipients"{
            
            self.previewImageView!.layer.sublayers = nil
            
            var nextController:ChooseReceiversViewController = segue.destinationViewController as! ChooseReceiversViewController
            nextController.filePiki = self.imageFile
            nextController.finalPhoto = self.finalImage
            nextController.filePreview = self.previewFile
            
            
        }
    }

    /*
    * TextView Delegate
    */
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //Return Button Take Piki or Send It
        if text == "\n"{
            if previewImageView!.hidden{
                //takePhoto()
                if checkIfCanPresentCamera(){
                    isTakingPicture = true
                    PBJVision.sharedInstance().startVideoCapture()
                }
                else{
                    askPermissionCamera()
                }
                
            }
            else{
                newPiki()
            }
            return false
        }
        
        
        
        
        var textEntered:NSString = textView.text as NSString
        textEntered = textEntered.stringByReplacingCharactersInRange(range, withString: text)
        
        
        if textEntered.length > (textView.text as NSString).length{
            if getNbLines(textView, string: textEntered) > 2{
                
                let maxDifFont = textView.font.pointSize - 25
                
                if maxDifFont > 0{
                    
                    for index in 1...Int(maxDifFont) {
                        
                        var fontSize = textView.font.pointSize
                        fontSize = fontSize - CGFloat(index)
                        
                        textView.font = UIFont(name: textView.font.fontName, size: fontSize)
                        
                        if getNbLines(textView, string: textEntered) < 3{
                            return true
                        }
                    }
                    
                    if getNbLines(textView, string: textEntered) > 2{
                        return false
                    }
                }
                else{
                    return false
                }
                
            }
        }
        else{
            let maxDifFont = 60 - textView.font.pointSize
            var previousFontSize:CGFloat = textView.font.pointSize
            
            if maxDifFont > 0{
                
                for index in 1...Int(maxDifFont) {
                    
                    var fontSize = textView.font.pointSize
                    fontSize = fontSize + CGFloat(index)
                    
                    textView.font = UIFont(name: textView.font.fontName, size: fontSize)
                    
                    if getNbLines(textView, string: textEntered) > 2{
                        textView.font = UIFont(name: textView.font.fontName, size: previousFontSize)
                        return true
                    }
                    
                    previousFontSize = textView.font.pointSize
                }
            }
        }
        
        
        
        return true
    }
    
    
    func getHeightTextView(textView : UITextView, string : NSString) -> CGFloat {
        var textEntered:NSString = string
        let textAttributes:[String:AnyObject] = [NSFontAttributeName: textView.font]
        
        var textWidth:CGFloat = CGRectGetWidth(UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset))
        textWidth = textWidth - 2.0 * textView.textContainer.lineFragmentPadding
        
        let boundingRect:CGRect = textEntered.boundingRectWithSize(CGSizeMake(textWidth, 0),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: textView.font],
            context: nil)
        
        let nbLines = CGRectGetHeight(boundingRect) / textView.font.lineHeight
        
        return CGRectGetHeight(boundingRect)
    }
    
    
    func getNbLines(textView : UITextView, string : NSString) -> CGFloat {
        var textEntered:NSString = string
        let textAttributes:[String:AnyObject] = [NSFontAttributeName: textView.font]
        
        var textWidth:CGFloat = CGRectGetWidth(UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset))
        textWidth = textWidth - 2.0 * textView.textContainer.lineFragmentPadding
        
        let boundingRect:CGRect = textEntered.boundingRectWithSize(CGSizeMake(textWidth, 0),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: textView.font],
            context: nil)
        
        let nbLines = CGRectGetHeight(boundingRect) / textView.font.lineHeight
        
        return nbLines
    }
    
    
    func moveText(recognizer : UIPanGestureRecognizer){
        
        let translation:CGPoint = recognizer.translationInView(self.view)
        
        if (recognizer.view!.frame.origin.y + translation.y) > 0 && (recognizer.view!.frame.origin.y + translation.y) < self.view.frame.size.width - recognizer.view!.frame.size.height{
            recognizer.view!.center = CGPointMake(recognizer.view!.center.x, recognizer.view!.center.y + translation.y)
        }

        recognizer.setTranslation(CGPointMake(0, 0), inView: self.view)
    }
    
    func saveImage(button : UIButton){
        
        if imageToUpload != nil{
            let library = ALAssetsLibrary()
            library.writeImageToSavedPhotosAlbum(imageToUpload!.CGImage, orientation: ALAssetOrientation.Up) { (url, error) -> Void in
                if error != nil {
                    let alert = UIAlertView(title: "Error", message: "Error while saving your photo",
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                else{
                    let alert = UIAlertView(title: "Saved!", message: "Your photo has been saved on your library",
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
        else if urlVideoToUpload != nil{
            let library = ALAssetsLibrary()
            if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(self.urlVideoToUpload!){
                library.writeVideoAtPathToSavedPhotosAlbum(self.urlVideoToUpload, completionBlock: { (assetUrl, error) -> Void in
                    if error != nil{
                        let alert = UIAlertView(title: "Error", message: "Error while saving your video",
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    else{
                        let alert = UIAlertView(title: "Saved!", message: "Your video has been saved on your library",
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                })
            }
        }
        
        
        
        
    }
    
    
    // META: Access Last Library Photo
    
    func accessLastLibPhoto(){
        
        var isImageSet = false
        let library:ALAssetsLibrary = ALAssetsLibrary()
        
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos,
            usingBlock: { (group : ALAssetsGroup!, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                
                if group != nil{
                    group.setAssetsFilter(ALAssetsFilter.allPhotos())
                    
                    group.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse,
                        usingBlock: { (result : ALAsset!, index:Int, innerStop : UnsafeMutablePointer<ObjCBool>) -> Void in
                            if result != nil {
                                
                                if !isImageSet{
                                    let representation:ALAssetRepresentation = result.defaultRepresentation()
                                    
                                    let lastPhoto:UIImage = UIImage(CGImage: result.thumbnail().takeUnretainedValue())!
                                    
                                    isImageSet = true
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.libraryButton!.setImage(lastPhoto, forState: UIControlState.Normal)
                                    });
                                }
                                
                                
                            }
                    })
                }
                
               
                
                
        }) { (error) -> Void in
            println("Error")
        }
        
    }
    
    
    //MARK : PERMISSIONS PHO
    func checkIfCanPresentCamera() -> Bool{
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ==  AVAuthorizationStatus.Authorized
        {
            // Already Authorized
            return true
        }
        else
        {
            return false
        }
    }
    
    func askPermissionCamera(){
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
            if granted == true
            {
                dispatch_async(dispatch_get_main_queue()) {
                    self.noAuthCameraImageView.hidden = true
                    self.libraryButton!.hidden = false
                    self.changeCameraSideButton!.hidden = false
                    self.tutorialView.hidden = true
                    PBJVision.sharedInstance().startPreview()
                }
                
            }
            else
            {
                // User Rejected
                self.camDenied()
                println("Acces rejected")
            }
        });
    }
    
    
    func camDenied(){
        
        dispatch_async(dispatch_get_main_queue()) {
            var canOpenSettings:Bool = false
            
            switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("To interact with your friends you need to allow the access to your camera. Go to settings to allow it? You'll need to go in the privacy menu", comment : "To interact with your friends you need to allow the access to your camera. Go to settings to allow it? You'll need to go in the privacy menu"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    
                    self.openSettings()
                }))
                self.presentViewController(alert, animated: false, completion: nil)
            case .OrderedAscending:
                var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("To interact with your friends you need to allow the access to your camera. Please go to Settings > Confidentiality > Camera and allow it for Pleek", comment : "To interact with your friends you need to allow the access to your camera. Please go to Settings > Confidentiality > Camera and allow it for Pleek"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment : "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: false, completion: nil)
            }
        }
        
        
        
        
    }
    
    
    func openSettings(){
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    
    
    // MARK: Text over video
    
    func exportDidFinish(exporter : AVAssetExportSession){
        
        if exporter.status == AVAssetExportSessionStatus.Completed{
            
            var url:NSURL = exporter.outputURL
            
            println("Upload video")
            self.isPhoto = false
            
            
            //Generate and upload preview image video
            self.finalImage = Utils().getImageFrameFromVideoBeginning(url)
            var imageData:NSData = UIImageJPEGRepresentation(self.finalImage, 0.8)
            self.previewFile = PFFile(name: "photo.jpg", data: imageData)
            self.previewFile!.saveInBackgroundWithBlock({ (succeeded : Bool, error) -> Void in
                
                }, progressBlock: { (progress : Int32) -> Void in
                    println("Preview Progress: \(progress)")
            })
            
            
            //Upload video
            self.imageFile = PFFile(name: "video.mp4", contentsAtPath: url.path!)
            self.imageFile!.saveInBackgroundWithBlock({ (succeedded, error) -> Void in
                
                }, progressBlock: { (progress : Int32) -> Void in
                    println("Video Progress : \(progress)")
            })
            
            self.performSegueWithIdentifier("chooseRecipients", sender: self)
            
        }
        else{
            println("Error export : \(exporter.error.description)")
        }
        
    }
    
    func applyOverlay(path: String!){
        
        
        self.videoAsset = AVAsset.assetWithURL(NSURL(fileURLWithPath: path)) as? AVAsset
        
        //Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        var mixComposition:AVMutableComposition = AVMutableComposition()
        
        //Video track
        var compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset!.duration), ofTrack: videoAsset!.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack, atTime: kCMTimeZero, error: nil)
        compositionVideoTrack.preferredTransform = (videoAsset!.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack).preferredTransform
        
        //Audio track
        var compositionAudioTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset!.duration), ofTrack: videoAsset!.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack, atTime: kCMTimeZero, error: nil)
        compositionAudioTrack.preferredTransform = (videoAsset!.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack).preferredTransform
        
        
        
        var videoComposition:AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = compositionVideoTrack.naturalSize
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        
        applyTextWithComposition(videoComposition)
        
        
        var instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
        var videoTrack:AVAssetTrack = mixComposition.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
        var layerInstruction : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.layerInstructions = [layerInstruction]
        
        videoComposition.instructions = [instruction]
        
        
        
        var paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory:NSString = paths[0] as! NSString
        var myPathDocs:NSString = documentsDirectory.stringByAppendingPathComponent("finalVideo\(NSDate().description).m4v")
        var url:NSURL = NSURL(fileURLWithPath: myPathDocs as String)!
        
        var exporter:AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition
        
        exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.exportDidFinish(exporter)
            })
            
        })
        
        
    }
    
    
    func applyTextWithComposition(composition : AVMutableVideoComposition){
        
        let scale:CGFloat = composition.renderSize.width / self.view.frame.width
        
        var viewBack:UIView = UIView(frame: CGRectMake(0, 0, composition.renderSize.width, composition.renderSize.height))
        var textViewCustom:UITextView = UITextView(frame: CGRectMake(0, cameraTextView!.frame.origin.y * scale, cameraTextView!.frame.width * scale, cameraTextView!.frame.height * scale))
        textViewCustom.textColor = UIColor.whiteColor()
        textViewCustom.font = UIFont(name: cameraTextView!.font.fontName, size: cameraTextView!.font.pointSize * scale)
        textViewCustom.text = cameraTextView!.text
        textViewCustom.layer.shadowColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0, 0, 0, 0.5])
        textViewCustom.layer.shadowOffset = CGSizeMake(0, 1)
        textViewCustom.layer.shadowOpacity = 1.0
        textViewCustom.layer.shadowRadius = 2
        textViewCustom.backgroundColor = UIColor.clearColor()
        textViewCustom.textAlignment = NSTextAlignment.Center
        viewBack.backgroundColor = UIColor.clearColor()
        viewBack.addSubview(textViewCustom)
        
        var imageLabel:UIImage?
        if (self.cameraTextView!.text as NSString).length > 0{
            UIGraphicsBeginImageContextWithOptions(viewBack.frame.size, false, 0.0);
            viewBack.layer.renderInContext(UIGraphicsGetCurrentContext())
            imageLabel = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        println("Size imageLabel : \(imageLabel!.size)")
        
        if imageLabel != nil{
            // Setup the overlay
            var overlayLayer:CALayer = CALayer()
            overlayLayer.contents = imageLabel!.CGImage
            overlayLayer.frame = CGRectMake(0, 0, composition.renderSize.width, composition.renderSize.height)
            
            //Parent Layer
            var parentLayer = CALayer()
            var videoLayer:CALayer = CALayer()
            parentLayer.frame = CGRectMake(0, 0, composition.renderSize.width, composition.renderSize.height)
            videoLayer.frame = CGRectMake(0, 0, composition.renderSize.width, composition.renderSize.height)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(overlayLayer)
            
            
            composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        }
        
        
    }
}
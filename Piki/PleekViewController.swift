//
//  ViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 08/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import AssetsLibrary
import MessageUI
import Social


protocol PleekControllerProtocol {
    func updateReactsForPiki(piki : PFObject, updateAll : Bool)
    func updatePikis()
}

class PleekViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, ReactsCellProtocol, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, PBJVisionDelegate, UIActionSheetDelegate, NewReactViewControllerDelegate, ReactManagerDelegate {
    
    var newReactViewcontroller: NewReactViewController?
    
    var collectionView: UICollectionView?
    var mainPhotoView : UIView?
    var mainPhotoImageView:UIImageView?
    var actualMode:Int = 0
    var imageFile:PFFile?
    var takePhotoLabel : UILabel?
    var lastPiki:PFObject?
    var switchCamera:UIButton?
    var reacts:NSArray = NSArray()
    var likeImageView:UIImageView?
    var likeOverlayBlackView: UIView?
    var photoTaken:UIImage?
    var statusBarHidden:Bool = false
    var cameraText:UITextField?
    var constraint: Constraint?
    
    var previewCameraCell:ReactsCollectionViewCell?
    
    var delegate:PleekControllerProtocol? = nil
    
    //Videos
    var videoDuration:Int = 0
    let maxDuration = 5
    var videoURLs = [NSURL]()
    var timerReact:NSTimer?
    
    //Infos
    var mainPiki:PFObject?
    var pikiReacts:Array<AnyObject> = []
    var hasNewReacts:Bool = false
    var videoReacts = [String : AVPlayer]()
    
    //Action buttons
    var cameraActionButton:UIButton?
    var emojiActionButton:UIButton?
    var emojiActionImage:UIImageView?
    
    
    //View back emojis
    var backEmojisView:UIView?
    var selectedEmoji:Int = 0
    var stillPressingLike:Bool = false
    var emojisOpen:Bool = false
    
    var recipients:Array<String>?
    var tapToDismissKeyboard:UITapGestureRecognizer?
    
    
    // POP UP
    var popUpView:UIView?
    var overlayView:UIView?
    var userPopUp:PFUser?
    
    //VIDEO
    var playerItmes:Array<[String:AnyObject]> = Array<[String:AnyObject]>()
    var isRecording:Bool = false
    
    //Tuto overlay
    var overlayTuto:UIView!
    
    
    //Keep images
    var mainPekeeImage:UIImage?
    
    //Camera Menu V2
    var mainOverlayCameraMenu:UIView?
    var secondOverlayCameraView:UIView?
    var isLeavingCameraMode:Bool = false
    
    //Share views elements
    var bottomShareView:UIView?
    var imageShareView:UIView?
    var shareOverlay:UIView?
    var viewToBuildImage:UIView?
    var imageContainerView:UIView?
    var quitButtonReply:UIButton?
    
    var indexPathBig:NSIndexPath?
    
    var documentInteractionController:UIDocumentInteractionController?
    var isLoadingMore:Bool = false
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var authorizing:Bool = false
    var parrotLoad:UIImageView?
    var previewCameraView:UIView?
    var memCollectionView:UICollectionView!
    var isMemShowed : Bool = false
    var positionMemShowed:Int?
    var mems : Array<PFObject> = Array<PFObject>()
    var backShareButton:UIImageView?
    
    var share1vs1View:UIView?
    
    var shareMessengerReactView:UIView?
    var gifURLLastReact:NSURL?
    var isPublicPleek:Bool = false
    
    
    //Likes
    var listLikesUser:Set<String> = Set<String>()
    var likeSoundPlayer:AVAudioPlayer?
    
    var playerVideoPleek:AVPlayer?
    var isTakingPhoto:Bool = true
    
    var reactToShare:PFObject?
    var tutorialView:UIView?
    var reactToRemove:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        if PFUser.currentUser() == nil {
            println("NIL")
        }
        
        FBSDKAppEvents.logEvent(FBSDKAppEventNameViewedContent)
        Mixpanel.sharedInstance().track("View Piki")
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        
        
        //IsPublic
        if self.mainPiki!["isPublic"] != nil {
            isPublicPleek = self.mainPiki!["isPublic"] as! Bool
        }
        else{
            isPublicPleek = true
        }
        recipients = self.mainPiki!["recipients"] as? Array<String>
        
        
        //Listen keyboard to move collection view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("morePeekee"), name: "moreInfosPleek", object: nil)
        
        
        
        
        //V2 UX/UI
        
        
        //Back Status bar
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        
        
        //Top Bar
        let topBarView:UIView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 60))
        topBarView.backgroundColor = Utils().primaryColor
        
        
        //View top left for username/back
        var gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("quit"))
        let backLeftView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        backLeftView.backgroundColor = Utils().primaryColor
        backLeftView.addGestureRecognizer(gesture)
        topBarView.addSubview(backLeftView)
        
        let backImageView:UIImageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 8, height: 60))
        backImageView.image = UIImage(named: "button_back")
        backImageView.contentMode = UIViewContentMode.Center
        topBarView.addSubview(backImageView)
        
        let colorShareButton:UIView = UIView(frame: CGRect(x: self.view.frame.size.width - 60, y: 0, width: 60, height: 60))
        colorShareButton.backgroundColor = Utils().primaryColorDark
        topBarView.addSubview(colorShareButton)
        
        backShareButton = UIImageView(frame: CGRect(x: self.view.frame.size.width - 60, y: 0, width: 60, height: 60))
        backShareButton!.contentMode = UIViewContentMode.Center
        backShareButton!.hidden = true
        backShareButton!.alpha = 0.5
        topBarView.addSubview(backShareButton!)
        
//        let usernameLabel:UILabel = UILabel(frame: CGRect(x: 40, y: 0, width: self.view.frame.width - 150, height: 40))
        let usernameLabel:UILabel = UILabel(frame: CGRectZero)
        usernameLabel.center = CGPoint(x: self.view.frame.width/2, y: 25)
        usernameLabel.textAlignment = NSTextAlignment.Center
        usernameLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        usernameLabel.textColor = UIColor.whiteColor()
        topBarView.addSubview(usernameLabel)
        
        usernameLabel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(backLeftView.snp_trailing)
            make.trailing.equalTo(colorShareButton.snp_leading)
            make.top.equalTo(topBarView.snp_top).offset(8)
            make.bottom.equalTo(topBarView.snp_centerY)
        }
        
        
        if self.mainPiki!["user"] != nil {
            
            var user = self.mainPiki!["user"] as! PFUser
            
            if user["name"] != nil{
                var name:String = user["name"] as! String
                usernameLabel.text = "\(name)"
            }
            else{
                usernameLabel.text = "@\(user.username!)"
            }
            
            
        }
        
//        let recipientsNumberLabel:UILabel = UILabel(frame: CGRect(x: 40, y: 0, width: self.view.frame.width - 150, height: 30))
        let recipientsNumberLabel:UILabel = UILabel(frame: CGRectZero)
        recipientsNumberLabel.center = CGPoint(x: self.view.frame.width/2, y: 45)
        recipientsNumberLabel.textAlignment = NSTextAlignment.Center
        recipientsNumberLabel.font = UIFont(name: Utils().customFontSemiBold, size: 13)
        recipientsNumberLabel.textColor = Utils().statusBarColor
        topBarView.addSubview(recipientsNumberLabel)
        
        recipientsNumberLabel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(backLeftView.snp_trailing)
            make.trailing.equalTo(colorShareButton.snp_leading)
            make.top.equalTo(topBarView.snp_centerY)
            make.bottom.equalTo(topBarView.snp_bottom).offset(-8)
        }
        
        if isPublicPleek {
            recipientsNumberLabel.text = LocalizedString("PUBLIC")
        }
        else{
            if recipients != nil{
                recipientsNumberLabel.text = String(format: LocalizedString("TO %@ FRIENDS"), Utils().formatNumber(recipients!.count))
            }
            else{
                recipientsNumberLabel.text = LocalizedString("TO SOME FRIENDS")
            }
            
        }
        
        
        
        
        
        let shareButton:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 60, y: 0, width: 60, height: 60))
        shareButton.setImage(UIImage(named: "share_icon"), forState: UIControlState.Normal)
        shareButton.addTarget(self, action: Selector("buildViewSharePopUp"), forControlEvents: UIControlEvents.TouchUpInside)
        topBarView.addSubview(shareButton)
        
        
        //Collection View Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width/2 - 0.5, height: UIScreen.mainScreen().bounds.width/2 - 0.5)

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 60, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 60) , collectionViewLayout: layout)
        //collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(ReactsCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView!.registerClass(MainPeekeeCollectionViewCell.self, forCellWithReuseIdentifier: "MainCell")
        collectionView!.registerClass(CameraCollectionViewCell.self, forCellWithReuseIdentifier: "CameraCell")
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.showsVerticalScrollIndicator = false
        self.view.addSubview(collectionView!)
        
        self.collectionView!.alwaysBounceVertical = true
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "moreFooter")
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "moreHeader")
        
        //Shadow Top Bar
        var stretchShadowImage:UIImage = UIImage(named: "shadow")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowTopBar:UIImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 64))
        shadowTopBar.image = stretchShadowImage
        self.view.addSubview(shadowTopBar)
        
        self.view.addSubview(backStatusBar)
        self.view.addSubview(topBarView)
        
        
        
        refreshControl.tintColor = Utils().darkGrey
        refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refreshControl)
        
        
        getReacts()
        Utils().setPikiAsView(self.mainPiki!)
        
        
        
        
        self.mainPiki!.fetchInBackgroundWithBlock { (updatedMainPiki : PFObject?, error : NSError?) -> Void in
            if error == nil{
                self.updateMainCellPleek()
            }
        }
        
        //Get Likes user has done on reacts of this pleek
        getLikesUser()
        
        setupCamera()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Photo stream init
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        PBJVision.sharedInstance().stopPreview()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        let betterPath = NSBundle.mainBundle().pathForResource("like_react_sound", ofType: "wav")
        let betterURL = NSURL(fileURLWithPath: betterPath!)
        likeSoundPlayer = AVAudioPlayer(contentsOfURL: betterURL, error: nil)
        likeSoundPlayer!.prepareToPlay()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
       //MARK : NEW VERSION CAMERA
    
    func setupCamera(){
        
        var vision:PBJVision = PBJVision.sharedInstance()
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        
        /*if Utils().isIphone4(){
        vision.videoBitRate = 87500 * 8
        
        }
        else{
        vision.videoBitRate = 437500 * 8
        }*/
        vision.thumbnailEnabled = false
        if Utils().isIphone4(){
            vision.captureSessionPreset = AVCaptureSessionPresetLow
        }
        else{
            vision.captureSessionPreset = AVCaptureSessionPresetMedium
        }
        
        vision.maximumCaptureDuration = CMTimeMakeWithSeconds(6, 600)
        vision.outputFormat = PBJOutputFormat.Square
        vision.cameraMode = PBJCameraMode.Video
        
    }
    
    
    func refresh(){
        
        self.mainPiki!.fetchInBackgroundWithBlock { (updatedMainPiki : PFObject?, error : NSError?) -> Void in
            if error == nil{
                self.updateMainCellPleek()
            }
        }
        
        getReacts()
        
    }
    
    
    func updateMainCellPleek(){
        
        if let mainCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? MainPeekeeCollectionViewCell{
            
            if let nbReplies = self.mainPiki!["nbReaction"] as? Int{
                if nbReplies > 0{
                    mainCell.nbRepliesLabel.text = String(format: LocalizedString("%@ REPLIES"), Utils().formatNumber(nbReplies))
                }
                else{
                    mainCell.nbRepliesLabel.text = LocalizedString("REPLY FIRST")
                }
                
            }
            else{
                mainCell.nbRepliesLabel.text = LocalizedString("REPLY FIRST")
            }
            
            //mainCell.updateInfosPleek()
        }
        
        //self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
        
    }
    
    //Number of cells
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else{
            return self.pikiReacts.count+1
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize(width: self.view.frame.width, height: 2)
        }
        else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
        }
        else {
            if indexPath == indexPathBig{
                return CGSize(width: self.view.frame.width, height: (self.view.frame.width - 2)/3 * 2)
            }
            else{
                return CGSize(width: self.view.frame.size.width/2 - 0.5, height: self.view.frame.size.width/2 - 0.5)
            }
            
            
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
    }*/
    //Build each cell
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
        //Load More
        if indexPath.item == (pikiReacts.count - 1){
            
            
            if pikiReacts.count > 30 && !isLoadingMore{
                
                let nbReact = self.mainPiki!["nbReaction"] as? Int
                if nbReact != nil{
                    if nbReact > pikiReacts.count{
                        isLoadingMore = true
                        self.getMoreReacts()
                    }
                }
            }
        }
        
        
        //Build cells
        if indexPath.section == 0{
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MainCell", forIndexPath: indexPath) as! MainPeekeeCollectionViewCell
            
            if self.mainPiki != nil {
                
                
                if let nbReplies = self.mainPiki!["nbReaction"] as? Int{
                    cell.nbRepliesLabel.text = String(format: LocalizedString("%@ REPLIES"), Utils().formatNumber(nbReplies))
                }
                else{
                    cell.nbRepliesLabel.text = "REPLY FIRST"
                }
                
                var file:PFFile?
                if mainPiki!["photo"] != nil {
                    file = mainPiki!["photo"] as? PFFile
                }
                else{
                    file = mainPiki!["previewImage"] as? PFFile
                }
                
                cell.mainImageView.file = file
                cell.spinnerView.hidden = false
                cell.spinnerView.startAnimating()
                cell.mainImageView.loadInBackground({ (image, error) -> Void in
                    cell.spinnerView.stopAnimating()
                    cell.spinnerView.hidden = true
                    }, progressBlock: { (progress) -> Void in
                        println("progress : \(progress)")
                })
                
                
                
                if mainPiki!["video"] != nil{
                    
                    if cell.playerLayer.player != nil{
                        
                    }
                    else{
                        cell.spinnerView.startAnimating()
                        cell.spinnerView.hidden = false
                        
                        let videoFile:PFFile = mainPiki!["video"] as! PFFile
                        
                        
                        videoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            
                            if data != nil{
                                if self.mainPiki != nil{
                                    var fileManager:NSFileManager = NSFileManager()
                                    if data!.writeToFile("\(NSTemporaryDirectory())_\(self.mainPiki!.objectId).mov", atomically: false){
                                        
                                        if self.playerVideoPleek == nil{
                                            
                                            var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(self.mainPiki!.objectId).mov")
                                            var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                                            self.playerVideoPleek = AVPlayer(playerItem: playerItem)
                                            self.playerVideoPleek!.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                                            self.playerVideoPleek!.muted = false
                                            
                                            
                                            
                                            
                                            
                                            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerVideoPleek!.currentItem)
                                            
                                        }
                                        
                                        
                                        
                                        
                                        if (self as UIViewController).isViewLoaded() && ((self as UIViewController).view.window != nil) {
                                            if cell.playerLayer.player == nil{
                                                cell.spinnerView.stopAnimating()
                                                cell.spinnerView.hidden = true
                                                cell.playerLayer.player = self.playerVideoPleek!
                                                cell.playerView.hidden = false
                                                self.playerVideoPleek!.play()
                                            }
                                            
                                        }
                                        
                                        
                                        
                                    }
                                }
                            }
                            
                            
                            
                            
                            
                        })
                    }
                    
                    
                }
                
            }
            
            return cell
            
        }
        else{
            
            //Camera view
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CameraCell", forIndexPath: indexPath) as! CameraCollectionViewCell
                if !cell.hasLoaded{
                    cell.loadCell()
                    
                }
                cell.grantAccessView.hidden = true
                cell.previewLayer = PBJVision.sharedInstance().previewLayer
                cell.previewLayer.frame = CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height)
                cell.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                cell.previewCameraView.layer.addSublayer(cell.previewLayer)
                cell.updateCell(checkIfCanPresentCamera())
                
                
                
                return cell
                
            }
                //Display React
            else{
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ReactsCollectionViewCell
                if !cell.hasLoaded{
                    cell.loadCell()
                }
                
                
                cell.ownPosition = indexPath.item
                cell.mainPeekee = self.mainPiki!
                
                
                cell.react = nil
                cell.delegate = self
                cell.readVideoImageView.hidden = true
                cell.reactVideoURL = nil
                cell.pikiInfos = nil
                cell.playerView.hidden = true
                cell.reactImage.hidden = false
                cell.reactImage.image = nil
                
                
                if self.pikiReacts[indexPath.item-1].isKindOfClass(PFObject){
                    cell.react = self.pikiReacts[indexPath.item-1] as? PFObject
                    cell.updateFrontLikes()
                    
                    var pikiReact:PFObject = self.pikiReacts[indexPath.item-1] as! PFObject
                    //React is a photo
                    if (pikiReact["photo"] != nil){
                        cell.playerView.hidden = true
                        
                        
                        
                        if let file = pikiReact["photo"] as? PFFile{
                            cell.startAnimateLoader()
                            cell.reactImage.file = file
                            cell.reactImage.loadInBackground({ (finalImage, error) -> Void in
                                cell.stopAnimateLoader()
                                }, progressBlock: { (progress) -> Void in
                                    
                            })
                        }
                        
                        /*
                        var file:PFFile = pikiReact["photo"] as! PFFile
                        file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                        var arrayIndex:Array<NSIndexPath> = collectionView.indexPathsForVisibleItems() as! Array<NSIndexPath>
                        if contains(arrayIndex, indexPath){
                        cell.backImageView!.hidden = true
                        let imageReact:UIImage? = UIImage(data : data!)
                        if imageReact != nil{
                        cell.reactImage.image = imageReact
                        cell.reactImage.hidden = false
                        }
                        
                        }
                        else{
                        }
                        }
                        else{
                        println("Error getting image")
                        
                        }
                        })*/
                    }
                        //React is a video
                    else{
                        cell.readVideoImageView.hidden = false
                        
                        cell.playerView.hidden = true
                        
                        
                        if let file = pikiReact["previewImage"] as? PFFile{
                            cell.startAnimateLoader()
                            cell.reactImage.file = file
                            cell.reactImage.loadInBackground({ (finalImage, error) -> Void in
                                cell.stopAnimateLoader()
                                }, progressBlock: { (progress) -> Void in
                                    
                            })
                        }
                        else{
                            cell.spinnerView.hidden = true
                            cell.reactImage.hidden = true
                        }
                        
                        /*
                        //Load preview image first
                        if pikiReact["previewImage"] != nil{
                        
                        var file:PFFile = pikiReact["previewImage"] as! PFFile
                        file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                        var arrayIndex:Array<NSIndexPath> = collectionView.indexPathsForVisibleItems() as! Array<NSIndexPath>
                        if contains(arrayIndex, indexPath){
                        
                        let imageReact:UIImage = UIImage(data : data!)!
                        cell.backImageView!.hidden = true
                        cell.reactImage.image = imageReact
                        cell.reactImage.hidden = false
                        }
                        }
                        })
                        }
                        else{
                        cell.reactImage.hidden = true
                        }*/
                    }
                }
                else{
                    var pikiInfos:[String : AnyObject] = self.pikiReacts[indexPath.item-1] as! [String : AnyObject]
                    cell.updateFrontLikes()
                    
                    cell.playerView.hidden = true
                    cell.reactRandomId = pikiInfos["id"] as? String
                    if pikiInfos["photo"] != nil {
                        cell.reactImage.image = pikiInfos["photo"] as? UIImage
                        cell.reactImage.hidden = false
                        
                    }
                    else{
                        println("PIKIINFOS :\(pikiInfos)")
                        cell.readVideoImageView.hidden = false
                        cell.reactImage.hidden = false
                        cell.reactVideoURL = (pikiInfos["videoPath"] as? NSURL)?.path!
                        
                        cell.reactImage.image = pikiInfos["previewImage"] as? UIImage
                    }
                    cell.pikiInfos = pikiInfos
                }
                
                
                return cell
                
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1{
            if indexPath.item == 0{
                let cell:CameraCollectionViewCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! CameraCollectionViewCell
                
                if checkIfCanPresentCamera(){
                    cell.openCamera()
                    cell.textViewOverPhoto.hidden = false
                    cell.textViewOverPhoto.text = ""
                    cell.textViewOverPhoto.becomeFirstResponder()
                }
                else{
                    self.askPermissionCamera()
                }
            }
            else{
                let cell:ReactsCollectionViewCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! ReactsCollectionViewCell
                cell.flip()
                //cell.startVideo()
            }
        }
        else{
            var cellMain:MainPeekeeCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as! MainPeekeeCollectionViewCell
            
            if cellMain.playerLayer.player != nil{
                
                if (cellMain.playerLayer.player.rate > 0 && cellMain.playerLayer.player.error == nil) {
                    cellMain.playerLayer.player.pause()
                    cellMain.readVideoIcon.hidden = false
                }
                else{
                    cellMain.playerLayer.player.play()
                    cellMain.readVideoIcon.hidden = true
                    NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["pikiId" : self.mainPiki!.objectId!])
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 1{
            if pikiReacts.count > 30{
                let nbReact = self.mainPiki!["nbReaction"] as? Int
                if nbReact != nil{
                    if nbReact > pikiReacts.count{
                        return CGSize(width: self.view.frame.width, height: 50)
                    }
                }
            }
            
            //return CGSize(width: self.view.frame.width, height: 50)
            return CGSize(width: self.view.frame.width, height: 0)
            
        }
        else{
            return CGSize(width: self.view.frame.width, height: 0)
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView:UICollectionReusableView?
        
    
        if kind == UICollectionElementKindSectionFooter{
            
            reusableView = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "moreFooter", forIndexPath: indexPath) as? UICollectionReusableView
            
            if parrotLoad != nil{
                parrotLoad!.hidden = true
            }
            
            if indexPath.section == 1{
                
                reusableView!.backgroundColor = UIColor.whiteColor()
                
                if parrotLoad == nil{
                    parrotLoad = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                    parrotLoad!.center = CGPoint(x: reusableView!.frame.width/2, y: reusableView!.frame.height/2)
                    parrotLoad!.contentMode = UIViewContentMode.Center
                    parrotLoad!.image = UIImage(named: "parrot_menu")
                    reusableView!.addSubview(parrotLoad!)
                }
                
                
                
                if pikiReacts.count > 30{
                    let nbReact = self.mainPiki!["nbReaction"] as? Int
                    if nbReact != nil{
                        if nbReact > pikiReacts.count{
                            parrotLoad!.hidden = false
                        }
                    }
                }
                else{
                    parrotLoad!.hidden = true
                }
                
                
                let options = UIViewAnimationOptions.Autoreverse | UIViewAnimationOptions.Repeat | UIViewAnimationOptions.CurveLinear
                UIView.animateWithDuration(0.8,
                    delay: 0,
                    options: options,
                    animations: { () -> Void in
                        self.parrotLoad!.alpha = 0.0
                    }, completion: { (finisehd) -> Void in
                        
                })
                
            }
            else{
                if parrotLoad != nil{
                    parrotLoad!.hidden = true
                }
            }
            
        }
        else{
            reusableView = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "moreHeader", forIndexPath: indexPath) as? UICollectionReusableView
            
            if parrotLoad != nil{
                parrotLoad!.hidden = true
            }
        }
        return reusableView!
    }
    
    

    
    
    
    /*
    * Build photos with different layers
    */
    
    
    
    func getPhotoWithTextOverlay(image : UIImage) -> UIImage? {
        var finalImage:UIImage?
        
        
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            let size:CGSize = CGSize(width: cell.frame.size.width * UIScreen.mainScreen().scale, height: cell.frame.size.width * UIScreen.mainScreen().scale)
            
            var imageLabel:UIImage?
            cell.textViewOverPhoto!.editable = false
            if (cell.textViewOverPhoto!.text as NSString).length > 0 {
                UIGraphicsBeginImageContextWithOptions(cell.textViewOverPhoto!.frame.size, false, 0.0);
                cell.textViewOverPhoto!.layer.renderInContext(UIGraphicsGetCurrentContext())
                imageLabel = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            cell.textViewOverPhoto!.editable = true
            
            
            UIGraphicsBeginImageContext(size)
            
            image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            if imageLabel != nil{
                imageLabel!.drawInRect(CGRect(x: 0, y: cell.textViewOverPhoto!.frame.origin.y * UIScreen.mainScreen().scale, width: imageLabel!.size.width * UIScreen.mainScreen().scale, height: imageLabel!.size.height * UIScreen.mainScreen().scale))
            }
            
            
            
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return finalImage
    }
    
    
    
    func getPhotoWithLikeOverlay(image : UIImage) ->  UIImage? {
        
        
        var imageLike:UIImage?
        var finalImage:UIImage?
        
        
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            cell.closeCamera()
            
            let size:CGSize = CGSize(width: cell.frame.size.width * UIScreen.mainScreen().scale, height: cell.frame.size.width * UIScreen.mainScreen().scale)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
            cell.memeImageView.layer.renderInContext(UIGraphicsGetCurrentContext())
            
            imageLike = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIGraphicsBeginImageContext(size)
            
            image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            imageLike!.drawInRect(CGRect(x: 0, y: 0, width: imageLike!.size.width *  UIScreen.mainScreen().scale, height: imageLike!.size.height  * UIScreen.mainScreen().scale))
            
            
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        
        
        
        
        return finalImage
        
    }
    
    
    // Quit button
    func quit(){
        
        //removeAudio()
        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
        Utils().setPikiAsView(self.mainPiki!)
        
        if self.hasNewReacts{
            self.delegate!.updateReactsForPiki(self.mainPiki!, updateAll : true)
        }
        else{
            self.delegate!.updateReactsForPiki(self.mainPiki!, updateAll : false)
        }
        
        
        
        self.performSegueWithIdentifier("returnToMenu", sender: self)
        
    }
    
    
    /*
    * Player notification
    */
    
    func videoDidEnd(notification : NSNotification){
        var player:AVPlayerItem = notification.object as! AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }
    
    
    
    
    
    
    /*
    * Scroll View Delegate
    */
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        //pauseAndMuteAllVideos()
        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate{
            NSNotificationCenter.defaultCenter().postNotificationName("scrollEnded", object: nil)
            //self.startVideoOnVisibleCells()
        }
        
        
        
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        println("End Decelerating")
        NSNotificationCenter.defaultCenter().postNotificationName("scrollEnded", object: nil)
        //self.startVideoOnVisibleCells()
    }
    
    /*
    * VIDEOS MANIP
    */
    
    func startVideoOnVisibleCells(){
        
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
            for cell in self.collectionView!.visibleCells() as! Array<ReactsCollectionViewCell> {
                
                let indexPath:NSIndexPath? = self.collectionView!.indexPathForCell(cell)
                
                if let index = indexPath {
                    if index.item > 0{
                        
                        if self.pikiReacts[index.item - 1].isKindOfClass(PFObject){
                            let pikiReact:PFObject = self.pikiReacts[index.item-1] as! PFObject
                            
                            if pikiReact["video"] != nil{
                                
                                var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(pikiReact.objectId).mov")
                                
                                if NSFileManager.defaultManager().fileExistsAtPath(filepath!.path!){
                                    var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                                    var player:AVPlayer = AVPlayer(playerItem: playerItem)
                                    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                                    player.muted = true
                                    player.play()
                                    
                                    
                                    
                                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                                    
                                    dispatch_async(dispatch_get_main_queue(), { ()->() in
                                        cell.playerLayer.player = player
                                        cell.playerView.hidden = false
                                    })
                                }
                                else{
                                    let videoFile:PFFile = pikiReact["video"] as! PFFile
                                    
                                    videoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                        
                                        
                                        var fileManager:NSFileManager = NSFileManager()
                                        if data!.writeToFile("\(NSTemporaryDirectory())_\(pikiReact.objectId).mov", atomically: false){
                                            
                                            
                                            var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(pikiReact.objectId).mov")
                                            var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                                            var player:AVPlayer = AVPlayer(playerItem: playerItem)
                                            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                                            player.muted = true
                                            player.play()
                                            
                                            
                                            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                                            
                                            dispatch_async(dispatch_get_main_queue(), { ()->() in
                                                cell.playerLayer.player = player
                                                cell.playerView.hidden = false
                                            })
                                        }
                                        
                                        
                                    })
                                }
                            }
                        }
                            
                        else{
                            var pikiInfos:[String : AnyObject] = self.pikiReacts[index.item-1] as! [String : AnyObject]
                            
                            if pikiInfos["videoPath"] != nil {
                                
                                var playerItem:AVPlayerItem = AVPlayerItem(URL: pikiInfos["videoPath"] as! NSURL)
                                var player:AVPlayer = AVPlayer(playerItem: playerItem)
                                player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                                player.muted = true
                                
                                dispatch_async(dispatch_get_main_queue(), { ()->() in
                                    cell.playerLayer.player = player
                                    cell.playerView.hidden = false
                                })
                                
                                player.play()
                                
                                
                                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                            }
                            
                        }
                        
                        
                    }
                }
                
                
            }
        })
        
        
        
        
    }
    
    
    
    
    /*
    * Action Reacts
    */
    
    
    
    func updateReactRequest(){
        var requestReact:PFQuery = PFQuery(className: "React")
        requestReact.whereKey("Piki", equalTo: mainPiki!)
        requestReact.orderByDescending("createdAt")
        requestReact.limit = 50
        requestReact.cachePolicy = PFCachePolicy.NetworkOnly
        requestReact.includeKey("user")
        
        requestReact.findObjectsInBackgroundWithBlock { (reacts, error) -> Void in
            
        }
    }
    
    
    func getReacts(){
        
        var requestReact:PFQuery = PFQuery(className: "React")
        requestReact.whereKey("Piki", equalTo: mainPiki!)
        requestReact.orderByDescending("createdAt")
        requestReact.limit = 50
        requestReact.cachePolicy = PFCachePolicy.CacheThenNetwork
        requestReact.includeKey("user")
        
        requestReact.findObjectsInBackgroundWithBlock { (reacts, error) -> Void in
            self.refreshControl.endRefreshing()
            if error != nil{
                
            }
            else{
                
                
                
                if self.pikiReacts.count == 0{
                    self.pikiReacts = reacts as! Array<PFObject>
                    
                    
                    self.buildViewShareBackButton()
                    self.collectionView!.reloadSections(NSIndexSet(index: 1))
                }
                else{
                    var nbReactToInsert:Int = 0
                    var indexPathToReload:[NSIndexPath] = [NSIndexPath]()
                    var positionIndexPathToReload:[Int] = [Int]()
                    
                    var position:Int = 0
                    for react in reacts as! Array<PFObject> {
                        var alreadyIn:Bool = false
                        for actualReact in self.pikiReacts{
                            
                            if actualReact.isKindOfClass(PFObject){
                                if react.objectId == actualReact.objectId{
                                    
                                    
                                    
                                    //update react nb likes
                                    if let nbLikesNew = react["nbLikes"] as? Int{
                                        
                                        if let nbLikesNew = react["nbLikes"] as? Int{
                                            if self.pikiReacts[position].isKindOfClass(PFObject){
                                                (self.pikiReacts[position] as! PFObject)["nbLikes"] = nbLikesNew
                                            }
                                            
                                            
                                            /*if let cellUpdate:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: position + 1, inSection: 1)) as? ReactsCollectionViewCell{
                                            println("Position : \(position), new like : \(nbLikesNew)")
                                            cellUpdate.updateFrontLikes()
                                            }*/
                                        }
                                        
                                        
                                    }
                                    
                                    alreadyIn = true
                                    break
                                }
                            }
                            
                            
                        }
                        
                        if !alreadyIn{
                            self.pikiReacts.insert(react, atIndex: nbReactToInsert)
                            nbReactToInsert++
                        }
                        
                        position++
                    }
                    
                    
                    self.collectionView!.reloadSections(NSIndexSet(index: 1))
                    /*if nbReactToInsert > 0{
                    
                    
                    var indexToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    for index in 1...(nbReactToInsert){
                    indexToInsert.append(NSIndexPath(forItem: index, inSection: 1))
                    }
                    
                    self.collectionView!.performBatchUpdates({ () -> Void in
                    self.collectionView!.insertItemsAtIndexPaths(indexToInsert)
                    }, completion: { (completed) -> Void in
                    self.buildViewShareBackButton()
                    
                    })
                    }*/
                    
                    
                    
                    
                    
                    
                    
                    
                }
                
            }
        }
        
        
    }
    
    
    func getMoreReacts(){
        
        println("MORE REACTS")
        
        var skipNumber:Int = self.pikiReacts.count
        
        var firstTimeDone:Bool = false
        
        var requestReact:PFQuery = PFQuery(className: "React")
        requestReact.whereKey("Piki", equalTo: mainPiki!)
        requestReact.orderByDescending("createdAt")
        requestReact.limit = 50
        requestReact.skip = skipNumber
        //requestReact.cachePolicy = kPFCachePolicyCacheThenNetwork
        requestReact.includeKey("user")
        
        requestReact.findObjectsInBackgroundWithBlock { (reacts, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                //if firstTimeDone{
                self.isLoadingMore = false
                //}
                
                //firstTimeDone = true
                
                
                self.refreshControl.endRefreshing()
                if error != nil{
                    
                }
                else{
                    
                    if self.pikiReacts.count == 0{
                        self.pikiReacts = reacts as! Array<PFObject>
                        
                        for react in self.pikiReacts{
                        }
                        
                        self.collectionView!.reloadSections(NSIndexSet(index: 1))
                    }
                    else{
                        var nbReactToInsert:Int = 0
                        for react in reacts as! Array<PFObject> {
                            var alreadyIn:Bool = false
                            for actualReact in self.pikiReacts{
                                if react.objectId == actualReact.objectId{
                                    alreadyIn = true
                                    break
                                }
                            }
                            
                            if !alreadyIn{
                                self.pikiReacts.append(react)
                                //self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: nbReactToInsert, inSection: 0)])
                                //self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: nbReactToInsert, inSection: 0)])
                                nbReactToInsert++
                            }
                            
                            
                        }
                        
                        if nbReactToInsert > 0{
                            
                            //self.collectionView!.reloadData()
                            
                            var indexToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                            for index in (self.pikiReacts.count - nbReactToInsert + 1)...self.pikiReacts.count{
                                indexToInsert.append(NSIndexPath(forItem: index, inSection: 1))
                            }
                            
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                self.collectionView!.performBatchUpdates({ () -> Void in
                                    self.collectionView!.insertItemsAtIndexPaths(indexToInsert)
                                    }, completion: { (completed) -> Void in
                                })
                            })
                            
                            
                            
                        }
                        
                        
                    }
                    
                }
            }
            
            
        }
        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        
        if shareOverlay != nil{
            if !shareOverlay!.hidden{
                return true
            }
        }
        
        return false;
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    
    func seeFriends(sender : AnyObject){
        println("see friends")
        self.performSegueWithIdentifier("showRecipients", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRecipients"{
            NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
            var listRecipientsController:ListRecipientsViewController = segue.destinationViewController as! ListRecipientsViewController
            listRecipientsController.mainPiki = self.mainPiki!
            
        }
    }
    
    func removeReact(react : AnyObject, isReport : Bool){
        self.reactToRemove = nil
        if !isReport{
            switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                
                var alert = UIAlertController(title: LocalizedString("Delete"), message: LocalizedString("Are you sure you want to delete this react? You won't be able to get it back!"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    
                    self.finallyRemove(react, isReport: isReport)
                    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            case .OrderedAscending:
                self.reactToRemove = react
                var alertView = UIAlertView(title: LocalizedString("Delete"),
                    message:  LocalizedString("Are you sure you want to delete this React? You won't be able to get it back!"),
                    delegate: self,
                    cancelButtonTitle: LocalizedString("No"),
                    otherButtonTitles: LocalizedString("Yes"))
                alertView.tag = 10
                alertView.show()
                
            }
        }
        else{
            finallyRemove(react, isReport: isReport)
        }
    }
    
    func finallyRemove(react : AnyObject, isReport : Bool){
        if react.isKindOfClass(PFObject){
            if !isReport{
                self.removeReactFromList(react)
            }
            
            var reactObject: PFObject = react as! PFObject
            PFCloud.callFunctionInBackground("reportOrRemoveReact ", withParameters: ["reactId" : reactObject.objectId!]) { (result, error) -> Void in
                if error != nil {
                    if isReport{
                        let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while reporting this react. Please try again later"),
                            delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                        alert.show()
                    }
                    else{
                        let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this react. Please try again later"),
                            delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                        alert.show()
                    }
                    
                    
                }
                else{
                    if isReport{
                        let alert = UIAlertView(title: LocalizedString("Report"), message: LocalizedString("This react has been reported. Thank you."),
                            delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                        alert.show()
                        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
                    }
                    else{
                        self.updateReactRequest()
                    }
                }
            }
        }
        else{
            self.removeReactFromList(react)
        }
    }
    
    
    // MARK: Pop Up
    
    func presentPopUpForUser(user : PFUser){
        
        //muteAllVideos()
        
        userPopUp = user
        
        if popUpView == nil {
            
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
            
            popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 180))
            popUpView!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpView!.center = self.view.center
            popUpView!.layer.cornerRadius = 5
            popUpView!.clipsToBounds = true
            self.view.addSubview(popUpView!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpView!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpView!.addSubview(header)
            
            let labelAddFriend:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelAddFriend.textAlignment = NSTextAlignment.Center
            labelAddFriend.font = UIFont(name: Utils().customFontSemiBold, size: 18)
            labelAddFriend.textColor = UIColor.whiteColor()
            labelAddFriend.text = "ADD AS FRIEND"
            labelAddFriend.tag = 12
            header.addSubview(labelAddFriend)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 121, width: popUpView!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpView!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpView!.frame.width/2, y: 121, width: 1, height: popUpView!.frame.height - 121))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpView!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 124, width: popUpView!.frame.width/2, height: popUpView!.frame.height - 124))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpView!.addSubview(quitImageView)
            
            
            let usernameLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 48, width: popUpView!.frame.width, height: 73))
            usernameLabel.textAlignment = NSTextAlignment.Center
            usernameLabel.font = UIFont(name: Utils().customFontNormal, size: 24)
            usernameLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            usernameLabel.text = "@\(user.username!)"
            usernameLabel.tag = 10
            popUpView!.addSubview(usernameLabel)
            
            let addFriend:UIButton = UIButton(frame: CGRect(x: popUpView!.frame.width/2, y: 124, width: popUpView!.frame.width/2, height: popUpView!.frame.height - 124))
            addFriend.addTarget(self, action: Selector("addFriendFromPopUp"), forControlEvents: UIControlEvents.TouchUpInside)
            addFriend.tag = 11
            popUpView!.addSubview(addFriend)
            
            let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.center = addFriend.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.tag = 13
            popUpView!.addSubview(activityIndicator)
            
            
        }
        
        
        self.popUpView!.transform =  CGAffineTransformMakeScale(0, 0)
        let labelUsername:UILabel = popUpView!.viewWithTag(10) as! UILabel
        labelUsername.text = "@\(user.username!)"
        let labelHeader:UILabel = popUpView!.viewWithTag(12) as! UILabel
        
        let actionButton:UIButton = popUpView!.viewWithTag(11) as! UIButton
        
        if Utils().isUserAFriend(user){
            actionButton.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            labelHeader.text = NSLocalizedString("REMOVE A FRIEND", comment : "REMOVE A FRIEND")
        }
        else{
            actionButton.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
            labelHeader.text = NSLocalizedString("ADD A FRIEND", comment : "ADD A FRIEND")
        }
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.4
                self.popUpView!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    
    func leavePopUp(){
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.overlayView!.alpha = 0
                self.popUpView!.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }) { (finished) -> Void in
                self.popUpView!.transform =  CGAffineTransformMakeScale(0, 0)
        }
    }
    
    
    func addFriendFromPopUp(){
        (self.popUpView!.viewWithTag(13) as! UIActivityIndicatorView).startAnimating()
        (self.popUpView!.viewWithTag(11) as! UIButton).hidden = true
        
        if userPopUp != nil {
            
            if Utils().isUserAFriend(userPopUp!){
                
                Utils().removeFriend(userPopUp!.objectId!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                    (self.popUpView!.viewWithTag(13) as! UIActivityIndicatorView).stopAnimating()
                    (self.popUpView!.viewWithTag(11) as! UIButton).hidden = false
                    if task.error != nil{
                        
                    }
                    else{
                        (self.popUpView!.viewWithTag(11) as! UIButton).setImage(UIImage(named: "add_friends_icon_pop_up"), forState: UIControlState.Normal)
                        (self.popUpView!.viewWithTag(12) as! UILabel).text = NSLocalizedString("ADD A FRIEND", comment : "ADD A FRIEND")
                    }
                    
                    return nil
                })
            }
            else{
                //Not a friend, friend him
                Utils().addFriend(self.userPopUp!.objectId!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                    (self.popUpView!.viewWithTag(13) as! UIActivityIndicatorView).stopAnimating()
                    (self.popUpView!.viewWithTag(11) as! UIButton).hidden = false
                    if task.error != nil{
                        
                    }
                    else{
                        Mixpanel.sharedInstance().track("Add Friend", properties : ["screen" : "big_react"])
                        
                        (self.popUpView!.viewWithTag(11) as! UIButton).setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
                        (self.popUpView!.viewWithTag(12) as! UILabel).text = NSLocalizedString("REMOVE A FRIEND", comment : "REMOVE A FRIEND")
                    }
                    
                    return nil
                    
                })
                
            }
            
        }
        
    }
    
    
    
    func sendPushNewComment(isPublic : Bool) -> BFTask{
        
        var task = BFTaskCompletionSource()
        
        let userPiki:PFUser = self.mainPiki!["user"] as! PFUser
        
        var recipients:Array<String> = Array<String>()
        if !isPublicPleek{
            recipients = self.mainPiki!["recipients"] as! Array<String>
        }
        
        PFCloud.callFunctionInBackground("sendPushNewComment", withParameters:["recipients":recipients, "isPublic" : isPublic, "pikiId" : self.mainPiki!.objectId!, "ownerId" : userPiki.objectId!]) {
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
    
    
    
    
    func leaveTuto(){
        
        overlayTuto.removeFromSuperview()
        
    }
    
    
    // MARK: Utils
    
    func removeReactFromList(react : AnyObject){
        
        var position:Int = 0
        var j:Int = 0
        
        if react.isKindOfClass(PFObject){
            for reactIncrement in self.pikiReacts{
                
                if reactIncrement.isKindOfClass(PFObject){
                    
                    if reactIncrement.objectId == react.objectId{
                        position = j
                    }
                }
                
                j++
            }
        }
        else{
            for reactIncrement in self.pikiReacts{
                
                if !reactIncrement.isKindOfClass(PFObject){
                    
                    if (reactIncrement["id"] as! Int) == (react["id"] as! Int){
                        position = j
                    }
                }
                
                j++
            }
        }
        
        
        
        
        self.pikiReacts.removeAtIndex(position)
        self.collectionView!.deleteItemsAtIndexPaths([NSIndexPath(forItem: position + 1, inSection: 1)])
        
    }
    
    
    // MARK: More Pleek
    
    func morePeekee(){
        
        
        if objc_getClass("UIAlertController") != nil {
            
            var alert = UIAlertController(title: NSLocalizedString("More", comment : "More"),
                message: NSLocalizedString("More actions for this Pleek", comment : "More actions for this Pleek"), preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: LocalizedString("Cancel"), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                
            }))
            if !isPublicPleek{
                alert.addAction(UIAlertAction(title:LocalizedString("Show Recipients"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    self.performSegueWithIdentifier("showRecipients", sender: self)
                }))
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Report this Pleek", comment : "Report this Pleek"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                PFCloud.callFunctionInBackground("reportPiki ",
                    withParameters: ["pikiId" : self.mainPiki!.objectId!], block: { (result, error) -> Void in
                        if error != nil{
                            let alert = UIAlertView(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("Problem while reporting this Pleek. Please try again later", comment :"Problem while reporting this Pleek. Please try again later") ,
                                delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                            alert.show()
                        }
                        else{
                            let alert = UIAlertView(title: "Confirmation", message: NSLocalizedString( "This Pleek has been reported. Thank you.", comment :  "This Pleek has been reported. Thank you."),
                                delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                })
            }))
            
            
            alert.popoverPresentationController?.sourceView = self.view
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
            var actionSheet:UIActionSheet = UIActionSheet(title: NSLocalizedString("More", comment : "More"),
                delegate: self,
                cancelButtonTitle: LocalizedString("Cancel"),
                destructiveButtonTitle: nil,
                otherButtonTitles: LocalizedString("Show Recipients"), NSLocalizedString("Report this Pleek", comment : "Report this Pleek"))
            actionSheet.showInView(self.view)
            println("UIAlertController can NOT be instantiated")
            
            //make and use a UIAlertView
        }
        
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
        case 1:
            self.performSegueWithIdentifier("showRecipients", sender: self)
        case 2:
            PFCloud.callFunctionInBackground("reportPiki ",
                withParameters: ["pikiId" : self.mainPiki!.objectId!], block: { (result, error) -> Void in
                    if error != nil{
                        let alert = UIAlertView(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("Problem while reporting this Pleek. Please try again later", comment :"Problem while reporting this Pleek. Please try again later") ,
                            delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                        alert.show()
                    }
                    else{
                        let alert = UIAlertView(title: LocalizedString("Confirmation"), message: NSLocalizedString( "This Pleek has been reported. Thank you.", comment :  "This Pleek has been reported. Thank you."),
                            delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                        alert.show()
                    }
            })
        default:
            println("Do nothing")
        }
    }
    
    
    
    //MARK: Share View
    
    func showShareView(isMozaic : Bool){
        
        
        var isPleekPublic:Bool? = self.mainPiki!["isPublic"] as? Bool
        
        if isPleekPublic == nil{
            isPleekPublic = false
        }
        
        
        shareOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        shareOverlay!.backgroundColor = UIColor.blackColor()
        shareOverlay!.alpha = 0.8
        self.view.addSubview(shareOverlay!)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        bottomShareView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 254, width: self.view.frame.width, height: 254))
        bottomShareView!.backgroundColor = UIColor.whiteColor()
        bottomShareView!.alpha = 0.94
        self.view.addSubview(bottomShareView!)
        bottomShareView!.transform = CGAffineTransformMakeTranslation(0, bottomShareView!.frame.height)
        
        var shareTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bottomShareView!.frame.width, height: 50))
        shareTitleLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        shareTitleLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1)
        shareTitleLabel.text = NSLocalizedString("COLLAGE", comment : "COLLAGE")
        shareTitleLabel.textAlignment = NSTextAlignment.Center
        bottomShareView!.addSubview(shareTitleLabel)
        
        var separatorLine = UIView(frame: CGRect(x: 0, y: 50, width: bottomShareView!.frame.width, height: 2))
        separatorLine.backgroundColor = UIColor.whiteColor()
        bottomShareView!.addSubview(separatorLine)
        
        var buttonQuit = UIButton(frame: CGRect(x: bottomShareView!.frame.width - 60, y: 0, width: 40, height: 50))
        buttonQuit.setImage(UIImage(named : "quit_share"), forState: UIControlState.Normal)
        buttonQuit.addTarget(self, action: Selector("quitShare"), forControlEvents: UIControlEvents.TouchUpInside)
        bottomShareView!.addSubview(buttonQuit)
        
        // SMS Share
        if isMozaic || !isPleekPublic! || !Utils().facebookMessengerActivated{
            let shareSMSButton = UIButton(frame: CGRect(x: 30, y: 79, width: 64, height: 64))
            shareSMSButton.setImage(UIImage(named: "sms_share_icon"), forState: UIControlState.Normal)
            shareSMSButton.addTarget(self, action: Selector("shareSms"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareSMSButton)
            
            
            //Twitter Share
            //let shareTwitterButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width/2 - 32, y: 79, width: 64, height: 64))
            let shareTwitterButton = UIButton(frame: CGRect(x: 30, y: 168, width: 64, height: 64))
            shareTwitterButton.setImage(UIImage(named: "twitter_share_icon"), forState: UIControlState.Normal)
            shareTwitterButton.addTarget(self, action: Selector("shareTwitter"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareTwitterButton)
            
            // Save Share
            let shareSaveButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width/2 - 32, y: 168, width: 64, height: 64))
            shareSaveButton.setImage(UIImage(named: "save_share_icon"), forState: UIControlState.Normal)
            shareSaveButton.addTarget(self, action: Selector("shareSave"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareSaveButton)
        }
        else{
            
            var tapGestureSendGifBack:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("shareMessenger"))
            let backMessengerButtonView:UIImageView = UIImageView(frame: CGRect(x: 19, y: 48, width: 85, height: 100))
            backMessengerButtonView.image = UIImage(named: "send_gif")
            backMessengerButtonView.addGestureRecognizer(tapGestureSendGifBack)
            bottomShareView!.addSubview(backMessengerButtonView)
            
            let messengerButtonView = UIView(frame: CGRect(x: 30, y: 79, width: 64, height: 64))
            messengerButtonView.backgroundColor = UIColor.clearColor()
            bottomShareView!.addSubview(messengerButtonView)
            
            //var widthMessengerButton:CGFloat = 64
            //var buttonMessenger:UIButton = FBSDKMessengerShareButton.rectangularButtonWithStyle(FBSDKMessengerShareButtonStyle.Blue)
            //buttonMessenger.frame.size = CGSize(width: 64, height: 64)
            var buttonMessenger:UIButton = FBSDKMessengerShareButton.circularButtonWithStyle(FBSDKMessengerShareButtonStyle.Blue, width: 64)
            buttonMessenger.backgroundColor = UIColor.clearColor()
            buttonMessenger.addTarget(self, action: Selector("shareMessenger"), forControlEvents: UIControlEvents.TouchUpInside)
            messengerButtonView.addSubview(buttonMessenger)
            
            
            
            let shareSMSButton = UIButton(frame: CGRect(x: 30, y: 168, width: 64, height: 64))
            shareSMSButton.setImage(UIImage(named: "sms_share_icon"), forState: UIControlState.Normal)
            shareSMSButton.addTarget(self, action: Selector("shareSms"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareSMSButton)
            
            
            
            let shareTwitterButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width/2 - 32, y: 168, width: 64, height: 64))
            shareTwitterButton.setImage(UIImage(named: "twitter_share_icon"), forState: UIControlState.Normal)
            shareTwitterButton.addTarget(self, action: Selector("shareTwitter"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareTwitterButton)
            
            // Save Share
            let shareSaveButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width - 98, y: 168, width: 64, height: 64))
            shareSaveButton.setImage(UIImage(named: "save_share_icon"), forState: UIControlState.Normal)
            shareSaveButton.addTarget(self, action: Selector("shareSave"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareSaveButton)
        }
        
        //Facebook Share
        //let shareFacebookButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width - 98, y: 79, width: 64, height: 64))
        let shareFacebookButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width/2 - 32, y: 79, width: 64, height: 64))
        shareFacebookButton.setImage(UIImage(named: "facebook_share_icon"), forState: UIControlState.Normal)
        shareFacebookButton.addTarget(self, action: Selector("shareFacebook"), forControlEvents: UIControlEvents.TouchUpInside)
        bottomShareView!.addSubview(shareFacebookButton)
        
        // Instagram Share
        //let shareInstagramButton = UIButton(frame: CGRect(x: 30, y: 168, width: 64, height: 64))
        let shareInstagramButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width - 98, y: 79, width: 64, height: 64))
        shareInstagramButton.setImage(UIImage(named: "instagram_share_icon"), forState: UIControlState.Normal)
        shareInstagramButton.addTarget(self, action: Selector("shareInstagram"), forControlEvents: UIControlEvents.TouchUpInside)
        bottomShareView!.addSubview(shareInstagramButton)
        
        
        
        let heightContainer:CGFloat = (self.view.frame.height - bottomShareView!.frame.height) - 30
        let maxWidth:CGFloat = self.view.frame.width - 30
        
        var realSizeContainer:CGFloat!
        if heightContainer > maxWidth{
            realSizeContainer = maxWidth
        }
        else{
            realSizeContainer = heightContainer
        }
        
        imageContainerView = UIView(frame: CGRect(x: self.view.frame.width/2 - realSizeContainer/2, y: (self.view.frame.height - bottomShareView!.frame.height)/2 - realSizeContainer/2, width: realSizeContainer, height: realSizeContainer))
        imageContainerView!.layer.borderColor = UIColor.whiteColor().CGColor
        imageContainerView!.layer.cornerRadius = 4
        imageContainerView!.clipsToBounds = true
        imageContainerView!.backgroundColor = UIColor.blackColor()
        imageContainerView!.layer.borderWidth = 2
        imageContainerView!.hidden = true
        self.view.addSubview(imageContainerView!)
        
        
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.bottomShareView!.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                println("finished printing share view")
                self.shareOverlay!.hidden = false
                self.imageContainerView!.hidden = false
        }
        
    }
    
    func quitShare(){
        share1vs1View = nil
        
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.bottomShareView!.transform = CGAffineTransformMakeTranslation(0, self.bottomShareView!.frame.height)
            }) { (finished) -> Void in
                self.shareOverlay!.removeFromSuperview()
                self.shareOverlay = nil
                self.bottomShareView!.removeFromSuperview()
                self.bottomShareView = nil
                self.imageContainerView!.hidden = true
                self.setNeedsStatusBarAppearanceUpdate()
        }
        
        
    }
    
    func shareInstagram(){
        
        
        
        
        let instagramURL : NSURL = NSURL(string: "instagram://app")!
        
        if UIApplication.sharedApplication().canOpenURL(instagramURL){
            
            var image:UIImage?
            
            
            if share1vs1View != nil{
                share1vs1View!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(share1vs1View!)
                
                let scale:CGFloat = imageContainerView!.frame.height / share1vs1View!.frame.height
                share1vs1View!.transform = CGAffineTransformMakeScale(scale, scale)
                
                Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Instagram", "is_mozaic" : false])
            }
            else if viewToBuildImage != nil{
                viewToBuildImage!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(viewToBuildImage!)
                
                let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
                viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
                
                Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Instagram", "is_mozaic" : true])
            }
            
            
            
            
            var fileManager:NSFileManager = NSFileManager()
            
            if fileManager.fileExistsAtPath("\(NSTemporaryDirectory())_shareInstagram.igo"){
                var errPath : NSError? = nil
                if !fileManager.removeItemAtPath("\(NSTemporaryDirectory())_shareInstagram.igo", error: &errPath){
                    //Handle error
                }
                else{
                    var imageData:NSData = UIImageJPEGRepresentation(image, 1.0)
                    if imageData.writeToFile("\(NSTemporaryDirectory())_shareInstagram.igo", atomically: true){
                        
                        self.documentInteractionController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_shareInstagram.igo")!)
                        let url =  NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_shareInstagram.igo")!
                        println("URL : \(url.description)")
                        self.documentInteractionController!.UTI = "com.instagram.exclusivegram"
                        self.documentInteractionController!.annotation = ["InstagramCaption" : LocalizedString("Awesome friends mozaic created with @Pleekapp #pleek")]
                        
                        self.documentInteractionController!.presentOpenInMenuFromRect(CGRectMake(0,0,0,0), inView: self.view, animated: true)
                        
                        
                        
                    }
                }
            }
            else{
                var imageData:NSData = UIImageJPEGRepresentation(image, 1.0)
                if imageData.writeToFile("\(NSTemporaryDirectory())_shareInstagram.igo", atomically: true){
                    
                    self.documentInteractionController  = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_shareInstagram.igo")!)
                    let url =  NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_shareInstagram.igo")!
                    println("URL : \(url.description)")
                    self.documentInteractionController!.UTI = "com.instagram.exclusivegram"
                    self.documentInteractionController!.annotation = ["InstagramCaption" : LocalizedString("Awesome friends mozaic created with @Pleekapp #pleek")]
                    
                    self.documentInteractionController!.presentOpenInMenuFromRect(CGRectMake(0,0,0,0), inView: self.view, animated: true)
                    
                    
                    
                }
            }
        }
        else{
            
        }
    }
    
    func shareTwitter(){
        var okTwitter :Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
        
        if okTwitter{
            
            
            var composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            var image:UIImage?
            
            if share1vs1View != nil{
                share1vs1View!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(share1vs1View!)
                
                let scale:CGFloat = imageContainerView!.frame.height / share1vs1View!.frame.height
                share1vs1View!.transform = CGAffineTransformMakeScale(scale, scale)
                
                Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Twitter", "is_mozaic" : false])
            }
            else if viewToBuildImage != nil{
                viewToBuildImage!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(viewToBuildImage!)
                
                let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
                viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
                
                Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Twitter", "is_mozaic" : true])
            }
            
            
            
            composer.addImage(image!)
            composer.setInitialText(LocalizedString("Awesome friends mozaic created with @Pleekapp"))
            composer.addURL(NSURL(string: Utils().websiteUrl))
            
            composer.completionHandler = {
                (result:SLComposeViewControllerResult) in
                println("Result : \(result)")
            }
            self.presentViewController(composer, animated: true, completion: nil)
            
        }
        else{
            
        }
    }
    
    func shareFacebook(){
        
        var image:UIImage?
        
        if share1vs1View != nil{
            share1vs1View!.transform = CGAffineTransformIdentity
            
            image = Utils().imageWithView(share1vs1View!)
            
            let scale:CGFloat = imageContainerView!.frame.height / share1vs1View!.frame.height
            share1vs1View!.transform = CGAffineTransformMakeScale(scale, scale)
            
            Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Facebook", "is_mozaic" : false])
        }
        else if viewToBuildImage != nil{
            viewToBuildImage!.transform = CGAffineTransformIdentity
            
            image = Utils().imageWithView(viewToBuildImage!)
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            
            Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Facebook", "is_mozaic" : true])
        }
        
        var photo:FBSDKSharePhoto = FBSDKSharePhoto(image: image, userGenerated: true)
        var content:FBSDKSharePhotoContent = FBSDKSharePhotoContent()
        content.photos = [photo]
        
        
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
        
        
    }
    
    func shareMessenger(){
        println("Share on Messenger")
        var pleekImage:UIImage?
        var reactImage:UIImage?
        
        if let reactShare = self.reactToShare{
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            Utils().getImagePleekOrReact(self.mainPiki!).continueWithBlock { (task : BFTask!) -> AnyObject! in
                if task.error != nil{
                    //Error
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    println("Error Image pleek: \(task.error)")
                }
                else{
                    pleekImage = task.result as? UIImage
                    
                    Utils().getImagePleekOrReact(reactShare).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                        if task.error != nil{
                            println("Error react Image: \(task.error)")
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        }
                        else{
                            
                            reactImage = task.result as? UIImage
                            
                            Utils().buildGifShareMessenger(pleekImage!, reactImage: reactImage!, otherReact: nil).continueWithBlock({ (taskGif : BFTask!) -> AnyObject! in
                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                                
                                if taskGif.error != nil{
                                    //Error
                                    
                                }
                                else{
                                    Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Messenger", "is_mozaic" : false])
                                    var urlGif : NSURL = (taskGif.result as! NSURL)
                                    Utils().shareFBMessenger((taskGif.result as! NSURL).path!, pleekId: self.mainPiki!.objectId!, context : nil)
                                }
                                
                                return nil
                                
                            })
                            
                        }
                        
                        return nil
                    })
                }
                
                return nil
            }
        }
        
        /*if indexPathBig != nil{
        
        
        
        }
        else if self.gifURLLastReact != nil{
        self.quitShareMessenger()
        
        Utils().shareFBMessenger(self.gifURLLastReact!.path!, pleekId: self.mainPiki!.objectId!, context : (UIApplication.sharedApplication().delegate as! AppDelegate)._replyMessengerContext)
        }*/
        
        
        
        
    }
    
    func shareSave(){
        if viewToBuildImage != nil || share1vs1View != nil{
            
            Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Save"])
            
            var image:UIImage?
            
            if share1vs1View != nil{
                share1vs1View!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(share1vs1View!)
                
                let scale:CGFloat = imageContainerView!.frame.height / share1vs1View!.frame.height
                share1vs1View!.transform = CGAffineTransformMakeScale(scale, scale)
            }
            else if viewToBuildImage != nil{
                viewToBuildImage!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(viewToBuildImage!)
                
                let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
                viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            }
            
            
            let library = ALAssetsLibrary()
            library.writeImageToSavedPhotosAlbum(image!.CGImage, orientation: ALAssetOrientation.Up) { (url, error) -> Void in
                if error != nil {
                    let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Error while saving your photo"),
                        delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                    alert.show()
                }
                else{
                    let alert = UIAlertView(title: LocalizedString("Saved!"), message: LocalizedString("Your photo has been saved on your library"),
                        delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                    alert.show()
                }
            }
            
        }
    }
    
    func shareSms(){
        
        Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "SMS"])
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        var messageController:MFMessageComposeViewController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.body = String(format: NSLocalizedString("SendInvitSMS", comment : ""), Utils().shareAppUrl)
        
        if MFMessageComposeViewController.respondsToSelector(Selector("canSendAttachments")){
            
            var image:UIImage?
            
            if share1vs1View != nil{
                share1vs1View!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(share1vs1View!)
                
                let scale:CGFloat = imageContainerView!.frame.height / share1vs1View!.frame.height
                share1vs1View!.transform = CGAffineTransformMakeScale(scale, scale)
            }
            else if viewToBuildImage != nil{
                viewToBuildImage!.transform = CGAffineTransformIdentity
                
                image = Utils().imageWithView(viewToBuildImage!)
                
                let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
                viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            }
            
            let attachementsData:NSData = UIImageJPEGRepresentation(image!, 1.0)
            
            messageController.addAttachmentData(attachementsData, typeIdentifier: "public.data", filename: "mymozaic.jpg")
        }
        
        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
        
        
    }
    
    func buildViewShareBackButton(){
        
        
        var nbReacts:Int? = self.pikiReacts.count
        var arrayImageViewReact:Array<UIImageView> = Array<UIImageView>()
        
        if nbReacts == nil{
            nbReacts = 0
        }
        
        /*for react in self.pikiReacts{
        if !react.isKindOfClass(PFObject){
        nbReacts!++
        }
        }*/
        
        if nbReacts! > 5{
            
            buildShareView()
            
            
            let scale:CGFloat = 60 / viewToBuildImage!.frame.height
            
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            viewToBuildImage!.frame.origin = CGPoint(x: 0, y: 0)
            backShareButton!.addSubview(viewToBuildImage!)
            backShareButton!.hidden = false
        }
        else{
            backShareButton!.hidden = true
        }
        
    }
    
    
    
    func buildViewSharePopUp(){
        
        
        
        
        
        var nbReacts:Int? = self.pikiReacts.count
        var arrayImageViewReact:Array<UIImageView> = Array<UIImageView>()
        
        if nbReacts == nil{
            nbReacts = 0
        }
        
        /*for react in self.pikiReacts{
        if !react.isKindOfClass(PFObject){
        nbReacts!++
        }
        }*/
        
        if nbReacts! > 5{
            showShareView(true)
            
            
            buildShareView()
            
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            viewToBuildImage!.frame.origin = CGPoint(x: 0, y: 0)
            imageContainerView!.addSubview(viewToBuildImage!)
        }
        else{
            if Utils().iOS8{
                var alert = UIAlertController(title: NSLocalizedString("Share", comment : "Share"), message: NSLocalizedString("AlertNotEnoughReact", comment : "Sorry but you need to have at least 6 answers to this Pleek in order to create your mozaic! Try to post some answers yourself to create your own mozaic!"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    self.sendSMSToContacts()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                var alertView = UIAlertView(title: NSLocalizedString("Share", comment : "Share"),
                    message: NSLocalizedString("AlertNotEnoughReact", comment : "Sorry but you need to have at least 6 answers to this Pleek in order to create your mozaic! Try to post some answers yourself to create your own mozaic!"),
                    delegate: self, cancelButtonTitle: NSLocalizedString("No", comment : "No"),
                    otherButtonTitles: NSLocalizedString("Yes", comment : "Yes"))
                
                alertView.tag = 1
                alertView.show()
            }
            
        }
        
    }
    
    
    func buildShareView(){
        
        
        var nbReacts:Int? = self.pikiReacts.count
        var arrayImageViewReact:Array<UIImageView> = Array<UIImageView>()
        
        if nbReacts == nil{
            nbReacts = 0
        }
        
        /*for react in self.pikiReacts{
        if !react.isKindOfClass(PFObject){
        nbReacts!++
        }
        }*/
        
        //MainSHare View
        viewToBuildImage = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        viewToBuildImage!.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        
        //Main Pleek image view
        var viewMainPeekeeContainer = UIView(frame: CGRect(x: 250, y: 250, width: 500, height: 500))
        viewMainPeekeeContainer.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        viewToBuildImage!.addSubview(viewMainPeekeeContainer)
        
        if nbReacts > 5 && nbReacts < 11{
            viewMainPeekeeContainer.frame = CGRect(x: 0, y: 0, width: 750, height: 750)
        }
        else if nbReacts > 23 && nbReacts < 44{
            viewMainPeekeeContainer.frame = CGRect(x: 0, y: 0, width: 750, height: 750)
        }
        
        
        var mainPikiView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewMainPeekeeContainer.frame.width, height: viewMainPeekeeContainer.frame.height))
        viewMainPeekeeContainer.addSubview(mainPikiView)
        
        //Shadow for bottom button
        var stretchShadowImage:UIImage = UIImage(named: "shadow_piki")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowImageView = UIImageView(frame: CGRect(x: 0, y: viewMainPeekeeContainer.frame.height - 115 , width: viewMainPeekeeContainer.frame.width, height: 115))
        shadowImageView.image = stretchShadowImage
        shadowImageView.hidden = true
        viewMainPeekeeContainer.addSubview(shadowImageView)
        
        //Icon Pleek
        var iconPeekee = UIImageView(frame: CGRect(x: 15, y: viewMainPeekeeContainer.frame.height - 60, width: 50, height: 50))
        iconPeekee.layer.cornerRadius = 15
        iconPeekee.clipsToBounds = true
        iconPeekee.image = UIImage(named: "app_icon")
        viewMainPeekeeContainer.addSubview(iconPeekee)
        
        //User label
        let userMainPeekee = self.mainPiki!["user"] as! PFUser
        var userLabel = UILabel(frame: CGRect(x: iconPeekee.frame.origin.x + iconPeekee.frame.width + 20, y: iconPeekee.frame.origin.y, width: viewMainPeekeeContainer.frame.width - (iconPeekee.frame.origin.x + iconPeekee.frame.width + 20 + 10), height: 30))
        userLabel.font = UIFont(name: Utils().customFontSemiBold, size: 24.0)
        userLabel.textColor = UIColor.whiteColor()
        let onPeekeeFormat = String(format: NSLocalizedString("%@ on Pleek", comment : "%@ on Pleek"), userMainPeekee.username!)
        userLabel.text = onPeekeeFormat
        viewMainPeekeeContainer.addSubview(userLabel)
        
        //Label when
        var creationDate:NSDate = self.mainPiki!.createdAt!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - h:mm a" // superset of OP's format
        let str = dateFormatter.stringFromDate(creationDate)
        
        var labelWhen = UILabel(frame: CGRect(x: iconPeekee.frame.origin.x + iconPeekee.frame.width + 20, y: iconPeekee.frame.origin.y + 30, width: viewMainPeekeeContainer.frame.width - (iconPeekee.frame.origin.x + iconPeekee.frame.width + 20 + 10), height: 20))
        labelWhen.font = UIFont(name: Utils().customFontNormal, size: 18.0)
        labelWhen.textColor = UIColor.whiteColor()
        labelWhen.text = "\(str)"
        viewMainPeekeeContainer.addSubview(labelWhen)
        
        //PeekeeInfos VIew
        var peekeeInfosView = UIView(frame: CGRect(x: 0, y: 750, width: 250, height: 250))
        peekeeInfosView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        viewToBuildImage!.addSubview(peekeeInfosView)
        
        var labelNbReply:UILabel = UILabel(frame: CGRect(x: 15, y: 60, width: peekeeInfosView.frame.width - 30, height: peekeeInfosView.frame.height - 40))
        labelNbReply.numberOfLines = 2
        labelNbReply.adjustsFontSizeToFitWidth = true
        labelNbReply.font = UIFont(name: Utils().customFontSemiBold, size: 36.0)
        labelNbReply.textColor = UIColor.whiteColor()
        let repliesFormat = String(format: NSLocalizedString("%d+ replies on the app", comment : "%d+ replies on the app"), nbReacts!)
        labelNbReply.text = repliesFormat
        labelNbReply.textAlignment = NSTextAlignment.Center
        peekeeInfosView.addSubview(labelNbReply)
        
        //Apple Icon
        var appleIcon = UIImageView(frame: CGRect(x: 89, y: 195, width: 20, height: 24))
        appleIcon.image = UIImage(named: "apple_icon")
        //peekeeInfosView.addSubview(appleIcon)
        
        //Android Icon
        var androidIcon = UIImageView(frame: CGRect(x: 137, y: 195, width: 20, height: 24))
        androidIcon.image = UIImage(named: "android_icon")
        //peekeeInfosView.addSubview(androidIcon)
        
        //Reply Icon
        var replyIcon = UIImageView(frame: CGRect(x: 0, y: 50, width: peekeeInfosView.frame.width, height: 40))
        replyIcon.contentMode = UIViewContentMode.Center
        replyIcon.image = UIImage(named: "app_icon")
        peekeeInfosView.addSubview(replyIcon)
        
        //Set the image
        if self.mainPekeeImage != nil{
            mainPikiView.image = self.mainPekeeImage
            
            
            if self.mainPiki!["video"] != nil{
                var playImage = UIImageView(frame: CGRect(x: 0, y: 0, width: mainPikiView.frame.width/3, height: mainPikiView.frame.width/3))
                playImage.center = mainPikiView.center
                playImage.image = UIImage(named: "read_video_icon")
                playImage.contentMode = UIViewContentMode.ScaleAspectFit
                viewMainPeekeeContainer.addSubview(playImage)
            }
        }
        else{
            if self.mainPiki!["photo"] != nil{
                var filePeekee:PFFile = mainPiki!["photo"] as! PFFile
                filePeekee.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if data != nil{
                        mainPikiView.image = UIImage(data: data!)
                    }
                })
            }
            else{
                var filePeekee:PFFile = mainPiki!["previewImage"] as! PFFile
                filePeekee.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if data != nil{
                        mainPikiView.image = UIImage(data: data!)
                        
                        var playImage = UIImageView(frame: CGRect(x: 0, y: 0, width: mainPikiView.frame.width/3, height: mainPikiView.frame.width/3))
                        playImage.center = mainPikiView.center
                        playImage.image = UIImage(named: "read_video_icon")
                        playImage.contentMode = UIViewContentMode.ScaleAspectFit
                        viewMainPeekeeContainer.addSubview(playImage)
                    }
                })
            }
        }
        
        if nbReacts! > 5 && nbReacts! < 11{
            for i in 0...5{
                
                if i < 4{
                    var imageViewReact = UIImageView(frame: CGRect(x: 750, y: 0 + (250 * i), width: 250, height: 250))
                    viewToBuildImage!.addSubview(imageViewReact)
                    arrayImageViewReact.append(imageViewReact)
                }
                else{
                    if i == 5{
                        var imageViewReact = UIImageView(frame: CGRect(x: 500, y: 750, width: 250, height: 250))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 250, y: 750, width: 250, height: 250))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    
                }
                
                
            }
        }
        else if nbReacts! > 10 && nbReacts! < 24 {
            for i in 0...10{
                
                if i < 2{
                    var imageViewReact = UIImageView(frame: CGRect(x: 0, y: 250 + (250 * i), width: 250, height: 250))
                    viewToBuildImage!.addSubview(imageViewReact)
                    arrayImageViewReact.append(imageViewReact)
                }
                else if i > 1 && i < 6{
                    var imageViewReact = UIImageView(frame: CGRect(x: 0 + (250 * (i - 2)), y: 0, width: 250, height: 250))
                    viewToBuildImage!.addSubview(imageViewReact)
                    arrayImageViewReact.append(imageViewReact)
                }
                else if i > 5 && i < 9{
                    var imageViewReact = UIImageView(frame: CGRect(x: 750 , y: 250 + (250 * (i - 6)), width: 250, height: 250))
                    viewToBuildImage!.addSubview(imageViewReact)
                    arrayImageViewReact.append(imageViewReact)
                }
                else{
                    var imageViewReact = UIImageView(frame: CGRect(x: 500 - (250 * (i - 9)), y: 750, width: 250, height: 250))
                    viewToBuildImage!.addSubview(imageViewReact)
                    arrayImageViewReact.append(imageViewReact)
                    
                }
                
                
            }
        }
        else if nbReacts! > 23 && nbReacts! < 44{
            for i in 1...24{
                
                if i < 13{
                    
                    var divider:Float = roundf(Float(i)/2) - 1
                    var positionYMore : Float = 125 * divider
                    
                    if i%2 == 0{
                        var imageViewReact = UIImageView(frame: CGRect(x: 250 + CGFloat(positionYMore), y: 750, width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 250 + CGFloat(positionYMore), y: 875, width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    
                    
                }
                else if i > 12 && i < 25{
                    var divider:Float = roundf(Float(i)/2) - 7
                    var positionYMore : Float = 125 * divider
                    
                    
                    if i%2 == 0{
                        var imageViewReact = UIImageView(frame: CGRect(x: 750, y: 0 + CGFloat(positionYMore), width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 875, y: 0 + CGFloat(positionYMore), width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                }
                
            }
        }
        else if nbReacts! > 43{
            for i in 1...44{
                
                if i < 13{
                    
                    var divider:Float = roundf(Float(i)/2)
                    var positionYMore : Float = 125 * divider
                    
                    if i%2 == 0{
                        var imageViewReact = UIImageView(frame: CGRect(x: 0, y: 750 - CGFloat(positionYMore), width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 125, y: 750 - CGFloat(positionYMore), width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    
                    
                }
                else if i > 12 && i < 25{
                    var divider:Float = roundf(Float(i)/2) - 7
                    var positionYMore : Float = 125 * divider
                    
                    if i%2 == 0{
                        var imageViewReact = UIImageView(frame: CGRect(x: 250 + CGFloat(positionYMore), y: 0, width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 250 + CGFloat(positionYMore), y: 125, width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                }
                else if i > 24 && i < 37{
                    var divider:Float = roundf(Float(i)/2) - 13
                    var positionYMore : Float = 125 * divider
                    
                    if i%2 == 0{
                        var imageViewReact = UIImageView(frame: CGRect(x: 750, y: 250 + CGFloat(positionYMore), width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 875, y: 250 + CGFloat(positionYMore), width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                }
                else{
                    var divider:Float = roundf(Float(i)/2) - 19
                    var positionYMore : Float = 125 * divider
                    
                    if i%2 == 0{
                        var imageViewReact = UIImageView(frame: CGRect(x: 625 - CGFloat(positionYMore), y: 750 , width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                    else{
                        var imageViewReact = UIImageView(frame: CGRect(x: 625 - CGFloat(positionYMore), y: 875, width: 125, height: 125))
                        viewToBuildImage!.addSubview(imageViewReact)
                        arrayImageViewReact.append(imageViewReact)
                    }
                }
                
            }
            
            
        }
        else if nbReacts! < 6{
            
            if Utils().iOS8{
                var alert = UIAlertController(title: NSLocalizedString("Share", comment : "Share"), message: NSLocalizedString("AlertNotEnoughReact", comment : "Sorry but you need to have at least 6 answers to this Pleek in order to create your mozaic! Try to post some answers yourself to create your own mozaic!"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    self.sendSMSToContacts()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                var alertView = UIAlertView(title: NSLocalizedString("Share", comment : "Share"),
                    message: NSLocalizedString("AlertNotEnoughReact", comment : "Sorry but you need to have at least 6 answers to this Pleek in order to create your mozaic! Try to post some answers yourself to create your own mozaic!"),
                    delegate: self, cancelButtonTitle: NSLocalizedString("No", comment : "No"),
                    otherButtonTitles: NSLocalizedString("Yes", comment : "Yes"))
                
                alertView.tag = 1
                alertView.show()
            }
            
        }
        
        var position:Int = 0
        var nbReactDone:Int = 0
        
        
        for react in self.pikiReacts {
            
            if arrayImageViewReact.count > 0{
                
                
                if react.isKindOfClass(PFObject){
                    
                    let reactObject:PFObject = react as! PFObject
                    if reactObject["photo"] != nil {
                        
                        let photoFile:PFFile = reactObject["photo"] as! PFFile
                        photoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if error == nil{
                                if arrayImageViewReact.count > 0{
                                    let imageViewNow:UIImageView = arrayImageViewReact.removeAtIndex(arrayImageViewReact.count - 1)
                                    imageViewNow.image = UIImage(data: data!)
                                    nbReactDone++
                                }
                                
                            }
                            else{
                                
                            }
                        })
                    }
                    else{
                        let photoFile:PFFile = reactObject["previewImage"] as! PFFile
                        photoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if error == nil{
                                if arrayImageViewReact.count > 0{
                                    let imageViewNow:UIImageView = arrayImageViewReact.removeAtIndex(arrayImageViewReact.count - 1)
                                    imageViewNow.image = UIImage(data: data!)
                                    
                                    var playImage = UIImageView(frame: CGRect(x: 0, y: 0, width: imageViewNow.frame.width/3, height: imageViewNow.frame.width/3))
                                    playImage.center = imageViewNow.center
                                    playImage.image = UIImage(named: "play_answer")
                                    self.viewToBuildImage!.addSubview(playImage)
                                    nbReactDone++
                                }
                            }
                            else{
                                
                            }
                        })
                    }
                    
                }
                else{
                    
                    var pikiInfos:[String : AnyObject] = react as! [String : AnyObject]
                    
                    
                    if pikiInfos["photo"] != nil {
                        
                        if arrayImageViewReact.count > 0{
                            
                            let imageViewNow:UIImageView = arrayImageViewReact.removeAtIndex(arrayImageViewReact.count - 1)
                            imageViewNow.image = pikiInfos["photo"] as? UIImage
                            nbReactDone++
                        }
                        
                        
                    }
                    else{
                        if arrayImageViewReact.count > 0{
                            
                            let imageViewNow:UIImageView = arrayImageViewReact.removeAtIndex(arrayImageViewReact.count - 1)
                            imageViewNow.image = pikiInfos["previewImage"] as? UIImage
                            
                            var playImage = UIImageView(frame: CGRect(x: 0, y: 0, width: imageViewNow.frame.width/3, height: imageViewNow.frame.width/3))
                            playImage.center = imageViewNow.center
                            playImage.image = UIImage(named: "play_answer")
                            self.viewToBuildImage!.addSubview(playImage)
                            nbReactDone++
                        }
                    }
                    
                }
            }
            else{
                nbReactDone++
            }
            
            
        }
    }
    
    
    // MARK: SMS DELEGATE
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultSent.value:
            
            if controller.recipients != nil{
                Mixpanel.sharedInstance().track("Send SMS", properties: ["nb_recipients" : controller.recipients.count])
            }
            else{
                Mixpanel.sharedInstance().track("Send SMS")
            }
            
            
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        
        
        
    }
    
    

    
    
    // MARK:
    
    func findPikiInfosPosition(intId : Int) -> Int?{
        
        var peekeePosition : Int?
        var position = 0
        
        for react in self.pikiReacts{
            if !react.isKindOfClass(PFObject){
                if react["id"] != nil{
                    var intIdTemp:Int = react["id"] as! Int
                    
                    if intIdTemp == intId{
                        peekeePosition = position
                        return peekeePosition
                    }
                }
            }
            position++
        }
        
        return peekeePosition
        
    }
    
    
    func removeDefaultReact(){
        
        var peekeePosition : Int?
        var position = 0
        
        for react in self.pikiReacts{
            
            if react.isKindOfClass(NSNumber){
                peekeePosition = position
            }
            position++
        }
        
        
        if peekeePosition != nil{
            self.pikiReacts.removeAtIndex(peekeePosition!)
            self.collectionView!.deleteItemsAtIndexPaths([NSIndexPath(forItem: peekeePosition! + 1, inSection: 1)])
        }
        
    }
    
    
    
    func postNewTempReact(pikiInfos: [String:AnyObject]) {
        self.pikiReacts.insert(pikiInfos, atIndex: 0)
        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)])
        
        self.buildViewShareBackButton()
        
        PBJVision.sharedInstance().startPreview()
    }
    
    
    // MARK: Send SMS
    
    func sendSMSToContacts(){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        
        var messageController:MFMessageComposeViewController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.body = String(format: NSLocalizedString("SendInvitSMS", comment : ""), Utils().shareAppUrl)
        
        if Utils().iOS8{
            if MFMessageComposeViewController.respondsToSelector(Selector("canSendAttachments")) && MFMessageComposeViewController.canSendAttachments(){
                messageController.addAttachmentURL(Utils().createGifInvit(PFUser.currentUser()!.username!), withAlternateFilename: "invitationGif.gif")
            }
        }
        else{
            var dataImage:NSData? = UIImagePNGRepresentation(Utils().getShareUsernameImage())
            if dataImage != nil{
                messageController.addAttachmentData(dataImage, typeIdentifier: "image/png", filename: "peekeeInvit.png")
            }
            
        }
        
        
        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
        
        
    }
    
    
    // MARK: Cam Denied
    
    func camDenied() {
        var canOpenSettings:Bool = false

        if Utils().iOS8 {
            var alert = UIAlertController(title: LocalizedString("Error"), message: LocalizedString("To interact with your friends you need to allow the access to your camera. Go to settings to allow it? You'll need to go in the privacy menu"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: LocalizedString("No"), style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: LocalizedString("Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                self.openSettings()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            UIAlertView(title: LocalizedString("Error"), message: LocalizedString("To interact with your friends you need to allow the access to your camera. Please go to Settings > Confidentiality > Camera and allow it for Pleek"), delegate: nil, cancelButtonTitle: LocalizedString("Ok")).show()
        }
    }
    
    
    func openSettings(){
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    
    // MARK: Mem
    
    func getLastMem(){
        var queryMem:PFQuery = PFQuery(className: "stickers")
        queryMem.orderByAscending("priorite")
        queryMem.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryMem.findObjectsInBackgroundWithBlock { (mems, error) -> Void in
            if error != nil {
                
            }
            else {
                self.mems = mems as! Array<PFObject>
                self.memCollectionView.reloadData()
            }
        }
    }
    
    
    // MARK : 1vs1 Share
    
    func shareOneVsOne(react : PFObject){
        
        self.reactToShare = react
        
        showShareView(false)
        
        share1vs1View = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        share1vs1View!.backgroundColor = Utils().secondColor
        
        var mainImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: share1vs1View!.frame.width, height: share1vs1View!.frame.height))
        
        if self.mainPiki!["photo"] != nil{
            var filePeekee:PFFile = mainPiki!["photo"] as! PFFile
            filePeekee.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if data != nil{
                    mainImageView.image = UIImage(data: data!)
                }
            })
        }
        else{
            var filePeekee:PFFile = mainPiki!["previewImage"] as! PFFile
            filePeekee.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if data != nil{
                    mainImageView.image = UIImage(data: data!)
                }
            })
        }
        
        share1vs1View!.addSubview(mainImageView)
        
        //Shadow for bottom button
        var stretchShadowImage:UIImage = UIImage(named: "shadow_piki")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowImageView = UIImageView(frame: CGRect(x: 0, y: share1vs1View!.frame.height - 115 , width: share1vs1View!.frame.width, height: 115))
        shadowImageView.image = stretchShadowImage
        shadowImageView.hidden = false
        share1vs1View!.addSubview(shadowImageView)
        
        var reactImageView = UIImageView(frame: CGRect(x: 640, y: 640, width: 360, height: 360))
        reactImageView.layer.borderColor = UIColor.whiteColor().CGColor
        reactImageView.layer.borderWidth = 2
        reactImageView.layer.cornerRadius = 4
        
        if react["photo"] != nil{
            var fileReact:PFFile = react["photo"] as! PFFile
            fileReact.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if data != nil{
                    reactImageView.image = UIImage(data: data!)
                }
            })
        }
        else{
            var fileReact:PFFile = react["previewImage"] as! PFFile
            fileReact.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if data != nil{
                    reactImageView.image = UIImage(data: data!)
                }
            })
        }
        share1vs1View!.addSubview(reactImageView)
        
        var iconPeekee:UIImageView = UIImageView(frame: CGRect(x: 36, y: 900, width: 66, height: 66))
        iconPeekee.image = UIImage(named: "app_icon")
        iconPeekee.layer.cornerRadius = 12
        iconPeekee.clipsToBounds = true
        share1vs1View!.addSubview(iconPeekee)
        
        var labelWho:UILabel = UILabel(frame: CGRect(x: 129, y: 917, width: 500, height: 34))
        labelWho.textColor = UIColor.whiteColor()
        labelWho.font = UIFont(name: Utils().customFontSemiBold, size: 40)
        labelWho.adjustsFontSizeToFitWidth = true
        share1vs1View!.addSubview(labelWho)
        
        
        var userReact:PFUser = react["user"] as! PFUser
        var userPiki:PFUser = self.mainPiki!["user"] as! PFUser
        labelWho.text = String(format: LocalizedString("@%@ to @%@ on Pleek"), userReact.username!, userPiki.username!)
        
        
        
        
        let scale:CGFloat = imageContainerView!.frame.height / share1vs1View!.frame.height
        
        share1vs1View!.transform = CGAffineTransformMakeScale(scale, scale)
        share1vs1View!.frame.origin = CGPoint(x: 0, y: 0)
        imageContainerView!.addSubview(share1vs1View!)
        
        
        
        
    }
    
    
    func shareOnMessengerDirectReact(reactImage : UIImage){
        
        if Utils().isComingFromMessengerForThisPleek(self.mainPiki!){
            shareMessengerReactView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            
            var shareMessengerQuitAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("quitShareMessenger"))
            shareMessengerReactView!.addGestureRecognizer(shareMessengerQuitAction)
            
            let overlay:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlay.backgroundColor = UIColor.blackColor()
            overlay.alpha = 0.85
            shareMessengerReactView!.addSubview(overlay)
            
            let animatedGifView:UIImageView = UIImageView(frame: CGRect(x: 10, y: 30, width: self.view.frame.width - 20, height: self.view.frame.width - 20))
            animatedGifView.image = reactImage
            shareMessengerReactView!.addSubview(animatedGifView)
            
            
            var animatedGifBottom:CGFloat = animatedGifView.frame.height + animatedGifView.frame.origin.y
            let viewButtonMessenger:UIView = UIView(frame: CGRect(x: self.view.frame.width/2 - 40, y: (animatedGifBottom + (self.view.frame.height - animatedGifBottom)/2) - 40, width: 80, height: 80))
            
            var buttonMessenger:UIButton = FBSDKMessengerShareButton.circularButtonWithStyle(FBSDKMessengerShareButtonStyle.Blue, width: 80)
            buttonMessenger.addTarget(self, action: Selector("shareMessenger"), forControlEvents: UIControlEvents.TouchUpInside)
            viewButtonMessenger.addSubview(buttonMessenger)
            shareMessengerReactView!.addSubview(viewButtonMessenger)
            
            let sendLabel:UILabel = UILabel(frame: CGRect(x: 0, y: viewButtonMessenger.frame.origin.y - 50, width: self.view.frame.width, height: 30))
            sendLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            sendLabel.textColor = UIColor.whiteColor()
            sendLabel.textAlignment = NSTextAlignment.Center
            sendLabel.text = LocalizedString("Reply to your friends on Messenger!")
            shareMessengerReactView!.addSubview(sendLabel)
            
            self.view.addSubview(shareMessengerReactView!)
            
            
            Utils().getImagePleekOrReact(self.mainPiki!).continueWithBlock { (task : BFTask!) -> AnyObject! in
                if task.error != nil{
                    
                }
                else{
                    Utils().buildGifShareMessenger((task.result as! UIImage), reactImage: reactImage, otherReact: nil).continueWithBlock({ (taskGif : BFTask!) -> AnyObject! in
                        
                        if taskGif.error != nil{
                            //Error
                            println("Error Gif : \(taskGif.error)")
                        }
                        else{
                            self.gifURLLastReact = (taskGif.result as! NSURL)
                            var animatedGif : AnimatedGif = AnimatedGif.getAnimationForGifAtUrl((taskGif.result as! NSURL))
                            animatedGifView.setAnimatedGif(animatedGif, startImmediately: true)
                            
                        }
                        
                        return nil
                    })
                }
                
                return nil
            }
        }
    }
    
    func quitShareMessenger(){
        shareMessengerReactView!.removeFromSuperview()
    }
    
    
    // MARK : UIAlertView Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.tag == 1{
            // No Invit Mosaic
            if buttonIndex == 0{
            }
                //Invit Mosaic
            else{
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.sendSMSToContacts()
            }
        }
        else if alertView.tag == 10{
            if buttonIndex == 1{
                finallyRemove(self.reactToRemove!, isReport: false)
            }
        }
        
    }
    

    
    // MARK: Keyboard
    
    //Keyboard Notifs
    func keyboardWillShow(notification : NSNotification){
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
        let animationDuration: NSTimeInterval = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        buildMenu(keyboardSize)
        self.newReactViewcontroller?.getLastMem()
        self.collectionView!.frame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height+self.view.frame.width)
        self.collectionView!.scrollEnabled = false
   
        self.constraint?.uninstall()
        
        self.newReactViewcontroller!.view.snp_makeConstraints { (make) -> Void in
            self.constraint = make.height.equalTo(95.0 + 60.0 + keyboardSize.height).constraint
        }

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.collectionView!.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.width - 2)
            
            if !Utils().hasSeenVideoTuto(){
                self.newReactViewcontroller?.tutorialView.alpha = 1.0
            }
            
            //AppearOverlays
            self.mainOverlayCameraMenu!.alpha = 0.85
            self.secondOverlayCameraView!.alpha = 0.85
        }) { (finished) -> Void in
            self.newReactViewcontroller?.selectCameraMode(self.newReactViewcontroller!.keyboardButton)
        }
    }
    
    func keyboardWillHide(notification : NSNotification){
        self.newReactViewcontroller?.keyboardButton.selected = false
        let animationDuration: NSTimeInterval = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        quitAnimation(animationDuration)
    }
    
    // MARK: NewReactDelegate
    
    func presentKeyboard() {
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            cell.textViewOverPhoto.hidden = false
            cell.memeImageView.hidden = true
            cell.textViewOverPhoto.becomeFirstResponder()
        }
    }
    
    func dismissKeyboard() {
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            cell.textViewOverPhoto.resignFirstResponder()
        }
    }
    
    func startRecording() {
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            if !Utils().isIphone4(){
                cell.startRecording(6)
            }
        }
    }
    
    func endRecording() {
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            if !Utils().isIphone4(){
                cell.endRecording()
            }
        }
    }
    
    func toName1() {
        if let cellCamera:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell {
            cellCamera.textViewOverPhoto.hidden = true
            cellCamera.memeImageView.hidden = false
            cellCamera.memeImageView.image = nil
        }
    }
    
    func toName2(imageData: NSData) {
        if let cellCamera:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell {
            cellCamera.textViewOverPhoto.hidden = true
            cellCamera.memeImageView.hidden = false
            cellCamera.memeImageView.image = UIImage(data: imageData)
        }
    }
    
    func toName3(indexPath: NSIndexPath) {
        if let cellCamera:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            cellCamera.textViewOverPhoto.hidden = false
            cellCamera.memeImageView.hidden = true
            cellCamera.textViewOverPhoto.font = Utils().getFontsWithSize(30)[indexPath.item]["font"] as! UIFont
            cellCamera.textViewOverPhoto.textColor = Utils().getFontsWithSize(30)[indexPath.item]["color"] as! UIColor

            if count(cellCamera.textViewOverPhoto.text) == 0{
                cellCamera.textViewOverPhoto.text = LocalizedString("YO")
            }
            cellCamera.reloadPositionTextView()
        }
    }

    //MARK: Camera Menu V2
    
    func buildMenu(keyboardSize : CGSize){
//        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)

        if self.newReactViewcontroller == nil {
            var differencePositionOverlay:CGFloat = 80 + self.view.frame.width/2
            
            //Overlays
            mainOverlayCameraMenu = UIView(frame: CGRect(x: 0, y: differencePositionOverlay - 1, width: self.view.frame.width, height: self.view.frame.height - (differencePositionOverlay - 1)))
            mainOverlayCameraMenu!.backgroundColor = UIColor.blackColor()
            mainOverlayCameraMenu!.alpha = 0
            self.view.addSubview(mainOverlayCameraMenu!)
            
            secondOverlayCameraView = UIView(frame: CGRect(x: self.view.frame.width/2 - 1, y: 80, width: self.view.frame.width/2 + 1, height: self.view.frame.width/2))
            secondOverlayCameraView!.backgroundColor = UIColor.blackColor()
            secondOverlayCameraView!.alpha = 0
            self.view.addSubview(secondOverlayCameraView!)
            
            //Tap gestures overlays
            var tapGestureMainOverlay:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("quitCameraMenu"))
            mainOverlayCameraMenu!.addGestureRecognizer(tapGestureMainOverlay)
            var tapGestureSecondOverlay:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("quitCameraMenu"))
            secondOverlayCameraView!.addGestureRecognizer(tapGestureSecondOverlay)
            
            self.newReactViewcontroller = NewReactViewController()
            var vision:PBJVision = PBJVision.sharedInstance()
            vision.delegate = self.newReactViewcontroller!

            self.newReactViewcontroller?.delegate = self
            self.newReactViewcontroller?.pleekManager.isPublicPleek = self.isPublicPleek
            self.newReactViewcontroller?.pleekManager.mainPleek = self.mainPiki
            self.newReactViewcontroller?.pleekManager.delegate = self
            self.view.addSubview(self.newReactViewcontroller!.view)
            
            self.newReactViewcontroller!.view.snp_makeConstraints { (make) -> Void in
                make.leading.equalTo(self.view.snp_leading)
                make.trailing.equalTo(self.view.snp_trailing)
                self.constraint = make.height.equalTo(95.0 + 60.0 + keyboardSize.height).constraint
                make.bottom.equalTo(self.view.snp_bottom)
            }
        }
        else {
            self.newReactViewcontroller?.view.hidden = false
        }
    }
    
    func quitCameraMenu(){
        //Get camera Cell
        let cell:CameraCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell
        if cell != nil {
            self.isLeavingCameraMode = true
            if cell!.textViewOverPhoto.isFirstResponder(){
                cell!.textViewOverPhoto.resignFirstResponder()
            }
            else{
                let animationDuration: NSTimeInterval = 0.5
                
                quitAnimation(animationDuration)
            }
        }
    }
    
    func quitAnimation(duration : NSTimeInterval){
        if self.isLeavingCameraMode {
            //AppearOverlays
            self.mainOverlayCameraMenu!.alpha = 0
            self.secondOverlayCameraView!.alpha = 0

            if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
                cell.memeImageView.hidden = true
                cell.textViewOverPhoto.hidden = true
            }

            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.collectionView!.transform = CGAffineTransformIdentity
                self.newReactViewcontroller?.view.transform = CGAffineTransformIdentity
                self.newReactViewcontroller?.view.alpha = 0

            }) { (finished) -> Void in

                self.collectionView!.frame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.width, height: self.view.frame.height - 60)
                self.newReactViewcontroller?.view.hidden = true
                self.newReactViewcontroller?.view.alpha = 1
                self.isLeavingCameraMode = false
                self.collectionView!.scrollEnabled = true

                if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
                    cell.closeCamera()
                }
            }
        }
    }
    
    //MARK: LIKES REACTS
    
    func getLikesUser(){
        var likesQuery:PFQuery = PFQuery(className: "Like")
        likesQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        likesQuery.whereKey("piki", equalTo: self.mainPiki!)
        likesQuery.includeKey("react")
        likesQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
        
        likesQuery.findObjectsInBackgroundWithBlock { (likes, error) -> Void in
            if error == nil{
                if likes != nil{
                    self.listLikesUser.removeAll(keepCapacity: false)
                    
                    for like in likes as! [PFObject]{
                        if let react = like["react"] as? PFObject{
                            self.listLikesUser.insert(react.objectId!)
                        }
                    }
                }
            }
        }
    }
    
    func hasUserLikedThisReact(react : PFObject) -> Bool {
       return self.listLikesUser.contains(react.objectId!)
    }
    
    func userJustLiked(react : PFObject){
       if hasUserLikedThisReact(react){
            self.listLikesUser.remove(react.objectId!)
            
            for (index, value) in enumerate(self.pikiReacts){
                
                if value.isKindOfClass(PFObject){
                    if (value as! PFObject).objectId == react.objectId{
                        if let nbLikesActual = (self.pikiReacts[index] as! PFObject)["nbLikes"] as? Int{
                            (self.pikiReacts[index] as! PFObject)["nbLikes"] = nbLikesActual - 1
                        }
                        else{
                            (self.pikiReacts[index] as! PFObject)["nbLikes"] = 0
                        }
                        
                    }
                }
            }
        }
        else{
            if let player = likeSoundPlayer{
                player.play()
            }
            
            self.listLikesUser.insert(react.objectId!)
            
            for (index, value) in enumerate(self.pikiReacts){
                
                if value.isKindOfClass(PFObject){
                    if (value as! PFObject).objectId == react.objectId{
                        if let nbLikesActual = (self.pikiReacts[index] as! PFObject)["nbLikes"] as? Int{
                            (self.pikiReacts[index] as! PFObject)["nbLikes"] = nbLikesActual + 1
                        }
                        else{
                            (self.pikiReacts[index] as! PFObject)["nbLikes"] = 1
                        }
                        
                    }
                }
            }
        }
    }
    
    //MARK : PERMISSIONS
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
                // User granted
                dispatch_async(dispatch_get_main_queue()) {
                    if let cellCamera = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
                        cellCamera.updateCell(true)
                    }
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
    
    // ReactManagerDelegate
    
    func addPhotoToCollectionView(modifyImage: UIImage, randomNumber: Int) {
        //Add photo to the collection view right now
        var pikiInfos:[String : AnyObject] = [String : AnyObject]()
        pikiInfos["photo"] = modifyImage
        pikiInfos["id"] = randomNumber
        self.postNewTempReact(pikiInfos)
   }
    
    func modifyImageWithTextAndMeme(modifyImage: UIImage) -> (UIImage?, String?) {
        if let cell:CameraCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as? CameraCollectionViewCell{
            if !cell.textViewOverPhoto.hidden && cell.textViewOverPhoto.text != nil && count(cell.textViewOverPhoto.text) > 0{
                println("React with text")
                if let fontImage:UIImage = self.getPhotoWithTextOverlay(modifyImage){
                    return (fontImage, "Text")
                }

            }
            else if !cell.memeImageView.hidden{
                println("React with Meme")
                if let memeImage:UIImage = self.getPhotoWithLikeOverlay(modifyImage){
                    return (memeImage, "Emoji")
                }
            }
        }

        return (nil, nil)
        
    }
    
    func setNewReacts(react: AnyObject, randomNumber: Int) -> Int? {
        var position = self.findPikiInfosPosition(randomNumber)
        
        if let post = position {
            self.pikiReacts[post] = react
            self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: post + 1, inSection: 1)])
            self.hasNewReacts = true
        }

        return position
    }
    
    func addVideoToCollectionView(screenImage: UIImage, path: String, randomNumber: Int) {
        //Add photo to the collection view right now
        var pikiInfos:[String : AnyObject] = [String : AnyObject]()
        pikiInfos["videoPath"] = NSURL(fileURLWithPath: path as String)
        pikiInfos["previewImage"] = screenImage
        pikiInfos["id"] = randomNumber
        self.postNewTempReact(pikiInfos)
    }
}



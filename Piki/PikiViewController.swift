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


protocol PikiControllerProtocol {
    func updateReactsForPiki(piki : PFObject, updateAll : Bool)
    func updatePikis()
}

class PikiViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextViewDelegate, AVCaptureFileOutputRecordingDelegate, UIScrollViewDelegate, UITextFieldDelegate, ReactsCellProtocol, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    
    //Asset Keys
    private let PlayerTracksKey = "tracks"
    private let PlayerPlayableKey = "playable"
    private let PlayerDurationKey = "duration"
    private let PlayerRateKey = "rate"
    private var asset: AVAsset!
    
    let transitionManager = TransitionPikiManager()
    
    var collectionView: UICollectionView?
    var mainPhotoView : UIView?
    var mainPhotoImageView:UIImageView?
    var actualMode:Int = 0
    var imageFile:PFFile?
    var takePhotoLabel : UILabel?
    var comeFromMode:Int = 0
    var lastPiki:PFObject?
    var switchCamera:UIButton?
    var reacts:NSArray = NSArray()
    var likeOverlayView:UIView?
    var likeImageView:UIImageView?
    var likeOverlayBlackView: UIView?
    var photoTaken:UIImage?
    var statusBarHidden:Bool = false
    var cameraText:UITextField?
    
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var audioCaptureDevice : AVCaptureDevice?
    var previewLayer :AVCaptureVideoPreviewLayer?
    var imageOutput : AVCaptureStillImageOutput?
    var videoOutput : AVCaptureMovieFileOutput?
    var captureDeviceInput:AVCaptureDeviceInput?
    var audioDeviceInput:AVCaptureDeviceInput?
    
    var previewCameraCell:ReactsCollectionViewCell?
    
     var delegate:PikiControllerProtocol? = nil
    
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
    
    var nbreactsView:UIView?
    var nbPeopleView:UIView?
    var mainPikiPreview:PFImageView?
    var nbReactLabel: UILabel?
    
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
    
    
    //New version react
    var replyButton:UIButton!
    var topOverlay:UIView!
    var alternativeMiddleOverlay:UIView!
    var middleOverlay:UIView!
    var bottomOverlay:UIView!
    var arrayEmojisButton:Array<UIButton> = Array<UIButton>()
    var backCameraActionView:UIView!
    var emojiButtonSelected:UIButton?
    var backEmojiButtonSelected:UIView!
    
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() == nil {
            println("NIL")
        }
        
        FBAppEvents.logEvent(FBAppEventNameViewedContent)
        Mixpanel.sharedInstance().track("View Piki")
        
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        
        tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        
        
        

        
        //Listen keyboard to move collection view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        
        //Like overlay view
        likeOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
        likeOverlayView!.backgroundColor = UIColor.clearColor()
        likeOverlayView!.hidden = true
        //self.view.addSubview(likeOverlayView!)
        
        likeOverlayBlackView =  UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
        likeOverlayBlackView!.backgroundColor = UIColor.blackColor()
        likeOverlayBlackView!.alpha = 0.7
        likeOverlayView!.addSubview(likeOverlayBlackView!)
        
        likeImageView = UIImageView(frame: CGRect(x: likeOverlayView!.frame.size.height/2 - 75, y: likeOverlayView!.frame.size.width/2 - 75, width: 150, height: 150))
        likeImageView!.image = UIImage(named: "like")
        likeOverlayView!.addSubview(likeImageView!)
        

        
        
        //V2 UX/UI
        
        //Back Status bar
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        
        
        //Top Bar
        let topBarView:UIView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 60))
        topBarView.backgroundColor = Utils().primaryColor
        
        
        //View top left for username/back
        var gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("quit"))
        let backLeftView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/4 * 3, height: 60))
        backLeftView.backgroundColor = Utils().primaryColorDark
        backLeftView.addGestureRecognizer(gesture)
        topBarView.addSubview(backLeftView)
        
        let usernameLabel:UILabel = UILabel(frame: CGRect(x: 40, y: 0, width: backLeftView.frame.size.width - 35, height: backLeftView.frame.size.height))
        usernameLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20)
        usernameLabel.textColor = UIColor.whiteColor()
        backLeftView.addSubview(usernameLabel)
        if self.mainPiki!["user"] != nil {
            var user = self.mainPiki!["user"] as PFUser
            var username:String = user["username"] as String
            usernameLabel.text = "@\(username)"
        }
        
        let backImageView:UIImageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 8, height: 60))
        backImageView.image = UIImage(named: "button_back")
        backImageView.contentMode = UIViewContentMode.Center
        topBarView.addSubview(backImageView)
        
        let shareButton:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width/4 * 3, y: 0, width: self.view.frame.size.width/4, height: 60))
        shareButton.setImage(UIImage(named: "share_icon"), forState: UIControlState.Normal)
        shareButton.addTarget(self, action: Selector("buildViewShare"), forControlEvents: UIControlEvents.TouchUpInside)
        topBarView.addSubview(shareButton)
        
        //Collection View Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        
        if Utils().isIphone6Plus(){
            layout.minimumInteritemSpacing = 0
        }
        else{
            layout.minimumInteritemSpacing = 1
        }
        
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: (UIScreen.mainScreen().bounds.width  - 2)/3, height: (UIScreen.mainScreen().bounds.width - 2)/3)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 60, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 60) , collectionViewLayout: layout)
        //collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(ReactsCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView!.registerClass(MainPeekeeCollectionViewCell.self, forCellWithReuseIdentifier: "MainCell")
        collectionView!.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.showsVerticalScrollIndicator = false
        self.view.addSubview(collectionView!)
        
        self.collectionView!.alwaysBounceVertical = true
        
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "moreFooter")
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "moreHeader")
        
        
        self.view.addSubview(backStatusBar)
        self.view.addSubview(topBarView)
        
        
        //NB People Infos View
        nbPeopleView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.width + topBarView.frame.size.height - 50, width: self.view.frame.size.width, height: 50))
        nbPeopleView!.backgroundColor = UIColor.clearColor()
        
        let nbPeopleButton:UIButton = UIButton(frame: CGRect(x: 20, y: 0, width: 200, height: nbPeopleView!.frame.height))
        nbPeopleButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        nbPeopleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        recipients = self.mainPiki!["recipients"] as? Array<String>
        if recipients != nil {
            if recipients!.count > 1{
                let nbFriendsFormat = String(format: NSLocalizedString("%d friends", comment : "%d friends"), recipients!.count)
                nbPeopleButton.setTitle(nbFriendsFormat, forState: UIControlState.Normal)
            }
            else{
                let nbFriendsFormat = String(format: NSLocalizedString("%d friend", comment : "%d friend"), recipients!.count)
                nbPeopleButton.setTitle(nbFriendsFormat, forState: UIControlState.Normal)
            }
            
        }
        else{
            nbPeopleButton.setTitle(" friends", forState: UIControlState.Normal)
        }
        nbPeopleButton.titleLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 25)
        nbPeopleButton.titleLabel!.textAlignment = NSTextAlignment.Left
        nbPeopleButton.addTarget(self, action: Selector("seeFriends:"), forControlEvents: UIControlEvents.TouchUpInside)
        nbPeopleView!.addSubview(nbPeopleButton)
        
        var moreButton = UIButton(frame: CGRect(x: nbPeopleView!.frame.width - 50, y: 0, width: 35, height: nbPeopleView!.frame.height))
        moreButton.setImage(UIImage(named: "view_more_peekee"), forState: UIControlState.Normal)
        moreButton.addTarget(self, action: Selector("morePeekee"), forControlEvents: UIControlEvents.TouchUpInside)
        nbPeopleView!.addSubview(moreButton)
        
        
        
        self.view.addSubview(nbPeopleView!)
        
        //NB Reacts Infos Bar
        nbreactsView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.width + 20 + topBarView.frame.size.height - 50, width: self.view.frame.size.width, height: 50))
        nbreactsView!.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 0.96)
        nbreactsView!.hidden = true
        self.view.addSubview(nbreactsView!)

        //Nb React View
        
        let nbReactInBarView:UIView = UIView(frame: CGRect(x: 15, y: 0, width: 55, height: nbreactsView!.frame.height))
        nbReactInBarView.backgroundColor = UIColor.clearColor()
        nbreactsView!.addSubview(nbReactInBarView)
        
        //Nb React Label
        nbReactLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: nbReactInBarView.frame.height))
        nbReactLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        nbReactLabel!.textColor = UIColor.whiteColor()
        nbReactLabel!.textAlignment = NSTextAlignment.Center
        
        let nbReact = self.mainPiki!["nbReaction"] as? Int
        if nbReact != nil{
            nbReactLabel!.text = "\(nbReact!)"
        }
        else{
            nbReactLabel!.text = "0"

        }
        nbReactInBarView.addSubview(nbReactLabel!)
        
        
        //Nb React Icon
        let nbReactIcon:UIImageView = UIImageView(frame: CGRect(x: nbReactInBarView.frame.width - 20, y: 0, width: 20, height: nbReactInBarView.frame.height))
        nbReactIcon.contentMode = UIViewContentMode.Center
        nbReactIcon.image = UIImage(named: "reacts_nb_piki_icon")
        nbReactInBarView.addSubview(nbReactIcon)
        
        
        //Nb Friends In Bar View
        let gestureTapNbFriends:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("seeFriends:"))
        let nbFriendsInBarView:UIView = UIView(frame: CGRect(x: nbReactInBarView.frame.origin.x + nbReactInBarView.frame.width + 10, y: 0, width: 60, height: nbreactsView!.frame.height))
        nbFriendsInBarView.backgroundColor = UIColor.clearColor()
        nbFriendsInBarView.addGestureRecognizer(gestureTapNbFriends)
        nbreactsView!.addSubview(nbFriendsInBarView)
        
        //Nb People in bar Label
        let nbPeopleInBarLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: nbFriendsInBarView.frame.height))
        nbPeopleInBarLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        nbPeopleInBarLabel.textColor = UIColor.whiteColor()
        nbPeopleInBarLabel.textAlignment = NSTextAlignment.Center
        if recipients != nil {
            nbPeopleInBarLabel.text = "\(recipients!.count)"
            
        }
        else{
            nbPeopleInBarLabel.text = "0"
        }
        nbFriendsInBarView.addSubview(nbPeopleInBarLabel)
        
        
        //Nb People Icon
        let nbPeopleIcon:UIImageView = UIImageView(frame: CGRect(x: nbFriendsInBarView.frame.width - 20, y: 0, width: 20, height: nbFriendsInBarView.frame.height))
        nbPeopleIcon.contentMode = UIViewContentMode.Center
        nbPeopleIcon.image = UIImage(named: "recipient_piki_icon")
        nbFriendsInBarView.addSubview(nbPeopleIcon)
        
        //Preview of the main Piki on the infos bar
        mainPikiPreview = PFImageView(frame: CGRect(x: self.view.frame.size.width - 45, y: 5, width: 40, height: 40))
        
        mainPikiPreview!.layer.cornerRadius = 2
        mainPikiPreview!.clipsToBounds = true
        
        nbreactsView!.addSubview(mainPikiPreview!)
        if self.mainPiki!["smallPiki"] != nil{
            mainPikiPreview!.file = self.mainPiki!["smallPiki"] as PFFile
        }
        else if self.mainPiki!["previewImage"] != nil{
            mainPikiPreview!.file = self.mainPiki!["previewImage"] as PFFile
        }
        
        mainPikiPreview!.loadInBackground()
        
        
        
        //Reply Button
        replyButton = UIButton(frame: CGRect(x: self.view.frame.width - 103, y: self.view.frame.height - 108, width: 75, height: 80))
        replyButton.setImage(UIImage(named: "reply_button"), forState: UIControlState.Normal)
        replyButton.addTarget(self, action: Selector("replyPeekee"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(replyButton)
        

        //Overlays Reply Mode
        var spaceToMove =  (self.view.frame.height - (20 + 60 + 125 + self.view.frame.width/3)) - self.view.frame.width
        
        let tapGestureLeaveReplyTop = UITapGestureRecognizer(target: self, action: Selector("leaveReply"))
        topOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - (125 + self.view.frame.width/3) + 2))
        topOverlay.backgroundColor = UIColor.blackColor()
        topOverlay.addGestureRecognizer(tapGestureLeaveReplyTop)
        topOverlay.alpha = 0.0
        self.view.addSubview(topOverlay)
        
        let tapGestureLeaveReplyMiddle = UITapGestureRecognizer(target: self, action: Selector("leaveReply"))
        middleOverlay = UIView(frame : CGRect(x: self.view.frame.width/3 - 1, y: topOverlay.frame.origin.y + topOverlay.frame.height, width: (self.view.frame.width/3) * 2 + 1, height: self.view.frame.width/3))
        middleOverlay.backgroundColor = UIColor.blackColor()
        middleOverlay.alpha = 0
        //middleOverlay.addGestureRecognizer(tapGestureLeaveReplyMiddle)
        self.view.addSubview(middleOverlay)
        
        var stretchBackgroundMeme:UIImage = UIImage(named: "background_stickers")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let backgroundMemeImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: middleOverlay.frame.width, height: middleOverlay.frame.height))
        backgroundMemeImageView.image = stretchBackgroundMeme
        middleOverlay.addSubview(backgroundMemeImageView)
        
        //Collection View Layout
        let layoutMem: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutMem.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layoutMem.minimumInteritemSpacing = 0
        layoutMem.minimumLineSpacing = 0
        layoutMem.itemSize = CGSize(width: middleOverlay.frame.height, height: middleOverlay.frame.height)
        layoutMem.scrollDirection = UICollectionViewScrollDirection.Horizontal
        memCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: middleOverlay.frame.width, height: middleOverlay.frame.height) , collectionViewLayout: layoutMem)
        memCollectionView.registerClass(MemCollectionViewCell.self, forCellWithReuseIdentifier: "CellMem")
        memCollectionView.backgroundColor = UIColor.clearColor()
        memCollectionView!.dataSource = self
        memCollectionView!.delegate = self
        memCollectionView.showsHorizontalScrollIndicator = false
        memCollectionView.showsVerticalScrollIndicator = false
        middleOverlay.addSubview(memCollectionView)
        
        var stretchShadowMeme:UIImage = UIImage(named: "shadow_meme")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowMemeImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: middleOverlay.frame.height))
        shadowMemeImageView.image = stretchShadowMeme
        middleOverlay.addSubview(shadowMemeImageView)
        
        
        
        let tapGestureLeaveReplyBottom = UITapGestureRecognizer(target: self, action: Selector("leaveReply"))
        bottomOverlay = UIView(frame : CGRect(x: 0, y:middleOverlay.frame.origin.y + middleOverlay.frame.height - 1 , width: self.view.frame.width, height: self.view.frame.height - (middleOverlay.frame.origin.y + middleOverlay.frame.height) + 1))
        bottomOverlay.backgroundColor = UIColor.blackColor()
        bottomOverlay.alpha = 0
        bottomOverlay.addGestureRecognizer(tapGestureLeaveReplyBottom)
        self.view.addSubview(bottomOverlay)
        
        backEmojiButtonSelected = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        backEmojiButtonSelected.backgroundColor = UIColor.whiteColor()
        backEmojiButtonSelected.layer.cornerRadius = 28
        backEmojiButtonSelected.clipsToBounds = true
        backEmojiButtonSelected.hidden = true
        self.view.addSubview(backEmojiButtonSelected)
        
        
        
        //Emojis buttons
        //for i in 0...3{
            var emojiButton = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 60))
            emojiButton.center = CGPoint(x: replyButton.center.x, y: replyButton.center.y)
            emojiButton.setImage(UIImage(named: "text_emoji_button"), forState: UIControlState.Normal)
        
            /*switch i {
            case 0:
                emojiButton.setImage(UIImage(named: "text_emoji_button"), forState: UIControlState.Normal)
            case 1:
                emojiButton.setImage(UIImage(named: "awesome_icon"), forState: UIControlState.Normal)
            case 2:
                emojiButton.setImage(UIImage(named: "cute_icon"), forState: UIControlState.Normal)
            case 3:
                emojiButton.setImage(UIImage(named: "fuck_icon"), forState: UIControlState.Normal)
            default:
                emojiButton.setImage(UIImage(named: "awesome_icon"), forState: UIControlState.Normal)
            }*/
            
            emojiButton.transform = CGAffineTransformMakeScale(0, 0)
            emojiButton.addTarget(self, action: Selector("selectEmoji:"), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(emojiButton)
            arrayEmojisButton.append(emojiButton)
        //}
        
        
            
            
        
        var tapGestureTakeReact: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("takeReact:"))
        var longPressGestureReact : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("recordVideoReact:"))
        longPressGestureReact.minimumPressDuration = 0.4
        //Camera Action Button
        cameraActionButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 172, y: self.view.frame.height - 75, width: 62, height: 65))
        cameraActionButton!.center = CGPoint(x: self.view.frame.width/2, y: replyButton.center.y)
        cameraActionButton!.setImage(UIImage(named: "answer_button"), forState: UIControlState.Normal)
        cameraActionButton!.addGestureRecognizer(tapGestureTakeReact)
        cameraActionButton!.addGestureRecognizer(longPressGestureReact)
        cameraActionButton!.hidden = true
        
        
        
        //Circle around action button
        backCameraActionView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        backCameraActionView.center = CGPoint(x: cameraActionButton!.center.x, y: cameraActionButton!.center.y - 2)
        backCameraActionView.backgroundColor = UIColor.whiteColor()
        backCameraActionView.layer.cornerRadius = 35
        backCameraActionView.clipsToBounds = true
        backCameraActionView.alpha = 0.4
        backCameraActionView.hidden = true
        self.view.addSubview(backCameraActionView)
        self.view.addSubview(cameraActionButton!)
        
        
        var translateCameraButton:CGFloat = self.replyButton.center.x - self.cameraActionButton!.center.x
        cameraActionButton!.transform = CGAffineTransformMakeTranslation(translateCameraButton, 0)
        backCameraActionView!.transform = CGAffineTransformMakeTranslation(translateCameraButton, 0)
        
        
        quitButtonReply = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        quitButtonReply!.addTarget(self, action: Selector("leaveReply"), forControlEvents: UIControlEvents.TouchUpInside)
        quitButtonReply!.center = replyButton.center
        quitButtonReply!.setImage(UIImage(named: "quit_reply_icon"), forState: UIControlState.Normal)
        quitButtonReply!.hidden = true
        self.view.addSubview(quitButtonReply!)
        
        
        backEmojisView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        backEmojisView!.hidden = true
        backEmojisView!.backgroundColor = UIColor.whiteColor()
        backEmojisView!.alpha = 0.6
        self.view.addSubview(backEmojisView!)
        
        
        captureSession.sessionPreset = AVCaptureSessionPresetMedium
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Front) {
                    println("Init capture cevice")
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        
        refreshControl.tintColor = UIColor(red: 63/255, green: 45/255, blue: 50/255, alpha: 1.0)
        refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView!.addSubview(refreshControl)
        
        
        getReacts()
        Utils().setPikiAsView(self.mainPiki!)
        
        
        getLastMem()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //Photo stream init
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        //See if show tuto overlay
        if PFUser.currentUser()["hasShownOverlayPeekee"] != nil{
            
            if !(PFUser.currentUser()["hasShownOverlayPeekee"] as Bool){
                showOverlayTuto()
            }
        }
        else{
            showOverlayTuto()
        }
        
        if collectionView != nil {
            //startVideoOnVisibleCells()
            self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)])
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        
        getReacts()
        
    }
    
    
    //Number of cells
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView! {
            if section == 0{
                return 1
            }
            else{
                return self.pikiReacts.count+1
            }
        }
        else{
            return self.mems.count
        }
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == self.collectionView! {
            if section == 1{
                return CGSize(width: self.view.frame.width, height: 2)
            }
            else{
                return CGSize(width: 0, height: 0)
            }
        }
        else{
            return CGSize(width: 0, height: 0)
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == self.collectionView! {
            if indexPath.section == 0{
                return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width)
            }
            else{
                if indexPath == indexPathBig{
                    //return CGSize(width: self.view.frame.width, height: (self.view.frame.width - 2)/3 * 2)
                    return CGSize(width: (self.view.frame.width - 2)/3 * 2, height: (self.view.frame.width - 2)/3 * 2)
                }
                else{
                    return CGSize(width: (self.view.frame.size.width - 2)/3, height: (self.view.frame.size.width - 2)/3)
                }
                
                
            }
        }
        else{
            return CGSize(width: self.middleOverlay.frame.height, height: self.middleOverlay.frame.height)
        }
        
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        if collectionView == self.collectionView! {
            return 2
        }
        else{
            return 1
        }
        
        
    }
    
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }*/
    //Build each cell
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        if collectionView == self.collectionView! {
            if indexPath.section == 0{
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MainCell", forIndexPath: indexPath) as MainPeekeeCollectionViewCell
                
                if self.mainPiki != nil {
                    
                    
                    var file:PFFile?
                    if mainPiki!["photo"] != nil {
                        file = mainPiki!["photo"] as? PFFile
                    }
                    else{
                        file = mainPiki!["previewImage"] as? PFFile
                    }
                    
                    
                    file!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            let image:UIImage = UIImage(data: data)!
                            self.mainPekeeImage = image
                            cell.mainImageView.image = image
                        }
                    })
                    
                    if mainPiki!["video"] != nil{
                        
                        if cell.playerLayer.player != nil{
                            
                        }
                        else{
                            cell.loadIndicator.hidden = false
                            cell.loadIndicator.startAnimating()
                            
                            let videoFile:PFFile = mainPiki!["video"] as PFFile
                            
                            
                            videoFile.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                                
                                
                                var fileManager:NSFileManager = NSFileManager()
                                if data.writeToFile("\(NSTemporaryDirectory())_\(self.mainPiki!.objectId).mov", atomically: false){
                                    
                                    
                                    var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(self.mainPiki!.objectId).mov")
                                    var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                                    var player:AVPlayer = AVPlayer(playerItem: playerItem)
                                    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                                    player.muted = false
                                    
                                    
                                    
                                    
                                    
                                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                                    
                                    
                                    if (self as UIViewController).isViewLoaded() && ((self as UIViewController).view.window != nil) {
                                        cell.loadIndicator.hidden = true
                                        cell.playerLayer.player = player
                                        cell.playerView.hidden = false
                                        player.play()
                                    }
                                    
                                    
                                    
                                }
                                
                                
                            })
                        }
                        
                        
                    }
                    
                }
                
                return cell
                
            }
            else{
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ReactsCollectionViewCell
                
                cell.ownPosition = indexPath.item
                cell.mainPeekee = self.mainPiki!
                
                
                if indexPath.item%2 == 0{
                    cell.backImageView!.backgroundColor = UIColor(red: 230/255, green: 231/255, blue: 234/255, alpha: 1.0)
                }
                else{
                    cell.backImageView!.backgroundColor = UIColor(red: 236/255, green: 238/255, blue: 240/255, alpha: 1.0)
                }
                
                
                cell.react = nil
                cell.delegate = self
                cell.backImageView!.hidden = true
                cell.insideCollectionView.hidden = false
                cell.readVideoImageView.hidden = true
                cell.reactVideoURL = nil
                cell.pikiInfos = nil
                cell.emptyCaseImageView!.hidden = true
                cell.playerView.hidden = true
                
                //Camera view
                if indexPath.item == 0 {
                    cell.insideCollectionView.hidden = true
                    cell.iconInfo!.hidden = false
                    cell.iconInfo!.image = UIImage(named: "switch_camera")
                    
                    self.previewCameraCell = cell
                    cell.previewCameraView.hidden = false
                    cell.previewCameraView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
                    cell.reactImage.hidden = true
                    cell.playerView.hidden = true
                    
                    if captureDevice != nil && !captureSession.running{
                        println("Begin Session from cell")
                        beginSession(cell.previewCameraView)
                    }
                    else{
                        previewLayer?.frame = cell.previewCameraView.layer.frame
                        cell.previewCameraView.layer.addSublayer(previewLayer)
                    }
                }
                    //Display React
                else{
                    
                    cell.iconInfo!.hidden = true
                    cell.previewCameraView.hidden = true
                    cell.reactImage.hidden = true
                    cell.backImageView!.hidden = false
                    
                    
                    if self.pikiReacts[indexPath.item-1].isKindOfClass(PFObject){
                        cell.react = self.pikiReacts[indexPath.item-1] as? PFObject
                        cell.updateDeleteSign()
                        
                        var pikiReact:PFObject = self.pikiReacts[indexPath.item-1] as PFObject
                        //React is a photo
                        if (pikiReact["photo"] != nil){
                            cell.playerView.hidden = true
                            
                            var file:PFFile = pikiReact["photo"] as PFFile
                            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                if error == nil {
                                    var arrayIndex:Array<NSIndexPath> = collectionView.indexPathsForVisibleItems() as Array<NSIndexPath>
                                    if contains(arrayIndex, indexPath){
                                        cell.backImageView!.hidden = true
                                        let imageReact:UIImage? = UIImage(data : data)
                                        if imageReact != nil{
                                            cell.reactImage.image = imageReact
                                            cell.reactImage.hidden = false
                                        }
                                        
                                    }
                                    else{
                                        println("index not in the array")
                                    }
                                }
                                else{
                                    println("Error getting image")
                                    
                                }
                            })
                        }
                            //React is a video
                        else{
                            cell.readVideoImageView.hidden = false
                            //cell.iconInfo!.hidden = false
                            cell.iconInfo!.image = UIImage(named: "mute_react_icon")
                            
                            cell.playerView.hidden = true
                            //Load preview image first
                            if pikiReact["previewImage"] != nil{
                                var file:PFFile = pikiReact["previewImage"] as PFFile
                                file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                    if error == nil {
                                        var arrayIndex:Array<NSIndexPath> = collectionView.indexPathsForVisibleItems() as Array<NSIndexPath>
                                        if contains(arrayIndex, indexPath){
                                            
                                            let imageReact:UIImage = UIImage(data : data)!
                                            cell.backImageView!.hidden = true
                                            cell.reactImage.image = imageReact
                                            cell.reactImage.hidden = false
                                        }
                                    }
                                })
                            }
                            else{
                                cell.reactImage.hidden = true
                            }
                        }
                    }
                    else{
                        var pikiInfos:[String : AnyObject] = self.pikiReacts[indexPath.item-1] as [String : AnyObject]
                        
                        cell.playerView.hidden = true
                        if pikiInfos["photo"] != nil {
                            cell.backImageView!.hidden = true
                            cell.reactImage.image = pikiInfos["photo"] as? UIImage
                            cell.reactImage.hidden = false
                            
                        }
                        else{
                            println("PIKIINFOS :\(pikiInfos)")
                            cell.readVideoImageView.hidden = false
                            //cell.iconInfo!.hidden = false
                            cell.iconInfo!.image = UIImage(named: "mute_react_icon")
                            cell.backImageView!.hidden = true
                            cell.reactImage.hidden = false
                            cell.reactVideoURL = (pikiInfos["videoPath"] as? NSURL)?.path
                            
                            cell.reactImage.image = pikiInfos["previewImage"] as? UIImage
                        }
                        cell.pikiInfos = pikiInfos
                        cell.updateDeleteSign()
                    }
                    
                }
                
                if indexPath.item == (pikiReacts.count - 1){
                    
                    
                    if pikiReacts.count > 0 && !isLoadingMore{
                        
                        let nbReact = self.mainPiki!["nbReaction"] as? Int
                        if nbReact != nil{
                            if nbReact > pikiReacts.count{
                                isLoadingMore = true
                                self.getMoreReacts()
                            }
                        }
                    }
                }
                
                
                return cell
            }
        }
        else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellMem", forIndexPath: indexPath) as MemCollectionViewCell

            cell.iconImageView.image = nil
            
            var fileMem = self.mems[indexPath.item]["image"] as PFFile
            fileMem.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                
                cell.iconImageView.image = UIImage(data: data)
                
            })
            
            return cell
        }
        
        
    

        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView == self.collectionView! {
            if indexPath.section == 1{
                if indexPath.item == 0{
                    comeFromMode = 1
                    
                    self.changeCameraPosition()
                }
                else{
                    let cell:ReactsCollectionViewCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as ReactsCollectionViewCell
                    if !cell.playerView.hidden{
                        
                        muteAllVideosExcept(indexPath)
                        
                        
                        if  cell.playerLayer.player.muted {
                            cell.iconInfo!.hidden = true
                            cell.playerLayer.player.muted = false
                            
                        }
                        else{
                            cell.iconInfo!.hidden = false
                            cell.playerLayer.player.muted = true
                        }
                        
                        
                        
                        
                    }
                }
            }
            else{
                var cellMain:MainPeekeeCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as MainPeekeeCollectionViewCell
                
                if cellMain.playerLayer.player != nil{
                    
                    if (cellMain.playerLayer.player.rate > 0 && cellMain.playerLayer.player.error == nil) {
                        cellMain.playerLayer.player.pause()
                        cellMain.readVideoIcon.hidden = false
                        cellMain.loadIndicator.hidden = true
                    }
                    else{
                        cellMain.playerLayer.player.play()
                        cellMain.readVideoIcon.hidden = true
                        cellMain.loadIndicator.hidden = true
                    }
                    
                    
                    
                }
            }
        }
        else{
            
            
            
            if (self.memCollectionView!.cellForItemAtIndexPath(indexPath) as MemCollectionViewCell).iconImageView.image != nil{
                
                if positionMemShowed != nil{
                    
                    if positionMemShowed == indexPath.item{
                        hideMem()
                        positionMemShowed = nil
                    }
                    else{
                        self.showMem(indexPath.item)
                        positionMemShowed = indexPath.item
                    }
                    
                    
                }
                else{
                    self.showMem(indexPath.item)
                    self.positionMemShowed = indexPath.item
                }
                
            }
            
            
            
            
        }
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if collectionView == self.collectionView! {
            if section == 1{
                if pikiReacts.count > 0{
                    let nbReact = self.mainPiki!["nbReaction"] as? Int
                    if nbReact != nil{
                        if nbReact > pikiReacts.count{
                            return CGSize(width: self.view.frame.width, height: 50)
                        }
                    }
                }
                
                
                return CGSize(width: self.view.frame.width, height: 0)
                
            }
            else{
                return CGSize(width: self.view.frame.width, height: 0)
            }
        }
        else{
            return CGSize(width: 0, height: 0)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView:UICollectionReusableView?
        
        if collectionView == self.collectionView! {
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
                    
                    parrotLoad!.hidden = false
                    
                    
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
        }
        else{
            reusableView = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "moreHeader", forIndexPath: indexPath) as? UICollectionReusableView
            
        }
        
        
  
        
        
        return reusableView!
    }
    
    
    /*
    * TAP GESTURE RECOGNIZERS
    */

    
    func takePhotoFromCell(){
        
        var bgTaskIdentifierUploadReact:UIBackgroundTaskIdentifier?
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var videoConnection : AVCaptureConnection?
            for connecton in self.imageOutput!.connections {
                //find a matching input port
                for port in connecton.inputPorts!{
                    if port.mediaType == AVMediaTypeVideo {
                        videoConnection = connecton as? AVCaptureConnection
                        break //for port
                    }
                }
                
                if videoConnection  != nil {
                    break// for connections
                }
            }
            if videoConnection  != nil {
                Mixpanel.sharedInstance().timeEvent("Send React")
                
                self.imageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection){
                    (imageSampleBuffer : CMSampleBuffer!, _) in
                    
                    let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    var pickedImage: UIImage = UIImage(data: imageDataJpeg)!
                    
                    
                    var flippedImage:UIImage?
                    if self.captureDevice!.position == AVCaptureDevicePosition.Front {
                        flippedImage = UIImage(CGImage: pickedImage.CGImage, scale: pickedImage.scale, orientation: UIImageOrientation.LeftMirrored)
                    }
                    else{
                        flippedImage = pickedImage
                    }
                    
                    var squareImage = RBSquareImageTo(flippedImage!, CGSize(width: 300, height: 300))
                    
                    
                    var randomNumber = self.randomNumber()
                    
                    //Add photo now to the collection
                    var pikiInfos:[String : AnyObject] = [String : AnyObject]()
                    pikiInfos["photo"] = squareImage
                    pikiInfos["id"] = randomNumber

                    
                    self.postNewTempReact(pikiInfos)
                    
                    //Upload file
                    self.uploadImage(squareImage)
                    println("Photo Taken")
                    
                    //Push notif
                    var isPublic:Bool?
                    if self.mainPiki!["isPublic"] != nil {
                        isPublic = self.mainPiki!["isPublic"] as? Bool
                    }
                    else{
                        isPublic = true
                    }
                    
                    
                    
                    
                    //Create React
                    if self.imageFile != nil{
                        if self.mainPiki != nil{
                            var newReact:PFObject = PFObject(className: "React")
                            newReact["photo"] = self.imageFile!
                            newReact["Piki"] = self.mainPiki!
                            newReact["user"] = PFUser.currentUser()
                            var reactACL:PFACL = PFACL()
                            
                            
                            if isPublic!{
                                reactACL.setPublicReadAccess(true)
                            }
                            else{
                                for userId in self.mainPiki!["recipients"] as Array<String>{
                                    reactACL.setReadAccess(true, forUserId: userId)
                                }
                            }
                            
                            reactACL.setWriteAccess(true, forUser: PFUser.currentUser())
                            
                            if self.mainPiki!["user"] != nil {
                                reactACL.setWriteAccess(true, forUser: self.mainPiki!["user"] as PFUser)
                            }
                            
                            newReact.ACL = reactACL
                            
                            
                            //Start a background task
                            bgTaskIdentifierUploadReact = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                                UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                            })
                            
                            
                            newReact.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
                                if succeeded{
                                    Mixpanel.sharedInstance().people.increment(["React Sent" : 1, "React Photo Sent" : 1])
                                    FBAppEvents.logEvent("Send React", parameters: ["React Type" : "Photo"])
                                    Mixpanel.sharedInstance().track("Send React", properties: ["React Type" : "Photo"])
                                    
                                    println("NEw REact : \(newReact)")
                                    
                                    var peekeeInfosPosition:Int? = self.findPikiInfosPosition(randomNumber)
                                    if peekeeInfosPosition != nil{
                                        println("found")
                                        self.pikiReacts[peekeeInfosPosition!] = newReact
                                        self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: peekeeInfosPosition! + 1, inSection: 1)])
                                        
                                        self.hasNewReacts = true
                                        
                                        self.mainPiki!.fetchInBackground()
                                        
                                        //Push notif
                                        self.sendPushNewComment(isPublic!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                                            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                            bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                            
                                            Utils().setPikiAsView(self.mainPiki!)
                                            return nil
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
                            
                            //self.pikiReacts.insert(newReact, atIndex: 0)
                            //self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0)])
                        }
                        
                    }
                    
                    
                }
                
            }
        }
    }



    
    /*
    * Camera functions
    *
    */
    
    func beginSession(viewToUse : UIView) {
        
        
        
        var authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if authStatus == AVAuthorizationStatus.Authorized{
            println("Already AUTH")
            //configureDevice()
            audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            var errAudio : NSError? = nil
            audioDeviceInput = AVCaptureDeviceInput(device: audioCaptureDevice, error: &errAudio)
            if errAudio != nil{
                println("Problem to get audio input : \(errAudio!.localizedDescription)")
            }
            else{
                /*if captureSession.canAddInput(audioDeviceInput){
                captureSession.addInput(audioDeviceInput)
                println("ADD")
                }*/
            }
            
            
            
            
            var err : NSError? = nil
            
            var tempCaptureDevice = AVCaptureDeviceInput(device: captureDevice, error: &err)
            
            if captureSession.canAddInput(tempCaptureDevice){
                captureDeviceInput = tempCaptureDevice
                captureSession.addInput(captureDeviceInput!)
            }
            
            
            if err != nil {
                println("error: \(err?.localizedDescription)")
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            previewLayer?.frame = viewToUse.layer.frame
            viewToUse.layer.addSublayer(previewLayer)
            
            
            
            var imageOutputTemp = AVCaptureStillImageOutput()
            imageOutputTemp.outputSettings = NSDictionary(object: AVVideoCodecJPEG, forKey: AVVideoCodecKey)
            if captureSession.canAddOutput(imageOutputTemp){
                println("Capture add image output")
                imageOutput = imageOutputTemp
                captureSession.addOutput(imageOutput)
            }
            
            
            //Movie output
            var tempVideoOutput = AVCaptureMovieFileOutput()
            let totalSeconds:Float64 = 10
            let preferedTimeScale:Int32 = 30
            let maxDuration:CMTime = CMTimeMakeWithSeconds(totalSeconds, preferedTimeScale)
            tempVideoOutput.maxRecordedDuration = maxDuration
            tempVideoOutput.minFreeDiskSpaceLimit = 1024 * 1024
            if captureSession.canAddOutput(tempVideoOutput){
                videoOutput = tempVideoOutput
                captureSession.addOutput(videoOutput!)
            }
            
            captureSession.startRunning()
        }
        else if authStatus == AVAuthorizationStatus.NotDetermined{
            
            if !authorizing{
                authorizing = true
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (succeed) -> Void in
                    if succeed{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
                            var errAudio : NSError? = nil
                            self.audioDeviceInput = AVCaptureDeviceInput(device: self.audioCaptureDevice, error: &errAudio)
                            if errAudio != nil{
                                println("Problem to get audio input : \(errAudio!.localizedDescription)")
                            }
                            else{
                                /*if captureSession.canAddInput(audioDeviceInput){
                                captureSession.addInput(audioDeviceInput)
                                println("ADD")
                                }*/
                            }
                            
                            
                            
                            
                            var err : NSError? = nil
                            self.captureDeviceInput = AVCaptureDeviceInput(device: self.captureDevice, error: &err)
                            if self.captureSession.canAddInput(self.captureDeviceInput!){
                                self.captureSession.addInput(self.captureDeviceInput!)
                            }
                            
                            
                            if err != nil {
                                println("error: \(err?.localizedDescription)")
                            }
                            
                            
                            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                            self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                            
                            self.previewLayer?.frame = viewToUse.layer.frame
                            viewToUse.layer.addSublayer(self.previewLayer)
                            
                            
                            
                            
                            
                            self.imageOutput = AVCaptureStillImageOutput()
                            self.imageOutput!.outputSettings = NSDictionary(object: AVVideoCodecJPEG, forKey: AVVideoCodecKey)
                            if self.captureSession.canAddOutput(self.imageOutput){
                                self.captureSession.addOutput(self.imageOutput)
                            }
                            
                            
                            //Movie output
                            self.videoOutput = AVCaptureMovieFileOutput()
                            let totalSeconds:Float64 = 10
                            let preferedTimeScale:Int32 = 30
                            let maxDuration:CMTime = CMTimeMakeWithSeconds(totalSeconds, preferedTimeScale)
                            self.videoOutput!.maxRecordedDuration = maxDuration
                            self.videoOutput!.minFreeDiskSpaceLimit = 1024 * 1024
                            if self.captureSession.canAddOutput(self.videoOutput!){
                                self.captureSession.addOutput(self.videoOutput!)
                            }
                            
                            
                            self.captureSession.startRunning()
                        })
                        
                        
                        
                    }
                    else{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.camDenied()
                        })
                        
                    }
                })
            }
            
            
        }
        else{
            self.camDenied()
        }
        
        
    }
    
    func addAudio(){
        //var successful = BFTaskCompletionSource()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            self.captureSession.beginConfiguration()
            
            self.audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            var errAudio : NSError? = nil
            self.audioDeviceInput = AVCaptureDeviceInput(device: self.audioCaptureDevice, error: &errAudio)
            if errAudio != nil{
                println("Problem to get audio input : \(errAudio!.localizedDescription)")
            }
            
            if self.audioDeviceInput != nil {
                if self.captureSession.canAddInput(self.audioDeviceInput){
                    self.captureSession.addInput(self.audioDeviceInput)
                    
                }
                
            }
            
            self.captureSession.commitConfiguration()
            
        }
        

    
        //return successful.task
    }
    
    func removeAudio(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.captureSession.beginConfiguration()
            
            if self.audioDeviceInput != nil {
                self.captureSession.removeInput(self.audioDeviceInput)
            }
            
            self.captureSession.commitConfiguration()
        }
        
    }
    
    
    func switchCamera(button : UIButton){
        self.changeCameraPosition()
    }
    
    func changeCameraPosition(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            var preferredPosition:AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            var currentPosition:AVCaptureDevicePosition = self.captureDevice!.position
            
            switch currentPosition{
                
            case AVCaptureDevicePosition.Unspecified:
                preferredPosition = AVCaptureDevicePosition.Front
                
            case AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
                
            case AVCaptureDevicePosition.Back:
                preferredPosition = AVCaptureDevicePosition.Front
                
            default:
                preferredPosition = AVCaptureDevicePosition.Back
            }
            
            self.captureSession.beginConfiguration()
            
            let devices = AVCaptureDevice.devices()
            var tempCaptureDevice:AVCaptureDevice?
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == preferredPosition) {
                        tempCaptureDevice = device as? AVCaptureDevice
                    }
                }
            }
            
            
            var videoCaptureDeviceInput:AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(tempCaptureDevice, error: nil) as AVCaptureDeviceInput
            
            self.captureSession.removeInput(self.captureDeviceInput!)
            
            if self.captureSession.canAddInput(videoCaptureDeviceInput){
                self.captureSession.addInput(videoCaptureDeviceInput)
                self.captureDevice = tempCaptureDevice
                self.captureDeviceInput = videoCaptureDeviceInput
            }
            else{
                self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice, error: nil))
            }
            
            self.captureSession.commitConfiguration()
            
        }
    }
    
    
    func uploadImage(image : UIImage){
        
        var imageData:NSData = UIImageJPEGRepresentation(image, 0.5)
        imageFile = PFFile(name: "photo.jpg", data: imageData)
        
        
        
        
        imageFile!.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
            println(succeeded)
            }, progressBlock: { (progress:Int32) -> Void in
            println(progress)
        })
        
    }
    
    
    /*
    * SERVER
    */
    
    func getLastPiki(){
        
        var requestPiki:PFQuery = PFQuery(className: "Piki")
        requestPiki.orderByDescending("createdAt")
        requestPiki.getFirstObjectInBackgroundWithBlock { (piki : PFObject!, error : NSError!) -> Void in
            
            if piki != nil{
                
                //If there is already a Piki, see if it is the same
                if self.mainPiki != nil {
                    if self.mainPiki!.objectId != piki.objectId{
                        self.mainPiki = piki
                        var file:PFFile = piki["photo"] as PFFile
                        
                        self.getLastReact()
                        
                        file.getDataInBackgroundWithBlock({ (imageData : NSData!, error : NSError!) -> Void in
                            if error == nil {
                                self.mainPhotoImageView!.image = UIImage(data: imageData)
                            }
                        })
                    }
                    else{
                        self.getLastReact()
                    }
                }
                else{
                    self.mainPiki = piki
                    var file:PFFile = piki["photo"] as PFFile
                    
                    self.getLastReact()
                    
                    file.getDataInBackgroundWithBlock({ (imageData : NSData!, error : NSError!) -> Void in
                        if error == nil {
                            self.mainPhotoImageView!.image = UIImage(data: imageData)
                        }
                    })
                }
                
                
                
            }
        }
        
    }
    
    func getLastReact(){
        
        if self.mainPiki != nil {
            var requestReacts:PFQuery = PFQuery(className: "React")
            requestReacts.orderByDescending("createdAt")
            requestReacts.whereKey("Piki", equalTo: self.mainPiki)
        
            
            requestReacts.findObjectsInBackgroundWithBlock { (reacts : [AnyObject]!, error : NSError!) -> Void in
                if error == nil{
                    self.videoReacts.removeAll(keepCapacity: false)
                    self.pikiReacts = reacts as Array<PFObject>
                    self.collectionView!.reloadData()
                    self.collectionView?.layoutIfNeeded()
                }
            }
        }
        
    }
    
    
    /*
    * LIKE
    */
    
    func likePhoto(){
        
        var bgTaskIdentifierUploadReact:UIBackgroundTaskIdentifier?
        
        //See if front camera, otherwise change orientation
        
        if actualMode == 0{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var videoConnection : AVCaptureConnection?
                for connecton in self.imageOutput!.connections {
                    //find a matching input port
                    println("connections")
                    for port in connecton.inputPorts!{
                        println("input port")
                        if port.mediaType == AVMediaTypeVideo {
                            println("video port")
                            videoConnection = connecton as? AVCaptureConnection
                            break //for port
                        }
                    }
                    
                    if videoConnection  != nil {
                        break// for connections
                    }
                }
                if videoConnection  != nil {
                    Mixpanel.sharedInstance().timeEvent("Send React")
                    self.imageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection){
                        (imageSampleBuffer : CMSampleBuffer!, _) in
                        
                        let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        var pickedImage: UIImage = UIImage(data: imageDataJpeg!)!
                        
                        var flippedImage:UIImage?
                        if self.captureDevice!.position == AVCaptureDevicePosition.Front {
                            flippedImage = UIImage(CGImage: pickedImage.CGImage, scale: pickedImage.scale, orientation: UIImageOrientation.LeftMirrored)
                        }
                        else{
                            flippedImage = pickedImage
                        }
                        
                        var squareImage = RBSquareImageTo(flippedImage!, CGSize(width: 400, height: 400))
                        
                        
                        self.photoTaken = squareImage
                        //self.uploadImage(self.getPhotoWithLikeOverlay(squareImage))
                        let finalImage:UIImage = self.getPhotoWithLikeOverlay(squareImage)
                        
                        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
                        cameraCell.overlayCameraView.hidden = true
                        
                        self.deselectAllEmojis()
                        
                        var randomNumber = self.randomNumber()
                        
                        //Add photo now to the collection
                        var pikiInfos:[String : AnyObject] = [String : AnyObject]()
                        pikiInfos["photo"] = finalImage
                        pikiInfos["id"] = randomNumber
                        
                        self.postNewTempReact(pikiInfos)
                        
                        
                        //Hide et deslect all emojis butt
                        
                        
                        //Upload file
                        self.uploadImage(finalImage)
                        
                        
                        
                        //Create React
                        if self.imageFile != nil{
                            if self.mainPiki != nil{
                                var newReact:PFObject = PFObject(className: "React")
                                newReact["photo"] = self.imageFile!
                                newReact["Piki"] = self.mainPiki!
                                newReact["user"] = PFUser.currentUser()
                                var reactACL:PFACL = PFACL()
                                reactACL.setPublicReadAccess(true)
                                reactACL.setWriteAccess(true, forUser: PFUser.currentUser())
                                if self.mainPiki!["user"] != nil {
                                    reactACL.setWriteAccess(true, forUser: self.mainPiki!["user"] as PFUser)
                                }
                                
                                newReact.ACL = reactACL
                                
                                
                                //Start a background task
                                bgTaskIdentifierUploadReact = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                                    UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                    bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                })
                                
                                
                                newReact.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
                                    if succeeded{
                                        Mixpanel.sharedInstance().people.increment(["React Sent" : 1, "React Emoji Sent" : 1])
                                        FBAppEvents.logEvent("Send React", parameters: ["React Type" : "Emoji"])
                                        Mixpanel.sharedInstance().track("Send React", properties: ["React Type" : "Emoji"])
                                        
                                        //Push notif
                                        var isPublic:Bool?
                                        if self.mainPiki!["isPublic"] != nil {
                                            isPublic = self.mainPiki!["isPublic"] as? Bool
                                        }
                                        else{
                                            isPublic = true
                                        }
                                        
                                        
                                        var peekeeInfosPosition:Int? = self.findPikiInfosPosition(randomNumber)
                                        if peekeeInfosPosition != nil{
                                            println("found")
                                            self.pikiReacts[peekeeInfosPosition!] = newReact
                                            self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: peekeeInfosPosition! + 1, inSection: 1)])
                                            
                                            self.hasNewReacts = true
                                            
                                            self.mainPiki!.fetchIfNeededInBackground()
                                            
                                            //Push notif
                                            self.sendPushNewComment(isPublic!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                                                UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                                bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                                
                                                Utils().setPikiAsView(self.mainPiki!)
                                                return nil
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
                        
                        
                    }
                    
                }
            }
        }

    }
    
    /*
    * Build photos with different layers
    */

    
    
    func getPhotoWithTextOverlay(image : UIImage) -> UIImage {
        var blackOverlayImage:UIImage?
        
        
        
        
        
        var overlayView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.4
        
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        
        let size:CGSize = CGSize(width: cameraCell.frame.size.width * UIScreen.mainScreen().scale, height: cameraCell.frame.size.width * UIScreen.mainScreen().scale)
        
        
        
        var imageLabel:UIImage?
        cameraCell.textViewOverPhoto!.editable = false
        if (cameraCell.textViewOverPhoto!.text as NSString).length > 0{
            UIGraphicsBeginImageContextWithOptions(cameraCell.textViewOverPhoto!.frame.size, false, 0.0);
            cameraCell.textViewOverPhoto!.layer.renderInContext(UIGraphicsGetCurrentContext())
            imageLabel = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        cameraCell.textViewOverPhoto!.editable = true
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0);
        overlayView.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        blackOverlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIGraphicsBeginImageContext(size)
        
        image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        blackOverlayImage!.drawInRect(CGRect(x: 0, y: 0, width: size.width , height: size.height))
        
        if imageLabel != nil{
            imageLabel!.drawInRect(CGRect(x: 0, y: cameraCell.textViewOverPhoto!.frame.origin.y * UIScreen.mainScreen().scale, width: imageLabel!.size.width * UIScreen.mainScreen().scale, height: imageLabel!.size.height * UIScreen.mainScreen().scale))
        }
        
        
        
        var finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    
    
    func getPhotoWithLikeOverlay(image : UIImage) ->  UIImage {
        
        
        var imageLike:UIImage?
        var blackOverlayImage:UIImage?
        
        
        
        
        
        var overlayView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.4
        
        var selectedCell:ReactsCollectionViewCell?
        
        
        for cell in collectionView!.visibleCells() as Array<UICollectionViewCell>{
            
            let indexPathCell = collectionView!.indexPathForCell(cell as UICollectionViewCell)
            if indexPathCell!.section == 1{
                if indexPathCell!.item == 0{
                    selectedCell = cell as ReactsCollectionViewCell
                    
                }
            }
            
            
        }
        
        if selectedCell == nil{
            println("nil")
        }
        
        
        let size:CGSize = CGSize(width: selectedCell!.frame.size.width * UIScreen.mainScreen().scale, height: selectedCell!.frame.size.width * UIScreen.mainScreen().scale)
        
        
        
        let sizeLikeImage:CGSize = CGSize(width: selectedCell!.emojiImageView!.frame.size.width * UIScreen.mainScreen().scale, height: selectedCell!.emojiImageView!.frame.size.height * UIScreen.mainScreen().scale)
        UIGraphicsBeginImageContextWithOptions(sizeLikeImage, false, 0.0);
        selectedCell!.emojiImageView!.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        imageLike = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        /*UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0);
        overlayView.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        blackOverlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();*/
        
        UIGraphicsBeginImageContext(size)
        
        image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        /*blackOverlayImage!.drawInRect(CGRect(x: 0, y: 0, width: size.width * UIScreen.mainScreen().scale , height: size.height * UIScreen.mainScreen().scale))*/
        imageLike!.drawInRect(CGRect(x: 0, y: 0, width: imageLike!.size.width *  UIScreen.mainScreen().scale, height: imageLike!.size.height  * UIScreen.mainScreen().scale))
        
        
        var finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
        
    }
    
    
    /*
    * TEXTFIELD functions
    */
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    
    /*
    * Capture File Recording Delegate
    */
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
    
        var bgTaskIdentifierUploadReact:UIBackgroundTaskIdentifier?
        
        if error != nil {
            println("Error : \(error.localizedDescription)")
        }
        
        for cell in collectionView!.visibleCells() as Array<UICollectionViewCell>{
            
            let indexPathCell = collectionView!.indexPathForCell(cell as UICollectionViewCell)
            if indexPathCell!.section == 1{
                if indexPathCell!.item == 0{
                    (cell as ReactsCollectionViewCell).recordVideoBar!.removeFromSuperview()
                }
            }
            
            
        }
        
        var recordedSuccessfully = true
        
        if error != nil{
            if error.code != 0{
                //An error occured
                var value: AnyObject! = error.userInfo![AVErrorRecordingSuccessfullyFinishedKey]
                if value != nil{
                    recordedSuccessfully = value.boolValue
                }
                
            }
        }
        
        
        if recordedSuccessfully {
            
            

            Mixpanel.sharedInstance().timeEvent("Send React")
            Utils().cropVideo(outputFileURL, captureDevice: self.captureDevice!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                if task.error != nil{
                    println("Error : \(error.localizedDescription)")
                }
                else{
                    var finalURL = task.result as NSURL
                    let screenImage:UIImage = Utils().getImageFrameFromVideo(finalURL)
                    var imageData:NSData = UIImageJPEGRepresentation(screenImage, 0.8)
                    
                    var randomNumber = self.randomNumber()
                    
                    //Add photo now to the collection
                    var pikiInfos:[String : AnyObject] = [String : AnyObject]()
                    pikiInfos["videoPath"] = finalURL
                    pikiInfos["previewImage"] = UIImage(data: imageData)
                    pikiInfos["id"] = randomNumber

                    dispatch_async(dispatch_get_main_queue(), {

                        
                        self.pikiReacts.insert(pikiInfos, atIndex: 0)
                        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)])
                        self.leaveReply()
                        //self.startVideoOnVisibleCells()
                    })
                    
                    

                    
                    self.imageFile = PFFile(name: "video.mp4", contentsAtPath: finalURL.path!)
                    
                    
                    
                    
                    
                    
                    /*
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        var player:AVPlayer = AVPlayer(URL: finalURL)
                        var playerLayer:AVPlayerLayer = AVPlayerLayer(player: player)
                        playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
                        self.mainPhotoView!.layer.addSublayer(playerLayer)
                        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                        player.muted = true
                        player.play()
                        
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)

                    })*/
                    
                    
                    //Start a background task
                    bgTaskIdentifierUploadReact = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                        UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                        bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                    })
                    
                    
                    
                    let previewFile:PFFile = PFFile(name: "photo.jpg", data: imageData)
                    previewFile.saveInBackgroundWithBlock({ (succeeded : Bool, error : NSError!) -> Void in
                        
                        }, progressBlock: { (progress : Int32) -> Void in
                        println("Preview : \(progress)")
                    })
                    
                    
                    var newVideoReact:PFObject = PFObject(className: "React")
                    self.imageFile!.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
                        if succeeded{
                            //self.pikiReacts.insert(newVideoReact, atIndex: 0)
                            //self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0)])
                        }
                        
                        }, progressBlock: { (progress:Int32) -> Void in
                            println(progress)
                    })
                    
                    //Push notif
                    var isPublic:Bool?
                    if self.mainPiki!["isPublic"] != nil {
                        isPublic = self.mainPiki!["isPublic"] as? Bool
                    }
                    else{
                        isPublic = true
                    }
                    
                    
                    
                    newVideoReact["video"] = self.imageFile!
                    newVideoReact["previewImage"] = previewFile
                    newVideoReact["Piki"] = self.mainPiki!
                    
                    if PFUser.currentUser() != nil{
                        newVideoReact["user"] = PFUser.currentUser()
                        var reactACL:PFACL = PFACL()
                        
                        if isPublic!{
                            reactACL.setPublicReadAccess(true)
                        }
                        else{
                            for userId in self.mainPiki!["recipients"] as Array<String>{
                                reactACL.setReadAccess(true, forUserId: userId)
                            }
                        }
                        
                        
                        reactACL.setWriteAccess(true, forUser: PFUser.currentUser())
                        if self.mainPiki!["user"] != nil {
                            reactACL.setWriteAccess(true, forUser: self.mainPiki!["user"] as PFUser)
                        }
                        newVideoReact.ACL = reactACL
                    }
                    
                    
                    newVideoReact.saveInBackgroundWithBlock({ (success :Bool, error : NSError!) -> Void in
                        if success{
                            Mixpanel.sharedInstance().people.increment(["React Sent" : 1, "React Video Sent" : 1])
                            FBAppEvents.logEvent("Send React", parameters: ["React Type" : "Video"])
                            Mixpanel.sharedInstance().track("Send React", properties: ["React Type" : "Video"])

                            var peekeeInfosPosition:Int? = self.findPikiInfosPosition(randomNumber)
                            if peekeeInfosPosition != nil{
                                println("found")
                                self.pikiReacts[peekeeInfosPosition!] = newVideoReact
                                self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: peekeeInfosPosition! + 1, inSection: 1)])
                                
                                self.hasNewReacts = true
                                
                                //Push notif
                                self.sendPushNewComment(isPublic!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                                    UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                    bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                    
                                    Utils().setPikiAsView(self.mainPiki!)
                                    return nil
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
                
                return nil
            })
            
            //removeAudio()
            
        }
        
    }
    
    
    // Quit button
    func quit(){
        
        //removeAudio()
         muteAllVideos()
        captureSession.stopRunning()
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
        var player:AVPlayerItem = notification.object as AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }

    
    
    override func viewWillDisappear(animated: Bool) {
        self.captureSession.removeInput(audioDeviceInput)
        self.captureSession.removeInput(captureDeviceInput)
        self.captureSession.stopRunning()
    }
    
    
    
    
    
    
    /*
    * Scroll View Delegate
    */
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

        if scrollView == self.collectionView{
            let originYNbReactsView:CGFloat = self.view.frame.size.width + 80 - nbreactsView!.frame.size.height
            
            if originYNbReactsView - scrollView.contentOffset.y > 80{
                nbreactsView!.hidden = true
                nbPeopleView!.hidden = false
                
                
                nbreactsView!.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y)
                
                nbPeopleView!.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y)
                
                
                
            }
            else{
                nbPeopleView!.hidden = true
                nbreactsView!.hidden = false
                
                nbreactsView!.transform = CGAffineTransformMakeTranslation(0, -(originYNbReactsView - 80))
            }
        }
        
        
        
        
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        //pauseAndMuteAllVideos()
        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
        
        if indexPathBig != nil{
            self.cellSmaller(self.collectionView!.cellForItemAtIndexPath(indexPathBig!) as ReactsCollectionViewCell)
        }
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if !decelerate{
            println("End Dragging")
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
            for cell in self.collectionView!.visibleCells() as Array<ReactsCollectionViewCell> {
                
                let indexPath:NSIndexPath? = self.collectionView!.indexPathForCell(cell)
                
                if let index = indexPath {
                    if index.item > 0{
                        
                        if self.pikiReacts[index.item - 1].isKindOfClass(PFObject){
                            let pikiReact:PFObject = self.pikiReacts[index.item-1] as PFObject
                            
                            if pikiReact["video"] != nil{

                                
                                dispatch_async(dispatch_get_main_queue(), { ()->() in
                                    cell.iconInfo!.hidden = false
                                })
                                
                                
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
                                    let videoFile:PFFile = pikiReact["video"] as PFFile
                                    
                                    videoFile.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                                        
                                        
                                        var fileManager:NSFileManager = NSFileManager()
                                        if data.writeToFile("\(NSTemporaryDirectory())_\(pikiReact.objectId).mov", atomically: false){
                                            
                                            
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
                            else{
                                cell.iconInfo!.hidden = true
                            }
                        }
                            
                        else{
                            var pikiInfos:[String : AnyObject] = self.pikiReacts[index.item-1] as [String : AnyObject]
                            
                            if pikiInfos["videoPath"] != nil {
                                cell.iconInfo!.hidden = false
                                
                                var playerItem:AVPlayerItem = AVPlayerItem(URL: pikiInfos["videoPath"] as NSURL)
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
                            else{
                                cell.iconInfo!.hidden = true
                            }
                        }
                        
                        
                    }
                }
                
                
            }
        })
        
        
        
        
    }
    
    
    func pauseAndMuteAllVideos(){
        println("Pause and mute")
        
        dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
            for cell in self.collectionView!.visibleCells() as Array<UICollectionViewCell>{
                
                
                let indexPath:NSIndexPath? = self.collectionView!.indexPathForCell(cell)
                
                if indexPath!.section > 0{
                    if indexPath != nil {
                        if (cell as ReactsCollectionViewCell).playerLayer.player != nil{
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                (cell as ReactsCollectionViewCell).playerLayer.player.pause()
                                (cell as ReactsCollectionViewCell).playerLayer.player = nil
                            })
                            
                            
                        }
                    }
                }
                else{
                    if indexPath != nil {
                        if (cell as MainPeekeeCollectionViewCell).playerLayer.player != nil{
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                (cell as MainPeekeeCollectionViewCell).playerLayer.player.pause()
                                (cell as MainPeekeeCollectionViewCell).loadIndicator.hidden = true
                                (cell as MainPeekeeCollectionViewCell).readVideoIcon.hidden = false
                            })
                            
                            
                        }
                    }
                }
                
                
            }
        })
    }
    
    
    func muteAllVideos(){
        
        dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
            for cell in self.collectionView!.visibleCells() as Array<UICollectionViewCell>{
                
                if cell.isKindOfClass(ReactsCollectionViewCell){
                    let cellReact : ReactsCollectionViewCell = cell as ReactsCollectionViewCell
                    if cellReact.playerLayer.player != nil{
                        cellReact.playerLayer.player.muted = true
                        dispatch_async(dispatch_get_main_queue(), {
                            cellReact.iconInfo!.hidden = false
                        })
                        
                    }
                }
                else{
                    let cellReact : MainPeekeeCollectionViewCell = cell as MainPeekeeCollectionViewCell
                    if cellReact.playerLayer.player != nil {
                        cellReact.playerLayer.player.muted = true
                        cellReact.playerLayer.player.pause()
                    }
                }
                
                
                
                
            }
        })
        
        
    }
    
    func muteAllVideosExcept(indexPath : NSIndexPath){
        
        dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
            for cell in self.collectionView!.visibleCells() as Array<UICollectionViewCell>{
                
                
                if cell.isKindOfClass(ReactsCollectionViewCell){
                    
                    let cellReact : ReactsCollectionViewCell = cell as ReactsCollectionViewCell
                    
                    if self.collectionView!.indexPathForCell(cellReact)?.item != indexPath.item{
                        if cellReact.playerLayer.player != nil{
                            cellReact.playerLayer.player.muted = true
                            dispatch_async(dispatch_get_main_queue(), {
                                cellReact.iconInfo!.hidden = false
                            })
                        }
                    }
                }
                else{
                    
                }
                
                
                
                
                
            }
        })
        
        
    }
    
    
    
    
    /*
    * Action Reacts
    */
    
    
    func recordVideoReact(sender : UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began{

            //Create temporary URL to record to
            let outpuPath:NSString = "\(NSTemporaryDirectory())output-\(NSDate()).mov"
            let outputURL:NSURL = NSURL(fileURLWithPath: outpuPath)!
            var fileManager:NSFileManager = NSFileManager()
            
            for cell in collectionView!.visibleCells() as Array<UICollectionViewCell>{
                
                let indexPathCell = collectionView!.indexPathForCell(cell as UICollectionViewCell)
                if indexPathCell!.section == 1{
                    if indexPathCell!.item == 0{
                        
                        
                        
                        (cell as ReactsCollectionViewCell).startRecording()
                        timerReact = NSTimer(timeInterval: 5, target: self, selector: Selector("endRecording"), userInfo: nil, repeats: false)
                        NSRunLoop.currentRunLoop().addTimer(timerReact!, forMode: NSRunLoopCommonModes)
                    }
                }
                
                
            }

            //Start Recording
            self.isRecording = true
            videoOutput!.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
            
            
        }
        else if sender.state == UIGestureRecognizerState.Ended {

            self.timerReact!.invalidate()
            
            if isRecording{
                videoOutput!.stopRecording()
            }
            
        }
    }
    
    
    func endRecording(){
        
        if isRecording{
            videoOutput!.stopRecording()
        }
        
    }
    
    
    func takeReact(recognizer: UITapGestureRecognizer){
        
        if isAnEmojiShowed(){
            self.likePhoto()
            
        }
        else if isInTextMode(){
            postTextReact()
        }
        else{
            takePhotoFromCell()
        }
        
        
    }
    
    
    func reducActions(){
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.cameraActionButton!.frame = CGRect(x: 15 + 36, y: self.view.frame.height - 80 + 36, width: 0, height: 0)
            
            self.emojiActionButton!.frame = CGRect(x: self.view.frame.size.width - 75 + 31, y: self.view.frame.height - 62 + 31, width: 0, height: 0)
            
        }) { (completed) -> Void in
        }
        
    }
    
    func getBackActions(full : Bool){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            if full {
                self.cameraActionButton!.frame = CGRect(x: 15, y: self.view.frame.height - 80, width: 71, height: 72)
                
                self.emojiActionButton!.frame = CGRect(x: self.view.frame.size.width - 75, y: self.view.frame.height - 70, width: 61, height: 62)
            }
            else{
                self.cameraActionButton!.frame = CGRect(x: 33, y: self.view.frame.height - 62, width: 36, height: 36)
                
                self.emojiActionButton!.frame = CGRect(x: self.view.frame.size.width - 60, y: self.view.frame.height - 55, width: 31, height: 31)
            }
            
            
            }) { (completed) -> Void in
        }
    }
    
    

    func getReacts(){
        
        var requestReact:PFQuery = PFQuery(className: "React")
        requestReact.whereKey("Piki", equalTo: mainPiki)
        requestReact.orderByDescending("createdAt")
        requestReact.limit = 50
        requestReact.cachePolicy = kPFCachePolicyCacheThenNetwork
        requestReact.includeKey("user")
        
        requestReact.findObjectsInBackgroundWithBlock { (reacts, error) -> Void in
            self.refreshControl.endRefreshing()
            if error != nil{
                
            }
            else{
                
                if self.pikiReacts.count == 0{
                    self.pikiReacts = reacts as Array<PFObject>
                    
                    for react in self.pikiReacts{
                    }
                    
                    self.collectionView!.reloadData()
                }
                else{
                    var nbReactToInsert:Int = 0
                    for react in reacts as Array<PFObject> {
                        var alreadyIn:Bool = false
                        for actualReact in self.pikiReacts{
                            if react.objectId == actualReact.objectId{
                                alreadyIn = true
                                break
                            }
                        }
                        
                        if !alreadyIn{
                            self.pikiReacts.insert(react, atIndex: nbReactToInsert)
                            //self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: nbReactToInsert, inSection: 0)])
                            //self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: nbReactToInsert, inSection: 0)])
                            nbReactToInsert++
                        }
                        
                        
                    }
                    
                    if nbReactToInsert > 0{
                        var indexToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                        for index in 1...(nbReactToInsert){
                            indexToInsert.append(NSIndexPath(forItem: index, inSection: 1))
                        }
                        
                        self.collectionView!.performBatchUpdates({ () -> Void in
                            self.collectionView!.insertItemsAtIndexPaths(indexToInsert)
                        }, completion: { (completed) -> Void in
                        })
                        
                        
                    }
                    else{
                        //self.startVideoOnVisibleCells()
                    }

                    
                }
                
            }
        }
        
        
    }
    
    
    func getMoreReacts(){
        
        
        var skipNumber:Int = self.pikiReacts.count
        
        var firstTimeDone:Bool = false
        
        var requestReact:PFQuery = PFQuery(className: "React")
        requestReact.whereKey("Piki", equalTo: mainPiki)
        requestReact.orderByDescending("createdAt")
        requestReact.limit = 50
        requestReact.skip = skipNumber
        //requestReact.cachePolicy = kPFCachePolicyCacheThenNetwork
        requestReact.includeKey("user")
        
        requestReact.findObjectsInBackgroundWithBlock { (reacts, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if firstTimeDone{
                    self.isLoadingMore = false
                }
                
                firstTimeDone = true
                
                
                self.refreshControl.endRefreshing()
                if error != nil{
                    
                }
                else{
                    
                    if self.pikiReacts.count == 0{
                        self.pikiReacts = reacts as Array<PFObject>
                        
                        for react in self.pikiReacts{
                        }
                        
                        self.collectionView!.reloadData()
                    }
                    else{
                        var nbReactToInsert:Int = 0
                        for react in reacts as Array<PFObject> {
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
            captureSession.stopRunning()
            pauseAndMuteAllVideos()
            var listRecipientsController:ListRecipientsViewController = segue.destinationViewController as ListRecipientsViewController
            listRecipientsController.mainPiki = self.mainPiki!
            
        }
    }

    
    
    func goInTextMode(){
        
        for button in arrayEmojisButton{
            button.hidden = true
        }
        
        self.backCameraActionView.hidden = true
        
        
        
        
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        cameraCell.textViewOverPhoto!.becomeFirstResponder()
        cameraCell.textViewOverPhoto!.text = ""
        
    }
    
    func leaveTextMode(){
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        cameraCell.overlayCameraView!.hidden = true
        cameraCell.textViewOverPhoto!.resignFirstResponder()
        deselectAllEmojis()
        cameraCell.textViewOverPhoto!.text = "Your text here 😀"
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
    
    
    
    // MARK: Keyboard
    
    //Keyboard Notifs
    func keyboardWillShow(notification : NSNotification){
        
        self.view.addGestureRecognizer(tapToDismissKeyboard!)
        
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
        let animationDuration: NSTimeInterval = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        
        
        self.nbPeopleView!.hidden = true
        self.nbreactsView!.hidden = true
        
        self.arrayEmojisButton[0].hidden = false
        self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        self.backCameraActionView!.hidden = true
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            
            
            self.cameraActionButton!.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height)
            self.backEmojiButtonSelected.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height)
            self.arrayEmojisButton[0].transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height)
            self.topOverlay.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height + (self.view.frame.height - (80 + self.view.frame.width + self.view.frame.width/3)))
            self.middleOverlay.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height + (self.view.frame.height - (80 + self.view.frame.width + self.view.frame.width/3)))
            self.bottomOverlay.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height + (self.view.frame.height - (80 + self.view.frame.width + self.view.frame.width/3)))
            self.collectionView!.transform = CGAffineTransformMakeTranslation(0, -keyboardSize.height + (self.view.frame.height - (80 + self.view.frame.width + self.view.frame.width/3)))
            
            }) { (finished) -> Void in
        }
        
        
    }
    
    func keyboardWillHide(notification : NSNotification){
        
        self.view.removeGestureRecognizer(tapToDismissKeyboard!)
        
        for button in arrayEmojisButton{
            button.hidden = false
        }
        
       let animationDuration: NSTimeInterval = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            
            self.backEmojiButtonSelected.transform = CGAffineTransformIdentity
            self.arrayEmojisButton[0].transform = CGAffineTransformIdentity
            self.cameraActionButton!.transform = CGAffineTransformIdentity
            self.collectionView!.transform = CGAffineTransformIdentity
            self.topOverlay.transform = CGAffineTransformIdentity
            self.middleOverlay.transform = CGAffineTransformIdentity
            self.bottomOverlay.transform = CGAffineTransformIdentity
            
            }) { (finished) -> Void in
                self.nbreactsView!.hidden = true
                self.backCameraActionView!.hidden = false
                
        }
        
    }
    
    func dismissKeyboard(gesture : UITapGestureRecognizer){
        
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        cameraCell.textViewOverPhoto!.resignFirstResponder()
        cameraCell.overlayCameraView!.hidden = true
        
    }
    
    
    // MARK: ReactCollectionViewCell Deelegate
    
    func postTextReact() {
        
        var bgTaskIdentifierUploadReact:UIBackgroundTaskIdentifier?
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var videoConnection : AVCaptureConnection?
            for connecton in self.imageOutput!.connections {
                //find a matching input port
                for port in connecton.inputPorts!{
                    if port.mediaType == AVMediaTypeVideo {
                        videoConnection = connecton as? AVCaptureConnection
                        break //for port
                    }
                }
                
                if videoConnection  != nil {
                    break// for connections
                }
            }
            if videoConnection  != nil {
                Mixpanel.sharedInstance().timeEvent("Send React")
                self.imageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection){
                    (imageSampleBuffer : CMSampleBuffer!, _) in
                    
                    let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    var pickedImage: UIImage = UIImage(data: imageDataJpeg!)!
                    
                    var flippedImage:UIImage?
                    if self.captureDevice!.position == AVCaptureDevicePosition.Front {
                        flippedImage = UIImage(CGImage: pickedImage.CGImage, scale: pickedImage.scale, orientation: UIImageOrientation.LeftMirrored)
                    }
                    else{
                        flippedImage = pickedImage
                    }
                    
                    var squareImage = RBSquareImageTo(flippedImage!, CGSize(width: 400, height: 400))
                    
                    
                    self.photoTaken = squareImage
                    //self.uploadImage(self.getPhotoWithLikeOverlay(squareImage))
                    var finalImage:UIImage = self.getPhotoWithTextOverlay(squareImage)
                    
                    var randomNumber = self.randomNumber()
                    
                    //Add photo now to the collection
                    var pikiInfos:[String : AnyObject] = [String : AnyObject]()
                    pikiInfos["photo"] = finalImage
                    pikiInfos["id"] = randomNumber
                    
                    self.postNewTempReact(pikiInfos)
                    
                    self.leaveTextMode()

                    
                    
                    
                    
                    //Upload file
                    self.uploadImage(finalImage)
                    
                    
                    
                    
                    //Create React
                    if self.imageFile != nil{
                        if self.mainPiki != nil{
                            var newReact:PFObject = PFObject(className: "React")
                            newReact["photo"] = self.imageFile!
                            newReact["Piki"] = self.mainPiki!
                            newReact["user"] = PFUser.currentUser()
                            var reactACL:PFACL = PFACL()
                            reactACL.setPublicReadAccess(true)
                            reactACL.setWriteAccess(true, forUser: PFUser.currentUser())
                            if self.mainPiki!["user"] != nil {
                                reactACL.setWriteAccess(true, forUser: self.mainPiki!["user"] as PFUser)
                            }
                            
                            newReact.ACL = reactACL
                            
                            
                            
                            //Start a background task
                            bgTaskIdentifierUploadReact = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                                UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                            })
                            
                            
                            
                            
                            newReact.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
                                if succeeded{
                                    Mixpanel.sharedInstance().people.increment(["React Sent" : 1, "React Text Sent" : 1])
                                    FBAppEvents.logEvent("Send React", parameters: ["React Type" : "Text"])
                                    Mixpanel.sharedInstance().track("Send React", properties: ["React Type" : "Text"])
                                    
                                    //Push notif
                                    var isPublic:Bool?
                                    if self.mainPiki!["isPublic"] != nil {
                                        isPublic = self.mainPiki!["isPublic"] as? Bool
                                    }
                                    else{
                                        isPublic = true
                                    }
                                    
                                    var peekeeInfosPosition:Int? = self.findPikiInfosPosition(randomNumber)
                                    if peekeeInfosPosition != nil{
                                        println("found")
                                        self.pikiReacts[peekeeInfosPosition!] = newReact
                                        self.collectionView!.reloadItemsAtIndexPaths([NSIndexPath(forItem: peekeeInfosPosition! + 1, inSection: 1)])
                                        
                                        self.hasNewReacts = true
                                        
                                        self.mainPiki!.fetchIfNeededInBackground()
                                        
                                        self.sendPushNewComment(isPublic!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                                            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                            bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                            
                                            return nil
                                        })
                                        
                                    }
                                    else{
                                        println("delete")
                                        newReact.deleteEventually()
                                        
                                        UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                        bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                    }
                                    
                                    
                                    
                                    //self.getLastReact()
                                    
                                }
                                else{
                                    println("Error while creating new react")
                                    UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierUploadReact!)
                                    bgTaskIdentifierUploadReact = UIBackgroundTaskInvalid
                                }
                            })
                        }
                        
                    }
                    
                    
                }
                
            }
        }
        
        
    }

    
    func seeUserWhoPosted(user : PFUser){
        
        presentPopUpForUser(user)
        
    }
    
    
    func printUsernamesreact(){
        for cell in self.collectionView!.visibleCells() as Array<UICollectionViewCell>{
            if cell.isKindOfClass(ReactsCollectionViewCell){
                (cell as ReactsCollectionViewCell).showUsername()
            }
            
        }
    }
    
    func hideUsernamesreact(){
        for cell in self.collectionView!.visibleCells() as Array<UICollectionViewCell>{
            if cell.isKindOfClass(ReactsCollectionViewCell){
                (cell as ReactsCollectionViewCell).hideUserName()
            }
            
        }
    }
    
    
    func removeReact(react : AnyObject, isReport : Bool){
        println("React \(react)")
        
        if react.isKindOfClass(PFObject){
            if !isReport{
                self.removeReactFromList(react)
            }
            
            var reactObject: PFObject = react as PFObject
            PFCloud.callFunctionInBackground("reportOrRemoveReact ", withParameters: ["reactId" : reactObject.objectId]) { (result, error) -> Void in
                if error != nil {
                    if isReport{
                        let alert = UIAlertView(title: "Error", message: "Problem while reporting this react. Please try again later",
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    else{
                        let alert = UIAlertView(title: "Error", message: "Problem while deleting this react. Please try again later",
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                    
                }
                else{
                    if isReport{
                        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
                        
                        let alert = UIAlertView(title: "Report", message: "This react has been reported. Thank you.",
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    else{
                        let alert = UIAlertView(title: "Delete", message: "Your react has been deleted.",
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                    }
                }
            }
        }
        else{
            self.removeReactFromList(react)
        }
        
        
        
    }
    
    
    func cellBigger(cell : ReactsCollectionViewCell){
        
        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
        
        //Bigger
        var cellToReduce:ReactsCollectionViewCell?
        if indexPathBig != nil{
            cellToReduce = self.collectionView!.cellForItemAtIndexPath(indexPathBig!) as? ReactsCollectionViewCell
            cellSmaller(cellToReduce!)
        }
        
        
        
        self.indexPathBig = self.collectionView!.indexPathForCell(cell)
        self.collectionView!.collectionViewLayout.invalidateLayout()
        //cell.addFriendsView.alpha = 1.0
        
        UIView.transitionWithView(cell, duration: 0.5, options: nil,
            animations: { () -> Void in
                
                //cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.width, (self.view.frame.width - 2)/3 * 2)
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, (self.view.frame.width - 2)/3 * 2, (self.view.frame.width - 2)/3 * 2)
                //cell.reactImage.frame = CGRectMake(0, 0, (cell.frame.width - 2)/3 * 2, (cell.frame.width - 2)/3 * 2)
                cell.reactImage.frame = CGRectMake(0, 0, cell.frame.width, cell.frame.height)
                cell.usernameLabel!.frame = CGRectMake(0,cell.reactImage.frame.height - 25, cell.reactImage.frame.width, 25)
                cell.playerView.frame = CGRectMake(0, 0, cell.reactImage.frame.width, cell.reactImage.frame.height)
                cell.playerLayer.frame = CGRectMake(0, 0, cell.reactImage.frame.width, cell.reactImage.frame.height)
                cell.loadIndicator!.center = cell.playerView.center
                cell.readVideoImageView.center = cell.playerView.center
                cell.insideCollectionView.frame = CGRectMake(0, 0, cell.reactImage.frame.width, cell.reactImage.frame.height)
                //cell.addFriendsView.frame = CGRectMake(cell.reactImage.frame.width + 1, 0, cell.frame.width - cell.reactImage.frame.width - 1, cell.frame.height)
                cell.insideCollectionView.reloadData()
            }, completion: { (finisehd) -> Void in
                //cell.showMoreInfos()
                cell.isInBigMode = true
                self.collectionView!.scrollToItemAtIndexPath(self.indexPathBig!, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
                cell.startVideo()
                NSNotificationCenter.defaultCenter().postNotificationName("scrollEnded", object: nil)
        })
        
    }
    
    func cellSmaller(cell : ReactsCollectionViewCell){
        
        self.indexPathBig = nil
        self.collectionView!.collectionViewLayout.invalidateLayout()
    
        
        cell.stopVideo()
        //cell.addFriendsView.alpha = 0.0
        
        
        if cell.moreInfosIconeUserImageView != nil{
            cell.moreInfosUsernameLabel!.hidden = true
            cell.moreInfosIconeUserImageView!.hidden = true
            cell.moreInfosUserAdd!.hidden = true
        }
        
        
        UIView.transitionWithView(cell, duration: 0.2, options: nil,
            animations: { () -> Void in
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,  (self.view.frame.size.width - 2)/3,  (self.view.frame.size.width - 2)/3)
                cell.usernameLabel!.frame = CGRectMake(0,cell.frame.height - 25, cell.frame.width, 25)
                cell.reactImage.frame = CGRectMake(0, 0, (self.view.frame.size.width - 2)/3, (self.view.frame.size.width - 2)/3)
                cell.playerView.frame = CGRectMake(0, 0, (self.view.frame.size.width - 2)/3, (self.view.frame.size.width - 2)/3)
                cell.playerLayer.frame = CGRectMake(0, 0, (self.view.frame.size.width - 2)/3, (self.view.frame.size.width - 2)/3)
                cell.insideCollectionView.frame = CGRectMake(0, 0, (self.view.frame.size.width - 2)/3, (self.view.frame.size.width - 2)/3)
                cell.insideCollectionView.reloadData()
                cell.loadIndicator!.center = cell.playerView.center
                cell.readVideoImageView.center = cell.playerView.center
                //cell.addFriendsView.frame = CGRectMake(0, 0, 0, 0)
                
                
            }, completion: { (finisehd) -> Void in
                cell.isInBigMode = false
        })
        
    }
    
    func removeReact(cell: ReactsCollectionViewCell) {
        
        if indexPathBig != nil{
            
            cellSmaller(self.collectionView!.cellForItemAtIndexPath(indexPathBig!) as ReactsCollectionViewCell)
            
        }
        
        cell.removeReact()
        
    }
    
    
    
    // MARK: Pop Up
    
    func presentPopUpForUser(user : PFUser){
        
        muteAllVideos()
        
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
            usernameLabel.text = "@\(user.username)"
            usernameLabel.tag = 10
            popUpView!.addSubview(usernameLabel)
            
            let addFriend:UIButton = UIButton(frame: CGRect(x: popUpView!.frame.width/2, y: 124, width: popUpView!.frame.width/2, height: popUpView!.frame.height - 124))
            addFriend.addTarget(self, action: Selector("addFriendFromPopUp"), forControlEvents: UIControlEvents.TouchUpInside)
            addFriend.tag = 11
            popUpView!.addSubview(addFriend)
            
            
        }
        
        
        self.popUpView!.transform =  CGAffineTransformMakeScale(0, 0)
        let labelUsername:UILabel = popUpView!.viewWithTag(10) as UILabel
        labelUsername.text = "@\(user.username)"
        let labelHeader:UILabel = popUpView!.viewWithTag(12) as UILabel
        
        let actionButton:UIButton = popUpView!.viewWithTag(11) as UIButton
        
        if Utils().isUserAFriend(user){
            actionButton.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            labelHeader.text = NSLocalizedString("ADD A FRIEND", comment : "ADD A FRIEND")
        }
        else{
            actionButton.setImage(UIImage(named: "add_friends_icon_pop_up"), forState: UIControlState.Normal)
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
        println("Add Friend")
        
        if userPopUp != nil {
            
            if Utils().isUserAFriend(userPopUp!){
                
                Utils().removeFriend(userPopUp!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                    if task.error != nil{
                        
                    }
                    else{
                        (self.popUpView!.viewWithTag(11) as UIButton).setImage(UIImage(named: "mute_icon"), forState: UIControlState.Normal)
                    }
                    
                    return nil
                })
            }
            else{
                //Not a friend, friend him
                Utils().addFriend(self.userPopUp!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                    if task.error != nil{
                        
                    }
                    else{
                        (self.popUpView!.viewWithTag(11) as UIButton).setImage(UIImage(named: "mute_icon"), forState: UIControlState.Normal)
                    }
                    
                    return nil
                    
                })
                
            }
            
        }
        
    }
    
    
    
    func sendPushNewComment(isPublic : Bool) -> BFTask{
        
        var task = BFTaskCompletionSource()
        
        let userPiki:PFUser = self.mainPiki!["user"] as PFUser
        PFCloud.callFunctionInBackground("sendPushNewComment", withParameters:["recipients":self.mainPiki!["recipients"], "isPublic" : isPublic, "pikiId" : self.mainPiki!.objectId, "ownerId" : userPiki.objectId]) {
            (result: AnyObject!, error: NSError!) -> Void in
            
            if error != nil{
                task.setError(error)
            }
            else{
                task.setResult(result)
            }

        }
        
        
        return task.task
    }
    
    
    
    // MARK: VIDEO FUNCTIONS
    
    func setURL(react : PFObject, cell : ReactsCollectionViewCell){
        
        let videoFile:PFFile = react["video"] as PFFile
        
        var remoteUrl: NSURL? = NSURL(string: videoFile.url)
        if remoteUrl? != nil && remoteUrl?.scheme? != nil {
            if let asset = AVURLAsset(URL: remoteUrl, options: nil) {
                let keys: [String] = [PlayerTracksKey, PlayerPlayableKey, PlayerDurationKey]
                
                if let asset = AVURLAsset(URL: remoteUrl, options: nil) {
                    
                    //self.asset = asset
                    
                    asset.loadValuesAsynchronouslyForKeys(keys, completionHandler: { () -> Void in
                        for key in keys {
                            var error: NSError?
                            let status = asset.statusOfValueForKey(key, error:&error)
                            if status == .Failed {
                                println("Failed")
                                return
                            }
                        }
                        
                        if asset.playable.boolValue == false {
                            println("Playable")
                            return
                        }
                        
                        println("Setup")
                        
                        if !self.isAssetExisting(react){
                            self.saveAssetForReact(asset, react: react)
                            self.setAssetForCell(asset, cell: cell)
                        }
                        else{
                            self.setAssetForCell(self.getAssetForReact(react)!, cell: cell)
                        }
                        
                        
                    })
                    
                }
            }
        }

    }
    
    
    func setAssetForCell(asset : AVURLAsset, cell : ReactsCollectionViewCell){

        if !self.collectionView!.dragging && !self.collectionView!.decelerating{
            
            let indexPathCell:NSIndexPath? = self.collectionView!.indexPathForCell(cell)
            let indexPathVisibleCells:Array<NSIndexPath>? = self.collectionView!.indexPathsForVisibleItems() as? Array<NSIndexPath>
            
            if indexPathCell != nil{
                if indexPathVisibleCells != nil{
                    
                    if contains(indexPathVisibleCells!, indexPathCell!){

                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            let playerItem: AVPlayerItem = AVPlayerItem(asset: asset)
                            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
                            
                            
                            var player = AVPlayer(playerItem: playerItem)
                            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                            player.muted = true
                            cell.playerLayer.player = player
                            cell.playerView!.hidden = false
                            player.play()
                        })
                        
                        
                    }
                    
                }
            }
        }
        
        
    }
    
    
    func saveAssetForReact(asset : AVURLAsset, react : PFObject){
        playerItmes.append(["reactId" : react.objectId, "asset" : asset])
    }
    
    func isAssetExisting(react : PFObject) -> Bool{
        
        for playerItemsInfo in playerItmes{
            
            if playerItemsInfo["reactId"] as? String == react.objectId{
                return true
            }
            
        }
        
        return false
        
    }
    
    
    func getAssetForReact(react : PFObject) -> AVURLAsset? {
        
        var asset:AVURLAsset?
        
        for playerItemsInfo in playerItmes{
            
            if playerItemsInfo["reactId"] as? String == react.objectId{
                asset = playerItemsInfo["asset"] as? AVURLAsset
                
                return asset
            }
            
        }
        
        
        return asset
        
    }
    
    
    // MARK: Overlay Tuto
    
    func showOverlayTuto(){
        
        if overlayTuto == nil{
            
            let tapGestureLeaveTuto:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leaveTuto"))
            
            overlayTuto = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayTuto.backgroundColor = UIColor.clearColor()
            overlayTuto.addGestureRecognizer(tapGestureLeaveTuto)
            
            let mainOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80 + self.view.frame.width + 1))
            mainOverlay.backgroundColor = UIColor.blackColor()
            mainOverlay.alpha = 0.7
            overlayTuto.addSubview(mainOverlay)
            
            let cameraOverlay = UIView(frame: CGRect(x: 0, y: 80 + self.view.frame.width, width: self.view.frame.width/3 + 1, height: self.view.frame.width/3))
            cameraOverlay.backgroundColor = UIColor.blackColor()
            cameraOverlay.alpha = 0.7
            overlayTuto.addSubview(cameraOverlay)
            
            let oneReactOverlay = UIView(frame: CGRect(x: (self.view.frame.width/3) * 2, y: 80 + self.view.frame.width, width: self.view.frame.width/3, height: self.view.frame.width/3))
            oneReactOverlay.backgroundColor = UIColor.blackColor()
            oneReactOverlay.alpha = 0.7
            overlayTuto.addSubview(oneReactOverlay)
            
            let restScreenOverlay = UIView(frame: CGRect(x: 0, y: 80 + self.view.frame.width + self.view.frame.width/3, width: self.view.frame.width, height: self.view.frame.height - (80 + self.view.frame.width + self.view.frame.width/3)))
            restScreenOverlay.backgroundColor = UIColor.blackColor()
            restScreenOverlay.alpha = 0.7
            overlayTuto.addSubview(restScreenOverlay)
            
            let imageButton  = UIImageView(frame: CGRect(x: replyButton!.frame.origin.x, y: replyButton!.frame.origin.y, width: replyButton!.frame.width, height: replyButton!.frame.height))
            imageButton.image = UIImage(named: "reply_button")
            overlayTuto.addSubview(imageButton)
            
            let lineReact = UIImageView(frame: CGRect(x: cameraOverlay.frame.width + 5, y: cameraOverlay.frame.origin.y - 100, width: 6, height: 113))
            lineReact.image = UIImage(named: "peekee_line_react")
            overlayTuto.addSubview(lineReact)
            
            let lineButton = UIImageView(frame: CGRect(x: replyButton!.center.x - 3, y: replyButton!.frame.origin.y - 280 , width: 6, height: 275))
            lineButton.image = UIImage(named: "peekee_line_button")
            overlayTuto.addSubview(lineButton)
            
            
            let reactLabel = UILabel(frame: CGRect(x: 5, y: lineReact.frame.origin.y - 28 , width: 200, height: 22))
            reactLabel.adjustsFontSizeToFitWidth = true
            reactLabel.font = UIFont(name: Utils().customGothamBol, size: 30.0)
            reactLabel.textColor = UIColor.whiteColor()
            reactLabel.text = NSLocalizedString("This is a reaction 🎉", comment : "This is a reaction 🎉") 
            overlayTuto.addSubview(reactLabel)
            
            let buttonLabel = UILabel(frame: CGRect(x: lineButton.frame.origin.x - 140, y: lineButton.frame.origin.y - 50 , width: 140, height: 43))
            buttonLabel.numberOfLines = 2
            buttonLabel.adjustsFontSizeToFitWidth = true
            buttonLabel.font = UIFont(name: Utils().customGothamBol, size: 30.0)
            buttonLabel.textColor = UIColor.whiteColor()
            buttonLabel.text = NSLocalizedString("Add your own reaction", comment : "Add your own reaction")
            overlayTuto.addSubview(buttonLabel)
            
            let beerLabel = UILabel(frame: CGRect(x: buttonLabel.frame.origin.x + 140, y: buttonLabel.frame.origin.y , width: 40, height: 43))
            beerLabel.font = UIFont(name: Utils().customGothamBol, size: 30.0)
            beerLabel.text = "🍻"
            overlayTuto.addSubview(beerLabel)
            
            
            self.view.addSubview(overlayTuto)
            
            
        }
        
        PFUser.currentUser()["hasShownOverlayPeekee"] = true
        PFUser.currentUser().saveInBackgroundWithBlock { (finished, error) -> Void in
            PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                println("UPDATE USER")
            })
        }
        
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
                    
                    if (reactIncrement["id"] as Int) == (react["id"] as Int){
                        position = j
                    }
                }
                
                j++
            }
        }
        
        
        
        
        self.pikiReacts.removeAtIndex(position)
        self.collectionView!.deleteItemsAtIndexPaths([NSIndexPath(forItem: position + 1, inSection: 1)])
        
    }
    
    
    // MARK: More Peekee
    
    func morePeekee(){
        
        
        if objc_getClass("UIAlertController") != nil {
            
            var alert = UIAlertController(title: NSLocalizedString("More", comment : "More"),
                message: NSLocalizedString("More actions for this Peekee", comment : "More actions for this Peekee"), preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Report this Peekee", comment : "Report this Peekee"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                PFCloud.callFunctionInBackground("reportPiki ",
                    withParameters: ["pikiId" : self.mainPiki!.objectId], block: { (result, error) -> Void in
                        if error != nil{
                            let alert = UIAlertView(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("Problem while reporting this Peekee. Please try again later", comment :"Problem while reporting this Peekee. Please try again later") ,
                                delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                        else{
                            let alert = UIAlertView(title: "Confirmation", message: NSLocalizedString( "This Peekee has been reported. Thank you.", comment :  "This Peekee has been reported. Thank you."),
                                delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                })
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
            
            println("UIAlertController can NOT be instantiated")
            
            //make and use a UIAlertView
        }
        
        
    }
    
    
    
    
    
    
    
    // MARK: Answer / React
    
    
    //Go in answer mode : camera button and emoji buttons
    func replyPeekee(){
        
        if indexPathBig != nil{
            self.cellSmaller(self.collectionView!.cellForItemAtIndexPath(indexPathBig!) as ReactsCollectionViewCell)
        }
        
        
        self.collectionView!.performBatchUpdates({ () -> Void in
            self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        }, completion: { (finished) -> Void in
            // Calculate the move the table view has to made in order to have enough space
            var spaceToMove =  (self.view.frame.height - (20 + 60 + 125 + self.view.frame.width/3)) - self.view.frame.width
            println("Table view to move of : \(spaceToMove)")
            
            
            self.collectionView!.frame = CGRect(x: 0, y: self.collectionView!.frame.origin.y + spaceToMove, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height - spaceToMove)
            self.collectionView!.reloadData()
        })
        
        
        
        
        
        
        self.nbPeopleView!.hidden = true
        
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("scrollStarted", object: nil)
        
        //Show camera action button
        cameraActionButton!.hidden = false
        backCameraActionView.hidden = false
        
        //Hide reply button
        replyButton.hidden = true
        
        self.collectionView!.scrollEnabled = false
        
        /*if Utils().isIphone4(){
            topOverlay.transform = CGAffineTransformMakeTranslation(0, -40)
            middleOverlay.transform = CGAffineTransformMakeTranslation(0, -40)
            bottomOverlay.transform = CGAffineTransformMakeTranslation(0, -40)
            alternativeMiddleOverlay.transform = CGAffineTransformMakeTranslation(0, -40)
            
            nbPeopleView!.transform = CGAffineTransformMakeTranslation(0, -40)
            
            self.collectionView!.frame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height + 40)
            self.collectionView!.transform = CGAffineTransformMakeTranslation(0, -40)
            self.collectionView!.reloadData()
        }*/
        
        
        self.quitButtonReply!.hidden = false
        self.quitButtonReply!.alpha = 0.0
        
        UIView.animateWithDuration(0.3,
            delay:0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 10,
            options: nil,
            animations: { () -> Void in
                
                //Show overlay
                self.topOverlay.alpha = 0.85
                self.middleOverlay.alpha = 1.0
                self.bottomOverlay.alpha = 0.85
                
                self.cameraActionButton!.alpha = 1.0
                self.cameraActionButton!.transform = CGAffineTransformIdentity
                self.backCameraActionView!.alpha = 0.4
                self.backCameraActionView!.transform = CGAffineTransformIdentity
                
                self.quitButtonReply!.alpha = 1.0
                self.quitButtonReply!.center = CGPoint(x: 40, y: self.replyButton.center.y)
            }, completion: { (finished) -> Void in
                self.memCollectionView.reloadData()
        })
        
        var position:Int = 0
        for button in arrayEmojisButton{
            
            UIView.animateWithDuration(0.2,
                delay: Double(position) * 0.1,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 10,
                options: nil,
                animations: { () -> Void in
                    button.transform = CGAffineTransformIdentity
            }, completion: { (finished) -> Void in
            })
            
            position++
            
        }
        
        
        
    }
    
    //Leave reply mode
    func leaveReply(){
        
        NSNotificationCenter.defaultCenter().postNotificationName("scrollEnded", object: nil)
        
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        
        if cameraCell.textViewOverPhoto!.isFirstResponder(){
            var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
            cameraCell.textViewOverPhoto!.resignFirstResponder()
            cameraCell.overlayCameraView!.hidden = true
            deselectAllEmojis()
        }
        else{
            deselectAllEmojis()
            
            
            /*if Utils().isIphone4(){
                self.collectionView!.frame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height - 40)
                self.collectionView!.transform = CGAffineTransformIdentity
                self.collectionView!.reloadData()
                
                topOverlay.transform = CGAffineTransformIdentity
                middleOverlay.transform = CGAffineTransformIdentity
                bottomOverlay.transform = CGAffineTransformIdentity
                alternativeMiddleOverlay.transform = CGAffineTransformIdentity
                nbPeopleView!.transform = CGAffineTransformIdentity
            }*/
            
            UIView.animateWithDuration(0.3,
                delay:0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 10,
                options: nil,
                animations: { () -> Void in
                    var translateCameraButton:CGFloat = self.replyButton.center.x - self.cameraActionButton!.center.x
                    self.cameraActionButton!.alpha = 0.0
                    self.cameraActionButton!.transform = CGAffineTransformMakeTranslation(translateCameraButton, 0)
                    self.backCameraActionView!.alpha = 0.0
                    self.backCameraActionView!.transform = CGAffineTransformMakeTranslation(translateCameraButton, 0)
                    
                    //Hide overlay
                    self.topOverlay.alpha = 0.0
                    self.middleOverlay.alpha = 0.0
                    self.bottomOverlay.alpha = 0.0
                    
                    // Calculate the move the table view has to made in order to have enough space
                    var spaceToMove =  (self.view.frame.height - (20 + 60 + 125 + self.view.frame.width/3)) - self.view.frame.width
                    
                    self.collectionView!.frame = CGRect(x: 0, y: self.collectionView!.frame.origin.y - spaceToMove, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height + spaceToMove)
                    
                    self.quitButtonReply!.center = self.replyButton.center
                    self.quitButtonReply!.alpha = 0.0
                    
                    
                }, completion: { (finished) -> Void in
                    self.cameraActionButton!.hidden = true
                    self.backCameraActionView!.hidden = true
                    self.replyButton.hidden = false
                    
                    self.quitButtonReply!.hidden = true
                    
                    self.collectionView!.scrollEnabled = true
                    self.nbPeopleView!.hidden = false
                    
            })
            
            
            
            
            
            for button in arrayEmojisButton{
                button.transform = CGAffineTransformMakeScale(0, 0)
            }
            
            removeAudio()
        }
        
        
        
        
        
    }
    
    func selectEmoji(button : UIButton){
        
        switch button{
        case arrayEmojisButton[0]:
            if arrayEmojisButton[0].selected{
                hideEmojis()
                arrayEmojisButton[0].selected = false
                leaveTextMode()
            }
            else{
                deselectAllEmojis()
                showEmojis(0)
                arrayEmojisButton[0].selected = true
            }
            
            
        case arrayEmojisButton[1]:
            
            if arrayEmojisButton[1].selected{
                hideEmojis()
                arrayEmojisButton[1].selected = false
            }
            else{
                deselectAllEmojis()
                showEmojis(1)
                arrayEmojisButton[1].selected = true
            }
        case arrayEmojisButton[2]:
            
            if arrayEmojisButton[2].selected{
                hideEmojis()
                arrayEmojisButton[2].selected = false
            }
            else{
                deselectAllEmojis()
                showEmojis(2)
                arrayEmojisButton[2].selected = true
            }
            
        case arrayEmojisButton[3]:
            if arrayEmojisButton[3].selected{
                hideEmojis()
                arrayEmojisButton[3].selected = false
            }
            else{
                deselectAllEmojis()
                showEmojis(3)
                arrayEmojisButton[3].selected = true
            }
            
        default:
            println("default")
        }
        
    }
    
    
    func deselectAllEmojis(){
        
        for button in arrayEmojisButton{
            button.selected = false
        }
        
        hideEmojis()
        self.backCameraActionView.hidden = false
        
    }
    
    func isInTextMode() -> Bool{
        if arrayEmojisButton[0].selected{
            return true
        }
        
        return false
    }
    
    func isAnEmojiShowed() -> Bool{
        
        if positionMemShowed != nil{
            return true
        }
        
        return false
    
    }
    
    func hideEmojis(){
        backCameraActionView.hidden = false
        backEmojiButtonSelected.hidden = true
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        cameraCell.overlayCameraView.hidden = true
        cameraCell.emojiImageView.hidden = true
        cameraCell.textViewOverPhoto!.hidden = true
        
        self.isMemShowed = false
    }
    
    
    func hideMem(){
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        cameraCell.overlayCameraView.hidden = true
        cameraCell.emojiImageView.hidden = true
        cameraCell.textViewOverPhoto!.hidden = true
    }
    
    func showMem(position : Int){
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        
        cameraCell.textViewOverPhoto!.hidden = true
        cameraCell.emojiImageView!.hidden = false
        cameraCell.overlayCameraView.hidden = true
        cameraCell.emojiImageView.image = (self.memCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: position, inSection: 0)) as MemCollectionViewCell).iconImageView.image
        
        self.isMemShowed = true
    }
    
    
    func showEmojis(position: Int){
        
        var cameraCell:ReactsCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1)) as ReactsCollectionViewCell
        
        cameraCell.textViewOverPhoto!.hidden = true
        
        backCameraActionView.hidden = true
        arrayEmojisButton[position].selected = true
        backEmojiButtonSelected.center = CGPoint(x: arrayEmojisButton[position].center.x, y: arrayEmojisButton[position].center.y - 2)
        backEmojiButtonSelected.hidden = false
        cameraCell.emojiImageView!.hidden = false
        cameraCell.overlayCameraView.hidden = true
        
        switch position{
        case 0:
            cameraCell.overlayCameraView.hidden = false
            cameraCell.textViewOverPhoto!.hidden = false
            cameraCell.emojiImageView!.hidden = true
            cameraCell.textViewOverPhoto!.frame = CGRect(x: 0, y: cameraCell.frame.height/2 - getHeightTextView(cameraCell.textViewOverPhoto!, string: cameraCell.textViewOverPhoto!.text)/2, width: cameraCell.textViewOverPhoto!.frame.width, height: cameraCell.textViewOverPhoto!.frame.height)
            cameraCell.textViewOverPhoto!.text = "Your text here 😀"
            goInTextMode()
        case 1:
            cameraCell.emojiImageView.image = UIImage(named: "awesome")
        case 2:
            cameraCell.emojiImageView.image = UIImage(named: "cute")
        case 3:
            cameraCell.emojiImageView.image = UIImage(named: "fuck")
        default:
            cameraCell.emojiImageView.image = UIImage(named: "awesome")
        }
        
        
        //cameraCell.overlayCameraView.hidden = false
        
    }
    
    //MARK: Share View
    
    func showShareView(){
        
        if bottomShareView == nil{
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
            shareTitleLabel.text = NSLocalizedString("SEND", comment : "SEND")
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
            let shareSMSButton = UIButton(frame: CGRect(x: 30, y: 79, width: 64, height: 64))
            shareSMSButton.setImage(UIImage(named: "sms_share_icon"), forState: UIControlState.Normal)
            shareSMSButton.addTarget(self, action: Selector("shareSms"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareSMSButton)
            
            //Twitter Share
            let shareTwitterButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width/2 - 32, y: 79, width: 64, height: 64))
            shareTwitterButton.setImage(UIImage(named: "twitter_share_icon"), forState: UIControlState.Normal)
            shareTwitterButton.addTarget(self, action: Selector("shareTwitter"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareTwitterButton)
            
            //Facebook Share
            let shareFacebookButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width - 98, y: 79, width: 64, height: 64))
            shareFacebookButton.setImage(UIImage(named: "facebook_share_icon"), forState: UIControlState.Normal)
            shareFacebookButton.addTarget(self, action: Selector("shareFacebook"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareFacebookButton)
            
            // Instagram Share
            let shareInstagramButton = UIButton(frame: CGRect(x: 30, y: 168, width: 64, height: 64))
            shareInstagramButton.setImage(UIImage(named: "instagram_share_icon"), forState: UIControlState.Normal)
            shareInstagramButton.addTarget(self, action: Selector("shareInstagram"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareInstagramButton)
            
            // Save Share
            let shareSaveButton = UIButton(frame: CGRect(x: bottomShareView!.frame.width/2 - 32, y: 168, width: 64, height: 64))
            shareSaveButton.setImage(UIImage(named: "save_share_icon"), forState: UIControlState.Normal)
            shareSaveButton.addTarget(self, action: Selector("shareSave"), forControlEvents: UIControlEvents.TouchUpInside)
            bottomShareView!.addSubview(shareSaveButton)
            
            
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
        }
        
        
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
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.bottomShareView!.transform = CGAffineTransformMakeTranslation(0, self.bottomShareView!.frame.height)
            }) { (finished) -> Void in
                self.shareOverlay!.hidden = true
                self.imageContainerView!.hidden = true
                self.setNeedsStatusBarAppearanceUpdate()
        }
        
        
    }
    
    func shareInstagram(){
        
        
        Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Instagram"])
        
        let instagramURL : NSURL = NSURL(string: "instagram://app")!
        
        if UIApplication.sharedApplication().canOpenURL(instagramURL){
            viewToBuildImage!.transform = CGAffineTransformIdentity
            
            var image = Utils().imageWithView(viewToBuildImage!)
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            
            
            
            
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
                        self.documentInteractionController!.annotation = ["InstagramCaption" : "Awesome friends mozaic created with @Peekeeapp #peekee"]
                        
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
                    self.documentInteractionController!.annotation = ["InstagramCaption" : "Awesome friends mozaic created with @Peekeeapp #peekee"]
                    
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
            
            Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Twitter"])
            
            var composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            viewToBuildImage!.transform = CGAffineTransformIdentity
            
            var image = Utils().imageWithView(viewToBuildImage!)
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            
            composer.addImage(image)
            composer.setInitialText("Awesome friends mozaic created with @Peekeeapp")
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
        
        viewToBuildImage!.transform = CGAffineTransformIdentity
        
        var image = Utils().imageWithView(viewToBuildImage!)
        
        let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
        viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
        
        var params : FBPhotoParams = FBPhotoParams()
        params.photos = [image]

        
        
        if FBDialogs.canPresentShareDialogWithPhotos() {
            
            Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Facebook"])
            
            FBDialogs.presentShareDialogWithPhotoParams(params,
                clientState: nil,
                handler: { (appCall, result, error) -> Void in
                    if error != nil{
                        println("\(error.description)")
                        
                    }
                    else{
                        println("Result : \(result)")
                    }
            })
        }
        else{
            
        }
    }
    
    func shareSave(){
        if viewToBuildImage != nil{
            
            Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "Save"])
            
            viewToBuildImage!.transform = CGAffineTransformIdentity
            
            var image = Utils().imageWithView(viewToBuildImage!)
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            
            
            let library = ALAssetsLibrary()
            library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.Up) { (url, error) -> Void in
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
    }
    
    func shareSms(){
        
        Mixpanel.sharedInstance().track("Share", properties: ["Canal" : "SMS"])
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        var messageController:MFMessageComposeViewController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.body = String(format: NSLocalizedString("SendInvitSMS", comment : ""), Utils().shareAppUrl)
        
        if MFMessageComposeViewController.respondsToSelector(Selector("canSendAttachments")){
            
            viewToBuildImage!.transform = CGAffineTransformIdentity
            
            var image = Utils().imageWithView(viewToBuildImage!)
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            
            let attachementsData:NSData = UIImageJPEGRepresentation(image, 1.0)
            
            messageController.addAttachmentData(attachementsData, typeIdentifier: "public.data", filename: "mymozaic.jpg")
        }
        
        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
        
        
    }
    
    func buildViewShare(){
        
        
        
        
        
        var nbReacts:Int? = self.mainPiki!["nbReaction"] as? Int
        var arrayImageViewReact:Array<UIImageView> = Array<UIImageView>()
        
        if nbReacts == nil{
            nbReacts = 0
        }
        
        for react in self.pikiReacts{
            if !react.isKindOfClass(PFObject){
                nbReacts!++
            }
        }
        
        if nbReacts! > 5{
            showShareView()
            
            //MainSHare View
            viewToBuildImage = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
            viewToBuildImage!.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            
            //Main peekee image view
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
            
            //Icon Peekee
            var iconPeekee = UIImageView(frame: CGRect(x: 15, y: viewMainPeekeeContainer.frame.height - 60, width: 50, height: 50))
            iconPeekee.layer.cornerRadius = 15
            iconPeekee.clipsToBounds = true
            iconPeekee.image = UIImage(named: "app_icon")
            viewMainPeekeeContainer.addSubview(iconPeekee)
            
            //User label
            let userMainPeekee = self.mainPiki!["user"] as PFUser
            var userLabel = UILabel(frame: CGRect(x: iconPeekee.frame.origin.x + iconPeekee.frame.width + 20, y: iconPeekee.frame.origin.y, width: viewMainPeekeeContainer.frame.width - (iconPeekee.frame.origin.x + iconPeekee.frame.width + 20 + 10), height: 30))
            userLabel.font = UIFont(name: Utils().customFontSemiBold, size: 24.0)
            userLabel.textColor = UIColor.whiteColor()
            let onPeekeeFormat = String(format: NSLocalizedString("%@ on Peekee", comment : "%@ on Peekee"), userMainPeekee.username)
            userLabel.text = onPeekeeFormat
            viewMainPeekeeContainer.addSubview(userLabel)
            
            //Label when
            var creationDate:NSDate = self.mainPiki!.createdAt
            
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
            peekeeInfosView.backgroundColor = Utils().secondColor
            viewToBuildImage!.addSubview(peekeeInfosView)
            
            var labelNbReply:UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: peekeeInfosView.frame.width - 30, height: peekeeInfosView.frame.height))
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
            peekeeInfosView.addSubview(appleIcon)
            
            //Android Icon
            var androidIcon = UIImageView(frame: CGRect(x: 137, y: 195, width: 20, height: 24))
            androidIcon.image = UIImage(named: "android_icon")
            peekeeInfosView.addSubview(androidIcon)
            
            //Reply Icon
            var replyIcon = UIImageView(frame: CGRect(x: 0, y: 40, width: peekeeInfosView.frame.width, height: 25))
            replyIcon.contentMode = UIViewContentMode.Center
            replyIcon.image = UIImage(named: "reply_icon_share")
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
                        
                        println("Divider : \(positionYMore)")
                        
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
                        
                        println("Divider : \(positionYMore)")
                        
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
                
                var alert = UIAlertController(title: NSLocalizedString("Share", comment : "Share"), message: NSLocalizedString("AlertNotEnoughReact", comment : "Sorry but you need to have at least 6 answers to this Peekee in order to create your mozaic! Try to post some answers yourself to create your own mozaic!"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    self.sendSMSToContacts()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            var position:Int = 0
            var nbReactDone:Int = 0

            
            for react in self.pikiReacts {

                if arrayImageViewReact.count > 0{

                    
                    if react.isKindOfClass(PFObject){
                        
                        let reactObject:PFObject = react as PFObject
                        if reactObject["photo"] != nil {
                            
                            let photoFile:PFFile = reactObject["photo"] as PFFile
                            photoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                if error == nil{
                                    if arrayImageViewReact.count > 0{
                                        let imageViewNow:UIImageView = arrayImageViewReact.removeAtIndex(arrayImageViewReact.count - 1)
                                        imageViewNow.image = UIImage(data: data)
                                        nbReactDone++
                                    }
                                    
                                }
                                else{
                                    
                                }
                            })
                        }
                        else{
                            let photoFile:PFFile = reactObject["previewImage"] as PFFile
                            photoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                                if error == nil{
                                    if arrayImageViewReact.count > 0{
                                        let imageViewNow:UIImageView = arrayImageViewReact.removeAtIndex(arrayImageViewReact.count - 1)
                                        imageViewNow.image = UIImage(data: data)
                                        
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
                       
                        var pikiInfos:[String : AnyObject] = react as [String : AnyObject]


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
            
            
            
            
            /*var image = Utils().imageWithView(mainShareView)
            println("image ok")
            
            let library = ALAssetsLibrary()
            library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.Up) { (url, error) -> Void in
            if error != nil {
            
            }
            }*/
            
            let scale:CGFloat = imageContainerView!.frame.height / viewToBuildImage!.frame.height
            
            viewToBuildImage!.transform = CGAffineTransformMakeScale(scale, scale)
            viewToBuildImage!.frame.origin = CGPoint(x: 0, y: 0)
            imageContainerView!.addSubview(viewToBuildImage!)
        }
        else{
            
            var alert = UIAlertController(title: NSLocalizedString("Share", comment : "Share"), message: NSLocalizedString("AlertNotEnoughReact", comment : "Sorry but you need to have at least 6 answers to this Peekee in order to create your mozaic! Try to post some answers yourself to create your own mozaic!"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.sendSMSToContacts()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
        
       
        
        
        
    }
    
    
    // MARK: SMS DELEGATE
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            println("Canceled")
            
        case MessageComposeResultFailed.value:
            println("Failed")
            
        case MessageComposeResultSent.value:
            println("Sent")
            
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        
        
        
    }
    
    
    // MARK: Random Number 
    
    func randomNumber() -> Int{
        var random:Int = 0
        
        random = Int(arc4random_uniform(100000))
        
        return random
    }
    
    
    // MARK: 
    
    func findPikiInfosPosition(intId : Int) -> Int?{
        
        var peekeePosition : Int?
        var position = 0
        
        for react in self.pikiReacts{
            if !react.isKindOfClass(PFObject){
                if react["id"] != nil{
                    var intIdTemp:Int = react["id"] as Int
                    
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
    
    
    
    func postNewTempReact(pikiInfos : [String : AnyObject]){

        
        
        self.pikiReacts.insert(pikiInfos, atIndex: 0)
        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 1)])
        
        self.leaveReply()
        
    }
    
    
    // MARK: Send SMS
    
    func sendSMSToContacts(){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        
        var messageController:MFMessageComposeViewController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.body = String(format: NSLocalizedString("SendInvitSMS", comment : ""), Utils().shareAppUrl)
        
        if MFMessageComposeViewController.respondsToSelector(Selector("canSendAttachments")) && MFMessageComposeViewController.canSendAttachments(){
            messageController.addAttachmentURL(Utils().createGifInvit(PFUser.currentUser().username), withAlternateFilename: "invitationGif.gif")
        }
        
        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
        
        
    }
    
    
    // MARK: Cam Denied
    
    func camDenied(){
        
        
        var canOpenSettings:Bool = false
        
        if UIApplicationOpenSettingsURLString != nil{
            canOpenSettings = true
        }
        
        if canOpenSettings{
            var alert = UIAlertController(title: "Error", message: "To interact with your friends you need to allow the access to your camera. Go to settings to allow it? You'll need to go in the privacy menu", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                
                self.openSettings()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            var alert = UIAlertController(title: "Error", message: "To interact with your friends you need to allow the access to your camera. Please go to Settings > Confidentiality > Camera and allow it for Peekee", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment : "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func openSettings(){
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    
    // MARK: Mem
    
    func getLastMem(){
        
        var queryMem:PFQuery = PFQuery(className: "stickers")
        queryMem.orderByAscending("priorite")
        queryMem.findObjectsInBackgroundWithBlock { (mems, error : NSError!) -> Void in
            if error != nil{
                
            }
            else{
                self.mems = mems as Array<PFObject>
                self.memCollectionView.reloadData()
            }
            
            
        }
        
    }

}


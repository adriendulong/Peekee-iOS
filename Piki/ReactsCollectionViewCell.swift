//
//  ReactsCollectionViewCell.swift
//  Piki
//
//  Created by Adrien Dulong on 09/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import AVFoundation


protocol ReactsCellProtocol: class {
    func removeReact(react : AnyObject, isReport : Bool)
    func shareOneVsOne(react : PFObject)
    
    //Like
    func hasUserLikedThisReact(react : PFObject) -> Bool
    func userJustLiked(react : PFObject)
}

class ReactsCollectionViewCell : UICollectionViewCell {
    
    weak var delegate:ReactsCellProtocol? = nil
    
    var mainViewCell:UIView!
    var flipView:UIView!
    
    var reactImage:PFImageView!
    var playerLayer:AVPlayerLayer!
    var playerView:UIView!
    //let player:AVPlayer!
    var overlayCameraView:UIView!
    var emojiImageView:UIImageView!
    var recordVideoBar:UIView?
    var react:PFObject?
    var player:AVPlayer?
    var ownPosition:Int?
    
    //Delete View
    var readVideoImageView:UIImageView!
    var reactVideoURL:String?
    
    //Empty Cell
    var emptyCaseImageView:UIImageView?
    
    var loadIndicator:UIActivityIndicatorView?
    
    var pikiInfos:[String : AnyObject]?
    
    var mainPeekee:PFObject!
    var isInBigMode:Bool = false
    
    var moreInfosView:UIView!
    
    var hasLoaded:Bool = false
    var reactRandomId:String?
    var reportOrDeleteLabel:UILabel!
    
    //Flip
    var flipPosition:Int = 0
    var usernameLabel:UILabel!
    var nbLikes:UILabel!
    var likesIcon:UIImageView!
    var addUserIcon:UIImageView!
    
    //Colors
    let greyNotSelected:UIColor = UIColor(red: 216/255, green: 215/255, blue: 216/255, alpha: 1.0)
    let blackSelected:UIColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
    
    //Icons
    let imageUserAdded:UIImage = UIImage(named: "friend_added_icon_react")!
    let imageUserNotAdded:UIImage = UIImage(named: "friend_add_icon_react")!
    let imageUserHasLiked:UIImage = UIImage(named: "like_icon_liked")!
    let imageUserHasNotLiked:UIImage = UIImage(named: "like_icon_not_liked")!
    
    var nbLikesView:UIView!
    var nbLikesLabelFront:UILabel!
    var nbLikesImageView:UIImageView!
    var imageLikeFast:UIImageView!
    
    var spinnerView:LLARingSpinnerView!
    var spinnerViewAddFriend:LLARingSpinnerView!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "startNewVideo", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "scrollStarted", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "startFlip", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateLikeInfos", object: nil)
    }
    
    func loadCell(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("newVideoStarted:"), name: "startNewVideo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scrollStarted"), name: "scrollStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("startFlip:"), name: "startFlip", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateLikeInfos:"), name: "updateLikeInfos", object: nil)
        
        contentView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 251/255, alpha: 1.0)
        
        //Flip View
        flipView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.height))
        flipView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 251/255, alpha: 1.0)
        contentView.addSubview(flipView)
        
        
        
        //Username View
        let tapGestureUsernameAdd:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("addFriend"))
        let usernameView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: flipView.frame.width/2, height: flipView.frame.width/2))
        usernameView.addGestureRecognizer(tapGestureUsernameAdd)
        usernameView.backgroundColor = UIColor.clearColor()
        flipView.addSubview(usernameView)
        
        addUserIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: usernameView.frame.width, height: usernameView.frame.height/4 * 3))
        addUserIcon.contentMode = UIViewContentMode.Center
        addUserIcon.image = imageUserAdded
        usernameView.addSubview(addUserIcon)
        
        usernameLabel = UILabel(frame: CGRect(x: 5, y: usernameView.frame.height/2, width: usernameView.frame.width - 10, height: usernameView.frame.height/2))
        usernameLabel.textAlignment = NSTextAlignment.Center
        usernameLabel.font = UIFont(name: Utils().montserratRegular, size: 14)
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.textColor = blackSelected
        usernameView.addSubview(usernameLabel)
        
        spinnerViewAddFriend = LLARingSpinnerView(frame: CGRect(x: usernameView.frame.width/2 - 10, y: usernameView.frame.height/2 - 10, width: 20, height: 20))
        spinnerViewAddFriend.center = addUserIcon.center
        spinnerViewAddFriend.lineWidth = 2
        spinnerViewAddFriend.tintColor = Utils().secondColor
        spinnerViewAddFriend.hidden = true
        usernameView.addSubview(spinnerViewAddFriend)
        spinnerViewAddFriend.startAnimating()
        
        
        //Likes View
        let tapGestureLikeReact:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("likeReact"))
        let likesView:UIView = UIView(frame: CGRect(x: flipView.frame.width/2, y: 0, width: flipView.frame.width/2, height: flipView.frame.width/2))
        likesView.addGestureRecognizer(tapGestureLikeReact)
        likesView.backgroundColor = UIColor.clearColor()
        flipView.addSubview(likesView)
        
        likesIcon = UIImageView(frame: CGRect(x: 5, y: 0, width: likesView.frame.width - 10, height: likesView.frame.height/4 * 3))
        likesIcon.contentMode = UIViewContentMode.Center
        likesIcon.image = imageUserHasNotLiked
        likesView.addSubview(likesIcon)
        
        //Likes
        nbLikes = UILabel(frame: CGRect(x: 0, y: likesView.frame.height/2, width: likesView.frame.width, height: likesView.frame.height/2))
        nbLikes.textAlignment = NSTextAlignment.Center
        nbLikes.font = UIFont(name: Utils().montserratRegular, size: 14)
        nbLikes.adjustsFontSizeToFitWidth = true
        nbLikes.textColor = greyNotSelected
        nbLikes.text = "0"
        likesView.addSubview(nbLikes)

        
        let bottomFlipView:UIView = UIView(frame: CGRect(x: 0, y: flipView.frame.height/2, width: flipView.frame.width, height: flipView.frame.height/2))
        bottomFlipView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 251/255, alpha: 1.0)
        flipView.addSubview(bottomFlipView)
        
        let innerShadowImage:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: flipView.frame.width, height: flipView.frame.height))
        innerShadowImage.image = UIImage(named: "inner_shadow_selected_cell")
        flipView.addSubview(innerShadowImage)
        
        let reportOrDeleteButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: bottomFlipView.frame.width/2, height: bottomFlipView.frame.height/4 * 3))
        reportOrDeleteButton.setImage(UIImage(named: "trash_react_icon"), forState: UIControlState.Normal)
        reportOrDeleteButton.addTarget(self, action: Selector("reportOrRemove"), forControlEvents: UIControlEvents.TouchUpInside)
        reportOrDeleteButton.tag = 10
        bottomFlipView.addSubview(reportOrDeleteButton)
        
        reportOrDeleteLabel = UILabel(frame: CGRect(x: 0, y: bottomFlipView.frame.height/2, width: bottomFlipView.frame.width/2, height: bottomFlipView.frame.height/2))
        reportOrDeleteLabel.textAlignment = NSTextAlignment.Center
        reportOrDeleteLabel.font = UIFont(name: Utils().montserratRegular, size: 12)
        reportOrDeleteLabel.adjustsFontSizeToFitWidth = true
        reportOrDeleteLabel.textColor = blackSelected
        reportOrDeleteLabel.text = LocalizedString("Delete").uppercaseString
        bottomFlipView.addSubview(reportOrDeleteLabel)
        
        let shareReactButton:UIButton = UIButton(frame: CGRect(x: bottomFlipView.frame.width/2, y: 0, width: bottomFlipView.frame.width/2, height: bottomFlipView.frame.height/4 * 3))
        shareReactButton.setImage(UIImage(named: "share_react_icon"), forState: UIControlState.Normal)
        shareReactButton.addTarget(self, action: Selector("shareOne"), forControlEvents: UIControlEvents.TouchUpInside)
        shareReactButton.tag = 11
        bottomFlipView.addSubview(shareReactButton)
        
        let shareReactButtonLabel = UILabel(frame: CGRect(x: bottomFlipView.frame.width/2, y: bottomFlipView.frame.height/2, width: bottomFlipView.frame.width/2, height: bottomFlipView.frame.height/2))
        shareReactButtonLabel.textAlignment = NSTextAlignment.Center
        shareReactButtonLabel.font = UIFont(name: Utils().montserratRegular, size: 12)
        shareReactButtonLabel.adjustsFontSizeToFitWidth = true
        shareReactButtonLabel.textColor = blackSelected
        shareReactButtonLabel.text = LocalizedString("Preview").uppercaseString
        bottomFlipView.addSubview(shareReactButtonLabel)
        
        
        let middleDivider:UIView = UIView(frame: CGRect(x: 0, y: flipView.frame.height/2, width: flipView.frame.width, height: 1))
        middleDivider.backgroundColor = UIColor(red: 213/255, green: 214/255, blue: 216/255, alpha: 1.0)
        flipView.addSubview(middleDivider)
        
        let middleVerticalDivider:UIView = UIView(frame: CGRect(x: flipView.frame.width/2, y: 0, width: 1, height: flipView.frame.height))
        middleVerticalDivider.backgroundColor = UIColor(red: 213/255, green: 214/255, blue: 216/255, alpha: 1.0)
        flipView.addSubview(middleVerticalDivider)
        
        //Main View Cell
        let longTapLike:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("likeLong:"))
        longTapLike.minimumPressDuration = 0.4
        mainViewCell = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        mainViewCell.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 251/255, alpha: 1.0)
        mainViewCell.addGestureRecognizer(longTapLike)
        
        //Image of the React
        reactImage = PFImageView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height))
        mainViewCell.addSubview(reactImage)
        
        
        
        playerView = UIView(frame:  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        
        playerLayer = AVPlayerLayer()
        playerLayer.frame =  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.layer.addSublayer(playerLayer)
        playerView.hidden = true
        mainViewCell.addSubview(playerView)
        
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = self.playerView.center
        loadIndicator!.hidesWhenStopped = true
        loadIndicator!.hidden = true
        mainViewCell.addSubview(loadIndicator!)
        
        overlayCameraView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        overlayCameraView.hidden = true
        mainViewCell.addSubview(overlayCameraView)
        
    
        
        emojiImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: overlayCameraView.frame.size.width, height: overlayCameraView.frame.size.height))
        emojiImageView.contentMode = UIViewContentMode.ScaleAspectFit
        emojiImageView.image = UIImage(named: "emoji_smiley")
        emojiImageView.hidden = true
        mainViewCell.addSubview(emojiImageView)
        
        
        
        recordVideoBar = UIView(frame: CGRect(x: 0, y: frame.size.height-20, width: 0, height: 20))
        recordVideoBar!.backgroundColor = UIColor(red: 255/255, green: 100/255, blue: 93/255, alpha: 1.0)
        recordVideoBar!.alpha = 0.8

        nbLikesView = UIView(frame: CGRect(x: mainViewCell.frame.width - 40, y: mainViewCell.frame.height - 24, width: 40, height: 24))
        nbLikesView.backgroundColor = UIColor.clearColor()
        nbLikesView.hidden = true
        mainViewCell.addSubview(nbLikesView)
        
        nbLikesImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: nbLikesView.frame.width, height: nbLikesView.frame.height))
        nbLikesImageView.image = UIImage(named: "like_background")
        nbLikesView.addSubview(nbLikesImageView)
        
        nbLikesLabelFront = UILabel(frame: CGRect(x: 0, y: 0, width: nbLikesView.frame.width - 24, height: nbLikesView.frame.height))
        nbLikesLabelFront.textAlignment = NSTextAlignment.Right
        nbLikesLabelFront.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        nbLikesLabelFront.font = UIFont(name: Utils().montserratRegular, size: 12)
        nbLikesLabelFront.text = LocalizedString("0")
        nbLikesView.addSubview(nbLikesLabelFront)
        
        //Heart
        let heartImageView:UIImageView = UIImageView(frame: CGRect(x: nbLikesView.frame.width - 19, y: 0, width: 10, height: nbLikesView.frame.height))
        heartImageView.contentMode = UIViewContentMode.Center
        heartImageView.image = UIImage(named: "like_pleek_view")
        nbLikesView.addSubview(heartImageView)
        
        readVideoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        readVideoImageView.center = CGPoint(x: frame.width/2, y: frame.height/2)
        readVideoImageView.image = UIImage(named: "play_answer")
        readVideoImageView.hidden = true
        readVideoImageView.contentMode = UIViewContentMode.Center
        mainViewCell.addSubview(readVideoImageView)
        
        spinnerView = LLARingSpinnerView(frame: CGRect(x: mainViewCell.frame.width/2 - 15, y: mainViewCell.frame.height/2 - 15, width: 30, height: 30))
        spinnerView.lineWidth = 2
        spinnerView.tintColor = UIColor(red: 128/255, green: 137/255, blue: 148/255, alpha: 1.0)
        spinnerView.hidden = true
        mainViewCell.addSubview(spinnerView)
        
        //Image like fast
        imageLikeFast = UIImageView(frame: CGRect(x: 0, y: 0, width: mainViewCell.frame.width, height: mainViewCell.frame.height))
        imageLikeFast.contentMode = UIViewContentMode.Center
        imageLikeFast.image = UIImage(named: "heart_like_fast")
        imageLikeFast.hidden = true
        mainViewCell.addSubview(imageLikeFast)
        
        contentView.addSubview(mainViewCell)
        
        
        
        
        hasLoaded = true
        
    }
    
    func startAnimateLoader(){
        if !Utils().isIphone4(){
            spinnerView.hidden = false
            spinnerView.startAnimating()
        }
        
    }
    
    func stopAnimateLoader(){
        if !Utils().isIphone4(){
            spinnerView.stopAnimating()
            spinnerView.hidden = true
        }
        
    }
    
    //MARK: FLIP
    
    func flip(){
        
        initFlipInfos()
        
        //If video can't flip must play
        var canFlip:Bool = true
        if self.react != nil{
            
            if self.react!["video"] != nil{
                if playerLayer.player == nil{
                    canFlip = false
                }
            }
 
        }
        else if self.reactVideoURL != nil{
            if playerLayer.player == nil{
                canFlip = false
            }
        }
        
        
        switch flipPosition{
        case 0:
            if canFlip{
                
                //Flip back other react
                if self.react != nil{
                    NSNotificationCenter.defaultCenter().postNotificationName("startFlip", object: nil, userInfo: ["exceptReact" : self.react!.objectId!])
                }
                else if self.reactRandomId != nil{
                    NSNotificationCenter.defaultCenter().postNotificationName("startFlip", object: nil, userInfo: ["exectpId" : self.reactRandomId!])
                }
                
                UIView.transitionWithView(self.contentView,
                    duration: 0.4,
                    options: UIViewAnimationOptions.TransitionFlipFromRight,
                    animations: { () -> Void in
                        self.contentView.insertSubview(self.flipView, aboveSubview: self.mainViewCell)
                    }, completion: { (finished) -> Void in
                        
                })
                self.flipPosition = 1
                
                println("Flip back")
            }
            else{
                self.startVideo()
            }
            
        case 1:
            println("Flip front")
            UIView.transitionWithView(self.contentView,
                duration: 0.4,
                options: UIViewAnimationOptions.TransitionFlipFromRight,
                animations: { () -> Void in
                    self.contentView.insertSubview(self.mainViewCell, aboveSubview: self.flipView)
                }, completion: { (finished) -> Void in
                    
            })
            self.flipPosition = 0
        default:
            println("Flip front")
        }
    }
    
    func flipInitialState(){
        
        if flipPosition == 1{
            UIView.transitionWithView(self.contentView,
                duration: 0.4,
                options: UIViewAnimationOptions.TransitionFlipFromRight,
                animations: { () -> Void in
                    self.contentView.insertSubview(self.mainViewCell, aboveSubview: self.flipView)
                }, completion: { (finished) -> Void in
                    
            })
            self.flipPosition = 0
        }
    }
    
    
    func initFlipInfos(){
        
        if self.react != nil{
            
            if self.react!["user"] != nil{
                var userReact:PFUser = self.react!["user"] as! PFUser
                usernameLabel.text = userReact.username!
                
                //Adapt Report/React CTA
                adaptRemoveOrReact()
                
                //Adapt friend CTA
                adaptFriendActions(Utils().isUserAFriend(userReact))
                
                //Adapt Like CTA
                adaptLikeActions()
                
            }
            
        }
        else{
            
        }
        
    }
    
    func startFlip(notification : NSNotification){
        
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        
        if self.react != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["exceptReact" : self.react!.objectId!])
        }
        else if self.reactVideoURL != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["exectpURL" : self.reactVideoURL!])
        }
        
        if let theReact = self.react {
            
            if let exceptReact = userInfo["exceptReact"]{
                
                if theReact.objectId != userInfo["exceptReact"]{
                    flipInitialState()
                }
            }
            
            
        }
        else if self.reactVideoURL != nil{
            
            if let exceptId = userInfo["exceptId"]{
                flipInitialState()
            }
        }
    }
    

    func startRecording(){
        
        contentView.addSubview(recordVideoBar!)
        recordVideoBar!.frame = CGRect(x: 0, y: frame.size.height-20, width: 0, height: 20)
        
        UIView.animateWithDuration(5,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                self.recordVideoBar!.frame = CGRect(x: 0, y: self.contentView.frame.size.height-20, width: self.contentView.frame.size.width, height: 20)
        }) { (completed) -> Void in
        }
    }

    
    // MARK : VIdeo
    
    func stopVideo(){
        if self.playerLayer.player != nil{
            println("there is a player")
            
            self.playerLayer.player.pause()
            self.playerLayer.player = nil
            readVideoImageView.hidden = false
            
        }
    }
    
    func startVideo(){
        
        //NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil)
        if self.react != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startFlip", object: nil, userInfo: ["exceptReact" : self.react!.objectId!])
        }
        else if self.reactRandomId != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startFlip", object: nil, userInfo: ["exectpId" : self.reactRandomId!])
        }
        
        if self.react != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["exceptReact" : self.react!.objectId!])
        }
        else if self.reactVideoURL != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["exectpURL" : self.reactVideoURL!])
        }
        
        if self.react != nil{
            dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
                if self.react!["video"] != nil{
                    dispatch_async(dispatch_get_main_queue(), { ()->() in
                        self.loadIndicator!.hidden = false
                        self.loadIndicator!.startAnimating()
                        self.readVideoImageView.hidden = true
                    })
                    
                    
                    let videoFile:PFFile = self.react!["video"] as! PFFile
                    
                    videoFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        
                        
                        var fileManager:NSFileManager = NSFileManager()
                        if data!.writeToFile("\(NSTemporaryDirectory())_\(self.react!.objectId).mov", atomically: false){
                            
                            
                            var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(self.react!.objectId).mov")
                            var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                            var player:AVPlayer = AVPlayer(playerItem: playerItem)
                            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                            
                            
                            
                            
                            
                            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                            
                            dispatch_async(dispatch_get_main_queue(), { ()->() in
                                
                                
                                if (self.delegate as! PleekViewController).isViewLoaded() && ((self.delegate as! PleekViewController).view.window != nil) {
                                    self.loadIndicator!.hidden = true
                                    
                                    self.playerLayer.player = player
                                    self.playerView.hidden = false
                                    self.readVideoImageView.hidden = true
                                    player.play()
                                }
                                
                                
                            })
                        }
                        
                        
                    })
                }
            })
        }
        else if self.reactVideoURL != nil{
            var fileManager:NSFileManager = NSFileManager()
            var playerItem:AVPlayerItem = AVPlayerItem(URL: NSURL(fileURLWithPath: self.reactVideoURL!))
            var player:AVPlayer = AVPlayer(playerItem: playerItem)
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
            
            
            
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
            
            dispatch_async(dispatch_get_main_queue(), { ()->() in
                
                
                if (self.delegate as! PleekViewController).isViewLoaded() && ((self.delegate as! PleekViewController).view.window != nil) {
                    self.loadIndicator!.hidden = true
                    
                    self.playerLayer.player = player
                    self.playerView.hidden = false
                    self.readVideoImageView.hidden = true
                    player.play()
                }
                
                
            })
        }
        
        
        
        
        
    }
    
    
    // MARK : Notification Listener Scroll
    
    func scrollStarted(){
        
        flipInitialState()
        
        if react != nil{
            if react!["video"] != nil{
                readVideoImageView.hidden = false
            }
        }
        else if reactVideoURL != nil{
            readVideoImageView.hidden = false
        }
        
        if self.playerLayer.player != nil{
            self.playerLayer.player.pause()
            self.playerLayer.player = nil
            self.loadIndicator!.hidden = true
            
            //Create temporary URL to record to
            if self.react != nil{
                dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
                    
                    let outpuPath:String = "\(NSTemporaryDirectory())_\(self.react!.objectId).mov"
                    let outputURL:NSURL = NSURL(fileURLWithPath: outpuPath)!
                    var fileManager:NSFileManager = NSFileManager()
                    
                    if fileManager.fileExistsAtPath(outpuPath){
                        var errPath : NSError? = nil
                        if !fileManager.removeItemAtPath(outpuPath, error: &errPath){
                            //Handle error
                        }
                        
                        
                    }
                })
            }
            
            
            
            
        }
        
    }
    
    
    
    func videoDidEnd(notification : NSNotification){
        var player:AVPlayerItem = notification.object as! AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }
    
    
    
    func newVideoStarted(notification : NSNotification){
        
        
        if let userInfo = notification.userInfo as? Dictionary<String,String!>{
            if let theReact = self.react {
                
                if userInfo["exceptReact"] != nil{
                    if theReact.objectId != userInfo["exceptReact"]{
                        if self.playerLayer.player != nil{
                            self.playerLayer.player.pause()
                            self.playerLayer.player = nil
                            readVideoImageView.hidden = false
                            self.loadIndicator!.hidden = true
                        }
                    }
                }
                else{
                    if self.playerLayer.player != nil{
                        self.playerLayer.player.pause()
                        self.playerLayer.player = nil
                        readVideoImageView.hidden = false
                        self.loadIndicator!.hidden = true
                    }
                }
                
                
            }
            else if self.reactVideoURL != nil{
                if userInfo["exectpURL"] != nil{
                    
                    if self.reactVideoURL! != userInfo["exceptReact"]{
                        if self.playerLayer.player != nil{
                            self.playerLayer.player.pause()
                            self.playerLayer.player = nil
                            readVideoImageView.hidden = false
                        }
                    }
                }
                else{
                    if self.playerLayer.player != nil{
                        self.playerLayer.player.pause()
                        self.playerLayer.player = nil
                        readVideoImageView.hidden = false
                    }
                }
            }
        }
        else{
            if self.playerLayer.player != nil{
                self.playerLayer.player.pause()
                self.playerLayer.player = nil
                readVideoImageView.hidden = false
            }
        }

        

        
        
        
    }
    
    
    //MARK: ADD FRIEND
    
    func addFriend(){
        println("add friend")
        if self.react != nil{
            if let userReact = self.react!["user"] as? PFUser{
                spinnerViewAddFriend.hidden = false
                addUserIcon.hidden = true
                if Utils().isUserAFriend(userReact){
                    //Remove Friend
                    Utils().removeFriend(userReact.objectId!).continueWithBlock({ (task) -> AnyObject! in
                        self.spinnerViewAddFriend.hidden = true
                        
                        if task.error != nil{
                            self.addUserIcon.hidden = false
                        }
                        else{
                            self.adaptFriendActions(false)
                        }
                        return nil
                    })
                }
                else{
                    //Add Friend
                    
                    Utils().addFriend(userReact.objectId!).continueWithBlock({ (task) -> AnyObject! in
                        self.spinnerViewAddFriend.hidden = true
                        if task.error != nil{
                            self.addUserIcon.hidden = false
                        }
                        else{
                            self.adaptFriendActions(true)
                        }
                        return nil
                    })
                }
                
            }
        }
    }
    
    func adaptFriendActions(isFriend : Bool){
        self.addUserIcon.hidden = false
        if isFriend{
            usernameLabel.textColor = blackSelected
            addUserIcon.image = imageUserAdded
        }
        else{
            usernameLabel.textColor = greyNotSelected
            addUserIcon.image = imageUserNotAdded
        }
    }
    
    
    //MARK: LIKES
    
    func updateLikeInfos(notification : NSNotification){
        
        
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        
        if let theReact = self.react {
            
            if let reactId = userInfo["reactId"]{
                
                if theReact.objectId != reactId{
                    println("UPDATE likes : \(reactId)")
                    adaptLikeActions()
                    updateFrontLikes()
                }
            }
            
            
        }
    }
    
    func likeReact(){
        println("Like React")
        
        if let reactPleek = self.react{
            
            if let pleek = self.mainPeekee{
                
                if let delegatePleek = self.delegate{
                    
                    Utils().likeReact(reactPleek, pleek: pleek, hasAlreadyLiked : userHasLiked())
                    
                    delegatePleek.userJustLiked(reactPleek)
                    self.adaptLikeActions()
                    self.updateFrontLikes()
                    
                }
                
                
                
                
            }
            
            
        }
   
    }
    
    func likeAfterLongPress(){
        
        if !userHasLiked(){
            if let reactPleek = self.react{
                
                if let pleek = self.mainPeekee{
                    
                    if let delegatePleek = self.delegate{
                        
                        Utils().likeReact(reactPleek, pleek: pleek, hasAlreadyLiked : userHasLiked())
                        
                        delegatePleek.userJustLiked(reactPleek)
                        self.adaptLikeActions()
                        self.updateFrontLikes()
                        
                    }
                    
                    
                    
                    
                }
                
                
            }
        }
        
    }
    
    func userHasLiked() -> Bool{
        
        if let delagatePleek = self.delegate{
            if let reactPleek = self.react{
                return delagatePleek.hasUserLikedThisReact(reactPleek)
            }
            
        }
        
        return false
        
    }
    
    func adaptLikeActions(){
        
        if userHasLiked(){
            nbLikes.textColor = blackSelected
            likesIcon.image = imageUserHasLiked
            
            UIView.animateWithDuration(0.2,
                delay: 0,
                options: nil,
                animations: { () -> Void in
                    self.likesIcon.transform = CGAffineTransformMakeScale(1.5, 1.5)
                }, completion: { (finished) -> Void in
                    UIView.animateWithDuration(0.2,
                        delay: 0,
                        options: nil,
                        animations: { () -> Void in
                            self.likesIcon.transform = CGAffineTransformIdentity
                        }, completion: { (finished) -> Void in
                            
                    })
            })
        }
        else{
            nbLikes.textColor = greyNotSelected
            likesIcon.image = imageUserHasNotLiked
            
            
        }
        
        //Set nb likes
        nbLikes.text = "0"
        if let reactPleek = self.react{
            if let nbLikesReact = reactPleek["nbLikes"] as? Int{

                nbLikes.text = "\(Utils().formatNumber(nbLikesReact))"
            }
        }
        
    }
    
    func updateFrontLikes(){
        
        nbLikesView.hidden = true
        if let reactPleek = self.react{
            if let nbLikesCount = reactPleek["nbLikes"] as? Int {
                if nbLikesCount > 0{
                    nbLikesView.hidden = false
                    nbLikesLabelFront.text = "\(nbLikesCount)"
                }
            }
        }
        
    }
    
    func likeLong(sender : UILongPressGestureRecognizer){
        switch sender.state{
            
        case UIGestureRecognizerState.Began:

            println("start long press")
            startHeartBigger()
            
            
            
        case UIGestureRecognizerState.Ended:
            println("end long press")
            //imageLikeFast.hidden = false
            
            
            
        default:
            println("none")
            
        }
    }
    
    
    func startHeartBigger(){
        imageLikeFast.transform = CGAffineTransformMakeScale(0, 0)
        imageLikeFast.hidden = false
        
        UIView.animateWithDuration(1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 10,
            options: nil,
            animations: { () -> Void in
                self.imageLikeFast.transform = CGAffineTransformIdentity
        }) { (finisehd) -> Void in
            self.likeAfterLongPress()
            self.slowlyHideHeart()
        }
        
    }
    
    func slowlyHideHeart(){
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.imageLikeFast.alpha = 0.0
        }) { (finisehd) -> Void in
            self.imageLikeFast.hidden = true
            self.imageLikeFast.alpha = 1.0
        }
    }
    
    //MARK: REPORT OR REMOVE
    
    
    
    func adaptRemoveOrReact(){
        
        if canRemove(){
            (flipView.viewWithTag(10) as! UIButton).setImage(UIImage(named: "trash_react_icon"), forState: UIControlState.Normal)
            reportOrDeleteLabel.text = LocalizedString("Delete").uppercaseString
        }
        else{
            (flipView.viewWithTag(10) as! UIButton).setImage(UIImage(named: "report_react_icon"), forState: UIControlState.Normal)
            reportOrDeleteLabel.text = LocalizedString("Report").uppercaseString
        }
        
    }
    
    func reportOrRemove(){
    
        self.stopVideo()
        if let delegatePleek = self.delegate{
            if let reactPleek = self.react{
                delegatePleek.removeReact(reactPleek, isReport: !canRemove())
            }
            
        }
    
    }
    
    func canRemove() -> Bool{
        var canRemove:Bool = false
        
        //Ca Remove if has posted the react
        if self.react != nil{
            
            if self.react!["user"] != nil{
                var userReact:PFUser = self.react!["user"] as! PFUser
                
                //Adapt Report/React CTA
                if userReact.objectId == PFUser.currentUser()!.objectId{
                    return true
                }

            }
            
        }
        
        //Can remove if he is owner of the pleek
        if let pleek = self.mainPeekee{
            
            if let userPleek = pleek["user"] as? PFUser{
                
                if userPleek.objectId == PFUser.currentUser()!.objectId{
                    return true
                }
                
            }
            
        }
        
        return canRemove
    }
    
    
    //MARK: SHARE
    func shareOne(){
        if let delegateReact = self.delegate{
            if let reactGood = self.react{
                delegateReact.shareOneVsOne(reactGood)
            }
            
        }
    }
    
    
    
    
}
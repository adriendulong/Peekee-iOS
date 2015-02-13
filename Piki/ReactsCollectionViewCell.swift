//
//  ReactsCollectionViewCell.swift
//  Piki
//
//  Created by Adrien Dulong on 09/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import AVFoundation


protocol ReactsCellProtocol {
    func postTextReact()
    func seeUserWhoPosted(user : PFUser)
    func printUsernamesreact()
    func hideUsernamesreact()
    func removeReact(react : AnyObject, isReport : Bool)
    func cellBigger(cell : ReactsCollectionViewCell)
    func cellSmaller(cell : ReactsCollectionViewCell)
    func removeReact(cell: ReactsCollectionViewCell)
}

class insideReactCell : UICollectionViewCell{
    
    var iconImageView:UIImageView!
    var labelInfos:UILabel!
    var parentCell:ReactsCollectionViewCell!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if iconImageView == nil {
            
            iconImageView = UIImageView(frame: CGRect(x: frame.width/2 - 15, y: frame.height/2 - 20, width: 30, height: 30))
            iconImageView.contentMode = UIViewContentMode.Center
            contentView.addSubview(iconImageView)
            
            labelInfos = UILabel(frame: CGRect(x: 0, y: iconImageView.frame.origin.y + iconImageView.frame.height + 5, width: frame.width, height: 20))
            labelInfos.font = UIFont(name: Utils().customFontSemiBold, size: 15)
            labelInfos.textColor = UIColor.whiteColor()
            labelInfos.textAlignment = NSTextAlignment.Center
            contentView.addSubview(labelInfos)
            
        }
        else{
            iconImageView.frame = CGRect(x: frame.width/2 - 15, y: frame.height/2 - 20, width: 30, height: 30)
        }
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadCell(position : Int){
        
        iconImageView.frame = CGRect(x: frame.width/2 - 15, y: frame.height/2 - 20, width: 30, height: 30)
        labelInfos.frame = CGRect(x: 0, y: iconImageView.frame.origin.y + iconImageView.frame.height + 5, width: frame.width, height: 20)
        iconImageView.hidden = false
        
        switch position{
        case 0:
            contentView.backgroundColor = UIColor.clearColor()
            iconImageView.hidden = true
            labelInfos.hidden = true
            
        case 1:
            contentView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            iconImageView.image = UIImage(named: self.parentCell.getNameImageReportOrDelete())
            labelInfos.text = self.parentCell.getLabelReportOrDelete()
            labelInfos.hidden = false
            
        default:
            contentView.backgroundColor = UIColor.clearColor()
            iconImageView.hidden = true
        }
        
    }
    
}

class ReactsCollectionViewCell : UICollectionViewCell, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate:ReactsCellProtocol? = nil
    
    let reactImage:UIImageView!
    let previewCameraView:UIView!
    var playerLayer:AVPlayerLayer!
    var playerView:UIView!
    //let player:AVPlayer!
    let overlayCameraView:UIView!
    let emojiImageView:UIImageView!
    let recordVideoBar:UIView?
    var textViewOverPhoto:UITextView?
    var backgoundOverlayView:UIView?
    var react:PFObject?
    var iconInfo:UIImageView?
    var usernameLabel:UILabel?
    var backImageView:UIImageView?
    var player:AVPlayer?
    var ownPosition:Int?
    
    //Delete View
    var insideCollectionView:UICollectionView!
    var readVideoImageView:UIImageView!
    var reactVideoURL:String?
    
    //Empty Cell
    var emptyCaseImageView:UIImageView?
    
    var loadIndicator:UIActivityIndicatorView?
    
    var pikiInfos:[String : AnyObject]?
    
    var mainPeekee:PFObject!
    var isInBigMode:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("newVideoStarted:"), name: "startNewVideo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scrollStarted"), name: "scrollStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scrollEnded"), name: "scrollEnded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scrollCell:"), name: "scrollCell", object: nil)
        
        var tapGestureDOubleClick:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("doubleTap:"))
        tapGestureDOubleClick.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(tapGestureDOubleClick)
        
        var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPress:"))
        contentView.addGestureRecognizer(longPress)
        
        
        
        //Preview Camera View
        previewCameraView = UIView(frame: contentView.frame)
        contentView.addSubview(previewCameraView)
        previewCameraView.hidden = true
        
        backImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        backImageView!.contentMode = UIViewContentMode.Center
        backImageView!.backgroundColor = UIColor(red: 230/255, green: 231/255, blue: 234/255, alpha: 1.0)
        contentView.addSubview(backImageView!)
        
        emptyCaseImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        emptyCaseImageView!.contentMode = UIViewContentMode.Center
        emptyCaseImageView!.image = UIImage(named: "empty_reacts")
        //contentView.addSubview(emptyCaseImageView!)
        
        //Image of the React
        reactImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(reactImage)
        

        
        playerView = UIView(frame:  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        
        playerLayer = AVPlayerLayer()
        playerLayer.frame =  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.layer.addSublayer(playerLayer)
        playerView.hidden = true
        contentView.addSubview(playerView)
        
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = self.playerView.center
        loadIndicator!.hidesWhenStopped = true
        loadIndicator!.hidden = true
        contentView.addSubview(loadIndicator!)
        
        overlayCameraView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        overlayCameraView.hidden = true
        contentView.addSubview(overlayCameraView)
        
        
        
        backgoundOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: overlayCameraView.frame.size.width, height: overlayCameraView.frame.size.height))
        backgoundOverlayView!.backgroundColor = UIColor.blackColor()
        backgoundOverlayView!.alpha = 0.4
        overlayCameraView.addSubview(backgoundOverlayView!)
        
        emojiImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: overlayCameraView.frame.size.width, height: overlayCameraView.frame.size.height))
        emojiImageView.contentMode = UIViewContentMode.ScaleAspectFit
        emojiImageView.image = UIImage(named: "emoji_smiley")
        emojiImageView.hidden = true
        contentView.addSubview(emojiImageView)
        
        
        textViewOverPhoto = UITextView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 10))
        textViewOverPhoto!.font = UIFont(name: Utils().customFontSemiBold, size: 26.0)
        textViewOverPhoto!.textAlignment = NSTextAlignment.Center
        textViewOverPhoto!.textColor = UIColor.whiteColor()
        textViewOverPhoto!.backgroundColor = UIColor.clearColor()
        textViewOverPhoto!.text = "Your text here 😀"
        textViewOverPhoto!.hidden = true
        textViewOverPhoto!.delegate = self
        textViewOverPhoto!.autocorrectionType = UITextAutocorrectionType.No
        textViewOverPhoto!.keyboardAppearance = UIKeyboardAppearance.Dark
        textViewOverPhoto!.returnKeyType = UIReturnKeyType.Send
        overlayCameraView.addSubview(textViewOverPhoto!)
        
        recordVideoBar = UIView(frame: CGRect(x: 0, y: frame.size.height-20, width: 0, height: 20))
        recordVideoBar!.backgroundColor = UIColor(red: 255/255, green: 100/255, blue: 93/255, alpha: 1.0)
        recordVideoBar!.alpha = 0.8
        
        
        iconInfo = UIImageView(frame: CGRect(x: frame.width - 40, y: frame.height - 35, width: 35, height: 35))
        iconInfo!.contentMode = UIViewContentMode.Center
        iconInfo!.image = UIImage(named: "switch_camera")
        contentView.addSubview(iconInfo!)
        
        
        usernameLabel = UILabel(frame: CGRect(x: 0, y: frame.height - 25, width: frame.width, height: 25))
        usernameLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
        usernameLabel!.textColor = UIColor.whiteColor()
        usernameLabel!.hidden = true
        usernameLabel!.textAlignment = NSTextAlignment.Center
        usernameLabel!.adjustsFontSizeToFitWidth = true
        contentView.addSubview(usernameLabel!)
        
        
        //Pan Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        //contentView.addGestureRecognizer(panGesture)
        
        
        //Delete View 
        //deleteView = UIView(frame: CGRect(x: -frame.width, y: 0, width: frame.width, height: frame.height))
        //deleteView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        //contentView.addSubview(deleteView)
        
        //Collection View Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: frame.width, height: frame.height)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        insideCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: layout)
        insideCollectionView.collectionViewLayout = layout
        insideCollectionView!.registerClass(insideReactCell.self, forCellWithReuseIdentifier: "Cell")
        insideCollectionView.pagingEnabled = true
        insideCollectionView.delegate = self
        insideCollectionView.dataSource = self
        insideCollectionView.backgroundColor = UIColor.clearColor()
        insideCollectionView.bounces = false
        insideCollectionView.showsHorizontalScrollIndicator = false
        insideCollectionView.showsVerticalScrollIndicator = false
        contentView.addSubview(insideCollectionView)
        
        
        readVideoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        readVideoImageView.center = CGPoint(x: frame.width/2, y: frame.height/2)
        readVideoImageView.image = UIImage(named: "play_answer")
        readVideoImageView.hidden = true
        readVideoImageView.contentMode = UIViewContentMode.Center
        contentView.addSubview(readVideoImageView)
        
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
        if text == "\n"{
            self.delegate!.postTextReact()
            return false
        }
        
        
        
        
        var textEntered:NSString = textView.text as NSString
        textEntered = textEntered.stringByReplacingCharactersInRange(range, withString: text)
        
        
        if textEntered.length > (textView.text as NSString).length{
            if getHeightTextView(textView, string: textEntered) > textView.frame.height{
                
                let maxDifFont = textView.font.pointSize - 14
                
                if maxDifFont > 0{
                    
                    for index in 1...Int(maxDifFont) {
                        
                        var fontSize = textView.font.pointSize
                        fontSize = fontSize - CGFloat(index)
                        
                        textView.font = UIFont(name: textView.font.fontName, size: fontSize)
                        
                        if getHeightTextView(textView, string: textEntered) < textView.frame.height{
                            modifyFrameTextView()
                            return true
                        }
                    }
                    
                    if getHeightTextView(textView, string: textEntered) > textView.frame.height{
                        return false
                    }
                }
                else{
                    return false
                }
                
            }
        }
        else{
            let maxDifFont = 26 - textView.font.pointSize
            var previousFontSize:CGFloat = textView.font.pointSize
            
            if maxDifFont > 0{
                
                for index in 1...Int(maxDifFont) {
                    
                    var fontSize = textView.font.pointSize
                    fontSize = fontSize + CGFloat(index)
                    
                    textView.font = UIFont(name: textView.font.fontName, size: fontSize)
                    
                    if getHeightTextView(textView, string: textEntered) > textView.frame.height{
                        textView.font = UIFont(name: textView.font.fontName, size: previousFontSize)
                        modifyFrameTextView()
                        return true
                    }
                    
                    previousFontSize = textView.font.pointSize
                }
            }
        }
        
        
        modifyFrameTextView()
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
    
    
    func modifyFrameTextView(){
        self.textViewOverPhoto!.frame = CGRect(x: 0, y: self.frame.height/2 - getHeightTextView(self.textViewOverPhoto!, string: self.textViewOverPhoto!.text)/2 - self.textViewOverPhoto!.textContainerInset.top, width: self.textViewOverPhoto!.frame.width, height: self.textViewOverPhoto!.frame.height)
    }
    
    
    
    func doubleTap(gesture : UITapGestureRecognizer){
        println("Double Tap")
        if react != nil{
            if react!["user"] != nil{
                self.delegate!.seeUserWhoPosted(react!["user"] as PFUser)
            }
            
        }
        
    }
    
    func longPress(longPress : UILongPressGestureRecognizer){
        
        if longPress.state == UIGestureRecognizerState.Began{
            self.delegate!.printUsernamesreact()
            
            
        }
        else if longPress.state == UIGestureRecognizerState.Ended{
            self.delegate!.hideUsernamesreact()
            
            
        }
        
    }
    
    
    func showUsername(){
        
        if react != nil{
            if react!["user"] != nil{
                let username = (react!["user"] as PFUser).username
                self.usernameLabel!.text = "@\(username)"
                self.usernameLabel!.hidden = false
            }
        }
        
        
        
    }
    
    func hideUserName(){
        self.usernameLabel!.hidden = true
    }
    
    
    // MARK : Collection View
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as insideReactCell
        
        cell.parentCell = self
        cell.loadCell(indexPath.item)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.frame.size
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.react != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("scrollCell", object: nil, userInfo: ["exceptReact" : self.react!.objectId])
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == 0{
            if self.react != nil{
                
                if !self.isInBigMode{
                    self.delegate!.cellBigger(self)
                }
                else{
                    self.delegate!.cellSmaller(self)
                }
                
                /*if self.react!["video"] != nil{
                dispatch_async(dispatch_get_main_queue(), { ()->() in
                self.loadIndicator!.hidden = false
                self.loadIndicator!.startAnimating()
                self.readVideoImageView.hidden = true
                })
                
                
                let videoFile:PFFile = self.react!["video"] as PFFile
                
                videoFile.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                
                
                var fileManager:NSFileManager = NSFileManager()
                if data.writeToFile("\(NSTemporaryDirectory())_\(self.react!.objectId).mov", atomically: false){
                
                
                var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(self.react!.objectId).mov")
                var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                var player:AVPlayer = AVPlayer(playerItem: playerItem)
                player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                
                
                
                
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                
                dispatch_async(dispatch_get_main_queue(), { ()->() in
                
                self.loadIndicator!.hidden = true
                
                self.playerLayer.player = player
                self.playerView.hidden = false
                self.readVideoImageView.hidden = true
                player.play()
                })
                }
                
                
                })
                }
                else{
                dispatch_async(dispatch_get_main_queue(), { ()->() in
                if !self.isInBigMode{
                self.delegate!.cellBigger(self)
                }
                else{
                self.delegate!.cellSmaller(self)
                }
                
                })
                
                }*/
            }
            else if self.reactVideoURL != nil{
                dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
                    dispatch_async(dispatch_get_main_queue(), { ()->() in
                        self.loadIndicator!.hidden = false
                        self.loadIndicator!.startAnimating()
                        self.readVideoImageView.hidden = true
                    })
                    
                    var filepath = NSURL(fileURLWithPath: self.reactVideoURL!)
                    var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                    var player:AVPlayer = AVPlayer(playerItem: playerItem)
                    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                    
                    
                    
                    
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                    
                    dispatch_async(dispatch_get_main_queue(), { ()->() in
                        self.loadIndicator!.hidden = true
                        self.playerLayer.player = player
                        self.playerView.hidden = false
                        self.readVideoImageView.hidden = true
                        player.play()
                    })
                })
            }
        }
        else if indexPath.item == 1{
            
            self.delegate!.removeReact(self)

        }
    }
    
    func scrollCell(notification : NSNotification){
        let userInfo:Dictionary<String,String!> = notification.userInfo as Dictionary<String,String!>
        
        if let theReact = self.react {
            
            if userInfo["exceptReact"] != nil{
                if theReact.objectId != userInfo["exceptReact"]{
                    insideCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
                }
            }
        }
    }
    
    
    func removeReact(){
        
        let currentUser:PFUser = PFUser.currentUser()
        if self.react != nil{
            let reactUser:PFUser? = self.react!["user"] as? PFUser
            
            if reactUser?.objectId == currentUser.objectId{
                self.delegate!.removeReact(self.react!, isReport: false)
            }
            else if currentUser.objectId == (self.mainPeekee!["user"] as PFUser).objectId{
                self.delegate!.removeReact(self.react!, isReport: false)
            }
            else{
                self.delegate!.removeReact(self.react!, isReport: true)
            }
        }
        else if self.pikiInfos != nil{
            self.delegate!.removeReact(self.pikiInfos!, isReport: true)
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
            NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["exceptReact" : self.react!.objectId])
        }
        else if self.reactVideoURL != nil{
            NSNotificationCenter.defaultCenter().postNotificationName("startNewVideo", object: nil, userInfo: ["exectpURL" : self.reactVideoURL!])
        }
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), { ()->() in
            if self.react!["video"] != nil{
                dispatch_async(dispatch_get_main_queue(), { ()->() in
                    self.loadIndicator!.hidden = false
                    self.loadIndicator!.startAnimating()
                    self.readVideoImageView.hidden = true
                })
                
                
                let videoFile:PFFile = self.react!["video"] as PFFile
                
                videoFile.getDataInBackgroundWithBlock({ (data : NSData!, error : NSError!) -> Void in
                    
                    
                    var fileManager:NSFileManager = NSFileManager()
                    if data.writeToFile("\(NSTemporaryDirectory())_\(self.react!.objectId).mov", atomically: false){
                        
                        
                        var filepath = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())_\(self.react!.objectId).mov")
                        var playerItem:AVPlayerItem = AVPlayerItem(URL: filepath)
                        var player:AVPlayer = AVPlayer(playerItem: playerItem)
                        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                        
                        
                        
                        
                        
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoDidEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
                        
                        dispatch_async(dispatch_get_main_queue(), { ()->() in
                            
                            self.loadIndicator!.hidden = true
                            
                            self.playerLayer.player = player
                            self.playerView.hidden = false
                            self.readVideoImageView.hidden = true
                            player.play()
                        })
                    }
                    
                    
                })
            }
        })
        
        
    }
    
    
    // MARK : Notification Listener Scroll
    
    func scrollStarted(){
        
        insideCollectionView.hidden = true
        insideCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        
        if react != nil{
            println("React")
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
                    
                    let outpuPath:NSString = "\(NSTemporaryDirectory())_\(self.react!.objectId).mov"
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
    
    
    func scrollEnded(){
        
        
        if ownPosition != nil{
            
            if ownPosition > 0{
                insideCollectionView.hidden = false
                
                insideCollectionView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
            
        }
        
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: frame.width, height: frame.height)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        insideCollectionView.setCollectionViewLayout(layout, animated: false)
        
    }
    
    
    func videoDidEnd(notification : NSNotification){
        var player:AVPlayerItem = notification.object as AVPlayerItem
        player.seekToTime(kCMTimeZero)
    }
    
    
    func updateDeleteSign(){
        let currentUser:PFUser = PFUser.currentUser()
        if react != nil{
            let reactUser:PFUser? = self.react!["user"] as? PFUser
            
            
            let cell:insideReactCell? = self.insideCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as? insideReactCell
            
            if cell != nil{
                if reactUser?.objectId == currentUser.objectId{
                    cell!.iconImageView.image = UIImage(named: "delete_react_icon")
                }
                else if currentUser.objectId == (self.mainPeekee!["user"] as PFUser).objectId{
                    cell!.iconImageView.image = UIImage(named: "delete_react_icon")
                }
                else{
                    cell!.iconImageView.image = UIImage(named: "report_react_icon")
                }
            }
            
            
        }
        else if self.pikiInfos != nil{
            
            
            let cell:insideReactCell? = self.insideCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as? insideReactCell
            
            if cell != nil{
                cell!.iconImageView.image = UIImage(named: "delete_react_icon")
            }
        }
        
    }
    
    func getLabelReportOrDelete() -> String{
        let currentUser:PFUser = PFUser.currentUser()
        if react != nil{
            let reactUser:PFUser? = self.react!["user"] as? PFUser
            
            
            if reactUser?.objectId == currentUser.objectId{
                return NSLocalizedString("DELETE", comment : "")
            }
            else if currentUser.objectId == (self.mainPeekee!["user"] as PFUser).objectId{
                return NSLocalizedString("DELETE", comment : "")
            }
            else{
                return NSLocalizedString("REPORT", comment : "")
            }
            
            
        }
        else if self.pikiInfos != nil{
            return NSLocalizedString("DELETE", comment : "")
        }
        else{
            return NSLocalizedString("REPORT", comment : "")
        }
    }
    
    func getNameImageReportOrDelete() -> String{
        
        let currentUser:PFUser = PFUser.currentUser()
        if react != nil{
            let reactUser:PFUser? = self.react!["user"] as? PFUser
            
            
            if reactUser?.objectId == currentUser.objectId{
                return "delete_react_icon"
            }
            else if currentUser.objectId == (self.mainPeekee!["user"] as PFUser).objectId{
                return "delete_react_icon"
            }
            else{
                return "report_react_icon"
            }
            
            
        }
        else if self.pikiInfos != nil{
            return "delete_react_icon"
        }
        else{
            return "report_react_icon"
        }
        
    }
    
    func morePeekee(){
        println("MORE")
    }

    
    func newVideoStarted(notification : NSNotification){
        
         let userInfo:Dictionary<String,String!> = notification.userInfo as Dictionary<String,String!>

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
    
    
}
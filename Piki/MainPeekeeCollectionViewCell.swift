//
//  MainPeekeeCollectionViewCell.swift
//  Pleek
//
//  Created by Adrien Dulong on 29/01/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import AVFoundation


class MainPeekeeCollectionViewCell : UICollectionViewCell{

    
    var mainImageView:PFImageView!
    var shadowImageView:UIImageView!
    var readVideoIcon:UIImageView!
    
    var playerLayer:AVPlayerLayer!
    var playerView:UIView!
    
    var nbRepliesLabel:UILabel!
    var moreInfosButton:UIButton!
    var spinnerView:LLARingSpinnerView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scrollStarted"), name: "scrollStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("newVideoStarted"), name: "startNewVideo", object: nil)
        
        contentView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 251/255, alpha: 1.0)
        
        
        mainImageView = PFImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        contentView.addSubview(mainImageView)
        
        
        
        
        playerView = UIView(frame:  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        playerLayer = AVPlayerLayer()
        playerLayer.frame =  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.layer.addSublayer(playerLayer)
        playerView.hidden = true
        contentView.addSubview(playerView)
        
        readVideoIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        readVideoIcon.contentMode = UIViewContentMode.Center
        readVideoIcon!.image = UIImage(named: "read_video_icon")
        readVideoIcon.hidden = true
        contentView.addSubview(readVideoIcon)
        
        //Shadow for bottom button
        var stretchShadowImage:UIImage = UIImage(named: "shadow_piki")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        shadowImageView = UIImageView(frame: CGRect(x: 0, y: frame.height - 115 , width: frame.width, height: 115))
        shadowImageView.image = stretchShadowImage
        shadowImageView.hidden = false
        contentView.addSubview(shadowImageView)
        
        nbRepliesLabel = UILabel(frame: CGRect(x: 12, y: frame.height - 30, width: 150, height: 20))
        nbRepliesLabel.textColor = UIColor.whiteColor()
        nbRepliesLabel.font = UIFont(name: Utils().montserratRegular, size: 18)
        nbRepliesLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(nbRepliesLabel)
        
        moreInfosButton = UIButton(frame: CGRect(x: frame.width - 40, y: frame.height - 30, width: 30, height: 30))
        moreInfosButton.center = CGPoint(x: frame.width - 25, y: frame.height - 20)
        moreInfosButton.setImage(UIImage(named: "view_more_peekee"), forState: UIControlState.Normal)
        moreInfosButton.addTarget(self, action: Selector("moreInfos"), forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(moreInfosButton)
        
        spinnerView = LLARingSpinnerView(frame: CGRect(x: contentView.frame.width/2 - 22, y: contentView.frame.height/2 - 22, width: 45, height: 45))
        spinnerView.lineWidth = 2
        spinnerView.tintColor = UIColor(red: 33/255, green: 35/255, blue: 37/255, alpha: 1.0)
        contentView.addSubview(spinnerView)
        spinnerView.startAnimating()
        
        
        
        
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK : Notification Listener Scroll
    
    func scrollStarted(){
        
        if self.playerLayer.player != nil{
            self.playerLayer.player.pause()
            readVideoIcon.hidden = false
        }
        
    }
    
    func newVideoStarted(){
        if self.playerLayer.player != nil{
            self.playerLayer.player.pause()
            readVideoIcon.hidden = false
        }
    }
    
    func updateInfosPleek(){
        nbRepliesLabel.text = "COUCOU"
    }
    
    func startDownloadImage(){
        
    }
    
    
    
    func moreInfos(){
        
        NSNotificationCenter.defaultCenter().postNotificationName("moreInfosPleek", object: nil, userInfo: nil)
        
    }
    
    
}
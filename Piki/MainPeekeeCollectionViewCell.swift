//
//  MainPeekeeCollectionViewCell.swift
//  Peekee
//
//  Created by Adrien Dulong on 29/01/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import AVFoundation


class MainPeekeeCollectionViewCell : UICollectionViewCell{

    
    var mainImageView:UIImageView!
    var backImageView:UIImageView!
    var shadowImageView:UIImageView!
    var readVideoIcon:UIImageView!
    var loadIndicator:UIActivityIndicatorView!
    
    var playerLayer:AVPlayerLayer!
    var playerView:UIView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("scrollStarted"), name: "scrollStarted", object: nil)
        
        backImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        backImageView.contentMode = UIViewContentMode.Center
        backImageView!.image = UIImage(named: "parrot_empty_screen")
        backImageView!.backgroundColor = UIColor.clearColor()
        contentView.addSubview(backImageView)
        
        mainImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
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
        
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadIndicator.tintColor = Utils().secondColor
        loadIndicator.center = self.playerView.center
        loadIndicator.hidesWhenStopped = true
        loadIndicator.hidden = true
        contentView.addSubview(loadIndicator)
        
        
        
        
        
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
    
    
}
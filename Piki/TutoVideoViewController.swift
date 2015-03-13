//
//  TutoVideoViewController.swift
//  Pleek
//
//  Created by Adrien Dulong on 27/02/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation
import AVFoundation

protocol TutoProtocol {
    func letsSayWhereVideo()
}

class TutoVideoViewController : UIViewController{
    
    var avPlayer:AVPlayer?
    var quitButton:UIButton?
    var delegate:TutoProtocol? = nil
    var firstTimePlay:Bool = false
    
    override func viewDidLoad() {
        
        
        
        var filePath:String? = NSBundle.mainBundle().pathForResource("peekee_tuto", ofType: "mp4")
        
        if filePath != nil{
            var fileURL = NSURL(fileURLWithPath: filePath!)
            self.avPlayer = AVPlayer(URL: fileURL)
            
            var layer:AVPlayerLayer = AVPlayerLayer(player: self.avPlayer!)
            self.avPlayer!.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
            layer.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            self.view.layer.addSublayer(layer)
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoEnded:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayer!.currentItem)
            
            self.avPlayer!.play()
            
            
        }
        
        quitButton = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 20, width: 40, height: 40))
        quitButton!.setImage(UIImage(named: "quit_reply_icon"), forState: UIControlState.Normal)
        quitButton!.addTarget(self, action: Selector("quit"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(quitButton!)
        
        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func videoEnded(notification : NSNotification){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if self.firstTimePlay{
                if self.delegate != nil{
                    self.delegate!.letsSayWhereVideo()
                }
                
            }
        })
    }
    
    func quit(){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if self.firstTimePlay{
                if self.delegate != nil{
                    self.delegate!.letsSayWhereVideo()
                }
                
            }
        })
    }
    
}
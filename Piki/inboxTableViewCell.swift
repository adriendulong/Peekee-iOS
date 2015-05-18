//
//  inboxTableViewCell.swift
//  Piki
//
//  Created by Adrien Dulong on 03/12/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation

protocol InboxCellProtocol {
    func deletePiki(cell : inboxTableViewCell)
}

class inboxTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {

    var delegate:InboxCellProtocol? = nil
    var imagePikiPreview:UIImageView?
    var usernameLabel:UILabel?
    var firstPreviewReact:PFImageView?
    var secondPreviewReact:PFImageView?
    var thirdPreviewReact:PFImageView?
    var moreInfosViewIndicator:UIView?
    var moreInfosLabel:UILabel?
    var answersIcon:UIImageView?
    var mainContent:UIView?
    var deleteImageView:UIImageView?
    var backTempImagePiki:UIView?
    var videoIcon:UIImageView!
    var fromLabel:UILabel!
    
    
    var deleteView:UIView?
    var deleteLabel:UILabel?
    
    var peekee:PFObject?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    
        deleteView = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/4 * 3, y: 0, width: UIScreen.mainScreen().bounds.width/4 + UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width/3))
        deleteView!.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0)
        self.addSubview(deleteView!)
        
        deleteLabel = UILabel(frame: CGRect(x: 0, y: deleteView!.frame.size.height/3 * 2 - 15, width: UIScreen.mainScreen().bounds.width/4, height: 30))
        deleteLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        deleteLabel!.textAlignment = NSTextAlignment.Center
        deleteLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 14)
        deleteLabel!.text = LocalizedString("Delete").uppercaseString
        deleteView!.addSubview(deleteLabel!)
        
        deleteImageView = UIImageView(frame: CGRect(x: 0, y: deleteView!.frame.size.height/2 - 15, width: UIScreen.mainScreen().bounds.width/4, height: 17))
        deleteImageView!.image = UIImage(named: "delete_icon_gray")
        deleteImageView!.contentMode = UIViewContentMode.Center
        deleteView!.addSubview(deleteImageView!)
        
        
        mainContent = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width/3))
        mainContent!.backgroundColor = UIColor.whiteColor()
        self.addSubview(mainContent!)
        
        let separationDeleteImage:UIImage = UIImage(named: "delete_piki_separation")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let sepDeleteImageView:UIImageView = UIImageView(frame: CGRect(x: mainContent!.frame.size.width, y: 0, width: 9, height: mainContent!.frame.size.height))
        sepDeleteImageView.image = separationDeleteImage
        mainContent!.addSubview(sepDeleteImageView)
        
        backTempImagePiki = UIView(frame: CGRect(x: 0, y: 0, width: (UIScreen.mainScreen().bounds.width - 2)/3, height: (UIScreen.mainScreen().bounds.width - 2)/3))
        backTempImagePiki!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        self.mainContent!.addSubview(backTempImagePiki!)
        
        imagePikiPreview = UIImageView(frame: CGRect(x: 0, y: 0, width: (UIScreen.mainScreen().bounds.width - 2)/3, height: (UIScreen.mainScreen().bounds.width - 2)/3))
        self.mainContent!.addSubview(imagePikiPreview!)
        
        
        fromLabel = UILabel(frame: CGRect(x: (UIScreen.mainScreen().bounds.width - 2)/3 + 20, y: UIScreen.mainScreen().bounds.width/9 -  4, width: 40, height: 14))
        //fromLabel!.center = CGPoint(x: UIScreen.mainScreen().bounds.width/3 * 2, y: UIScreen.mainScreen().bounds.width/9)
        fromLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 16)
        fromLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        fromLabel!.text = LocalizedString("From")
        //self.mainContent!.addSubview(fromLabel!)
        
        usernameLabel = UILabel(frame: CGRect(x: (UIScreen.mainScreen().bounds.width - 2)/3 + 20, y: UIScreen.mainScreen().bounds.width/9 - 15, width: UIScreen.mainScreen().bounds.width/3 * 2 - 40, height: 30))
        //usernameLabel!.center = CGPoint(x: UIScreen.mainScreen().bounds.width/3 * 2, y: UIScreen.mainScreen().bounds.width/9)
        usernameLabel?.font = UIFont(name: Utils().customFontSemiBold, size: 26)
        usernameLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        usernameLabel!.text = ""
        //usernameLabel!.backgroundColor = UIColor.orangeColor()
        usernameLabel!.adjustsFontSizeToFitWidth = true
        self.mainContent!.addSubview(usernameLabel!)
        
        answersIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 24))
        answersIcon!.image = UIImage(named: "icon_answers")
        answersIcon!.center = CGPoint(x: (UIScreen.mainScreen().bounds.width - 2)/3 + 24, y: UIScreen.mainScreen().bounds.width/9 * 2)
        //self.mainContent!.addSubview(answersIcon!)
        
        var separator:UIView = UIView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.width/3 - 1, width: UIScreen.mainScreen().bounds.width, height: 1))
        separator.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
        self.addSubview(separator)
        
        
        firstPreviewReact = PFImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        firstPreviewReact!.center = CGPoint(x: (UIScreen.mainScreen().bounds.width - 2)/3 + 35, y: answersIcon!.center.y)
        firstPreviewReact!.layer.cornerRadius = 2
        firstPreviewReact!.clipsToBounds = true
        firstPreviewReact!.hidden = true
        self.mainContent!.addSubview(firstPreviewReact!)
        
        secondPreviewReact = PFImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        secondPreviewReact!.center = CGPoint(x: firstPreviewReact!.center.x + 39, y: answersIcon!.center.y)
        secondPreviewReact!.layer.cornerRadius = 2
        secondPreviewReact!.clipsToBounds = true
        secondPreviewReact!.hidden = true
        self.mainContent!.addSubview(secondPreviewReact!)
        
        thirdPreviewReact = PFImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        thirdPreviewReact!.center = CGPoint(x: secondPreviewReact!.center.x + 39, y: answersIcon!.center.y)
        thirdPreviewReact!.layer.cornerRadius = 2
        thirdPreviewReact!.clipsToBounds = true
        thirdPreviewReact!.hidden = true
        self.mainContent!.addSubview(thirdPreviewReact!)
        
        moreInfosViewIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        moreInfosViewIndicator!.backgroundColor = Utils().secondColor
        moreInfosViewIndicator!.layer.cornerRadius = 2
        moreInfosViewIndicator!.clipsToBounds = true
        moreInfosViewIndicator!.hidden = true
        self.mainContent!.addSubview(moreInfosViewIndicator!)
        
        
        moreInfosLabel = UILabel(frame: CGRect(x: firstPreviewReact!.frame.origin.x, y: 0, width: moreInfosViewIndicator!.frame.size.width, height: moreInfosViewIndicator!.frame.size.height))
        moreInfosLabel!.textColor = UIColor.whiteColor()
        moreInfosLabel!.textAlignment = NSTextAlignment.Center
        moreInfosLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 15)
        moreInfosLabel!.text = LocalizedString("NEW")
        moreInfosViewIndicator!.addSubview(moreInfosLabel!)
        
        let panGestureRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("deleteAction:"))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        
        UIScreen.mainScreen().bounds.width
        
        videoIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: imagePikiPreview!.frame.width/4, height: imagePikiPreview!.frame.width/4))
        videoIcon.center = imagePikiPreview!.center
        videoIcon.contentMode = UIViewContentMode.ScaleAspectFit
        videoIcon.image = UIImage(named: "video_icon_inbox")
        videoIcon.hidden = true
        self.mainContent!.addSubview(videoIcon)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder : aDecoder)
        
        
    }
    
    
    func updateDeleteIcon(){
        if self.peekee != nil{
            
            let userPeekee:PFUser? = self.peekee!["user"] as? PFUser
            
            if userPeekee != nil{
                //Delete Icon
                if userPeekee!.objectId == (PFUser.currentUser())!.objectId{
                    self.deleteLabel!.text = LocalizedString("Delete").uppercaseString
                }
                    //Hide Icon
                else{
                    self.deleteLabel!.text = NSLocalizedString("HIDE", comment: "HIDE")
                }
            }
            
            
            
            
        }
        
    }
    
    
    
    func deleteAction(pan : UIPanGestureRecognizer){
        
        let translation = pan.translationInView(pan.view!)
        
        switch pan.state{
            
        case UIGestureRecognizerState.Began:
            break
            
        case UIGestureRecognizerState.Changed:
            
            if translation.x < 0{
                mainContent?.transform = CGAffineTransformMakeTranslation(translation.x, 0)
                
                if fabs(translation.x) > UIScreen.mainScreen().bounds.width/4 {
                    self.deleteLabel!.textColor = UIColor(red: 236/255, green: 18/255, blue: 63/255, alpha: 1.0)
                    self.deleteImageView!.image = UIImage(named: "delete_icon")
                    deleteView!.transform = CGAffineTransformMakeTranslation(translation.x + UIScreen.mainScreen().bounds.width/4 , 0)
                }
                else{
                    self.deleteView!.transform = CGAffineTransformIdentity
                    self.deleteImageView!.image = UIImage(named: "delete_icon_gray")
                    self.deleteLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                }
            }
            
            break
            
        case UIGestureRecognizerState.Ended:
            
            if mainContent!.frame.origin.x < -self.frame.size.width/4{
                UIView.animateKeyframesWithDuration(0.2,
                    delay: 0,
                    options: nil,
                    animations: { () -> Void in
                        self.mainContent!.transform = CGAffineTransformMakeTranslation(-UIScreen.mainScreen().bounds.width, 0)
                        self.deleteView!.transform = CGAffineTransformMakeTranslation(-UIScreen.mainScreen().bounds.width + UIScreen.mainScreen().bounds.width/4, 0)
                    }, completion: { (finished) -> Void in
                        self.delegate!.deletePiki(self)
                })
            }
            else{
                UIView.animateKeyframesWithDuration(0.2,
                    delay: 0,
                    options: nil,
                    animations: { () -> Void in
                        self.mainContent!.transform = CGAffineTransformIdentity
                        self.deleteView!.transform = CGAffineTransformIdentity
                }, completion: { (finished) -> Void in
                    
                })
            }
            
            
        default:
            UIView.animateKeyframesWithDuration(0.2,
                delay: 0,
                options: nil,
                animations: { () -> Void in
                    self.mainContent!.transform = CGAffineTransformIdentity
                    self.deleteView!.transform = CGAffineTransformIdentity
                }, completion: { (finished) -> Void in
                    
            })
            
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer){
            
            let uiPanGesture:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let velocity:CGPoint = uiPanGesture.velocityInView(self)
            
            return fabs(velocity.y) < fabs(velocity.x)
            
        }
        else{
            return true
        }
        
    }
    
    
    
}

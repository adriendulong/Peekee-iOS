//
//  CameraCollectionViewCell.swift
//  Peekee
//
//  Created by Adrien Dulong on 21/04/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class CameraCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
    
    var previewCameraView:UIView!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var hasLoaded:Bool = false
    var textViewOverPhoto:UITextView!
    var iconImageView:UIImageView!
    var memeImageView:UIImageView!
    var loaderImageView:UIImageView!
    var labelTapToReply:UILabel!
    var isRecording:Bool = false
    var grantAccessView:UIView!
    
    
    func loadCell(){
        
        println("Cemra width : \(self.contentView.frame.width)")
        
        previewCameraView = UIView(frame: self.contentView.frame)
        contentView.addSubview(previewCameraView)
        
        
        textViewOverPhoto = UITextView(frame: CGRect(x: 15, y: self.contentView.frame.height - 50, width: self.contentView.frame.width - 20, height: self.contentView.frame.height))
        textViewOverPhoto.font = UIFont(name: "BanzaiBros", size: 30.0)
        textViewOverPhoto.textColor = UIColor.whiteColor()
        textViewOverPhoto.backgroundColor = UIColor.clearColor()
        textViewOverPhoto.layer.shadowColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0, 0, 0, 0.5])
        textViewOverPhoto.layer.shadowOffset = CGSizeMake(0, 2)
        textViewOverPhoto.layer.shadowOpacity = 1.0
        textViewOverPhoto.layer.shadowRadius = 4
        textViewOverPhoto.hidden = true
        textViewOverPhoto.delegate = self
        textViewOverPhoto.autocorrectionType = UITextAutocorrectionType.No
        textViewOverPhoto.keyboardAppearance = UIKeyboardAppearance.Dark
        textViewOverPhoto.returnKeyType = UIReturnKeyType.Send
        self.reloadPositionTextView()
        contentView.addSubview(textViewOverPhoto)
        
        memeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        memeImageView.hidden = true
        contentView.addSubview(memeImageView)
        
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        iconImageView.image = UIImage(named: "reply_icon")
        iconImageView.contentMode = UIViewContentMode.Center
        contentView.addSubview(iconImageView)
        
        labelTapToReply = UILabel(frame: CGRect(x: 0, y: contentView.frame.height - 45, width: contentView.frame.width, height: 15))
        labelTapToReply.font = UIFont(name: Utils().montserratRegular, size: 16)
        labelTapToReply.text = "TAP TO REPLY"
        labelTapToReply.textColor = UIColor.whiteColor()
        labelTapToReply.adjustsFontSizeToFitWidth = true
        labelTapToReply.textAlignment = NSTextAlignment.Center
        contentView.addSubview(labelTapToReply)
        
        
        loaderImageView = UIImageView(frame: CGRect(x: 0, y: contentView.frame.height - 6, width: contentView.frame.width, height: 6))
        loaderImageView.image = UIImage(named: "loading_bar")
        contentView.addSubview(loaderImageView)
        loaderImageView.transform = CGAffineTransformMakeTranslation(-contentView.frame.width, 0)
        
        grantAccessView = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        grantAccessView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 251/255, alpha: 1.0)
        grantAccessView.hidden = true
        contentView.addSubview(grantAccessView)
        let imageGrantAccess:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        imageGrantAccess.image = UIImage(named: "enable_camera_react")
        grantAccessView.addSubview(imageGrantAccess)
        let tapGrantAccess:UILabel = UILabel(frame: CGRect(x: 0, y: grantAccessView.frame.height - 30, width: grantAccessView.frame.width, height: 20))
        tapGrantAccess.textAlignment = NSTextAlignment.Center
        tapGrantAccess.text = "TAP TO REPLY"
        tapGrantAccess.font = UIFont(name: Utils().montserratRegular, size: 14)
        tapGrantAccess.textColor = UIColor(red: 155/255, green: 162/255, blue: 171/255, alpha: 1.0)
        grantAccessView.addSubview(tapGrantAccess)
        
        hasLoaded = true
        
    }
    
    func updateCell(canAccessCamera : Bool){
        if canAccessCamera{
            grantAccessView.hidden = true
            labelTapToReply.hidden = false
            iconImageView.hidden = false
            PBJVision.sharedInstance().startPreview()
        }
        else{
            grantAccessView.hidden = false
            labelTapToReply.hidden = true
            iconImageView.hidden = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
        if text == "\n"{
            //self.delegate!.postTextReact()
            return false
        }
        
        
        
        
        var textEntered:NSString = textView.text as NSString
        textEntered = textEntered.stringByReplacingCharactersInRange(range, withString: text)
        


        UIView.animateWithDuration(0.2, animations: { () -> Void in
            textView.frame = CGRect(x: 0, y: self.contentView.frame.height - (self.getNbLines(textView, string: textEntered) * (textView.font.lineHeight + 5)) - 5, width: self.contentView.frame.width, height: self.contentView.frame.height)
        }) { (finished) -> Void in
            
        }
        
        return true
    }
    
    func getNbLines(textView : UITextView, string : NSString) -> CGFloat{
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
    
    
    func reloadPositionTextView(){
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.textViewOverPhoto.frame = CGRect(x: 0, y: self.contentView.frame.height - (self.getNbLines(self.textViewOverPhoto, string: self.textViewOverPhoto.text) * (self.textViewOverPhoto.font.lineHeight + 5)) - 5, width: self.contentView.frame.width, height: self.contentView.frame.height)
            }) { (finished) -> Void in
                
        }
    }
    
    func startRecording(length : Double){
        self.loaderImageView.hidden = false
        isRecording = true
        
        UIView.animateWithDuration(length,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                self.loaderImageView.transform = CGAffineTransformIdentity
        }) { (finished) -> Void in
            println("FINISH ANIMATION")
            self.loaderImageView.hidden = true
            self.loaderImageView.transform = CGAffineTransformMakeTranslation(-self.contentView.frame.width, 0)
            
        }
        
    }
    
    func endRecording(){
        self.loaderImageView.layer.removeAllAnimations()
        self.loaderImageView.hidden = true
        UIView.animateWithDuration(0.1,
            delay: 0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                self.loaderImageView.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                self.loaderImageView.hidden = true
                self.loaderImageView.transform = CGAffineTransformMakeTranslation(-self.contentView.frame.width, 0)
        }
        
    }
    
    func openCamera(){
        iconImageView.hidden = true
        labelTapToReply.hidden = true
        
        
        
    }
    
    
    func closeCamera(){
        
        iconImageView.hidden = false
        labelTapToReply.hidden = false
    }
    
    
}

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
    
    
    func loadCell(){
        
        previewCameraView = UIView(frame: self.contentView.frame)
        contentView.addSubview(previewCameraView)
        
        
        textViewOverPhoto = UITextView(frame: CGRect(x: 5, y: self.contentView.frame.height - 50, width: self.contentView.frame.width - 10, height: self.contentView.frame.height))
        textViewOverPhoto.font = UIFont(name: Utils().montserratRegular, size: 26.0)
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
        contentView.addSubview(textViewOverPhoto)
        
        memeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        memeImageView.hidden = true
        contentView.addSubview(memeImageView)
        
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        iconImageView.image = UIImage(named: "reply_icon")
        iconImageView.contentMode = UIViewContentMode.Center
        contentView.addSubview(iconImageView)
        
        loaderImageView = UIImageView(frame: CGRect(x: 0, y: contentView.frame.height - 6, width: contentView.frame.width, height: 6))
        loaderImageView.image = UIImage(named: "loading_bar")
        contentView.addSubview(loaderImageView)
        loaderImageView.transform = CGAffineTransformMakeTranslation(-contentView.frame.width, 0)
        
        hasLoaded = true
        
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
        if text == "\n"{
            //self.delegate!.postTextReact()
            return false
        }
        
        
        
        
        var textEntered:NSString = textView.text as NSString
        textEntered = textEntered.stringByReplacingCharactersInRange(range, withString: text)
        
        
        if textEntered.length > (textView.text as NSString).length{
            println("Nb lines : \(getNbLines(textView, string: textEntered))")
            
            
        }
        else{

        }

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            textView.frame = CGRect(x: 0, y: self.contentView.frame.height - 50 - (self.getNbLines(textView, string: textEntered) - 1) * textView.font.lineHeight, width: self.contentView.frame.width, height: self.contentView.frame.height)
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
            self.textViewOverPhoto.frame = CGRect(x: 0, y: self.contentView.frame.height - 50 - (self.getNbLines(self.textViewOverPhoto, string: self.textViewOverPhoto.text) - 1) * self.textViewOverPhoto.font.lineHeight, width: self.contentView.frame.width, height: self.contentView.frame.height)
            }) { (finished) -> Void in
                
        }
    }
    
    func startRecording(length : Double){
        UIView.animateWithDuration(length,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                self.loaderImageView.transform = CGAffineTransformIdentity
        }) { (finished) -> Void in
            self.loaderImageView.hidden = true
            self.loaderImageView.transform = CGAffineTransformMakeTranslation(-self.loaderImageView.frame.width, 0)
        }
        
    }
    
    func endRecording(){
        self.loaderImageView.hidden = true
    }
    
    
    
}

//
//  InboxTableViewCell.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {
    
    lazy var pleekImageView: PFImageView = {
        let pleekIM = PFImageView()
        
        self.contentView.addSubview(pleekIM)
        
        pleekIM.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(58)
            make.leading.equalTo(self.contentView.snp_leading)
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
            make.height.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
        })
        
        pleekIM.backgroundColor = UIColor.Theme.PleekBackGroundColor
        pleekIM.layer.shadowColor = UIColor.blackColor().CGColor
        pleekIM.layer.shadowOffset = CGSizeMake(0, 0)
        pleekIM.layer.shadowOpacity = 0.2
        pleekIM.layer.shadowRadius = 2.0
        let shadowRect = CGRectInset(pleekIM.bounds, 0, 2.0)
        pleekIM.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
        return pleekIM
    } ()
    
    lazy var pleekImageSpinner: LLARingSpinnerView = {
        let pleekIS = LLARingSpinnerView()
        pleekIS.hidesWhenStopped = true
        pleekIS.backgroundColor = UIColor.Theme.PleekBackGroundColor
        pleekIS.tintColor = UIColor.Theme.PleekSpinnerColor
        pleekIS.lineWidth = Dimensions.SpinnerLineWidth
        self.pleekImageView.addSubview(pleekIS)
        
        pleekIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.pleekImageView.snp_center)
            make.size.equalTo(30)
        })
        
        return pleekIS
    } ()
    
    lazy var contentReactView: UIView = {
        let contentRV = UIView()
        
        self.contentView.addSubview(contentRV)
        
        contentRV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(58)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0)
            make.height.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
        })
        
        contentRV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        contentRV.layer.shadowColor = UIColor.blackColor().CGColor
        contentRV.layer.shadowOffset = CGSizeMake(0, 0)
        contentRV.layer.shadowOpacity = 0.2
        contentRV.layer.shadowRadius = 2.0
        let shadowRect = CGRectInset(contentRV.bounds, 0, 2.0)
        contentRV.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
        return contentRV
    } ()
    
    lazy var reactTopImageView: PFImageView = {
        let reacTopIV = PFImageView()
        reacTopIV.backgroundColor = UIColor.Theme.PleekBackGroundColor

        self.contentReactView.addSubview(reacTopIV)
        
        reacTopIV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentReactView.snp_top)
            make.bottom.equalTo(self.contentReactView.snp_centerY)
            make.leading.equalTo(self.contentReactView.snp_leading)
            make.trailing.equalTo(self.contentReactView.snp_trailing)
        })
        
        return reacTopIV
    } ()
    
    lazy var reactTopImageSpinner: LLARingSpinnerView = {
        let reactTIS = LLARingSpinnerView()
        reactTIS.hidesWhenStopped = true
        reactTIS.lineWidth = Dimensions.SpinnerLineWidth
        reactTIS.tintColor = UIColor.Theme.PleekSpinnerColor
        reactTIS.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.reactTopImageView.addSubview(reactTIS)
        
        reactTIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.reactTopImageView.snp_center)
            make.size.equalTo(18)
        })
        
        return reactTIS
    } ()
    
    lazy var reactBottomImageView: PFImageView = {
        let reactBottomIV = PFImageView()
        reactBottomIV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.contentReactView.addSubview(reactBottomIV)
        
        reactBottomIV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentReactView.snp_centerY)
            make.bottom.equalTo(self.contentReactView.snp_bottom)
            make.leading.equalTo(self.contentReactView.snp_leading)
            make.trailing.equalTo(self.contentReactView.snp_trailing)
        })
        
        return reactBottomIV
    } ()
    
    lazy var reactBottomImageSpinner: LLARingSpinnerView = {
        let reactBIS = LLARingSpinnerView()
        reactBIS.hidesWhenStopped = true
        reactBIS.lineWidth = Dimensions.SpinnerLineWidth
        reactBIS.tintColor = UIColor.Theme.PleekSpinnerColor
        reactBIS.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.reactBottomImageView.addSubview(reactBIS)
        
        reactBIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.reactBottomImageView.snp_center)
            make.size.equalTo(18)
        })
        
        return reactBIS
    } ()
    
    var noReactViewTopConstraint: Constraint = Constraint()
    
    lazy var noReactView: UIView = {
        let noReactV = UIView()
        noReactV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.contentReactView.addSubview(noReactV)
        
        noReactV.snp_makeConstraints { (make) -> Void in
            self.noReactViewTopConstraint = make.top.equalTo(self.reactBottomImageView.snp_top).constraint
            make.leading.equalTo(self.contentReactView.snp_leading)
            make.trailing.equalTo(self.contentReactView.snp_trailing)
            make.bottom.equalTo(self.contentReactView.snp_bottom)
        }
        
        let replyLabel = UILabel()
        replyLabel.text = LocalizedString("REPLY")
        replyLabel.textAlignment = .Center
        replyLabel.font = UIFont(name: "Montserrat-Regular", size: 12)!
        replyLabel.textColor = UIColor.Theme.DarkTextColor
        replyLabel.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        noReactV.addSubview(replyLabel)
        
        replyLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(noReactV.snp_centerX)
            make.top.equalTo(noReactV.snp_centerY).offset(8)
        }
        
        let replyImageView = UIImageView()
        replyImageView.backgroundColor = UIColor.Theme.PleekBackGroundColor
        replyImageView.image = UIImage(named: "reply-cta")
        
        noReactV.addSubview(replyImageView)
        
        replyImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(noReactV.snp_centerX)
            make.bottom.equalTo(noReactV.snp_centerY).offset(-8)
            make.width.equalTo(28.5)
            make.height.equalTo(24.5)
        }
        
        return noReactV
    } ()
    
    lazy var fromLabel: UILabel = {
        let fromL = UILabel(frame: CGRectZero)
        
        self.contentView.addSubview(fromL)
        
        fromL.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(25)
            make.height.equalTo(18)
            make.leading.equalTo(self.contentView.snp_leading).offset(20)
        }
        
        return fromL
    } ()
    
    lazy var certifiedAccountImageView: UIImageView = {
        let certifiedAIV = UIImageView()
        certifiedAIV.backgroundColor = UIColor.clearColor()
        certifiedAIV.image = UIImage(named: "certified-icon")
        
        self.contentView.addSubview(certifiedAIV)
        
        certifiedAIV.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(24)
            make.height.equalTo(25.5)
            make.leading.equalTo(self.fromLabel.snp_trailing).offset(8)
            make.centerY.equalTo(self.fromLabel.snp_centerY)
        }
        
        return certifiedAIV
    } ()
    
    lazy var toXFriendsLabel: UILabel = {
        let toXFL = UILabel()
        toXFL.backgroundColor = UIColor.clearColor()
        toXFL.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        toXFL.textColor = UIColor(red: 193.0/255.0, green: 204.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        self.contentView.addSubview(toXFL)
        
        toXFL.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(25)
            make.height.equalTo(18)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-20)
        }
        
        return toXFL
    } ()
    
    lazy var toXFriendsImageView: UIImageView = {
        let toXFIV = UIImageView()
        toXFIV.backgroundColor = UIColor.clearColor()
        toXFIV.contentMode = .Center
        
        self.contentView.addSubview(toXFIV)
        
        toXFIV.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(12)
            make.trailing.equalTo(self.toXFriendsLabel.snp_leading).offset(-7)
            make.centerY.equalTo(self.toXFriendsLabel.snp_centerY)
        }
        
        return toXFIV
    } ()
    
    lazy var contentRepliesView: UIView = {
        let contentRV = UIView()
        contentRV.clipsToBounds = true
        
        self.contentView.addSubview(contentRV)
        
        contentRV.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.pleekImageView.snp_bottom)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
        }
        
        contentRV.backgroundColor = UIColor.whiteColor()
        
        return contentRV
    } ()
    
    lazy var repliesImageView: UIImageView = {
        let repliesIV = UIImageView()
        repliesIV.backgroundColor = UIColor.clearColor()
        repliesIV.image = UIImage(named: "repliescount-icon")
        
        
        self.contentRepliesView.addSubview(repliesIV)
        
        repliesIV.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(13.5)
            make.height.equalTo(11.5)
            make.leading.equalTo(self.contentRepliesView.snp_leading).offset(20)
            make.top.equalTo(self.contentRepliesView.snp_top).offset(17)
        }
        
        return repliesIV
    } ()
    
    lazy var repliesLabel: UILabel = {
        let repliesL = UILabel()
        repliesL.backgroundColor = UIColor.clearColor()
        repliesL.font = UIFont(name: "ProximaNova-Semibold", size: 12.0)
        repliesL.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        self.contentRepliesView.addSubview(repliesL)
        
        repliesL.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(13)
            make.centerY.equalTo(self.repliesImageView.snp_centerY)
            make.leading.equalTo(self.repliesImageView.snp_trailing).offset(8)
        }
        
        return repliesL
    } ()
    
    lazy var newRepliesImageView: UIImageView = {
        let newRIV = UIImageView()
        newRIV.backgroundColor = UIColor.clearColor()
        newRIV.image = UIImage(named: "next-icon")
        
        self.contentRepliesView.addSubview(newRIV)
        
        newRIV.snp_makeConstraints({ (make) -> Void in
            make.width.equalTo(6.5)
            make.height.equalTo(11)
            make.trailing.equalTo(self.contentRepliesView.snp_trailing).offset(-20)
            make.top.equalTo(self.pleekImageView.snp_bottom).offset(17)
        })
        
        return newRIV
    } ()
    
    lazy var newRepliesLabel: UILabel = {
        let newRL = UILabel()
        newRL.backgroundColor = UIColor.clearColor()
        newRL.font = UIFont(name: "ProximaNova-Semibold", size: 12.0)
        newRL.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        self.contentRepliesView.addSubview(newRL)
        
        newRL.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(13)
            make.centerY.equalTo(self.newRepliesImageView.snp_centerY)
            make.trailing.equalTo(self.newRepliesImageView.snp_leading).offset(-15)
        })
        
        return newRL
    } ()
    
    lazy var cellSeparatorView: UIView = {
        let cellSV = UIView()
        cellSV.backgroundColor = UIColor(white: 234.0/255.0, alpha: 1.0)
       
        self.contentRepliesView.addSubview(cellSV)
        
        cellSV.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(1)
            make.bottom.equalTo(self.contentRepliesView.snp_bottom)
            make.leading.equalTo(self.contentRepliesView.snp_leading)
            make.trailing.equalTo(self.contentRepliesView.snp_trailing)
        })
        
        return cellSV
    } ()
    
    func setupView() {
        let v1 = self.pleekImageSpinner
        let v2 = self.contentReactView
        let v3 = self.reactTopImageSpinner
        let v4 = self.reactBottomImageSpinner
        let v5 = self.certifiedAccountImageView
        let v7 = self.contentRepliesView
        let v6 = self.cellSeparatorView
        self.contentReactView.bringSubviewToFront(self.noReactView)
        self.contentView.bringSubviewToFront(self.contentReactView)
        self.contentView.bringSubviewToFront(self.pleekImageView)
        
        self.clipsToBounds = true
        self.selectionStyle = .None
    }
}

extension InboxCell {
    
    func configureFor(pleek: Pleek) {
        
        self.setupView()
        
        self.fromLabel.attributedText = self.attributedTextForFrom(pleek.user.username ?? "")
        
        if pleek.isPublic {
            self.toXFriendsLabel.text = "PUBLIC"
            self.toXFriendsImageView.image = UIImage(named: "public-icon")
        } else {
            self.toXFriendsLabel.text = String(format: LocalizedString("TO %d FRIENDS"), pleek.getRealRecipientsNumber())
            self.toXFriendsImageView.image = UIImage(named: "private-icon")
        }
        
        if pleek.nbReaction > 0 {
            self.contentRepliesView.hidden = false
            self.repliesLabel.text = String(format: LocalizedString("%@ REPLIES"), self.formatNumber(pleek.nbReaction))
            self.newRepliesLabel.text = String(format: LocalizedString("%@ NEW"), self.formatNumber(pleek.nbReaction))
        } else {
            self.contentRepliesView.hidden = true
        }
        
        weak var weakSelf = self
        
        self.pleekImageView.image = nil
        self.pleekImageSpinner.hidden = false
        self.pleekImageSpinner.startAnimating()
        self.pleekImageView.file = pleek.extraSmallPiki
        self.pleekImageView.loadInBackground { (image, error) -> Void in
            weakSelf?.pleekImageSpinner.hidden = true
        }
        
        self.reactTopImageView.image = nil
        self.reactBottomImageView.image = nil
        self.noReactView.hidden = true
        
        if let react1 = pleek.react1 {
            self.reactTopImageSpinner.hidden = false
            self.reactTopImageSpinner.startAnimating()
            self.reactTopImageView.file = react1
            self.reactTopImageView.loadInBackground { (image, error) -> Void in
                weakSelf?.reactTopImageSpinner.hidden = true
            }
        }
        
        if let react2 = pleek.react2 {
            self.reactBottomImageSpinner.hidden = false
            self.reactBottomImageSpinner.startAnimating()
            self.reactBottomImageView.file = react2
            self.reactBottomImageView.loadInBackground { (image, error) -> Void in
                weakSelf?.reactBottomImageSpinner.hidden = true
            }
        }
        
        self.noReactViewTopConstraint.uninstall()
        
        if pleek.react1 == nil {
            self.noReactView.hidden = false
            self.noReactView.snp_makeConstraints { (make) -> Void in
                self.noReactViewTopConstraint = make.top.equalTo(self.contentReactView.snp_top).constraint
            }
        } else if pleek.react2 == nil {
            self.noReactView.hidden = false
            self.noReactView.snp_makeConstraints { (make) -> Void in
                self.noReactViewTopConstraint = make.top.equalTo(self.contentReactView.snp_centerY).constraint
            }
        }
        
        self.contentReactView.setNeedsLayout()
        
        if pleek.user.isCertified {
            self.certifiedAccountImageView.hidden = false
        } else {
            self.certifiedAccountImageView.hidden = true
        }
    }
    
    func attributedTextForFrom(name: String) -> NSAttributedString {
        let from = LocalizedString("FROM")
        let fromWithName = LocalizedString("FROM  %@")
        let finalString = String(format: fromWithName, name)
        
        var string = NSMutableAttributedString(string: finalString)
        
        let fromRange = (finalString as NSString).rangeOfString(from)
        let nameRange = (finalString as NSString).rangeOfString(name)
        
        string.addAttribute(NSFontAttributeName, value: UIFont(name: "Montserrat-Regular", size: 12.0)!, range: fromRange)
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 193.0/255.0, green: 204.0/255.0, blue: 217.0/255.0, alpha: 1.0), range: fromRange)
        string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, range: nameRange)
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0), range: nameRange)
        
        return string
    }
    
    func formatNumber(number: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter.stringFromNumber(number)!
    }
}
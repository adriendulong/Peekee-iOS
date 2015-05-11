//
//  InboxTableViewCell.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {
    
    lazy var pleekImageView: UIImageView = {
        let pleekIM = UIImageView()
        
        self.contentView.addSubview(pleekIM)
        
        pleekIM.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(58)
            make.leading.equalTo(self.contentView.snp_leading)
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
            make.height.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
        })
        
        pleekIM.backgroundColor = UIColor.whiteColor()
        pleekIM.layer.shadowColor = UIColor.blackColor().CGColor
        pleekIM.layer.shadowOffset = CGSizeMake(0, 0)
        pleekIM.layer.shadowOpacity = 0.2
        pleekIM.layer.shadowRadius = 2.0
        let shadowRect = CGRectInset(pleekIM.bounds, 0, 2.0)
        pleekIM.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
        return pleekIM
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
        
        contentRV.backgroundColor = UIColor.whiteColor()
        contentRV.layer.shadowColor = UIColor.blackColor().CGColor
        contentRV.layer.shadowOffset = CGSizeMake(0, 0)
        contentRV.layer.shadowOpacity = 0.2
        contentRV.layer.shadowRadius = 2.0
        let shadowRect = CGRectInset(contentRV.bounds, 0, 2.0)
        contentRV.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
        return contentRV
    } ()
    
    lazy var reactTopImageView: UIImageView = {
        let reacTopIV = UIImageView()
        reacTopIV.backgroundColor = UIColor.whiteColor()

        self.contentReactView.addSubview(reacTopIV)
        
        reacTopIV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentReactView.snp_top)
            make.bottom.equalTo(self.contentReactView.snp_centerY)
            make.leading.equalTo(self.contentReactView.snp_leading)
            make.trailing.equalTo(self.contentReactView.snp_trailing)
        })
        
        return reacTopIV
    } ()
    
    lazy var reactBottomImageView: UIImageView = {
        let reactBottomIV = UIImageView()
        reactBottomIV.backgroundColor = UIColor.whiteColor()
        
        self.contentReactView.addSubview(reactBottomIV)
        
        reactBottomIV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentReactView.snp_centerY)
            make.bottom.equalTo(self.contentReactView.snp_bottom)
            make.leading.equalTo(self.contentReactView.snp_leading)
            make.trailing.equalTo(self.contentReactView.snp_trailing)
        })
        
        return reactBottomIV
    } ()
    
    lazy var fromLabel: UILabel = {
        let fromL = UILabel(frame: CGRectZero)
        
        self.contentView.addSubview(fromL)
        
        fromL.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(25)
            make.height.equalTo(18)
            make.leading.equalTo(self.contentView.snp_leading).offset(20)
            //make.width.equalTo(185.0)
        })
        
        return fromL
    } ()
    
    lazy var certifiedAccountImageView: UIImageView = {
        let certifiedAIV = UIImageView()
        certifiedAIV.backgroundColor = UIColor.clearColor()
        certifiedAIV.image = UIImage(named: "certified-icon")
        
        self.contentView.addSubview(certifiedAIV)
        
        certifiedAIV.snp_makeConstraints({ (make) -> Void in
            make.width.equalTo(24)
            make.height.equalTo(25.5)
            make.leading.equalTo(self.fromLabel.snp_trailing).offset(8)
            make.centerY.equalTo(self.fromLabel.snp_centerY)
        })
        
        return certifiedAIV
    } ()
    
    lazy var toXFriendsLabel: UILabel = {
        let toXFL = UILabel()
        toXFL.backgroundColor = UIColor.clearColor()
        toXFL.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        toXFL.textColor = UIColor(red: 193.0/255.0, green: 204.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        self.contentView.addSubview(toXFL)
        
        toXFL.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView.snp_top).offset(25)
            make.height.equalTo(18)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-20)
        })
        
        return toXFL
    } ()
    
    lazy var toXFriendsImageView: UIImageView = {
        let toXFIV = UIImageView()
        toXFIV.backgroundColor = UIColor.clearColor()
        toXFIV.contentMode = .Center
        
        self.contentView.addSubview(toXFIV)
        
        toXFIV.snp_makeConstraints({ (make) -> Void in
            make.size.equalTo(12)
            make.trailing.equalTo(self.toXFriendsLabel.snp_leading).offset(-7)
            make.centerY.equalTo(self.toXFriendsLabel.snp_centerY)
        })
        
        return toXFIV
    } ()
    
    lazy var repliesImageView: UIImageView = {
        let repliesIV = UIImageView()
        repliesIV.backgroundColor = UIColor.clearColor()
        repliesIV.image = UIImage(named: "repliescount-icon")
        
        
        self.contentView.addSubview(repliesIV)
        
        repliesIV.snp_makeConstraints({ (make) -> Void in
            make.width.equalTo(13.5)
            make.height.equalTo(11.5)
            make.leading.equalTo(self.contentView.snp_leading).offset(20)
            make.top.equalTo(self.pleekImageView.snp_bottom).offset(17)
        })
        
        return repliesIV
    } ()
    
    lazy var repliesLabel: UILabel = {
        let repliesL = UILabel()
        repliesL.backgroundColor = UIColor.clearColor()
        repliesL.font = UIFont(name: "ProximaNova-Semibold", size: 12.0)
        repliesL.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        self.contentView.addSubview(repliesL)
        
        repliesL.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(13)
            make.centerY.equalTo(self.repliesImageView.snp_centerY)
            make.leading.equalTo(self.repliesImageView.snp_trailing).offset(8)
        })
        
        return repliesL
    } ()
    
    lazy var newRepliesImageView: UIImageView = {
        let newRIV = UIImageView()
        newRIV.backgroundColor = UIColor.clearColor()
        newRIV.image = UIImage(named: "next-icon")
        
        self.contentView.addSubview(newRIV)
        
        newRIV.snp_makeConstraints({ (make) -> Void in
            make.width.equalTo(6.5)
            make.height.equalTo(11)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-20)
            make.top.equalTo(self.pleekImageView.snp_bottom).offset(17)
        })
        
        return newRIV
    } ()
    
    lazy var newRepliesLabel: UILabel = {
        let newRL = UILabel()
        newRL.backgroundColor = UIColor.clearColor()
        newRL.font = UIFont(name: "ProximaNova-Semibold", size: 12.0)
        newRL.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        self.contentView.addSubview(newRL)
        
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
       
        self.contentView.addSubview(cellSV)
        
        cellSV.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(1)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
        })
        
        return cellSV
    } ()
    
    func setupView() {
        let v1 = self.pleekImageView
        let v2 = self.contentReactView
        let v3 = self.reactTopImageView
        let v4 = self.reactBottomImageView
        let v5 = self.certifiedAccountImageView
        let v6 = self.cellSeparatorView
        self.contentView.bringSubviewToFront(self.pleekImageView)
    }
}


extension InboxCell {
    
    func configureFor(pleek: PFObject) {
        
        println(pleek)
        
        let user = pleek["user"] as! PFUser
        println(user)
        self.fromLabel.attributedText = self.attributedTextForFrom(user["username"] as! String)
        
        if (pleek["isPublic"] as? Bool ?? false) {
            self.toXFriendsLabel.text = "PUBLIC"
            self.toXFriendsImageView.image = UIImage(named: "public-icon")
        } else {
            self.toXFriendsLabel.text = String(format: NSLocalizedString("TO %d FRIENDS", comment: ""), 5)
            self.toXFriendsImageView.image = UIImage(named: "private-icon")
        }
        
        self.repliesLabel.text = String(format: NSLocalizedString("%@ REPLIES", comment: ""), self.formatNumber(pleek["nbReaction"] as? Int ?? 0))
        self.newRepliesLabel.text = String(format: NSLocalizedString("%@ NEW", comment: ""), self.formatNumber(pleek["nbReaction"] as? Int ?? 0))
    }
    
    func configureFor(name: String, indexPath: NSIndexPath) {
        self.fromLabel.attributedText = self.attributedTextForFrom(name)

        if (indexPath.row % 2  == 0) {
            self.toXFriendsLabel.text = "PUBLIC"
            self.toXFriendsImageView.image = UIImage(named: "public-icon")
        } else {
            self.toXFriendsLabel.text = String(format: NSLocalizedString("TO %d FRIENDS", comment: ""), 5)
            self.toXFriendsImageView.image = UIImage(named: "private-icon")
        }
        
        self.repliesLabel.text = String(format: NSLocalizedString("%@ REPLIES", comment: ""), self.formatNumber((indexPath.row + 1) * 3654))
        self.newRepliesLabel.text = String(format: NSLocalizedString("%@ NEW", comment: ""), self.formatNumber((indexPath.row + 1) * 254))
    }
    
    func attributedTextForFrom(name: String) -> NSAttributedString {
        let from = NSLocalizedString("FROM", comment: "")
        let fromWithName = NSLocalizedString("FROM  %@", comment: "")
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
//    override func awakeFromNib() {
//        super.awakeFromNib()
////        let dd = self.pleekImageView
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
////        let dd = self.pleekImageView
//    }
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
////        let dd = self.pleekImageView
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

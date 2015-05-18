//
//  InboxTableViewCell.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

protocol InboxCellDelegate: class {
    func deletePleek(cell : InboxCell)
}

class InboxCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    weak var delegate: InboxCellDelegate? = nil
    
    lazy var deleteView: UIView = {
        let deleteV = UIView()
        deleteV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.contentView.addSubview(deleteV)
        
        deleteV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView)
            make.trailing.equalTo(self.contentView)
            make.leading.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-10)
        })
        
        return deleteV
    } ()
    
    lazy var trashImageView: UIImageView = {
        let trashIV = UIImageView()
        trashIV.image = UIImage(named: "trash-icon-inactive")
        trashIV.backgroundColor = UIColor.clearColor()
        
        self.deleteView.addSubview(trashIV)
        
        trashIV.snp_makeConstraints({ (make) -> Void in
            make.centerY.equalTo(self.deleteView)
            make.trailing.lessThanOrEqualTo(self.deleteView).offset(-35.5)
            make.size.equalTo(CGSizeMake(17, 22.5))
            make.leading.equalTo(self.mainContainerView.snp_trailing).offset(35.5).priorityLow()
        })
        
        return trashIV
    } ()
    
    var mainContainerViewTrailingConstraint: Constraint = Constraint()
    
    lazy var mainContainerView: UIView = {
        let mainCV = UIView()
        mainCV.backgroundColor = UIColor.whiteColor()
        
        self.contentView.addSubview(mainCV)

        mainCV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView)
            self.mainContainerViewTrailingConstraint = make.trailing.equalTo(self.contentView).constraint
            make.width.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-10)
        })
        
        return mainCV
    } ()
    

    lazy var containerView: UIView = {
        let containerV = UIView()
        containerV.backgroundColor = UIColor.whiteColor()
        
        self.mainContainerView.addSubview(containerV)
        
        containerV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.mainContainerView)
            make.trailing.equalTo(self.mainContainerView)
            make.leading.equalTo(self.mainContainerView)
            make.height.equalTo(self.mainContainerView)
        })
        
        return containerV
    } ()
    
    var pleekImageViewWidthConstraint: Constraint = Constraint()
    
    lazy var pleekImageView: PFImageView = {
        let pleekIM = PFImageView()
        
        self.containerView.addSubview(pleekIM)
        
        pleekIM.snp_makeConstraints({ (make) -> Void in
            make.bottom.equalTo(self.containerView)
            make.leading.equalTo(self.containerView)
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
            make.height.equalTo(pleekIM.snp_width)
        })
        
        pleekIM.backgroundColor = UIColor.Theme.PleekBackGroundColor
        pleekIM.layer.shadowColor = UIColor.blackColor().CGColor
        pleekIM.layer.shadowOffset = CGSizeMake(0, 0)
        pleekIM.layer.shadowOpacity = 0.4
        pleekIM.layer.shadowRadius = 2.0
        let shadowRect = CGRectInset(pleekIM.bounds, 0, 2.0)
        pleekIM.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
        return pleekIM
    } ()
    
    lazy var pleekPlayImageView: PFImageView = {
        let pleekPIM = PFImageView()
        pleekPIM.backgroundColor = UIColor.clearColor()
        pleekPIM.image = UIImage(named: "video-icon-big")
        
        self.pleekImageView.addSubview(pleekPIM)
        
        pleekPIM.snp_makeConstraints({ (make) -> Void in
            make.width.equalTo(31)
            make.height.equalTo(37.5)
            make.center.equalTo(self.pleekImageView)
        })

        return pleekPIM
    } ()
    
    lazy var pleekImageSpinner: LLARingSpinnerView = {
        let pleekIS = LLARingSpinnerView()
        pleekIS.hidesWhenStopped = true
        pleekIS.backgroundColor = UIColor.clearColor()
        pleekIS.tintColor = UIColor.Theme.PleekSpinnerColor
        pleekIS.lineWidth = Dimensions.SpinnerLineFatWidth
        self.pleekImageView.addSubview(pleekIS)
        
        pleekIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.pleekImageView)
            make.size.equalTo(30)
        })
        
        return pleekIS
    } ()
    
    lazy var contentReactView: UIView = {
        let contentRV = UIView()
        
        self.containerView.addSubview(contentRV)
        
        contentRV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.pleekImageView)
            make.trailing.equalTo(self.containerView)
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0)
            make.height.equalTo(self.pleekImageView)
        })
        
        contentRV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        contentRV.layer.shadowColor = UIColor.blackColor().CGColor
        contentRV.layer.shadowOffset = CGSizeMake(0, 0)
        contentRV.layer.shadowOpacity = 0.4
        contentRV.layer.shadowRadius = 2.0
        let shadowRect = CGRectInset(contentRV.bounds, 0, 2.0)
        contentRV.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
        return contentRV
    } ()
    
    var topReactBottomConstraint: Constraint = Constraint()
    
    lazy var reactTopImageView: PFImageView = {
        let reacTopIV = PFImageView()
        reacTopIV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        reacTopIV.contentMode = .ScaleAspectFill
        
        reacTopIV.clipsToBounds = true
        
        self.contentReactView.addSubview(reacTopIV)
        
        reacTopIV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentReactView)
            self.topReactBottomConstraint = make.bottom.equalTo(self.contentReactView.snp_centerY).constraint
            make.leading.equalTo(self.contentReactView)
            make.trailing.equalTo(self.contentReactView)
        })
        
        return reacTopIV
    } ()
    
    lazy var reactTopImageSpinner: LLARingSpinnerView = {
        let reactTIS = LLARingSpinnerView()
        reactTIS.hidesWhenStopped = true
        reactTIS.lineWidth = Dimensions.SpinnerLineThinWidth
        reactTIS.tintColor = UIColor.Theme.PleekSpinnerColor
        reactTIS.backgroundColor = UIColor.clearColor()
        
        self.reactTopImageView.addSubview(reactTIS)
        
        reactTIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.reactTopImageView)
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
            make.bottom.equalTo(self.contentReactView)
            make.leading.equalTo(self.contentReactView)
            make.trailing.equalTo(self.contentReactView)
        })
        
        return reactBottomIV
    } ()
    
    lazy var reactBottomImageSpinner: LLARingSpinnerView = {
        let reactBIS = LLARingSpinnerView()
        reactBIS.hidesWhenStopped = true
        reactBIS.lineWidth = Dimensions.SpinnerLineThinWidth
        reactBIS.tintColor = UIColor.Theme.PleekSpinnerColor
        reactBIS.backgroundColor = UIColor.clearColor()
        
        self.reactBottomImageView.addSubview(reactBIS)
        
        reactBIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.reactBottomImageView)
            make.size.equalTo(18)
        })
        
        return reactBIS
    } ()
    
    lazy var fromImageView: UIImageView = {
        let fromIV = UIImageView(frame: CGRectZero)
        fromIV.image = UIImage(named: "incoming-icon")
        
        self.containerView.addSubview(fromIV)
        
        fromIV.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.containerView).offset(20)
            make.width.equalTo(12)
            make.height.equalTo(12.5)
            make.leading.equalTo(self.containerView).offset(20)
        }
        
        return fromIV
    } ()
    
    lazy var usernameLabel: UILabel = {
        let usernameL = UILabel(frame: CGRectZero)
        usernameL.font = UIFont(name: "ProximaNova-Semibold", size: 16.0)!
        usernameL.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        
        self.containerView.addSubview(usernameL)
        
        usernameL.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.fromImageView)
            make.leading.equalTo(self.fromImageView.snp_trailing).offset(9)
        }
        
        return usernameL
    } ()
    
    lazy var certifiedAccountImageView: UIImageView = {
        let certifiedAIV = UIImageView()
        certifiedAIV.backgroundColor = UIColor.whiteColor()
        certifiedAIV.image = UIImage(named: "certified-icon")
        
        self.containerView.addSubview(certifiedAIV)
        
        certifiedAIV.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(24)
            make.height.equalTo(25.5)
            make.leading.equalTo(self.usernameLabel.snp_trailing).offset(8)
            make.centerY.equalTo(self.usernameLabel)
        }
        
        return certifiedAIV
    } ()
    
    lazy var actionImageView: UIImageView = {
        let actionIV = UIImageView()
        actionIV.backgroundColor = UIColor.whiteColor()
        actionIV.image = UIImage(named: "next-icon")
        
        self.containerView.addSubview(actionIV)

        actionIV.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(6.5)
            make.height.equalTo(11)
            make.trailing.equalTo(self.containerView).offset(-20)
            make.centerY.equalTo(self.fromImageView.snp_centerY).offset(-1)
        }

        return actionIV
    } ()
    
    lazy var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.backgroundColor = UIColor.whiteColor()
        infoLabel.font = UIFont(name: "Montserrat-Regular", size: 11.0)
        infoLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        infoLabel.text = LocalizedString("NEW REPLIES")
        
        self.containerView.addSubview(infoLabel)
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.fromImageView)
            make.trailing.equalTo(self.actionImageView.snp_leading).offset(-10)
        }
        
        return infoLabel
    } ()

    lazy var infoImageView: UIImageView = {
        let infoIV = UIImageView()
        infoIV.backgroundColor = UIColor.whiteColor()
        infoIV.contentMode = .Center
        infoIV.image = UIImage(named: "newpicture-icon")
        
        self.containerView.addSubview(infoIV)
        
        infoIV.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(12)
            make.centerY.equalTo(self.fromImageView)
            make.trailing.equalTo(self.infoLabel.snp_leading).offset(-5)
        }
        
        return infoIV
    } ()

    lazy var cellSeparatorView: UIView = {
        let cellSV = UIView()
        cellSV.backgroundColor = UIColor(red: 206.0/255.0, green: 212.0/255.0, blue: 220.0/255.0, alpha: 1.0)
       
        self.contentView.addSubview(cellSV)
        
        cellSV.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(0.5)
            make.top.equalTo(self.contentView)
            make.leading.equalTo(self.contentView)
            make.trailing.equalTo(self.contentView)
        })
        
        return cellSV
    } ()
    
    // MARK: Life Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        self.contentView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        
        let v111 = self.trashImageView
        let v112 = self.mainContainerView
        let v11 = self.pleekPlayImageView
        let v1 = self.pleekImageSpinner
        let v2 = self.contentReactView
        let v3 = self.reactTopImageSpinner
        let v4 = self.reactBottomImageSpinner
        let v5 = self.certifiedAccountImageView
        let v7 = self.infoImageView
        let v6 = self.cellSeparatorView

        self.mainContainerView.bringSubviewToFront(self.contentReactView)
        self.mainContainerView.bringSubviewToFront(self.pleekImageView)
        
        
        self.clipsToBounds = true
        self.selectionStyle = .None
        
        let panGestureRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        self.pleekImageView.snp_updateConstraints{ (make) -> Void in
            if CGRectGetHeight(self.contentView.frame) == CGRectGetWidth(self.contentView.frame) + 60 {
                make.width.equalTo(CGRectGetWidth(self.contentView.frame))
            } else {
                make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0 * 2.0 - 2)
            }
        }
        
        self.contentReactView.snp_updateConstraints{ (make) -> Void in
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) / 3.0)
        }
        
        super.updateConstraints()
    }
    
    // MARK: Action
    
    func handlePan(recognizer: UIPanGestureRecognizer!) {
        
        let translation = recognizer.translationInView(recognizer.view!)
        
        if recognizer.state == .Began {
            return
        } else if recognizer.state == .Changed {
            if translation.x < 0 {
                if abs(translation.x) >= CGRectGetWidth(self.frame) / 3.0 {
                    self.deleteView.backgroundColor = UIColor.Theme.DeletePleekBackGroundColor
                    self.trashImageView.image = UIImage(named: "trash-icon-active")
                } else {
                    self.deleteView.backgroundColor = UIColor.Theme.PleekBackGroundColor
                    self.trashImageView.image = UIImage(named: "trash-icon-inactive")
                }

                self.mainContainerViewTrailingConstraint.updateOffset(translation.x)
                self.deleteView.setNeedsLayout()
                self.deleteView.layoutIfNeeded()
            }
            return
        } else if recognizer.state == .Ended || recognizer.state == .Cancelled {
            var finalColor = UIColor.Theme.PleekBackGroundColor
            var offset: CGFloat = 0
            var image = UIImage(named: "trash-icon-inactive")
            var shouldDelete = false
            if abs(translation.x) >= CGRectGetWidth(self.frame) / 3.0 {
                finalColor = UIColor.Theme.DeletePleekBackGroundColor
                offset = -CGRectGetWidth(self.frame)
                image = UIImage(named: "trash-icon-active")
                shouldDelete = true
            }
            
            self.mainContainerViewTrailingConstraint.updateOffset(offset)
            self.contentView.setNeedsLayout()
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.deleteView.backgroundColor = finalColor
                self.contentView.layoutIfNeeded()
                self.trashImageView.image = image
            }) { (finished) -> Void in
                if let delegate = self.delegate {
                    if shouldDelete {
                        delegate.deletePleek(self)
                    }
                }
            }
            return
        }
    }

}

extension InboxCell {
    
    func configureFor(pleek: Pleek) {

        self.mainContainerViewTrailingConstraint.updateOffset(0)
        self.deleteView.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.usernameLabel.text = pleek.user.username
        
        weak var weakSelf = self
        
        self.pleekImageView.image = nil
        self.pleekImageSpinner.hidden = false
        self.pleekImageSpinner.startAnimating()
        
        if pleek.isVideo {
            self.pleekImageView.file = pleek.previewImage
            self.pleekPlayImageView.hidden = false
        } else {
            self.pleekImageView.file = pleek.photo
            self.pleekPlayImageView.hidden = true
        }
        
        self.pleekImageView.loadInBackground { (image, error) -> Void in
            weakSelf?.pleekImageSpinner.hidden = true
        }
        
        self.reactTopImageView.image = nil
        self.reactBottomImageView.image = nil

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
        
        self.topReactBottomConstraint.uninstall()
        
        if pleek.nbReaction > 1 {
            self.contentReactView.hidden = false
            self.reactBottomImageView.hidden = false
            self.reactTopImageView.snp_makeConstraints { (make) -> Void in
                self.topReactBottomConstraint = make.bottom.equalTo(self.contentReactView.snp_centerY).constraint
            }
        } else if pleek.nbReaction > 0 {
            self.contentReactView.hidden = false
            self.reactBottomImageView.hidden = true
            self.reactTopImageView.snp_makeConstraints { (make) -> Void in
                self.topReactBottomConstraint = make.bottom.equalTo(self.contentReactView.snp_bottom).constraint
            }
        } else {
            self.contentReactView.hidden = true
        }
        
        self.contentReactView.setNeedsLayout()
        
        if pleek.user.isCertified {
            self.certifiedAccountImageView.hidden = false
        } else {
            self.certifiedAccountImageView.hidden = true
        }
        
        self.infoImageView.hidden = true
        
        if !pleek.isSeen {
            self.infoImageView.hidden = false
            if pleek.isVideo {
                self.infoLabel.text = LocalizedString("NEW VIDEO")
                self.infoImageView.image = UIImage(named: "newvideo-icon")
            } else {
                self.infoLabel.text = LocalizedString("NEW PICTURE")
                self.infoImageView.image = UIImage(named: "newpicture-icon")
            }
        } else if pleek.nbNewReaction > 0 {
            self.infoImageView.hidden = false
            self.infoLabel.text = LocalizedString("NEW REPLIES")
            self.infoImageView.image = UIImage(named: "newreplies-icon")
        } else if pleek.nbReaction == 0 {
            self.infoLabel.text = LocalizedString("REPLY FIRST")
        } else if pleek.nbReaction == 1 {
            self.infoLabel.text = LocalizedString("1 REPLY")
        } else {
            self.infoLabel.text = String(format: LocalizedString("%@ REPLIES"), self.formatNumber(pleek.nbReaction))
        }
    }
    
    func formatNumber(number: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter.stringFromNumber(number)!
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            let uiPanGesture:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let velocity:CGPoint = uiPanGesture.velocityInView(self)
            return fabs(velocity.y) < fabs(velocity.x)
        } else {
            return true
        }
    }

}






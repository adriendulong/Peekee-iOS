//
//  InboxTableViewCell.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

enum InboxCellType {
    case BlueBandLargePhoto
    case BlueBandSmallPhoto
    case LargePhoto
    case SmallPhoto
}

protocol InboxCellDelegate: class {
    func deletePleek(cell : InboxCell)
}

class InboxCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    weak var delegate: InboxCellDelegate? = nil
    var type: InboxCellType = .BlueBandSmallPhoto
    
    lazy var deleteView: UIView = {
        let deleteV = UIView()
        deleteV.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        
        self.contentView.addSubview(deleteV)
        
        deleteV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView)
            make.trailing.equalTo(self.contentView)
            make.leading.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
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
        mainCV.backgroundColor = UIColor.clearColor()
        
        self.contentView.addSubview(mainCV)

        mainCV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.contentView).offset(12.0)
            self.mainContainerViewTrailingConstraint = make.trailing.equalTo(self.contentView).constraint
            make.width.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-3.0)
        })
        
        return mainCV
    } ()
    
    lazy var cardView: UIView = {
        let cardV = UIView()
        cardV.backgroundColor = UIColor.whiteColor()
        cardV.layer.cornerRadius = 5.0
        cardV.clipsToBounds = true
        
        self.mainContainerView.addSubview(cardV)
        
        cardV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.mainContainerView)
            make.centerX.equalTo(self.mainContainerView)
            make.width.equalTo(self.mainContainerView).offset(-20)
            make.bottom.equalTo(self.mainContainerView)
        })
        
        return cardV
    } ()

    lazy var containerView: UIView = {
        let containerV = UIView()
        containerV.backgroundColor = UIColor.clearColor()
        
        self.mainContainerView.addSubview(containerV)
        
        containerV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.mainContainerView)
            make.trailing.equalTo(self.mainContainerView)
            make.leading.equalTo(self.mainContainerView)
            make.bottom.equalTo(self.mainContainerView)
        })
        
        return containerV
    } ()
    
    var pleekImageViewWidthConstraint: Constraint = Constraint()
    
    lazy var pleekImageView: PFImageView = {
        let pleekIM = PFImageView()
         pleekIM.backgroundColor = UIColor.clearColor()
        
        self.containerView.addSubview(pleekIM)
        
        pleekIM.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.containerView).offset(45.0)
            make.leading.equalTo(self.containerView).offset(5.0)
            make.width.equalTo(CGRectGetWidth(self.contentView.frame) - 10.0)
            make.height.equalTo(pleekIM.snp_width)
        })
        
       
//        pleekIM.layer.shadowColor = UIColor.blackColor().CGColor
//        pleekIM.layer.shadowOffset = CGSizeMake(0, 0)
//        pleekIM.layer.shadowOpacity = 0.4
//        pleekIM.layer.shadowRadius = 2.0
//        let shadowRect = CGRectInset(pleekIM.bounds, 0, 2.0)
//        pleekIM.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
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
        contentRV.backgroundColor = UIColor.clearColor()
        
        self.containerView.addSubview(contentRV)
        
        contentRV.snp_makeConstraints({ (make) -> Void in
            make.top.equalTo(self.pleekImageView)
            make.trailing.equalTo(self.containerView).offset(-5.0)
            make.width.equalTo((CGRectGetWidth(self.contentView.frame) - 12.5) / 3.0)
            make.height.equalTo(self.pleekImageView)
        })
        
//        contentRV.layer.shadowColor = UIColor.blackColor().CGColor
//        contentRV.layer.shadowOffset = CGSizeMake(0, 0)
//        contentRV.layer.shadowOpacity = 0.4
//        contentRV.layer.shadowRadius = 2.0
//        let shadowRect = CGRectInset(contentRV.bounds, 0, 2.0)
//        contentRV.layer.shadowPath = UIBezierPath(rect: shadowRect).CGPath
        
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
            self.topReactBottomConstraint = make.bottom.equalTo(self.contentReactView.snp_centerY).offset(-1.25).constraint
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
            make.top.equalTo(self.contentReactView.snp_centerY).offset(1.25)
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
    
    lazy var replyLabel: UILabel = {
        let replyLabel = UILabel()
        replyLabel.backgroundColor = UIColor.whiteColor()
        replyLabel.font = UIFont(name: "Montserrat-Regular", size: 11.0)
        replyLabel.textColor = UIColor(red: 26.0/255.0, green: 27.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        replyLabel.text = LocalizedString("NEW REPLIES")
        
        self.containerView.addSubview(replyLabel)
        
        replyLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.fromImageView)
            make.trailing.equalTo(self.actionImageView.snp_leading).offset(-10)
        }
        
        return replyLabel
    } ()
    
    lazy var blueCardView: UIView = {
        let cardV = UIView()
        cardV.backgroundColor = UIColor(red: 85.0/255.0, green: 114.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        cardV.layer.cornerRadius = 5.0
        
        self.cardView.addSubview(cardV)
        
        cardV.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(45.0)
            make.centerX.equalTo(self.mainContainerView)
            make.width.equalTo(self.cardView)
            make.bottom.equalTo(self.cardView)
        })
        
        let innerTrick = UIView()
        innerTrick.backgroundColor = UIColor(red: 85.0/255.0, green: 114.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
        cardV.addSubview(innerTrick)
        
        innerTrick.snp_makeConstraints({ (make) -> Void in
            make.height.equalTo(10.0)
            make.centerX.equalTo(cardV)
            make.width.equalTo(cardV)
            make.top.equalTo(cardV)
        })
        
        return cardV
    } ()
    

    lazy var infoImageView: UIImageView = {
        let infoIV = UIImageView()
        infoIV.backgroundColor = UIColor.clearColor()
        infoIV.contentMode = .Center
        infoIV.image = UIImage(named: "newpicture-icon")
        
        self.blueCardView.addSubview(infoIV)
        
        infoIV.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(12)
            make.trailing.equalTo(self.infoLabel.snp_leading).offset(-8)
            make.centerY.equalTo(self.infoLabel)
        }
        
        return infoIV
    } ()
    
    lazy var infoLabel: UILabel = {
        let infoL = UILabel()
        infoL.textColor = UIColor.whiteColor()
        infoL.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        infoL.textAlignment = .Center
        
        self.blueCardView.addSubview(infoL)
        
        infoL.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.blueCardView)
            make.centerX.equalTo(self.blueCardView).offset(10)
        }
        
        return infoL
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
        let cardView = self.cardView
        let blueCardView = self.blueCardView
        let v11 = self.pleekPlayImageView
        let v1 = self.pleekImageSpinner
        let v2 = self.contentReactView
        let v3 = self.reactTopImageSpinner
        let v4 = self.reactBottomImageSpinner
        let v5 = self.certifiedAccountImageView
        let infoImageView = self.infoImageView
        let infoLabel = self.infoLabel

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
            switch self.type {
                case .BlueBandLargePhoto, .LargePhoto:
                    make.width.equalTo(CGRectGetWidth(self.contentView.frame) - 10.0)
                break
                case .BlueBandSmallPhoto, .SmallPhoto:
                    make.width.equalTo(round((CGRectGetWidth(self.contentView.frame) - 12.5) / 3.0 * 2.0))
                break
            }
        }
        
        self.contentReactView.snp_updateConstraints{ (make) -> Void in
            make.width.equalTo(round((CGRectGetWidth(self.contentView.frame) - 12.5) / 3.0))
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
                    self.trashImageView.image = UIImage(named: "trash-icon-active")
                } else {
                    self.trashImageView.image = UIImage(named: "trash-icon-inactive")
                }

                self.mainContainerViewTrailingConstraint.updateOffset(translation.x)
                self.deleteView.setNeedsLayout()
                self.deleteView.layoutIfNeeded()
            }
            return
        } else if recognizer.state == .Ended || recognizer.state == .Cancelled {
            var offset: CGFloat = 0
            var image = UIImage(named: "trash-icon-inactive")
            var shouldDelete = false
            if abs(translation.x) >= CGRectGetWidth(self.frame) / 3.0 {
                offset = -CGRectGetWidth(self.frame)
                image = UIImage(named: "trash-icon-active")
                shouldDelete = true
            }
            
            self.mainContainerViewTrailingConstraint.updateOffset(offset)
            self.contentView.setNeedsLayout()
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
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
        
        switch (pleek.state, pleek.nbReaction > 0) {
        case (.NotSeenVideo, true), (.NotSeenPhoto, true), (.SeenNewReact, true):
            self.type = .BlueBandSmallPhoto
            break
        case (.SeenNotNewReact, true):
            self.type = .SmallPhoto
            break
        case (.NotSeenVideo, false), (.NotSeenPhoto, false), (.SeenNewReact, false):
            self.type = .BlueBandLargePhoto
            break
        case (.SeenNotNewReact, false):
            self.type = .LargePhoto
            break
        default:
            break
        }
        
        self.mainContainerViewTrailingConstraint.updateOffset(0)
        self.deleteView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        
        self.usernameLabel.text = pleek.user.username
        
        weak var weakSelf = self
        
        self.pleekImageView.image = nil
        self.pleekImageSpinner.startAnimating()
        self.pleekPlayImageView.hidden = true
        
        if pleek.isVideo {
            self.pleekImageView.file = pleek.previewImage
        } else {
            self.pleekImageView.file = pleek.photo
        }
        
        self.pleekImageView.loadInBackground { (image, error) -> Void in
            weakSelf?.pleekImageSpinner.stopAnimating()
            if pleek.isVideo {
                self.pleekPlayImageView.hidden = false
            }
        }
        
        self.reactTopImageView.image = nil
        self.reactBottomImageView.image = nil

        if let react1 = pleek.react1 {
            self.reactTopImageSpinner.startAnimating()
            self.reactTopImageView.file = react1
            self.reactTopImageView.loadInBackground { (image, error) -> Void in
                weakSelf?.reactTopImageSpinner.stopAnimating()
            }
        }
        
        if let react2 = pleek.react2 {
            self.reactBottomImageSpinner.startAnimating()
            self.reactBottomImageView.file = react2
            self.reactBottomImageView.loadInBackground { (image, error) -> Void in
                weakSelf?.reactBottomImageSpinner.stopAnimating()
            }
        }
        
        self.topReactBottomConstraint.uninstall()
        
        if pleek.nbReaction > 1 {
            self.contentReactView.hidden = false
            self.reactBottomImageView.hidden = false
            self.reactTopImageView.snp_makeConstraints { (make) -> Void in
                self.topReactBottomConstraint = make.bottom.equalTo(self.contentReactView.snp_centerY).offset(-1.25).constraint
            }
        } else if pleek.nbReaction > 0 {
            self.contentReactView.hidden = false
            self.reactBottomImageView.hidden = true
            self.reactTopImageView.snp_makeConstraints { (make) -> Void in
                self.topReactBottomConstraint = make.bottom.equalTo(self.contentReactView).constraint
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
        
        self.blueCardView.hidden = false
        
        switch pleek.state {
            case .NotSeenVideo:
                self.infoImageView.image = UIImage(named: "newvideo-icon")
                self.infoLabel.text = LocalizedString("NEW VIDEO")
                break
            case .NotSeenPhoto:
                self.infoImageView.image = UIImage(named: "newpicture-icon")
                self.infoLabel.text = LocalizedString("NEW PICTURE")
                break
            case .SeenNewReact:
                self.infoImageView.image = UIImage(named: "newreplies-icon")
                self.infoLabel.text = LocalizedString("NEW REPLIES")
                break
            case .SeenNotNewReact:
                self.blueCardView.hidden = true
                break
        }
        
        if pleek.nbReaction == 0 {
            self.replyLabel.text = LocalizedString("REPLY FIRST")
        } else if pleek.nbReaction == 1 {
            self.replyLabel.text = LocalizedString("1 REPLY")
        } else {
            self.replyLabel.text = String(format: LocalizedString("%@ REPLIES"), self.formatNumber(pleek.nbReaction))
        }
    }
    
    func formatNumber(number: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.locale = NSLocale.currentLocale()
        return formatter.stringFromNumber(number)!
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity:CGPoint = panGesture.velocityInView(self)
            return fabs(velocity.y) < fabs(velocity.x)
        } else {
            return true
        }
    }

}






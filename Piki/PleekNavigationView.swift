//
//  PleekNavigationView.swift
//  POCTopBar
//
//  Created by Kevin CATHALY on 13/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

protocol PleekNavigationViewDelegate: class {
    func navigationView(navigationView: PleekNavigationView, didSelectTabAtIndex index: UInt)
    func navigationView(navigationView: PleekNavigationView, shouldUpdateTopConstraintOffset offset: CGFloat, animated: Bool)
    func navigationViewShowSettings(navigationView: PleekNavigationView)
    func navigationViewShowFriends(navigationView: PleekNavigationView)
}

class PleekNavigationView: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: PleekNavigationViewDelegate?
    private var indicatorCenterXConstraint = Constraint()
    
    private var startY: CGFloat = 0
    private var startOffset: CGFloat = 0
    
    private let minimumOffset: CGFloat = -35
    private let maximumOffset: CGFloat = 20
    private lazy var middleOffset: CGFloat = {
        return (self.minimumOffset + self.maximumOffset) / 2.0
    } ()
    
    private let startDelta: CGFloat = 120
    
    private lazy var topContainerView: UIView = {
        let topCV = UIView()
        topCV.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        self.addSubview(topCV)
        
        topCV.snp_makeConstraints{ (make) -> Void in
            make.leading.equalTo(self.snp_leading)
            make.trailing.equalTo(self.snp_trailing)
            make.height.equalTo(55)
            make.bottom.equalTo(self.bottomContainerView.snp_top)
        }
        
        return topCV
    } ()
    
    private lazy var bottomContainerView: UIView = {
        let bottomCV = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame), 45))
        bottomCV.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        
        self.addSubview(bottomCV)
        
        bottomCV.snp_makeConstraints{ (make) -> Void in
            make.leading.equalTo(self.snp_leading)
            make.trailing.equalTo(self.snp_trailing)
            make.height.equalTo(45)
            make.bottom.equalTo(self.snp_bottom)
        }
        
        return bottomCV
    } ()
    
    private lazy var settingsButton: UIButton = {
        let settingsB = UIButton()
        settingsB.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        settingsB.setImage(UIImage(named: "settings-icon"), forState: .Normal)
        settingsB.addTarget(self, action: Selector("settingsAction:"), forControlEvents: .TouchUpInside)
        
        self.topContainerView.addSubview(settingsB)
        
        settingsB.snp_makeConstraints{ (make) -> Void in
            make.leading.equalTo(self.topContainerView.snp_leading).offset(22)
            make.size.equalTo(21)
            make.top.equalTo(self.topContainerView.snp_top).offset(20)
        }
        
        return settingsB
    } ()
    
    private lazy var logoImageView: UIImageView = {
        let logoIV = UIImageView()
        logoIV.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        logoIV.image = UIImage(named: "logo")
        
        self.topContainerView.addSubview(logoIV)
        
        logoIV.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(37)
            make.height.equalTo(40.5)
            make.centerX.equalTo(self.topContainerView.snp_centerX)
            make.top.equalTo(self.topContainerView.snp_top).offset(13)
        }
        
        return logoIV
    } ()
    
    private lazy var friendsButton: UIButton = {
        let friendsB = UIButton()
        friendsB.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        friendsB.setImage(UIImage(named: "friends-icon"), forState: .Normal)
        friendsB.addTarget(self, action: Selector("friendsAction:"), forControlEvents: .TouchUpInside)
        
        self.topContainerView.addSubview(friendsB)
        
        friendsB.snp_makeConstraints{ (make) -> Void in
            make.trailing.equalTo(self.topContainerView.snp_trailing).offset(-22)
            make.width.equalTo(25)
            make.height.equalTo(16)
            make.centerY.equalTo(self.settingsButton.snp_centerY)
        }
        
        return friendsB
    } ()
    
    private lazy var inboxButton: PleekNavigationButton = {
        let inboxB = PleekNavigationButton(image: UIImage(named: "inbox-icon-inactive"), selectedImage: UIImage(named: "inbox-icon-active"), text: NSLocalizedString("INBOX", comment: ""))
        inboxB.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        inboxB.selected = true
        
        inboxB.addTarget(self, action: Selector("didSelectButton:"), forControlEvents: .TouchUpInside)
        
        self.bottomContainerView.addSubview(inboxB)
        
        inboxB.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(CGRectGetWidth(self.bottomContainerView.frame)/3.0)
            make.leading.equalTo(self.bottomContainerView.snp_leading)
            make.top.equalTo(self.bottomContainerView.snp_top)
            make.bottom.equalTo(self.bottomContainerView.snp_bottom)
        }
        
        return inboxB
    } ()
    
    private lazy var sentButton: PleekNavigationButton = {
        let sentB = PleekNavigationButton(image: UIImage(named: "sent-icon-inactive"), selectedImage: UIImage(named: "sent-icon-active"), text: NSLocalizedString("SENT", comment: ""))
        sentB.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        
        sentB.addTarget(self, action: Selector("didSelectButton:"), forControlEvents: .TouchUpInside)
        
        self.bottomContainerView.addSubview(sentB)
        
        sentB.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(self.inboxButton.snp_width)
            make.centerX.equalTo(self.bottomContainerView.snp_centerX)
            make.top.equalTo(self.bottomContainerView.snp_top)
            make.bottom.equalTo(self.bottomContainerView.snp_bottom)
        }

        return sentB
    } ()
    
    private lazy var bestButton: PleekNavigationButton = {
        let bestB = PleekNavigationButton(image: UIImage(named: "best-icon-inactive"), selectedImage: UIImage(named: "best-icon-active"), text: NSLocalizedString("BEST", comment: ""))
        bestB.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        bestB.newContent = true
        
        bestB.addTarget(self, action: Selector("didSelectButton:"), forControlEvents: .TouchUpInside)
        
        self.bottomContainerView.addSubview(bestB)
        
        bestB.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(self.inboxButton.snp_width)
            make.trailing.equalTo(self.bottomContainerView.snp_trailing)
            make.top.equalTo(self.bottomContainerView.snp_top)
            make.bottom.equalTo(self.bottomContainerView.snp_bottom)
        }
        
        return bestB
    } ()
    
    private lazy var selectedIndicatorView: UIView = {
        let selectedIV = UIView()
        selectedIV.backgroundColor = UIColor(red: 255.0/255.0, green: 64.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        
        self.bottomContainerView.addSubview(selectedIV)
        
        selectedIV.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(self.inboxButton.snp_width)
            make.height.equalTo(2 )
            make.bottom.equalTo(self.bottomContainerView.snp_bottom)
            self.indicatorCenterXConstraint = make.centerX.equalTo(self.inboxButton.snp_centerX).constraint
        }
        
        
        return selectedIV
    } ()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    private func setupView() {
        
        self.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        
        let settings = self.settingsButton
        let logo = self.logoImageView
        let friends = self.friendsButton
        
        let inbox = self.inboxButton
        let sent = self.sentButton
        let best = self.bestButton
        let indicator = self.selectedIndicatorView
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.38
        self.layer.shadowOffset = CGSizeMake(0, 2)

        self.setNeedsUpdateConstraints()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        self.inboxButton.snp_updateConstraints{ (make) -> Void in
            make.width.equalTo(CGRectGetWidth(self.bottomContainerView.frame)/3.0)
        }
        
        super.updateConstraints()
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Action
    
    func settingsAction(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.navigationViewShowSettings(self)
        }
    }
    
    func friendsAction(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.navigationViewShowFriends(self)
        }
    }
    
    func didSelectButton(sender: PleekNavigationButton) {
        
        sender.selected = true
        
        if sender != self.inboxButton {
            self.inboxButton.selected = false
        }
        
        if sender != self.sentButton {
            self.sentButton.selected = false
        }
        
        if sender != self.bestButton {
            self.bestButton.selected = false
        }
        
        var index: UInt = 0
        
        switch sender {
        case self.inboxButton:
            index = 0
        break
        case self.sentButton:
            index = 1
        break
        case self.bestButton:
            index = 2
        break
        default:
            return
        }

        self.indicatorCenterXConstraint.updateOffset(CGRectGetMidX(sender.frame) - CGRectGetMidX(self.inboxButton.frame))
        sender.superview!.setNeedsLayout()
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 8.0, options: nil, animations: { () -> Void in
            sender.superview!.layoutIfNeeded()
        }, completion: nil)
        
        if let delegate = self.delegate {
            delegate.navigationView(self, didSelectTabAtIndex: index)
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer!) {
        
        if recognizer.state == .Began {
            self.startY = recognizer.locationInView(self.superview!).y
            self.startOffset = CGRectGetMinY(self.frame)

            return
        } else if recognizer.state == .Changed {
            let delta = recognizer.locationInView(self.superview!).y - self.startY

            
            if abs(delta) < self.startDelta {
                return
            }
            var newOffset = delta
            
            if delta > 0 {
                newOffset -= self.startDelta
            } else {
                newOffset += self.startDelta
            }
            
            if newOffset + self.startOffset <= self.minimumOffset {
                newOffset = self.minimumOffset
            } else if newOffset + self.startOffset >= self.maximumOffset {
                newOffset = self.maximumOffset
            } else {
                newOffset += self.startOffset
            }
            
            if let delegate = self.delegate {
                delegate.navigationView(self, shouldUpdateTopConstraintOffset: newOffset, animated: false)
            }
            
            return
        } else if recognizer.state == .Ended || recognizer.state == .Cancelled {
            let delta = recognizer.locationInView(self.superview!).y - self.startY

            if abs(delta) <= self.startDelta {
                if let delegate = self.delegate {
                    delegate.navigationView(self, shouldUpdateTopConstraintOffset: self.startOffset, animated: true)
                }
                return
            }
            
            var newOffset = delta
            
            if newOffset + self.startOffset <= self.minimumOffset || newOffset <= -middleOffset {
                newOffset = self.minimumOffset
            } else if newOffset + self.startOffset >= self.maximumOffset || newOffset > -middleOffset {
                newOffset = self.maximumOffset
            }
            
            if let delegate = self.delegate {
                delegate.navigationView(self, shouldUpdateTopConstraintOffset: newOffset, animated: true)
            }
            
            return
        }
    }
    
    func openView() {
        if let delegate = self.delegate {
            delegate.navigationView(self, shouldUpdateTopConstraintOffset: self.maximumOffset, animated: true)
        }
    }

}

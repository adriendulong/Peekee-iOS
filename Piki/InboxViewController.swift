//
//  InboxViewController.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, PleekNavigationViewDelegate, PleekTableViewControllerDelegate, PleekCollectionViewControllerDelegate, SearchFriendsProtocol, UIAlertViewDelegate {
    
    
    // MARK: Old
    
    var popUpUnlockFriends:UIView?
    var popUpLoopNotif:UIView?
    var overlayView:UIView?
    
    var firstUserUnlock:Bool?
    
    var overlayTutoView:UIView?
    
    var popUpShowTuto:UIView?
    var showTutoFirst:Bool = false
    
    var isLoadingMore:Bool = false
    
    // MARK: New
    
    var receivedPleeksTableViewTrailingConstraint = Constraint()
    
    lazy var receivedPleeksTableViewController: PleekTableViewController = {
        let tableViewC = PleekTableViewController()
        tableViewC.key = "mostRecentReceivedPleek"
        tableViewC.dataSource = User.currentUser()!.getReceivedPleeks()
        tableViewC.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        tableViewC.tableView.addGestureRecognizer(panGesture)
        
        self.addChildViewController(tableViewC)
        
        self.view.addSubview(tableViewC.view)
        
        tableViewC.view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view.snp_bottom)
            make.width.equalTo(self.view.snp_width)
            self.receivedPleeksTableViewTrailingConstraint = make.trailing.equalTo(self.view.snp_trailing).offset(0).constraint
        }
        
        return tableViewC
    } ()
    
    lazy var sentPleeksTableViewController: PleekTableViewController = {
        let tableViewC = PleekTableViewController()
        tableViewC.key = "mostRecentSentPleek"
        tableViewC.searchState = .Unsearchable
        tableViewC.dataSource = User.currentUser()!.getSentPleeks()
        tableViewC.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        tableViewC.tableView.addGestureRecognizer(panGesture)
        
        self.addChildViewController(tableViewC)
        
        self.view.addSubview(tableViewC.view)
        
        tableViewC.view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view.snp_bottom)
            make.width.equalTo(self.view.snp_width)
            make.leading.equalTo(self.receivedPleeksTableViewController.view.snp_trailing)
        }
        
        return tableViewC
    } ()
    
    lazy var bestPleekCollectionViewController: PleekCollectionViewController = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 7
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top:9, left: 9, bottom: 8, right: 9)
        
        let collectionViewC = PleekCollectionViewController(collectionViewLayout: layout)
        collectionViewC.key = "mostRecentBestPleek"
        collectionViewC.dataSource = Pleek.getBestPleek()
        collectionViewC.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        collectionViewC.collectionView?.addGestureRecognizer(panGesture)
        
        self.addChildViewController(collectionViewC)
        
        self.view.addSubview(collectionViewC.view)
        
        collectionViewC.view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view)
            make.width.equalTo(self.view)
            make.leading.equalTo(self.sentPleeksTableViewController.view.snp_trailing)
        }
        
        return collectionViewC
    } ()
    
    lazy var statusBarView: UIView = {
        let statusBV = UIView()
        statusBV.backgroundColor = UIColor(red: 31.0/255.0, green: 41.0/255.0, blue: 103.0/255.0, alpha: 1.0)
        
        self.view.addSubview(statusBV)
        
        statusBV.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.top.equalTo(self.view.snp_top)
            make.height.equalTo(20)
        }
        
        return statusBV
    } ()
    
    var navigationViewTopConstraint = Constraint()
    
    lazy var navigationView: PleekNavigationView = {
       let navigationV = PleekNavigationView()
        navigationV.delegate = self
        
        self.view.addSubview(navigationV)
        
        navigationV.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            self.navigationViewTopConstraint = make.top.equalTo(self.view.snp_top).offset(20).constraint
            make.height.equalTo(100)
        }
        
        return navigationV
    } ()
    
    var newPleekButtonBottomConstraint = Constraint()
    
    lazy var newPleekButton: UIButton = {
        let newPB = UIButton()
        newPB.addTarget(self, action: Selector("newPleekAction:"), forControlEvents: .TouchUpInside)
        newPB.setImage(UIImage(named: "newpleek-button"), forState: .Normal)
        
        self.view.addSubview(newPB)
        
        newPB.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(77)
            make.height.equalTo(80.5)
            make.trailing.equalTo(self.view.snp_trailing).offset(-20)
            self.newPleekButtonBottomConstraint = make.bottom.equalTo(self.view.snp_bottom).offset(80.5).constraint
        }
        
        return newPB
    } ()
    
    // MARK: Life Cycle
    
    override func viewDidAppear(animated: Bool) {
        if let hasSeenRecommanded = User.currentUser()!["hasSeenRecommanded"] as? Bool {
            if !hasSeenRecommanded {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let acountsAdviceViewController = storyboard.instantiateViewControllerWithIdentifier("AcountsAdviceViewControllerID") as? AcountsAdviceViewController {
                    self.presentViewController(acountsAdviceViewController, animated: true, completion: nil)
                }
            }
        } else {
            if let hasShownOverlayMenu = User.currentUser()!["hasShownOverlayMenu"] as? Bool {
                if !hasShownOverlayMenu {
                    self.showTutoOverlay()
                    self.showTutoFirst = true
                    self.askShowTutoVideo()
                }
            } else {
                showTutoOverlay()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    func setupView() {
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.setNeedsStatusBarAppearanceUpdate()
        
        let received = self.receivedPleeksTableViewController
        let sent = self.sentPleeksTableViewController
        let navigationView = self.navigationView
        let statusBar = self.statusBarView
        let best = self.bestPleekCollectionViewController
        let newPleekButton = self.newPleekButton
        
        self.view.bringSubviewToFront(self.navigationView)
        self.view.bringSubviewToFront(self.statusBarView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    // MARK: Appearance
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func popNewPleekButton() {
        self.newPleekButtonBottomConstraint.updateOffset(-20.0)
        self.newPleekButton.setNeedsLayout()
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: nil, animations: { () -> Void in
            self.newPleekButton.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideNewPleekButton() {
        self.newPleekButtonBottomConstraint.updateOffset(80.5)
        self.newPleekButton.setNeedsLayout()
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: nil, animations: { () -> Void in
            self.newPleekButton.layoutIfNeeded()
            }, completion: nil)
    }
    
    // MARK: PleekNavigationViewDelegate
    
    func navigationView(navigationView: PleekNavigationView, didSelectTabAtIndex index: UInt) {
        self.receivedPleeksTableViewController.tableView.scrollsToTop = false
        self.sentPleeksTableViewController.tableView.scrollsToTop = false
        self.bestPleekCollectionViewController.collectionView?.scrollsToTop = false
        
        if index == 0 {
            self.receivedPleeksTableViewTrailingConstraint.updateOffset(0)
            self.receivedPleeksTableViewController.tableView.scrollsToTop = true
            self.popNewPleekButton()
        } else if index == 1 {
            self.receivedPleeksTableViewTrailingConstraint.updateOffset(-CGRectGetWidth(self.view.frame))
            self.sentPleeksTableViewController.tableView.scrollsToTop = true
            self.popNewPleekButton()
        } else if index == 2 {
            self.receivedPleeksTableViewTrailingConstraint.updateOffset(-CGRectGetWidth(self.view.frame) * 2)
            self.bestPleekCollectionViewController.collectionView?.scrollsToTop = true
            self.hideNewPleekButton()
        }
        
        self.view.setNeedsLayout()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func navigationView(navigationView: PleekNavigationView, shouldUpdateTopConstraintOffset offset: CGFloat, animated: Bool) {
        self.navigationViewTopConstraint.updateOffset(offset)
        
        self.view.setNeedsLayout()
        if animated {
            UIView.animateWithDuration(0.4) { () -> Void in
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    func navigationViewShowSettings(navigationView: PleekNavigationView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsNavC = storyboard.instantiateViewControllerWithIdentifier("SettingsNavigationControllerID") as? UINavigationController {
            self.presentViewController(settingsNavC, animated: true, completion: nil)
        }
    }
    
    func navigationViewShowFriends(navigationView: PleekNavigationView) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchFriendsVC = storyboard.instantiateViewControllerWithIdentifier("SearchFriendsViewControllerID") as? SearchFriendsViewController {
            searchFriendsVC.delegate = self
            
            if firstUserUnlock != nil {
                searchFriendsVC.firstUserUnlock = firstUserUnlock!
                firstUserUnlock = nil
            }
            self.navigationController?.pushViewController(searchFriendsVC, animated: true)
        }
    }
    
    func navigationViewDidSelectLogo(navigationView: PleekNavigationView) {
        self.showVideo()
    }
    
    // MARK: PleekTableViewDelegate
    
    func scrollViewDidScrollToTop() {
        self.navigationView.openView()
    }
    
    func searchBegin() {
        self.hideNewPleekButton()
        self.navigationView.hideView()
    }
    
    func searchEnd() {
        self.popNewPleekButton()
        self.navigationView.unHideView()
    }
    
    func shouldRefresh() {
        self.receivedPleeksTableViewController.refreshPleek()
        self.sentPleeksTableViewController.refreshPleek()
        self.bestPleekCollectionViewController.refreshPleek()
    }
    
    func newContent(controller: UIViewController) {
        
        if controller == self.receivedPleeksTableViewController {
            self.navigationView.newContent(atIndex: 0)
        } else if controller == self.sentPleeksTableViewController {
            self.navigationView.newContent(atIndex: 1)
        } else if controller == self.bestPleekCollectionViewController {
            self.navigationView.newContent(atIndex: 5)
        }
    }

    // MARK: Action
    
    func showPleek(pleek: Pleek) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pleekVC = storyboard.instantiateViewControllerWithIdentifier("PleekViewController") as? PleekViewController {
            pleekVC.from = "Notification"
            pleekVC.mainPiki = pleek
            self.navigationController?.pushViewController(pleekVC, animated: true)
        }
    }
    
    func newPleekAction(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newPleek = storyboard.instantiateViewControllerWithIdentifier("TakePhotoNavControllerID") as? UIViewController {
            self.presentViewController(newPleek, animated: true, completion: nil)
        }
    }
    
    // MARK : Old
    
    func showTutoOverlay() {
        
        if overlayTutoView == nil{
            
            overlayTutoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayTutoView!.backgroundColor = UIColor.clearColor()
            
            let gestureTapLeaveOverlay:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leaveOverlayTuto"))
            overlayTutoView!.addGestureRecognizer(gestureTapLeaveOverlay)
            
            
            let statusOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
            statusOverlay.backgroundColor = UIColor.blackColor()
            statusOverlay.alpha = 0.7
            overlayTutoView!.addSubview(statusOverlay)
            
            
            
            let topBarOverlay:UIView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width - 85, height: 60))
            topBarOverlay.backgroundColor = UIColor.blackColor()
            topBarOverlay.alpha = 0.7
            overlayTutoView!.addSubview(topBarOverlay)
            
            
            let firstPeekeeOverlay:UIView = UIView(frame: CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: self.view.frame.size.width/3))
            firstPeekeeOverlay.backgroundColor = UIColor.blackColor()
            firstPeekeeOverlay.alpha = 0.7
            overlayTutoView!.addSubview(firstPeekeeOverlay)
            
            let restOverlay = UIView(frame: CGRect(x: 0, y: 80 + 2 * (self.view.frame.size.width/3), width: self.view.frame.size.width, height: self.view.frame.height - (80 + 2 * (self.view.frame.size.width/3))))
            restOverlay.backgroundColor = UIColor.blackColor()
            restOverlay.alpha = 0.7
            overlayTutoView!.addSubview(restOverlay)
            
            let lineFriends:UIImageView = UIImageView(frame: CGRect(x: self.view.frame.width - 40 - 42, y: 76, width: 42, height: 47))
            lineFriends.image = UIImage(named: "menu_line_friends")
            overlayTutoView!.addSubview(lineFriends)
            
            let linePeekee = UIImageView(frame: CGRect(x: self.view.frame.size.width/6, y: restOverlay.frame.origin.y - 4, width: 47, height: 42))
            linePeekee.image = UIImage(named: "menu_line_peekee")
            overlayTutoView!.addSubview(linePeekee)
            
            let labelTutoFriends = UILabel(frame: CGRect(x: 10, y: 95, width: self.view.frame.width - 40 - 42 - 10 - 30, height: 43))
            labelTutoFriends.numberOfLines = 2
            labelTutoFriends.adjustsFontSizeToFitWidth = true
            labelTutoFriends.font = UIFont(name: Utils().customGothamBol, size: 24.0)
            labelTutoFriends.textColor = UIColor.whiteColor()
            labelTutoFriends.text = NSLocalizedString("Find more friends to get more Pleeks", comment : "Find more friends to get more Pleeks")
            overlayTutoView!.addSubview(labelTutoFriends)
            
            let labelTutoPeekee = UILabel(frame: CGRect(x: linePeekee.frame.origin.x + linePeekee.frame.width + 5, y: linePeekee.frame.origin.y + 30, width: self.view.frame.width - (linePeekee.frame.origin.x + linePeekee.frame.width + 5), height: 22))
            labelTutoPeekee.numberOfLines = 1
            labelTutoPeekee.font = UIFont(name: Utils().customGothamBol, size: 24.0)
            labelTutoPeekee.textColor = UIColor.whiteColor()
            labelTutoPeekee.adjustsFontSizeToFitWidth = true
            labelTutoPeekee.text = NSLocalizedString("This is a PLEEK 🍩", comment : "This is a PLEEK 🍩")
            overlayTutoView!.addSubview(labelTutoPeekee)
            
            let labelSplash = UILabel(frame: CGRect(x: labelTutoFriends.frame.origin.x + labelTutoFriends.frame.width - 10, y: labelTutoFriends.center.y - 10, width: 30, height: 30))
            labelSplash.text = "💥"
            labelSplash.font = UIFont(name: Utils().customGothamBol, size: 30.0)
            overlayTutoView!.addSubview(labelSplash)
            
            self.view.addSubview(overlayTutoView!)
        }
        
        User.currentUser()!["hasShownOverlayMenu"] = true
        User.currentUser()!.saveInBackgroundWithBlock { (finished, error) -> Void in
            User.currentUser()!.fetchInBackgroundWithBlock({ (user, error) -> Void in
                println("UPDATE USER")
            })
        }
        
    }
    
    func showVideo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tutoVideoViewController = storyboard.instantiateViewControllerWithIdentifier("TutoVideoViewControllerID") as? TutoVideoViewController {
            if showTutoFirst {
                self.showTutoFirst = false
                tutoVideoViewController.firstTimePlay = true
            }
            self.presentViewController(tutoVideoViewController, animated: true, completion: nil)
        }
    }
    
    func askShowTutoVideo() {
        
        if overlayView == nil {
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUpTuto"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
        }
        
        if popUpShowTuto == nil {
            
            
            
            popUpShowTuto = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 284))
            popUpShowTuto!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpShowTuto!.center = self.view.center
            popUpShowTuto!.layer.cornerRadius = 5
            popUpShowTuto!.clipsToBounds = true
            self.view.addSubview(popUpShowTuto!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpShowTuto!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpShowTuto!.addSubview(header)
            
            let labelBigTime:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelBigTime.textAlignment = NSTextAlignment.Center
            labelBigTime.font = UIFont(name: Utils().customFontSemiBold, size: 22)
            labelBigTime.textColor = UIColor.whiteColor()
            labelBigTime.text = NSLocalizedString("SOME HELP?!", comment : "SOME HELP?!")
            labelBigTime.tag = 12
            header.addSubview(labelBigTime)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 226, width: popUpShowTuto!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpShowTuto!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpShowTuto!.frame.width/2, y: 226, width: 1, height: popUpShowTuto!.frame.height - 226))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpShowTuto!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUpTuto"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 226, width: popUpShowTuto!.frame.width/2, height: popUpShowTuto!.frame.height - 226))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpShowTuto!.addSubview(quitImageView)
            
            let unlockFriendsIcon:UIImageView = UIImageView(frame: CGRect(x: 0, y: 78, width: popUpShowTuto!.frame.width, height: 34))
            unlockFriendsIcon.contentMode = UIViewContentMode.Center
            unlockFriendsIcon.image = UIImage(named: "unlock_friends_icon")
            //popUpShowTuto!.addSubview(unlockFriendsIcon)
            
            let tvLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 78, width: popUpShowTuto!.frame.width, height: 40))
            tvLabel.font = UIFont(name: Utils().customFontSemiBold, size: 45)
            tvLabel.textAlignment = NSTextAlignment.Center
            tvLabel.text = "📺"
            popUpShowTuto!.addSubview(tvLabel)
            
            
            let validateAction:UIButton = UIButton(frame: CGRect(x: popUpShowTuto!.frame.width/2, y: 226, width: popUpShowTuto!.frame.width/2, height: popUpShowTuto!.frame.height - 226))
            validateAction.addTarget(self, action: Selector("leavePopUpTutoShowVideo"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            popUpShowTuto!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 136, width: popUpShowTuto!.frame.width - 36, height: 70))
            labelPopUp.numberOfLines = 3
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Do you want to watch a simple video to understand Pleek?", comment : "Look at this 10 sec' video to get the PLEEK concept?")
            popUpShowTuto!.addSubview(labelPopUp)
            
            
        }
        
        self.overlayView!.hidden = false
        self.popUpShowTuto!.transform =  CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.5
                self.popUpShowTuto!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    func leaveOverlayTuto(){
        overlayTutoView!.removeFromSuperview()
    }
    
    func leavePopUpTuto(){
        
        UIView.animateWithDuration(0.1,
            animations: { () -> Void in
                self.overlayView!.alpha = 0
                self.popUpShowTuto!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                
                
            }) { (finished) -> Void in
                self.popUpShowTuto!.transform =  CGAffineTransformMakeScale(0, 0)
                self.popUpShowTuto!.removeFromSuperview()
                self.popUpShowTuto = nil
                self.overlayView!.removeFromSuperview()
                self.overlayView = nil
        }
        
    }
    
    
    func leavePopUpTutoShowVideo(){
        
        UIView.animateWithDuration(0.1,
            animations: { () -> Void in
                self.overlayView!.alpha = 0
                self.popUpShowTuto!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                
                
            }) { (finished) -> Void in
                self.popUpShowTuto!.transform =  CGAffineTransformMakeScale(0, 0)
                self.popUpShowTuto!.removeFromSuperview()
                self.popUpShowTuto = nil
                self.overlayView!.removeFromSuperview()
                self.overlayView = nil
                
                self.showVideo()
                
        }
        
    }

    
    func getInLoopNotif(){
        
        if overlayView == nil {
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
        }
        
        if popUpLoopNotif == nil {
            
            popUpLoopNotif = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 346))
            popUpLoopNotif!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpLoopNotif!.center = self.view.center
            popUpLoopNotif!.layer.cornerRadius = 5
            popUpLoopNotif!.clipsToBounds = true
            self.view.addSubview(popUpLoopNotif!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpLoopNotif!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpLoopNotif!.addSubview(header)
            
            let labelBigTime:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelBigTime.textAlignment = NSTextAlignment.Center
            labelBigTime.font = UIFont(name: Utils().customFontSemiBold, size: 22)
            labelBigTime.textColor = UIColor.whiteColor()
            labelBigTime.text = NSLocalizedString("GET IN THE LOOP", comment : "GET IN THE LOOP")
            labelBigTime.tag = 12
            header.addSubview(labelBigTime)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 287, width: popUpLoopNotif!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpLoopNotif!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpLoopNotif!.frame.width/2, y: 287, width: 1, height: popUpLoopNotif!.frame.height - 287))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpLoopNotif!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 287, width: popUpLoopNotif!.frame.width/2, height: popUpLoopNotif!.frame.height - 287))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpLoopNotif!.addSubview(quitImageView)
            
            let unlockNotifs:UIImageView = UIImageView(frame: CGRect(x: 0, y: 78, width: popUpLoopNotif!.frame.width, height: 60))
            unlockNotifs.contentMode = UIViewContentMode.Center
            unlockNotifs.image = UIImage(named: "notif_popup_icon")
            popUpLoopNotif!.addSubview(unlockNotifs)
            
            
            let validateAction:UIButton = UIButton(frame: CGRect(x: popUpLoopNotif!.frame.width/2, y: 287, width: popUpLoopNotif!.frame.width/2, height: popUpLoopNotif!.frame.height - 287))
            validateAction.addTarget(self, action: Selector("validateNotifications"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            popUpLoopNotif!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 167, width: popUpLoopNotif!.frame.width - 36, height: 90))
            labelPopUp.numberOfLines = 3
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Don't miss the next pictures from your friends 😁", comment : "Don't miss the next pictures from your friends 😁")
            popUpLoopNotif!.addSubview(labelPopUp)
            
            
        }
        
        self.overlayView!.hidden = false
        self.popUpLoopNotif!.transform =  CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.5
                self.popUpLoopNotif!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    // MARK: SearchFriendsProtocol
    
    func leaveSearchFriends() {
        
        if !Utils().hasEverViewInLoop(){
            self.getInLoopNotif()
            Utils().viewInLoop()
        }
        
    }
    
    func leavePopUp(){
        leavePopUp(true)
    }
    
    func leavePopUp(showingNextScreen : Bool){
        
        if self.popUpUnlockFriends != nil{
            
            if showingNextScreen {
                self.firstUserUnlock = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let searchFriendsVC = storyboard.instantiateViewControllerWithIdentifier("SearchFriendsViewControllerID") as? SearchFriendsViewController {
                    searchFriendsVC.delegate = self
                    
                    if firstUserUnlock != nil {
                        searchFriendsVC.firstUserUnlock = firstUserUnlock!
                        firstUserUnlock = nil
                    }
                    self.navigationController?.pushViewController(searchFriendsVC, animated: true)
                }
            }
            
            
            UIView.animateWithDuration(0.1,
                animations: { () -> Void in
                    self.overlayView!.alpha = 0
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    
                }) { (finished) -> Void in
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpUnlockFriends!.removeFromSuperview()
                        self.popUpUnlockFriends = nil
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpLoopNotif!.removeFromSuperview()
                        self.popUpLoopNotif = nil
                    }
                    self.overlayView!.removeFromSuperview()
                    self.overlayView = nil
                    
                    
                    
            }
        }
        else{
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    self.overlayView!.alpha = 0
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    
                }) { (finished) -> Void in
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpUnlockFriends!.removeFromSuperview()
                        self.popUpUnlockFriends = nil
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpLoopNotif!.removeFromSuperview()
                        self.popUpLoopNotif = nil
                    }
                    self.overlayView!.removeFromSuperview()
                    self.overlayView = nil
                    
                    
                    
            }
        }
        
        
    }
    
    func unlockFriendsPopUp(){
        
        if overlayView == nil {
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
        }
        
        if popUpUnlockFriends == nil {
            
            
            
            popUpUnlockFriends = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 284))
            popUpUnlockFriends!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpUnlockFriends!.center = self.view.center
            popUpUnlockFriends!.layer.cornerRadius = 5
            popUpUnlockFriends!.clipsToBounds = true
            self.view.addSubview(popUpUnlockFriends!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpUnlockFriends!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpUnlockFriends!.addSubview(header)
            
            let labelBigTime:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelBigTime.textAlignment = NSTextAlignment.Center
            labelBigTime.font = UIFont(name: Utils().customFontSemiBold, size: 22)
            labelBigTime.textColor = UIColor.whiteColor()
            labelBigTime.text = NSLocalizedString("BIG TIME!", comment : "BIG TIME!")
            labelBigTime.tag = 12
            header.addSubview(labelBigTime)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 226, width: popUpUnlockFriends!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpUnlockFriends!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpUnlockFriends!.frame.width/2, y: 226, width: 1, height: popUpUnlockFriends!.frame.height - 226))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpUnlockFriends!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 226, width: popUpUnlockFriends!.frame.width/2, height: popUpUnlockFriends!.frame.height - 226))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpUnlockFriends!.addSubview(quitImageView)
            
            let unlockFriendsIcon:UIImageView = UIImageView(frame: CGRect(x: 0, y: 78, width: popUpUnlockFriends!.frame.width, height: 34))
            unlockFriendsIcon.contentMode = UIViewContentMode.Center
            unlockFriendsIcon.image = UIImage(named: "unlock_friends_icon")
            popUpUnlockFriends!.addSubview(unlockFriendsIcon)
            
            
            let validateAction:UIButton = UIButton(frame: CGRect(x: popUpUnlockFriends!.frame.width/2, y: 226, width: popUpUnlockFriends!.frame.width/2, height: popUpUnlockFriends!.frame.height - 226))
            validateAction.addTarget(self, action: Selector("validateUnlockFriends"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            popUpUnlockFriends!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 136, width: popUpUnlockFriends!.frame.width - 36, height: 61))
            labelPopUp.numberOfLines = 2
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Let's find your friends on the app! 🙇", comment : "Let's find your friends on the app! 🙇")
            popUpUnlockFriends!.addSubview(labelPopUp)
            
            
        }
        
        self.overlayView!.hidden = false
        self.popUpUnlockFriends!.transform =  CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.5
                self.popUpUnlockFriends!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    func showFriend() {
        if !Utils().hasEverViewUnlockFriend(){
            self.unlockFriendsPopUp()
            Utils().viewUnlockFriend()
        }
    }
    
    func validateUnlockFriends(){
        
        leavePopUp(false)
        self.firstUserUnlock = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let searchFriendsVC = storyboard.instantiateViewControllerWithIdentifier("SearchFriendsViewControllerID") as? SearchFriendsViewController {
            searchFriendsVC.delegate = self
            
            if firstUserUnlock != nil {
                searchFriendsVC.firstUserUnlock = firstUserUnlock!
                firstUserUnlock = nil
            }
            self.navigationController?.pushViewController(searchFriendsVC, animated: true)
        }
       
    }
    
    func validateNotifications(){
        
        self.leavePopUp(false)
        //Ask For Notif
        if User.currentUser() != nil{
            //Notifications
            if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")){
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert |
                    UIUserNotificationType.Badge |
                    UIUserNotificationType.Sound, categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
            }
            else{
                UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound)
            }
        }
    }
}

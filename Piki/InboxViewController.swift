//
//  InboxViewController.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, PleekNavigationViewDelegate, PleekTableViewControllerDelegate, PleekCollectionViewDelegate {
    
    var bestPleeksProtocol: PleekCollectionViewProtocol = PleekCollectionViewProtocol()
    lazy var bestPleekRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshBestPleek"), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    } ()
    
    var receivedPleeksTableViewTrailingConstraint = Constraint()
    
    lazy var receivedPleeksTableViewController: PleekTableViewController = {
        let tableViewC = PleekTableViewController()
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
    
    lazy var bestPleekCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 7
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top:9, left: 9, bottom: 8, right: 9)

        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        collectionView.addSubview(self.bestPleekRefreshControl)
        collectionView.alwaysBounceVertical = true
        self.bestPleeksProtocol.delegate = self
        collectionView.dataSource = self.bestPleeksProtocol
        collectionView.delegate = self.bestPleeksProtocol
        self.bestPleeksProtocol.collectionView = collectionView
        collectionView.scrollsToTop = false

        
        collectionView.registerClass(BestCell.self, forCellWithReuseIdentifier: "BestCollectionViewCell")
        collectionView.registerClass(LoadMoreCollectionViewCell.self, forCellWithReuseIdentifier: "LoadMoreCollectionViewCellIdentifier")
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        collectionView.addGestureRecognizer(panGesture)
        
        self.view.addSubview(collectionView)
        
        collectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view)
            make.width.equalTo(self.view)
            make.leading.equalTo(self.sentPleeksTableViewController.view.snp_trailing)
        }
        
        return collectionView
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
        let best = self.bestPleekCollectionView
        let newPleekButton = self.newPleekButton
        
        self.view.bringSubviewToFront(self.navigationView)
        self.view.bringSubviewToFront(self.statusBarView)

        self.getBestPleek(true)
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
        self.bestPleekCollectionView.scrollsToTop = false
        
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
            self.bestPleekCollectionView.scrollsToTop = true
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
            self.navigationController?.pushViewController(searchFriendsVC, animated: true)
        }
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
    
    // MARK: PleekCollectionViewViewDelegate
    
    func pleekCollectionView(tableView: UICollectionView?, didSelectPleek pleek: Pleek, atIndexPath indexPath: NSIndexPath?) {
        self.showPleek(pleek)
    }
    
    func pleekCollectionViewLoadMore(pleekProtocol: PleekCollectionViewProtocol, collectionView: UICollectionView, toSkip: Int) {
        weak var weakSelf = self
        Pleek.getBestPleek(true, skip: toSkip) { (pleeks, error) -> Void in
            weakSelf?.pleekCollectionViewLoadMoreResult(pleekProtocol, collectionView: collectionView, pleeks: pleeks, error: error)
        }
    }
    
    func pleekCollectionViewLoadMoreResult(pleekProtocol: PleekCollectionViewProtocol, collectionView: UICollectionView, pleeks: [Pleek]?, error: NSError?) {
        if let error = error {
            println("Error : \(error.localizedDescription)")
        } else {
            pleekProtocol.updateCollectionView(collectionView, pleeks: pleeks!)
        }
        pleekProtocol.isLoadingMore = false
    }
    
    // MARK: Action
    
    func showPleek(pleek: Pleek) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pleekVC = storyboard.instantiateViewControllerWithIdentifier("PleekViewController") as? PleekViewController {
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
    
    func refreshBestPleek() {
        self.getBestPleek(false)
    }
    
    // MARK: Data
    
    func getBestPleek(withCache: Bool) {
        weak var weakSelf = self
        Pleek.getBestPleek(withCache, skip: 0, completed: { (pleeks, error) -> () in
            if error != nil {
                println("Error : \(error!.localizedDescription)")
            } else {
                if count(pleeks!) < Constants.LoadPleekLimit {
                    weakSelf?.bestPleeksProtocol.shouldLoadMore = false
                } else {
                    weakSelf?.bestPleeksProtocol.shouldLoadMore = true
                }
                weakSelf?.bestPleeksProtocol.pleeks = pleeks!
                weakSelf?.bestPleekRefreshControl.endRefreshing()
                weakSelf?.bestPleekCollectionView.reloadData()
            }
        })
    }
}

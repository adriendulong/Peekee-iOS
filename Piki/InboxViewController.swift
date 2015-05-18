//
//  InboxViewController.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, PleekNavigationViewDelegate, PleekTableViewDelegate {

    var receivedPleeksProtocol: PleekTableViewProtocol = PleekTableViewProtocol()
    var sentPleeksProtocol: PleekTableViewProtocol = PleekTableViewProtocol()
    
    var receivedPleeksTableViewTrailingConstraint = Constraint()
    
    lazy var receivedPleeksTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.receivedPleeksProtocol.delegate = self
        tableView.dataSource = self.receivedPleeksProtocol
        tableView.delegate = self.receivedPleeksProtocol
        self.receivedPleeksProtocol.tableView = tableView
        tableView.separatorStyle = .None
        tableView.scrollsToTop = true
        
        tableView.registerClass(InboxCell.self, forCellReuseIdentifier: "InboxTableViewCellIdentifier")
        tableView.registerClass(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreTableViewCellIdentifier")
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        tableView.addGestureRecognizer(panGesture)
        
        self.view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view.snp_bottom)
            make.width.equalTo(self.view.snp_width)
            self.receivedPleeksTableViewTrailingConstraint = make.trailing.equalTo(self.view.snp_trailing).offset(0).constraint
        }
        
        return tableView
    } ()
    
    lazy var sentPleeksTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.sentPleeksProtocol.delegate = self
        tableView.dataSource = self.sentPleeksProtocol
        tableView.delegate = self.sentPleeksProtocol
        self.sentPleeksProtocol.tableView = tableView
        tableView.separatorStyle = .None
        tableView.scrollsToTop = false
        
        tableView.registerClass(InboxCell.self, forCellReuseIdentifier: "InboxTableViewCellIdentifier")
        tableView.registerClass(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreTableViewCellIdentifier")
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        tableView.addGestureRecognizer(panGesture)
        
        self.view.addSubview(tableView)
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view.snp_bottom)
            make.width.equalTo(self.view.snp_width)
            make.leading.equalTo(self.receivedPleeksTableView.snp_trailing)
        }
        
        return tableView
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
        
        let received = self.receivedPleeksTableView
        let sent = self.sentPleeksTableView
        let navigationView = self.navigationView
        let statusBar = self.statusBarView
        let newPleekButton = self.newPleekButton
    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        weak var weakSelf = self
        User.currentUser()!.getReceivedPleeks(true, skip: 0, completed: { (pleeks, error) -> () in
            if error != nil {
                println("Error : \(error!.localizedDescription)")
            } else {
                if count(pleeks!) < Constants.LoadPleekLimit {
                    weakSelf?.receivedPleeksProtocol.shouldLoadMore = false
                } else {
                    weakSelf?.receivedPleeksProtocol.shouldLoadMore = true
                }
                weakSelf?.receivedPleeksProtocol.pleeks = pleeks!
                weakSelf?.receivedPleeksTableView.reloadData()
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("popNewPleekButton"), userInfo: nil, repeats: false)
            }
        })
        
        User.currentUser()!.getSentPleeks(true, skip: 0, completed: { (pleeks, error) -> () in
            if error != nil {
                println("Error : \(error!.localizedDescription)")
            } else {
                if count(pleeks!) < Constants.LoadPleekLimit {
                    weakSelf?.sentPleeksProtocol.shouldLoadMore = false
                } else {
                    weakSelf?.sentPleeksProtocol.shouldLoadMore = true
                }
                weakSelf?.sentPleeksProtocol.pleeks = pleeks!
                weakSelf?.sentPleeksTableView.reloadData()
            }
        })
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
        self.newPleekButtonBottomConstraint.updateOffset(-20)
        self.newPleekButton.setNeedsLayout()
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10.0, options: nil, animations: { () -> Void in
            self.newPleekButton.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: PleekNavigationViewDelegate
    
    func navigationView(navigationView: PleekNavigationView, didSelectTabAtIndex index: UInt) {
        self.receivedPleeksTableView.scrollsToTop = false
        self.sentPleeksTableView.scrollsToTop = false
        
        if index == 0 {
            self.receivedPleeksTableViewTrailingConstraint.updateOffset(0)
            self.receivedPleeksTableView.scrollsToTop = true
        } else if index == 1 {
            self.receivedPleeksTableViewTrailingConstraint.updateOffset(-CGRectGetWidth(self.view.frame))
            self.sentPleeksTableView.scrollsToTop = true
        }
        
        self.view.setNeedsLayout()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
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
    
    // MARK: PleekTableViewDelegate
    
    func pleekTableView(tableView: UITableView, didSelectPleek pleek: Pleek, atIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pleekVC: PleekViewController = storyboard.instantiateViewControllerWithIdentifier("PleekViewController") as! PleekViewController
        pleekVC.mainPiki = pleek
        self.navigationController?.pushViewController(pleekVC, animated: true)
    }
    
    func pleekTableViewLoadMore(pleekProtocol: PleekTableViewProtocol, tableView: UITableView, toSkip: Int) {
        if tableView == self.receivedPleeksTableView {
            User.currentUser()!.getReceivedPleeks(true, skip: toSkip, completed: { (pleeks, error) -> () in
                self.pleekTableViewLoadMoreResult(pleekProtocol, tableView: tableView, pleeks: pleeks, error: error)
            })
        } else if tableView == self.sentPleeksTableView {
            User.currentUser()!.getSentPleeks(true, skip: toSkip, completed: { (pleeks, error) -> () in
                self.pleekTableViewLoadMoreResult(pleekProtocol, tableView: tableView, pleeks: pleeks, error: error)
            })
        }
    }
    
    func pleekTableViewLoadMoreResult(pleekProtocol: PleekTableViewProtocol, tableView: UITableView, pleeks: [Pleek]?, error: NSError?) {
        if let error = error {
            println("Error : \(error.localizedDescription)")
        } else {
            pleekProtocol.updateTableView(tableView, pleeks: pleeks!)
        }
        pleekProtocol.isLoadingMore = false
    }
    
    func scrollViewDidScrollToTop() {
        self.navigationView.openView()
    }
    
    // MARK: Action
    
    func newPleekAction(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newPleek = storyboard.instantiateViewControllerWithIdentifier("TakePhotoNavControllerID") as! UIViewController

        self.presentViewController(newPleek, animated: true, completion: nil)
    }
}

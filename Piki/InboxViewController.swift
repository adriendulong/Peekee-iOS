//
//  InboxViewController.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, PleekNavigationViewDelegate, UITableViewDataSource, UITableViewDelegate {

    var pleeks: [Pleek] = []
    var tableView = UITableView()
    var navigationView: PleekNavigationView = PleekNavigationView()
    var navigationViewTopConstraint = Constraint()
    var statusBarView = UIView()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(InboxCell.self, forCellReuseIdentifier: "InboxTableViewCellIdentifier")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.navigationView)
        self.view.addSubview(self.statusBarView)
        
        let panGesture = UIPanGestureRecognizer(target: self.navigationView, action: Selector("handlePan:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self.navigationView
        self.tableView.addGestureRecognizer(panGesture)
        
        self.navigationView.delegate = self
        
        self.setNeedsStatusBarAppearanceUpdate()

        self.tableView.reloadData()
        
        self.statusBarView.backgroundColor = UIColor(red: 31.0/255.0, green: 41.0/255.0, blue: 103.0/255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true

        self.navigationView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            self.navigationViewTopConstraint = make.top.equalTo(self.view.snp_top).offset(20).constraint
            make.height.equalTo(100)
        }
        
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.navigationView.snp_bottom)
            make.bottom.equalTo(self.view.snp_bottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
        }
        
        self.statusBarView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.top.equalTo(self.view.snp_top)
            make.height.equalTo(20)
        }
        
        weak var weakSelf = self
        User.currentUser()!.getPleeks(true, completed: { (pleeks, error) -> () in
            if error != nil {
                println("Error : \(error!.localizedDescription)")
            }
            else {
                weakSelf?.pleeks = pleeks!
                weakSelf?.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(self.pleeks)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxTableViewCellIdentifier", forIndexPath: indexPath) as! InboxCell
        cell.configureFor(self.pleeks[indexPath.row])
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var pleekVC: PleekViewController = storyboard.instantiateViewControllerWithIdentifier("PleekViewController") as! PleekViewController
        pleekVC.mainPiki = self.pleeks[indexPath.row]
        
        self.navigationController?.pushViewController(pleekVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let pleek = self.pleeks[indexPath.row]
        
        if pleek.nbReaction > 0 {
            return CGRectGetWidth(self.view.frame) / 3.0 * 2.0 + 114.0
        } else {
            return CGRectGetWidth(self.view.frame) / 3.0 * 2.0 + 56.0
        }
    }
    
    // MARK: Appearance
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: PleekNavigationViewDelegate
    
    func navigationView(navigationView: PleekNavigationView, didSelectTabAtIndex index: UInt) {
        
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
}

//
//  InboxViewController.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pleeks: [Pleek] = []
    var tableView = UITableView()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        self.tableView.registerClass(InboxCell.self, forCellReuseIdentifier: "InboxTableViewCellIdentifier")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.view.addSubview(self.tableView)
        
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.snp_top)
            make.bottom.equalTo(self.view.snp_bottom)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
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
        
        self.navigationController?.navigationBarHidden = true
        
        self.tableView.reloadData()
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
    
    // MARK: Navigation

}

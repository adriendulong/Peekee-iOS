//
//  InboxViewController.swift
//  POCInbox
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pleeks: [PFObject] = []
    var tableView = UITableView()
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = self.view.frame
        self.tableView.registerClass(InboxCell.self, forCellReuseIdentifier: "InboxTableViewCellIdentifier")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.view.addSubview(self.tableView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.rowHeight = CGRectGetWidth(self.view.frame) / 3.0 * 2.0 + 114.0
        
        self.getPikis(false)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(pleeks)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxTableViewCellIdentifier", forIndexPath: indexPath) as! InboxCell
        cell.setupView()
        cell.configureFor(pleeks[indexPath.row])
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let heigth = CGRectGetWidth(self.view.frame) / 3.0 * 2.0 + 114.0
        return heigth
    }
    
    func getPikis(withCache: Bool){
        
        //Get the list of friends : to get the pleek from them
        var friendsObjects:Array<PFUser> = Array<PFUser>()
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            if task.error == nil{
                friendsObjects = Utils().getListOfUserObjectFromJoinObject(task.result as! Array<PFObject>)
            }
            
            friendsObjects.append(PFUser(withoutDataWithObjectId: PFUser.currentUser()!.objectId))
            
            //Get the pleek of the friends list
            var requestPiki:PFQuery = PFQuery(className: "Piki")
            requestPiki.orderByDescending("lastUpdate")
            requestPiki.includeKey("user")
            requestPiki.whereKey("user", containedIn: friendsObjects)
            requestPiki.whereKey("objectId", notContainedIn: Utils().getHidesPleek())
            
            if withCache{
                requestPiki.cachePolicy = PFCachePolicy.CacheThenNetwork
            }
            else{
                requestPiki.cachePolicy = PFCachePolicy.NetworkElseCache
            }
            
            
            requestPiki.limit = 30
            
            requestPiki.findObjectsInBackgroundWithBlock { (pikis : [AnyObject]?, error : NSError?) -> Void in
                if error != nil{
                    println("Error : \(error!.localizedDescription)")
                    
                }
                else{
                    self.pleeks = pikis as! [PFObject]
                    self.tableView.reloadData()
                    
                }
            }
            
            return nil
        }
    }
}

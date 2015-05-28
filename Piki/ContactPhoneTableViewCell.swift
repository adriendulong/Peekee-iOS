//
//  ContactPhoneTableViewCell.swift
//  Peekee
//
//  Created by Kevin CATHALY on 05/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

class ContactPhoneTableViewCell : UITableViewCell {
    
    var nameContactLabel: UILabel!
    var usernameLabel: UILabel!
    var searchController:SearchFriendsViewController?
    var contact:APContact?
    var userInfos:[String : String]?
    var loadIndicator:UIActivityIndicatorView?
    var actionButton:UIButton?
    var moreInfosLabel:UILabel?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.Theme.CellHighlightColor
        self.selectedBackgroundView = bgColorView
        
        var separatorView = UIView()
        separatorView.backgroundColor = UIColor.Theme.CellSeparatorColor
        self.contentView.addSubview(separatorView)
        
        separatorView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.height.equalTo(Dimensions.CellSeparatorHeight)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
    }
    
    func loadContact(contact : APContact, searchController : SearchFriendsViewController){
        
        self.searchController = searchController
        self.contact = contact
        
        if actionButton == nil {
            actionButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 110, y: 0, width: 100, height: 60))
            actionButton!.addTarget(self, action: Selector("inviteContact:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionButton!)
        }
        
        
        actionButton!.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 110, y: 0, width: 100, height: 60)
        actionButton!.setImage(UIImage(named: "sms_invit_gif"), forState: UIControlState.Normal)
        
        self.backgroundColor = UIColor.whiteColor()
        
        if nameContactLabel == nil {
            nameContactLabel = UILabel(frame: CGRect(x: 15, y: 0, width: UIScreen.mainScreen().bounds.width - 125, height: 60))
            nameContactLabel.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            nameContactLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            nameContactLabel.adjustsFontSizeToFitWidth = true
            self.addSubview(nameContactLabel)
        }
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = actionButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if moreInfosLabel != nil{
            moreInfosLabel!.hidden = true
        }
        
        nameContactLabel.text = contact.compositeName
        
        /*if let phones = contact.phones {
        let array = phones as NSArray
        usernameLabel.text = array.componentsJoinedByString(" ")
        }*/
        
        if userInfos != nil {
            
            actionButton!.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 55, y: 0, width: 45, height: 60)
            actionButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
            
            if contains(Utils().getAppDelegate().friendsIdList, userInfos!["userObjectId"]! as String){
                actionButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            }
        }
        else{
            actionButton!.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 110, y: 0, width: 100, height: 60)
            actionButton!.setImage(UIImage(named: "sms_invit_gif"), forState: UIControlState.Normal)
        }
        
    }
    
    func loadUserContact(contactUserInfo : [String : AnyObject], searchController : SearchFriendsViewController){
        self.searchController = searchController
        self.contact = contactUserInfo["contact"] as? APContact
        
        if actionButton == nil {
            actionButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 55, y: 0, width: 45, height: 60))
            actionButton!.addTarget(self, action: Selector("inviteContact:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionButton!)
        }
        
        actionButton!.frame = CGRect(x: UIScreen.mainScreen().bounds.width - 55, y: 0, width: 45, height: 60)
        actionButton!.setImage(UIImage(named: "sms_invit_gif"), forState: UIControlState.Normal)
        
        self.backgroundColor = UIColor.whiteColor()
        
        if nameContactLabel == nil {
            nameContactLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            nameContactLabel.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            nameContactLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(nameContactLabel)
            
        }
        
        if moreInfosLabel == nil{
            moreInfosLabel = UILabel(frame: CGRect(x: 15, y: 40, width: 300, height: 20))
            moreInfosLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 14.0)
            moreInfosLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
            self.addSubview(moreInfosLabel!)
            
        }
        
        moreInfosLabel!.hidden = false
        
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = actionButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        
        nameContactLabel.text = contact!.compositeName
        
        
        userInfos =  contactUserInfo["userInfos"] as? [String : String]
        /*if let phones = contact.phones {
        let array = phones as NSArray
        usernameLabel.text = array.componentsJoinedByString(" ")
        }*/
        
        if userInfos != nil {
            var username:String? = userInfos!["username"]
            moreInfosLabel!.text = "@\(username!)"
            
            actionButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
            
            if contains(Utils().getAppDelegate().friendsIdList, userInfos!["userObjectId"]! as String){
                actionButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            }
        }
        else{
            actionButton!.setImage(UIImage(named: "sms_invit_gif"), forState: UIControlState.Normal)
        }
    }
    
    /*@IBAction func inviteContact(sender: AnyObject) {
    
    self.searchController!.sendSMSToContacts([self.contact!])
    
    }*/
    
    func inviteContact(button : UIButton){
        
        if userInfos != nil{
            
            
            if !contains(Utils().getAppDelegate().friendsIdList, userInfos!["userObjectId"]! as String){
                
                loadIndicator!.startAnimating()
                
                
                Utils().addFriend(userInfos!["userObjectId"]!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                    self.loadIndicator!.stopAnimating()
                    if task.error != nil {
                        
                    }
                    else{
                        Mixpanel.sharedInstance().track("Add Friend", properties : ["screen" : "search_friend"])
                        
                        self.searchController!.getAllUsersFromContacts()
                        self.searchController!.addUserInFriendsList(task.result as! User)
                        self.searchController!.sortFriends()
                        self.searchController!.tableView.reloadData()
                        
                        
                        self.searchController!.friendsSelectorLabel!.text = "\(self.searchController!.getNumberOfFriends())"
                        UIView.animateWithDuration(0.2,
                            animations: { () -> Void in
                                self.searchController!.friendsSelectorLabel!.textColor = Utils().secondColor
                                self.searchController!.friendsSelectorLabel!.transform = CGAffineTransformMakeScale(1.5, 1.5)
                            }, completion: { (finisehd) -> Void in
                                
                                UIView.animateWithDuration(0.2,
                                    animations: { () -> Void in
                                        self.searchController!.friendsSelectorLabel!.transform = CGAffineTransformIdentity
                                        self.searchController!.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                                })
                        })
                    }
                    
                    return nil
                })
            }
            
            
        }
        else{
            self.searchController!.sendSMSToContacts([self.contact!])
        }
        
    }
}

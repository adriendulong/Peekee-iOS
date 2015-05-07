//
//  PikiUserTableViewCell.swift
//  Peekee
//
//  Created by Kevin CATHALY on 05/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

class PikiUserTableViewCell : UITableViewCell {
    
    var usernameLabel: UILabel?
    var secondLabel: UILabel?
    var addUserButton: UIButton?
    var user:PFUser?
    var loadIndicator:UIActivityIndicatorView?
    var searchController:SearchFriendsViewController?
    
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
    
    func loadItem(user : PFUser, searchController : SearchFriendsViewController){
        
        self.searchController = searchController
        
        self.backgroundColor = UIColor.whiteColor()
        
        if usernameLabel == nil {
            usernameLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            usernameLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            usernameLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(usernameLabel!)
            
        }
        
        
        if user["name"] != nil{
            usernameLabel!.frame = CGRect(x: 15, y: 0, width: 300, height: 50)
            
            usernameLabel!.text = user["name"] as? String
            
            if secondLabel == nil{
                secondLabel = UILabel(frame: CGRect(x: 15, y: 30, width: 300, height: 30))
                secondLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 17.0)
                secondLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                self.addSubview(secondLabel!)
            }
            secondLabel!.hidden = false
            secondLabel!.text = "@\(user.username!)"
        }
        else{
            usernameLabel!.frame = CGRect(x: 15, y: 0, width: 300, height: 60)
            
            if secondLabel != nil{
                secondLabel!.hidden = true
            }
            
            usernameLabel!.text = "@\(user.username!)"
            
        }
        
        
        if addUserButton == nil {
            addUserButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            addUserButton!.addTarget(self, action: Selector("addUser:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(addUserButton!)
        }
        
        addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        addUserButton!.hidden = false
        
        self.user = user
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.center = addUserButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if Utils().isUserAFriend(user){
            addUserButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            
        }
        else{
            addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        }
    }
    
    
    func loadItemSearch(contactInfos : [String : AnyObject]){
        
        self.backgroundColor = UIColor.whiteColor()
        
        var username:String = contactInfos["username"] as! String
        var isSearching:Bool = contactInfos["searching"] as! Bool
        
        if usernameLabel == nil {
            usernameLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            usernameLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            usernameLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(usernameLabel!)
            
        }
        
        
        if addUserButton == nil {
            addUserButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            addUserButton!.addTarget(self, action: Selector("addUser:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(addUserButton!)
        }
        
        addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        
        addUserButton!.hidden = true
        
        
        //self.user = user
        if self.secondLabel != nil{
            self.secondLabel!.hidden = true
        }
        
        usernameLabel!.text = "@\(username)"
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.center = addUserButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if isSearching{
            loadIndicator!.startAnimating()
        }
        else{
            loadIndicator!.stopAnimating()
        }
    }
    
    
    func addUser(sender: UIButton) {
        
        loadIndicator!.startAnimating()
        self.addUserButton!.hidden = true
        
        if Utils().isUserAFriend(user!){
            
            
            Utils().removeFriend(self.user!.objectId!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.loadIndicator!.stopAnimating()
                if task.error != nil{
                    
                }
                else{
                    self.addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
                }
                
                self.addUserButton!.hidden = false
                
                return nil
            })
            
        }
        else{
            //Not a friend, friend him
            Utils().addFriend(self.user!.objectId!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.loadIndicator!.stopAnimating()
                if task.error != nil{
                    
                }
                else{
                    self.addUserButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
                    self.addUserButton!.hidden = false
                    
                    Mixpanel.sharedInstance().track("Add Friend", properties : ["screen" : "search_friend"])
                    self.searchController!.getAllUsersFromContacts()
                    self.searchController!.addUserInFriendsList(task.result as! PFUser)
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
    
}

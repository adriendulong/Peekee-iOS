//
//  MuteAllViewController.swift
//  Pleek
//
//  Created by Adrien Dulong on 02/03/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation


class MuteAllFriendsTableViewCell : UITableViewCell{
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var friend:PFUser?
    
    func loadCell(friend : PFUser){
        
        self.friend = friend
        self.muteButton.addTarget(self, action: Selector("muteSelect"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.usernameLabel.text = "@\(friend.username)"
        self.secondLabel.hidden = true
        
        if friend["name"] != nil{
            self.usernameLabel.text = friend["name"] as? String
            
            self.secondLabel.hidden = false
            self.secondLabel.text = "@\(friend.username)"
            
        }
        
        if Utils().isUserMuted(friend){
            self.usernameLabel.textColor = self.secondLabel.textColor
            muteButton.setImage(UIImage(named: "muted_icon"), forState: UIControlState.Normal)
        }
        else{
            self.usernameLabel.textColor = UIColor.blackColor()
            muteButton.setImage(UIImage(named: "new_mute_icon"), forState: UIControlState.Normal)
        }
    
    }
    
    
    /*@IBAction func muteAction(sender: AnyObject) {
        
        self.activityIndicator.startAnimating()
        self.muteButton.hidden = true
        
        if Utils().isUserMuted(self.friend!){
            
            // Unmute
            Utils().unMuteFriend(self.friend!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.activityIndicator.stopAnimating()
                self.muteButton.hidden = false
                if task.error != nil{
                    
                }
                else{
                    self.usernameLabel.textColor = UIColor.blackColor()
                    self.muteButton.setImage(UIImage(named: "new_mute_icon"), forState: UIControlState.Normal)
                }
                
                return nil
                
            })
            
            
        }
        else{
            
            Utils().muteFriend(self.friend!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.activityIndicator.stopAnimating()
                self.muteButton.hidden = false
                if task.error != nil{
                    
                }
                else{
                    self.usernameLabel.textColor = self.secondLabel.textColor
                    self.muteButton.setImage(UIImage(named: "muted_icon"), forState: UIControlState.Normal)
                }
                
                return nil
            })
            
           
        }
        
    }*/
    
    func muteSelect(){
        self.activityIndicator.startAnimating()
        self.muteButton.hidden = true
        
        if Utils().isUserMuted(self.friend!){
            
            // Unmute
            Utils().unMuteFriend(self.friend!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.activityIndicator.stopAnimating()
                self.muteButton.hidden = false
                if task.error != nil{
                    
                }
                else{
                    self.usernameLabel.textColor = UIColor.blackColor()
                    self.muteButton.setImage(UIImage(named: "new_mute_icon"), forState: UIControlState.Normal)
                }
                
                return nil
                
            })
            
            
        }
        else{
            
            Utils().muteFriend(self.friend!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.activityIndicator.stopAnimating()
                self.muteButton.hidden = false
                if task.error != nil{
                    
                }
                else{
                    self.usernameLabel.textColor = self.secondLabel.textColor
                    self.muteButton.setImage(UIImage(named: "muted_icon"), forState: UIControlState.Normal)
                }
                
                return nil
            })
            
            
        }
    }
}


class MuteAllViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var switchMute: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleSwitchLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var friends:Array<PFUser> = Array<PFUser>()
    var isLoadingMore:Bool = false
    
    
    override func viewDidLoad() {
        
        activityIndicator.startAnimating()
        switchMute.hidden = true
        switchMute.onTintColor = Utils().secondColor
        titleSwitchLabel.text = NSLocalizedString("Silent Mode Status", comment : "Silent Mode Status")
        descriptionLabel.text = NSLocalizedString("If you activate the silent mode all your contacts will be mute. And you won't receive their Pleeks anymore. Here you'll be able to unmute the friend you want to receive Pleek from.", comment : "If you activate the silent mode all your contacts will be mute. And you won't receive their Pleeks anymore. Here you'll be able to unmute the friend you want to receive Pleek from.")
        
        self.tableView.hidden = true
        
        // Update user
        PFUser.currentUser().fetchInBackgroundWithBlock { (user, error) -> Void in
            
            if PFUser.currentUser()["isMuteModeEnabled"] != nil{
                
                
                if (PFUser.currentUser()["isMuteModeEnabled"] as Bool){
                    
                    if PFUser.currentUser()["endMuteAllJob"] != nil{
                        // Is in activation
                        if !(PFUser.currentUser()["endMuteAllJob"] as Bool){
                            self.titleSwitchLabel.text = NSLocalizedString("Silent Mode Status (activating)", comment : "Silent Mode Status (activating)")
                        }
                        else{
                            self.activityIndicator.stopAnimating()
                            self.switchMute.on = true
                            self.switchMute.hidden = false
                            self.tableView.hidden = false
                            
                            self.getFriends()
                        }
                    }
                    else{
                        self.titleSwitchLabel.text = NSLocalizedString("Silent Mode Status (activating)", comment : "Silent Mode Status (activating)")
                    }

                }
                else{
                    
                    if PFUser.currentUser()["endunmuteAllJob"] != nil{
                        // Is in activation
                        if !(PFUser.currentUser()["endunmuteAllJob"] as Bool){
                            self.titleSwitchLabel.text = NSLocalizedString("Silent Mode Status (stopping)", comment : "Silent Mode Status (stopping)")
                        }
                        else{
                            self.activityIndicator.stopAnimating()
                            self.switchMute.on = false
                            self.switchMute.hidden = false
                            self.tableView.hidden = true
                        }
                    }
                    else{
                        self.titleSwitchLabel.text = NSLocalizedString("Silent Mode Status (stopping)", comment : "Silent Mode Status (stopping)")
                    }
                }
                
            }
            else{
                self.activityIndicator.stopAnimating()
                self.switchMute.on = false
                self.switchMute.hidden = false
                self.tableView.hidden = true
            }
            

        }
        
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func quit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        if switchMute.on{
            
            switchMute.hidden = true
            activityIndicator.startAnimating()
            
            //MuteAll
            PFCloud.callFunctionInBackground("callMuteAll", withParameters: ["test": "rien"], block: { (result, error) -> Void in
                if error != nil{
                    
                    self.switchMute.on = false
                    self.switchMute.hidden = false
                    self.activityIndicator.stopAnimating()
                    
                    //Alert user we had a problem
                    let alert = UIAlertView(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("We had a problem activating the silent mode. Please try again later", comment : "We had a problem activating the silent mode. Please try again later"),
                        delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
                else{
                    
                    PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                        
                        PFUser.currentUser()["isMuteModeEnabled"] = true
                        PFUser.currentUser().saveInBackgroundWithBlock({ (succedded, error) -> Void in
                            self.titleSwitchLabel.text = NSLocalizedString("Silent Mode Status (activating)", comment : "Silent Mode Status (activating)")
                            
                            // Alert User it can take a while, he will receive a notification when the operation is completed
                            let alert = UIAlertView(title: NSLocalizedString("In Progress", comment : "In Progress"), message: NSLocalizedString("The silent mode is being activated. It can take a while. You'll receive a notification when the activation will be completed.", comment : "The silent mode is being activated. It can take a while. You'll receive a notification when the activation will be completed."),
                                delegate: nil, cancelButtonTitle: "Ok")
                            alert.show()
                        })
                        
                        
                    })
                    
                }
            })
            
        }
        else{
            //Unmute All
            switchMute.hidden = true
            activityIndicator.startAnimating()
            
            //MuteAll
            PFCloud.callFunctionInBackground("callunmuteAll", withParameters: ["test": "rien"], block: { (result, error) -> Void in
                if error != nil{
                    
                    self.switchMute.on = true
                    self.switchMute.hidden = false
                    self.activityIndicator.stopAnimating()
                    
                    //Alert user we had a problem
                    let alert = UIAlertView(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("We had a problem stopping the silent mode. Please try again later", comment : "We had a problem stopping the silent mode. Please try again later"),
                        delegate: nil, cancelButtonTitle: "Ok")
                    alert.show()
                }
                else{
                    
                    PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                        
                        self.tableView.hidden = true
                        
                        PFUser.currentUser()["isMuteModeEnabled"] = false
                        PFUser.currentUser().saveInBackgroundWithBlock({ (succedded, error) -> Void in
                            self.titleSwitchLabel.text = NSLocalizedString("Silent Mode Status (stopping)", comment : "Silent Mode Status (stopping)")
                            
                            // Alert User it can take a while, he will receive a notification when the operation is completed
                            let alert = UIAlertView(title: NSLocalizedString("In Progress", comment : "In Progress"), message: NSLocalizedString("The silent mode is being stopped. It can take a while. You'll receive a notification when the silent mode will be stopped", comment : "The silent mode is being stopped. It can take a while. You'll receive a notification when the silent mode will be stopped"),
                                delegate: nil, cancelButtonTitle: "Ok")
                            alert.show()
                        })
                        
                        
                    })
                    
                }
            })
            
        }
    }
    
    
    
    // MARK : Table View DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Friends"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:MuteAllFriendsTableViewCell = tableView.dequeueReusableCellWithIdentifier("muteAllCell") as MuteAllFriendsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.loadCell(self.friends[indexPath.row])
        
        
        var arrayFriendsId:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
        if arrayFriendsId!.count > friends.count{
            if indexPath.row == (friends.count - 10){
                if friends.count > 0 && !isLoadingMore{
                    if friends.count % 100 == 0{
                        println("Load More")
                        isLoadingMore = true
                        getMoreFriends()
                    }
                }
            }
        }
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:MuteAllFriendsTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as MuteAllFriendsTableViewCell
        cell.muteSelect()
        
    }
    
    
    // MARK : Get Friends
    
    func getFriends(){
        
        var arrayFriendsId:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
        
        if arrayFriendsId != nil{
            var queryFriends:PFQuery = PFUser.query()
            queryFriends.whereKey("objectId", containedIn: arrayFriendsId!)
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = kPFCachePolicyCacheThenNetwork
            queryFriends.limit = 100
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    self.friends = friends as Array<PFUser>
                    self.tableView.reloadData()
                    
                }
            }
        }
        
    }
    
    
    func getMoreFriends(){
        
        
        var arrayFriendsId:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
        
        
        if arrayFriendsId != nil {
            var queryFriends:PFQuery = PFUser.query()
            queryFriends.whereKey("objectId", containedIn: arrayFriendsId!)
            queryFriends.orderByAscending("username")
            queryFriends.limit = 100
            queryFriends.skip = friends.count
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    
                    for friend in friends as Array<PFUser>{
                        self.friends.append(friend)
                        indexPathToInsert.append(NSIndexPath(forRow: self.friends.count - 1, inSection: 0))
                    }

                    
                }
            }
        }
        
    }
    
}
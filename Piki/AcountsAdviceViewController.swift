//
//  AcountsAdviceViewController.swift
//  Peekee
//
//  Created by Adrien Dulong on 07/01/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation
import CoreTelephony


protocol AccountsCellProtocol{
    
    func addFriend(user : PFUser)
    
}

class AccountsTableViewCell : UITableViewCell{
    
    var accountImageView:UIImageView!
    var dividerBottomView:UIView!
    var usernameLabel:UILabel!
    var descriptionLabel:UILabel!
    var actionbutton:UIButton!
    var loadIndicator:UIActivityIndicatorView!
    
    var user:PFUser!
    var delegate:AccountsCellProtocol! = nil
    var alreadyAdded:Bool!
    
    
    
    func loadCell(user : PFUser, alreadyAdded : Bool, cellDelegate : AccountsCellProtocol){
        
        self.user = user
        self.delegate = cellDelegate
        self.alreadyAdded = alreadyAdded
        
        
        //Set UI Elements
        if accountImageView == nil{
            accountImageView = UIImageView(frame: CGRect(x: 15, y: 10, width: 55, height: 55))
            accountImageView.layer.cornerRadius = 5
            accountImageView.clipsToBounds = true
            contentView.addSubview(accountImageView)
        }
        
        if dividerBottomView == nil {
            dividerBottomView = UIView(frame: CGRect(x: 0, y: 73, width: UIScreen.mainScreen().bounds.width, height: 2))
            dividerBottomView.backgroundColor = Utils().primaryColorDark
            contentView.addSubview(dividerBottomView)
        }
        
        if usernameLabel == nil{
            usernameLabel = UILabel(frame: CGRect(x: 90, y: 18, width: 250, height: 20))
            usernameLabel.font = UIFont(name: Utils().customFontSemiBold, size: 21)
            usernameLabel.textColor = UIColor.whiteColor()
            contentView.addSubview(usernameLabel)
        }
        
        
        if actionbutton == nil{
            actionbutton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 60, y: 16, width: 40, height: 41))
            actionbutton.setImage(UIImage(named: "add_friend_first_screen"), forState: UIControlState.Normal)
            actionbutton.addTarget(self, action: Selector("addFriend"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionbutton)
        }
        
        
        if descriptionLabel == nil{
            descriptionLabel = UILabel(frame: CGRect(x: 90, y: 45, width: UIScreen.mainScreen().bounds.width - 60 - 90, height: 15))
            descriptionLabel.font = UIFont(name: Utils().customFontNormal, size: 14)
            descriptionLabel.textColor = UIColor(red: 121/255, green: 134/255, blue: 202/255, alpha: 1.0)
            descriptionLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(descriptionLabel)
        }
        
        if loadIndicator == nil{
            loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            loadIndicator!.tintColor = Utils().secondColor
            loadIndicator.center = actionbutton!.center
            loadIndicator.hidesWhenStopped = true
            loadIndicator.stopAnimating()
            self.addSubview(loadIndicator)
        }
        
        
        if !alreadyAdded {
            actionbutton.setImage(UIImage(named: "add_friend_first_screen"), forState: UIControlState.Normal)
        }
        else{
            actionbutton.setImage(UIImage(named: "friend_added_first_screen"), forState: UIControlState.Normal)
        }
        
        //Set with user infos
        usernameLabel.text = "@\(self.user.username)"
        descriptionLabel.text = self.user["recommendDescription"] as? String
        
        let imageFile:PFFile? = self.user["recommendPicture"] as? PFFile
        if imageFile != nil{
            imageFile!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                self.accountImageView.image = UIImage(data: data)
            })
        }
        
        
        
    }
    
    
    func addFriend(){
        
        if !self.alreadyAdded{
            self.delegate.addFriend(self.user)
            actionbutton.setImage(UIImage(named: "friend_added_first_screen"), forState: UIControlState.Normal)
        }
        
        
    }
    
    
}


class AcountsAdviceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccountsCellProtocol {
    
    @IBOutlet weak var topInfosView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var topConstraintsInfoView: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goView: UIView!
    @IBOutlet weak var letsGoLabel: UILabel!
    
    var recommandedUsers:Array<PFUser> = Array<PFUser>()
    var usersAdded:Array<PFUser> = Array<PFUser>()
    var regionLabel:String?
    
    override func viewDidLoad() {
        
        //Adapt position depending device
        if Utils().isIphone4(){
            topConstraintsInfoView.constant = 5
            
            var stretchShadowImageTop:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            let shadowImageViewTop:UIImageView = UIImageView(frame: CGRect(x: 0, y: tableView.frame.origin.y - 15, width: UIScreen.mainScreen().bounds.width, height: 4))
            shadowImageViewTop.image = stretchShadowImageTop
            self.view.addSubview(shadowImageViewTop)
        }
        else if Utils().isIphone5(){
            topConstraintsInfoView.constant = 25
            
            var stretchShadowImageTop:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            let shadowImageViewTop:UIImageView = UIImageView(frame: CGRect(x: 0, y: tableView.frame.origin.y + 5, width: UIScreen.mainScreen().bounds.width, height: 4))
            shadowImageViewTop.image = stretchShadowImageTop
            self.view.addSubview(shadowImageViewTop)
        }
        else if Utils().isIphone6Plus(){
            topConstraintsInfoView.constant = 40
            
            var stretchShadowImageTop:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            let shadowImageViewTop:UIImageView = UIImageView(frame: CGRect(x: 0, y: tableView.frame.origin.y + 20, width: UIScreen.mainScreen().bounds.width, height: 4))
            shadowImageViewTop.image = stretchShadowImageTop
            self.view.addSubview(shadowImageViewTop)
        }
        else{
            topConstraintsInfoView.constant = 30
            
            var stretchShadowImageTop:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            let shadowImageViewTop:UIImageView = UIImageView(frame: CGRect(x: 0, y: tableView.frame.origin.y + 10, width: UIScreen.mainScreen().bounds.width, height: 4))
            shadowImageViewTop.image = stretchShadowImageTop
            self.view.addSubview(shadowImageViewTop)
        }
        
        subtitleLabel.text = NSLocalizedString("Here are some cool people who are already using the app", comment :"Here are some cool people who are already using the app")
        letsGoLabel.text = NSLocalizedString("Let's GO!", comment :"Let's GO!")
        
        //Shadow for bottom button
        var stretchShadowImage:UIImage = UIImage(named: "shadow_tuto")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: self.view.frame.height - 59 , width: UIScreen.mainScreen().bounds.width, height: 4))
        shadowImageView.image = stretchShadowImage
        self.view.addSubview(shadowImageView)
        
        tableView.backgroundColor = Utils().primaryColor
        
        //Tap Gesture to go
        let tapGestureToGo:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("goLeave"))
        goView.addGestureRecognizer(tapGestureToGo)
        
        
        //Get country code
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        if carrier != nil{
            regionLabel = carrier.isoCountryCode
            
            if regionLabel == nil{
                regionLabel = "us"
            }
        }
        else{
            regionLabel = "us"
        }

        getRecommendedUsers()
        
        //Shadow for bottom button
        
        
        
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    // MARK : Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommandedUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:AccountsTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as AccountsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.loadCell(recommandedUsers[indexPath.row], alreadyAdded: isUserAlreadyAdded(recommandedUsers[indexPath.row]), cellDelegate : self)
        
        return cell
        
    }
    
    
    // MARK : Server Requests
    
    func getRecommendedUsers(){
        
        var userQuery:PFQuery = PFUser.query()
        userQuery.whereKey("isRecommend", equalTo: true)
        userQuery.whereKey("recommendLocalisation", equalTo: self.regionLabel!)
        userQuery.orderByAscending("recommendOrder")
        userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            if error == nil {
                
                self.recommandedUsers = users as Array<PFUser>
            }
            else{
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    // MARK : Accounts Cell Protocol
    
    func addFriend(user: PFUser) {
        
        println("Add friend : \(user.objectId) & \(user.username)")
        
        var bgTaskIdentifierAddFriend:UIBackgroundTaskIdentifier?
        
        //Start a background task
        bgTaskIdentifierAddFriend = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierAddFriend!)
            bgTaskIdentifierAddFriend = UIBackgroundTaskInvalid
        })
        
        Utils().addFriend(user.objectId).continueWithBlock { (task) -> AnyObject! in
            if task.error != nil{
                
            }
            else{
                self.usersAdded.append(user)
            }
            
            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierAddFriend!)
            bgTaskIdentifierAddFriend = UIBackgroundTaskInvalid
            
            return nil
        }
    }
    
    
    // MARK : Utils Function
    func isUserAlreadyAdded(user : PFUser) -> Bool{
        
        for userAdded in usersAdded{
            
            if userAdded.objectId == user.objectId{
                return true
            }
            
        }
        
        for userAddedId in PFUser.currentUser()["usersFriend"] as Array<String>{
            if userAddedId == user.objectId{
                return true
            }
        }
        
        return false
        
    }
    
    // MARK : Leave
    
    func goLeave(){
        
        PFUser.currentUser()["hasSeenRecommanded"] = true
        PFUser.currentUser().saveInBackgroundWithBlock { (finished, error) -> Void in
            PFUser.currentUser().fetchInBackgroundWithBlock({ (user, error) -> Void in
                println("UPDATE USER")
            })
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    
    
    
    
}
